@echo off
setlocal

call "%~dp0_config.bat"

set "JUPYTER_EXE=%SCRIPTS_DIR%\jupyter-lab.exe"

:: Check for jupyter-lab.exe as a proxy for whether jupyterlab is installed
if not exist "%JUPYTER_EXE%" (
    echo ERROR: Jupyter Lab not found.
    echo Ensure 'jupyterlab' is in your requirements.txt and run 3-python-pkgs-installer.bat.
    endlocal
    pause
    exit /b 1
)

echo Initializing Portable Jupyter Environment...

call "%~dp0_activate.bat"

if not exist notebooks mkdir notebooks

:: Launch Jupyter Lab
echo Launching Jupyter Lab...

"%PYTHON_EXE%" -m jupyterlab --log-level=ERROR --notebook-dir=./notebooks
set "JUPYTER_EXIT=%ERRORLEVEL%"

echo.
if %JUPYTER_EXIT% neq 0 (
    echo Jupyter Lab exited with an error ^(exit code %JUPYTER_EXIT%^).
    echo Check the output above for details.
) else (
    echo Jupyter Lab exited.
)
pause
