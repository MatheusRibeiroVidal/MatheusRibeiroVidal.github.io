@echo off
setlocal EnableDelayedExpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Load paths from config file
set "CONFIG_FILE=%SCRIPT_DIR%paths.config"

if not exist "%CONFIG_FILE%" (
    echo ERROR: paths.config file not found at %CONFIG_FILE%
    echo Please create paths.config with your folder paths.
    exit /b 1
)

REM Parse the config file
for /f "usebackq tokens=1,* delims==" %%a in ("%CONFIG_FILE%") do (
    set "line=%%a"
    REM Skip comments and empty lines
    if not "!line:~0,1!"=="#" if not "!line!"=="" (
        set "%%a=%%b"
    )
)

REM Validate that all required paths were loaded
if not defined OBSIDIAN_CONTENT_FOLDER (
    echo ERROR: OBSIDIAN_CONTENT_FOLDER not defined in paths.config
    exit /b 1
)
if not defined OBSIDIAN_STATIC_FOLDER (
    echo ERROR: OBSIDIAN_STATIC_FOLDER not defined in paths.config
    exit /b 1
)
if not defined REPO_FOLDER (
    echo ERROR: REPO_FOLDER not defined in paths.config
    exit /b 1
)

REM Derive repo subfolders
set "REPO_CONTENT_FOLDER=%REPO_FOLDER%\Zola_builder\content"
set "REPO_STATIC_FOLDER=%REPO_FOLDER%\Zola_builder\static"
set "NOW_FILE=%OBSIDIAN_CONTENT_FOLDER%\now.md"

REM Validate that source folders exist
if not exist "%OBSIDIAN_CONTENT_FOLDER%" (
    echo ERROR: Obsidian content folder not found at:
    echo %OBSIDIAN_CONTENT_FOLDER%
    exit /b 1
)

if not exist "%OBSIDIAN_STATIC_FOLDER%" (
    echo ERROR: Obsidian static folder not found at:
    echo %OBSIDIAN_STATIC_FOLDER%
    exit /b 1
)

REM Validate that destination folders exist
if not exist "%REPO_CONTENT_FOLDER%" (
    echo ERROR: Repo content folder not found at:
    echo %REPO_CONTENT_FOLDER%
    exit /b 1
)

if not exist "%REPO_STATIC_FOLDER%" (
    echo ERROR: Repo static folder not found at:
    echo %REPO_STATIC_FOLDER%
    exit /b 1
)

REM Check if --update_now flag is passed
set "UPDATE_TIMESTAMP=false"
if "%~1"=="--update_now" set "UPDATE_TIMESTAMP=true"

REM Optionally update the 'updated' tag inside now.md
if "%UPDATE_TIMESTAMP%"=="true" (
    if not exist "%NOW_FILE%" (
        echo ERROR: now.md not found at %NOW_FILE%
        exit /b 1
    )
    
    echo Updating now.md timestamp...
    powershell -NoProfile -Command "if (Test-Path '%NOW_FILE%') { $ts = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'; (Get-Content '%NOW_FILE%') | ForEach-Object { if ($_ -match '^updated\s*=\s*\".*\"') { 'updated = \"' + $ts + '\"' } else { $_ } } | Set-Content '%NOW_FILE%'; Write-Host 'Updated /now timestamp to' $ts } else { Write-Host 'now.md not found'; exit 1 }"
    
    if errorlevel 1 (
        echo ERROR: Failed to update now.md timestamp
        exit /b 1
    )
    
    REM Run the now2then script BEFORE syncing
    echo Running now2then.py to archive to then.md...
    pushd "%REPO_FOLDER%"
    python now2then.py
    
    if errorlevel 1 (
        echo ERROR: now2then.py failed
        popd
        exit /b 1
    )
    popd
)

REM Sync content (removes deleted files)
echo Syncing content folder...
robocopy "%OBSIDIAN_CONTENT_FOLDER%" "%REPO_CONTENT_FOLDER%" /E /PURGE /NFL /NDL /NJH /NJS
if errorlevel 8 (
    echo ERROR: Content sync failed with error level %errorlevel%
    exit /b 1
)

REM Sync static (keeps existing files)
echo Syncing static folder...
robocopy "%OBSIDIAN_STATIC_FOLDER%" "%REPO_STATIC_FOLDER%" /E /NFL /NDL /NJH /NJS
if errorlevel 8 (
    echo ERROR: Static sync failed with error level %errorlevel%
    exit /b 1
)

echo Sync complete successfully.
exit /b 0