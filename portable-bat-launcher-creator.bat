@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  Generates relocatable .bat wrappers for all console_scripts
::  entry points found in the portable Python's site-packages.
::
::  Usage: portable-bat-launcher-creator.bat [/nopause]
:: ============================================================

call "%~dp0dependencies\_config.bat"

set "HELPER=%HELPER_SCRIPTS_DIR%\create-shims.py"


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
endlocal
if /i "%~1" neq "/nopause" pause
exit /b 1

:done
echo.
endlocal
if /i "%~1" neq "/nopause" pause
exit /b 0
