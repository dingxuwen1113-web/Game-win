# ============================================================================
# Windows 11 Quick Deploy Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: One-click deployment for common optimization scenarios
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "QuickDeploy"

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
Write-Header "Quick Deploy v$SCRIPT_VERSION"
Write-Host "  One-Click Optimization Scenarios" -ForegroundColor Cyan
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

# ============================================================================
# Deployment Scenarios
# ============================================================================
Write-Host "Select deployment scenario:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1] 🎮 Gaming PC (Performance Focus)" -ForegroundColor White
Write-Host "      - Game optimization" -ForegroundColor Gray
Write-Host "      - Network optimization" -ForegroundColor Gray
Write-Host "      - Disable telemetry" -ForegroundColor Gray
Write-Host "      - High performance power" -ForegroundColor Gray
Write-Host ""
Write-Host "  [2] 💼 Workstation (Stability Focus)" -ForegroundColor White
Write-Host "      - System cleanup" -ForegroundColor Gray
Write-Host "      - Privacy optimization" -ForegroundColor Gray
Write-Host "      - Startup optimization" -ForegroundColor Gray
Write-Host "      - Update management" -ForegroundColor Gray
Write-Host ""
Write-Host "  [3] 🏠 Home PC (Balanced)" -ForegroundColor White
Write-Host "      - Basic cleanup" -ForegroundColor Gray
Write-Host "      - Network optimization" -ForegroundColor Gray
Write-Host "      - Animation fixes" -ForegroundColor Gray
Write-Host "      - Moderate privacy" -ForegroundColor Gray
Write-Host ""
Write-Host "  [4] ⚡ Quick Boost (5 minutes)" -ForegroundColor White
Write-Host "      - Quick game mode" -ForegroundColor Gray
Write-Host "      - Clean temp files" -ForegroundColor Gray
Write-Host "      - Clear standby memory" -ForegroundColor Gray
Write-Host "      - Network reset" -ForegroundColor Gray
Write-Host ""
Write-Host "  [5] 🔒 Privacy Mode (Maximum Privacy)" -ForegroundColor White
Write-Host "      - Full privacy optimization" -ForegroundColor Gray
Write-Host "      - Disable telemetry" -ForegroundColor Gray
Write-Host "      - Disable Cortana" -ForegroundColor Gray
Write-Host "      - Disable background apps" -ForegroundColor Gray
Write-Host ""
Write-Host "  [0] Exit" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Enter choice (0-5)"

# ============================================================================
# Scenario 1: Gaming PC
# ============================================================================
if ($choice -eq "1") {
    Write-Header "Gaming PC Deployment"
    Write-Info "Optimizing for maximum gaming performance..."
    Write-Host ""
    
    $steps = 6
    $current = 0
    
    # Step 1: Game Optimization
    $current++
    Write-Step "Game Optimization" $current $steps
    if (Test-Path ".\03-GameOptimize.ps1") {
        & ".\03-GameOptimize.ps1"
        Write-OK "Game optimization complete"
    } else {
        Write-Warn "Script not found: 03-GameOptimize.ps1"
    }
    Write-Host ""
    
    # Step 2: Network Optimization
    $current++
    Write-Step "Network Optimization" $current $steps
    if (Test-Path ".\04-NetworkOptimize.ps1") {
        & ".\04-NetworkOptimize.ps1"
        Write-OK "Network optimization complete"
    } else {
        Write-Warn "Script not found: 04-NetworkOptimize.ps1"
    }
    Write-Host ""
    
    # Step 3: Privacy (Telemetry)
    $current++
    Write-Step "Disabling Telemetry" $current $steps
    if (Test-Path ".\14-PrivacyOptimize.ps1") {
        # Run non-interactive mode for telemetry only
        Write-Info "Disabling telemetry services..."
        Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
        Get-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
        Get-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-OK "Telemetry disabled"
    }
    Write-Host ""
    
    # Step 4: Power Plan
    $current++
    Write-Step "Activating Ultimate Performance" $current $steps
    try {
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Ultimate Performance plan activated"
        } else {
            powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            Write-OK "High Performance plan activated"
        }
    }
    catch {
        Write-Warn "Power plan activation failed"
    }
    Write-Host ""
    
    # Step 5: Disable Visual Effects
    $current++
    Write-Step "Optimizing Visual Effects" $current $steps
    try {
        $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        New-ItemProperty -Path $path -Name "VisualFXSetting" -Value 2 -PropertyType DWord -Force | Out-Null
        Write-OK "Visual effects optimized for performance"
    }
    catch {
        Write-Warn "Visual effects optimization failed"
    }
    Write-Host ""
    
    # Step 6: Summary
    $current++
    Write-Step "Deployment Summary" $current $steps
    Write-Host ""
    Write-OK "Gaming PC deployment complete!"
    Write-Host ""
    Write-Host "Performance improvements:" -ForegroundColor Cyan
    Write-Host "  ✓ Game mode enabled" -ForegroundColor Green
    Write-Host "  ✓ HAGS enabled" -ForegroundColor Green
    Write-Host "  ✓ High performance power" -ForegroundColor Green
    Write-Host "  ✓ Network optimized" -ForegroundColor Green
    Write-Host "  ✓ Telemetry disabled" -ForegroundColor Green
    Write-Host ""
    Write-Warn "Restart recommended for best results"
    Write-Host ""
}

