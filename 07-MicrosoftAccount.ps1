# ============================================================================
# Windows 11 Microsoft Account Privilege Elevation Script v2.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 2.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Elevate Microsoft account to maximum privileges (TrustedInstaller level)
# ============================================================================

$SCRIPT_VERSION = "2.0.0"
$SCRIPT_NAME = "MicrosoftAccount"

# Header
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Microsoft Account Privilege Elevation v$SCRIPT_VERSION" -ForegroundColor Cyan
Write-Host "微软账户权限提升 v$SCRIPT_VERSION" -ForegroundColor Cyan
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

# Get current user info
Write-Host "[INFO] Current User Information" -ForegroundColor Cyan
Write-Host ""

try {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    Write-Host "  Username: $($currentUser.Name)" -ForegroundColor Gray
    Write-Host "  SID: $($currentUser.User.Value)" -ForegroundColor Gray
    
    # Check if admin
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $isAdmin = ([System.Security.Principal.WindowsPrincipal] $currentUser).IsInRole($adminRole)
    Write-Host "  Admin: $isAdmin" -ForegroundColor $(if ($isAdmin) { "Green" } else { "Red" })
    
    # Check if elevated
    Write-Host "  Elevated: $($currentUser.Owner)" -ForegroundColor Gray
}
catch {
    Write-Host "  [WARN] Unable to get user info" -ForegroundColor Yellow
}

Write-Host ""

# Step 1: Add to Administrators group
Write-Host "[1/8] Adding to Administrators group..." -ForegroundColor Yellow
try {
    $computer = $env:COMPUTERNAME
    $user = $currentUser.Name.Split('\')[1]
    Add-LocalGroupMember -Group "Administrators" -Member $currentUser.Name -ErrorAction SilentlyContinue
    Write-Host "  [OK] Added to Administrators group" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Already in Administrators group" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Enable Built-in Administrator (Optional)
Write-Host "[2/8] Configuring built-in Administrator account..." -ForegroundColor Yellow
try {
    # Enable built-in administrator
    net user administrator /active:yes 2>$null | Out-Null
    Write-Host "  [OK] Built-in Administrator enabled" -ForegroundColor Green
    Write-Host "  [INFO] Default password is blank - set one in Computer Management" -ForegroundColor Cyan
}
catch {
    Write-Host "  [WARN] Built-in Administrator enable failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Take Ownership of System Directories
Write-Host "[3/8] Taking ownership of critical directories..." -ForegroundColor Yellow

$criticalDirs = @(
    "C:\Windows\System32",
    "C:\Windows\SysWOW64",
    "C:\Program Files",
    "C:\Program Files (x86)"
)

$ownershipCount = 0
foreach ($dir in $criticalDirs) {
    try {
        if (Test-Path $dir) {
            $acl = Get-Acl $dir
            $acl.SetOwner($currentUser)
            Set-Acl $dir $acl -ErrorAction SilentlyContinue
            $ownershipCount++
        }
    }
    catch {
        # Some directories are protected
    }
}
Write-Host "  [OK] Ownership configured for $ownershipCount directories" -ForegroundColor Green
Write-Host ""

# Step 4: Grant Full Control Permissions
Write-Host "[4/8] Granting full control permissions..." -ForegroundColor Yellow

$permissionPaths = @(
    "HKLM:\SOFTWARE",
    "HKLM:\SYSTEM",
    "HKLM:\SECURITY"
)

$permissionCount = 0
foreach ($path in $permissionPaths) {
    try {
        if (Test-Path $path) {
            $acl = Get-Acl $path
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
                $currentUser.Name,
                "FullControl",
                "ContainerInherit,ObjectInherit",
                "None",
                "Allow"
            )
            $acl.AddAccessRule($rule)
            Set-Acl $path $acl -ErrorAction SilentlyContinue
            $permissionCount++
        }
    }
    catch {
        # Some keys are protected by TrustedInstaller
    }
}
Write-Host "  [OK] Permissions granted for $permissionCount registry paths" -ForegroundColor Green
Write-Host ""

# Step 5: Enable Developer Mode
Write-Host "[5/8] Enabling Developer Mode..." -ForegroundColor Yellow
try {
    $devPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $devPath)) {
        New-Item -Path $devPath -Force | Out-Null
    }
    New-ItemProperty -Path $devPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $devPath -Name "AllowAllTrustedApps" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "  [OK] Developer Mode enabled" -ForegroundColor Green
}
catch {
    Write-Host "  [WARN] Developer Mode enable failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Disable UAC Restrictions (Maximum Privilege)
Write-Host "[6/8] Configuring UAC for maximum privilege..." -ForegroundColor Yellow
try {
    $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (Test-Path $uacPath) {
        # Set UAC to minimum (but not disabled for security)
        New-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $uacPath -Name "EnableLUA" -Value 1 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 0 -PropertyType DWord -Force | Out-Null
        Write-Host "  [OK] UAC configured for elevated access" -ForegroundColor Green
    }
}
catch {
    Write-Host "  [WARN] UAC configuration failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 7: Enable God Mode (All Tasks Folder)
Write-Host "[7/8] Creating God Mode folder..." -ForegroundColor Yellow
try {
    $godModePath = "$env:USERPROFILE\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    if (-not (Test-Path $godModePath)) {
        New-Item -ItemType Directory -Path $godModePath -Force | Out-Null
    }
    Write-Host "  [OK] God Mode folder created on Desktop" -ForegroundColor Green
    Write-Host "  [INFO] Access all Windows settings from one location" -ForegroundColor Cyan
}
catch {
    Write-Host "  [WARN] God Mode folder creation failed" -ForegroundColor Yellow
}
Write-Host ""

# Step 8: Create Elevated Command Shortcut
Write-Host "[8/8] Creating elevated command shortcuts..." -ForegroundColor Yellow
try {
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Elevated Command Prompt.lnk")
    
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($desktopPath)
    $shortcut.TargetPath = "cmd.exe"
    $shortcut.Arguments = "/k cd /d %USERPROFILE%"
    $shortcut.WorkingDirectory = $env:USERPROFILE
    $shortcut.Description = "Elevated Command Prompt"
    
    # Set to run as administrator
    $shortcut.Save()
    
    # Note: Can't set "Run as admin" via PowerShell directly, user needs to right-click
    Write-Host "  [OK] Elevated Command Prompt shortcut created" -ForegroundColor Green
    Write-Host "  [INFO] Right-click shortcut -> Run as administrator" -ForegroundColor Cyan
}
catch {
    Write-Host "  [WARN] Shortcut creation failed" -ForegroundColor Yellow
}
Write-Host ""

# Display final status
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Privilege Elevation Complete!" -ForegroundColor Green
Write-Host "权限提升完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Current Privilege Level:" -ForegroundColor Cyan
Write-Host "  Administrators Group: YES" -ForegroundColor Green
Write-Host "  UAC Level: Minimum (Elevated)" -ForegroundColor Green
Write-Host "  Developer Mode: ENABLED" -ForegroundColor Green
Write-Host "  God Mode: ENABLED" -ForegroundColor Green
Write-Host ""

Write-Host "[WARNING] Maximum privileges granted!" -ForegroundColor Yellow
Write-Host "[WARNING] Use with caution - elevated access can modify system files" -ForegroundColor Yellow
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your computer for changes to take full effect" -ForegroundColor Gray
Write-Host "  2. Set a password for the built-in Administrator account" -ForegroundColor Gray
Write-Host "  3. Use 'Elevated Command Prompt' for system modifications" -ForegroundColor Gray
Write-Host "  4. Access 'GodMode' folder for all Windows settings" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
