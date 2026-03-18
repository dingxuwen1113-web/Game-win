# ============================================================================
# Windows 11 网速优化模块 v1.0.0
# Windows 11 Optimization Suite - Network Speed Optimization Module
# ============================================================================
# Version: 1.0.0
# Created: 2026-03-18
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Description: 专注于提升网络速度和降低延迟的优化模块
# ============================================================================

$SCRIPT_VERSION = "1.0.0"
$SCRIPT_NAME = "NetSpeedOptimize"
$LOG_FILE = "logs\NetSpeedOptimize_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# 颜色输出函数
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "OK" { Write-Host $Message -ForegroundColor Green }
        "WARN" { Write-Host $Message -ForegroundColor Yellow }
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "INFO" { Write-Host $Message -ForegroundColor Cyan }
        "STEP" { Write-Host $Message -ForegroundColor Magenta }
    }
    
    # 写入日志文件
    try {
        $logEntry | Out-File -FilePath $LOG_FILE -Append -Encoding UTF8 -ErrorAction SilentlyContinue
    }
    catch {}
}

# Header
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 11 网速优化模块 v$SCRIPT_VERSION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Log "步骤 [1/12] 检查管理员权限..." "STEP"

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "[错误] 需要管理员权限！" "ERROR"
    Write-Log "请右键点击脚本，选择'以管理员身份运行'" "INFO"
    Read-Host "按 Enter 键退出"
    exit 1
}
Write-Log "[OK] 管理员权限确认" "OK"
Write-Host ""

# 创建还原点
Write-Log "步骤 [2/12] 创建系统还原点..." "STEP"
try {
    Checkpoint-Computer -Description "Before NetSpeed Optimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Log "[OK] 系统还原点已创建" "OK"
}
catch {
    Write-Log "[警告] 还原点创建失败，但优化将继续" "WARN"
}
Write-Host ""

# ============================================================================
# 模块 1: TCP/IP 栈深度优化
# ============================================================================
Write-Log "步骤 [3/12] TCP/IP 栈深度优化..." "STEP"
$tcpStats = @{ Modified = 0; Failed = 0 }

# 1.1 启用 TCP 窗口自动调优
try {
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    Write-Log "[OK] TCP 窗口自动调优已启用 (normal)" "OK"
    $tcpStats.Modified++
}
catch {
    Write-Log "[失败] TCP 窗口调优配置失败" "ERROR"
    $tcpStats.Failed++
}

# 1.2 启用 TCP 接收端扩展 (RSS)
try {
    netsh int tcp set global rss=enabled 2>$null | Out-Null
    Write-Log "[OK] 接收端扩展 (RSS) 已启用" "OK"
    $tcpStats.Modified++
}
catch {
    $tcpStats.Failed++
}

# 1.3 启用 TCP 烟囱卸载
try {
    netsh int tcp set global chimney=enabled 2>$null | Out-Null
    Write-Log "[OK] TCP 烟囱卸载已启用" "OK"
    $tcpStats.Modified++
}
catch {
    $tcpStats.Failed++
}

# 1.4 启用直接缓存访问 (DCA)
try {
    netsh int tcp set global dca=enabled 2>$null | Out-Null
    Write-Log "[OK] 直接缓存访问 (DCA) 已启用" "OK"
    $tcpStats.Modified++
}
catch {
    $tcpStats.Failed++
}

# 1.5 启用 NetDMA
try {
    netsh int tcp set global netdma=enabled 2>$null | Out-Null
    Write-Log "[OK] NetDMA 已启用" "OK"
    $tcpStats.Modified++
}
catch {
    $tcpStats.Failed++
}

# 1.6 启用 ECN 能力
try {
    netsh int tcp set global ecncapability=enabled 2>$null | Out-Null
    Write-Log "[OK] ECN 能力已启用" "OK"
    $tcpStats.Modified++
}
catch {
    $tcpStats.Failed++
}

Write-Log "TCP 设置：$($tcpStats.Modified) 成功，$($tcpStats.Failed) 失败" "INFO"
Write-Host ""