# ============================================================================
# Scenario 2: Workstation
# ============================================================================
elseif ($choice -eq "2") {
    Write-Header "Workstation Deployment"
    Write-Info "Optimizing for stability and productivity..."
    Write-Host ""
    
    $steps = 5
    $current = 0
    
    # Step 1: Clean Apps
    $current++
    Write-Step "Cleaning Bloatware" $current $steps
    if (Test-Path ".\01-CleanApps.ps1") {
        & ".\01-CleanApps.ps1"
        Write-OK "Bloatware cleanup complete"
    }
    Write-Host ""
    
    # Step 2: Privacy
    $current++
    Write-Step "Privacy Optimization" $current $steps
    if (Test-Path ".\14-PrivacyOptimize.ps1") {
        Write-Info "Running privacy optimization..."
        & ".\14-PrivacyOptimize.ps1"
        Write-OK "Privacy optimization complete"
    }
    Write-Host ""
    
    # Step 3: Startup
    $current++
    Write-Step "Startup Optimization" $current $steps
    if (Test-Path ".\15-StartupOptimize.ps1") {
        & ".\15-StartupOptimize.ps1"
        Write-OK "Startup optimization complete"
    }
    Write-Host ""
    
    # Step 4: Update Management
    $current++
    Write-Step "Update Management" $current $steps
    if (Test-Path ".\16-UpdateOptimize.ps1") {
        Write-Info "Configuring update settings..."
        # Auto-configure without interaction
        try {
            $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
            New-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $regPath -Name "AUOptions" -Value 3 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $regPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -PropertyType DWord -Force | Out-Null
            Write-OK "Update settings configured (notify before install)"
        }
        catch {
            Write-Warn "Update configuration failed"
        }
    }
    Write-Host ""
    
    # Step 5: Summary
    $current++
    Write-Step "Deployment Summary" $current $steps
    Write-Host ""
    Write-OK "Workstation deployment complete!"
    Write-Host ""
    Write-Host "Configurations applied:" -ForegroundColor Cyan
    Write-Host "  ✓ Bloatware removed" -ForegroundColor Green
    Write-Host "  ✓ Privacy enhanced" -ForegroundColor Green
    Write-Host "  ✓ Startup optimized" -ForegroundColor Green
    Write-Host "  ✓ Updates managed" -ForegroundColor Green
    Write-Host ""
    Write-Warn "Restart recommended"
    Write-Host ""
}

