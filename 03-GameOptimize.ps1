# ============================================================================
# Windows 11 Game Performance Optimization Script v4.0.0
# Windows 11 Optimization Suite - Core Game Optimization
# ============================================================================
# Version: 4.0.0 (Merged: 03 + 03b + 03c + 03e)
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Comprehensive game optimization with auto GPU detection
# Features: HAGS, Game Mode, Power Plan, GPU Priority, Network, Memory
# ============================================================================

# Load Logger Module
. .\Logger.ps1

$SCRIPT_VERSION = "4.0.0"
$SCRIPT_NAME = "GameOptimize"

# ============================================================================
# Configuration
# ============================================================================
$CONFIG = @{
    EnableHAGS = $true
    EnableGameMode = $true
    EnableHighPerfPower = $true
    OptimizeGamePriority = $true
    DisableMemoryCompression = $true
    OptimizeNetwork = $true
    ClearStandbyMemory = $true
    DisableVisualEffects = $true
    DisableBackgroundApps = $true
    ShowStatus = $true
    QuickMode = $false  # Set via parameter for quick 30-second optimization
}

# Parse command line arguments
if ($args -contains "-QuickMode" -or $args -contains "-quick" -or $args -contains "-q") {
    $CONFIG.QuickMode = $true
}

# ============================================================================
# System Detection Functions
# ============================================================================

function Get-GPUInfo {
    try {
        $gpu = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -notlike "*Microsoft*" } | Select-Object -First 1
        if ($gpu) {
            $vendor = "Unknown"
            if ($gpu.Name -like "*NVIDIA*") { $vendor = "NVIDIA" }
            elseif ($gpu.Name -like "*AMD*" -or $gpu.Name -like "*Radeon*") { $vendor = "AMD" }
            elseif ($gpu.Name -like "*Intel*") { $vendor = "Intel" }
            
            return @{
                Name = $gpu.Name
                Vendor = $vendor
                VRAM = [Math]::Round($gpu.AdapterRAM / 1GB, 2)
                DriverVersion = $gpu.DriverVersion
            }
        }
    }
    catch { }
    return $null
}

function Get-SystemInfo {
    try {
        $os = Get-WmiObject Win32_OperatingSystem
        $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
        $totalRAM = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeRAM = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
        
        return @{
            CPU = $cpu.Name
            TotalRAM = $totalRAM
            FreeRAM = $freeRAM
            UsedPercent = [Math]::Round((($totalRAM - $freeRAM) / $totalRAM) * 100, 1)
        }
    }
    catch { }
    return $null
}

function Get-HAGSStatus {
    try {
        $path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        $value = (Get-ItemProperty -Path $path -Name "HwSchMode" -ErrorAction SilentlyContinue).HwSchMode
        if ($value -eq 2) { return $true }
        return $false
    }
    catch { return $false }
}

function Get-GameModeStatus {
    try {
        $path = "HKCU:\SOFTWARE\Microsoft\GameBar"
        $value = (Get-ItemProperty -Path $path -Name "AutoGameModeEnabled" -ErrorAction SilentlyContinue).AutoGameModeEnabled
        if ($value -eq 1) { return $true }
        return $false
    }
    catch { return $false }
}

function Get-PowerPlanName {
    try {
        $plan = powercfg -getactivescheme 2>&1
        if ($plan -like "*Ultimate Performance*") { return "Ultimate Performance" }
        elseif ($plan -like "*High Performance*") { return "High Performance" }
        elseif ($plan -like "*Balanced*") { return "Balanced" }
        else { return "Other" }
    }
    catch { return "Unknown" }
}

# ============================================================================
# Optimization Functions
# ============================================================================

function Enable-HAGS {
    Write-Step "Checking Hardware GPU Scheduling (HAGS)" 1 10
    
    if (Get-HAGSStatus) {
        Write-OK "HAGS already enabled"
        return $true
    }
    
    try {
        $path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        New-ItemProperty -Path $path -Name "HwSchMode" -Value 2 -PropertyType DWord -Force | Out-Null
        Write-OK "Hardware GPU Scheduling enabled"
        Write-Info "Requires restart to take effect"
        return $true
    }
    catch {
        Write-Warn "Failed to enable HAGS"
        return $false
    }
}

