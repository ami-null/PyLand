@echo off
setlocal

:: Configuration
set "ROOT_DIR=%~dp0dependencies"
set "PYTHON_DIR=%ROOT_DIR%\python"
set "SCRIPTS_DIR=%PYTHON_DIR%\Scripts"
set "JUPYTER_EXE=%SCRIPTS_DIR%\jupyter-lab.exe"
set "UV_DIR=%ROOT_DIR%\uv"
set "CUSTOM_SCRIPTS_DIR=%~dp0custom_scripts"

set UV_LINK_MODE=copy
set UV_PYTHON_INSTALL_BIN=0
set UV_BREAK_SYSTEM_PACKAGES=true

:: 1. Validation
if not exist "%JUPYTER_EXE%" (
    echo ERROR: Jupyter Lab not found. 
    echo Ensure 'jupyterlab' is in your requirements.txt and run 03_install_packages.bat.
    pause
    exit /b 1
)

echo Initializing Portable Jupyter Environment...

:: Set Portable Paths (Current Session Only)
set "PATH=%CUSTOM_SCRIPTS_DIR%;%PYTHON_DIR%;%SCRIPTS_DIR%;%UV_DIR%;%PATH%"

:: Set Python Home to ensure it stays internal
set "PYTHONHOME=%PYTHON_DIR%"

:: Redirect Jupyter's internal storage to our portable root
:: This prevents Jupyter from writing to C:\Users\Name\AppData
set "JUPYTER_CONFIG_DIR=%ROOT_DIR%\.jupyter_config"
set "JUPYTER_DATA_DIR=%ROOT_DIR%\.jupyter_data"
set "JUPYTER_RUNTIME_DIR=%ROOT_DIR%\.jupyter_runtime"

:: Create these directories if they don't exist
if not exist "%JUPYTER_CONFIG_DIR%" mkdir "%JUPYTER_CONFIG_DIR%"
if not exist "%JUPYTER_DATA_DIR%" mkdir "%JUPYTER_DATA_DIR%"


if not exist notebooks mkdir notebooks

:: Launch Jupyter Lab
echo Launching Jupyter Lab...

:: Launching in the current directory
"%PYTHON_DIR%\python.exe" -m jupyterlab --log-level=ERROR --notebook-dir=./notebooks

echo.
echo Jupyter Lab exited.
pause