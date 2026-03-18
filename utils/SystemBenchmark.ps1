# ============================================================================
# Windows 11 System Benchmark Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: System performance benchmark and scoring
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "SystemBenchmark"

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

function Write-Score {
    param([int]$Score, [string]$Label)
    $color = if ($Score -ge 80) { "Green" } elseif ($Score -ge 60) { "Yellow" } else { "Red" }
    Write-Host "  $Score / 100" -NoNewline -ForegroundColor $color
    Write-Host " - $Label"
}

# ============================================================================
# Main Script
# ============================================================================
Clear-Host
Write-Header "System Benchmark v$SCRIPT_VERSION"
Write-Host "  Performance Testing & Scoring" -ForegroundColor Cyan
Write-Host ""

$totalTests = 8
$currentTest = 0
$scores = @{}

# ============================================================================
# 1. CPU Benchmark
# ============================================================================
$currentTest++
Write-Step "CPU Performance Test" $currentTest $totalTests

try {
    $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
    $cores = $cpu.NumberOfCores
    $logical = $cpu.NumberOfLogicalProcessors
    $baseSpeed = $cpu.CurrentClockSpeed
    $maxSpeed = $cpu.MaxClockSpeed
    
    Write-Info "  Model: $($cpu.Name)"
    Write-Info "  Cores: $cores | Threads: $logical"
    Write-Info "  Current Speed: $baseSpeed MHz"
    Write-Info "  Max Speed: $maxSpeed MHz"
    
    # Simple scoring based on specs
    $cpuScore = [Math]::Min(100, [Math]::Round(($cores * 10) + ($logical * 5) + ($baseSpeed / 100)))
    Write-Score $cpuScore "CPU Score"
    $scores["CPU"] = $cpuScore
}
catch {
    Write-Warn "CPU test failed"
    $scores["CPU"] = 0
}
Write-Host ""

# ============================================================================
# 2. Memory Benchmark
# ============================================================================
$currentTest++
Write-Step "Memory Performance Test" $currentTest $totalTests

try {
    $os = Get-WmiObject Win32_OperatingSystem
    $totalRAM = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedPercent = [Math]::Round((($totalRAM - $freeRAM) / $totalRAM) * 100, 1)
    
    Write-Info "  Total RAM: $totalRAM GB"
    Write-Info "  Free RAM: $freeRAM GB"
    Write-Info "  Usage: $usedPercent%"
    
    # Memory speed test (simple copy test)
    $testSize = 100MB
    $testData = New-Object byte[] $testSize
    $random = New-Object Random
    $random.NextBytes($testData)
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $testCopy = $testData.Clone()
    $stopwatch.Stop()
    
    $memorySpeed = [Math]::Round($testSize / $stopwatch.Elapsed.TotalSeconds / 1MB, 2)
    Write-Info "  Memory Copy Speed: $memorySpeed MB/s"
    
    # Scoring
    $ramScore = [Math]::Min(100, [Math]::Round(($totalRAM * 5) + (100 - $usedPercent) * 0.5))
    Write-Score $ramScore "Memory Score"
    $scores["Memory"] = $ramScore
}
catch {
    Write-Warn "Memory test failed"
    $scores["Memory"] = 0
}
Write-Host ""

# ============================================================================
# 3. Disk Benchmark
# ============================================================================
$currentTest++
Write-Step "Disk Performance Test" $currentTest $totalTests

try {
    $disk = Get-PhysicalDisk | Select-Object -First 1
    $sizeGB = [Math]::Round($disk.Size / 1GB, 2)
    $mediaType = if ($disk.MediaType) { $disk.MediaType } else { "Unknown" }
    
    Write-Info "  Model: $($disk.FriendlyName)"
    Write-Info "  Type: $mediaType"
    Write-Info "  Size: $sizeGB GB"
    
    # Simple disk write test
    $testFile = "$env:TEMP\benchmark_test.dat"
    $testSize = 50MB
    $testData = New-Object byte[] $testSize
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    [System.IO.File]::WriteAllBytes($testFile, $testData)
    $stopwatch.Stop()
    
    $writeSpeed = [Math]::Round($testSize / $stopwatch.Elapsed.TotalSeconds / 1MB, 2)
    Write-Info "  Write Speed: $writeSpeed MB/s"
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $null = [System.IO.File]::ReadAllBytes($testFile)
    $stopwatch.Stop()
    
    $readSpeed = [Math]::Round($testSize / $stopwatch.Elapsed.TotalSeconds / 1MB, 2)
    Write-Info "  Read Speed: $readSpeed MB/s"
    
    Remove-Item $testFile -Force -ErrorAction SilentlyContinue
    
    # Scoring
    $diskScore = [Math]::Min(100, [Math]::Round(($writeSpeed + $readSpeed) / 10))
    if ($mediaType -eq "SSD") { $diskScore = [Math]::Min(100, $diskScore + 20) }
    Write-Score $diskScore "Disk Score ($mediaType)"
    $scores["Disk"] = $diskScore
}
catch {
    Write-Warn "Disk test failed"
    $scores["Disk"] = 0
}
Write-Host ""

# ============================================================================
# 4. Graphics Benchmark
# ============================================================================
$currentTest++
Write-Step "Graphics Performance Test" $currentTest $totalTests

