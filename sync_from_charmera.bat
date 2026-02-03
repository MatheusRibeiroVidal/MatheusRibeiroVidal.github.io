@echo off
setlocal EnableDelayedExpansion

echo Syncing Charmera gallery...

REM Get script directory
set "SCRIPT_DIR=%~dp0"

REM Load paths from config
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

REM Validate Charmera folder
if not defined CHARMERA_GALLERY_FOLDER (
    echo ERROR: CHARMERA_GALLERY_FOLDER not defined in paths.config
    exit /b 1
)

if not exist "%CHARMERA_GALLERY_FOLDER%" (
    echo ERROR: Charmera folder not found at %CHARMERA_GALLERY_FOLDER%
    exit /b 1
)

REM Set Zola static folder
set "REPO_STATIC_FOLDER=%REPO_FOLDER%\zola\static\charmera"

REM Ensure static folder exists
if not exist "%REPO_STATIC_FOLDER%" mkdir "%REPO_STATIC_FOLDER%"

REM Copy Charmera images
robocopy "%CHARMERA_GALLERY_FOLDER%" "%REPO_STATIC_FOLDER%" /E /NFL /NDL /NJH /NJS
if errorlevel 8 (
    echo ERROR: Charmera sync failed with error level %errorlevel%
    exit /b 1
)

REM Run Python script to update _index.md
echo Updating _index.md...
python "%SCRIPT_DIR%update_charmera_index.py"
if errorlevel 1 (
    echo ERROR: Failed to update _index.md
    exit /b 1
)

echo Charmera gallery sync complete.
exit /b 0
