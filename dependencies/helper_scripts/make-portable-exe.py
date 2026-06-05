import os
import sys
import struct
import zipfile
from io import BytesIO
from importlib.metadata import distributions

PORTABLE_MARKER = b"# PYLAND PORTABLE EXE\n"

def get_launcher_stubs():
    import distlib
    distlib_dir = os.path.dirname(distlib.__file__)
    is_64bit = struct.calcsize("P") * 8 == 64
    console_stub = os.path.join(distlib_dir, "t64.exe" if is_64bit else "t32.exe")
    gui_stub = os.path.join(distlib_dir, "w64.exe" if is_64bit else "w32.exe")
    return console_stub, gui_stub

def is_already_converted(exe_path):
    try:
        with open(exe_path, "rb") as f:
            data = f.read()
        return PORTABLE_MARKER in data
    except OSError:
        return False

def replace_with_portable_exes_in_scripts(verbose=False):
    print("Making portable executables of console entry points of Python packages...")
    python_dir = os.path.dirname(sys.executable)
    bindir = os.path.join(python_dir, "Scripts")
    os.makedirs(bindir, exist_ok=True)

    if verbose:
        print(f"[INFO] Python Root Directory: {python_dir}")
        print(f"[INFO] Replacing binaries in: {bindir}\n")

    console_stub, gui_stub = get_launcher_stubs()

    if verbose:
        print(f"[INFO] Console stub: {console_stub}")
        print(f"[INFO] GUI stub:     {gui_stub}\n")

    count = 0
    skipped = 0
    up_to_date = 0
    errors = 0

    for dist in distributions():
        scripts = [ep for ep in dist.entry_points if ep.group in ("console_scripts", "gui_scripts")]
        if not scripts:
            continue

        if verbose:
            print(f"[PKG]  Processing package: {dist.name}")

        for ep in scripts:
            exe_name = ep.name

            if ":" not in ep.value:
                if verbose:
                    print(f"  [WARN] Skipping {exe_name} - no callable in entry point value: {ep.value!r}")
                skipped += 1
                continue

            module, callable_ = ep.value.split(":", 1)
            is_gui = ep.group == "gui_scripts"
            stub_path = gui_stub if is_gui else console_stub

            exe_path = os.path.join(bindir, f"{exe_name}.exe")
            stale_path = exe_path + ".old"

            # Skip if already converted
            if os.path.exists(exe_path) and is_already_converted(exe_path):
                if verbose:
                    print(f"  [SKIP] Already converted -> Scripts\\{exe_name}.exe")
                up_to_date += 1
                continue

            # Move existing exe out of the way
            if os.path.exists(exe_path):
                try:
                    os.remove(stale_path)
                except FileNotFoundError:
                    pass
                try:
                    os.rename(exe_path, stale_path)
                except PermissionError:
                    print(f"  [WARN] Skipping {exe_name}.exe - file is locked by another process")
                    skipped += 1
                    continue

            if verbose:
                print(f"  [OK]   Replacing -> Scripts\\{exe_name}.exe")

            script_content = (
                f"# -*- coding: utf-8 -*-\n"
                f"import sys, functools, importlib\n"
                f"\n"
                f"def main():\n"
                f"    sys.argv[0] = '{exe_name}'\n"
                f"    m = importlib.import_module('{module}')\n"
                f"    sys.exit(functools.reduce(getattr, '{callable_}'.split('.'), m)())\n"
                f"\n"
                f"main()\n"
            )

            try:
                with open(stub_path, "rb") as f:
                    stub_bytes = f.read()

                shebang = b"#!python.exe\n" + PORTABLE_MARKER
                script_bytes = script_content.encode("utf-8")

                stream = BytesIO()
                with zipfile.ZipFile(stream, "w") as zf:
                    zf.writestr("__main__.py", script_bytes)
                zip_data = stream.getvalue()

                with open(exe_path, "wb") as f:
                    f.write(stub_bytes + shebang + zip_data)

                if os.path.exists(stale_path):
                    try:
                        os.remove(stale_path)
                    except OSError:
                        pass

                count += 1

            except Exception as e:
                print(f"  [WARN] Failed to create {exe_name}.exe: {e}")
                if os.path.exists(stale_path) and not os.path.exists(exe_path):
                    os.rename(stale_path, exe_path)
                errors += 1
                continue

    print(f"[DONE] Replaced: {count}  |  Up-to-date: {up_to_date}  |  Skipped: {skipped}  |  Errors: {errors}")

if __name__ == "__main__":
    verbose = "/verbose" in sys.argv
    replace_with_portable_exes_in_scripts(verbose=verbose)