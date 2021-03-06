@echo off

@rem Change the working directory to the location of this file so that relative paths will work
cd /D "%~dp0"

@rem Make sure the environment variables are up-to-date. This is useful if the user installed python a moment ago.
call ./RefreshEnv.cmd

python -V >nul 2>&1 && (
    for /f "delims=" %%a in ('python -V') do @set pythonVer=%%a
    (echo %pythonVer% | findstr /i "3.6. 3.7." >nul) && (
        goto continue
    ) || (
        echo It appears that version of the installed Python is not supported.
        echo Please install version 3.6.5!
        goto end
    )
) || (
    echo Python was not found!
    echo If you recently installed Python reinstall it and check the "Add to PATH" during the installation.
    goto end
)
:continue

setlocal EnableDelayedExpansion

@rem Run the is_safe_to_upgrade function and save the output to a temp file.
python -c "from rlbot.utils import public_utils; print(public_utils.is_safe_to_upgrade());" > %temp%\is_safe_to_upgrade.txt

IF %ERRORLEVEL% NEQ 0 (
    @rem The python command failed, so rlbot is probably not installed at all. Safe to 'upgrade'.
    set is_safe_to_upgrade=True
) ELSE (
    @rem read the file containing the python output.
    set /p is_safe_to_upgrade= < %temp%\is_safe_to_upgrade.txt
)
del %temp%\is_safe_to_upgrade.txt

IF "!is_safe_to_upgrade!"=="True" (
    python -m pip install -r requirements.txt --upgrade
) ELSE (
    echo Will not attempt to upgrade rlbot because files are in use.
)

python -c "from rlbot.gui.qt_root import RLBotQTGui; RLBotQTGui.main();"

:end
pause
