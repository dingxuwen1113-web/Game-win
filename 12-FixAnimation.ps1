# ============================================================================
# Windows 11 Animation Effects Fix Script v1.0.0
# Windows 11 Optimization Suite - Animation & Visual Effects
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Fix and optimize Windows 11 animation effects
# Features: Restore animations, fix stuttering, optimize performance
# ============================================================================

# Load Logger Module
. .\Logger.ps1

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "FixAnimation"

# ============================================================================
# Configuration
# ============================================================================
$CONFIG = @{
    EnableAnimations = $true
    EnableTransparency = $true
    EnableSmoothScrolling = $true
    EnableFadeEffects = $true
    EnableShadowEffects = $true
    OptimizeForPerformance = $false  # Set to true for gaming rigs
    FixStuttering = $true
    ResetToDefaults = $false  # Set to true to reset all to Windows defaults
}

# ============================================================================
# Helper Functions
# ============================================================================

function Get-CurrentAnimationSettings {
    Write-Host ""
    Write-Host "Current Animation Settings:" -ForegroundColor Cyan
    Write-Host ""
    
    # Check animation setting
    try {
        $visualPath = "HKCU:\Control Panel\Desktop"
        $userPrefs = (Get-ItemProperty -Path $visualPath -Name "UserPreferencesMask" -ErrorAction SilentlyContinue).UserPreferencesMask
        
        if ($userPrefs) {
            # Byte 0: Animation settings
            $animationEnabled = ($userPrefs[0] -band 0x01) -eq 0
            Write-Status "Window Animations" $(if ($animationEnabled) { "Enabled" } else { "Disabled" }) $(if ($animationEnabled) { "Green" } else { "Yellow" })
        }
    }
    catch {
        Write-Status "Window Animations" "Unknown" "Yellow"
    }
    
    # Check transparency
    try {
        $transparencyPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $transparency = (Get-ItemProperty -Path $transparencyPath -Name "EnableTransparency" -ErrorAction SilentlyContinue).EnableTransparency
        Write-Status "Transparency Effects" $(if ($transparency -eq 1) { "Enabled" } else { "Disabled" }) $(if ($transparency -eq 1) { "Green" } else { "Yellow" })
    }
    catch {
        Write-Status "Transparency Effects" "Unknown" "Yellow"
    }
    
    # Check smooth scrolling
    try {
        $smoothPath = "HKCU:\Control Panel\Desktop"
        $smoothScroll = (Get-ItemProperty -Path $smoothPath -Name "SmoothScroll" -ErrorAction SilentlyContinue).SmoothScroll
        Write-Status "Smooth Scrolling" $(if ($smoothScroll -eq 1) { "Enabled" } else { "Disabled" }) $(if ($smoothScroll -eq 1) { "Green" } else { "Yellow" })
    }
    catch {
        Write-Status "Smooth Scrolling" "Unknown" "Yellow"
    }
    
    # Check font smoothing
    try {
        $fontSmooth = (Get-ItemProperty -Path $visualPath -Name "FontSmoothing" -ErrorAction SilentlyContinue).FontSmoothing
        Write-Status "Font Smoothing" $(if ($fontSmooth -eq "2") { "Enabled" } else { "Disabled" }) $(if ($fontSmooth -eq "2") { "Green" } else { "Yellow" })
    }
    catch {
        Write-Status "Font Smoothing" "Unknown" "Yellow"
    }
    
    Write-Host ""
}

# ============================================================================
# Animation Fix Functions
# ============================================================================

function Enable-WindowAnimations {
    Write-Step "Configuring Window Animations" 1 8
    
    try {
        $path = "HKCU:\Control Panel\Desktop"
        
        # Get current UserPreferencesMask
        $currentPrefs = (Get-ItemProperty -Path $path -Name "UserPreferencesMask" -ErrorAction SilentlyContinue).UserPreferencesMask
        
        if ($currentPrefs) {
            # Create new preferences with animations enabled
            $newPrefs = [byte[]]($currentPrefs[0], $currentPrefs[1], $currentPrefs[2], $currentPrefs[3], 
                                  $currentPrefs[4], $currentPrefs[5], $currentPrefs[6], $currentPrefs[7])
            
            # Enable animations (clear bit 0)
            $newPrefs[0] = $newPrefs[0] -band 0xFE
            
            Set-ItemProperty -Path $path -Name "UserPreferencesMask" -Value $newPrefs -Force
            Write-OK "Window animations enabled"
            return $true
        }
        else {
            # Set default with animations
            $defaultPrefs = [byte[]](158, 18, 3, 128, 16, 0, 0, 0)
            Set-ItemProperty -Path $path -Name "UserPreferencesMask" -Value $defaultPrefs -Force
            Write-OK "Window animations enabled (default)"
            return $true
        }
    }
    catch {
        Write-Warn "Failed to configure window animations"
        return $false
    }
}

