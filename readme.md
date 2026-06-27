# Self-contained and Isolated Python Environment

A modular, self-contained development environment designed to run in complete isolation from your system Python. No admin rights required, no system-wide installations, and zero footprint on the host machine. Does not make any permanent changes to system environment variables or Windows registry.

This project was **vibe coded using Gemini**.

---

## Project Structure

* **`dependencies/`**: The root directory of the environment.
    * `uv/`: The directory containing the `uv.exe` executable, used for downloading Python and Python packages.
    * `python/`: The directory containing the Python distribution.
* **`notebooks/`**: The directory intended to contain Jupyter notebooks.
* **`python-version.txt`**: Stores the Python version to download.
* **`requirements.txt`**: Define your libraries here (e.g., `pandas`, `jupyterlab`).
    * *Note: Version pinning is not automated; please edit this file manually to pin specific versions.*

---

## How to Use

### 1. Build the Environment
Run the scripts in order to initialize the isolated Python environment:

1.  **`1-uv-downloader.bat`**: Fetches the latest `uv` binary from GitHub.
2.  **`2-python-downloader.bat`**: Downloads a standalone Python distribution via `uv`. You will be prompted to choose a version (e.g., `3.12`).
3.  **`3-python-pkgs-installer.bat`**: Installs the packages in `requirements.txt` using `uv pip`.
<!-- 4.  **`4-bat-shim-creator.bat`**: Various Python packages install `.exe` entry points in the `Scripts` directory of the Python installation. The `4-bat-shim-creator.bat` creates `.bat` shims for those `.exe` files. This is optional but useful when the whole environment is moved around. Because the `.exe` files hardcode the location of the Python executable at install time of the Python packages, this leads to broken executables when the environment is moved or renamed. The generated `.bat` scripts do not hardcode the location of the Python executable, so these `.bat` files do not fail to launch even when the environment is moved or renamed. -->

### 2. Launch
* **`open-cmd.bat`**: Sets a temporary and isolated PATH and other environment variables necessary to make the environment isolated from the rest of the system, then launches Windows Command Prompt in which the `uv` and `python` commands are availabale.
* **`open-jupyterlab.bat`**: Sets a temporary and isolated PATH and other environment variables necessary to make the environment isolated from the rest of the system, then launches **Jupyter Lab**. All configuration and runtime data stay within the local folder.

---

## Key Features

* **No permanent change to system:** Uses temporary session variables. Your system `PATH` and other related environment variables as well as the Windows registry remain untouched.
* **Portable Jupyter:** Redirects `JUPYTER_CONFIG_DIR` so your settings travel with you.
* **Full Python:** Includes a complete standard library, unlike "embeddable" zips.
* **Aliase `pip`to `uv pip`:** So that `!pip ...` commands can be run from within Jupyter Notebook
* **Portable executable files of launch scripts of Python packages**: The alias of the `pip` command runs another script whenever a new package is installed, this script makes the executable files portable so that you can move/rename the Python environment and the executable files would still work.

---

<!-- Known Issues

# ⚠️ Broken Shims on Move/Rename
Moving or renaming the parent folder will break the executable "shims" (the `.exe` files in `python\Scripts\`). This happens because the absolute paths to the interpreter are hardcoded into these wrappers during package installation.

**The Workaround:**
* As a workaround, instead of running the `.exe` files directly, run `python -m <module>` (e.g., `python -m jupyterlab`). This ensures the environment remains functional regardless of the folder's location.
* Another fix is to run `4-bat-shim-creator.bat`. This creates `.bat` files for each console entry point of all the installed Python packages. These `.bat` files do not hardcode the location of the Python executable.
* **Manual Fix:** If you really need to fix the `.exe` files in the `Scripts` folder, simply rerun `3-python-pkgs-installer.bat`. This will refresh the internal paths to match the new location.
---
 -->

## License

This is free and unencumbered software released into the public domain under **The Unlicense**.