function Enable-GameMode {
    Write-Step "Checking Windows Game Mode" 2 10
    
    if (Get-GameModeStatus) {
        Write-OK "Game Mode already enabled"
        return $true
    }
    
    try {
        $path = "HKCU:\SOFTWARE\Microsoft\GameBar"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        New-ItemProperty -Path $path -Name "AllowAutoGameMode" -Value 1 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $path -Name "AutoGameModeEnabled" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-OK "Windows Game Mode enabled"
        return $true
    }
    catch {
        Write-Warn "Failed to enable Game Mode"
        return $false
    }
}

function Enable-HighPerfPower {
    Write-Step "Activating High Performance Power Plan" 3 10
    
    try {
        # Try Ultimate Performance first
        $result = powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Ultimate Performance power plan activated"
            
            # Additional processor optimization
            try {
                powercfg -setacvalueindex SCHEME_CURRENT sub_processor 893dee8e-2bef-41e0-89c6-b55d0929964c 100 2>$null | Out-Null
                powercfg -setacvalueindex SCHEME_CURRENT sub_processor bc5038f7-23e0-4960-96da-33abaf5935ec 100 2>$null | Out-Null
                Write-OK "Processor state: 100%"
            }
            catch { }
            
            return $true
        }
        
        # Fall back to High Performance
        $result = powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-OK "High Performance power plan activated"
            return $true
        }
        
        Write-Warn "Failed to activate high performance power plan"
        return $false
    }
    catch {
        Write-Warn "Power plan activation failed"
        return $false
    }
}

function Optimize-GamePriority {
    Write-Step "Optimizing Game Process Priority" 4 10
    
    try {
        $tasksPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks"
        $count = 0
        
        foreach ($task in @("Games", "Games  ")) {
            $taskPath = "$tasksPath\$task"
            if (Test-Path $taskPath) {
                New-ItemProperty -Path $taskPath -Name "GPU Priority" -Value 8 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
                New-ItemProperty -Path $taskPath -Name "Mem Priority" -Value 8 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
                New-ItemProperty -Path $taskPath -Name "IO Priority" -Value 3 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
                New-ItemProperty -Path $taskPath -Name "Scheduling Category" -Value "High" -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
                $count++
            }
        }
        
        if ($count -gt 0) {
            Write-OK "Game priority optimized ($count tasks)"
        } else {
            Write-Info "No game tasks found to optimize"
        }
        return $true
    }
    catch {
        Write-Warn "Priority optimization failed"
        return $false
    }
}

function Disable-MemoryCompression {
    Write-Step "Configuring Memory Compression" 5 10
    
    try {
        $status = (Get-MMAgent).MemoryCompression
        if ($status) {
            Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
            Write-OK "Memory compression disabled (more free RAM)"
        } else {
            Write-OK "Memory compression already disabled"
        }
        return $true
    }
    catch {
        Write-Warn "Memory compression config failed"
        return $false
    }
}

function Optimize-Network {
    Write-Step "Optimizing Network for Gaming" 6 10
    
    $success = 0
    try {
        netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
        $success++
    } catch { }
    
    try {
        netsh int tcp set global rss=enabled 2>$null | Out-Null
        $success++
    } catch { }
    
    if ($success -gt 0) {
        Write-OK "Network optimized for gaming"
    } else {
        Write-Warn "Network optimization failed"
    }
    return ($success -gt 0)
}

function Disable-VisualEffects {
    Write-Step "Disabling Visual Effects" 7 10
    
    try {
        $path = "HKCU:\Control Panel\Desktop"
        if (Test-Path $path) {
            Set-ItemProperty -Path $path -Name "UserPreferencesMask" -Value ([byte[]](144,18,3,128,16,0,0,0)) -Force
            Write-OK "Visual effects optimized for performance"
            return $true
        }
        Write-Info "Desktop path not found"
        return $false
    }
    catch {
        Write-Warn "Visual effects optimization failed"
        return $false
    }
}

