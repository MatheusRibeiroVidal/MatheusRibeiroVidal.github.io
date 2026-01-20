@echo off
setlocal EnableDelayedExpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Load paths from config file
set "CONFIG_FILE=%SCRIPT_DIR%paths.config"

if not exist "%CONFIG_FILE%" (
    echo ERROR: paths.config file not found at %CONFIG_FILE%
    exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%a in ("%CONFIG_FILE%") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" if not "!line!"=="" (
        set "%%a=%%b"
    )
)

REM Derived folders
set "REPO_STATIC_FOLDER=%REPO_FOLDER%\Zola_builder\static"
set "REPO_PUBLIC_FOLDER=%REPO_FOLDER%\Zola_builder\public"

REM Ensure static folder exists
if not exist "%OBSIDIAN_STATIC_FOLDER%" (
    echo ERROR: Obsidian static folder not found at:
    echo %OBSIDIAN_STATIC_FOLDER%
    exit /b 1
)

REM Ensure public folder exists
if not exist "%REPO_PUBLIC_FOLDER%" (
    mkdir "%REPO_PUBLIC_FOLDER%"
)

REM CLEAN public folder first
echo Cleaning Zola public folder...
rmdir /S /Q "%REPO_PUBLIC_FOLDER%"
mkdir "%REPO_PUBLIC_FOLDER%"

REM Sync static folder
echo Syncing static folder from Obsidian...
robocopy "%OBSIDIAN_STATIC_FOLDER%" "%REPO_STATIC_FOLDER%" /E /NFL /NDL /NJH /NJS
if errorlevel 8 (
    echo ERROR: Static sync failed with error level %errorlevel%
    exit /b 1
)

echo Sync complete successfully.
exit /b 0
