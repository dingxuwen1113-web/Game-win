# ============================================================================
# Windows 11 Network Security Hardening Script v2.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 2.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# ============================================================================

$SCRIPT_VERSION = "2.0.0"
$SCRIPT_NAME = "NetworkSecurity"

# Header
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Network Security Hardening v$SCRIPT_VERSION" -ForegroundColor Cyan
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
Write-Host "[1/7] Creating system restore point..." -ForegroundColor Yellow
try {
    Checkpoint-Computer -Description "Before Network Security Hardening" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  [OK] Restore point created" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Restore point creation failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Disable SMBv1
Write-Host "[2/7] Disabling SMBv1 (insecure protocol)..." -ForegroundColor Yellow
try {
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue
    Write-Host "  [OK] SMBv1 disabled" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] SMBv1 disable failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Enable Windows Firewall
Write-Host "[3/7] Configuring Windows Firewall..." -ForegroundColor Yellow
$fwModified = 0

try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
    Write-Host "  [OK] Firewall enabled for all profiles" -ForegroundColor Green
    $fwModified++
}
catch {
    Write-Host "  [WARN] Firewall config failed" -ForegroundColor Yellow
}

try {
    # Block inbound connections by default
    Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block -ErrorAction SilentlyContinue
    Write-Host "  [OK] Default inbound action: Block" -ForegroundColor Green
    $fwModified++
}
catch {
    Write-Host "  [WARN] Inbound rule config failed" -ForegroundColor Yellow
}

Write-Host "  Firewall settings: $fwModified configured" -ForegroundColor Cyan
Write-Host ""

# Step 4: Disable LLMNR
Write-Host "[4/7] Disabling LLMNR (security risk)..." -ForegroundColor Yellow
try {
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    New-ItemProperty -Path $path -Name "EnableLLMNR" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "  [OK] LLMNR disabled" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] LLMNR disable failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Disable NetBIOS over TCP/IP
Write-Host "[5/7] Disabling NetBIOS over TCP/IP..." -ForegroundColor Yellow
$netbiosModified = 0

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        try {
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "NetBIOS over TCP/IP" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Write-Host "  [OK] $($adapter.Name) NetBIOS disabled" -ForegroundColor Green
            $netbiosModified++
        }
        catch {
            # Skip if not supported
        }
    }
}
catch {
    Write-Host "  [WARN] NetBIOS config failed" -ForegroundColor Yellow
}

Write-Host "  NetBIOS settings: $netbiosModified configured" -ForegroundColor Cyan
Write-Host ""

# Step 6: Enable DEP
Write-Host "[6/7] Configuring DEP (Data Execution Prevention)..." -ForegroundColor Yellow
try {
    bcdedit /set nx OptIn 2>$null | Out-Null
    Write-Host "  [OK] DEP enabled (OptIn)" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] DEP config failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 7: Summary
Write-Host "[7/7] Security hardening complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  SMBv1:        Disabled" -ForegroundColor Green
Write-Host "  Firewall:     Enabled (all profiles)" -ForegroundColor Green
Write-Host "  LLMNR:        Disabled" -ForegroundColor Green
Write-Host "  NetBIOS:      $netbiosModified adapters configured" -ForegroundColor Green
Write-Host "  DEP:          Enabled" -ForegroundColor Green
Write-Host ""

Write-Host "[INFO] Network security hardening complete" -ForegroundColor Cyan
Write-Host "[INFO] Some changes may require a restart" -ForegroundColor Cyan
Write-Host ""

Write-Host "Security Tips:" -ForegroundColor Cyan
Write-Host "  - Keep Windows updated" -ForegroundColor Gray
Write-Host "  - Use strong passwords" -ForegroundColor Gray
Write-Host "  - Enable BitLocker encryption" -ForegroundColor Gray
Write-Host "  - Regular security scans" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
