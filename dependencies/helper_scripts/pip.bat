@echo off
uv pip %*
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

if /i "%1" == "install" "%PYTHON_EXE%" "%HELPER_SCRIPTS_DIR%\make-portable-exe.py"