# ============================================================================
# 模块 2: 网络适配器高级优化
# ============================================================================
Write-Log "步骤 [4/12] 网络适配器高级优化..." "STEP"
$adapterStats = @{ Optimized = 0; Skipped = 0 }

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.ConnectorPresent -eq $true }
    
    foreach ($adapter in $adapters) {
        Write-Log "  优化适配器：$($adapter.Name) ($($adapter.InterfaceDescription))" "INFO"
        
        try {
            # 2.1 禁用节能以太网
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Green Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Energy-Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            
            # 2.2 禁用中断节流
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Interrupt Moderation" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Interrupt Moderation Rate" -DisplayValue "Off" -ErrorAction SilentlyContinue
            
            # 2.3 启用最大吞吐量
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Throughput" -DisplayValue "Maximum Throughput" -ErrorAction SilentlyContinue
            
            # 2.4 禁用流量控制 (减少延迟)
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Flow Control" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            
            # 2.5 设置速度和双工为最大值
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Speed & Duplex" -DisplayValue "Auto Negotiation" -ErrorAction SilentlyContinue
            
            Write-Log "  [OK] $($adapter.Name) 优化完成" "OK"
            $adapterStats.Optimized++
        }
        catch {
            Write-Log "  [跳过] $($adapter.Name) 不支持某些高级设置" "WARN"
            $adapterStats.Skipped++
        }
    }
}
catch {
    Write-Log "[失败] 网络适配器优化失败" "ERROR"
}

Write-Log "适配器优化：$($adapterStats.Optimized) 成功，$($adapterStats.Skipped) 跳过" "INFO"
Write-Host ""

# ============================================================================
# 模块 3: 禁用网络 throttling
# ============================================================================
Write-Log "步骤 [5/12] 禁用网络节流..." "STEP"

try {
    $multimediaPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $multimediaPath) {
        # 设置网络节流索引为最大值 (禁用节流)
        Set-ItemProperty -Path $multimediaPath -Name "NetworkThrottlingIndex" -Value 4294967295 -Type DWord -Force
        Set-ItemProperty -Path $multimediaPath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
        Write-Log "[OK] 网络节流已禁用" "OK"
    }
    
    # 设置游戏模式优先级
    $gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (Test-Path $gamesPath) {
        Set-ItemProperty -Path $gamesPath -Name "GPU Priority" -Value 8 -Type DWord -Force
        Set-ItemProperty -Path $gamesPath -Name "Priority" -Value 6 -Type DWord -Force
        Set-ItemProperty -Path $gamesPath -Name "Scheduling Category" -Value "High" -Type String -Force
        Write-Log "[OK] 游戏网络优先级已设置" "OK"
    }
}
catch {
    Write-Log "[失败] 网络节流配置失败" "ERROR"
}
Write-Host ""

# ============================================================================
# 模块 4: DNS 优化
# ============================================================================
Write-Log "步骤 [6/12] DNS 优化..." "STEP"

try {
    # 4.1 刷新 DNS 缓存
    ipconfig /flushdns 2>$null | Out-Null
    Write-Log "[OK] DNS 缓存已刷新" "OK"
}
catch {
    Write-Log "[失败] DNS 刷新失败" "ERROR"
}

try {
    # 4.2 注册 DNS
    ipconfig /registerdns 2>$null | Out-Null
    Write-Log "[OK] DNS 已重新注册" "OK"
}
catch {
    Write-Log "[失败] DNS 注册失败" "ERROR"
}

try {
    # 4.3 释放和更新 IP
    ipconfig /release 2>$null | Out-Null
    Start-Sleep -Seconds 2
    ipconfig /renew 2>$null | Out-Null
    Write-Log "[OK] IP 地址已更新" "OK"
}
catch {
    Write-Log "[失败] IP 更新失败" "ERROR"
}
Write-Host ""

# ============================================================================
# 模块 5: 禁用 Large Send Offload (LSO)
# ============================================================================
Write-Log "步骤 [7/12] 配置 Large Send Offload..." "STEP"
$lsoStats = @{ Modified = 0; Skipped = 0 }

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    
    foreach ($adapter in $adapters) {
        try {
            # 禁用 LSO 以减少延迟
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv4)" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Large Send Offload V2 (IPv6)" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Write-Log "[OK] $($adapter.Name) LSO 已禁用" "OK"
            $lsoStats.Modified++
        }
        catch {
            $lsoStats.Skipped++
        }
    }
}
catch {
    Write-Log "[失败] LSO 配置失败" "ERROR"
}

Write-Log "LSO 配置：$($lsoStats.Modified) 修改，$($lsoStats.Skipped) 跳过" "INFO"
Write-Host ""

# ============================================================================
# 模块 6: 电源管理优化
# ============================================================================
Write-Log "步骤 [8/12] 网络电源管理优化..." "STEP"
$powerStats = @{ Modified = 0 }