function Enable-TransparencyEffects {
    Write-Step "Configuring Transparency Effects" 2 8
    
    try {
        $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        Set-ItemProperty -Path $path -Name "EnableTransparency" -Value 1 -Type DWord -Force
        Write-OK "Transparency effects enabled"
        return $true
    }
    catch {
        Write-Warn "Failed to enable transparency effects"
        return $false
    }
}

function Enable-SmoothScrolling {
    Write-Step "Configuring Smooth Scrolling" 3 8
    
    try {
        $path = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $path -Name "SmoothScroll" -Value 1 -Type DWord -Force
        Write-OK "Smooth scrolling enabled"
        return $true
    }
    catch {
        Write-Warn "Failed to enable smooth scrolling"
        return $false
    }
}

function Enable-FadeEffects {
    Write-Step "Configuring Fade Effects" 4 8
    
    try {
        $path = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $path -Name "UserPreferencesMask" -Value ([byte[]](158, 18, 3, 128, 16, 0, 0, 0)) -Force
        Set-ItemProperty -Path $path -Name "MinAnimate" -Value "1" -Type String -Force
        Write-OK "Fade effects enabled"
        return $true
    }
    catch {
        Write-Warn "Failed to enable fade effects"
        return $false
    }
}

function Enable-ShadowEffects {
    Write-Step "Configuring Shadow Effects" 5 8
    
    try {
        $path = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $path -Name "ListviewShadow" -Value "1" -Type String -Force
        Write-OK "Shadow effects enabled"
        return $true
    }
    catch {
        Write-Warn "Failed to enable shadow effects"
        return $false
    }
}

function Fix-AnimationStuttering {
    Write-Step "Fixing Animation Stuttering" 6 8
    
    $fixed = 0
    
    try {
        # Disable power saving on GPU
        $path = "HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        Set-ItemProperty -Path $path -Name "UserGpuPreference" -Value 2 -Type DWord -Force
        Write-OK "GPU performance mode enabled"
        $fixed++
    }
    catch { }
    
    try {
        # Optimize window rendering
        $path = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $path -Name "HungAppTimeout" -Value "1000" -Type String -Force
        Set-ItemProperty -Path $path -Name "WaitToKillAppTimeout" -Value "2000" -Type String -Force
        Write-OK "Window rendering optimized"
        $fixed++
    }
    catch { }
    
    try {
        # Enable hardware acceleration
        $path = "HKCU:\SOFTWARE\Microsoft\Avalanche.Graphics"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        Set-ItemProperty -Path $path -Name "DisableHardwareAcceleration" -Value 0 -Type DWord -Force
        Write-OK "Hardware acceleration enabled"
        $fixed++
    }
    catch { }
    
    if ($fixed -gt 0) {
        Write-OK "Animation stuttering fixes applied ($fixed)"
        return $true
    } else {
        Write-Warn "No stuttering fixes applied"
        return $false
    }
}

function Enable-FontSmoothing {
    Write-Step "Configuring Font Smoothing" 7 8
    
    try {
        $path = "HKCU:\Control Panel\Desktop"
        Set-ItemProperty -Path $path -Name "FontSmoothing" -Value "2" -Type String -Force
        Set-ItemProperty -Path $path -Name "FontSmoothingType" -Value 2 -Type DWord -Force
        Set-ItemProperty -Path $path -Name "FontSmoothingGamma" -Value 1400 -Type DWord -Force
        Write-OK "Font smoothing configured (ClearType)"
        return $true
    }
    catch {
        Write-Warn "Failed to configure font smoothing"
        return $false
    }
}

function Restart-Explorer {
    Write-Step "Applying Changes" 8 8
    
    Write-Host ""
    Write-Host "  Changes will take effect after restarting Explorer" -ForegroundColor Yellow
    Write-Host ""
    
    $restart = Read-Host "  Restart Explorer now? (Y/N, default: Y)"
    
    if ($restart -eq "" -or $restart -eq "Y" -or $restart -eq "y") {
        try {
            Stop-Process -Name "explorer" -Force -ErrorAction Stop
            Write-OK "Explorer restarted"
            Write-Info "Desktop will flicker briefly"
            return $true
        }
        catch {
            Write-Warn "Failed to restart Explorer (manual restart recommended)"
            return $false
        }
    }
    else {
        Write-Info "Explorer restart skipped (manual restart later)"
        return $true
    }
}

