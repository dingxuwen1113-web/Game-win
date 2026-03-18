# Windows 11 精简脚本套件 v5.2.0

**Windows 11 Optimization Suite** - 一站式系统优化解决方案

---

## 📦 版本信息

- **当前版本:** 5.2.0 (创作者版)
- **发布日期:** 2026-03-18
- **系统要求:** Windows 11 (21H2 或更高版本)
- **权限要求:** 管理员权限

---

## 👤 创作者与开发者

- **创作者:** 丁旭文
- **开发者:** 丁旭文
- **邮箱:** dxw2005@petalmail.com

---

## 🚀 快速开始

### 一键执行（推荐）

```cmd
# 右键点击 - 以管理员身份运行
.\00-RunAll.bat
```

**预计耗时:** 15-20 分钟  
**需要重启:** 是

### 游戏模式（每次游戏前运行）

```cmd
# 智能游戏模式 - 自动检测 GPU
.\03-GameOptimize.ps1
```

**预计耗时:** 30 秒（快速模式）  
**需要重启:** 否

### 动画效果修复

```cmd
# 修复 Windows 11 动画效果
.\12-FixAnimationAuto.ps1
```

**预计耗时:** 1 分钟  
**需要重启:** Explorer（会提示）

---

## 📋 脚本清单

### 核心脚本

| 序号 | 脚本 | 版本 | 功能 | 必需 |
|------|------|------|------|------|
| 00 | `00-RunAll.bat` | 4.0.0 | 一键执行所有优化 | ✅ |
| 01 | `01-CleanApps.ps1` | 2.0.0 | 移除预装应用（Bloatware） | ✅ |
| 02 | `02-DisableServices.ps1` | 2.0.0 | 禁用不必要的服务 | ✅ |
| 03 | `03-GameOptimize.ps1` | 4.0.0 | **游戏性能优化（合并版）** ⭐ | ✅ |
| 04 | `04-NetworkOptimize.ps1` | 2.0.0 | 网络优化 | ✅ |
| 05 | `05-NetworkSecurity.ps1` | 2.0.0 | 网络安全加固 | ✅ |
| 06 | `06-SystemHealth.ps1` | 1.0.0 | 系统健康检查 | ❌ |
| 07 | `07-MicrosoftAccount.ps1` | 2.0.0 | 微软账户权限最大化 | ❌ |
| 09 | `09-Restore.ps1` | 1.0.0 | 恢复系统设置 | ❌ |
| 10 | `10-FixRegistryPermissions.ps1` | 1.0.0 | 修复注册表权限 | ❌ |
| 11 | `11-SetWallpaper.ps1` | 1.0.0 | 设置壁纸 | ❌ |
| 12 | `12-FixAnimation.ps1` | 1.0.0 | **修复动画效果** ⭐ | ❌ |
| 12a | `12-FixAnimationAuto.ps1` | 1.0.0 | **动画修复（自动模式）** ⭐ | ❌ |
| 13 | `13-StorageOptimize.ps1` | 1.0.0 | **存储优化（SSD/清理）** ⭐ NEW | ❌ |
| 14 | `14-PrivacyOptimize.ps1` | 1.0.0 | **隐私优化（遥测禁用）** ⭐ NEW | ❌ |
| 15 | `15-StartupOptimize.ps1` | 1.0.0 | **启动项优化（加速开机）** ⭐ NEW | ❌ |
| 16 | `16-UpdateOptimize.ps1` | 1.0.0 | **Windows Update 管理** ⭐ NEW | ❌ |

⭐ = v4.0.0 新增/重构

### 工具脚本（utils/ 目录）

| 脚本 | 功能 | 使用场景 |
|------|------|---------|
| `utils/GamingTools.ps1` | 游戏工具菜单 | 游戏遇到问题时 |
| `utils/GameMemoryOptimize.ps1` | 游戏内存优化 | 内存不足时 |
| `utils/ValidateScripts.ps1` | 脚本语法验证 | 开发/调试时 |

---

## 🎮 v4.0.0 新特性

### 1. 重构合并（性能提升 28%）

**合并的脚本:**
- `03-GameOptimize.ps1` ← 03 + 03b + 03c + 03e
- 统一日志格式（Logger.ps1）
- 统一错误处理
- 统一命令行参数

**优势:**
- 减少功能重复
- 执行时间从 25 分钟降至 18 分钟
- 代码量减少 31%
- 更易维护

---

### 2. 动画效果修复（新增）

**`12-FixAnimation.ps1` - 交互式动画修复**

**功能:**
- ✅ 启用窗口动画
- ✅ 启用透明度效果
- ✅ 启用平滑滚动
- ✅ 启用阴影效果
- ✅ 配置 ClearType 字体
- ✅ 修复动画卡顿
- ✅ GPU 性能模式

**使用方式:**
```powershell
# 交互式（推荐）
.\12-FixAnimation.ps1

# 自动模式（无需交互）
.\12-FixAnimationAuto.ps1
```

**适用场景:**
- 动画效果消失
- 动画卡顿/掉帧
- 透明度不显示
- 滚动不平滑
- 游戏后恢复动画

---

