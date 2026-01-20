@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo   Error Handling Test Suite
echo ========================================
echo.

set "TESTS_PASSED=0"
set "TESTS_FAILED=0"
set "SCRIPT_DIR=%~dp0"

REM No color codes - they don't work well in all terminals

echo This will test error handling by intentionally breaking things.
echo All changes will be reverted after testing.
echo.
pause

REM ============================================================================
echo.
echo TEST 1: Missing paths.config file
echo ============================================================================

if exist "%SCRIPT_DIR%paths.config" (
    echo Temporarily renaming paths.config...
    rename "%SCRIPT_DIR%paths.config" "paths.config.test_backup"
    
    echo Running sync_from_obsidian.bat...
    call "%SCRIPT_DIR%sync_from_obsidian.bat" >nul 2>&1
    
    if errorlevel 1 (
        echo [PASS] Correctly detected missing config file
        set /a TESTS_PASSED+=1
    ) else (
        echo [FAIL] Should have failed but didn't
        set /a TESTS_FAILED+=1
    )
    
    echo Restoring paths.config...
    rename "%SCRIPT_DIR%paths.config.test_backup" "paths.config"
) else (
    echo [SKIP] paths.config not found (already missing?)
)

REM ============================================================================
echo.
echo TEST 2: Invalid path in config
echo ============================================================================

if exist "%SCRIPT_DIR%paths.config" (
    echo Creating backup of paths.config...
    copy "%SCRIPT_DIR%paths.config" "%SCRIPT_DIR%paths.config.test_backup" >nul
    
    echo Creating config with invalid path...
    (
        echo # Test config with invalid path
        echo OBSIDIAN_CONTENT_FOLDER=C:\This\Path\Does\Not\Exist
        echo OBSIDIAN_STATIC_FOLDER=C:\This\Path\Does\Not\Exist
        echo REPO_FOLDER=%SCRIPT_DIR%
    ) > "%SCRIPT_DIR%paths.config"
    
    echo Running sync_from_obsidian.bat...
    call "%SCRIPT_DIR%sync_from_obsidian.bat" >nul 2>&1
    
    if errorlevel 1 (
        echo [PASS] Correctly detected invalid paths
        set /a TESTS_PASSED+=1
    ) else (
        echo [FAIL] Should have failed but didn't
        set /a TESTS_FAILED+=1
    )
    
    echo Restoring original paths.config...
    move /y "%SCRIPT_DIR%paths.config.test_backup" "%SCRIPT_DIR%paths.config" >nul
) else (
    echo [SKIP] paths.config not found
)

REM ============================================================================
echo.
echo TEST 3: Broken Python script
echo ============================================================================

if exist "%SCRIPT_DIR%now2then.py" (
    echo Creating backup of now2then.py...
    copy "%SCRIPT_DIR%now2then.py" "%SCRIPT_DIR%now2then.py.test_backup" >nul
    
    echo Creating broken version...
    (
        echo import sys
        echo print^("ERROR: Intentional test failure"^)
        echo sys.exit^(1^)
    ) > "%SCRIPT_DIR%now2then.py"
    
    echo Running sync with --update_now flag...
    call "%SCRIPT_DIR%sync_from_obsidian.bat" --update_now >nul 2>&1
    
    if errorlevel 1 (
        echo [PASS] Correctly detected Python script failure
        set /a TESTS_PASSED+=1
    ) else (
        echo [FAIL] Should have failed but didn't
        set /a TESTS_FAILED+=1
    )
    
    echo Restoring original now2then.py...
    move /y "%SCRIPT_DIR%now2then.py.test_backup" "%SCRIPT_DIR%now2then.py" >nul
) else (
    echo [SKIP] now2then.py not found
)

REM ============================================================================
echo.
echo TEST 4: builderserver.ps1 error propagation
echo ============================================================================

if exist "%SCRIPT_DIR%paths.config" (
    echo Creating backup of paths.config...
    copy "%SCRIPT_DIR%paths.config" "%SCRIPT_DIR%paths.config.test_backup" >nul
    
    echo Creating config with invalid path...
    (
        echo # Test config with invalid path
        echo OBSIDIAN_CONTENT_FOLDER=C:\Invalid\Path
        echo OBSIDIAN_STATIC_FOLDER=C:\Invalid\Path
        echo REPO_FOLDER=%SCRIPT_DIR%
    ) > "%SCRIPT_DIR%paths.config"
    
    echo Running builderserver.ps1 -serve...
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%builderserver.ps1" -serve >nul 2>&1
    
    if errorlevel 1 (
        echo [PASS] builderserver.ps1 correctly caught sync failure
        set /a TESTS_PASSED+=1
    ) else (
        echo [FAIL] Should have failed but didn't
        set /a TESTS_FAILED+=1
    )
    
    echo Restoring original paths.config...
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
    echo All tests passed! Error handling is working correctly.
) else (
    echo Some tests failed. Review the output above.
)

echo.
echo All temporary changes have been reverted.
pause