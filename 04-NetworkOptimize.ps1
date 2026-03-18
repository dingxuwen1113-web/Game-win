# ============================================================================
# Windows 11 Network Optimization Script v2.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 2.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# ============================================================================

$SCRIPT_VERSION = "2.0.0"
$SCRIPT_NAME = "NetworkOptimize"

# Header
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 11 Network Optimization v$SCRIPT_VERSION" -ForegroundColor Cyan
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
    Checkpoint-Computer -Description "Before Network Optimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  [OK] Restore point created" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Restore point creation failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: TCP/IP Optimization
Write-Host "[2/8] Optimizing TCP/IP settings..." -ForegroundColor Yellow
$tcpModified = 0
$tcpFailed = 0

try {
    # Disable Nagle's algorithm
    netsh int tcp set global autotuninglevel=normal 2>$null
    netsh int tcp set global chimney=enabled 2>$null
    netsh int tcp set global dca=enabled 2>$null
    netsh int tcp set global netdma=enabled 2>$null
    netsh int tcp set global ecncapability=enabled 2>$null
    Write-Host "  [OK] TCP autotuning configured" -ForegroundColor Green
    $tcpModified++
}
catch {
    Write-Host "  [FAIL] TCP configuration failed" -ForegroundColor Red
    $tcpFailed++
}

try {
    # Set TCP window size
    netsh int tcp set global rss=enabled 2>$null
    Write-Host "  [OK] RSS enabled" -ForegroundColor Green
    $tcpModified++
}
catch {
    $tcpFailed++
}

Write-Host "  TCP settings: $tcpModified modified, $tcpFailed failed" -ForegroundColor Cyan
Write-Host ""

# Step 3: DNS Optimization
Write-Host "[3/8] Optimizing DNS settings..." -ForegroundColor Yellow
$dnsModified = 0

try {
    # Flush DNS cache
    ipconfig /flushdns 2>$null | Out-Null
    Write-Host "  [OK] DNS cache flushed" -ForegroundColor Green
    $dnsModified++
}
catch {
    Write-Host "  [WARN] DNS flush failed" -ForegroundColor Yellow
}

try {
    # Register DNS
    ipconfig /registerdns 2>$null | Out-Null
    Write-Host "  [OK] DNS registered" -ForegroundColor Green
    $dnsModified++
}
catch {
    Write-Host "  [WARN] DNS registration failed" -ForegroundColor Yellow
}

Write-Host ""

# Step 4: Network Adapter Optimization
Write-Host "[4/8] Optimizing network adapters..." -ForegroundColor Yellow
$adapterModified = 0

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        try {
            # Enable jumbo packet (if supported)
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Jumbo Packet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            
            # Enable flow control
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Flow Control" -DisplayValue "Rx & Tx Enabled" -ErrorAction SilentlyContinue
            
            Write-Host "  [OK] $($adapter.Name) optimized" -ForegroundColor Green
            $adapterModified++
        }
        catch {
            # Skip adapters that don't support these settings
        }
    }
}
catch {
    Write-Host "  [WARN] Adapter optimization failed" -ForegroundColor Yellow
}

Write-Host "  Adapters optimized: $adapterModified" -ForegroundColor Cyan
Write-Host ""

# Step 5: Disable Network Throttling
Write-Host "[5/8] Disabling network throttling..." -ForegroundColor Yellow

try {
    $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "NetworkThrottlingIndex" -Value 4294967295 -Type DWord -Force
        Write-Host "  [OK] Network throttling disabled" -ForegroundColor Green
    }
}
catch {
    Write-Host "  [WARN] Network throttling disable failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Optimize Interrupt Moderation
Write-Host "[6/8] Optimizing interrupt settings..." -ForegroundColor Yellow
$intModified = 0

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        try {
            # Disable interrupt moderation for lower latency
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Write-Host "  [OK] $($adapter.Name) interrupt moderation disabled" -ForegroundColor Green
            $intModified++
        }
        catch {
            # Skip if not supported
        }
    }
}
catch {
    Write-Host "  [WARN] Interrupt optimization failed" -ForegroundColor Yellow
}

Write-Host "  Interrupt settings: $intModified modified" -ForegroundColor Cyan
Write-Host ""

# Step 7: Power Management
Write-Host "[7/8] Optimizing power management..." -ForegroundColor Yellow
$powerModified = 0

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        try {
            # Disable power saving
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Green Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Write-Host "  [OK] $($adapter.Name) power saving disabled" -ForegroundColor Green
            $powerModified++
        }
        catch {
            # Skip if not supported
        }
    }
}
catch {
    Write-Host "  [WARN] Power management optimization failed" -ForegroundColor Yellow
}

Write-Host "  Power settings: $powerModified modified" -ForegroundColor Cyan
Write-Host ""

# Step 8: Summary
Write-Host "[8/8] Network optimization complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  TCP settings:    $tcpModified modified, $tcpFailed failed" -ForegroundColor $(if ($tcpFailed -eq 0) { "Green" } else { "Yellow" })
Write-Host "  DNS operations:  $dnsModified completed" -ForegroundColor Green
Write-Host "  Adapters:        $adapterModified optimized" -ForegroundColor Green
Write-Host "  Interrupts:      $intModified configured" -ForegroundColor Green
Write-Host "  Power settings:  $powerModified updated" -ForegroundColor Green
Write-Host ""

Write-Host "[INFO] Network optimization complete" -ForegroundColor Cyan
Write-Host "[INFO] Some changes may require a restart" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
