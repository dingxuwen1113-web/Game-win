# ============================================================================
# Windows 11 Bloatware Removal Script v2.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 2.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# ============================================================================

$SCRIPT_VERSION = "2.0.0"
$SCRIPT_NAME = "CleanApps"

# Header
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 11 Bloatware Removal v$SCRIPT_VERSION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] Administrator privileges required!" -ForegroundColor Red
    Write-Host "  Right-click this script and select 'Run as administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[OK] Administrator privileges confirmed" -ForegroundColor Green
Write-Host ""

# Step 1: Create restore point
Write-Host "[1/4] Creating system restore point..." -ForegroundColor Yellow
try {
    Checkpoint-Computer -Description "Before Bloatware Removal" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  [OK] Restore point created" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Restore point creation failed (manual creation recommended)" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Define whitelist (apps to keep)
Write-Host "[2/4] Loading app whitelist..." -ForegroundColor Yellow
$KeepApps = @(
    # Essential System Apps
    "Microsoft.WindowsStore",
    "Microsoft.MicrosoftEdge",
    "Microsoft.Photos",
    "Microsoft.Calculator",
    "Microsoft.Notepad",
    "Microsoft.Paint",
    "Microsoft.ScreenSketch",
    "Microsoft.WindowsCalculator",
    "Microsoft.Windows.Photos",
    "Microsoft.StorePurchaseApp",
    
    # System Components (DO NOT REMOVE)
    "Microsoft.UI.Xaml",
    "Microsoft.AAD",
    "Microsoft.AccountsControl",
    "Microsoft.Windows.ShellExperienceHost",
    "Microsoft.Windows.Cortana",
    "Microsoft.Windows.SecHealthUI",
    
    # Windows Terminal (PRESERVED)
    "Microsoft.WindowsTerminal",
    "Microsoft.WindowsTerminal.Preview",
    "Microsoft.Windows.PowerShell.ISE"
)
Write-Host "  [OK] Whitelist loaded ($($KeepApps.Count) protected apps)" -ForegroundColor Green
Write-Host "  [INFO] Windows Terminal is protected and will not be removed" -ForegroundColor Cyan
Write-Host ""

# Step 3: Remove bloatware
Write-Host "[3/4] Removing bloatware..." -ForegroundColor Yellow
Write-Host ""

$allApps = Get-AppxPackage
$removed = 0
$failed = 0
$skipped = 0

foreach ($app in $allApps) {
    # Check if app is in whitelist
    $keep = $false
    foreach ($k in $KeepApps) {
        if ($app.Name -like "*$k*") {
            $keep = $true
            break
        }
    }
    
    # Skip protected system apps
    if ($app.Name -match "Microsoft\.UI\.|Microsoft\.AAD\.|Microsoft\.Accounts|ShellExperience|Cortana|SecHealth|WindowsTerminal|PowerShell") {
        $keep = $true
    }
    
    if (-not $keep) {
        try {
            Remove-AppxPackage -Package $app.PackageFullName -ErrorAction Stop
            Write-Host "  [-] Removed: $($app.Name)" -ForegroundColor Green
            $removed++
        }
        catch {
            Write-Host "  [!] Failed: $($app.Name) (protected or in use)" -ForegroundColor Yellow
            $failed++
        }
    }
    else {
        $skipped++
    }
}

Write-Host ""

# Step 4: Summary
Write-Host "[4/4] Cleanup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Apps removed:  $removed" -ForegroundColor $(if ($removed -gt 0) { "Green" } else { "Gray" })
Write-Host "  Apps failed:   $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "  Apps skipped:  $skipped (protected)" -ForegroundColor Gray
Write-Host ""

if ($removed -gt 0) {
    Write-Host "[INFO] Restart recommended to complete cleanup" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
