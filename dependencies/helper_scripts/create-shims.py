"""
create_shims.py
Walks all *.dist-info/entry_points.txt files in site-packages,
parses [console_scripts] entries, and writes relocatable .bat
wrappers into the Python Scripts directory.

Usage:
    python create_shims.py <site-packages-dir> <scripts-dir>
"""

import sys
import os
import re
import site
import sysconfig


site_packages = site.getsitepackages()[1]
scripts_dir   = sysconfig.get_path('scripts')

print("[INFO] Site package directory:", site_packages)
print("[INFO] Scripts directory:", scripts_dir)

# if not os.path.isdir(site_packages):
    # print(f"[ERROR] site-packages directory not found: {site_packages}")
    # sys.exit(1)

# if not os.path.isdir(scripts_dir):
    # print(f"[ERROR] Scripts directory not found: {scripts_dir}")
    # sys.exit(1)

# ── Collect all entry_points.txt files ───────────────────────
entry_point_files = []
for name in os.listdir(site_packages):
    if name.endswith(".dist-info"):
        ep_file = os.path.join(site_packages, name, "entry_points.txt")
        if os.path.isfile(ep_file):
            entry_point_files.append((name, ep_file))

if not entry_point_files:
    print("[INFO] No .dist-info directories found. Nothing to do.")
    sys.exit(0)

print(f"[INFO] Found {len(entry_point_files)} dist-info directories to scan.")
print()

# ── Parse and generate shims ──────────────────────────────────
created = 0
skipped = 0
errors  = 0

for dist_name, ep_path in sorted(entry_point_files):
    with open(ep_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract [console_scripts] section only
    # Match everything between [console_scripts] and the next [section] or EOF
    match = re.search(
        r"\[console_scripts\](.*?)(?=\[|\Z)",
        content,
        re.DOTALL | re.IGNORECASE
    )
    if not match:
        continue

    section = match.group(1).strip()
    if not section:
        continue

    for line in section.splitlines():
        line = line.strip()

        # Skip blank lines and comments
        if not line or line.startswith("#"):
            continue

        # Strip optional dependency markers e.g. "cmd = mod:fn [extra]" before parsing
        line = re.sub(r"\s*\[.+\]", "", line).strip()

        # Parse "command = module:callable"
        if "=" not in line or ":" not in line:
            print(f"  [SKIP] Unrecognised format, skipping: {line}")
            skipped += 1
            continue

        try:
            command, right = [s.strip() for s in line.split("=", 1)]
            module, callable_ = [s.strip() for s in right.split(":", 1)]
        except ValueError:
            print(f"  [SKIP] Could not parse entry point: {line}")
            skipped += 1
            continue

        # Build .bat content
        # %~dp0 resolves to the Scripts\ directory at runtime, so
        # ..\python.exe always points to the portable interpreter
        # regardless of where the root folder is located.
        bat_content = (
            f"@echo off\n"
            f'"%~dp0\\..\\python.exe" -c "from {module} import {callable_}; {callable_}()" %*\n'
        )

        bat_path = os.path.join(scripts_dir, f"{command}.bat")

        # Idempotent: skip if content is already identical
        if os.path.isfile(bat_path):
            with open(bat_path, "r", encoding="utf-8") as f:
                existing = f.read()
            if existing == bat_content:
                skipped += 1
                continue

        try:
            with open(bat_path, "w", encoding="utf-8") as f:
                f.write(bat_content)
            print(f"  [OK]   {command}.bat  ({module}:{callable_})")
            created += 1
        except OSError as e:
            print(f"  [ERROR] Could not write {command}.bat: {e}")
            errors += 1

# ── Summary ───────────────────────────────────────────────────
print()
print(f"[DONE] Created: {created}  |  Skipped/up-to-date: {skipped}  |  Errors: {errors}")

if errors:
    sys.exit(1)
