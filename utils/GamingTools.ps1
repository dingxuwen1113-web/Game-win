# ============================================================================
# Windows 11 Gaming Tools Menu v1.0.0
# Part of Windows 11 Optimization Suite
# ============================================================================
# Version: 1.0.0
# Updated: 2026-03-15
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: Interactive menu for gaming-related tools and utilities
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "GamingTools"

# ============================================================================
# Helper Functions
# ============================================================================

function Clear-Screen {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "         Windows 11 Gaming Tools Menu v$SCRIPT_VERSION            " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Menu {
    param([string[]]$Options)
    for ($i = 0; $i -lt $Options.Length; $i++) {
        $num = $i + 1
        Write-Host "  [$num] $($Options[$i])" -ForegroundColor White
    }
    Write-Host "  [0] Exit" -ForegroundColor Red
    Write-Host ""
}

function Write-Back {
    Write-Host ""
    Write-Host "Press any key to return to menu..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================================================
# Tool Functions
# ============================================================================

function Show-SystemInfo {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "              System Information                           " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $os = Get-WmiObject Win32_OperatingSystem
        $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
        $gpu = Get-WmiObject Win32_VideoController | Select-Object -First 1
        $totalRAM = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeRAM = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
        
        Write-Host "Operating System:" -ForegroundColor Yellow
        Write-Host "  $($os.Caption)" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "CPU:" -ForegroundColor Yellow
        Write-Host "  $($cpu.Name)" -ForegroundColor Gray
        Write-Host "  Cores: $($cpu.NumberOfCores) | Threads: $($cpu.NumberOfLogicalProcessors)" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "GPU:" -ForegroundColor Yellow
        Write-Host "  $($gpu.Name)" -ForegroundColor Gray
        Write-Host "  VRAM: $([Math]::Round($gpu.AdapterRAM / 1GB, 2)) GB" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "Memory:" -ForegroundColor Yellow
        Write-Host "  Total: $totalRAM GB | Free: $freeRAM GB" -ForegroundColor Gray
        Write-Host ""
    }
    catch {
        Write-Host "Error reading system information" -ForegroundColor Red
    }
    
    Write-Back
}

function Check-FPS {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "              FPS Monitoring Tips                          " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Built-in FPS Monitoring Options:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Xbox Game Bar (Windows + G)" -ForegroundColor Gray
    Write-Host "     - Press Windows + G during game" -ForegroundColor Gray
    Write-Host "     - Performance widget shows FPS" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. NVIDIA GeForce Experience (Alt + R)" -ForegroundColor Gray
    Write-Host "     - Press Alt + R during game" -ForegroundColor Gray
    Write-Host "     - Shows FPS, GPU, CPU usage" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. AMD Radeon Software (Ctrl + Shift + O)" -ForegroundColor Gray
    Write-Host "     - Press Ctrl + Shift + O" -ForegroundColor Gray
    Write-Host "     - Performance overlay" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  4. Steam Overlay (F12 for screenshots)" -ForegroundColor Gray
    Write-Host "     - Enable in Steam Settings > In-Game" -ForegroundColor Gray
    Write-Host "     - FPS counter available" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  5. Third-party tools:" -ForegroundColor Gray
    Write-Host "     - MSI Afterburner + RivaTuner" -ForegroundColor Gray
    Write-Host "     - FRAPS" -ForegroundColor Gray
    Write-Host "     - CapFrameX" -ForegroundColor Gray
    Write-Host ""
    
    Write-Back
}

function Optimize-GameFiles {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "              Game File Cleanup                            " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Cleaning temporary game files..." -ForegroundColor Yellow
    Write-Host ""
    
    $cleaned = 0
    
    try {
        if (Test-Path "$env:TEMP") {
            $files = Get-ChildItem -Path "$env:TEMP" -Recurse -ErrorAction SilentlyContinue
            $count = $files.Count
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] Cleaned Temp folder ($count files)" -ForegroundColor Green
            $cleaned += $count
        }
    }
    catch { }
    
    try {
        if (Test-Path "C:\Windows\Temp") {
            $files = Get-ChildItem -Path "C:\Windows\Temp" -Recurse -ErrorAction SilentlyContinue
            $count = $files.Count
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] Cleaned Windows Temp ($count files)" -ForegroundColor Green
            $cleaned += $count
        }
    }
    catch { }
    
    Write-Host ""
    Write-Host "Total files cleaned: $cleaned" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Back
}

