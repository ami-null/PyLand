@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: get_gh_release.bat
:: Usage: get_gh_release.bat <github_user> <repo> [filter1] [filter2] ...
::
:: Filters:
::   plain string   -> URL must contain it      (e.g.  windows)
::   -string        -> URL must NOT contain it  (e.g. -sha256)
::
:: Prints the download URL of the first matching asset in the
:: latest GitHub release.  All diagnostics go to stderr so the
:: caller can safely capture stdout.
::
:: Exit codes:
::   0  - success (URL printed to stdout)
::   1  - missing arguments
::   2  - curl error
::   3  - no matching asset found
::
:: Caller example:
::   for /f "delims=" %%U in ('call get_gh_release.bat astral-sh uv windows x86_64 -msvc') do set "UV_URL=%%U"
::   if errorlevel 1 ( echo Download failed & exit /b 1 )
:: ============================================================

:: ── Validate required args ────────────────────────────────────────────────────
set "GH_USER=%~1"
set "GH_REPO=%~2"

if "%GH_USER%"=="" (
    echo ERROR: First argument ^(GitHub username^) is missing. >&2
    exit /b 1
)
if "%GH_REPO%"=="" (
    echo ERROR: Second argument ^(repository name^) is missing. >&2
    exit /b 1
)

:: ── Collect filter arguments (everything after the first two) ─────────────────
:: FILTER_n      = the pattern string (leading - already stripped for excludes)
:: FILTER_TYPE_n = "include" or "exclude"
shift & shift

set "FILTER_COUNT=0"
:collect_filters
if "%~1"=="" goto filters_done
set /a FILTER_COUNT+=1
set "RAW=%~1"
:: Check for leading - (exclude filter)
if "!RAW:~0,1!"=="-" (
    set "FILTER_!FILTER_COUNT!=!RAW:~1!"
    set "FILTER_TYPE_!FILTER_COUNT!=exclude"
) else (
    set "FILTER_!FILTER_COUNT!=!RAW!"
    set "FILTER_TYPE_!FILTER_COUNT!=include"
)
shift
goto collect_filters
:filters_done

:: ── Fetch the release JSON via curl ──────────────────────────────────────────
set "API_URL=https://api.github.com/repos/%GH_USER%/%GH_REPO%/releases/latest"
set "JSON_TMP=%TEMP%\gh_release_%RANDOM%.tmp"
set "URL_TMP=%TEMP%\gh_urls_%RANDOM%.tmp"
set "SWAP_TMP=%TEMP%\gh_swap_%RANDOM%.tmp"

echo Fetching: %API_URL% >&2

curl -sfS -L -o "%JSON_TMP%" "%API_URL%"
if %ERRORLEVEL% neq 0 (
    echo ERROR: curl failed ^(exit code %ERRORLEVEL%^) fetching: >&2
    echo        %API_URL% >&2
    del "%JSON_TMP%" 2>nul
    exit /b 2
)

:: ── Extract all browser_download_url lines from JSON ─────────────────────────
:: GitHub API pretty-prints JSON so each asset URL is on its own line:
::   "browser_download_url": "https://github.com/..."
findstr "browser_download_url" "%JSON_TMP%" > "%URL_TMP%"
del "%JSON_TMP%" 2>nul

:: ── Apply each filter ────────────────────────────────────────────────────────
::   include -> findstr /i  "pattern"   (keep matching lines)
::   exclude -> findstr /iv "pattern"   (drop matching lines)
set /a "I=1"
:apply_filters
if %I% gtr %FILTER_COUNT% goto filters_applied

if "!FILTER_TYPE_%I%!"=="exclude" (
    findstr /iv "!FILTER_%I%!" "%URL_TMP%" > "%SWAP_TMP%"
) else (
    findstr /i  "!FILTER_%I%!" "%URL_TMP%" > "%SWAP_TMP%"
)
move /y "%SWAP_TMP%" "%URL_TMP%" >nul

set /a "I+=1"
goto apply_filters
:filters_applied

:: ── Read the first surviving URL line ────────────────────────────────────────
set "MATCHED_LINE="
for /f "usebackq delims=" %%L in ("%URL_TMP%") do (
    if not defined MATCHED_LINE set "MATCHED_LINE=%%L"
)
del "%URL_TMP%" 2>nul

if not defined MATCHED_LINE (
    echo ERROR: No release asset matched the given filters. >&2
    exit /b 3
)

:: ── Extract the URL from the JSON line ───────────────────────────────────────
:: Line format:  "browser_download_url": "https://..."
:: Splitting on " gives token 4 as the URL.
set "DOWNLOAD_URL="
for /f tokens^=4^ delims^=^" %%U in ("!MATCHED_LINE!") do (
    if not defined DOWNLOAD_URL set "DOWNLOAD_URL=%%U"
)

if not defined DOWNLOAD_URL (
    echo ERROR: Failed to parse URL from matched line. >&2
    echo        Line: !MATCHED_LINE! >&2
    exit /b 3
)

:: ── Print URL to stdout (the only stdout output) ─────────────────────────────
echo !DOWNLOAD_URL!

endlocal