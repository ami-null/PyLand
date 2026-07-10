@echo off
setlocal enabledelayedexpansion

call "%~dp0dependencies\_config.bat"

set "INSTALL_TEMP=%PYTHON_DIR%\_temp_install"

:: Use UV_PYTHON_INSTALL_DIR to redirect the toolchain installation.
:: We install into a temp folder first to flatten the structure.
set "UV_PYTHON_INSTALL_DIR=%INSTALL_TEMP%"
set UV_PYTHON_INSTALL_BIN=0
set UV_PYTHON_INSTALL_REGISTRY=0

:: Check if uv exists
if not exist "%UV_EXE%" (
    echo ERROR: uv.exe not found. Run 1_update-uv.bat first.
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

:: Check if directory exists
if exist "%PYTHON_DIR%" (
    echo WARNING: The 'python' folder already exists.
    echo Redownloading will DELETE the current Python AND all its installed packages.
    set /p "choice=Confirm deletion and redownload? (Y/N): "
    if /i "!choice!" neq "Y" (
        echo Skipping Python setup.
        endlocal
        if /i "%~1" neq "/nopause" pause
        exit /b 0
    )
    rd /s /q "%PYTHON_DIR%"
)

:: Interactive version selection
echo.
REM set /p "PY_VER=Enter Python version (e.g., 3.12, 3.11, or leave empty for latest): "
for /f "usebackq tokens=*" %%V in ("%~dp0python-version.txt") do set "PY_VER=%%V"

mkdir "%PYTHON_DIR%"
mkdir "%INSTALL_TEMP%"

echo.
echo Downloading Python %PY_VER%

"%UV_EXE%" python install %PY_VER%

if %ERRORLEVEL% neq 0 (
    echo.
    echo Failed to download Python. Check your version string or internet connection.
    rd /s /q "%PYTHON_DIR%"
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

echo.
:: uv installs into subdirectories like 'cpython-3.12.2-windows-x86_64-none'
:: We find the python.exe and move everything in its parent folder to root\python
set "FOUND_PYTHON_DIR="
for /f "delims=" %%I in ('dir /s /b "%INSTALL_TEMP%\python.exe" 2^>nul') do (
    if not defined FOUND_PYTHON_DIR set "FOUND_PYTHON_DIR=%%~dpI"
)

if not defined FOUND_PYTHON_DIR (
    echo Could not locate python.exe in the downloaded package.
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

:: Move all files from the found directory
move /Y "%FOUND_PYTHON_DIR%*" "%PYTHON_DIR%\" >nul 2>&1
:: Move all subdirectories from the found directory
for /d %%D in ("%FOUND_PYTHON_DIR%*") do (
    move /Y "%%D" "%PYTHON_DIR%\" >nul 2>&1
)

:: Cleanup temp install folder
rd /s /q "%INSTALL_TEMP%"

echo.
echo Installed Python version:
"%PYTHON_EXE%" --version



set "SKIP_PORTABLIZE=1"
call "%HELPER_SCRIPTS_DIR%\pip.bat" install distlib --system --break-system-packages --python "%PYTHON_EXE%" --link-mode=copy
set "SKIP_PORTABLIZE="
set "INSTALL_ERR=%ERRORLEVEL%"

if %INSTALL_ERR% neq 0 (
    echo.
    echo Failed to install the distlib package. Please check the error messages above.
    endlocal
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)


endlocal
if /i "%~1" neq "/nopause" pause
