# ============================================================================
# Windows 11 Optimization Suite - Interactive Menu v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Interactive menu system for all optimization scripts
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "SystemMenu"

# ============================================================================
# Helper Functions
# ============================================================================
function Write-Header { 
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Menu {
    param([string[]]$Options)
    $i = 1
    foreach ($option in $Options) {
        Write-Host "  [$i] $option" -ForegroundColor White
        $i++
    }
    Write-Host "  [0] Exit" -ForegroundColor Yellow
    Write-Host ""
}

function Run-Script {
    param([string]$ScriptPath, [string]$Description)
    
    Clear-Host
    Write-Header "Running: $Description"
    
    if (Test-Path $ScriptPath) {
        & $ScriptPath
        Write-Host ""
        Write-Host "Script completed. Press Enter to continue..." -ForegroundColor Green
        Read-Host
    } else {
        Write-Host "Script not found: $ScriptPath" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

# ============================================================================
# Main Menu
# ============================================================================
function Show-MainMenu {
    Clear-Host
    Write-Header "Windows 11 Optimization Suite v5.0.0"
    Write-Host "  Interactive Menu System" -ForegroundColor Cyan
    Write-Host ""
    
    $options = @(
        "Core Optimizations",
        "Extended Optimizations",
        "System Tools",
        "Gaming Tools",
        "Documentation",
        "System Information"
    )
    
    Write-Menu $options
    
    $choice = Read-Host "Select option (0-6)"
    
    switch ($choice) {
        "1" { Show-CoreMenu }
        "2" { Show-ExtendedMenu }
        "3" { Show-ToolsMenu }
        "4" { Show-GamingMenu }
        "5" { Show-DocsMenu }
        "6" { Show-SystemInfo }
        "0" { exit 0 }
        default { Show-MainMenu }
    }
}

# ============================================================================
# Core Optimizations Menu
# ============================================================================
function Show-CoreMenu {
    Clear-Host
    Write-Header "Core Optimizations"
    Write-Host "  Essential system optimizations" -ForegroundColor Cyan
    Write-Host ""
    
    $options = @(
        "Clean Bloatware (01-CleanApps)",
        "Disable Services (02-DisableServices)",
        "Game Optimization (03-GameOptimize)",
        "Network Optimization (04-NetworkOptimize)",
        "Network Security (05-NetworkSecurity)",
        "System Health Check (06-SystemHealth)",
        "< Back"
    )
    
    Write-Menu $options
    
    $choice = Read-Host "Select option (0-8)"
    
    switch ($choice) {
        "1" { Run-Script ".\01-CleanApps.ps1" "Clean Bloatware" }
        "2" { Run-Script ".\02-DisableServices.ps1" "Disable Services" }
        "3" { Run-Script ".\03-GameOptimize.ps1" "Game Optimization" }
        "4" { Run-Script ".\04-NetworkOptimize.ps1" "Network Optimization" }
        "5" { Run-Script ".\05-NetworkSecurity.ps1" "Network Security" }
        "6" { Run-Script ".\06-SystemHealth.ps1" "System Health Check" }
        "7" { Show-MainMenu }
        "0" { exit 0 }
        default { Show-CoreMenu }
    }
}

# ============================================================================
# Extended Optimizations Menu
# ============================================================================
function Show-ExtendedMenu {
    Clear-Host
    Write-Header "Extended Optimizations"
    Write-Host "  Advanced system enhancements" -ForegroundColor Cyan
    Write-Host ""
    
    $options = @(
        "Storage Optimization (13-StorageOptimize) [NEW]",
        "Privacy Optimization (14-PrivacyOptimize) [NEW]",
        "Startup Optimization (15-StartupOptimize) [NEW]",
        "Update Management (16-UpdateOptimize) [NEW]",
        "Fix Animation (12-FixAnimationAuto)",
        "Set Wallpaper (11-SetWallpaper)",
        "Microsoft Account Privilege (07-MicrosoftAccount)",
        "< Back"
    )
    
    Write-Menu $options
    
    $choice = Read-Host "Select option (0-9)"
    
    switch ($choice) {
        "1" { Run-Script ".\13-StorageOptimize.ps1" "Storage Optimization" }
        "2" { Run-Script ".\14-PrivacyOptimize.ps1" "Privacy Optimization" }
        "3" { Run-Script ".\15-StartupOptimize.ps1" "Startup Optimization" }
        "4" { Run-Script ".\16-UpdateOptimize.ps1" "Update Management" }
        "5" { Run-Script ".\12-FixAnimationAuto.ps1" "Fix Animation" }
        "6" { Run-Script ".\11-SetWallpaper.ps1" "Set Wallpaper" }
        "7" { Run-Script ".\07-MicrosoftAccount.ps1" "Microsoft Account Privilege" }
        "8" { Show-MainMenu }
        "0" { exit 0 }
        default { Show-ExtendedMenu }
    }
}

# ============================================================================
# System Tools Menu
# ============================================================================
function Show-ToolsMenu {
    Clear-Host
    Write-Header "System Tools"
    Write-Host "  Utilities and diagnostics" -ForegroundColor Cyan
    Write-Host ""
    
    $options = @(
        "System Benchmark (NEW)",
        "System Restore (09-Restore)",
        "Fix Registry Permissions (10-FixRegistryPermissions)",
        "Validate Scripts",
        "View Logs",
        "< Back"
    )
    
    Write-Menu $options
    
    $choice = Read-Host "Select option (0-6)"
    
    switch ($choice) {
        "1" { Run-Script ".\utils\SystemBenchmark.ps1" "System Benchmark" }
        "2" { Run-Script ".\09-Restore.ps1" "System Restore" }
        "3" { Run-Script ".\10-FixRegistryPermissions.ps1" "Fix Registry Permissions" }
        "4" { 
            if (Test-Path ".\utils\ValidateScripts.ps1") {
                Run-Script ".\utils\ValidateScripts.ps1" "Validate Scripts"
            } else {
                Write-Host "Validation script not found" -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
        "5" { 
            $logDir = "$PSScriptRoot\logs"
            if (Test-Path $logDir) {
                Get-ChildItem $logDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | Format-Table Name, Length, LastWriteTime
                Write-Host "Press Enter to continue..."
                Read-Host
            } else {
                Write-Host "No logs directory found" -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
        "6" { Show-MainMenu }
        "0" { exit 0 }
        default { Show-ToolsMenu }
    }
}

# ============================================================================
# Gaming Tools Menu
# ============================================================================
function Show-GamingMenu {
    Clear-Host
    Write-Header "Gaming Tools"
    Write-Host "  Game performance utilities" -ForegroundColor Cyan
    Write-Host ""
    
    $options = @(
        "Quick Game Mode (30 seconds)",
        "Full Game Optimization",
        "Gaming Tools Menu",
        "Game Memory Optimization",
        "< Back"
    )
    
    Write-Menu $options
    
    $choice = Read-Host "Select option (0-5)"
    
    switch ($choice) {
        "1" { 
            Write-Host "Running Quick Game Mode..." -ForegroundColor Green
            & ".\03-GameOptimize.ps1" -QuickMode
            Write-Host "Press Enter to continue..."
            Read-Host
        }
        "2" { Run-Script ".\03-GameOptimize.ps1" "Full Game Optimization" }
        "3" { Run-Script ".\utils\GamingTools.ps1" "Gaming Tools Menu" }
        "4" { Run-Script ".\utils\GameMemoryOptimize.ps1" "Game Memory Optimization" }
        "5" { Show-MainMenu }
        "0" { exit 0 }
        default { Show-GamingMenu }
    }
}

# ============================================================================
# Documentation Menu
# ============================================================================
function Show-DocsMenu {
    Clear-Host
    Write-Header "Documentation"
    Write-Host "  Guides and references" -ForegroundColor Cyan
    Write-Host ""
    
    $docs = @(
        "README.md",
        "NEW_FEATURES_v5.md",
        "OPTIMIZATION_STRATEGIES.md",
        "QUICK_START.md",
        "TROUBLESHOOTING.md",
        "VERSION.md",
        "< Back"
    )
    
    Write-Menu $docs
    
    $choice = Read-Host "Select option (0-7)"
    
    switch ($choice) {
        "1" { if (Test-Path ".\README.md") { notepad ".\README.md" } }
        "2" { if (Test-Path ".\NEW_FEATURES_v5.md") { notepad ".\NEW_FEATURES_v5.md" } }
        "3" { if (Test-Path ".\OPTIMIZATION_STRATEGIES.md") { notepad ".\OPTIMIZATION_STRATEGIES.md" } }
        "4" { if (Test-Path ".\QUICK_START.md") { notepad ".\QUICK_START.md" } }
        "5" { if (Test-Path ".\TROUBLESHOOTING.md") { notepad ".\TROUBLESHOOTING.md" } }
        "6" { if (Test-Path ".\VERSION.md") { notepad ".\VERSION.md" } }
        "7" { Show-MainMenu }
        "0" { exit 0 }
        default { Show-DocsMenu }
    }
}

# ============================================================================
# System Information
# ============================================================================
function Show-SystemInfo {
    Clear-Host
    Write-Header "System Information"
    
    try {
        $os = Get-WmiObject Win32_OperatingSystem
        $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
        $gpu = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -notlike "*Microsoft*" } | Select-Object -First 1
        $totalRAM = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        
        Write-Host ""
        Write-Host "  Operating System:" -ForegroundColor Cyan
        Write-Host "    $($os.Caption) $($os.OSArchitecture)" -ForegroundColor White
        Write-Host ""
        
        Write-Host "  CPU:" -ForegroundColor Cyan
        Write-Host "    $($cpu.Name)" -ForegroundColor White
        Write-Host "    Cores: $($cpu.NumberOfCores) | Threads: $($cpu.NumberOfLogicalProcessors)" -ForegroundColor White
        Write-Host ""
        
        Write-Host "  Memory:" -ForegroundColor Cyan
        Write-Host "    $totalRAM GB" -ForegroundColor White
        Write-Host ""
        
        if ($gpu) {
            Write-Host "  GPU:" -ForegroundColor Cyan
            Write-Host "    $($gpu.Name)" -ForegroundColor White
            $vram = [Math]::Round($gpu.AdapterRAM / 1GB, 2)
            Write-Host "    VRAM: $vram GB" -ForegroundColor White
            Write-Host ""
        }
        
        Write-Host "  Storage:" -ForegroundColor Cyan
        $disks = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size
        foreach ($disk in $disks) {
            $sizeGB = [Math]::Round($disk.Size / 1GB, 2)
            $type = if ($disk.MediaType) { $disk.MediaType } else { "Unknown" }
            Write-Host "    $($disk.FriendlyName): $sizeGB GB ($type)" -ForegroundColor White
        }
        Write-Host ""
        
        Write-Host "  Network:" -ForegroundColor Cyan
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            Write-Host "    $($adapter.Name): $($adapter.LinkSpeed / 1Mbps) Mbps" -ForegroundColor White
        }
    }
    catch {
        Write-Host "  Failed to retrieve system information" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "  Press Enter to continue..." -ForegroundColor Gray
    Read-Host
    
    Show-MainMenu
}

# ============================================================================
# Entry Point
# ============================================================================
Clear-Host

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Some features may not work without administrator privileges." -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 0
    }
}

Show-MainMenu
