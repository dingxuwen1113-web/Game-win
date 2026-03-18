# Protected Windows 11 Features

**Windows 11 精简脚本套件 - 受保护功能列表**

---

## 🛡️ 永远保留的功能

以下功能在优化过程中**受到保护，不会被删除或禁用**：

### 1. Windows Terminal ⭐

**保护级别:** 完全保护

**保留内容:**
- ✅ `Microsoft.WindowsTerminal` - Windows Terminal
- ✅ `Microsoft.WindowsTerminal.Preview` - Terminal Preview
- ✅ `Microsoft.Windows.PowerShell.ISE` - PowerShell ISE
- ✅ PowerShell 5.1/7.x 核心功能
- ✅ Command Prompt (cmd.exe)
- ✅ Windows Subsystem for Linux (WSL)

**原因:** Windows Terminal 是开发者和高级用户的核心工具

---

### 2. Microsoft Edge 浏览器

**保护级别:** 完全保护

**保留内容:**
- ✅ `Microsoft.MicrosoftEdge` - Edge 浏览器主程序
- ✅ Edge WebView2 组件
- ✅ Edge 更新服务

**原因:** 系统默认浏览器，许多系统功能依赖 Edge WebView2

---

### 3. Microsoft Store

**保护级别:** 完全保护

**保留内容:**
- ✅ `Microsoft.WindowsStore` - Microsoft Store
- ✅ `Microsoft.StorePurchaseApp` - Store 购买应用

**原因:** 应用商店是安装和更新现代应用的主要途径

---

### 4. 核心系统应用

**保护级别:** 完全保护

| 应用 | 包名 | 用途 |
|------|------|------|
| 照片 | `Microsoft.Photos` | 图片查看和编辑 |
| 计算器 | `Microsoft.Calculator` | 系统计算器 |
| 记事本 | `Microsoft.Notepad` | 文本编辑器 |
| 画图 | `Microsoft.Paint` | 图像编辑 |
| 截图工具 | `Microsoft.ScreenSketch` | 截图和标注 |

---

### 5. 系统关键组件

**保护级别:** 绝对保护（无法删除）

| 组件 | 用途 |
|------|------|
| `Microsoft.UI.Xaml` | UI 框架依赖 |
| `Microsoft.AAD` | Azure Active Directory |
| `Microsoft.AccountsControl` | 账户控制 |
| `Microsoft.Windows.ShellExperienceHost` | 任务栏和开始菜单 |
| `Microsoft.Windows.SecHealthUI` | Windows 安全中心 |

---

## ⚙️ 可选禁用的服务

以下服务**可以被禁用**，但不会影响 Windows Terminal：

### 安全禁用的服务

| 服务 | 影响 | 可恢复 |
|------|------|--------|
| DiagTrack | 禁用遥测 | ✅ 是 |
| dmwappushservice | WAP 推送 | ✅ 是 |
| RemoteRegistry | 远程注册表 | ✅ 是 |
| RetailDemo | 零售演示 | ✅ 是 |
| MapsBroker | 离线地图 | ✅ 是 |
| PhoneSvc | 电话服务 | ✅ 是 |
| Fax | 传真服务 | ✅ 是 |
| InsiderSvc | Windows Insider | ✅ 是 |

### 谨慎禁用的服务

| 服务 | 影响 | 建议 |
|------|------|------|
| XblAuthManager | Xbox 认证 | 游戏玩家保留 |
| XblGameSave | Xbox 游戏保存 | 游戏玩家保留 |
| XboxNetApiSvc | Xbox 网络 | 游戏玩家保留 |
| WSearch | Windows 搜索 | HDD 用户保留 |
| SysMain | 预读取 | HDD 用户保留 |

---

## 🔧 如何验证保护状态

### 检查 Windows Terminal 是否受保护

```powershell
# 查看已安装的 Terminal 相关应用
Get-AppxPackage | Where-Object { $_.Name -like "*Terminal*" -or $_.Name -like "*PowerShell*" }

# 应该看到:
# Microsoft.WindowsTerminal
# Microsoft.Windows.PowerShell.ISE
```

### 检查服务状态

```powershell
# 查看关键服务状态
Get-Service | Where-Object { $_.Name -like "*TermService*" -or $_.Name -like "*PowerShell*" }
```

---

## 📋 优化前后对比

| 功能 | 优化前 | 优化后 | 状态 |
|------|--------|--------|------|
| Windows Terminal | ✅ | ✅ | 保留 |
| PowerShell | ✅ | ✅ | 保留 |
| Command Prompt | ✅ | ✅ | 保留 |
| Microsoft Store | ✅ | ✅ | 保留 |
| Edge 浏览器 | ✅ | ✅ | 保留 |
| 照片应用 | ✅ | ✅ | 保留 |
| 计算器 | ✅ | ✅ | 保留 |
| 记事本 | ✅ | ✅ | 保留 |
| 画图 | ✅ | ✅ | 保留 |
| Xbox 服务 | ✅ | ⚠️ 手动 | 可选 |
| Windows 搜索 | ✅ | ⚠️ 手动 | 可选 |

---

## ⚠️ 注意事项

### 不要手动删除的文件

**系统目录:**
- `C:\Windows\System32\WindowsPowerShell\` - PowerShell 核心
- `C:\Windows\System32\WindowsTerminal\` - Terminal 文件
- `C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_*` - Terminal 应用

**注册表项:**
- `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\` - 应用包信息

---

## 🔄 恢复已删除的功能

如果意外删除了受保护的功能：

### 恢复 Windows Terminal

```powershell
# 从 Microsoft Store 重新安装
# 或运行:
Get-AppxPackage -AllUsers Microsoft.WindowsTerminal | Foreach {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}
```

### 恢复 PowerShell ISE

```powershell
# Windows 功能中启用
Enable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellISE
```

---

## 📞 支持

如遇到功能丢失问题：

1. 查看 `TROUBLESHOOTING.md`
2. 运行 `.\05-Restore.ps1` 恢复系统设置
3. 运行 `.\04-SystemHealth.ps1` 检查系统状态

---

**最后更新:** 2026-03-15  
**文档版本:** 1.0.0
