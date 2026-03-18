@echo off
chcp 65001 > nul
title Windows 11 NetSpeed Optimization

color 0A
echo ========================================
echo   Windows 11 NetSpeed Optimization
echo   Version: 1.0.0
echo ========================================
echo.
echo   This script optimizes network speed by:
echo   - TCP/IP stack optimization
echo   - Network adapter advanced settings
echo   - Disabling network throttling
echo   - DNS optimization
echo   - Power management optimization
echo   - QoS configuration
echo.
echo   Requirements:
echo   - Windows 11 (21H2 or later)
echo   - Administrator privileges
echo   - PowerShell 5.1+
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    echo.
    echo Right-click this file - Run as administrator
    echo.
    pause
    exit /b 1
)

echo [OK] Administrator confirmed
echo.
echo [INFO] Starting network speed optimization...
echo [INFO] A system restore point will be created
echo.

pause

echo.
echo ========================================
echo   Running NetSpeed Optimization
echo ========================================
echo.

powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\04-NetSpeedOptimize.ps1 }"

if errorlevel 1 (
    echo.
    echo [WARN] NetSpeedOptimize completed with warnings
) else (
    echo.
    echo [OK] NetSpeedOptimize completed successfully
)

echo.
echo ========================================
echo   OPTIMIZATION COMPLETE!
echo ========================================
echo.
echo [IMPORTANT] Please restart your system now!
echo [INFO] Changes will take full effect after restart
echo.
echo [TIP] Run speed test before and after to see improvements
echo [TIP] For gaming, also run 03-GameOptimize.ps1
echo.

pause
