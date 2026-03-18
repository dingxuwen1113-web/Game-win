# ============================================================================
# Windows 11 System Restore Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# ============================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Run as Administrator!" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

Write-Host "=== Windows 11 System Restore ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Select restore option:" -ForegroundColor Yellow
Write-Host "  1. Restore all services" -ForegroundColor White
Write-Host "  2. Reinstall all apps" -ForegroundColor White
Write-Host "  3. Reset power plan" -ForegroundColor White
Write-Host "  4. Open System Restore" -ForegroundColor White
Write-Host "  0. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (0-4)"
Write-Host ""

if ($choice -eq "1") {
    Write-Host "Restoring services..." -ForegroundColor Yellow
    $services = @("DiagTrack", "dmwappushservice", "RemoteRegistry", "MapsBroker", "PhoneSvc", "Fax")
    foreach ($svc in $services) {
        try {
            Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "  OK: $svc" -ForegroundColor Green
        }
        catch {
            Write-Host "  SKIP: $svc" -ForegroundColor Gray
        }
    }
    Write-Host "Services restored!" -ForegroundColor Green
}
elseif ($choice -eq "2") {
    Write-Host "Reinstalling apps..." -ForegroundColor Yellow
    Get-AppxPackage -AllUsers | ForEach-Object {
        Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
    }
    Write-Host "Apps reinstalled! Restart required." -ForegroundColor Green
}
elseif ($choice -eq "3") {
    Write-Host "Resetting power plan..." -ForegroundColor Yellow
    powercfg -restoredefaultschemes
    Write-Host "Power plan reset!" -ForegroundColor Green
}
elseif ($choice -eq "4") {
    Write-Host "Opening System Restore..." -ForegroundColor Yellow
    rstrui.exe
}
elseif ($choice -eq "0") {
    Write-Host "Exiting..." -ForegroundColor Gray
}
else {
    Write-Host "Invalid option!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Start-Sleep -Seconds 3 }
