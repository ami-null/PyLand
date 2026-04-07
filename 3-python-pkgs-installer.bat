@echo off
setlocal enabledelayedexpansion

:: Configuration
set "ROOT_DIR=%~dp0dependencies"
set "UV_EXE=%ROOT_DIR%\uv\uv.exe"
set "PYTHON_EXE=%ROOT_DIR%\python\python.exe"
set "REQ_FILE=%~dp0requirements.txt"

set UV_LINK_MODE=copy

echo Installing Python packages...

:: Validation
if not exist "%UV_EXE%" (
    echo ERROR: uv.exe not found. Run 01_download_uv.bat first.
    exit /b 1
)

if not exist "%PYTHON_EXE%" (
    echo ERROR: python.exe not found in %ROOT_DIR%\python. 
    echo Run 02_download_python.bat first.
    exit /b 1
)

if not exist "%REQ_FILE%" (
    echo WARNING: requirements.txt not found at %REQ_FILE%.
    echo Creating a blank requirements.txt for you...
    echo # Add your packages here > "%REQ_FILE%"
)

echo Using uv to install packages into the portable environment...
echo Targeted Python: %PYTHON_EXE%

:: Run uv pip install
:: The --python flag tells uv exactly which environment to populate
"%UV_EXE%" pip install --upgrade --break-system-packages -r "%REQ_FILE%" --python "%PYTHON_EXE%"

if %ERRORLEVEL% equ 0 (
    echo.
    echo Packages successfully installed.
    echo You can verify them by running: "%PYTHON_EXE%" -m pip list
) else (
    echo.
    echo Failed to install packages. Please check the error messages above.
    exit /b 1
)

if "%~1" neq "/nopause" pause