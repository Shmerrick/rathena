@echo off
:: ============================================================
:: patch-client.bat — RESTART Private Server Client Patcher
:: ============================================================
::
:: Pulls the latest WARP patch scripts and applies the RESTART
:: patch set to the Ragnarok client executable.
::
:: Usage:
::   patch-client.bat                    (uses default paths in warp-restart.yml)
::   patch-client.bat "C:\path\to\Ragexe.exe"
::
:: Output: Ragexe_patched.exe in the same folder as the source exe.
::
:: Requirements:
::   - Git must be in PATH
::   - tools\warp\win32\WARP_console.exe must exist (comes from the
::     tools/warp submodule — run 'git submodule update --init' first)
::
:: ============================================================

SETLOCAL EnableDelayedExpansion

:: Strip trailing backslash from REPO_DIR so git -C works correctly
SET REPO_DIR=%~dp0
IF "%REPO_DIR:~-1%"=="\" SET REPO_DIR=%REPO_DIR:~0,-1%

SET WARP_EXE=%REPO_DIR%\tools\warp\win32\WARP_console.exe
SET SESSION_FILE=%REPO_DIR%\tools\warp-restart.yml

:: ---- 1. Update WARP submodules to latest ----
echo.
echo [RESTART] Pulling latest WARP scripts...
git -C "%REPO_DIR%" submodule update --remote tools/warp tools/warp2025
IF ERRORLEVEL 1 (
    echo [WARNING] Could not update WARP submodules. Using local copy.
)

:: ---- 2. Verify WARP_console.exe exists ----
IF NOT EXIST "%WARP_EXE%" (
    echo [ERROR] WARP_console.exe not found at: %WARP_EXE%
    echo Run: git submodule update --init --recursive
    pause
    EXIT /B 1
)

:: ---- 3. Determine source exe and apply patches ----
IF "%~1"=="" (
    :: No argument — use paths from session file
    echo [RESTART] Using client path from warp-restart.yml
    "%WARP_EXE%" -using "%SESSION_FILE%"
) ELSE (
    :: Path provided — derive output path in same folder
    SET CLIENT_EXE=%~f1
    SET CLIENT_DIR=%~dp1
    IF "!CLIENT_DIR:~-1!"=="\" SET CLIENT_DIR=!CLIENT_DIR:~0,-1!
    SET PATCHED_EXE=!CLIENT_DIR!\Ragexe_patched.exe
    echo [RESTART] Patching: !CLIENT_EXE!
    echo [RESTART] Output:   !PATCHED_EXE!
    "%WARP_EXE%" -using "%SESSION_FILE%" -from "!CLIENT_EXE!" -to "!PATCHED_EXE!"
)

IF ERRORLEVEL 1 (
    echo [ERROR] Patching failed. Check WARP output above.
    pause
    EXIT /B 1
)

echo.
echo [RESTART] Patching complete.
echo Use Ragexe_patched.exe to connect to the server.
echo.
pause
