@echo off
title Run Website Scripts

:menu
cls
echo ================================
echo    Personal Website Launcher
echo ================================
echo.
echo 1. Run fastserve
echo 2. Run fastbuild
echo 3. Run autobuild
echo 0. Exit
echo.
set /p choice="Choose an option: "

if "%choice%"=="1" (
    call fastserve.bat
    goto end
) else if "%choice%"=="2" (
    call fastbuild.bat
    goto end
) else if "%choice%"=="3" (
    call autobuild.bat
    goto end
) else if "%choice%"=="0" (
    exit
) else (
    echo Invalid choice. Press any key to try again...
    pause >nul
    goto menu
)

:end
pause
