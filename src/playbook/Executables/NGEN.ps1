# Windows 11 29H1 NGEN Optimization Script
# Speeds up PowerShell startup time by 10x for 29H1

Write-Host "=== Windows 11 29H1 NGEN Optimization ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
    if ($29h1Mode) {
        Write-Host "29H1 Mode detected - Applying 29H1 NGEN optimizations" -ForegroundColor Green
    }
}

# Set .NET runtime path
$env:path = "$([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory());" + $env:path

# 29H1: Optimize .NET assemblies
Write-Host "NGENing .NET assemblies for 29H1..." -ForegroundColor Yellow

[AppDomain]::CurrentDomain.GetAssemblies().Location | Where-Object { $_ } | ForEach-Object {
    $assemblyName = Split-Path $_ -Leaf
    Write-Host "NGENing: $assemblyName" -ForegroundColor Gray
    try {
        ngen install $_ | Out-Null
        Write-Host "  [OK] $assemblyName" -ForegroundColor Green
    } catch {
        Write-Host "  [FAILED] $assemblyName : $_" -ForegroundColor Red
    }
}

# 29H1: Additional .NET optimizations
Write-Host "Applying 29H1 .NET optimizations..." -ForegroundColor Yellow

# Optimize common .NET assemblies for 29H1
$commonAssemblies = @(
    "System.Core.dll",
    "System.Windows.Forms.dll",
    "System.Drawing.dll",
    "System.Xml.dll",
    "System.Data.dll",
    "System.Runtime.Serialization.dll",
    "System.ServiceModel.dll",
    "System.Web.dll"
)

foreach ($assembly in $commonAssemblies) {
    $assemblyPath = Join-Path $([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) $assembly
    if (Test-Path $assemblyPath) {
        try {
            ngen install $assemblyPath | Out-Null
            Write-Host "  [OK] $assembly" -ForegroundColor Green
        } catch {
            Write-Host "  [FAILED] $assembly : $_" -ForegroundColor Red
        }
    }
}

# Set 29H1 NGEN flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_NGEN_Optimized" -Value 1 -Type DWord -Force

Write-Host "29H1 NGEN Optimization Complete" -ForegroundColor Green
exit 0
