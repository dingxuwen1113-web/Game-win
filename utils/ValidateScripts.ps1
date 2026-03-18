# ============================================================================
# Script Validation and Debug Script
# Checks all PowerShell scripts for syntax errors and issues
# Part of Windows 11 Optimization Suite
# ============================================================================
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Script Validation and Debug" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$psScripts = Get-ChildItem -Path $scriptDir -Filter "*.ps1" | Where-Object { $_.Name -match "^(0[0-9]|1[0-2])-" }

$totalScripts = $psScripts.Count
$validScripts = 0
$invalidScripts = 0
$errors = @()

Write-Host "Found $totalScripts PowerShell scripts to validate" -ForegroundColor Cyan
Write-Host ""

foreach ($script in $psScripts) {
    Write-Host "Checking: $($script.Name)" -ForegroundColor Yellow
    
    try {
        # Check syntax
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $script.FullName -Raw), [ref]$null)
        
        # Try to parse
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$null, [ref]$errors)
        
        if ($errors.Count -eq 0) {
            Write-Host "  OK: Syntax valid" -ForegroundColor Green
            $validScripts++
        }
        else {
            Write-Host "  ERROR: Syntax errors found:" -ForegroundColor Red
            foreach ($err in $errors) {
                Write-Host "    Line $($err.Extent.StartLineNumber): $($err.Message)" -ForegroundColor Red
            }
            $invalidScripts++
        }
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $invalidScripts++
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Total scripts: $totalScripts" -ForegroundColor White
Write-Host "  Valid scripts: $validScripts" -ForegroundColor Green
Write-Host "  Invalid scripts: $invalidScripts" -ForegroundColor $(if ($invalidScripts -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($invalidScripts -gt 0) {
    Write-Host "WARNING: Some scripts have syntax errors!" -ForegroundColor Red
    Write-Host "         Do not run invalid scripts until fixed." -ForegroundColor Red
    Write-Host ""
}
else {
    Write-Host "SUCCESS: All scripts passed validation!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
