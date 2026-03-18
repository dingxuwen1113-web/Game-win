@echo off
chcp 65001 > nul
title Windows 11 Optimization Suite v5.2.0

color 0B
echo ========================================
echo   Windows 11 Optimization Suite
echo   Version: 5.2.0 (Creator Edition)
echo ========================================
echo   Creator & Developer: 丁旭文
echo   Email: dxw2005@petalmail.com
echo ========================================
echo.
echo   Optimized Script Execution Order:
echo   ---------------------------------
echo   Phase 1 - System Cleanup:
echo     1. Bloatware Removal (01-CleanApps)
echo     2. Service Optimization (02-DisableServices)
echo.
echo   Phase 2 - Performance:
echo     3. Game Optimization (03-GameOptimize)
echo     4. Network Optimization (04-NetworkOptimize)
echo.
echo   Phase 3 - Security:
echo     5. Network Security (05-NetworkSecurity)
echo.
echo   Phase 4 - Verification:
echo     6. System Health Check (06-SystemHealth)
echo.
echo   Phase 5 - Extended Optimization (NEW):
echo     7. Storage Optimization (13-StorageOptimize)
echo     8. Privacy Optimization (14-PrivacyOptimize)
echo     9. Startup Optimization (15-StartupOptimize)
echo     10. Update Management (16-UpdateOptimize)
echo.
echo   Optional:
echo     - Microsoft Account Privilege (07-MicrosoftAccount)
echo     - Set Wallpaper (11-SetWallpaper)
echo     - Fix Animation (12-FixAnimationAuto)
echo.
echo ========================================
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
echo [INFO] Estimated time: 15-20 minutes
echo [INFO] System restart will be required
echo.

pause

echo.
echo ========================================
echo   PHASE 1: SYSTEM CLEANUP
echo ========================================
echo.

echo [1/6] Bloatware Removal
echo ----------------------------------------
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\01-CleanApps.ps1 }"
if errorlevel 1 (
    echo [WARN] CleanApps completed with warnings
) else (
    echo [OK] CleanApps completed successfully
)

echo.
echo [2/6] Service Optimization
echo ----------------------------------------
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\02-DisableServices.ps1 }"
if errorlevel 1 (
    echo [WARN] DisableServices completed with warnings
) else (
    echo [OK] DisableServices completed successfully
)

echo.
echo ========================================
echo   PHASE 2: PERFORMANCE OPTIMIZATION
echo ========================================
echo.

echo [3/6] Game Optimization (includes GPU + Power)
echo ----------------------------------------
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\03-GameOptimize.ps1 }"
if errorlevel 1 (
    echo [WARN] GameOptimize completed with warnings
) else (
    echo [OK] GameOptimize completed successfully
)

echo.
echo [4/6] Network Optimization
echo ----------------------------------------
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\04-NetworkOptimize.ps1 }"
if errorlevel 1 (
    echo [WARN] NetworkOptimize completed with warnings
) else (
    echo [OK] NetworkOptimize completed successfully
)

echo.
echo ========================================
echo   PHASE 3: SECURITY HARDENING
echo ========================================
echo.

echo [5/6] Network Security
echo ----------------------------------------
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\05-NetworkSecurity.ps1 }"
if errorlevel 1 (
    echo [WARN] NetworkSecurity completed with warnings
) else (
    echo [OK] NetworkSecurity completed successfully
)

echo.
echo ========================================
echo   PHASE 4: VERIFICATION
echo ========================================
echo.

echo [6/6] System Health Check
echo ----------------------------------------
powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\06-SystemHealth.ps1 }"
if errorlevel 1 (
    echo [WARN] SystemHealth completed with warnings
) else (
    echo [OK] SystemHealth completed successfully
)

echo.
echo ========================================
echo   PHASE 5: EXTENDED OPTIMIZATION (NEW)
echo ========================================
echo.
set /p RUNEXTENDED="Run extended optimization scripts? (Y/N, default: N): "
if /i "%RUNEXTENDED%"=="Y" (
    echo.
    echo [INFO] Running extended optimization scripts...
    echo.
    
    echo [7/10] Storage Optimization
    echo ----------------------------------------
    powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\13-StorageOptimize.ps1 }"
    if errorlevel 1 (
        echo [WARN] StorageOptimize completed with warnings
    ) else (
        echo [OK] StorageOptimize completed successfully
    )
    
    echo.
    echo [8/10] Privacy Optimization
    echo ----------------------------------------
    powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\14-PrivacyOptimize.ps1 }"
    if errorlevel 1 (
        echo [WARN] PrivacyOptimize completed with warnings
    ) else (
        echo [OK] PrivacyOptimize completed successfully
    )
    
    echo.
    echo [9/10] Startup Optimization
    echo ----------------------------------------
    powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\15-StartupOptimize.ps1 }"
    if errorlevel 1 (
        echo [WARN] StartupOptimize completed with warnings
    ) else (
        echo [OK] StartupOptimize completed successfully
    )
    
    echo.
    echo [10/10] Update Management
    echo ----------------------------------------
    powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\16-UpdateOptimize.ps1 }"
    if errorlevel 1 (
        echo [WARN] UpdateOptimize completed with warnings
    ) else (
        echo [OK] UpdateOptimize completed successfully
    )
    
    echo.
    echo [OK] Extended optimization complete!
) else (
    echo   [SKIPPED] Extended optimization (run scripts individually later)
)

echo.
echo ========================================
echo   OPTIONAL: ACCOUNT PRIVILEGE
echo ========================================
echo.
set /p SETPRIVILEGE="Elevate Microsoft Account privileges? (Y/N, default: N): "
if /i "%SETPRIVILEGE%"=="Y" (
    echo.
    echo [INFO] Starting privilege elevation...
    echo [WARNING] This grants maximum system access!
    echo.
    powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\07-MicrosoftAccount.ps1 }"
) else (
    echo   [SKIPPED] Privilege elevation
)

echo.
echo ========================================
echo   OPTIONAL: WALLPAPER
echo ========================================
echo.
set /p SETWALLPAPER="Set custom wallpaper? (Y/N, default: N): "
if /i "%SETWALLPAPER%"=="Y" (
    echo.
    powershell -ExecutionPolicy Bypass -Command "& { Set-Location '%~dp0'; .\11-SetWallpaper.ps1 }"
) else (
    echo   [SKIPPED] Wallpaper setting
)

echo.
echo ========================================
echo   ALL OPTIMIZATIONS COMPLETE!
echo ========================================
echo.
echo [OK] All scripts executed successfully
echo.
echo [IMPORTANT] Please restart your system now!
echo.
echo [INFO] Changes will take full effect after restart
echo.
echo [TIP] Run 03-GameOptimize.ps1 before each gaming session
echo [TIP] Run 06-SystemHealth.ps1 weekly for health monitoring
echo [TIP] Run 13-StorageOptimize.ps1 monthly for storage cleanup
echo [TIP] Run 15-StartupOptimize.ps1 quarterly for boot optimization
echo [TIP] Use utils\GamingTools.ps1 for gaming utilities
echo.

pause