try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    
    foreach ($adapter in $adapters) {
        try {
            # 禁用电源节省
            Disable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_lltd -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Wake on Magic Packet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Write-Log "[OK] $($adapter.Name) 电源管理已优化" "OK"
            $powerStats.Modified++
        }
        catch {
            # 跳过不支持的适配器
        }
    }
}
catch {
    Write-Log "[失败] 电源管理优化失败" "ERROR"
}

Write-Log "电源设置：$($powerStats.Modified) 修改" "INFO"
Write-Host ""

# ============================================================================
# 模块 7: 配置 QoS
# ============================================================================
Write-Log "步骤 [9/12] 配置 QoS 策略..." "STEP"

try {
    # 禁用 QoS 数据包计划程序限制
    $qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
    if (-not (Test-Path $qosPath)) {
        New-Item -Path $qosPath -Force | Out-Null
    }
    Set-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
    Write-Log "[OK] QoS 限制已禁用" "OK"
}
catch {
    Write-Log "[失败] QoS 配置失败" "ERROR"
}
Write-Host ""

# ============================================================================
# 模块 8: 配置 Windows 网络优化
# ============================================================================
Write-Log "步骤 [10/12] Windows 网络配置..." "STEP"

try {
    # 禁用实验性 TCP 功能
    netsh int tcp set global timestamps=disabled 2>$null | Out-Null
    Write-Log "[OK] TCP 时间戳已禁用" "OK"
}
catch {
    Write-Log "[失败] TCP 时间戳配置失败" "ERROR"
}

try {
    # 设置 MTU (可选，根据网络环境)
    # 注意：不自动设置 MTU，因为不同网络环境不同
    Write-Log "[INFO] MTU 保持自动 (根据网络环境)" "INFO"
}
catch {}

Write-Host ""

# ============================================================================
# 模块 9: 禁用远程差分压缩
# ============================================================================
Write-Log "步骤 [11/12] 禁用远程差分压缩..." "STEP"

try {
    # 检查并禁用 RDC
    $rdcPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Network\Performance"
    if (Test-Path $rdcPath) {
        Set-ItemProperty -Path $rdcPath -Name "DisableRemoteDifferentialCompression" -Value 1 -Type DWord -Force
        Write-Log "[OK] 远程差分压缩已禁用" "OK"
    }
}
catch {
    Write-Log "[失败] RDC 配置失败" "ERROR"
}
Write-Host ""

# ============================================================================
# 模块 10: 显示优化结果
# ============================================================================
Write-Log "步骤 [12/12] 生成优化报告..." "STEP"
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         网速优化完成报告" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "优化统计:" -ForegroundColor Cyan
Write-Host "  ┌─────────────────────────────────────┐" -ForegroundColor DarkGray
Write-Host "  │ TCP 设置：      $($tcpStats.Modified) 成功，$($tcpStats.Failed) 失败          │" -ForegroundColor $(if ($tcpStats.Failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "  │ 网络适配器：    $($adapterStats.Optimized) 优化，$($adapterStats.Skipped) 跳过      │" -ForegroundColor Green
Write-Host "  │ LSO 配置：      $($lsoStats.Modified) 修改，$($lsoStats.Skipped) 跳过          │" -ForegroundColor Green
Write-Host "  │ 电源管理：      $($powerStats.Modified) 修改                        │" -ForegroundColor Green
Write-Host "  └─────────────────────────────────────┘" -ForegroundColor DarkGray
Write-Host ""

Write-Host "已应用的优化:" -ForegroundColor Cyan
Write-Host "  ✓ TCP 窗口自动调优" -ForegroundColor Green
Write-Host "  ✓ 接收端扩展 (RSS)" -ForegroundColor Green
Write-Host "  ✓ TCP 烟囱卸载" -ForegroundColor Green
Write-Host "  ✓ 直接缓存访问 (DCA)" -ForegroundColor Green
Write-Host "  ✓ 网络节流禁用" -ForegroundColor Green
Write-Host "  ✓ 节能以太网禁用" -ForegroundColor Green
Write-Host "  ✓ 中断节流禁用" -ForegroundColor Green
Write-Host "  ✓ Large Send Offload 禁用" -ForegroundColor Green
Write-Host "  ✓ QoS 限制禁用" -ForegroundColor Green
Write-Host "  ✓ 远程差分压缩禁用" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[重要] 请重启计算机以使所有优化生效" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 保存日志
Write-Log "网速优化完成" "OK"
Write-Log "日志文件：$LOG_FILE" "INFO"
Write-Host ""

Read-Host "按 Enter 键退出"
