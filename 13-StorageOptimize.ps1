# ============================================================================
# Windows 11 Storage Optimization Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: SSD optimization, storage cleanup, and performance tuning
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "StorageOptimize"

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
Write-Header "Storage Optimization v$SCRIPT_VERSION"
Write-Host "  SSD Optimization & Storage Cleanup" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Administrator privileges required!"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-OK "Administrator privileges confirmed"

$healthScore = 100
$totalSteps = 10
$currentStep = 0

# ============================================================================
# 1. Detect Drive Types
# ============================================================================
$currentStep++
Write-Step "Detecting drive types" $currentStep $totalSteps

try {
    $disks = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size, OperationalStatus
    foreach ($disk in $disks) {
        $sizeGB = [Math]::Round($disk.Size / 1GB, 2)
        $mediaType = if ($disk.MediaType) { $disk.MediaType } else { "Unknown" }
        Write-Info "  $($disk.FriendlyName): $sizeGB GB ($mediaType)"
        
        if ($mediaType -eq "SSD") {
            Write-OK "  SSD detected - optimization enabled"
        } elseif ($mediaType -eq "HDD") {
            Write-Info "  HDD detected - defrag recommended"
        }
    }
}
catch {
    Write-Warn "Failed to detect drive types"
}
Write-Host ""

# ============================================================================
# 2. Enable TRIM for SSDs
# ============================================================================
$currentStep++
Write-Step "Configuring TRIM for SSDs" $currentStep $totalSteps

try {
    $trimStatus = Get-PhysicalDisk | Where-Object { $_.MediaType -eq "SSD" } | ForEach-Object {
        Get-PhysicalDiskSupport -DeviceId $_.DeviceId | Select-Object TrimSupported
    }
    
    if ($trimStatus) {
        Write-OK "TRIM support detected on SSDs"
    }
    
    # Enable automatic optimization
    Set-OptimizeDrive -Scheduled $true
    Write-OK "Automatic drive optimization enabled"
}
catch {
    Write-Warn "TRIM configuration failed"
}
Write-Host ""

# ============================================================================
# 3. Disable Windows Search Indexing (SSD)
# ============================================================================
$currentStep++
Write-Step "Optimizing Windows Search indexing" $currentStep $totalSteps

try {
    # Disable indexing on SSD system drive
    $systemDrive = $env:SystemDrive
    $volume = Get-Volume -DriveLetter $systemDrive.Replace(":", "")
    
    if ($volume.DriveType -eq "Fixed") {
        # Check if indexing is enabled
        $indexStatus = (Get-CimInstance Win32_Volume | Where-Object { $_.DriveLetter -eq $systemDrive }).IndexingEnabled
        
        if ($indexStatus) {
            Write-Info "  Windows Search indexing is enabled"
            Write-Info "  Consider disabling for SSD performance (optional)"
        } else {
            Write-OK "  Windows Search indexing is disabled"
        }
    }
}
catch {
    Write-Warn "Indexing check failed"
}
Write-Host ""

# ============================================================================
# 4. Disable Superfetch/SysMain
# ============================================================================
$currentStep++
Write-Step "Configuring SysMain service" $currentStep $totalSteps

try {
    $service = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
    
    if ($service) {
        if ($service.Status -eq "Running") {
            Write-Info "  SysMain service is running (normal for HDD, optional for SSD)"
            
            # Check drive type and recommend
            $disks = Get-PhysicalDisk | Select-Object MediaType
            $hasSSD = $disks | Where-Object { $_.MediaType -eq "SSD" }
            
            if ($hasSSD) {
                Write-Info "  SSD detected - SysMain can be disabled for better performance"
                Write-Info "  Run: Disable-Service -Name 'SysMain' (manual)"
            }
        } else {
            Write-OK "  SysMain service is disabled"
        }
    }
}
catch {
    Write-Warn "SysMain check failed"
}
Write-Host ""

# ============================================================================
# 5. Clean Temporary Files
# ============================================================================
$currentStep++
Write-Step "Cleaning temporary files" $currentStep $totalSteps

