@echo off
:: Shared environment activation for launcher scripts.
:: Do NOT add setlocal here — callers own their own scope.
:: Must be called AFTER _config.bat, as it depends on vars set there.

set UV_LINK_MODE=copy
set UV_PYTHON_INSTALL_BIN=0
set UV_BREAK_SYSTEM_PACKAGES=true
set UV_SYSTEM_PYTHON=1
set "UV_PYTHON=%PYTHON_EXE%"
set UV_PYTHON_INSTALL_REGISTRY=0

set PIP_BREAK_SYSTEM_PACKAGES=1

:: Prepend portable tools to the PATH (session only)
set "PATH=%PYTHON_DIR%;%HELPER_SCRIPTS_DIR%;%SCRIPTS_DIR%;%UV_DIR%;%PATH%"

:: Lock Python to the portable installation
set "PYTHONHOME=%PYTHON_DIR%"

:: Redirect Jupyter's internal storage into the portable root,
:: preventing any writes to C:\Users\Name\AppData
set "JUPYTER_CONFIG_DIR=%ROOT_DIR%\.jupyter_config"
set "JUPYTER_DATA_DIR=%ROOT_DIR%\.jupyter_data"
set "JUPYTER_RUNTIME_DIR=%ROOT_DIR%\.jupyter_runtime"

if not exist "%JUPYTER_CONFIG_DIR%" mkdir "%JUPYTER_CONFIG_DIR%"
if not exist "%JUPYTER_DATA_DIR%"   mkdir "%JUPYTER_DATA_DIR%"