### 3. 快速游戏模式

**`03-GameOptimize.ps1 -QuickMode`**

**30 秒快速优化:**
- 启用 HAGS
- 启用游戏模式
- 激活高性能电源
- 清理待命内存
- 优化网络延迟

**使用方式:**
```powershell
# 快速模式（游戏前）
.\03-GameOptimize.ps1 -QuickMode

# 完整模式（首次设置）
.\03-GameOptimize.ps1
```

---

## 📊 执行顺序（重构后）

### 一键执行
```cmd
.\00-RunAll.bat
```

### 手动执行顺序
```powershell
# 阶段 1: 系统清理
.\01-CleanApps.ps1
.\02-DisableServices.ps1

# 阶段 2: 性能优化
.\03-GameOptimize.ps1
.\04-NetworkOptimize.ps1

# 阶段 3: 安全加固
.\05-NetworkSecurity.ps1

# 阶段 4: 系统检查
.\06-SystemHealth.ps1

# 阶段 5: 可选操作
.\07-MicrosoftAccount.ps1  # 谨慎使用
.\12-FixAnimationAuto.ps1  # 修复动画
.\11-SetWallpaper.ps1

# 重启
shutdown /r /t 0
```

---

## 🎯 使用场景

### 场景 1: 首次优化系统
```cmd
.\00-RunAll.bat
```
**耗时:** 15-20 分钟 | **重启:** 是

---

### 场景 2: 游戏前快速优化
```powershell
.\03-GameOptimize.ps1 -QuickMode
```
**耗时:** 30 秒 | **重启:** 否

---

### 场景 3: 修复动画效果
```powershell
.\12-FixAnimationAuto.ps1
```
**耗时:** 1 分钟 | **重启:** Explorer（会提示）

---

### 场景 4: 系统健康检查
```powershell
.\06-SystemHealth.ps1
```
**耗时:** 2 分钟 | **重启:** 否

---

### 场景 5: 游戏工具（按需）
```powershell
.\utils\GamingTools.ps1
```
**耗时:** 按需 | **重启:** 否

---

## 🛡️ 受保护的功能

以下功能**永远不会被删除或禁用**:

| 功能 | 保护级别 | 说明 |
|------|----------|------|
| **Windows Terminal** | 🔒 完全保护 | 包括 Terminal、PowerShell、ISE |
| Microsoft Store | 🔒 完全保护 | 应用商店和购买功能 |
| Microsoft Edge | 🔒 完全保护 | 默认浏览器和 WebView2 |
| 核心系统应用 | 🔒 完全保护 | 照片、计算器、记事本、画图 |
| 系统关键组件 | 🔒 绝对保护 | UI 框架、账户控制、安全中心 |

详见：`PROTECTED_FEATURES.md`

---

## ⚠️ 注意事项

### 使用前

1. **创建系统还原点** - 脚本会自动创建，但建议手动备份重要数据
2. **在虚拟机中测试** - 首次使用建议在 VM 中测试
3. **确保电源稳定** - 优化过程中不要断电

### 使用后

1. **必须重启系统** - 所有优化需要重启才能完全生效
2. **检查功能正常** - 确认常用功能正常
3. **更新驱动程序** - 建议更新显卡、网卡驱动

### 风险提示

- **`07-MicrosoftAccount.ps1`** - 授予极高权限，请谨慎使用
- **动画修复** - 游戏时建议禁用动画以提升 FPS

---

## 🔧 故障排除

### 动画效果问题

**问题:** 动画卡顿/消失

**解决:**
```powershell
# 运行动画修复
.\12-FixAnimationAuto.ps1

# 重启 Explorer
Stop-Process -Name "explorer" -Force
```

### 游戏性能问题

**问题:** 游戏帧数低

**解决:**
```powershell
# 快速游戏优化
.\03-GameOptimize.ps1 -QuickMode

# 游戏工具菜单
.\utils\GamingTools.ps1
```

### PowerShell 执行策略阻止

**问题:** 提示执行策略错误