try {
    $tempPaths = @(
        $env:TEMP,
        $env:TMP,
        "$env:SystemRoot\Temp",
        "$env:LOCALAPPDATA\Temp"
    )
    
    $totalCleaned = 0
    
    foreach ($tempPath in $tempPaths) {
        if (Test-Path $tempPath) {
            $files = Get-ChildItem -Path $tempPath -File -ErrorAction SilentlyContinue
            $fileCount = $files.Count
            
            if ($fileCount -gt 0) {
                $totalCleaned += $fileCount
                Remove-Item -Path "$tempPath\*" -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
    }
    
    Write-OK "Cleaned $totalCleaned temporary files"
}
catch {
    Write-Warn "Temporary file cleanup failed"
}
Write-Host ""

# ============================================================================
# 6. Clean Windows Update Cache
# ============================================================================
$currentStep++
Write-Step "Cleaning Windows Update cache" $currentStep $totalSteps

try {
    Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
    
    $updateCachePath = "$env:SystemRoot\SoftwareDistribution\Download"
    
    if (Test-Path $updateCachePath) {
        $cacheFiles = Get-ChildItem -Path $updateCachePath -Recurse -File
        $cacheCount = $cacheFiles.Count
        
        if ($cacheCount -gt 0) {
            Remove-Item -Path "$updateCachePath\*" -Force -Recurse -ErrorAction SilentlyContinue
            Write-OK "Cleaned $cacheCount Windows Update cache files"
        } else {
            Write-OK "Windows Update cache already clean"
        }
    }
    
    Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Start-Service -Name "bits" -ErrorAction SilentlyContinue
}
catch {
    Write-Warn "Windows Update cache cleanup failed"
}
Write-Host ""

# ============================================================================
# 7. Clean Delivery Optimization Cache
# ============================================================================
$currentStep++
Write-Step "Cleaning Delivery Optimization cache" $currentStep $totalSteps

try {
    $doCachePath = "$env:SystemRoot\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache"
    
    if (Test-Path $doCachePath) {
        $cacheFiles = Get-ChildItem -Path $doCachePath -File -ErrorAction SilentlyContinue
        $cacheCount = $cacheFiles.Count
        
        if ($cacheCount -gt 0) {
            Remove-Item -Path "$doCachePath\*" -Force -ErrorAction SilentlyContinue
            Write-OK "Cleaned $cacheCount Delivery Optimization files"
        }
    } else {
        Write-OK "Delivery Optimization cache is clean"
    }
}
catch {
    Write-Warn "Delivery Optimization cleanup failed"
}
Write-Host ""

# ============================================================================
# 8. Disable Storage Sense (Manual Control)
# ============================================================================
$currentStep++
Write-Step "Configuring Storage Sense" $currentStep $totalSteps

try {
    $storageSensePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
    
    if (Test-Path $storageSensePath) {
        $status = (Get-ItemProperty -Path $storageSensePath -Name "01" -ErrorAction SilentlyContinue)."01"
        
        if ($status -eq 1) {
            Write-Info "  Storage Sense is enabled (automatic cleanup)"
            Write-Info "  Good for most users, but manual control is more precise"
        } else {
            Write-OK "  Storage Sense is disabled (manual control)"
        }
    }
}
catch {
    Write-Warn "Storage Sense check failed"
}
Write-Host ""

# ============================================================================
# 9. Optimize Page File
# ============================================================================
$currentStep++
Write-Step "Checking page file configuration" $currentStep $totalSteps

try {
    $pageFile = Get-CimInstance Win32_PageFileSetting
    
    if ($pageFile) {
        foreach ($pf in $pageFile) {
            $initialSize = $pf.InitialSize
            $maximumSize = $pf.MaximumSize
            
            Write-Info "  Page file on $($pf.Name):"
            Write-Info "    Initial: $([Math]::Round($initialSize / 1024, 2)) GB"
            Write-Info "    Maximum: $([Math]::Round($maximumSize / 1024, 2)) GB"
            
            if ($initialSize -eq $maximumSize) {
                Write-OK "    Fixed size (optimal for performance)"
            } else {
                Write-Info "    Variable size (consider fixed size for better performance)"
            }
        }
    } else {
        Write-Info "  No page file configured (system managed or disabled)"
    }
}
catch {
    Write-Warn "Page file check failed"
}
Write-Host ""

# ============================================================================
# 10. Disk Space Summary
# ============================================================================
$currentStep++
Write-Step "Analyzing disk space" $currentStep $totalSteps

try {
    $volumes = Get-Volume | Where-Object { $_.DriveType -eq "Fixed" -and $_.DriveLetter -ne $null }
    
    foreach ($vol in $volumes) {
        $sizeGB = [Math]::Round($vol.Size / 1GB, 2)
        $freeGB = [Math]::Round($vol.SizeRemaining / 1GB, 2)
        $usedPercent = [Math]::Round((($vol.Size - $vol.SizeRemaining) / $vol.Size) * 100, 1)
        
        Write-Info "  Drive $($vol.DriveLetter)::"
        Write-Info "    Total: $sizeGB GB"
        Write-Info "    Free: $freeGB GB"
        Write-Info "    Used: $usedPercent%"
        
        if ($usedPercent -gt 90) {
            Write-Error "    CRITICAL: Less than 10% free space!"
            $healthScore -= 20
        } elseif ($usedPercent -gt 80) {
            Write-Warn "    WARNING: Less than 20% free space"
            $healthScore -= 10
        } elseif ($usedPercent -gt 70) {
            Write-Info "    Consider cleaning up"
        } else {
            Write-OK "    Healthy disk space"
        }
    }
}
catch {
    Write-Warn "Disk space analysis failed"
}
Write-Host ""

# ============================================================================
# Summary
# ============================================================================
Write-Header "Storage Optimization Summary"

Write-Info "Health Score: $healthScore/100"

if ($healthScore -ge 90) {
    Write-OK "Storage health is excellent!"
} elseif ($healthScore -ge 70) {
    Write-Info "Storage health is good"
} elseif ($healthScore -ge 50) {
    Write-Warn "Storage health needs attention"
} else {
    Write-Error "Storage health is critical!"
}

Write-Host ""
Write-Host "Recommendations:" -ForegroundColor Cyan
Write-Host "  - Run Disk Cleanup regularly" -ForegroundColor White
Write-Host "  - Keep at least 20% free space on SSDs" -ForegroundColor White
Write-Host "  - Consider disabling SysMain on SSD systems" -ForegroundColor White
Write-Host "  - Use fixed-size page file for better performance" -ForegroundColor White
Write-Host ""

Write-OK "Storage optimization complete!"
Write-Host ""
Read-Host "Press Enter to exit"
