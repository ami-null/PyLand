# Portable Python Data Science Environment

A modular, "lab-in-a-box" setup for a fully functional Python data science environment contained within a single folder. No admin rights required, no system-wide installations, and zero footprint on the host machine.

This project was **vibe coded using Gemini**.

---

## Project Structure

* **`python_and_vscode/`**: The root container for all portable binaries.
    * `uv/`: The `uv` executable for lightning-fast package and Python management.
    * `python/`: A "full-fat" portable Python distribution.
* **`requirements.txt`**: Define your libraries here (e.g., `pandas`, `jupyterlab`).
    * *Note: Version pinning is not automated; please edit this file manually to pin specific versions.*

---

## How to Use

### 1. Build the Environment
Run the scripts in order to initialize the portable folder:

1.  **`01_download_uv.bat`**: Fetches the latest `uv` binary from GitHub.
2.  **`02_download_python.bat`**: Downloads a standalone Python distribution via `uv`. You will be prompted to choose a version (e.g., `3.12`).
3.  **`03_install_packages.bat`**: Installs your `requirements.txt` into the portable folder using `uv pip`.

### 2. Launch
* **`launch_jupyter.bat`**: Sets a temporary portable PATH and launches **Jupyter Lab**. All configuration and runtime data stay within the local folder.

---

## Key Features

* **Zero Footprint:** Uses temporary session variables. Your system `PATH` remains untouched.
* **Portable Jupyter:** Redirects `JUPYTER_CONFIG_DIR` so your settings travel with you.
* **Full-Fat Python:** Includes a complete standard library, unlike "embeddable" zips.

---

## Known Issues

### ⚠️ Broken Shims on Move/Rename
Moving or renaming the parent folder will break the executable "shims" (the `.exe` files in `python\Scripts\`). This happens because the absolute paths to the interpreter are hardcoded into these wrappers during installation.

**The Workaround:**
* **Launchers:** This environment uses `python -m <module>` (e.g., `python -m jupyterlab`) in its launch scripts to bypass these shims. This ensures the environment remains functional regardless of the folder's location.
* **Manual Fix:** If you need to fix the `.exe` files in the `Scripts` folder, simply rerun `03_install_packages.bat`. This will refresh the internal paths to match the new location.

---

## License

This is free and unencumbered software released into the public domain under **The Unlicense**.