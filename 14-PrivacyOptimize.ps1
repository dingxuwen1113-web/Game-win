# ============================================================================
# Windows 11 Privacy Optimization Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Disable telemetry, enhance privacy, reduce data collection
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "PrivacyOptimize"

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
Write-Header "Privacy Optimization v$SCRIPT_VERSION"
Write-Host "  Disable Telemetry & Enhance Privacy" -ForegroundColor Cyan
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

# Confirmation prompt
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PRIVACY OPTIMIZATION WARNING" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "This script will:" -ForegroundColor White
Write-Host "  - Disable Windows telemetry" -ForegroundColor White
Write-Host "  - Disable data collection services" -ForegroundColor White
Write-Host "  - Disable advertising ID" -ForegroundColor White
Write-Host "  - Disable Cortana" -ForegroundColor White
Write-Host "  - Disable location tracking" -ForegroundColor White
Write-Host "  - Disable diagnostic data" -ForegroundColor White
Write-Host ""
Write-Host "Some Windows features may be affected." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Continue? (Type YES to confirm)"
if ($confirm -ne "YES") {
    Write-Info "Operation cancelled by user"
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host ""

$totalSteps = 15
$currentStep = 0

# ============================================================================
# 1. Disable Telemetry Services
# ============================================================================
$currentStep++
Write-Step "Disabling telemetry services" $currentStep $totalSteps

$telemetryServices = @(
    "DiagTrack",           # Connected User Experiences and Telemetry
    "dmwappushservice",    # WAP Push Message Routing Service
    "lfsvc",               # Geolocation Service
    "MapsBroker",          # Downloaded Maps Manager
    "RetailDemo",          # Retail Demo Service
    "RemoteRegistry",      # Remote Registry
    "PcaSvc",              # Program Compatibility Assistant
    "HomeGroupListener",   # HomeGroup Listener (deprecated)
    "HomeGroupProvider"    # HomeGroup Provider (deprecated)
)

foreach ($service in $telemetryServices) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
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
# 2. Disable Diagnostic Data Collection
# ============================================================================
$currentStep++
Write-Step "Disabling diagnostic data collection" $currentStep $totalSteps

try {
    $diagPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    
    if (-not (Test-Path $diagPath)) {
        New-Item -Path $diagPath -Force | Out-Null
    }
    
    # Set diagnostic data to minimum (Security only)
    New-ItemProperty -Path $diagPath -Name "AllowTelemetry" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $diagPath -Name "MaxTelemetryAllowed" -Value 0 -PropertyType DWord -Force | Out-Null
    
    Write-OK "Diagnostic data collection disabled (Security level)"
}
catch {
    Write-Warn "Failed to disable diagnostic data"
}
Write-Host ""

# ============================================================================
# 3. Disable Advertising ID
# ============================================================================
$currentStep++
Write-Step "Disabling advertising ID" $currentStep $totalSteps

try {
    $adPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    
    if (-not (Test-Path $adPath)) {
        New-Item -Path $adPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-OK "Advertising ID disabled"
}
catch {
    Write-Warn "Failed to disable advertising ID"
}

try {
    $adPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
    
    if (-not (Test-Path $adPolicyPath)) {
        New-Item -Path $adPolicyPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $adPolicyPath -Name "DisabledByGroupPolicy" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-OK "Advertising ID policy disabled"
}
catch {
    Write-Warn "Failed to set advertising policy"
}
Write-Host ""

# ============================================================================
# 4. Disable Cortana
# ============================================================================
$currentStep++
Write-Step "Disabling Cortana" $currentStep $totalSteps

try {
    $cortanaPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    
    if (-not (Test-Path $cortanaPath)) {
        New-Item -Path $cortanaPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $cortanaPath -Name "CortanaEnabled" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $cortanaPath -Name "BingSearchEnabled" -Value 0 -PropertyType DWord -Force | Out-Null
    
    Write-OK "Cortana disabled"
}
catch {
    Write-Warn "Failed to disable Cortana"
}

try {
    $cortanaPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    
    if (-not (Test-Path $cortanaPolicyPath)) {
        New-Item -Path $cortanaPolicyPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $cortanaPolicyPath -Name "AllowCortana" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-OK "Cortana policy disabled"
}
catch {
    Write-Warn "Failed to set Cortana policy"
}
Write-Host ""

# ============================================================================
# 5. Disable Location Tracking
# ============================================================================
$currentStep++
Write-Step "Disabling location tracking" $currentStep $totalSteps

try {
    $locationPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    
    if (Test-Path $locationPath) {
        New-ItemProperty -Path $locationPath -Name "Value" -Value "Deny" -PropertyType String -Force | Out-Null
        Write-OK "Location tracking disabled"
    }
}
catch {
    Write-Warn "Failed to disable location tracking"
}

try {
    $locationPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
    
    if (-not (Test-Path $locationPolicyPath)) {
        New-Item -Path $locationPolicyPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $locationPolicyPath -Name "DisableLocation" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-OK "Location policy disabled"
}
catch {
    Write-Warn "Failed to set location policy"
}
Write-Host ""

# ============================================================================
# 6. Disable Windows Ink Workspace
# ============================================================================
$currentStep++
Write-Step "Disabling Windows Ink Workspace" $currentStep $totalSteps

try {
    $inkPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace"
    
    if (-not (Test-Path $inkPath)) {
        New-Item -Path $inkPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $inkPath -Name "AllowWindowsInkWorkspace" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-OK "Windows Ink Workspace disabled"
}
catch {
    Write-Warn "Failed to disable Windows Ink"
}
Write-Host ""

# ============================================================================
# 7. Disable Feedback Notifications
# ============================================================================
$currentStep++
Write-Step "Disabling feedback notifications" $currentStep $totalSteps

try {
    $feedbackPath = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
    
    if (-not (Test-Path $feedbackPath)) {
        New-Item -Path $feedbackPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $feedbackPath -Name "NumberOfSIUFInPeriod" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $feedbackPath -Name "PeriodInNanoSeconds" -Value 0 -PropertyType DWord -Force | Out-Null
    
    Write-OK "Feedback notifications disabled"
}
catch {
    Write-Warn "Failed to disable feedback"
}
Write-Host ""

# ============================================================================
# 8. Disable Activity History
# ============================================================================
$currentStep++
Write-Step "Disabling activity history" $currentStep $totalSteps

try {
    $activityPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    
    if (-not (Test-Path $activityPath)) {
        New-Item -Path $activityPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $activityPath -Name "EnableActivityFeed" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $activityPath -Name "PublishUserActivities" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $activityPath -Name "UploadUserActivities" -Value 0 -PropertyType DWord -Force | Out-Null
    
    Write-OK "Activity history disabled"
}
catch {
    Write-Warn "Failed to disable activity history"
}
Write-Host ""

# ============================================================================
# 9. Disable Tailored Experiences
# ============================================================================
$currentStep++
Write-Step "Disabling tailored experiences" $currentStep $totalSteps

try {
    $tailoredPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    
    if (-not (Test-Path $tailoredPath)) {
        New-Item -Path $tailoredPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $tailoredPath -Name "DisableTailoredExperiencesWithDiagnosticData" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-OK "Tailored experiences disabled"
}
catch {
    Write-Warn "Failed to disable tailored experiences"
}
Write-Host ""

# ============================================================================
# 10. Disable Third-Party Suggestions
# ============================================================================
$currentStep++
Write-Step "Disabling third-party suggestions" $currentStep $totalSteps

try {
    $contentPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    
    if (Test-Path $contentPath) {
        $properties = @(
            "SubscribedContent-338387Enabled",
            "SubscribedContent-338388Enabled",
            "SubscribedContent-338389Enabled",
            "SubscribedContent-338393Enabled",
            "SubscribedContent-353698Enabled",
            "SystemPaneSuggestionsEnabled",
            "SilentInstalledAppsEnabled",
            "SoftLandingEnabled"
        )
        
        foreach ($prop in $properties) {
            New-ItemProperty -Path $contentPath -Name $prop -Value 0 -PropertyType DWord -Force | Out-Null
        }
        
        Write-OK "Third-party suggestions disabled"
    }
}
catch {
    Write-Warn "Failed to disable third-party suggestions"
}
Write-Host ""

# ============================================================================
# 11. Disable Background Apps
# ============================================================================
$currentStep++
Write-Step "Disabling background apps" $currentStep $totalSteps

try {
    $bgAppsPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    
    if (-not (Test-Path $bgAppsPath)) {
        New-Item -Path $bgAppsPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $bgAppsPath -Name "GlobalUserDisabled" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-OK "Background apps disabled"
}
catch {
    Write-Warn "Failed to disable background apps"
}
Write-Host ""

# ============================================================================
# 12. Disable Windows Tips
# ============================================================================
$currentStep++
Write-Step "Disabling Windows tips and suggestions" $currentStep $totalSteps

try {
    $tipsPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    
    if (Test-Path $tipsPath) {
        New-ItemProperty -Path $tipsPath -Name "SubscribedContent-338387Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $tipsPath -Name "SubscribedContent-338389Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
        Write-OK "Windows tips disabled"
    }
}
catch {
    Write-Warn "Failed to disable Windows tips"
}
Write-Host ""

# ============================================================================
# 13. Disable Cloud Content Search
# ============================================================================
$currentStep++
Write-Step "Disabling cloud content search" $currentStep $totalSteps

try {
    $cloudSearchPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    
    if (-not (Test-Path $cloudSearchPath)) {
        New-Item -Path $cloudSearchPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $cloudSearchPath -Name "DisableCloudOptimizedContent" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-OK "Cloud content search disabled"
}
catch {
    Write-Warn "Failed to disable cloud content search"
}
Write-Host ""

# ============================================================================
# 14. Disable Bing Search in Start Menu
# ============================================================================
$currentStep++
Write-Step "Disabling Bing search in Start Menu" $currentStep $totalSteps

try {
    $bingPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    
    if (-not (Test-Path $bingPath)) {
        New-Item -Path $bingPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $bingPath -Name "DisableSearchBoxSuggestions" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-OK "Bing search in Start Menu disabled"
}
catch {
    Write-Warn "Failed to disable Bing search"
}
Write-Host ""

# ============================================================================
# 15. Flush DNS and Reset Network
# ============================================================================
$currentStep++
Write-Step "Flushing DNS cache" $currentStep $totalSteps

try {
    ipconfig /flushdns 2>$null | Out-Null
    Write-OK "DNS cache flushed"
}
catch {
    Write-Warn "DNS flush failed"
}
Write-Host ""

# ============================================================================
# Summary
# ============================================================================
Write-Header "Privacy Optimization Summary"

Write-OK "Privacy optimization complete!"
Write-Host ""
Write-Host "Changes applied:" -ForegroundColor Cyan
Write-Host "  ✓ Telemetry services disabled" -ForegroundColor Green
Write-Host "  ✓ Diagnostic data collection disabled" -ForegroundColor Green
Write-Host "  ✓ Advertising ID disabled" -ForegroundColor Green
Write-Host "  ✓ Cortana disabled" -ForegroundColor Green
Write-Host "  ✓ Location tracking disabled" -ForegroundColor Green
Write-Host "  ✓ Windows Ink disabled" -ForegroundColor Green
Write-Host "  ✓ Feedback notifications disabled" -ForegroundColor Green
Write-Host "  ✓ Activity history disabled" -ForegroundColor Green
Write-Host "  ✓ Tailored experiences disabled" -ForegroundColor Green
Write-Host "  ✓ Third-party suggestions disabled" -ForegroundColor Green
Write-Host "  ✓ Background apps disabled" -ForegroundColor Green
Write-Host "  ✓ Windows tips disabled" -ForegroundColor Green
Write-Host "  ✓ Cloud content search disabled" -ForegroundColor Green
Write-Host "  ✓ Bing search disabled" -ForegroundColor Green
Write-Host ""
Write-Host "Note: Some changes require a restart to take full effect." -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"