try {
    $gpu = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -notlike "*Microsoft*" } | Select-Object -First 1
    
    if ($gpu) {
        $vram = [Math]::Round($gpu.AdapterRAM / 1GB, 2)
        Write-Info "  GPU: $($gpu.Name)"
        Write-Info "  VRAM: $vram GB"
        Write-Info "  Driver: $($gpu.DriverVersion)"
        
        # Simple graphics score
        $gpuScore = [Math]::Min(100, [Math]::Round(($vram * 15) + 30))
        Write-Score $gpuScore "Graphics Score"
        $scores["Graphics"] = $gpuScore
    } else {
        Write-Info "  No dedicated GPU detected"
        $scores["Graphics"] = 50
    }
}
catch {
    Write-Warn "Graphics test failed"
    $scores["Graphics"] = 0
}
Write-Host ""

# ============================================================================
# 5. Boot Time Analysis
# ============================================================================
$currentTest++
Write-Step "Boot Time Analysis" $currentTest $totalTests

try {
    $bootTime = Get-WinEvent -FilterHashtable @{LogName='System';Id=6005} -MaxEvents 5 | 
        Select-Object TimeCreated | 
        Sort-Object TimeCreated
    
    if ($bootTime.Count -gt 0) {
        Write-Info "  Last 5 boot times:"
        foreach ($boot in $bootTime) {
            Write-Info "    $($boot.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss'))"
        }
        
        # Estimate boot score based on system responsiveness
        $bootScore = 75  # Default
        Write-Score $bootScore "Boot Score (estimated)"
        $scores["Boot"] = $bootScore
    }
}
catch {
    Write-Warn "Boot time analysis failed"
    $scores["Boot"] = 0
}
Write-Host ""

# ============================================================================
# 6. Network Speed Test
# ============================================================================
$currentTest++
Write-Step "Network Performance Test" $currentTest $totalTests

try {
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    
    if ($adapter) {
        Write-Info "  Adapter: $($adapter.Name)"
        Write-Info "  Link Speed: $($adapter.LinkSpeed / 1Mbps) Mbps"
        
        $networkScore = [Math]::Min(100, [Math]::Round($adapter.LinkSpeed / 100Mbps * 50))
        Write-Score $networkScore "Network Score"
        $scores["Network"] = $networkScore
    }
}
catch {
    Write-Warn "Network test failed"
    $scores["Network"] = 0
}
Write-Host ""

# ============================================================================
# 7. System Responsiveness
# ============================================================================
$currentTest++
Write-Step "System Responsiveness Test" $currentTest $totalTests

try {
    # Test process creation speed
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $proc = Start-Process notepad -PassThru -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    if ($proc) { Stop-Process $proc -Force -ErrorAction SilentlyContinue }
    $stopwatch.Stop()
    
    $responseTime = $stopwatch.ElapsedMilliseconds
    Write-Info "  Process Launch Time: ${responseTime}ms"
    
    $responseScore = [Math]::Min(100, [Math]::Round(100 - ($responseTime / 10)))
    Write-Score $responseScore "Responsiveness Score"
    $scores["Responsiveness"] = $responseScore
}
catch {
    Write-Warn "Responsiveness test failed"
    $scores["Responsiveness"] = 0
}
Write-Host ""

# ============================================================================
# 8. Overall System Health
# ============================================================================
$currentTest++
Write-Step "Overall System Health" $currentTest $totalTests

try {
    $healthScore = [Math]::Round(($scores.Values | Measure-Object -Average).Average)
    
    Write-Host ""
    Write-Header "Benchmark Results Summary"
    
    Write-Host "  Component Scores:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($key in $scores.Keys) {
        $score = $scores[$key]
        $color = if ($score -ge 80) { "Green" } elseif ($score -ge 60) { "Yellow" } else { "Red" }
        Write-Host "    $key`:" -NoNewline
        Write-Host " $score / 100" -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host "  Overall Score:" -ForegroundColor Cyan
    
    $overallColor = if ($healthScore -ge 80) { "Green" } elseif ($healthScore -ge 60) { "Yellow" } else { "Red" }
    Write-Host ""
    Write-Host "    $healthScore / 100" -ForegroundColor $overallColor -FontSize 16
    
    Write-Host ""
    
    if ($healthScore -ge 90) {
        Write-OK "System performance is EXCELLENT!"
    } elseif ($healthScore -ge 80) {
        Write-OK "System performance is VERY GOOD"
    } elseif ($healthScore -ge 70) {
        Write-Info "System performance is GOOD"
    } elseif ($healthScore -ge 60) {
        Write-Warn "System performance is AVERAGE"
    } else {
        Write-Error "System performance needs improvement"
    }
    
    # Save results
    $resultsPath = "$PSScriptRoot\logs\benchmark-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $results = @{
        Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Scores = $scores
        Overall = $healthScore
    } | ConvertTo-Json
    
    $results | Out-File -FilePath $resultsPath -Encoding UTF8
    Write-OK "Results saved to: $resultsPath"
}
catch {
    Write-Warn "Failed to calculate overall score"
}
Write-Host ""

Write-Host ""
Read-Host "Press Enter to exit"
