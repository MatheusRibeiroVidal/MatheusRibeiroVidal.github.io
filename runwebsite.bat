@echo off
title Run Website Scripts

:menu
cls
echo ================================
echo    Personal Website Launcher
echo ================================
echo.
echo 1. Serve (local preview)
echo 2. Build (build + manual commit in Github Desktop)
echo 3. Auto-build (build + auto-commit)
echo.
echo 0. Exit
echo.
set /p choice="Choose an option: "

if "%choice%"=="1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0builderserver.ps1" -serve
    start http://127.0.0.1:1111/
    goto end
) else if "%choice%"=="2" (
    powershell -ExecutionPolicy Bypass -File "%~dp0builderserver.ps1" -build
    goto end
) else if "%choice%"=="3" (
    powershell -ExecutionPolicy Bypass -File "%~dp0builderserver.ps1" -auto
    exit
) else if "%choice%"=="0" (
    exit
) else (
    echo Invalid choice. Press any key to try again...
    pause >nul
    goto menu
)

:end
pause