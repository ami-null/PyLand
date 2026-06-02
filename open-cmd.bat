@echo off
setlocal

call "%~dp0dependencies\helper_scripts\_config.bat"

:: Validation
if not exist "%PYTHON_EXE%" (
    echo ERROR: Portable Python not found.
    endlocal
    pause
    exit /b 1
)

if not exist "%UV_EXE%" (
    echo ERROR: uv not found.
    endlocal
    pause
    exit /b 1
)

call "%~dp0dependencies\helper_scripts\_activate.bat"

if not exist notebooks mkdir notebooks

echo ====================================================
echo   PORTABLE SHELL ACTIVATED
echo ====================================================
echo  Python: %PYTHON_DIR%
echo  uv:     %UV_DIR%
echo ====================================================
echo.

:: /K keeps the window open and executes the following commands
cmd /K "echo the following tools are available: & echo. & python --version & uv --version"

exit /b 0
