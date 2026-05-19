@echo off
setlocal enabledelayedexpansion

:: Configuration
set "ROOT_DIR=%~dp0dependencies"
set "UV_DIR=%ROOT_DIR%\uv"
set "HELPER_SCRIPTS_DIR=%ROOT_DIR%\helper_scripts"
set "TEMP_ZIP=%TEMP%\uv_download_latest.zip"

set "GH_USER=astral-sh"
set "GH_REPO=uv"

:: Detect CPU architecture
set "ARCH=x86_64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64"   set "ARCH=aarch64"
if /i "%PROCESSOR_ARCHITEW6432%"=="ARM64"   set "ARCH=aarch64"
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" (
    if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "ARCH=x86_64"
    if /i "%PROCESSOR_ARCHITEW6432%"==""      set "ARCH=i686"
)
echo Detected architecture: !ARCH!

:: Build the artifact name that uv uses for this platform
set "ARTIFACT=uv-!ARCH!-pc-windows-msvc.zip"


:: Check if uv.exe already exists
if exist "%UV_DIR%\uv.exe" (
    set /p "choice=The 'uv' tool already exists. Overwrite and download the latest version? (Y/N): "
    if /i "!choice!" neq "Y" (
        echo Skipping uv download.
        exit /b 0
    )
    rd /s /q "%UV_DIR%" 2>nul
)


echo Setting up uv...
:: Ensure uv directory exists
if not exist "%UV_DIR%" mkdir "%UV_DIR%"



:: Attempt to download the latest uv release zip file from GitHub without using the GitHub API:
set "DOWNLOAD_URL=https://github.com/%GH_USER%/%GH_REPO%/releases/latest/download/!ARTIFACT!"
echo Trying to download using URL: !DOWNLOAD_URL!
 
curl -fSL --progress-bar -o "%TEMP_ZIP%" "!DOWNLOAD_URL!"
if %ERRORLEVEL% equ 0 (
    echo Download complete.
    goto :extract
)
 
echo WARNING: download failed. Falling back to the GitHub API...


:: Fetch download URL using GitHub API via helper script:
if not exist "%HELPER_SCRIPTS_DIR%\get-gh-release.bat" (
    echo ERROR: Helper script not found at "%HELPER_SCRIPTS_DIR%\get-gh-release.bat" >&2
    echo        Both download methods have failed. >&2
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)

echo Resolving latest release URL via GitHub API...
set "DOWNLOAD_URL="
for /f "delims=" %%U in ('call "%HELPER_SCRIPTS_DIR%\get-gh-release.bat" %GH_USER% %GH_REPO% windows !ARCH! zip msvc -sha256') do (
    set "DOWNLOAD_URL=%%U"
)
 
if "!DOWNLOAD_URL!"=="" (
    echo ERROR: Could not resolve download URL via GitHub API either. >&2
    if exist "%TEMP_ZIP%" del /q "%TEMP_ZIP%"
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)
 
echo Trying to download using URL: !DOWNLOAD_URL!
curl -fSL --progress-bar -o "%TEMP_ZIP%" "!DOWNLOAD_URL!"
if %ERRORLEVEL% neq 0 (
    echo ERROR: curl failed ^(exit code %ERRORLEVEL%^) on fallback download. >&2
    if exist "%TEMP_ZIP%" del /q "%TEMP_ZIP%"
    if /i "%~1" neq "/nopause" pause
    exit /b 1
)
echo Download complete.



:extract
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