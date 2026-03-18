@echo off
chcp 65001 > nul
title Windows 11 Optimization Suite - Menu v5.2.0

color 0B
cls

:MAIN_MENU
cls
echo ========================================
echo   Windows 11 Optimization Suite
echo   Version: 5.2.0 (Creator Edition)
echo ========================================
echo   Creator & Developer: 丁旭文
echo   Email: dxw2005@petalmail.com
echo ========================================
echo.
echo   Main Menu:
echo   ----------
echo   [1] Core Optimizations
echo   [2] Extended Optimizations
echo   [3] System Tools
echo   [4] Gaming Tools
echo   [5] Quick Deploy
echo   [6] System Benchmark
echo   [7] Documentation
echo   [0] Exit
echo.
echo ========================================
echo.
set /p CHOICE="Select option (0-7): "

if "%CHOICE%"=="1" goto CORE_OPT
if "%CHOICE%"=="2" goto EXTENDED_OPT
if "%CHOICE%"=="3" goto SYSTEM_TOOLS
if "%CHOICE%"=="4" goto GAMING_TOOLS
if "%CHOICE%"=="5" goto QUICK_DEPLOY
if "%CHOICE%"=="6" goto BENCHMARK
if "%CHOICE%"=="7" goto DOCS
if "%CHOICE%"=="0" goto EXIT
goto MAIN_MENU

:CORE_OPT
cls
echo ========================================
echo   Core Optimizations
echo ========================================
echo.
echo   [1] Clean Bloatware (01-CleanApps)
echo   [2] Disable Services (02-DisableServices)
echo   [3] Game Optimization (03-GameOptimize)
echo   [4] Network Optimization (04-NetworkOptimize)
echo   [5] Network Security (05-NetworkSecurity)
echo   [6] System Health Check (06-SystemHealth)
echo   [7] NetSpeed Optimization (04-NetSpeedOptimize) [NEW]
echo   [0] Back
echo.
set /p CORE_CHOICE="Select option (0-7): "

if "%CORE_CHOICE%"=="1" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\01-CleanApps.ps1 }"
if "%CORE_CHOICE%"=="2" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\02-DisableServices.ps1 }"
if "%CORE_CHOICE%"=="3" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\03-GameOptimize.ps1 }"
if "%CORE_CHOICE%"=="4" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\04-NetworkOptimize.ps1 }"
if "%CORE_CHOICE%"=="5" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\05-NetworkSecurity.ps1 }"
if "%CORE_CHOICE%"=="6" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\06-SystemHealth.ps1 }"
if "%CORE_CHOICE%"=="7" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\04-NetSpeedOptimize.ps1 }"
goto CORE_OPT

:EXTENDED_OPT
cls
echo ========================================
echo   Extended Optimizations
echo ========================================
echo.
echo   [1] Storage Optimization (13-StorageOptimize) [NEW]
echo   [2] Privacy Optimization (14-PrivacyOptimize) [NEW]
echo   [3] Startup Optimization (15-StartupOptimize) [NEW]
echo   [4] Update Management (16-UpdateOptimize) [NEW]
echo   [5] Fix Animation (12-FixAnimationAuto)
echo   [6] Set Wallpaper (11-SetWallpaper)
echo   [7] Backup ^& Restore (17-BackupAndRestore) [NEW]
echo   [0] Back
echo.
set /p EXT_CHOICE="Select option (0-7): "

if "%EXT_CHOICE%"=="1" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\13-StorageOptimize.ps1 }"
if "%EXT_CHOICE%"=="2" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\14-PrivacyOptimize.ps1 }"
if "%EXT_CHOICE%"=="3" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\15-StartupOptimize.ps1 }"
if "%EXT_CHOICE%"=="4" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\16-UpdateOptimize.ps1 }"
if "%EXT_CHOICE%"=="5" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\12-FixAnimationAuto.ps1 }"
if "%EXT_CHOICE%"=="6" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\11-SetWallpaper.ps1 }"
if "%EXT_CHOICE%"=="7" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\17-BackupAndRestore.ps1 }"
goto EXTENDED_OPT

:SYSTEM_TOOLS
cls
echo ========================================
echo   System Tools
echo ========================================
echo.
echo   [1] System Benchmark [NEW]
echo   [2] System Restore (09-Restore)
echo   [3] Fix Registry Permissions (10-FixRegistryPermissions)
echo   [4] View Logs
echo   [0] Back
echo.
set /p TOOL_CHOICE="Select option (0-4): "

if "%TOOL_CHOICE%"=="1" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\utils\SystemBenchmark.ps1 }"
if "%TOOL_CHOICE%"=="2" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\09-Restore.ps1 }"
if "%TOOL_CHOICE%"=="3" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\10-FixRegistryPermissions.ps1 }"
if "%TOOL_CHOICE%"=="4" (
    if exist "%~dp0logs" (
        dir "%~dp0logs" /B /O-D
        pause
    ) else (
        echo No logs directory found
        pause
    )
)
goto SYSTEM_TOOLS

:GAMING_TOOLS
cls
echo ========================================
echo   Gaming Tools
echo ========================================
echo.
echo   [1] Quick Game Mode (30 seconds)
echo   [2] Full Game Optimization
echo   [3] Gaming Tools Menu
echo   [4] Game Memory Optimization
echo   [0] Back
echo.
set /p GAME_CHOICE="Select option (0-4): "

if "%GAME_CHOICE%"=="1" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\03-GameOptimize.ps1 -QuickMode }"
if "%GAME_CHOICE%"=="2" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\03-GameOptimize.ps1 }"
if "%GAME_CHOICE%"=="3" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\utils\GamingTools.ps1 }"
if "%GAME_CHOICE%"=="4" powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\utils\GameMemoryOptimize.ps1 }"
goto GAMING_TOOLS

:QUICK_DEPLOY
cls
echo ========================================
echo   Quick Deploy
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\18-QuickDeploy.ps1 }"
goto MAIN_MENU

:BENCHMARK
cls
echo ========================================
echo   System Benchmark
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\utils\SystemBenchmark.ps1 }"
goto MAIN_MENU

:DOCS
cls
echo ========================================
echo   Documentation
echo ========================================
echo.
echo   [1] README.md
echo   [2] NEW_FEATURES_v5.md
echo   [3] OPTIMIZATION_STRATEGIES.md
echo   [4] QUICK_START.md
echo   [5] TROUBLESHOOTING.md
echo   [6] VERSION.md
echo   [0] Back
echo.
set /p DOC_CHOICE="Select option (0-6): "

if "%DOC_CHOICE%"=="1" start notepad "%~dp0README.md"
if "%DOC_CHOICE%"=="2" start notepad "%~dp0NEW_FEATURES_v5.md"
if "%DOC_CHOICE%"=="3" start notepad "%~dp0OPTIMIZATION_STRATEGIES.md"
if "%DOC_CHOICE%"=="4" start notepad "%~dp0QUICK_START.md"
if "%DOC_CHOICE%"=="5" start notepad "%~dp0TROUBLESHOOTING.md"
if "%DOC_CHOICE%"=="6" start notepad "%~dp0VERSION.md"
goto DOCS

:EXIT
cls
echo.
echo ========================================
echo   Thank you for using
echo   Windows 11 Optimization Suite!
echo ========================================
echo.
timeout /t 2 > nul
exit

:MAIN_MENU
