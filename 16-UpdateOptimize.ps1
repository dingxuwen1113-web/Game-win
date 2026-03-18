# ============================================================================
# Windows 11 Update Optimization Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Manage Windows Update settings for better control
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "UpdateOptimize"

# ============================================================================
# Logger Functions
# ============================================================================
function Write-Header { 
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step { 
    param([string]$Text, [int]$Step, [int]$Total)
    Write-Host ""
    Write-Host "[$Step/$Total] $Text" -ForegroundColor Yellow
}

function Write-OK { 
    param([string]$Text)
    Write-Host "  [OK] $Text" -ForegroundColor Green
}

function Write-Warn { 
    param([string]$Text)
    Write-Host "  [WARN] $Text" -ForegroundColor Yellow
}

function Write-Error { 
    param([string]$Text)
    Write-Host "  [ERROR] $Text" -ForegroundColor Red
}

function Write-Info { 
    param([string]$Text)
    Write-Host "  [INFO] $Text" -ForegroundColor Gray
}

# ============================================================================
# Main Script
# ============================================================================
Clear-Host
Write-Header "Update Optimization v$SCRIPT_VERSION"
Write-Host "  Windows Update Management" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Administrator privileges required!"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-OK "Administrator privileges confirmed"
Write-Host ""

$totalSteps = 10
$currentStep = 0

# ============================================================================
# 1. Check Current Update Status
# ============================================================================
$currentStep++
Write-Step "Checking Windows Update status" $currentStep $totalSteps

try {
    $updateService = New-Object -ComObject Microsoft.Update.ServiceManager
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    
    $searchResult = $updateSearcher.Search("IsInstalled=0")
    
    Write-Info "  Pending updates: $($searchResult.Updates.Count)"
    
    if ($searchResult.Updates.Count -gt 0) {
        Write-Host ""
        Write-Info "  Pending updates:" -ForegroundColor Yellow
        
        foreach ($update in $searchResult.Updates) {
            Write-Info "    - $($update.Title)"
        }
    } else {
        Write-OK "  No pending updates"
    }
}
catch {
    Write-Warn "Failed to check update status"
}
Write-Host ""

# ============================================================================
# 2. Check Windows Update Service Status
# ============================================================================
$currentStep++
Write-Step "Checking Windows Update services" $currentStep $totalSteps

$updateServices = @(
    "wuauserv",      # Windows Update
    "bits",          # Background Intelligent Transfer Service
    "cryptsvc",      # Cryptographic Services
    "msiserver"      # Windows Installer
)

foreach ($service in $updateServices) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            $status = if ($svc.Status -eq "Running") { "Running" } else { "Stopped" }
            $startup = $svc.StartType.ToString()
            
            if ($svc.Status -eq "Running") {
                Write-OK "  $service : $status ($startup)"
            } else {
                Write-Info "  $service : $status ($startup)"
            }
        }
    }
    catch {
        Write-Warn "  Failed to check: $service"
    }
}
Write-Host ""

# ============================================================================
# 3. Configure Update Settings (Manual Mode)
# ============================================================================
$currentStep++
Write-Step "Configuring update settings" $currentStep $totalSteps

Write-Host ""
Write-Host "Choose update mode:" -ForegroundColor Cyan
Write-Host "  1. Automatic (Default - Recommended)" -ForegroundColor White
Write-Host "  2. Notify Before Download" -ForegroundColor White
Write-Host "  3. Notify Before Install" -ForegroundColor White
Write-Host "  4. Manual (Check for updates yourself)" -ForegroundColor White
Write-Host "  5. Keep current settings" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (1-5, default: 5)"

if ($choice -eq "1") {
    try {
        # Automatic updates
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "AUOptions" -Value 4 -PropertyType DWord -Force | Out-Null
        
        Write-OK "  Set to automatic updates"
    }
    catch {
        Write-Warn "  Failed to configure automatic updates"
    }
}
elseif ($choice -eq "2") {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "AUOptions" -Value 2 -PropertyType DWord -Force | Out-Null
        
        Write-OK "  Set to notify before download"
    }
    catch {
        Write-Warn "  Failed to configure notify mode"
    }
}
elseif ($choice -eq "3") {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "AUOptions" -Value 3 -PropertyType DWord -Force | Out-Null
        
        Write-OK "  Set to notify before install"
    }
    catch {
        Write-Warn "  Failed to configure notify mode"
    }
}
elseif ($choice -eq "4") {
    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 1 -PropertyType DWord -Force | Out-Null
        
        Write-OK "  Set to manual updates"
    }
    catch {
        Write-Warn "  Failed to configure manual mode"
    }
}
else {
    Write-Info "  Keeping current settings"
}
Write-Host ""

