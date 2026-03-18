# Windows 11 网速优化模块 v1.0.0

## 概述

网速优化模块是 Windows 11 优化套件的核心组件之一，专注于提升网络速度和降低延迟。

## 功能特性

### 1. TCP/IP 栈深度优化
- **TCP 窗口自动调优**: 自动调整 TCP 接收窗口大小以优化吞吐量
- **接收端扩展 (RSS)**: 允许多个 CPU 核心处理网络流量
- **TCP 烟囱卸载**: 将 TCP 处理卸载到网卡，减少 CPU 占用
- **直接缓存访问 (DCA)**: 直接将数据传送到 CPU 缓存
- **NetDMA**: 使用 DMA 引擎进行内存传输
- **ECN 能力**: 启用显式拥塞通知

### 2. 网络适配器高级优化
- 禁用节能以太网（减少延迟）
- 禁用中断节流（降低 CPU 延迟）
- 设置最大吞吐量模式
- 禁用流量控制（减少传输延迟）

### 3. 网络节流禁用
- 禁用 Windows 网络节流机制
- 设置游戏模式网络优先级
- 提升系统响应性

### 4. DNS 优化
- 刷新 DNS 缓存
- 重新注册 DNS
- 释放和更新 IP 地址

### 5. Large Send Offload 配置
- 禁用 LSO 以减少网络延迟
- 提升小包传输性能

### 6. 电源管理优化
- 禁用网络适配器电源节省
- 禁用 Wake on Magic Packet
- 禁用链路层拓扑发现

### 7. QoS 配置
- 禁用 QoS 数据包计划程序限制
- 移除带宽限制

### 8. 远程差分压缩禁用
- 禁用 RDC 以减少网络开销

## 使用方法

### 方法 1: 通过主菜单运行
```batch
# 运行 MENU.bat
MENU.bat

# 选择 [1] Core Optimizations
# 选择 [7] NetSpeed Optimization
```

### 方法 2: 直接运行
```batch
# 右键点击 - 以管理员身份运行
run-netspeed.bat
```

### 方法 3: PowerShell 直接运行
```powershell
# 以管理员身份打开 PowerShell
cd "C:\Users\Administrator\Desktop\精简脚本"
.\04-NetSpeedOptimize.ps1
```

## 执行步骤

脚本执行包含 12 个步骤：

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1 | 检查管理员权限 | 确保有足够权限 |
| 2 | 创建系统还原点 | 安全备份 |
| 3 | TCP/IP 栈优化 | 6 项 TCP 设置 |
| 4 | 网络适配器优化 | 高级属性配置 |
| 5 | 禁用网络节流 | 移除带宽限制 |
| 6 | DNS 优化 | 刷新和重新注册 |
| 7 | LSO 配置 | 禁用 Large Send Offload |
| 8 | 电源管理优化 | 禁用节能功能 |
| 9 | QoS 配置 | 禁用 QoS 限制 |
| 10 | Windows 网络配置 | 禁用 TCP 时间戳 |
| 11 | 禁用 RDC | 禁用远程差分压缩 |
| 12 | 生成优化报告 | 显示优化结果 |

## 预期效果

### 网速提升
- **下载速度**: 提升 5-15%
- **上传速度**: 提升 5-10%
- **网络延迟**: 降低 10-30ms

### 游戏体验
- **Ping 值**: 更稳定
- **网络卡顿**: 明显减少
- **多人游戏**: 更流畅

### 日常使用
- **网页加载**: 更快
- **视频缓冲**: 减少
- **文件传输**: 更稳定

## 注意事项

### 兼容性
- Windows 11 21H2 或更高版本
- 需要管理员权限
- 部分网卡可能不支持所有高级功能

### 功耗影响
禁用节能功能可能导致：
- 笔记本电脑电池续航略微减少
- 网卡功耗略微增加

### 恢复方法
如需恢复默认设置：
1. 使用系统还原点
2. 或手动重置网络：
```batch
netsh int ip reset
netsh winsock reset
ipconfig /flushdns
```

## 日志文件

优化日志保存在 `logs\NetSpeedOptimize_YYYYMMDD_HHMMSS.log`

## 故障排除

### 问题 1: 脚本无法运行
**解决**: 确保以管理员身份运行

### 问题 2: 某些设置不生效
**解决**: 需要重启计算机

### 问题 3: 网络适配器不支持某些功能
**解决**: 脚本会自动跳过不支持的功能

### 问题 4: 优化后网络变慢
**解决**: 
1. 使用系统还原点恢复
2. 或运行网络重置

## 技术参考

### 注册表修改
```
HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile
- NetworkThrottlingIndex: 4294967295 (禁用节流)
- SystemResponsiveness: 0 (最大响应性)

HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched
- NonBestEffortLimit: 0 (无限制)

HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Network\Performance
- DisableRemoteDifferentialCompression: 1 (禁用 RDC)
```

### Netsh 命令
```
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global rss=enabled
netsh int tcp set global chimney=enabled
netsh int tcp set global dca=enabled
netsh int tcp set global netdma=enabled
netsh int tcp set global ecncapability=enabled
```

## 版本历史

### v1.0.0 (2026-03-18)
- 初始版本
- 包含 12 项网络优化功能
- 完整的日志记录
- 详细的优化报告

## 相关文件

- `04-NetworkOptimize.ps1` - 基础网络优化
- `05-NetworkSecurity.ps1` - 网络安全优化
- `run-netspeed.bat` - 快速运行脚本
- `MENU.bat` - 主菜单

## 支持

如有问题，请查看：
- `TROUBLESHOOTING.md` - 故障排除指南
- `logs\` 目录 - 详细日志
