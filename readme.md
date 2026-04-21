# Self-contained and Isolated Python Environment

A modular, self-contained development environment designed to run in complete isolation from your system Python. No admin rights required, no system-wide installations, and zero footprint on the host machine. Does not make any permanent changes to system environment variables or Windows registry.

This project was **vibe coded using Gemini**.

---

## Project Structure

* **`dependencies/`**: The root directory of the environment.
    * `uv/`: The directory containing the `uv.exe` executable, used for downloading Python and Python packages.
    * `python/`: The directory containing the Python distribution.
* **`notebooks/`**: The directory intended to contain Jupyter notebooks.
* **`requirements.txt`**: Define your libraries here (e.g., `pandas`, `jupyterlab`).
    * *Note: Version pinning is not automated; please edit this file manually to pin specific versions.*

---

## How to Use

### 1. Build the Environment
Run the scripts in order to initialize the isolated Python environment:

1.  **`1-uv-downloader.bat`**: Fetches the latest `uv` binary from GitHub.
2.  **`2-python-downloader.bat`**: Downloads a standalone Python distribution via `uv`. You will be prompted to choose a version (e.g., `3.12`).
3.  **`3-python-pkgs-installer.bat`**: Installs the packages in `requirements.txt` using `uv pip`.

### 2. Launch
* **`open-cmd.bat`**: Sets a temporary and isolated PATH and other environment variables necessary to make the environment isolated from the rest of the system, then launches Windows Command Prompt in which the `uv` and `python` commands are availabale.
* **`open-jupyterlab.bat`**: Sets a temporary and isolated PATH and other environment variables necessary to make the environment isolated from the rest of the system, then launches **Jupyter Lab**. All configuration and runtime data stay within the local folder.

---

## Key Features

* **Zero Footprint:** Uses temporary session variables. Your system `PATH` and other related environment variables as well as the Windows registry remain untouched.
* **Portable Jupyter:** Redirects `JUPYTER_CONFIG_DIR` so your settings travel with you.
* **Full Python:** Includes a complete standard library, unlike "embeddable" zips.
* **Aliase `pip`to `uv pip`:** So that `!pip ...` commands can be run from within Jupyter Notebook

---

## Known Issues

### ⚠️ Broken Shims on Move/Rename
Moving or renaming the parent folder will break the executable "shims" (the `.exe` files in `python\Scripts\`). This happens because the absolute paths to the interpreter are hardcoded into these wrappers during installation.

**The Workaround:**
* As a workaround, instead of running the `.exe` files directly, run `python -m <module>` (e.g., `python -m jupyterlab`). This ensures the environment remains functional regardless of the folder's location.
* **Manual Fix:** If you need to fix the `.exe` files in the `Scripts` folder, simply rerun `03_install_packages.bat`. This will refresh the internal paths to match the new location.

---

## License

This is free and unencumbered software released into the public domain under **The Unlicense**.