# Windows 11 Optimization Suite - Troubleshooting

**Version:** 5.1.0 (Updated 2026-03-18)

## Quick Help

**Most Common Issues:**
1. Script won't run → Check Execution Policy
2. Access denied → Run as Administrator
3. Restore point failed → Enable System Restore
4. App removal failed → Some apps are protected

---

## Common Errors and Solutions

---

### Error 1: Get-AppxPackage : Access Denied

**Error Message:**
```
Get-AppxPackage : 拒绝访问。
UnauthorizedAccessException
```

**Cause:**
- `Get-AppxPackage -AllUsers` requires special permissions
- Even administrator accounts may be denied

**Solution:**
The script now handles this automatically:
1. Tries to get all user packages
2. Falls back to current user packages if denied
3. Removes what it can, skips protected apps

**Manual Fix (if needed):**
```powershell
# Run in elevated PowerShell
Get-AppxPackage -AllUsers | Remove-AppxPackage
```

---

### Error 2: Script Won't Run (Execution Policy)

**Error Message:**
```
cannot be loaded because running scripts is disabled on this system
```

**Solution:**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run the script again.

---

### Error 3: Cannot Create Restore Point

**Error Message:**
```
Checkpoint-Computer failed
```

**Cause:**
- System Restore may be disabled
- Insufficient disk space

**Solution:**
1. Enable System Restore manually:
   - Win + R → `sysdm.cpl`
   - System Protection tab
   - Enable for system drive
2. Create restore point manually
3. Continue with script

---

### Error 4: Remove-AppxPackage : Access Denied

**Error Message:**
```
Remove-AppxPackage : 拒绝访问。
```

**Cause:**
- Some apps are protected by Windows
- Cannot remove core system apps

**Solution:**
This is normal. The script will:
- Skip protected apps
- Show them as "Failed" or "Skipped"
- Continue with removable apps

**Protected apps (cannot remove):**
- Microsoft.WindowsStore (Store)
- Microsoft.MicrosoftEdge (Edge)
- Microsoft.Windows.Security (Defender)
- Cortana (sometimes)
- Windows.Photos (sometimes)

---

### Error 5: Service Cannot Be Stopped

**Error Message:**
```
Stop-Service : Service cannot be stopped
```

**Cause:**
- Service is in use by other services
- Service is critical to system

**Solution:**
- Script will skip these services
- No action needed
- Service will remain enabled (safe)

---

### Error 6: Registry Key Access Denied

**Error Message:**
```
Access to the registry key is denied
```

**Cause:**
- Registry key protected by TrustedInstaller
- Insufficient permissions

**Solution:**
```powershell
# Take ownership (advanced users only)
takeown /f "HKLM:\PATH\TO\KEY"
icacls "HKLM:\PATH\TO\KEY" /grant administrators:F
```

**Or:** Skip - registry optimization is optional

---

### Error 7: DISM Failed

**Error Message:**
```
DISM failed with error
```

**Cause:**
- Windows Update service running
- System files in use
- Corrupted system files

**Solution:**
```powershell
# Run SFC first
sfc /scannow

# Then try DISM
Dism /Online /Cleanup-Image /RestoreHealth

# Then retry cleanup
Dism /Online /Cleanup-Image /StartComponentCleanup
```

---

### Error 8: OneDrive Won't Uninstall

**Error Message:**
```
OneDrive uninstall failed
```

**Solution:**
Manual OneDrive removal:
```powershell
# Stop OneDrive
Stop-Process -Name "OneDrive" -Force

# Uninstall
if (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe") {
    & "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /uninstall
}

# Remove folder
Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force
```

---

## Pre-Run Checklist

Before running optimization scripts:

- [ ] **Backup important data**
- [ ] **Create system restore point**
- [ ] **Close all applications**
- [ ] **Run as Administrator**
- [ ] **Ensure stable power** (laptop: plug in)
- [ ] **Disable antivirus** (may interfere)

---

## Post-Run Checklist

After optimization:

- [ ] **Restart system**
- [ ] **Check Microsoft Store opens**
- [ ] **Check Edge browser works**
- [ ] **Check File Explorer works**
- [ ] **Check Windows Update works**
- [ ] **Test games/applications**
- [ ] **Verify no critical issues**

---

## Recovery Options

### Option 1: Use Restore Script
```powershell
.\05-Restore.ps1
```

### Option 2: System Restore
1. Win + R → `rstrui.exe`
2. Select restore point
3. Follow wizard

### Option 3: Reinstall Apps
```powershell
Get-AppxPackage -AllUsers | ForEach-Object {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}
```

### Option 4: Reset Windows (last resort)
1. Settings → Update & Security → Recovery
2. Reset this PC
3. Keep my files

---

## Specific App Removal

### Remove Xbox Apps (if needed manually)
```powershell
Get-AppxPackage *Xbox* | Remove-AppxPackage
```

### Remove Cortana
```powershell
Get-AppxPackage *Cortana* | Remove-AppxPackage
```

### Remove OneDrive (manual)
```powershell
Get-AppxPackage *OneDrive* | Remove-AppxPackage
```

### Remove News/Weather
```powershell
Get-AppxPackage *News* | Remove-AppxPackage
Get-AppxPackage *Weather* | Remove-AppxPackage
```

---

## Performance Issues After Optimization

### Problem: System runs slower
**Solution:**
- Restore services: `.\05-Restore.ps1`
- Check Task Manager for issues
- Run: `sfc /scannow`

### Problem: Apps won't open
**Solution:**
- Reinstall apps (see above)
- Check Windows Update
- Run Windows Store Apps troubleshooter

### Problem: Games crash
**Solution:**
- Restore Xbox services
- Update graphics drivers
- Disable Game Mode temporarily

---

## Contact & Support

If issues persist:

1. Check Windows Event Viewer
2. Run: `Get-AppxPackage -AllUsers | Get-AppxPackageLog`
3. Check PowerShell logs
4. Consider professional help

---

**Last Updated**: 2026-03-14  
**Scripts Version**: 1.0  
**Tested On**: Windows 11 Pro 22H2+
