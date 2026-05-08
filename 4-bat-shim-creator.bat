@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  Generates relocatable .bat wrappers for all console_scripts
::  entry points found in the portable Python's site-packages.
::
::  Run this after moving or renaming the root folder to create
::  alternative .bat shims for broken .exe shims.
::
::  Usage: 4-bat-shim-creator.bat [/nopause]
:: ============================================================


set "ROOT_DIR=%~dp0dependencies"
set "PYTHON_EXE=%ROOT_DIR%\python\python.exe"
set "HELPER=%ROOT_DIR%\helper_scripts\create-shims.py"

:: ── /nopause flag ────────────────────────────────────────────
set "NOPAUSE=0"
if /i "%~1"=="/nopause" set "NOPAUSE=1"


if not exist "%PYTHON_EXE%" (
    echo [ERROR] python.exe not found at: %PYTHON_EXE%
    echo         Please run 2-python-downloader.bat first.
    goto :error
)
echo [OK]   Found Python: %PYTHON_EXE%


"%PYTHON_EXE%" "%HELPER%"
if errorlevel 1 (
    echo.
    echo [ERROR] Shim generation encountered errors. See output above.
    goto :error
)

echo.
echo ============================================================
echo  Script ran successfully.
echo ============================================================
goto :done

:error
echo.
echo [FAIL] The script encountered an error. See messages above.
if "%NOPAUSE%"=="0" pause
exit /b 1

:done
echo.
if "%NOPAUSE%"=="0" pause
exit /b 0