@echo off
:: Shared path configuration.
:: Do NOT add setlocal here. Callers set it inside their own scope.
:: %~dp0 here refers to this file's own directory (dependencies\).

set "ROOT_DIR=%~dp0"
set "UV_DIR=%ROOT_DIR%uv"
set "UV_EXE=%UV_DIR%\uv.exe"
set "UV_CACHE_DIR=%ROOT_DIR%uv_cache"
set "PYTHON_DIR=%ROOT_DIR%python"
set "PYTHON_EXE=%PYTHON_DIR%\python.exe"
set "SCRIPTS_DIR=%PYTHON_DIR%\Scripts"
set "HELPER_SCRIPTS_DIR=%ROOT_DIR%helper_scripts"
set "REQ_FILE=%~dp0..\requirements.txt"
