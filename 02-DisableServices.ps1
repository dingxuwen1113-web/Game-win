# ============================================================================
# Windows 11 Service Optimization Script v2.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 2.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# ============================================================================

$SCRIPT_VERSION = "2.0.0"
$SCRIPT_NAME = "DisableServices"

# Header
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 11 Service Optimization v$SCRIPT_VERSION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] Administrator privileges required!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[OK] Administrator privileges confirmed" -ForegroundColor Green
Write-Host ""

# Step 1: Create restore point
Write-Host "[1/5] Creating system restore point..." -ForegroundColor Yellow
try {
    Checkpoint-Computer -Description "Before Service Optimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  [OK] Restore point created" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Restore point creation failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Define services to optimize
Write-Host "[2/5] Loading service configuration..." -ForegroundColor Yellow
$services = @(
    @{Name="DiagTrack"; DisplayName="Connected User Experiences and Telemetry"; Status="Disabled"; Risk="Low"},
    @{Name="dmwappushservice"; DisplayName="WAP Push Message Routing Service"; Status="Disabled"; Risk="Low"},
    @{Name="RemoteRegistry"; DisplayName="Remote Registry"; Status="Disabled"; Risk="Low"},
    @{Name="RetailDemo"; DisplayName="Retail Demo Service"; Status="Disabled"; Risk="Low"},
    @{Name="SCardSvr"; DisplayName="Smart Card"; Status="Disabled"; Risk="Medium"},
    @{Name="XblAuthManager"; DisplayName="Xbox Live Auth Manager"; Status="Manual"; Risk="Low"},
    @{Name="XblGameSave"; DisplayName="Xbox Live Game Save"; Status="Manual"; Risk="Low"},
    @{Name="XboxNetApiSvc"; DisplayName="Xbox Live Networking Service"; Status="Manual"; Risk="Low"},
    @{Name="MapsBroker"; DisplayName="Downloaded Maps Manager"; Status="Disabled"; Risk="Low"},
    @{Name="PhoneSvc"; DisplayName="Phone Service"; Status="Disabled"; Risk="Low"},
    @{Name="Fax"; DisplayName="Fax"; Status="Disabled"; Risk="Low"},
    @{Name="InsiderSvc"; DisplayName="Windows Insider Service"; Status="Disabled"; Risk="Low"},
    @{Name="lfsvc"; DisplayName="Geolocation Service"; Status="Manual"; Risk="Medium"},
    @{Name="HomeGroupListener"; DisplayName="HomeGroup Listener"; Status="Disabled"; Risk="Low"},
    @{Name="HomeGroupProvider"; DisplayName="HomeGroup Provider"; Status="Disabled"; Risk="Low"},
    @{Name="WSearch"; DisplayName="Windows Search"; Status="Manual"; Risk="Medium"},
    @{Name="SysMain"; DisplayName="SysMain"; Status="Manual"; Risk="Medium"}
)
Write-Host "  [OK] Loaded $($services.Count) services" -ForegroundColor Green
Write-Host ""

# Step 3: Apply service configurations
Write-Host "[3/5] Optimizing services..." -ForegroundColor Yellow
Write-Host ""

$modified = 0
$failed = 0
$skipped = 0

foreach ($svc in $services) {
    try {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        
        if ($null -eq $service) {
            Write-Host "  [SKIP] $($svc.DisplayName) - Not found" -ForegroundColor Gray
            $skipped++
            continue
        }
        
        $currentStatus = $service.Status
        $currentStartup = $service.StartType
        
        if ($svc.Status -eq "Disabled") {
            if ($service.Status -eq "Running") {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
            }
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
        }
        elseif ($svc.Status -eq "Manual") {
            Set-Service -Name $svc.Name -StartupType Manual -ErrorAction Stop
        }
        
        Write-Host "  [OK] $($svc.DisplayName) -> $($svc.Status)" -ForegroundColor Green
        $modified++
    }
    catch {
        Write-Host "  [FAIL] $($svc.DisplayName) - $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""

# Step 4: Disable telemetry
Write-Host "[4/5] Disabling telemetry..." -ForegroundColor Yellow

$telemetryKeys = @(
    @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name="AllowTelemetry"; Value=0},
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="AllowTelemetry"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="ContentDeliveryAllowed"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="OemPreInstalledAppsEnabled"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="PreInstalledAppsEnabled"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="SilentInstalledAppsEnabled"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="SubscribedContent-338387Enabled"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="SubscribedContent-353694Enabled"; Value=0},
    @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name="SubscribedContent-353696Enabled"; Value=0}
)

$telModified = 0
$telFailed = 0

foreach ($item in $telemetryKeys) {
    try {
        if (-not (Test-Path $item.Path)) {
            New-Item -Path $item.Path -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -Type DWord -Force -ErrorAction Stop
        $telModified++
    }
    catch {
        $telFailed++
    }
}

Write-Host "  [OK] Telemetry keys modified: $telModified" -ForegroundColor Green
if ($telFailed -gt 0) {
    Write-Host "  [WARN] Telemetry keys skipped: $telFailed (protected by Windows)" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Summary
Write-Host "[5/5] Optimization complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Services modified: $modified" -ForegroundColor Green
Write-Host "  Services failed:   $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "  Services skipped:  $skipped" -ForegroundColor Gray
Write-Host "  Telemetry keys:    $telModified modified, $telFailed skipped" -ForegroundColor Cyan
Write-Host ""

if ($modified -gt 0) {
    Write-Host "[WARNING] Restart required for changes to take full effect!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[INFO] Some services may affect related features:" -ForegroundColor Cyan
    Write-Host "  - Xbox services: Xbox gaming features" -ForegroundColor Gray
    Write-Host "  - Search service: File search functionality" -ForegroundColor Gray
    Write-Host "  - SysMain: SSD optimization (Safe to disable on SSD)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
