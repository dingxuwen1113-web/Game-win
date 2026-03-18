# ============================================================================
# Windows 11 Backup & Restore Script v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Create and restore system backups before optimizations
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "BackupAndRestore"

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
# Configuration
# ============================================================================
$BackupRoot = "$env:SystemDrive\OptimizationBackups"
$RegistryBackup = "$BackupRoot\Registry"
$SettingsBackup = "$BackupRoot\Settings"
$ScriptsBackup = "$BackupRoot\Scripts"

# ============================================================================
# Main Script
# ============================================================================
Clear-Host
Write-Header "Backup & Restore v$SCRIPT_VERSION"
Write-Host "  System Backup and Recovery" -ForegroundColor Cyan
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

# Create backup directory
if (-not (Test-Path $BackupRoot)) {
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    Write-OK "Created backup directory: $BackupRoot"
}

# ============================================================================
# Main Menu
# ============================================================================
Write-Host "Select operation:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1] Create Full Backup" -ForegroundColor White
Write-Host "  [2] Create Registry Backup" -ForegroundColor White
Write-Host "  [3] Create Settings Backup" -ForegroundColor White
Write-Host "  [4] Restore Registry" -ForegroundColor White
Write-Host "  [5] Restore Settings" -ForegroundColor White
Write-Host "  [6] View Available Backups" -ForegroundColor White
Write-Host "  [0] Exit" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Enter choice (0-6)"

