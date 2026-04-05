@echo off
setlocal enabledelayedexpansion

:: Configuration
set "ROOT_DIR=%~dp0python_and_vscode"
set "UV_DIR=%ROOT_DIR%\uv"
set "TEMP_ZIP=%TEMP%\uv_download.zip"

echo Setting up uv...

:: Check if directory exists
if exist "%UV_DIR%" (
    set /p "choice=The 'uv' folder already exists. Overwrite? (Y/N): "
    if /i "!choice!" neq "Y" (
        echo Skipping uv download.
        exit /b 0
    )
    rd /s /q "%UV_DIR%"
)

:: Ensure root and uv directory exists
if not exist "%UV_DIR%" mkdir "%UV_DIR%"

echo Fetching latest release info from GitHub...

:: PowerShell logic for API parsing and downloading
powershell -ExecutionPolicy Bypass -Command ^
    "$arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'aarch64' } else { 'x86_64' };" ^
    "$uri = 'https://api.github.com/repos/astral-sh/uv/releases/latest';" ^
    "$response = Invoke-RestMethod -Uri $uri;" ^
    "$asset = $response.assets | Where-Object { $_.name -like \"*-$arch-pc-windows-msvc.zip\" } | Select-Object -First 1;" ^
    "if (-not $asset) { Write-Error 'Could not find a matching Windows zip asset.'; exit 1 };" ^
    "Write-Host \"Downloading $($asset.name)...\";" ^
    "Invoke-WebRequest -Uri $asset.browser_download_url -OutFile '%TEMP_ZIP%';" ^
    "Write-Host 'Extracting...';" ^
    "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%UV_DIR%_temp' -Force;" ^
    "$exe = Get-ChildItem -Path '%UV_DIR%_temp' -Filter 'uv.exe' -Recurse | Select-Object -First 1;" ^
    "if ($exe) { Move-Item -Path $exe.FullName -Destination '%UV_DIR%\' -Force };" ^
    "if (Test-Path '%UV_DIR%_temp') { Remove-Item -Path '%UV_DIR%_temp' -Recurse -Force };" ^
    "if (Test-Path '%TEMP_ZIP%') { Remove-Item -Path '%TEMP_ZIP%' -Force };"

if %ERRORLEVEL% equ 0 (
    echo uv successfully set up in %UV_DIR%
    "%UV_DIR%\uv.exe" --version
) else (
    echo Failed to set up uv.
    exit /b 1
)

if "%~1" neq "/nopause" pause