function Clear-StandbyMemory {
    Write-Step "Clearing Standby Memory" 8 10
    
    try {
        $emptyStandbyPath = "$env:SystemRoot\System32\EmptyStandbyList.exe"
        if (Test-Path $emptyStandbyPath) {
            Start-Process -FilePath $emptyStandbyPath -ArgumentList "standbyonly" -Wait -NoNewWindow -ErrorAction SilentlyContinue
            Write-OK "Standby memory cleared"
            return $true
        } else {
            Write-Info "EmptyStandbyList not available (optional Windows SDK tool)"
            return $false
        }
    }
    catch {
        Write-Warn "Memory clear failed"
        return $false
    }
}

function Disable-BackgroundApps {
    Write-Step "Disabling Background Apps" 9 10
    
    try {
        $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        New-ItemProperty -Path $path -Name "GlobalUserDisabled" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-OK "Background apps disabled"
        return $true
    }
    catch {
        Write-Warn "Background apps disable failed"
        return $false
    }
}

function Show-Status {
    Write-Step "System Status" 10 10
    
    $sys = Get-SystemInfo
    $gpu = Get-GPUInfo
    $hags = Get-HAGSStatus
    $gameMode = Get-GameModeStatus
    $powerPlan = Get-PowerPlanName
    
    Write-Host ""
    Write-Host "+-----------------------------------------+" -ForegroundColor Cyan
    Write-Host "|           SYSTEM STATUS                 |" -ForegroundColor Cyan
    Write-Host "+-----------------------------------------+" -ForegroundColor Cyan
    
    if ($sys) {
        $cpuDisplay = $sys.CPU.Substring(0, [Math]::Min(35, $sys.CPU.Length))
        Write-Host "| CPU:  $cpuDisplay".PadRight(42) + "|" -ForegroundColor Gray
        $ramColor = if ($sys.UsedPercent -lt 70) { "Green" } else { "Yellow" }
        Write-Host "| RAM:  $($sys.FreeRAM) / $($sys.TotalRAM) GB free ($($sys.UsedPercent)% used)".PadRight(42) + "|" -ForegroundColor $ramColor
    }
    
    if ($gpu) {
        $gpuDisplay = $gpu.Name.Substring(0, [Math]::Min(35, $gpu.Name.Length))
        Write-Host "| GPU:  $gpuDisplay".PadRight(42) + "|" -ForegroundColor Gray
        Write-Host "| VRAM: $($gpu.VRAM) GB".PadRight(42) + "|" -ForegroundColor Gray
    }
    
    Write-Host "+-----------------------------------------+" -ForegroundColor Cyan
    $hagsStatus = if ($hags) { "ENABLED" } else { "DISABLED" }
    $hagsColor = if ($hags) { "Green" } else { "Yellow" }
    Write-Host "| HAGS:       $hagsStatus".PadRight(42) + "|" -ForegroundColor $hagsColor
    
    $gameModeStatus = if ($gameMode) { "ENABLED" } else { "DISABLED" }
    $gameModeColor = if ($gameMode) { "Green" } else { "Yellow" }
    Write-Host "| Game Mode:  $gameModeStatus".PadRight(42) + "|" -ForegroundColor $gameModeColor
    
    $powerPlanStatus = $powerPlan
    $powerPlanColor = if ($powerPlan -like "*Performance*") { "Green" } else { "Yellow" }
    Write-Host "| Power Plan: $powerPlanStatus".PadRight(42) + "|" -ForegroundColor $powerPlanColor
    
    Write-Host "+-----------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# Main Execution
# ============================================================================

# Clear screen
Clear-Host

# Header
Write-Header "Game Optimization v$SCRIPT_VERSION"
Write-Host "  Intelligent Game Optimization System" -ForegroundColor Cyan
if ($CONFIG.QuickMode) {
    Write-Host "  [QUICK MODE] Fast optimization (30 seconds)" -ForegroundColor Yellow
}
Write-Host ""

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Administrator privileges required!"
    Write-Info "Right-click this script and select 'Run as administrator'"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-OK "Administrator privileges confirmed"
Write-Host ""

# Create restore point (skip in Quick Mode)
if (-not $CONFIG.QuickMode) {
    Write-Step "Creating system restore point" 0 10
    try {
        Checkpoint-Computer -Description "Before Game Optimization v$SCRIPT_VERSION" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-OK "Restore point created"
    }
    catch {
        Write-Warn "Restore point creation failed (manual creation recommended)"
    }
    Write-Host ""
}

# Detect hardware
Write-Header "Hardware Detection"

$gpu = Get-GPUInfo
$sys = Get-SystemInfo

if ($gpu) {
    Write-OK "GPU: $($gpu.Name)"
    Write-Info "  Vendor: $($gpu.Vendor)"
    Write-Info "  VRAM: $($gpu.VRAM) GB"
    Write-Info "  Driver: $($gpu.DriverVersion)"
} else {
    Write-Warn "No dedicated GPU detected"
}

if ($sys) {
    Write-OK "System: $($sys.CPU)"
    Write-Info "  RAM: $($sys.FreeRAM) / $($sys.TotalRAM) GB free"
}

Write-Host ""

# Run optimizations
Write-Header "Running Optimizations"

$results = @{
    HAGS = if ($CONFIG.EnableHAGS) { Enable-HAGS } else { $true }
    GameMode = if ($CONFIG.EnableGameMode) { Enable-GameMode } else { $true }
    PowerPlan = if ($CONFIG.EnableHighPerfPower) { Enable-HighPerfPower } else { $true }
    Priority = if ($CONFIG.OptimizeGamePriority) { Optimize-GamePriority } else { $true }
    Memory = if ($CONFIG.DisableMemoryCompression) { Disable-MemoryCompression } else { $true }
    Network = if ($CONFIG.OptimizeNetwork) { Optimize-Network } else { $true }
    Visual = if ($CONFIG.DisableVisualEffects -and -not $CONFIG.QuickMode) { Disable-VisualEffects } else { $true }
    Standby = if ($CONFIG.ClearStandbyMemory) { Clear-StandbyMemory } else { $true }
    Background = if ($CONFIG.DisableBackgroundApps -and -not $CONFIG.QuickMode) { Disable-BackgroundApps } else { $true }
}

# Summary
Write-Host ""
Write-Header "Optimization Summary"

$successCount = ($results.Values | Where-Object { $_ -eq $true }).Count
$totalCount = $results.Count

Write-Host ""
Write-Host "  Total Optimizations: $totalCount" -ForegroundColor Cyan
Write-Host "  Successful: $successCount" -ForegroundColor Green
Write-Host "  Skipped/Failed: $($totalCount - $successCount)" -ForegroundColor $(if ($totalCount -eq $successCount) { "Green" } else { "Yellow" })
Write-Host ""

if ($successCount -eq $totalCount) {
    Write-Host "  ALL OPTIMIZATIONS COMPLETED SUCCESSFULLY" -ForegroundColor Green
} else {
    Write-Host "  Some optimizations were skipped or failed" -ForegroundColor Yellow
    Write-Info "  This is normal for already optimized settings"
}

Write-Host ""

# Final status
if ($CONFIG.ShowStatus) {
    Show-Status
}

# Footer
Write-Host "========================================" -ForegroundColor Green
Write-Host "  GAME MODE ACTIVATED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Recommendations:" -ForegroundColor Cyan
if (-not $CONFIG.QuickMode) {
    Write-Host "  - Restart for full effect (recommended)" -ForegroundColor Gray
}
Write-Host "  - Run this script before each gaming session" -ForegroundColor Gray
Write-Host "  - Keep GPU drivers updated" -ForegroundColor Gray
Write-Host "  - Close unnecessary background apps" -ForegroundColor Gray
Write-Host ""

if (-not (Get-HAGSStatus)) {
    Write-Host "WARNING: HAGS requires restart to activate!" -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "Press Enter to exit"
