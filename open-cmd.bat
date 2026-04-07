@echo off
setlocal

:: Configuration
set "ROOT_DIR=%~dp0pytools"
set "PYTHON_DIR=%ROOT_DIR%\python"
set "SCRIPTS_DIR=%PYTHON_DIR%\Scripts"
set "UV_DIR=%ROOT_DIR%\uv"
set "CUSTOM_SCRIPTS_DIR=%~dp0custom_scripts"

:: 1. Validation
if not exist "%PYTHON_DIR%\python.exe" (
    echo ERROR: Portable Python not found.
    pause
    exit /b 1
)

if not exist "%UV_DIR%\uv.exe" (
    echo ERROR: uv not found.
    pause
    exit /b 1
)

:: 2. Environment Setup (Session Only)
:: Prepend Python, Scripts, and uv to the PATH
set "PATH=%CUSTOM_SCRIPTS_DIR%;%PYTHON_DIR%;%SCRIPTS_DIR%;%UV_DIR%;%PATH%"

:: Set Python Home to ensure it stays internal
set "PYTHONHOME=%PYTHON_DIR%"

echo ====================================================
echo   PORTABLE SHELL ACTIVATED
echo ====================================================
echo  Python: %PYTHON_DIR%
echo  uv:     %UV_DIR%
echo ====================================================
echo.

:: 3. Launch CMD
:: /K keeps the window open and executes the following commands
cmd /K "echo the following tools are available: & echo. & python --version & uv --version"

exit /b 0