@echo off
setlocal enabledelayedexpansion

call "%~dp0_config.bat"

set UV_SYSTEM_PYTHON=1
set "UV_PYTHON=%PYTHON_EXE%"
set UV_LINK_MODE=copy

echo Installing Python packages...

:: Validation
if not exist "%UV_EXE%" (
    echo ERROR: uv.exe not found. Run 1-uv-downloader.bat first.
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

if not exist "%PYTHON_EXE%" (
    echo ERROR: python.exe not found in %ROOT_DIR%\python.
    echo Run 2-python-downloader.bat first.
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

if not exist "%REQ_FILE%" (
    echo WARNING: requirements.txt not found at %REQ_FILE%.
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

echo Using uv to install packages into the portable environment...
echo Targeted Python: %PYTHON_EXE%

:: Run uv pip install.
:: The --python flag tells uv exactly which environment to populate.
"%UV_EXE%" pip install --upgrade --break-system-packages -r "%REQ_FILE%" --python "%PYTHON_EXE%" --force-reinstall
set "INSTALL_ERR=%ERRORLEVEL%"

if %INSTALL_ERR% neq 0 (
    echo.
    echo Failed to install packages. Please check the error messages above.
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

echo.
echo Packages successfully installed.

endlocal
if /i "%~1" neq "/nopause" pause