@echo off
setlocal enabledelayedexpansion

:: Configuration
set "ROOT_DIR=%~dp0dependencies"
set "UV_DIR=%ROOT_DIR%\uv"
set "HELPER_SCRIPTS_DIR=%ROOT_DIR%\helper_scripts"
set "TEMP_ZIP=%TEMP%\uv_download_latest.zip"

echo Setting up uv...

:: Check if uv.exe already exists
if exist "%UV_DIR%\uv.exe" (
    set /p "choice=The 'uv' tool already exists. Overwrite and download the latest version? (Y/N): "
    if /i "!choice!" neq "Y" (
        echo Skipping uv download.
        exit /b 0
    )
    rd /s /q "%UV_DIR%" 2>nul
)

:: Ensure uv directory exists
if not exist "%UV_DIR%" mkdir "%UV_DIR%"

echo Resolving latest release information from GitHub...

set "GH_USER=astral-sh"
set "GH_REPO=uv"

:: Call the helper script to resolve the URL
for /f "delims=" %%U in ('call "%HELPER_SCRIPTS_DIR%\get-gh-release.bat" %GH_USER% %GH_REPO% windows x86_64 zip msvc -sha256') do (
    set "DOWNLOAD_URL=%%U"
)

if "!DOWNLOAD_URL!"=="" (
    echo ERROR: Could not resolve direct download URL. >&2
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

echo Downloading: !DOWNLOAD_URL!

:: -f (fail silently), -S (show errors), -L (follow redirects)
curl -fSL --progress-bar -o "%TEMP_ZIP%" "!DOWNLOAD_URL!"
if %ERRORLEVEL% neq 0 (
    echo ERROR: curl failed ^(exit code %ERRORLEVEL%^) while downloading: >&2
    echo        %DOWNLOAD_URL% >&2
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)
echo Download complete.

echo Extracting uv.exe...
:: Find uv.exe in the zip archive, extract it directly to stdout, and write to target
set "FOUND_EXE=0"
for /f "delims=" %%F in ('tar -tf "%TEMP_ZIP%" ^| findstr /i "uv\.exe$"') do (
    tar -xOf "%TEMP_ZIP%" "%%F" > "%UV_DIR%\uv.exe"
    set "FOUND_EXE=1"
    goto :done_extract
)

:done_extract
:: Cleanup the temporary zip file
if exist "%TEMP_ZIP%" del /q "%TEMP_ZIP%"

:: Verify whether extraction succeeded
if "%FOUND_EXE%"=="1" if exist "%UV_DIR%\uv.exe" (
    echo Extraction complete. uv successfully set up in "%UV_DIR%"
    "%UV_DIR%\uv.exe" --version
) else (
    echo ERROR: Failed to extract or locate uv.exe within the archive. >&2
    exit /b 1
)

if /i "%~1" neq "/nopause" pause