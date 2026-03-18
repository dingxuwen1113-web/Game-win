# ============================================================================
# Windows 11 System Health Check Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Comprehensive system health monitoring and diagnostics
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "SystemHealth"

# Helper Functions
function Write-Header { 
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
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

Clear-Host

# Header
Write-Header "System Health Check v$SCRIPT_VERSION"
Write-Host "  Comprehensive System Diagnostics" -ForegroundColor Cyan
Write-Host ""

# Check admin (optional - some checks don't need admin)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warn "Running without administrator privileges (some checks limited)"
    Write-Host ""
}

$healthScore = 100
$issues = @()

# ============================================================================
# 1. CPU Health
# ============================================================================
Write-Header "CPU Status"

try {
    $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
    Write-OK "CPU: $($cpu.Name)"
    Write-Info "  Cores: $($cpu.NumberOfCores)"
    Write-Info "  Logical Processors: $($cpu.NumberOfLogicalProcessors)"
    Write-Info "  Max Clock Speed: $($cpu.MaxClockSpeed) MHz"
}
catch {
    Write-Error "Failed to read CPU information"
    $healthScore -= 5
    $issues += "CPU info unavailable"
}
Write-Host ""

# ============================================================================
# 2. Memory Health
# ============================================================================
Write-Header "Memory Status"

try {
    $os = Get-WmiObject Win32_OperatingSystem
    $totalRAM = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedPercent = [Math]::Round((($totalRAM - $freeRAM) / $totalRAM) * 100, 1)
    
    Write-OK "Total RAM: $totalRAM GB"
    Write-OK "Free RAM: $freeRAM GB"
    
    if ($usedPercent -lt 50) {
        Write-OK "Memory Usage: $usedPercent% (Excellent)"
    } elseif ($usedPercent -lt 70) {
        Write-Info "Memory Usage: $usedPercent% (Normal)"
    } elseif ($usedPercent -lt 85) {
        Write-Warn "Memory Usage: $usedPercent% (High)"
        $healthScore -= 10
        $issues += "High memory usage"
    } else {
        Write-Error "Memory Usage: $usedPercent% (Critical)"
        $healthScore -= 20
        $issues += "Critical memory usage"
    }
}
catch {
    Write-Error "Failed to read memory information"
    $healthScore -= 5
    $issues += "Memory info unavailable"
}
Write-Host ""

# ============================================================================
# 3. Storage Health
# ============================================================================
Write-Header "Storage Status"

try {
    $disks = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    foreach ($disk in $disks) {
        $size = [Math]::Round($disk.Size / 1GB, 2)
        $free = [Math]::Round($disk.FreeSpace / 1GB, 2)
        $usedPercent = [Math]::Round((($size - $free) / $size) * 100, 1)
        
        Write-OK "Drive $($disk.DeviceID): $free / $size GB free ($usedPercent% used)"
        
        if ($usedPercent -gt 90) {
            Write-Error "  Critical: Less than 10% free space!"
            $healthScore -= 15
            $issues += "Low disk space on $($disk.DeviceID)"
        } elseif ($usedPercent -gt 80) {
            Write-Warn "  Warning: Less than 20% free space"
            $healthScore -= 5
        }
    }
}
catch {
    Write-Error "Failed to read storage information"
    $healthScore -= 5
    $issues += "Storage info unavailable"
}
Write-Host ""

# ============================================================================
# 4. GPU Status
# ============================================================================
Write-Header "Graphics Status"

try {
    $gpus = Get-WmiObject Win32_VideoController
    foreach ($gpu in $gpus) {
        if ($gpu.Name -notlike "*Microsoft*") {
            Write-OK "GPU: $($gpu.Name)"
            Write-Info "  VRAM: $([Math]::Round($gpu.AdapterRAM / 1GB, 2)) GB"
            Write-Info "  Driver: $($gpu.DriverVersion)"
        }
    }
}
catch {
    Write-Error "Failed to read GPU information"
    $healthScore -= 5
    $issues += "GPU info unavailable"
}
Write-Host ""

# ============================================================================
# 5. Windows Update Status
# ============================================================================
Write-Header "Windows Update Status"

try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult = $updateSearcher.Search("IsInstalled=0")
    
    if ($searchResult.Updates.Count -eq 0) {
        Write-OK "No pending updates"
    } else {
        Write-Warn "$($searchResult.Updates.Count) updates pending"
        foreach ($update in $searchResult.Updates | Select-Object -First 5) {
            Write-Info "  - $($update.Title)"
        }
        if ($searchResult.Updates.Count -gt 5) {
            Write-Info "  ... and $($searchResult.Updates.Count - 5) more"
        }
        $healthScore -= 5
        $issues += "Pending Windows updates"
    }
}
catch {
    Write-Warn "Unable to check Windows Update status"
}
Write-Host ""

# ============================================================================
# 6. Running Processes
# ============================================================================
Write-Header "Process Status"

try {
    $processCount = (Get-Process).Count
    Write-OK "Running Processes: $processCount"
    
    if ($processCount -gt 200) {
        Write-Warn "High number of running processes"
        $healthScore -= 5
        $issues += "Too many running processes"
    }
    
    # Get top 5 memory consumers
    Write-Host ""
    Write-Info "Top 5 Memory Consumers:"
    Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 | ForEach-Object {
        $mem = [Math]::Round($_.WorkingSet64 / 1MB, 2)
        Write-Info "  $($_.Name): $mem MB"
    }
}
catch {
    Write-Error "Failed to read process information"
    $healthScore -= 5
    $issues += "Process info unavailable"
}
Write-Host ""

