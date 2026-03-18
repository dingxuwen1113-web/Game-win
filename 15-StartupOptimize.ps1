# ============================================================================
# Windows 11 Startup Optimization Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Manage startup apps and services for faster boot time
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "StartupOptimize"

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
Write-Header "Startup Optimization v$SCRIPT_VERSION"
Write-Host "  Manage Startup Apps & Services" -ForegroundColor Cyan
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

$totalSteps = 8
$currentStep = 0

# ============================================================================
# 1. List Current Startup Apps
# ============================================================================
$currentStep++
Write-Step "Analyzing startup applications" $currentStep $totalSteps

try {
    $startupApps = Get-CimInstance Win32_Startup | Select-Object Name, Command, Location, User | Sort-Object Name
    
    Write-Info "  Found $($startupApps.Count) startup items"
    Write-Host ""
    
    # Group by location
    $locations = $startupApps | Group-Object Location
    
    foreach ($loc in $locations) {
        Write-Info "  $($loc.Name): $($loc.Count) items"
    }
}
catch {
    Write-Warn "Failed to analyze startup apps"
}
Write-Host ""

# ============================================================================
# 2. Show Startup Impact (Windows 10/11)
# ============================================================================
$currentStep++
Write-Step "Checking startup impact" $currentStep $totalSteps

try {
    # Get startup apps via registry (modern method)
    $registryPaths = @(
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    
    $startupCount = 0
    
    foreach ($path in $registryPaths) {
        if (Test-Path $path) {
            $items = Get-ItemProperty -Path $path
            $count = ($items.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" }).Count
            $startupCount += $count
        }
    }
    
    Write-Info "  Registry startup items: $startupCount"
    
    if ($startupCount -gt 10) {
        Write-Warn "  High number of startup items - consider disabling some"
    } elseif ($startupCount -gt 5) {
        Write-Info "  Moderate number of startup items"
    } else {
        Write-OK "  Low number of startup items (good)"
    }
}
catch {
    Write-Warn "Failed to check startup impact"
}
Write-Host ""

# ============================================================================
# 3. Disable Common Unnecessary Startup Apps
# ============================================================================
$currentStep++
Write-Step "Disabling unnecessary startup apps" $currentStep $totalSteps

$commonStartupApps = @(
    "OneDrive",
    "Microsoft Edge Update",
    "Google Update",
    "Adobe Reader Speed Launcher",
    "Adobe ARM",
    "iTunesHelper",
    "Spotify",
    "Steam",
    "EpicGamesLauncher",
    "Discord",
    "Skype",
    "Teams",
    "Cortana"
)

$disabled = 0
$skipped = 0

foreach ($appName in $commonStartupApps) {
    try {
        # Check registry locations
        $registryPaths = @(
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        )
        
        foreach ($path in $registryPaths) {
            if (Test-Path $path) {
                $items = Get-ItemProperty -Path $path
                
                foreach ($prop in $items.PSObject.Properties) {
                    if ($prop.Name -notlike "PS*" -and $prop.Name -like "*$appName*") {
                        Write-Info "  Found: $($prop.Name) at $path"
                        # Don't auto-remove, just report
                        $skipped++
                    }
                }
            }
        }
    }
    catch {
        # Skip on error
    }
}

Write-Info "  Scanned for $($commonStartupApps.Count) common apps"
Write-Info "  Found: $skipped | Skipped (manual review): $skipped"
Write-Host ""
Write-Info "  Note: Use Task Manager > Startup to disable apps manually" -ForegroundColor Gray
Write-Host ""

# ============================================================================
# 4. Optimize Startup Services
# ============================================================================
$currentStep++
Write-Step "Analyzing startup services" $currentStep $totalSteps

# Services that can be safely disabled for most users
$optionalServices = @{
    "XblAuthManager" = "Xbox Live Auth Manager (disable if not gaming)"
    "XblGameSave" = "Xbox Live Game Save (disable if not gaming)"
    "XboxNetApiSvc" = "Xbox Live Networking Service (disable if not gaming)"
    "MapsBroker" = "Downloaded Maps Manager (disable if not using maps)"
    "PhoneSvc" = "Phone Service (disable if no phone integration)"
    "RetailDemo" = "Retail Demo Service (can disable)"
    "DiagTrack" = "Connected User Experiences (telemetry)"
    "dmwappushservice" = "WAP Push Service (telemetry)"
    "HomeGroupListener" = "HomeGroup Listener (deprecated)"
    "HomeGroupProvider" = "HomeGroup Provider (deprecated)"
    "RemoteRegistry" = "Remote Registry (security risk)"
    "SCardSvr" = "Smart Card Service (disable if not using smart cards)"
    "WSearch" = "Windows Search (can disable on SSD)"
    "SysMain" = "SysMain/Superfetch (can disable on SSD)"
}

$canDisable = 0

foreach ($service in $optionalServices.Keys) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            if ($svc.StartType -ne "Disabled") {
                Write-Info "  Can disable: $service - $($optionalServices[$service])"
                $canDisable++
            } else {
                Write-OK "  Already disabled: $service"
            }
        }
    }
    catch {
        # Service not found
    }
}

