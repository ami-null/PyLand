"""
create_shims.py
Target Environment: Python 3.10+
Scans the environment for [console_scripts] and writes relocatable .bat
wrappers into the Python Scripts directory using modern pathlib and importlib.
"""

import sys
import site
import sysconfig
from pathlib import Path
from importlib.metadata import entry_points

site_packages = Path(site.getsitepackages()[1])
scripts_dir   = Path(sysconfig.get_path('scripts'))

# Auto-create directories if they don't exist yet
site_packages.mkdir(parents=True, exist_ok=True)
scripts_dir.mkdir(parents=True, exist_ok=True)

print(f"[INFO] Site package directory: {site_packages}")
print(f"[INFO] Scripts directory:      {scripts_dir}\n")

# ── Build .bat content ────────────────────────────────────────
def make_bat_content(command: str, module: str, callable_: str) -> str:
    """
    Return the .bat file body as string for a given module:callable entry point.
    - Sets sys.argv[0] so tool help menus/usage strings display correctly.
    - Wraps in sys.exit() to correctly bubble up tool exit codes.
    """
    runner = (
        f"import sys, functools, importlib; "
        f"sys.argv[0] = '{command}'; "
        f"m = importlib.import_module('{module}'); "
        f"sys.exit(functools.reduce(getattr, '{callable_}'.split('.'), m)())"
    )
    return f"@echo off\n\"%~dp0..\\python.exe\" -c \"{runner}\" %*\n"

# ── Parse and generate shims ──────────────────────────────────
created = 0
skipped = 0
errors = 0

console_scripts = entry_points(group='console_scripts')

if not console_scripts:
    print("[INFO] No console_scripts found in the environment. Nothing to do.")
    sys.exit(0)

print(f"[INFO] Found {len(console_scripts)} console scripts to process.")

for ep in console_scripts:
    command = ep.name
    
    # ep.value is always a string formatted as "module:callable"
    if ":" not in ep.value:
        continue
        
    module, callable_ = ep.value.split(":", 1)
    
    bat_content = make_bat_content(command, module, callable_)
    bat_path    = scripts_dir / f"{command}.bat"

    # Idempotent: skip if file exists and content matches perfectly
    if bat_path.is_file():
        if bat_path.read_text(encoding="utf-8") == bat_content:
            skipped += 1
            continue

    try:
        bat_path.write_text(bat_content, encoding="utf-8")
        print(f"  [OK]   {command}.bat  ({module}:{callable_})")
        created += 1
    except OSError as e:
        print(f"  [ERROR] Could not write {command}.bat: {e}")
        errors += 1

# ── Summary ───────────────────────────────────────────────────
print(f"\n[DONE] Created: {created}  |  Skipped/up-to-date: {skipped}  |  Errors: {errors}")

if errors:
    sys.exit(1)