# Windows 11 Optimization Suite - Version Info

## Current Version: 5.2.0

**Release Date:** 2026-03-18
**Edition:** Complete Edition

---

## Changelog

### v5.2.0 (2026-03-18) - Creator Update

**Breaking Changes:**
- None - Fully backward compatible with v5.1.0

**Creator & Developer Information:**
- ✅ Added creator name (丁旭文) to all scripts
- ✅ Added developer name (丁旭文) to all scripts
- ✅ Added contact email (dxw2005@petalmail.com) to all scripts
- ✅ Updated README.md with creator section
- ✅ Updated 00-RunAll.bat with creator info
- ✅ Updated Logger.ps1 with creator info

**Updated Files:**
- README.md - Added creator section
- 00-RunAll.bat - Added creator info in header
- 01-CleanApps.ps1 - Added creator info
- 02-DisableServices.ps1 - Added creator info
- 03-GameOptimize.ps1 - Added creator info
- 04-NetworkOptimize.ps1 - Added creator info
- 05-NetworkSecurity.ps1 - Added creator info
- 06-SystemHealth.ps1 - Added creator info
- 12-FixAnimationAuto.ps1 - Added creator info
- Logger.ps1 - Added creator info

---

### v5.1.0 (2026-03-18) - Complete Edition

**Breaking Changes:**
- None - Fully backward compatible with v2.0.0

**Protection Updates:**
- ✅ Windows Terminal is now explicitly protected from removal
- ✅ PowerShell and Terminal Preview added to whitelist
- ✅ Added PROTECTED_FEATURES.md documentation

**New Features:**

#### ⭐ Smart Game Mode (`03c-GameMode.ps1` v3.0.0)

Complete rewrite with intelligent features:

- **Auto GPU Detection**
  - Identifies NVIDIA, AMD, and Intel GPUs
  - Displays GPU vendor, VRAM, and driver version
  - Adapts optimization based on detected hardware

- **Smart HAGS Detection**
  - Automatically checks Hardware GPU Scheduling status
  - Only enables if not already active
  - Reports status clearly to user

- **Real-time Status Display**
  - Beautiful terminal UI with boxes and status indicators
  - Shows before/after optimization status
  - Color-coded success/warning/error messages

- **Health Scoring System**
  - 100-point health score
  - Star rating (★★★★★ to ★☆☆☆☆)
  - Detailed issue reporting

- **Enhanced Logging**
  - Unicode symbols (✓ ⚠ ✗ ℹ)
  - Step-by-step progress (1/10, 2/10, etc.)
  - Clear success/failure indicators

#### ⭐ Gaming Tools Menu (`03d-GamingTools.ps1` v1.0.0)

Interactive menu with 9 tools:

1. **System Information** - View detailed CPU/GPU/RAM specs
2. **FPS Monitoring Guide** - Learn how to monitor FPS in games
3. **Clean Game Files** - Remove temporary files and cache
4. **Network Speed Test** - Test latency to gaming servers
5. **Flush DNS Cache** - Fix connection issues
6. **Check for Updates** - Windows Update status
7. **Quick Game Optimization** - 30-second quick optimize
8. **Run Full Game Mode** - Launch 03c-GameMode.ps1
9. **Run System Health Check** - Launch 04-SystemHealth.ps1

#### ⭐ System Health Check (`04-SystemHealth.ps1` v1.0.0)

Comprehensive diagnostics:

- **10 Health Checks:**
  - CPU Status
  - Memory Health (with usage warnings)
  - Storage Health (disk space monitoring)
  - GPU Status
  - Windows Update Status
  - Running Processes
  - Network Status (ping tests)
  - System Temperature (if available)
  - Battery Status (laptops)
  - Optimization Status (HAGS, Game Mode, Power Plan)

- **Scoring System:**
  - 100-point scale
  - Deductions for issues found
  - Star rating display
  - Actionable recommendations

**Improvements:**