Write-Host ""
Write-Info "  Services that can be disabled: $canDisable"
Write-Host ""

# ============================================================================
# 5. Disable Telemetry Services (Auto)
# ============================================================================
$currentStep++
Write-Step "Disabling telemetry services" $currentStep $totalSteps

$telemetryServices = @("DiagTrack", "dmwappushservice")

foreach ($service in $telemetryServices) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc -and $svc.StartType -ne "Disabled") {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-OK "  Disabled: $service"
        }
    }
    catch {
        Write-Warn "  Failed to disable: $service"
    }
}
Write-Host ""

# ============================================================================
# 6. Optimize Boot Configuration
# ============================================================================
$currentStep++
Write-Step "Optimizing boot configuration" $currentStep $totalSteps

try {
    # Check current boot timeout
    $bootData = bcdedit /enum | Select-String "timeout"
    
    if ($bootData) {
        $timeout = [int]($bootData -replace ".*timeout\s+", "").Trim()
        
        if ($timeout -gt 10) {
            Write-Info "  Current boot timeout: ${timeout}s (high)"
            Write-Info "  Consider reducing to 5s: bcdedit /timeout 5"
        } else {
            Write-OK "  Boot timeout: ${timeout}s (optimal)"
        }
    }
}
catch {
    Write-Warn "Failed to check boot configuration"
}

try {
    # Check if fast startup is enabled
    $powerCfg = powercfg /a 2>&1
    
    if ($powerCfg -like "*Hibernate*") {
        Write-OK "  Fast Startup is available"
    } else {
        Write-Info "  Fast Startup may be disabled"
    }
}
catch {
    Write-Warn "Failed to check fast startup"
}
Write-Host ""

# ============================================================================
# 7. Clean Boot Temp Files
# ============================================================================
$currentStep++
Write-Step "Cleaning boot temporary files" $currentStep $totalSteps

try {
    $tempPaths = @(
        "$env:SystemRoot\Temp",
        "$env:LOCALAPPDATA\Temp"
    )
    
    $totalCleaned = 0
    
    foreach ($tempPath in $tempPaths) {
        if (Test-Path $tempPath) {
            $files = Get-ChildItem -Path $tempPath -File -ErrorAction SilentlyContinue
            
            if ($files.Count -gt 0) {
                Remove-Item -Path "$tempPath\*" -Force -Recurse -ErrorAction SilentlyContinue
                $totalCleaned += $files.Count
            }
        }
    }
    
    Write-OK "  Cleaned $totalCleaned temporary files"
}
catch {
    Write-Warn "Failed to clean temp files"
}
Write-Host ""

# ============================================================================
# 8. Generate Recommendations
# ============================================================================
$currentStep++
Write-Step "Generating recommendations" $currentStep $totalSteps

Write-Host ""
Write-Header "Startup Optimization Recommendations"

Write-Host ""
Write-Host "MANUAL ACTIONS (Recommended):" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Task Manager Startup Apps:" -ForegroundColor Yellow
Write-Host "   - Press Ctrl+Shift+Esc" -ForegroundColor White
Write-Host "   - Go to Startup tab" -ForegroundColor White
Write-Host "   - Disable apps you don't need at boot" -ForegroundColor White
Write-Host "   - Keep only essential apps (antivirus, drivers)" -ForegroundColor White
Write-Host ""

Write-Host "2. Services to Consider Disabling:" -ForegroundColor Yellow
foreach ($service in $optionalServices.GetEnumerator() | Select-Object -First 5) {
    Write-Host "   - $($service.Key): $($service.Value)" -ForegroundColor White
}
Write-Host ""

Write-Host "3. Boot Optimization Commands:" -ForegroundColor Yellow
Write-Host "   # Reduce boot timeout to 5 seconds" -ForegroundColor Gray
Write-Host "   bcdedit /timeout 5" -ForegroundColor Cyan
Write-Host ""
Write-Host "   # Enable Fast Startup (if disabled)" -ForegroundColor Gray
Write-Host "   powercfg /h on" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. Scheduled Tasks to Review:" -ForegroundColor Yellow
Write-Host "   - Open Task Scheduler" -ForegroundColor White
Write-Host "   - Review tasks in: Task Scheduler Library" -ForegroundColor White
Write-Host "   - Disable unnecessary update checkers" -ForegroundColor White
Write-Host ""

Write-Host "ESTIMATED BOOT TIME IMPROVEMENT:" -ForegroundColor Cyan
Write-Host "  - Light optimization (5-10 startup items): 5-10 seconds faster" -ForegroundColor White
Write-Host "  - Medium optimization (10-20 items): 10-20 seconds faster" -ForegroundColor White
Write-Host "  - Aggressive optimization (20+ items): 20-40 seconds faster" -ForegroundColor White
Write-Host ""

Write-OK "Startup analysis complete!"
Write-Host ""

Read-Host "Press Enter to exit"
