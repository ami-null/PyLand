@echo off
:: "%UV_EXE%" is set by the _config.bat script
"%UV_EXE%" pip %*
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
if /i "%1" == "install" (
    if not defined SKIP_PORTABLIZE "%PYTHON_EXE%" "%HELPER_SCRIPTS_DIR%\make-portable-exe.py"
)