- ✅ Unified UI style across all scripts
- ✅ Better error handling with nested try-catch
- ✅ Improved user feedback
- ✅ Auto-hardware detection
- ✅ Modern terminal graphics (boxes, symbols)
- ✅ Color-coded status messages

**Bug Fixes:**
- Fixed ReadKey() compatibility issues (replaced with Read-Host)
- Fixed registry permission handling
- Improved GPU detection reliability
- Better handling of missing tools (EmptyStandbyList, etc.)

---

### v2.0.0 (2026-03-15) - Major Update

**Breaking Changes:**
- Removed ISO creation functionality (moved to separate tool)
- Removed ADK installation scripts

**New Features:**
- Added aggressive GPU scheduling script (`03b-GPUAggressive.ps1`)
- Added one-click game mode script (`03c-GameMode.ps1`)
- Added Microsoft account privilege elevation (`08-MicrosoftAccount.ps1`)
- Version tracking system

**Improvements:**
- Fixed registry permission issues in GPU optimization
- Replaced unreliable `ReadKey()` with `Read-Host`
- Consistent logging format across all scripts
- Better user feedback and status messages

**Bug Fixes:**
- Fixed PowerShell syntax errors in GPU scheduling script
- Fixed registry access permission handling
- Improved service optimization error recovery

---

### v1.0.0 (2026-03-14) - Initial Release

- Basic bloatware removal
- Service optimization
- Game performance tweaks
- Network optimization
- Memory optimization
- Wallpaper setting

---

## Scripts Overview

| Script | Version | Purpose | Category |
|--------|---------|---------|----------|
| `00-RunAll.bat` | 3.0.0 | Main execution orchestrator | Core |
| `01-CleanApps.ps1` | 2.0.0 | Bloatware removal | Core |
| `02-DisableServices.ps1` | 2.0.0 | Service optimization | Core |
| `03-GameOptimize.ps1` | 2.0.0 | Game performance | Gaming |
| `03b-GPUAggressive.ps1` | 2.0.0 | GPU scheduling | Gaming |
| `03c-GameMode.ps1` | 3.0.0 | Smart game mode | Gaming ⭐ |
| `03d-GamingTools.ps1` | 1.0.0 | Gaming tools menu | Gaming ⭐ |
| `04-SystemHealth.ps1` | 1.0.0 | System health check | Diagnostic ⭐ |
| `05-Restore.ps1` | 1.0.0 | System restore | Utility |
| `06-FixRegistryPermissions.ps1` | 1.0.0 | Registry permissions | Utility |
| `07-NetworkOptimize.ps1` | 2.0.0 | Network optimization | Network |
| `08-MicrosoftAccount.ps1` | 2.0.0 | MS Account privilege | Utility |
| `09-GameMemoryOptimize.ps1` | 2.0.0 | Memory optimization | Gaming |
| `10-NetworkSecurity.ps1` | 2.0.0 | Network security | Network |
| `11-SetWallpaper.ps1` | 1.0.0 | Wallpaper setting | Personalization |
| `12-SetWallpaperAuto.ps1` | 1.0.0 | Auto wallpaper | Personalization |

⭐ = New in v3.0.0

---

## Requirements

- Windows 11 (21H2 or later)
- Administrator privileges (for most scripts)
- PowerShell 5.1 or later
- .NET Framework 4.7.2 or later

**Optional:**
- EmptyStandbyList.exe (for memory clearing - Windows SDK)
- Modern GPU (for HAGS feature)
- SSD (for best performance)

---

## Support

For issues and questions, refer to:
- `TROUBLESHOOTING.md` - Common issues
- `QUICK_REFERENCE.md` - Quick reference card
- `README.md` - Main documentation
- `QUICK_START.md` - Getting started

---

## Version Numbering

**Semantic Versioning:** `MAJOR.MINOR.PATCH`

- **MAJOR** - Breaking changes or major new features
- **MINOR** - New features, backward compatible
- **PATCH** - Bug fixes, minor improvements

**Current:** 3.0.0 (Major update with smart features)

---

**Last Updated:** 2026-03-15
**Maintained By:** Windows 11 Optimization Suite Team
