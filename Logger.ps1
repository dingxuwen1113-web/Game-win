# ============================================================================
# Logger Module - 统一日志格式
# Windows 11 Optimization Suite v4.0.0
# ============================================================================
# Creator & Developer: 丁旭文
# Email: dxw2005@petalmail.com
# Usage: . .\Logger.ps1   (dot-source to load functions)
# ============================================================================

# Log file location
$Script:LogDir = "$PSScriptRoot\logs"
$Script:LogFile = "$Script:LogDir\optimization-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

# Create log directory
if (-not (Test-Path $Script:LogDir)) {
    New-Item -ItemType Directory -Path $Script:LogDir -Force | Out-Null
}

# ============================================================================
# Logging Functions
# ============================================================================

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-LogInternal "HEADER: $Text" "INFO"
}

function Write-Step {
    param([string]$Text, [int]$Step, [int]$Total)
    Write-Host ""
    Write-Host "[$Step/$Total] $Text" -ForegroundColor Yellow
    Write-LogInternal "STEP [$Step/$Total]: $Text" "INFO"
}

function Write-OK {
    param([string]$Text)
    Write-Host "  [OK] $Text" -ForegroundColor Green
    Write-LogInternal "OK: $Text" "SUCCESS"
}

function Write-Warn {
    param([string]$Text)
    Write-Host "  [WARN] $Text" -ForegroundColor Yellow
    Write-LogInternal "WARN: $Text" "WARNING"
}

function Write-Error {
    param([string]$Text)
    Write-Host "  [ERROR] $Text" -ForegroundColor Red
    Write-LogInternal "ERROR: $Text" "ERROR"
}

function Write-Info {
    param([string]$Text)
    Write-Host "  [INFO] $Text" -ForegroundColor Gray
    Write-LogInternal "INFO: $Text" "INFO"
}

function Write-Debug {
    param([string]$Text)
    if ($Script:DebugMode) {
        Write-Host "  [DEBUG] $Text" -ForegroundColor DarkGray
    }
    Write-LogInternal "DEBUG: $Text" "DEBUG"
}

function Write-LogInternal {
    param([string]$Message, [string]$Level = "INFO")
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$timestamp] [$Level] $Message" | Out-File -FilePath $Script:LogFile -Append -Encoding UTF8 -ErrorAction SilentlyContinue
    }
    catch {
        # Silent fail - logging shouldn't break the script
    }
}

function Write-Status {
    param(
        [string]$Label,
        [string]$Value,
        [string]$Color = "Gray"
    )
    $padding = 25
    $displayLabel = $Label.PadRight($padding)
    Write-Host "  $displayLabel : $Value" -ForegroundColor $Color
    Write-LogInternal "STATUS: $Label = $Value" "INFO"
}

function Write-Table {
    param(
        [string[]]$Headers,
        [object[]]$Rows
    )
    # Simple table formatter
    $colWidths = @()
    for ($i = 0; $i -lt $Headers.Length; $i++) {
        $maxLen = $Headers[$i].Length
        foreach ($row in $Rows) {
            if ($i -lt $row.Length) {
                $cellLen = [string]($row[$i]).Length
                if ($cellLen -gt $maxLen) { $maxLen = $cellLen }
            }
        }
        $colWidths += $maxLen
    }
    
    # Header
    $headerLine = ""
    for ($i = 0; $i -lt $Headers.Length; $i++) {
        $headerLine += $Headers[$i].PadRight($colWidths[$i] + 2)
    }
    Write-Host $headerLine -ForegroundColor Cyan
    
    # Separator
    $sepLine = ""
    for ($i = 0; $i -lt $Headers.Length; $i++) {
        $sepLine += "".PadRight($colWidths[$i] + 2, "-")
    }
    Write-Host $sepLine -ForegroundColor DarkGray
    
    # Rows
    foreach ($row in $Rows) {
        $rowLine = ""
        for ($i = 0; $i -lt $Headers.Length; $i++) {
            $value = if ($i -lt $row.Length) { $row[$i] } else { "" }
            $rowLine += [string]$value.PadRight($colWidths[$i] + 2)
        }
        Write-Host $rowLine -ForegroundColor Gray
    }
}

function Get-LogFile {
    return $Script:LogFile
}

function Get-LogDir {
    return $Script:LogDir
}

# ============================================================================
# Initialization
# ============================================================================

Write-Debug "Logger module loaded"
Write-Info "Log file: $Script:LogFile"