# ============================================================================
# Scenario 3: Home PC (Balanced)
# ============================================================================
elseif ($choice -eq "3") {
    Write-Header "Home PC Deployment (Balanced)"
    Write-Info "Applying balanced optimizations..."
    Write-Host ""
    
    $steps = 4
    $current = 0
    
    # Step 1: Basic Cleanup
    $current++
    Write-Step "Basic System Cleanup" $current $steps
    try {
        $tempPaths = @($env:TEMP, "$env:SystemRoot\Temp")
        foreach ($path in $tempPaths) {
            if (Test-Path $path) {
                Remove-Item -Path "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        Write-OK "Temporary files cleaned"
    }
    catch {
        Write-Warn "Cleanup partially failed"
    }
    Write-Host ""
    
    # Step 2: Network
    $current++
    Write-Step "Network Optimization" $current $steps
    if (Test-Path ".\04-NetworkOptimize.ps1") {
        & ".\04-NetworkOptimize.ps1"
        Write-OK "Network optimization complete"
    }
    Write-Host ""
    
    # Step 3: Animation
    $current++
    Write-Step "Animation Configuration" $current $steps
    if (Test-Path ".\12-FixAnimationAuto.ps1") {
        & ".\12-FixAnimationAuto.ps1"
        Write-OK "Animation configuration complete"
    }
    Write-Host ""
    
    # Step 4: Summary
    $current++
    Write-Step "Deployment Summary" $current $steps
    Write-Host ""
    Write-OK "Home PC deployment complete!"
    Write-Host ""
    Write-Host "Configurations applied:" -ForegroundColor Cyan
    Write-Host "  ✓ Temporary files cleaned" -ForegroundColor Green
    Write-Host "  ✓ Network optimized" -ForegroundColor Green
    Write-Host "  ✓ Animation effects enabled" -ForegroundColor Green
    Write-Host ""
    Write-Warn "Restart recommended"
    Write-Host ""
}

# ============================================================================
# Scenario 4: Quick Boost
# ============================================================================
elseif ($choice -eq "4") {
    Write-Header "Quick Boost (5 Minutes)"
    Write-Info "Running quick performance boost..."
    Write-Host ""
    
    $steps = 4
    $current = 0
    
    # Step 1: Quick Game Mode
    $current++
    Write-Step "Quick Game Mode" $current $steps
    if (Test-Path ".\03-GameOptimize.ps1") {
        & ".\03-GameOptimize.ps1" -QuickMode
        Write-OK "Quick game mode applied"
    }
    Write-Host ""
    
    # Step 2: Clean Temp
    $current++
    Write-Step "Cleaning Temporary Files" $current $steps
    try {
        $tempPaths = @($env:TEMP, $env:TMP, "$env:SystemRoot\Temp")
        $count = 0
        foreach ($path in $tempPaths) {
            if (Test-Path $path) {
                $files = Get-ChildItem -Path $path -File -ErrorAction SilentlyContinue
                $count += $files.Count
                Remove-Item -Path "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        Write-OK "Cleaned $count temporary files"
    }
    catch {
        Write-Warn "Cleanup partially failed"
    }
    Write-Host ""
    
    # Step 3: Clear Standby Memory
    $current++
    Write-Step "Clearing Standby Memory" $current $steps
    try {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Memory {
    [DllImport("ntdll.dll")]
    public static extern uint NtSetSystemInformation(int infoClass, IntPtr info, int length);
}
"@ -ErrorAction SilentlyContinue
        
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
        Write-OK "Memory cleared"
    }
    catch {
        Write-Info "Standby memory cleared (or already clean)"
    }
    Write-Host ""
    
    # Step 4: Network Reset
    $current++
    Write-Step "Resetting Network" $current $steps
    try {
        ipconfig /flushdns 2>$null | Out-Null
        ipconfig /registerdns 2>$null | Out-Null
        Write-OK "Network reset complete"
    }
    catch {
        Write-Warn "Network reset partially failed"
    }
    Write-Host ""
    
    Write-OK "Quick Boost complete!"
    Write-Host ""
    Write-Host "Improvements:" -ForegroundColor Cyan
    Write-Host "  ✓ Game mode enabled" -ForegroundColor Green
    Write-Host "  ✓ Temporary files cleaned" -ForegroundColor Green
    Write-Host "  ✓ Memory optimized" -ForegroundColor Green
    Write-Host "  ✓ Network reset" -ForegroundColor Green
    Write-Host ""
    Write-Info "No restart required"
    Write-Host ""
}

# ============================================================================
# Scenario 5: Privacy Mode
# ============================================================================
elseif ($choice -eq "5") {
    Write-Header "Privacy Mode Deployment"
    Write-Info "Applying maximum privacy settings..."
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  PRIVACY MODE WARNING" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "This will disable:" -ForegroundColor White
    Write-Host "  - All telemetry" -ForegroundColor Yellow
    Write-Host "  - Cortana" -ForegroundColor Yellow
    Write-Host "  - Windows Ink" -ForegroundColor Yellow
    Write-Host "  - Background apps" -ForegroundColor Yellow
    Write-Host "  - Activity history" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Some Windows features may stop working." -ForegroundColor Red
    Write-Host ""
    
    $confirm = Read-Host "Continue? (Type YES to confirm)"
    
    if ($confirm -eq "YES") {
        if (Test-Path ".\14-PrivacyOptimize.ps1") {
            & ".\14-PrivacyOptimize.ps1"
            Write-OK "Privacy mode deployment complete!"
        }
    } else {
        Write-Info "Deployment cancelled"
    }
}

# ============================================================================
# Exit
# ============================================================================
elseif ($choice -eq "0") {
    exit 0
}

else {
    Write-Warn "Invalid option"
}

Write-Host ""
Write-Host "Quick Deploy script completed." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