# ============================================================================
# 7. Network Status
# ============================================================================
Write-Header "Network Status"

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    Write-OK "Active Network Adapters: $($adapters.Count)"
    
    foreach ($adapter in $adapters) {
        Write-Info "  - $($adapter.Name): $($adapter.LinkSpeed)"
    }
}
catch {
    Write-Warn "Unable to check network status"
}

# Ping test
try {
    $ping = New-Object System.Net.NetworkInformation.Ping
    $reply = $ping.Send("8.8.8.8", 1000)
    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        Write-OK "Internet Connection: OK ($($reply.RoundtripTime) ms)"
    } else {
        Write-Error "Internet Connection: Failed"
        $healthScore -= 15
        $issues += "No internet connection"
    }
}
catch {
    Write-Error "Network test failed"
    $healthScore -= 10
    $issues += "Network test failed"
}
Write-Host ""

# ============================================================================
# 8. System Temperature (if available)
# ============================================================================
Write-Header "Temperature Status"

try {
    $temps = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -ErrorAction SilentlyContinue
    if ($temps) {
        foreach ($temp in $temps) {
            $celsius = [Math]::Round(($temp.CurrentTemperature - 2732) / 10, 1)
            if ($celsius -lt 60) {
                Write-OK "Temperature: $celsius C (Normal)"
            } elseif ($celsius -lt 80) {
                Write-Info "Temperature: $celsius C (Warm)"
            } else {
                Write-Warn "Temperature: $celsius C (Hot!)"
                $healthScore -= 10
                $issues += "High system temperature"
            }
        }
    } else {
        Write-Info "Temperature sensors not available"
    }
}
catch {
    Write-Info "Temperature monitoring not available on this system"
}
Write-Host ""

# ============================================================================
# 9. Battery Status (if laptop)
# ============================================================================
Write-Header "Power Status"

try {
    $battery = Get-WmiObject Win32_Battery | Select-Object -First 1
    if ($battery) {
        Write-OK "Battery Detected"
        Write-Info "  Charge: $($battery.EstimatedChargeRemaining)%"
        Write-Info "  Status: $($battery.BatteryStatus)"
    } else {
        Write-Info "Desktop system (no battery)"
    }
}
catch {
    Write-Info "Battery status unavailable"
}
Write-Host ""

# ============================================================================
# 10. Optimization Status
# ============================================================================
Write-Header "Optimization Status"

# Check HAGS
try {
    $hags = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -ErrorAction SilentlyContinue).HwSchMode
    if ($hags -eq 2) {
        Write-OK "Hardware GPU Scheduling: Enabled"
    } else {
        Write-Warn "Hardware GPU Scheduling: Disabled"
    }
}
catch { Write-Info "HAGS status unavailable" }

# Check Game Mode
try {
    $gameMode = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AutoGameModeEnabled" -ErrorAction SilentlyContinue).AutoGameModeEnabled
    if ($gameMode -eq 1) {
        Write-OK "Windows Game Mode: Enabled"
    } else {
        Write-Warn "Windows Game Mode: Disabled"
    }
}
catch { Write-Info "Game Mode status unavailable" }

# Check Power Plan
try {
    $powerPlan = powercfg -getactivescheme 2>&1
    if ($powerPlan -like "*Ultimate Performance*" -or $powerPlan -like "*High Performance*") {
        Write-OK "Power Plan: High Performance"
    } else {
        Write-Warn "Power Plan: Balanced/Power Saver"
    }
}
catch { Write-Info "Power plan status unavailable" }

Write-Host ""

# ============================================================================
# Final Summary
# ============================================================================
Write-Header "Health Summary"

Write-Host ""
Write-Host "+-----------------------------------------+" -ForegroundColor Cyan
Write-Host "|           SYSTEM HEALTH SCORE           |" -ForegroundColor Cyan
Write-Host "+-----------------------------------------+" -ForegroundColor Cyan

$stars = ""
if ($healthScore -ge 90) { $stars = "*****" }
elseif ($healthScore -ge 75) { $stars = "**** " }
elseif ($healthScore -ge 60) { $stars = "***  " }
elseif ($healthScore -ge 40) { $stars = "**   " }
else { $stars = "*    " }

if ($healthScore -ge 90) {
    Write-Host "|  Score: $healthScore / 100  $stars          |" -ForegroundColor Green
} elseif ($healthScore -ge 75) {
    Write-Host "|  Score: $healthScore / 100  $stars          |" -ForegroundColor Cyan
} elseif ($healthScore -ge 60) {
    Write-Host "|  Score: $healthScore / 100  $stars          |" -ForegroundColor Yellow
} elseif ($healthScore -ge 40) {
    Write-Host "|  Score: $healthScore / 100  $stars          |" -ForegroundColor Magenta
} else {
    Write-Host "|  Score: $healthScore / 100  $stars          |" -ForegroundColor Red
}

Write-Host "+-----------------------------------------+" -ForegroundColor Cyan
Write-Host ""

if ($issues.Count -gt 0) {
    Write-Host "Issues Found:" -ForegroundColor Yellow
    foreach ($issue in $issues) {
        Write-Host "  - $issue" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "Recommendations:" -ForegroundColor Cyan
if ($healthScore -lt 90) {
    Write-Host "  - Run .\00-RunAll.bat for full optimization" -ForegroundColor Gray
}
Write-Host "  - Run .\03c-GameMode.ps1 before gaming" -ForegroundColor Gray
Write-Host "  - Keep system and drivers updated" -ForegroundColor Gray
Write-Host "  - Monitor temperatures during heavy use" -ForegroundColor Gray
Write-Host ""

if ($healthScore -ge 75) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  System Health: GOOD" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  System Health: NEEDS ATTENTION" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
}
Write-Host ""

Read-Host "Press Enter to exit"