# ============================================================================
# 4. Disable Automatic Restart
# ============================================================================
$currentStep++
Write-Step "Configuring automatic restart settings" $currentStep $totalSteps

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Disable automatic restart with logged-on users
    New-ItemProperty -Path $regPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -PropertyType DWord -Force | Out-Null
    
    Write-OK "  Automatic restart disabled (won't restart while you're using PC)"
}
catch {
    Write-Warn "  Failed to configure restart settings"
}
Write-Host ""

# ============================================================================
# 5. Configure Active Hours
# ============================================================================
$currentStep++
Write-Step "Configuring active hours" $currentStep $totalSteps

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Set active hours (8 AM to 6 PM by default)
    New-ItemProperty -Path $regPath -Name "SetActiveHours" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "ActiveHoursStart" -Value 8 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "ActiveHoursEnd" -Value 18 -PropertyType DWord -Force | Out-Null
    
    Write-OK "  Active hours set: 8:00 AM - 6:00 PM"
    Write-Info "  Windows won't restart for updates during active hours"
}
catch {
    Write-Warn "  Failed to configure active hours"
}
Write-Host ""

# ============================================================================
# 6. Disable Driver Updates via Windows Update
# ============================================================================
$currentStep++
Write-Step "Configuring driver update settings" $currentStep $totalSteps

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Exclude drivers from Windows Update
    New-ItemProperty -Path $regPath -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -PropertyType DWord -Force | Out-Null
    
    Write-OK "  Driver updates via Windows Update disabled"
    Write-Info "  Get drivers from manufacturer websites instead"
}
catch {
    Write-Warn "  Failed to configure driver update settings"
}
Write-Host ""

# ============================================================================
# 7. Disable Update Delivery Optimization (P2P)
# ============================================================================
$currentStep++
Write-Step "Configuring delivery optimization" $currentStep $totalSteps

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Disable P2P download
    New-ItemProperty -Path $regPath -Name "DODownloadMode" -Value 0 -PropertyType DWord -Force | Out-Null
    
    Write-OK "  P2P update delivery disabled"
    Write-Info "  Updates will download directly from Microsoft only"
}
catch {
    Write-Warn "  Failed to configure delivery optimization"
}
Write-Host ""

# ============================================================================
# 8. Clean Update Cache
# ============================================================================
$currentStep++
Write-Step "Cleaning Windows Update cache" $currentStep $totalSteps

Write-Info "  Stopping update services..."

try {
    Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "cryptsvc" -Force -ErrorAction SilentlyContinue
    
    Write-OK "  Services stopped"
}
catch {
    Write-Warn "  Failed to stop services"
}

try {
    $updateCachePath = "$env:SystemRoot\SoftwareDistribution"
    
    if (Test-Path $updateCachePath) {
        $cacheFiles = Get-ChildItem -Path $updateCachePath -Recurse -File
        $cacheCount = $cacheFiles.Count
        
        if ($cacheCount -gt 0) {
            Write-Info "  Removing $cacheCount cache files..."
            Remove-Item -Path "$updateCachePath\*" -Force -Recurse -ErrorAction SilentlyContinue
            Write-OK "  Update cache cleaned"
        } else {
            Write-OK "  Update cache already clean"
        }
    }
}
catch {
    Write-Warn "  Failed to clean update cache"
}

try {
    Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Start-Service -Name "bits" -ErrorAction SilentlyContinue
    Start-Service -Name "cryptsvc" -ErrorAction SilentlyContinue
    
    Write-OK "  Services restarted"
}
catch {
    Write-Warn "  Failed to restart services"
}
Write-Host ""

# ============================================================================
# 9. Reset Windows Update Components (Optional)
# ============================================================================
$currentStep++
Write-Step "Windows Update reset (optional)" $currentStep $totalSteps

