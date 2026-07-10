@echo off
setlocal enabledelayedexpansion

echo ============================================
echo  PyLand First-Time Setup
echo ============================================
echo.
echo This will run, in order:
echo   1. Download/update uv
echo   2. Download/install portable Python
echo   3. Install Python packages from requirements.txt
echo.

call "%~dp01_update-uv.bat" /nopause
set "ERR=%ERRORLEVEL%"
if !ERR! neq 0 (
    echo.
    echo ERROR: 1_update-uv.bat failed with exit code !ERR!. Aborting setup. >&2
    endlocal
    pause
    exit /b 1
)

echo.
call "%~dp02_update-python.bat" /nopause
set "ERR=%ERRORLEVEL%"
if !ERR! neq 0 (
    echo.
    echo ERROR: 2_update-python.bat failed with exit code !ERR!. Aborting setup. >&2
    endlocal
    pause
    exit /b 1
)

echo.
call "%~dp03_update-python-pkgs.bat" /nopause
set "ERR=%ERRORLEVEL%"
if !ERR! neq 0 (
    echo.
    echo ERROR: 3_update-python-pkgs.bat failed with exit code !ERR!. Aborting setup. >&2
    endlocal
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Setup complete.
echo ============================================

endlocal
pause
