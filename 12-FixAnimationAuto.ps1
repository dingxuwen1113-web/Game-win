# ============================================================================
# Windows 11 Animation Effects Fix - Auto Mode
# Windows 11 Optimization Suite - Animation & Visual Effects
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Automatically fix and enable Windows 11 animation effects
# Usage: .\12-FixAnimationAuto.ps1
# ============================================================================

# Load Logger Module
. .\Logger.ps1

$SCRIPT_VERSION = "1.0.0"

Clear-Host

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Animation Fix v$SCRIPT_VERSION" -ForegroundColor Cyan
Write-Host "  Auto Mode - Enabling All Animations" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  [WARN] Running without administrator privileges" -ForegroundColor Yellow
    Write-Host ""
}

$success = 0
$total = 0

# 1. Enable Window Animations
Write-Host "[1/8] Configuring Window Animations..." -ForegroundColor Yellow
try {
    $path = "HKCU:\Control Panel\Desktop"
    $defaultPrefs = [byte[]](158, 18, 3, 128, 16, 0, 0, 0)
    Set-ItemProperty -Path $path -Name "UserPreferencesMask" -Value $defaultPrefs -Force
    Set-ItemProperty -Path $path -Name "MinAnimate" -Value "1" -Type String -Force
    Write-Host "  [OK] Window animations enabled" -ForegroundColor Green
    $success++
}
catch {
    Write-Host "  [WARN] Failed to enable window animations" -ForegroundColor Yellow
}
$total++
Write-Host ""

# 2. Enable Transparency Effects
Write-Host "[2/8] Configuring Transparency Effects..." -ForegroundColor Yellow
try {
    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "EnableTransparency" -Value 1 -Type DWord -Force
    Write-Host "  [OK] Transparency effects enabled" -ForegroundColor Green
    $success++
}
catch {
    Write-Host "  [WARN] Failed to enable transparency" -ForegroundColor Yellow
}
$total++
Write-Host ""

# 3. Enable Smooth Scrolling
Write-Host "[3/8] Configuring Smooth Scrolling..." -ForegroundColor Yellow
try {
    $path = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $path -Name "SmoothScroll" -Value 1 -Type DWord -Force
    Write-Host "  [OK] Smooth scrolling enabled" -ForegroundColor Green
    $success++
}
catch {
    Write-Host "  [WARN] Failed to enable smooth scrolling" -ForegroundColor Yellow
}
$total++
Write-Host ""

# 4. Enable Fade Effects
Write-Host "[4/8] Configuring Fade Effects..." -ForegroundColor Yellow
try {
    $path = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $path -Name "MenuShowDelay" -Value "0" -Type String -Force
    Write-Host "  [OK] Fade effects configured" -ForegroundColor Green
    $success++
}
catch {
    Write-Host "  [WARN] Failed to configure fade effects" -ForegroundColor Yellow
}
$total++
Write-Host ""

# 5. Enable Shadow Effects
Write-Host "[5/8] Configuring Shadow Effects..." -ForegroundColor Yellow
try {
    $path = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $path -Name "ListviewShadow" -Value "1" -Type String -Force
    Write-Host "  [OK] Shadow effects enabled" -ForegroundColor Green
    $success++
}
catch {
    Write-Host "  [WARN] Failed to enable shadow effects" -ForegroundColor Yellow
}
$total++
Write-Host ""

# 6. Configure Font Smoothing (ClearType)
Write-Host "[6/8] Configuring Font Smoothing..." -ForegroundColor Yellow
try {
    $path = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $path -Name "FontSmoothing" -Value "2" -Type String -Force
    Set-ItemProperty -Path $path -Name "FontSmoothingType" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $path -Name "FontSmoothingGamma" -Value 1400 -Type DWord -Force
    Write-Host "  [OK] Font smoothing configured (ClearType)" -ForegroundColor Green
    $success++
}
catch {
    Write-Host "  [WARN] Failed to configure font smoothing" -ForegroundColor Yellow
}
$total++
Write-Host ""

# 7. Fix Animation Stuttering
Write-Host "[7/8] Fixing Animation Stuttering..." -ForegroundColor Yellow
try {
    # GPU performance mode
    $path = "HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences"
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "UserGpuPreference" -Value 2 -Type DWord -Force
    Write-Host "  [OK] GPU performance mode enabled" -ForegroundColor Green
    $success++
}
catch {
    Write-Host "  [WARN] Failed to configure GPU preferences" -ForegroundColor Yellow
}
$total++
Write-Host ""

# 8. Apply Changes (Restart Explorer)
Write-Host "[8/8] Applying Changes..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Changes will take effect after restarting Explorer" -ForegroundColor Yellow
Write-Host ""

$restart = Read-Host "  Restart Explorer now? (Y/N, default: Y)"

if ($restart -eq "" -or $restart -eq "Y" -or $restart -eq "y") {
    try {
        Stop-Process -Name "explorer" -Force -ErrorAction Stop
        Write-Host "  [OK] Explorer restarted" -ForegroundColor Green
        Write-Host "  [INFO] Desktop will flicker briefly" -ForegroundColor Cyan
        $success++
    }
    catch {
        Write-Host "  [WARN] Failed to restart Explorer (manual restart recommended)" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  [INFO] Explorer restart skipped (manual restart later)" -ForegroundColor Cyan
    $success++
}
$total++
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Animation Fix Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Successful: $success / $total" -ForegroundColor Green
Write-Host ""

if ($success -eq $total) {
    Write-Host "  ALL OPERATIONS COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Tips:" -ForegroundColor Cyan
Write-Host "  - If animations still seem off, sign out and sign back in" -ForegroundColor Gray
Write-Host "  - For best results, restart your computer" -ForegroundColor Gray
Write-Host "  - Update GPU drivers for optimal animation performance" -ForegroundColor Gray
Write-Host ""

Write-Host "Log file: $(Get-LogFile)" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