function Test-Network {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "              Network Speed Test                           " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Testing connection to gaming servers..." -ForegroundColor Yellow
    Write-Host ""
    
    $servers = @(
        @{Name="Google DNS"; Host="8.8.8.8"},
        @{Name="Cloudflare"; Host="1.1.1.1"},
        @{Name="Xbox Live"; Host="xboxlive.com"},
        @{Name="Steam"; Host="steampowered.com"}
    )
    
    foreach ($server in $servers) {
        try {
            $ping = New-Object System.Net.NetworkInformation.Ping
            $reply = $ping.Send($server.Host, 1000)
            if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                Write-Host "  [OK] $($server.Name): $($reply.RoundtripTime) ms" -ForegroundColor Green
            } else {
                Write-Host "  [FAIL] $($server.Name): Failed" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "  [FAIL] $($server.Name): Error" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Latency Guide:" -ForegroundColor Cyan
    Write-Host "  < 20ms  - Excellent" -ForegroundColor Green
    Write-Host "  20-50ms - Good" -ForegroundColor Cyan
    Write-Host "  50-100ms - Fair" -ForegroundColor Yellow
    Write-Host "  > 100ms - Poor (lag expected)" -ForegroundColor Red
    Write-Host ""
    
    Write-Back
}

function Flush-DNS {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "              Flush DNS Cache                              " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Flushing DNS cache..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        ipconfig /flushdns 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        Write-Host ""
        Write-Host "[OK] DNS cache flushed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] Failed to flush DNS cache" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "This can help with:" -ForegroundColor Cyan
    Write-Host "  - Connection issues in games" -ForegroundColor Gray
    Write-Host "  - Slow DNS resolution" -ForegroundColor Gray
    Write-Host "  - Outdated DNS entries" -ForegroundColor Gray
    Write-Host ""
    
    Write-Back
}

function Check-Updates {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "              Check for Updates                            " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Checking for Windows updates..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0")
        
        if ($searchResult.Updates.Count -eq 0) {
            Write-Host "[OK] No pending updates!" -ForegroundColor Green
        } else {
            Write-Host "[WARN] $($searchResult.Updates.Count) updates available:" -ForegroundColor Yellow
            Write-Host ""
            foreach ($update in $searchResult.Updates | Select-Object -First 10) {
                Write-Host "  - $($update.Title)" -ForegroundColor Gray
            }
            if ($searchResult.Updates.Count -gt 10) {
                Write-Host "  ... and $($searchResult.Updates.Count - 10) more" -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Host "Unable to check for updates" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Tip: Keep GPU drivers updated for best gaming performance!" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Back
}

function Quick-Optimize {
    Clear-Host
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "              Quick Game Optimization                      " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Running quick optimizations..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $path = "HKCU:\SOFTWARE\Microsoft\GameBar"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        New-ItemProperty -Path $path -Name "AutoGameModeEnabled" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-Host "  [OK] Game Mode enabled" -ForegroundColor Green
    }
    catch { Write-Host "  [WARN] Game Mode config failed" -ForegroundColor Yellow }
    
    try {
        $emptyStandbyPath = "$env:SystemRoot\System32\EmptyStandbyList.exe"
        if (Test-Path $emptyStandbyPath) {
            Start-Process -FilePath $emptyStandbyPath -ArgumentList "standbyonly" -Wait -NoNewWindow -ErrorAction SilentlyContinue
            Write-Host "  [OK] Standby memory cleared" -ForegroundColor Green
        }
    }
    catch { }
    
    try {
        ipconfig /flushdns 2>$null | Out-Null
        Write-Host "  [OK] DNS cache flushed" -ForegroundColor Green
    }
    catch { }
    
    Write-Host ""
    Write-Host "Quick optimization complete!" -ForegroundColor Green
    Write-Host "Ready for gaming!" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Back
}

# ============================================================================
# Main Menu Loop
# ============================================================================

$running = $true

while ($running) {
    Clear-Screen
    
    Write-Host "Quick Actions:" -ForegroundColor Cyan
    Write-Host ""
    
    $options = @(
        "System Information",
        "FPS Monitoring Guide",
        "Clean Game Files",
        "Network Speed Test",
        "Flush DNS Cache",
        "Check for Updates",
        "Quick Game Optimization",
        "Run Full Game Mode (03c-GameMode.ps1)",
        "Run System Health Check (04-SystemHealth.ps1)"
    )
    
    Write-Menu $options
    
    $choice = Read-Host "Select an option (0-9)"
    
    switch ($choice) {
        "1" { Show-SystemInfo }
        "2" { Check-FPS }
        "3" { Optimize-GameFiles }
        "4" { Test-Network }
        "5" { Flush-DNS }
        "6" { Check-Updates }
        "7" { Quick-Optimize }
        "8" { 
            if (Test-Path ".\03c-GameMode.ps1") {
                powershell -ExecutionPolicy Bypass -File ".\03c-GameMode.ps1"
            } else {
                Write-Host "Script not found: 03c-GameMode.ps1" -ForegroundColor Red
                Write-Back
            }
        }
        "9" { 
            if (Test-Path ".\04-SystemHealth.ps1") {
                powershell -ExecutionPolicy Bypass -File ".\04-SystemHealth.ps1"
            } else {
                Write-Host "Script not found: 04-SystemHealth.ps1" -ForegroundColor Red
                Write-Back
            }
        }
        "0" { 
            $running = $false
            Clear-Host
        }
        default { 
            Write-Host "Invalid option!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

Write-Host "Goodbye! Happy Gaming!" -ForegroundColor Cyan
Write-Host ""
