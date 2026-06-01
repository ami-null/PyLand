@echo off
:: Shared path configuration.
:: Do NOT add setlocal here — callers own their own scope.
:: %~dp0 here refers to this file's own directory, so keep all scripts in the same folder.

set "ROOT_DIR=%~dp0dependencies"
set "UV_DIR=%ROOT_DIR%\uv"
set "UV_EXE=%UV_DIR%\uv.exe"
set "PYTHON_DIR=%ROOT_DIR%\python"
set "PYTHON_EXE=%PYTHON_DIR%\python.exe"
set "SCRIPTS_DIR=%PYTHON_DIR%\Scripts"
set "HELPER_SCRIPTS_DIR=%ROOT_DIR%\helper_scripts"
set "REQ_FILE=%~dp0requirements.txt"