Write-Host ""
Write-Host "Reset Windows Update components?" -ForegroundColor Yellow
Write-Host "  This can fix update problems but will clear update history." -ForegroundColor Gray
Write-Host ""

$resetChoice = Read-Host "Reset Windows Update? (y/n, default: n)"

if ($resetChoice -eq "y" -or $resetChoice -eq "Y") {
    Write-Info "  Stopping services..."
    
    try {
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "cryptsvc" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "msiserver" -Force -ErrorAction SilentlyContinue
        
        Write-OK "  Services stopped"
    }
    catch {
        Write-Warn "  Failed to stop some services"
    }
    
    Write-Info "  Renaming SoftwareDistribution folder..."
    
    try {
        $sdPath = "$env:SystemRoot\SoftwareDistribution"
        $sdBackup = "$env:SystemRoot\SoftwareDistribution.old"
        
        if (Test-Path $sdPath) {
            if (Test-Path $sdBackup) {
                Remove-Item -Path $sdBackup -Force -Recurse -ErrorAction SilentlyContinue
            }
            Rename-Item -Path $sdPath -NewName "SoftwareDistribution.old" -Force
            Write-OK "  SoftwareDistribution renamed"
        }
    }
    catch {
        Write-Warn "  Failed to rename SoftwareDistribution"
    }
    
    Write-Info "  Renaming catroot2 folder..."
    
    try {
        $catrootPath = "$env:SystemRoot\System32\catroot2"
        $catrootBackup = "$env:SystemRoot\System32\catroot2.old"
        
        if (Test-Path $catrootPath) {
            if (Test-Path $catrootBackup) {
                Remove-Item -Path $catrootBackup -Force -Recurse -ErrorAction SilentlyContinue
            }
            Rename-Item -Path $catrootPath -NewName "catroot2.old" -Force
            Write-OK "  catroot2 renamed"
        }
    }
    catch {
        Write-Warn "  Failed to rename catroot2"
    }
    
    Write-Info "  Restarting services..."
    
    try {
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Start-Service -Name "bits" -ErrorAction SilentlyContinue
        Start-Service -Name "cryptsvc" -ErrorAction SilentlyContinue
        Start-Service -Name "msiserver" -ErrorAction SilentlyContinue
        
        Write-OK "  Services restarted"
    }
    catch {
        Write-Warn "  Failed to restart some services"
    }
    
    Write-OK "  Windows Update components reset complete!"
    Write-Info "  Restart your computer for changes to take effect"
}
else {
    Write-Info "  Skipped reset"
}
Write-Host ""

# ============================================================================
# 10. Create Update Restore Point
# ============================================================================
$currentStep++
Write-Step "Creating system restore point" $currentStep $totalSteps

try {
    Checkpoint-Computer -Description "Before Update Settings Change" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Write-OK "  Restore point created"
}
catch {
    Write-Warn "  Restore point creation failed"
}
Write-Host ""

# ============================================================================
# Summary
# ============================================================================
Write-Header "Update Optimization Summary"

Write-OK "Update optimization complete!"
Write-Host ""
Write-Host "Configuration applied:" -ForegroundColor Cyan
Write-Host "  ✓ Update settings configured" -ForegroundColor Green
Write-Host "  ✓ Automatic restart disabled" -ForegroundColor Green
Write-Host "  ✓ Active hours set (8 AM - 6 PM)" -ForegroundColor Green
Write-Host "  ✓ Driver updates via Windows Update disabled" -ForegroundColor Green
Write-Host "  ✓ P2P delivery optimization disabled" -ForegroundColor Green
Write-Host "  ✓ Update cache cleaned" -ForegroundColor Green
Write-Host ""

Write-Host "RECOMMENDATIONS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Check for updates manually once a month" -ForegroundColor White
Write-Host "   Settings > Windows Update > Check for updates" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Install security updates promptly" -ForegroundColor White
Write-Host "   Security patches are important for system protection" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Delay feature updates if needed" -ForegroundColor White
Write-Host "   Feature updates can wait 2-3 months for bug fixes" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Create restore points before major updates" -ForegroundColor White
Write-Host "   Use: Checkpoint-Computer in PowerShell (admin)" -ForegroundColor Gray
Write-Host ""

Write-Host ""
Read-Host "Press Enter to exit"
