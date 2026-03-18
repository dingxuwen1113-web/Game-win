# ============================================================================
# Windows 11 Game Memory Optimization Script v2.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 2.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# ============================================================================

$SCRIPT_VERSION = "2.0.0"
$SCRIPT_NAME = "GameMemoryOptimize"

# Header
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Game Memory Optimization v$SCRIPT_VERSION" -ForegroundColor Cyan
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
Write-Host "[1/8] Creating system restore point..." -ForegroundColor Yellow
try {
    Checkpoint-Computer -Description "Before Game Memory Optimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  [OK] Restore point created" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Restore point creation failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Enable Hardware GPU Scheduling
Write-Host "[2/8] Configuring GPU scheduling..." -ForegroundColor Yellow
try {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    New-ItemProperty -Path $path -Name "HwSchMode" -Value 2 -PropertyType DWord -Force | Out-Null
    Write-Host "  [OK] Hardware GPU scheduling enabled" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] GPU scheduling config failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Game Priority Configuration
Write-Host "[3/8] Configuring game priorities..." -ForegroundColor Yellow
$priorityModified = 0

try {
    $tasksPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks"
    $gameTasks = @("Games", "Games  ")
    
    foreach ($task in $gameTasks) {
        $taskPath = "$tasksPath\$task"
        if (Test-Path $taskPath) {
            New-ItemProperty -Path $taskPath -Name "GPU Priority" -Value 8 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $taskPath -Name "Mem Priority" -Value 8 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $taskPath -Name "IO Priority" -Value 3 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $taskPath -Name "Scheduling Category" -Value "High" -PropertyType String -Force | Out-Null
            Write-Host "  [OK] Game task '$task' prioritized" -ForegroundColor Green
            $priorityModified++
        }
    }
}
catch {
    Write-Host "  [WARN] Priority config failed" -ForegroundColor Yellow
}

Write-Host "  Tasks configured: $priorityModified" -ForegroundColor Cyan
Write-Host ""

# Step 4: Memory Compression
Write-Host "[4/8] Configuring memory compression..." -ForegroundColor Yellow
try {
    $compressionStatus = (Get-MMAgent).MemoryCompression
    if ($compressionStatus) {
        Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
        Write-Host "  [OK] Memory compression disabled (more free RAM)" -ForegroundColor Green
    }
    else {
        Write-Host "  [INFO] Memory compression already disabled" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  [WARN] Memory compression config failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Pagefile Optimization
Write-Host "[5/8] Optimizing pagefile..." -ForegroundColor Yellow
try {
    $computer = Get-WmiObject Win32_ComputerSystem
    $totalRAM = [Math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
    
    # Set system managed pagefile
    $pagefiles = Get-WmiObject Win32_PageFileSetting
    if ($pagefiles) {
        $pagefile = $pagefiles | Select-Object -First 1
        if ($pagefile) {
            $pagefile.InitialSize = [Math]::Max(4096, [Math]::Round($computer.TotalPhysicalMemory / 1MB * 0.5))
            $pagefile.MaximumSize = [Math]::Max(8192, [Math]::Round($computer.TotalPhysicalMemory / 1MB * 1.5))
            $pagefile.Put() | Out-Null
            Write-Host "  [OK] Pagefile optimized for $totalRAM GB RAM" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "  [WARN] Pagefile optimization failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Clear Standby Memory
Write-Host "[6/8] Clearing standby memory..." -ForegroundColor Yellow
try {
    $emptyStandbyPath = "$env:SystemRoot\System32\EmptyStandbyList.exe"
    if (Test-Path $emptyStandbyPath) {
        Start-Process -FilePath $emptyStandbyPath -ArgumentList "standbyonly" -Wait -NoNewWindow -ErrorAction SilentlyContinue
        Write-Host "  [OK] Standby memory cleared" -ForegroundColor Green
    }
    else {
        Write-Host "  [INFO] EmptyStandbyList not available (optional tool)" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  [WARN] Standby memory clear failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 7: Power Settings
Write-Host "[7/8] Optimizing power settings..." -ForegroundColor Yellow
try {
    powercfg -setacvalueindex SCHEME_CURRENT sub_pciexpress 501a4d26-f22e-4da2-afa2-3f8f02ca799d 0
    powercfg -setactive SCHEME_CURRENT
    Write-Host "  [OK] PCI Express power saving disabled" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Power settings optimization failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 8: Display Memory Status
Write-Host "[8/8] Memory Status" -ForegroundColor Yellow
Write-Host ""

try {
    $os = Get-WmiObject Win32_OperatingSystem
    $totalRAM = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [Math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 2)
    $usedPercent = [Math]::Round(($usedRAM / $totalRAM) * 100, 1)
    
    Write-Host "Memory Information:" -ForegroundColor Cyan
    Write-Host "  Total RAM:  $totalRAM GB" -ForegroundColor Gray
    Write-Host "  Used RAM:   $usedRAM GB ($usedPercent%)" -ForegroundColor Gray
    Write-Host "  Free RAM:   $freeRAM GB" -ForegroundColor $(if ($freeRAM -gt 2) { "Green" } else { "Yellow" })
    Write-Host ""
}
catch {
    Write-Host "  [WARN] Unable to display memory status" -ForegroundColor Gray
}

try {
    $gpu = Get-WmiObject Win32_VideoController | Select-Object -First 1
    if ($gpu) {
        Write-Host "Graphics Information:" -ForegroundColor Cyan
        Write-Host "  GPU:  $($gpu.Name)" -ForegroundColor Gray
        Write-Host "  VRAM: $([Math]::Round($gpu.AdapterRAM / 1GB, 2)) GB" -ForegroundColor Gray
        Write-Host ""
    }
}
catch {
    Write-Host "  [WARN] Unable to display GPU information" -ForegroundColor Gray
}

# Summary
Write-Host "========================================" -ForegroundColor Green
Write-Host "Game Memory Optimization Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "[INFO] Restart recommended for full effect" -ForegroundColor Cyan
Write-Host ""

Write-Host "Gaming Tips:" -ForegroundColor Cyan
Write-Host "  - Close background apps before gaming" -ForegroundColor Gray
Write-Host "  - Use Game Mode for automatic optimization" -ForegroundColor Gray
Write-Host "  - Keep GPU drivers updated" -ForegroundColor Gray
Write-Host "  - Monitor temps during gaming" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
