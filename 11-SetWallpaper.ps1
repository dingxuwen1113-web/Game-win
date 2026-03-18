# ============================================================================
# Windows 11 Wallpaper Setting Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Set custom image as lock screen and desktop wallpaper
# ============================================================================

# Check for administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "ERROR: Administrator privileges required!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run this script as Administrator:" -ForegroundColor Yellow
    Write-Host "  1. Right-click on the script" -ForegroundColor Yellow
    Write-Host "  2. Select 'Run as administrator'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 11 Wallpaper Setter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Administrator privileges: Confirmed" -ForegroundColor Green
Write-Host ""

# Image path
$sourceImage = "C:\Users\dxw\Pictures\【哲风壁纸】jk-制服 - 动漫女孩.png"

Write-Host "[1/5] Checking source image..." -ForegroundColor Yellow

# Check if source image exists
if (-not (Test-Path $sourceImage)) {
    Write-Host "  ERROR: Source image not found!" -ForegroundColor Red
    Write-Host "  Path: $sourceImage" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Please verify the image path and try again." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "  OK: Image found" -ForegroundColor Green
Write-Host "  Path: $sourceImage" -ForegroundColor Gray

# Get image properties
$imageInfo = Get-Item $sourceImage
Write-Host "  Size: $([Math]::Round($imageInfo.Length/1MB, 2)) MB" -ForegroundColor Gray
Write-Host "  Type: $($imageInfo.Extension)" -ForegroundColor Gray
Write-Host ""

# 2. Copy image to Windows theme folder
Write-Host "[2/5] Copying image to Windows theme folder..." -ForegroundColor Yellow

$windowsThemesPath = "$env:SystemRoot\Web\Wallpaper\Windows11"
$destImage = "$windowsThemesPath\Custom_Wallpaper.png"

try {
    if (-not (Test-Path $windowsThemesPath)) {
        New-Item -ItemType Directory -Path $windowsThemesPath -Force | Out-Null
    }
    
    Copy-Item -Path $sourceImage -Destination $destImage -Force
    Write-Host "  OK: Image copied to $destImage" -ForegroundColor Green
}
catch {
    Write-Host "  ERROR: Failed to copy image - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}
Write-Host ""

# 3. Set as desktop wallpaper
Write-Host "[3/5] Setting desktop wallpaper..." -ForegroundColor Yellow

try {
    # Method 1: Using registry
    $regPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $regPath -Name "WallPaper" -Value $destImage -Force
    
    # Set wallpaper style (2 = Stretch, 10 = Fit, 6 = Fill)
    Set-ItemProperty -Path $regPath -Name "WallPaperStyle" -Value 10 -Force
    
    Write-Host "  OK: Desktop wallpaper set via registry" -ForegroundColor Green
}
catch {
    Write-Host "  WARN: Registry method failed" -ForegroundColor Yellow
}

try {
    # Method 2: Using Windows API (PowerShell wrapper)
    $signature = @"
[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@
    
    $type = Add-Type -MemberDefinition $signature -Name "Win32" -Namespace "Win32" -PassThru
    
    # SPI_SETDESKWALLPAPER = 20
    # SPIF_UPDATEINIFILE = 1
    # SPIF_SENDCHANGE = 2
    $result = $type::SystemParametersInfo(20, 0, $destImage, 3)
    
    if ($result -ne 0) {
        Write-Host "  OK: Desktop wallpaper set via API" -ForegroundColor Green
    }
}
catch {
    Write-Host "  INFO: API method not available (registry method used)" -ForegroundColor Gray
}
Write-Host ""

# 4. Set as lock screen
Write-Host "[4/5] Setting lock screen..." -ForegroundColor Yellow

try {
    # Generate a unique filename for lock screen
    $lockScreenImage = "$env:LOCALAPPDATA\Microsoft\Windows\LockScreen.png"
    Copy-Item -Path $sourceImage -Destination $lockScreenImage -Force
    
    # Set lock screen via registry
    $lockRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lock Screen"
    if (-not (Test-Path $lockRegPath)) {
        New-Item -Path $lockRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $lockRegPath -Name "LockScreenImage" -Value $lockScreenImage -Force
    
    Write-Host "  OK: Lock screen image set" -ForegroundColor Green
}
catch {
    Write-Host "  WARN: Lock screen setting may require manual selection in Settings" -ForegroundColor Yellow
    Write-Host "  TIP: Go to Settings > Personalization > Lock screen to select manually" -ForegroundColor Cyan
}
Write-Host ""

# 5. Refresh desktop
Write-Host "[5/5] Refreshing desktop..." -ForegroundColor Yellow

try {
    # Broadcast WM_SETTINGCHANGE to refresh desktop
    $signature = @"
[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageW(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr lParam);
"@
    
    $user32 = Add-Type -MemberDefinition $signature -Name "User32" -Namespace "Win32" -PassThru
    
    # HWND_BROADCAST = 0xFFFF
    # WM_SETTINGCHANGE = 0x001A
    $user32::SendMessageW(0xFFFF, 0x001A, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
    
    Write-Host "  OK: Desktop refreshed" -ForegroundColor Green
}
catch {
    Write-Host "  INFO: Desktop will refresh automatically" -ForegroundColor Gray
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wallpaper Setting Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Applied Settings:" -ForegroundColor Cyan
Write-Host "  OK: Desktop wallpaper set" -ForegroundColor Green
Write-Host "  OK: Lock screen set" -ForegroundColor Green
Write-Host "  OK: Wallpaper style: Fit (10)" -ForegroundColor Green
Write-Host ""
Write-Host "Image Information:" -ForegroundColor Cyan
Write-Host "  Source: $sourceImage" -ForegroundColor Gray
Write-Host "  Desktop: $destImage" -ForegroundColor Gray
Write-Host "  Lock Screen: $lockScreenImage" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTE: If wallpaper doesn't appear immediately:" -ForegroundColor Yellow
Write-Host "  - Press F5 to refresh desktop" -ForegroundColor White
Write-Host "  - Or sign out and sign back in" -ForegroundColor White
Write-Host "  - Lock screen may require manual selection in Settings" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
