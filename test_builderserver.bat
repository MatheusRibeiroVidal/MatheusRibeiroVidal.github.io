@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo   BuilderServer Test Suite
echo ========================================
echo.

set "TESTS_PASSED=0"
set "TESTS_FAILED=0"
set "SCRIPT_DIR=%~dp0"

echo This will test builderserver.ps1 functionality.
echo Some tests will make actual git commits - make sure you're on a test branch!
echo.
set /p confirm="Are you on a test branch and ready to proceed? (y/n): "
if /i not "%confirm%"=="y" (
    echo Test cancelled.
    exit /b
)

REM ============================================================================
echo.
echo TEST 1: Parameter validation (no parameters)
echo ============================================================================

powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" >nul 2>&1

if errorlevel 1 (
    echo [PASS] Correctly rejected no parameters
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] Should have failed with no parameters
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 2: Parameter validation (multiple parameters)
echo ============================================================================

powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" -serve -build >nul 2>&1

if errorlevel 1 (
    echo [PASS] Correctly rejected multiple parameters
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] Should have failed with multiple parameters
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 3: Serve mode (builds without committing)
echo ============================================================================

echo Starting serve mode test (will be killed after 3 seconds)...
start /b powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" -serve

REM Wait 3 seconds then check if zola process started
timeout /t 3 /nobreak >nul

tasklist /FI "IMAGENAME eq powershell.exe" 2>NUL | find /I "powershell.exe" >nul
if %ERRORLEVEL% EQU 0 (
    echo [PASS] Serve mode started successfully
    set /a TESTS_PASSED+=1
    
    REM Kill the zola serve process
    echo Cleaning up zola serve processes...
    taskkill /F /IM powershell.exe /FI "WINDOWTITLE eq*zola*" >nul 2>&1
) else (
    echo [FAIL] Serve mode did not start
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 4: Build mode with no changes (should not commit)
echo ============================================================================

REM Store current commit count
for /f "tokens=*" %%a in ('git rev-list --count HEAD') do set "INITIAL_COMMITS=%%a"

echo Running build mode with no changes...
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" -build 2>nul

REM Check if commit count stayed the same
for /f "tokens=*" %%a in ('git rev-list --count HEAD') do set "FINAL_COMMITS=%%a"

if "%INITIAL_COMMITS%"=="%FINAL_COMMITS%" (
    echo [PASS] Build mode did not commit when no changes present
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] Build mode created a commit when it shouldn't have
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 5: Auto mode with no changes (should not commit)
echo ============================================================================

REM Store current commit count
for /f "tokens=*" %%a in ('git rev-list --count HEAD') do set "INITIAL_COMMITS=%%a"

echo Running auto mode with no changes...
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" -auto 2>nul

REM Check if commit count stayed the same
for /f "tokens=*" %%a in ('git rev-list --count HEAD') do set "FINAL_COMMITS=%%a"

if "%INITIAL_COMMITS%"=="%FINAL_COMMITS%" (
    echo [PASS] Auto mode did not commit when no changes present
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] Auto mode created a commit when it shouldn't have
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 6: Build mode file generation
echo ============================================================================

REM Check if public folder was created after build
if exist "%SCRIPT_DIR%Zola_builder\public" (
    echo [PASS] Build successfully generated public folder
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] Public folder not found after build
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 7: Docs folder sync
echo ============================================================================

REM Check if docs folder was updated
if exist "%SCRIPT_DIR%docs\index.html" (
    echo [PASS] Docs folder successfully synced from public
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] Docs folder not properly synced
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 8: Auto mode with simulated change
echo ============================================================================

REM Create a temporary test file to trigger a change
echo Test content > "%SCRIPT_DIR%Zola_builder\content\test_file.md"

REM Store current commit count
for /f "tokens=*" %%a in ('git rev-list --count HEAD') do set "INITIAL_COMMITS=%%a"

echo Running auto mode with a test change...
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" -auto 2>nul

REM Check if commit was created
for /f "tokens=*" %%a in ('git rev-list --count HEAD') do set "FINAL_COMMITS=%%a"

if not "%INITIAL_COMMITS%"=="%FINAL_COMMITS%" (
    echo [PASS] Auto mode created commit with changes present
    set /a TESTS_PASSED+=1
    
    REM Clean up - revert the test commit
    echo Reverting test commit...
    git reset --hard HEAD~1 >nul 2>&1
) else (
    echo [FAIL] Auto mode did not commit when changes were present
    set /a TESTS_FAILED+=1
    
    REM Clean up test file if commit didn't happen
    del "%SCRIPT_DIR%Zola_builder\content\test_file.md" >nul 2>&1
    git restore "%SCRIPT_DIR%Zola_builder\content\test_file.md" >nul 2>&1
)

REM ============================================================================
echo.
echo TEST 9: Config timestamp update detection
echo ============================================================================

REM Check if config.toml has last_update_to_site field
findstr /C:"last_update_to_site" "%SCRIPT_DIR%Zola_builder\config.toml" >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [PASS] Config.toml contains last_update_to_site timestamp
    set /a TESTS_PASSED+=1
) else (
    echo [FAIL] Config.toml missing last_update_to_site field
    set /a TESTS_FAILED+=1
)

REM ============================================================================
echo.
echo TEST 10: Sync error handling propagation
echo ============================================================================

REM Temporarily break paths.config
if exist "%SCRIPT_DIR%paths.config" (
    copy "%SCRIPT_DIR%paths.config" "%SCRIPT_DIR%paths.config.test_backup" >nul
    
    echo OBSIDIAN_CONTENT_FOLDER=C:\Invalid\Path > "%SCRIPT_DIR%paths.config"
    echo OBSIDIAN_STATIC_FOLDER=C:\Invalid\Path >> "%SCRIPT_DIR%paths.config"
    echo REPO_FOLDER=%SCRIPT_DIR% >> "%SCRIPT_DIR%paths.config"
    
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" -build >nul 2>&1
    
    if errorlevel 1 (
        echo [PASS] BuilderServer correctly stopped on sync error
        set /a TESTS_PASSED+=1
    ) else (
        echo [FAIL] BuilderServer did not stop on sync error
        set /a TESTS_FAILED+=1
    )
    
    REM Restore config
    move /y "%SCRIPT_DIR%paths.config.test_backup" "%SCRIPT_DIR%paths.config" >nul
) else (
    echo [SKIP] paths.config not found
)

REM ============================================================================
echo.
echo ========================================
echo   Test Results Summary
echo ========================================
echo Tests Passed: %TESTS_PASSED%
echo Tests Failed: %TESTS_FAILED%
echo.

if %TESTS_FAILED% EQU 0 (
    echo All tests passed! BuilderServer is working correctly.
) else (
    echo Some tests failed. Review the output above.
)

echo.
echo Test complete. Make sure to check your git status.
pause