**解决:**
```powershell
# 临时允许执行
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 或永久允许（需要管理员权限）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

---

## 📚 相关文档

| 文档 | 说明 |
|------|------|
| `REFACTOR_PLAN.md` | v4.0.0 重构计划 |
| `ANIMATION_FIX_REPORT.md` | 动画修复报告 |
| `TROUBLESHOOTING.md` | 故障排除大全 |
| `QUICK_START.md` | 快速入门指南 |
| `QUICK_REFERENCE.md` | 快速参考卡 |
| `NETWORK_OPTIMIZATION.md` | 网络优化详解 |
| `NETWORK_SECURITY_GUIDE.md` | 网络安全详解 |
| `WALLPAPER_GUIDE.md` | 壁纸设置详解 |

---

## 📝 更新日志

### v5.2.0 (2026-03-18) - Creator Update

**新增:**
- ⭐ **创作者信息** - 在所有脚本中添加创作者和开发者信息
- ⭐ **联系方式** - 添加邮箱 dxw2005@petalmail.com
- ⭐ **文档更新** - README.md 新增创作者章节

**更新文件:**
- README.md - 新增创作者与开发者章节
- 00-RunAll.bat - 添加创作者信息
- 01-CleanApps.ps1 - 添加创作者信息
- 02-DisableServices.ps1 - 添加创作者信息
- 03-GameOptimize.ps1 - 添加创作者信息
- 04-NetworkOptimize.ps1 - 添加创作者信息
- 05-NetworkSecurity.ps1 - 添加创作者信息
- 06-SystemHealth.ps1 - 添加创作者信息
- 12-FixAnimationAuto.ps1 - 添加创作者信息
- Logger.ps1 - 添加创作者信息

### v5.1.0 (2026-03-18) - Complete Edition

**新增:**
- ⭐ **备份与恢复系统** - 17-BackupAndRestore.ps1
- ⭐ **快速部署场景** - 18-QuickDeploy.ps1
- ⭐ **系统性能测试** - utils/SystemBenchmark.ps1
- ⭐ **交互式菜单** - utils/SystemMenu.ps1 和 MENU.bat

### v5.0.0 (2026-03-15) - Extended Edition

**新增:**
- ⭐ **存储优化** - 13-StorageOptimize.ps1
- ⭐ **隐私优化** - 14-PrivacyOptimize.ps1
- ⭐ **启动项优化** - 15-StartupOptimize.ps1
- ⭐ **更新管理** - 16-UpdateOptimize.ps1

### v4.0.0 (2026-03-15) - Major Refactoring

**重构:**
- ⭐ **合并游戏优化脚本** - 03 + 03b + 03c + 03e → 03-GameOptimize.ps1
- ⭐ **统一日志系统** - Logger.ps1 模块
- ⭐ **重命名脚本** - 统一编号系统
- ⭐ **删除重复脚本** - 减少 45% 脚本数量

**新增:**
- ⭐ **动画效果修复** - 12-FixAnimation.ps1 / 12-FixAnimationAuto.ps1
- ⭐ **快速游戏模式** - 03-GameOptimize.ps1 -QuickMode
- ⭐ **utils/ 目录** - 可选工具脚本

**改进:**
- ✅ 执行时间从 25 分钟降至 18 分钟 (-28%)
- ✅ 代码量减少 31%
- ✅ 日志格式统一
- ✅ 错误处理改进
- ✅ 文档更新

### v3.0.0 (2026-03-15)

- 智能游戏模式
- 游戏工具菜单
- 系统健康检查

### v2.0.0 (2026-03-15)

- 一键游戏模式
- 微软账户权限最大化
- 激进显卡调度

### v1.0.0 (2026-03-14)

- 初始版本发布

---

## 💡 提示

### 日常使用

- **完整优化:** 每月运行一次 `.\00-RunAll.bat`
- **游戏前:** 每次游戏前运行 `.\03-GameOptimize.ps1 -QuickMode`
- **系统检查:** 每周运行一次 `.\06-SystemHealth.ps1`
- **动画修复:** 动画问题时运行 `.\12-FixAnimationAuto.ps1`

### 玩家推荐流程

```powershell
# 首次设置（一次性）
.\00-RunAll.bat

# 每次游戏前
.\03-GameOptimize.ps1 -QuickMode

# 每周检查
.\06-SystemHealth.ps1

# 遇到问题
.\utils\GamingTools.ps1

# 动画问题
.\12-FixAnimationAuto.ps1
```

---

## 📁 目录结构

```
精简脚本/
├── 00-RunAll.bat                  # 主执行脚本
├── 01-CleanApps.ps1               # 清理预装应用
├── 02-DisableServices.ps1         # 禁用服务
├── 03-GameOptimize.ps1            # 游戏优化（合并版）
├── 04-NetworkOptimize.ps1         # 网络优化
├── 05-NetworkSecurity.ps1         # 网络安全
├── 06-SystemHealth.ps1            # 系统健康检查
├── 07-MicrosoftAccount.ps1        # 账户权限
├── 09-Restore.ps1                 # 系统恢复
├── 10-FixRegistryPermissions.ps1  # 修复注册表权限
├── 11-SetWallpaper.ps1            # 设置壁纸
├── 12-FixAnimation.ps1            # 动画修复（交互式）
├── 12-FixAnimationAuto.ps1        # 动画修复（自动）
├── 13-StorageOptimize.ps1         # 存储优化（SSD/清理）NEW
├── 14-PrivacyOptimize.ps1         # 隐私优化（遥测禁用）NEW
├── 15-StartupOptimize.ps1         # 启动项优化（加速开机）NEW
├── 16-UpdateOptimize.ps1          # Windows Update 管理 NEW
├── Logger.ps1                     # 日志模块
│
├── utils/                         # 工具脚本
│   ├── GamingTools.ps1            # 游戏工具菜单
│   ├── GameMemoryOptimize.ps1     # 内存优化
│   └── ValidateScripts.ps1        # 脚本验证
│
├── docs/                          # 文档
│   └── (各种指南)
│
└── logs/                          # 日志（自动创建）
```

---

**最后更新:** 2026-03-15  
**维护者:** Windows 11 Optimization Suite Team  
**重构者:** 小智

🎮 **Happy Gaming!** 🎮
