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


set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "PYTHON_EXE=%ROOT%\dependencies\python\python.exe"
set "HELPER=%ROOT%\dependencies\helper_scripts\create-shims.py"

:: ── /nopause flag ────────────────────────────────────────────
set "NOPAUSE=0"
if /i "%~1"=="/nopause" set "NOPAUSE=1"


:: ── Verify prerequisites ─────────────────────────────────────
if not exist "%PYTHON_EXE%" (
    echo [ERROR] python.exe not found at: %PYTHON_EXE%
    echo         Please run 2-python-downloader.bat first.
    goto :error
)
echo [OK]   Found Python: %PYTHON_EXE%


:: ── Run the helper ───────────────────────────────────────────
"%PYTHON_EXE%" "%HELPER%"
if errorlevel 1 (
    echo.
    echo [ERROR] Shim generation encountered errors. See output above.
    goto :error
)

echo.
echo ============================================================
echo  Shims created successfully.
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