# ============================================================================
# Option 1: Create Full Backup
# ============================================================================
if ($choice -eq "1") {
    Write-Header "Creating Full System Backup"
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$BackupRoot\Full-$timestamp"
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    
    Write-Info "Backup location: $backupPath"
    Write-Host ""
    
    # 1. Registry Backup
    Write-Step "Backing up Registry" 1 5
    
    $regKeys = @(
        @{Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies"; File="Policies.reg"},
        @{Path="HKLM\SYSTEM\CurrentControlSet\Services"; File="Services.reg"},
        @{Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate"; File="WindowsUpdate.reg"},
        @{Path="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; File="Search.reg"},
        @{Path="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; File="ContentDelivery.reg"},
        @{Path="HKLM\SOFTWARE\Policies\Microsoft\Windows"; File="WindowsPolicies.reg"}
    )
    
    foreach ($key in $regKeys) {
        try {
            $regFile = "$backupPath\$($key.File)"
            reg export $key.Path $regFile /y 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-OK "  Backed up: $($key.Path)"
            }
        }
        catch {
            Write-Warn "  Failed: $($key.Path)"
        }
    }
    Write-Host ""
    
    # 2. System Restore Point
    Write-Step "Creating System Restore Point" 2 5
    
    try {
        Checkpoint-Computer -Description "Optimization Backup $timestamp" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-OK "  System restore point created"
    }
    catch {
        Write-Warn "  System restore point creation failed (may require additional permissions)"
    }
    Write-Host ""
    
    # 3. Driver Backup
    Write-Step "Backing up Drivers" 3 5
    
    try {
        $driverBackup = "$backupPath\Drivers"
        New-Item -ItemType Directory -Path $driverBackup -Force | Out-Null
        Export-WindowsDriver -Online -Destination $driverBackup -ErrorAction SilentlyContinue | Out-Null
        Write-OK "  Drivers exported"
    }
    catch {
        Write-Warn "  Driver backup failed"
    }
    Write-Host ""
    
    # 4. Settings Backup
    Write-Step "Backing up System Settings" 4 5
    
    try {
        $settingsBackup = "$backupPath\Settings"
        New-Item -ItemType Directory -Path $settingsBackup -Force | Out-Null
        
        # Export power plans
        powercfg -export "$settingsBackup\PowerPlans.pow" 2>$null
        Write-OK "  Power plans exported"
        
        # Export network settings
        netsh interface dump > "$settingsBackup\NetworkSettings.txt" 2>$null
        Write-OK "  Network settings exported"
        
        # Export firewall settings
        netsh advfirewall export "$settingsBackup\FirewallSettings.wfw" 2>$null
        Write-OK "  Firewall settings exported"
    }
    catch {
        Write-Warn "  Settings backup partially failed"
    }
    Write-Host ""
    
    # 5. Create Backup Info
    Write-Step "Creating Backup Information" 5 5
    
    $backupInfo = @"
Backup Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Computer Name: $env:COMPUTERNAME
Windows Version: $(Get-WmiObject Win32_OperatingSystem).Caption
Backup Type: Full System Backup

Contents:
- Registry exports
- System restore point
- Driver backups
- System settings

Location: $backupPath
"@
    
    $backupInfo | Out-File -FilePath "$backupPath\BACKUP_INFO.txt" -Encoding UTF8
    Write-OK "  Backup information saved"
    Write-Host ""
    
    Write-Header "Backup Complete!"
    Write-OK "Full backup created successfully"
    Write-Info "Location: $backupPath"
    Write-Host ""
    Write-Host "To restore:" -ForegroundColor Yellow
    Write-Host "  1. Run this script again" -ForegroundColor White
    Write-Host "  2. Select 'Restore Registry' or 'Restore Settings'" -ForegroundColor White
    Write-Host "  3. Or use Windows System Restore" -ForegroundColor White
    Write-Host ""
}

# ============================================================================
# Option 2: Create Registry Backup
# ============================================================================
elseif ($choice -eq "2") {
    Write-Header "Creating Registry Backup"
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $regBackupPath = "$RegistryBackup\$timestamp"
    New-Item -ItemType Directory -Path $regBackupPath -Force | Out-Null
    
    Write-Info "Backup location: $regBackupPath"
    Write-Host ""
    
    $regKeys = @(
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies",
        "HKLM\SYSTEM\CurrentControlSet\Services",
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate",
        "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search",
        "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
        "HKLM\SOFTWARE\Policies\Microsoft\Windows",
        "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameBar",
        "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    )
    
    foreach ($key in $regKeys) {
        try {
            $fileName = ($key -replace '\\', '_') + '.reg'
            $regFile = "$regBackupPath\$fileName"
            reg export $key $regFile /y 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-OK "  Backed up: $key"
            }
        }
        catch {
            Write-Warn "  Failed: $key"
        }
    }
    
    Write-Host ""
    Write-OK "Registry backup complete!"
    Write-Info "Location: $regBackupPath"
}

# ============================================================================
# Option 3: Create Settings Backup
# ============================================================================
elseif ($choice -eq "3") {
    Write-Header "Creating Settings Backup"
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $settingsBackupPath = "$SettingsBackup\$timestamp"
    New-Item -ItemType Directory -Path $settingsBackupPath -Force | Out-Null
    
    Write-Info "Backup location: $settingsBackupPath"
    Write-Host ""
    
    # Power plans
    Write-Step "Backing up Power Plans" 1 4
    try {
        powercfg -export "$settingsBackupPath\PowerPlans.pow" 2>$null
        Write-OK "  Power plans exported"
    }
    catch {
        Write-Warn "  Power plans export failed"
    }
    Write-Host ""
    
    # Network settings
    Write-Step "Backing up Network Settings" 2 4
    try {
        netsh interface dump > "$settingsBackupPath\NetworkSettings.txt" 2>$null
        Write-OK "  Network settings exported"
    }
    catch {
        Write-Warn "  Network settings export failed"
    }
    Write-Host ""
    
    # Firewall settings
    Write-Step "Backing up Firewall Settings" 3 4
    try {
        netsh advfirewall export "$settingsBackupPath\FirewallSettings.wfw" 2>$null
        Write-OK "  Firewall settings exported"
    }
    catch {
        Write-Warn "  Firewall settings export failed"
    }
    Write-Host ""
    
    # Windows Update settings
    Write-Step "Backing up Windows Update Settings" 4 4
    try {
        reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" "$settingsBackupPath\WindowsUpdate.reg" /y 2>$null
        Write-OK "  Windows Update settings exported"
    }
    catch {
        Write-Warn "  Windows Update settings export failed"
    }
    Write-Host ""
    
    Write-OK "Settings backup complete!"
    Write-Info "Location: $settingsBackupPath"
}

# ============================================================================
# Option 4: Restore Registry
# ============================================================================
elseif ($choice -eq "4") {
    Write-Header "Restore Registry"
    
    Write-Host "Available Registry Backups:" -ForegroundColor Cyan
    Write-Host ""
    
    if (Test-Path $RegistryBackup) {
        $backups = Get-ChildItem $RegistryBackup -Directory | Sort-Object Name -Descending
        $i = 1
        
        foreach ($backup in $backups) {
            Write-Host "  [$i] $($backup.Name)" -ForegroundColor White
            $i++
        }
        
        if ($backups.Count -eq 0) {
            Write-Warn "  No registry backups found"
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 0
        }
        
        Write-Host ""
        $restoreChoice = Read-Host "Select backup to restore (1-$($backups.Count))"
        
        if ([int]$restoreChoice -ge 1 -and [int]$restoreChoice -le $backups.Count) {
            $selectedBackup = $backups[$restoreChoice - 1]
            
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Red
            Write-Host "  WARNING: Registry Restore Operation" -ForegroundColor Red
            Write-Host "========================================" -ForegroundColor Red
            Write-Host ""
            Write-Host "This will overwrite current registry settings!" -ForegroundColor Yellow
            Write-Host "A system restart will be required." -ForegroundColor Yellow
            Write-Host ""
            
            $confirm = Read-Host "Continue? (Type YES to confirm)"
            
            if ($confirm -eq "YES") {
                Write-Host ""
                Write-Info "Restoring registry from: $($selectedBackup.FullName)"
                
                $regFiles = Get-ChildItem $selectedBackup.FullName -Filter *.reg
                
                foreach ($regFile in $regFiles) {
                    try {
                        reg import $regFile.FullName 2>$null
                        if ($LASTEXITCODE -eq 0) {
                            Write-OK "  Restored: $($regFile.Name)"
                        }
                    }
                    catch {
                        Write-Warn "  Failed: $($regFile.Name)"
                    }
                }
                
                Write-Host ""
                Write-OK "Registry restore complete!"
                Write-Warn "Please restart your computer for changes to take effect"
                Write-Host ""
                
                $restart = Read-Host "Restart now? (y/n)"
                if ($restart -eq "y" -or $restart -eq "Y") {
                    shutdown /r /t 0
                }
            } else {
                Write-Info "Restore cancelled"
            }
        }
    } else {
        Write-Warn "No registry backups found"
    }
}

# ============================================================================
# Option 5: Restore Settings
# ============================================================================
elseif ($choice -eq "5") {
    Write-Header "Restore Settings"
    
    Write-Host "Available Settings Backups:" -ForegroundColor Cyan
    Write-Host ""
    
    if (Test-Path $SettingsBackup) {
        $backups = Get-ChildItem $SettingsBackup -Directory | Sort-Object Name -Descending
        $i = 1
        
        foreach ($backup in $backups) {
            Write-Host "  [$i] $($backup.Name)" -ForegroundColor White
            $i++
        }
        
        if ($backups.Count -eq 0) {
            Write-Warn "  No settings backups found"
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 0
        }
        
        Write-Host ""
        $restoreChoice = Read-Host "Select backup to restore (1-$($backups.Count))"
        
        if ([int]$restoreChoice -ge 1 -and [int]$restoreChoice -le $backups.Count) {
            $selectedBackup = $backups[$restoreChoice - 1]
            
            Write-Host ""
            Write-Info "Restoring settings from: $($selectedBackup.FullName)"
            
            # Restore power plans
            $powerFile = "$($selectedBackup.FullName)\PowerPlans.pow"
            if (Test-Path $powerFile) {
                powercfg -import $powerFile 2>$null
                Write-OK "  Power plans restored"
            }
            
            # Restore network settings
            $networkFile = "$($selectedBackup.FullName)\NetworkSettings.txt"
            if (Test-Path $networkFile) {
                netsh interface reset all 2>$null
                Write-OK "  Network settings restored (requires restart)"
            }
            
            # Restore firewall
            $firewallFile = "$($selectedBackup.FullName)\FirewallSettings.wfw"
            if (Test-Path $firewallFile) {
                netsh advfirewall import $firewallFile 2>$null
                Write-OK "  Firewall settings restored"
            }
            
            Write-Host ""
            Write-OK "Settings restore complete!"
            Write-Warn "Some changes may require a restart"
        }
    } else {
        Write-Warn "No settings backups found"
    }
}

# ============================================================================
# Option 6: View Available Backups
# ============================================================================
elseif ($choice -eq "6") {
    Write-Header "Available Backups"
    
    Write-Host "Backup Location: $BackupRoot" -ForegroundColor Cyan
    Write-Host ""
    
    if (Test-Path $BackupRoot) {
        Write-Host "Full Backups:" -ForegroundColor Yellow
        $fullBackups = Get-ChildItem $BackupRoot -Directory -Filter "Full-*" | Sort-Object Name -Descending
        foreach ($backup in $fullBackups) {
            Write-Host "  - $($backup.Name)" -ForegroundColor White
        }
        Write-Host ""
        
        Write-Host "Registry Backups:" -ForegroundColor Yellow
        $regBackups = Get-ChildItem $RegistryBackup -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
        foreach ($backup in $regBackups) {
            Write-Host "  - $($backup.Name)" -ForegroundColor White
        }
        Write-Host ""
        
        Write-Host "Settings Backups:" -ForegroundColor Yellow
        $settingsBackups = Get-ChildItem $SettingsBackup -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
        foreach ($backup in $settingsBackups) {
            Write-Host "  - $($backup.Name)" -ForegroundColor White
        }
    } else {
        Write-Warn "No backups found"
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
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
Write-Host "Backup & Restore script completed." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