# ============================================================================
# Performance Mode (for gaming)
# ============================================================================

function Set-PerformanceMode {
    Write-Host ""
    Write-Host "PERFORMANCE MODE: Disabling animations for maximum FPS" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $path = "HKCU:\Control Panel\Desktop"
        # Disable animations
        $prefs = [byte[]](144, 18, 3, 128, 16, 0, 0, 0)
        Set-ItemProperty -Path $path -Name "UserPreferencesMask" -Value $prefs -Force
        Write-OK "Animations disabled (performance mode)"
    }
    catch { }
    
    try {
        $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path $path -Name "EnableTransparency" -Value 0 -Type DWord -Force
        Write-OK "Transparency disabled"
    }
    catch { }
}

# ============================================================================
# Main Execution
# ============================================================================

# Clear screen
Clear-Host

# Header
Write-Header "Windows 11 Animation Fix v$SCRIPT_VERSION"
Write-Host "  Animation & Visual Effects Optimizer" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges (optional but recommended)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warn "Running without administrator privileges (some settings may fail)"
    Write-Host ""
}

# Show current settings
Write-Header "Current Settings"
Get-CurrentAnimationSettings

# Menu
Write-Host "Select Action:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1] Enable All Animations (Recommended)" -ForegroundColor White
Write-Host "  [2] Fix Animation Stuttering" -ForegroundColor White
Write-Host "  [3] Performance Mode (Disable Animations for Gaming)" -ForegroundColor White
Write-Host "  [4] Reset to Windows Defaults" -ForegroundColor White
Write-Host "  [0] Exit" -ForegroundColor Red
Write-Host ""

$choice = Read-Host "Enter choice (0-4)"

$results = @{}

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Header "Enabling All Animations"
        
        $results = @{
            Animations = Enable-WindowAnimations
            Transparency = Enable-TransparencyEffects
            SmoothScroll = Enable-SmoothScrolling
            FadeEffects = Enable-FadeEffects
            ShadowEffects = Enable-ShadowEffects
            FontSmoothing = Enable-FontSmoothing
            StutteringFix = Fix-AnimationStuttering
            Apply = Restart-Explorer
        }
    }
    
    "2" {
        Write-Host ""
        Write-Header "Fixing Animation Stuttering"
        
        $results = @{
            StutteringFix = Fix-AnimationStuttering
            GPUOptimize = Fix-AnimationStuttering
            Apply = Restart-Explorer
        }
    }
    
    "3" {
        Write-Host ""
        Write-Header "Performance Mode"
        Set-PerformanceMode
        $results = @{ PerformanceMode = $true }
    }
    
    "4" {
        Write-Host ""
        Write-Header "Resetting to Windows Defaults"
        
        try {
            $path = "HKCU:\Control Panel\Desktop"
            $defaultPrefs = [byte[]](158, 18, 3, 128, 16, 0, 0, 0)
            Set-ItemProperty -Path $path -Name "UserPreferencesMask" -Value $defaultPrefs -Force
            Write-OK "Visual effects reset to default"
        }
        catch { }
        
        try {
            $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            Set-ItemProperty -Path $path -Name "EnableTransparency" -Value 1 -Type DWord -Force
            Write-OK "Transparency reset to default"
        }
        catch { }
        
        $results = @{ Reset = $true; Apply = Restart-Explorer }
    }
    
    "0" {
        Write-Host ""
        Write-Host "Exiting..." -ForegroundColor Gray
        exit 0
    }
    
    default {
        Write-Host ""
        Write-Host "Invalid option!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Summary
if ($results.Count -gt 0) {
    Write-Host ""
    Write-Header "Summary"
    
    $successCount = ($results.Values | Where-Object { $_ -eq $true }).Count
    $totalCount = $results.Count
    
    Write-Host ""
    Write-Host "  Operations: $totalCount" -ForegroundColor Cyan
    Write-Host "  Successful: $successCount" -ForegroundColor Green
    
    if ($successCount -eq $totalCount) {
        Write-Host ""
        Write-Host "  ALL OPERATIONS COMPLETED SUCCESSFULLY" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Animation Fix Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    if ($choice -eq "1" -or $choice -eq "4") {
        Write-Host "Tips:" -ForegroundColor Cyan
        Write-Host "  - If animations still seem off, sign out and sign back in" -ForegroundColor Gray
        Write-Host "  - For best results, restart your computer" -ForegroundColor Gray
        Write-Host "  - Update GPU drivers for optimal animation performance" -ForegroundColor Gray
        Write-Host ""
    }
}

Read-Host "Press Enter to exit"
