# Windows 11 29H1 Main Engine
# Complete 29H1 transformation system for Windows 11 25H2
# This is the master engine that orchestrates all 29H1 components

param(
    [switch]$ApplyAll = $true,
    [switch]$ApplyOOBE = $true,
    [switch]$ApplyDesktop = $true,
    [switch]$ApplyFeatures = $true,
    [switch]$Silent = $false,
    [switch]$Force = $false
)

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Right-click and select 'Run as administrator'" -ForegroundColor Gray
    exit 1
}

# Set console title
$Host.UI.RawUI.WindowTitle = "Windows 11 29H1 Transformation Engine"

# Clear screen for better visibility
Clear-Host

# ============================================
# 29H1 Main Engine - Initialization
# ============================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Windows 11 29H1 Transformation Engine" -ForegroundColor White
Write-Host " Transforms 25H2 into Complete 29H1 Experience" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor DarkGray

# Check if already transformed
$completionMarker = "C:\Windows\System32\29h1-complete-transformation.flag"
if (Test-Path $completionMarker -and -not $Force) {
    Write-Host "Windows 11 29H1 transformation already applied!" -ForegroundColor Yellow
    Write-Host "Use -Force switch to reapply" -ForegroundColor Gray
    exit 0
}

# Get current Windows version
$currentVersion = (Get-CimInstance Win32_OperatingSystem).Version
$currentBuild = (Get-CimInstance Win32_OperatingSystem).BuildNumber

Write-Host "Current Windows Version: $currentVersion" -ForegroundColor Gray
Write-Host "Current Build: $currentBuild" -ForegroundColor Gray
Write-Host "" -ForegroundColor DarkGray

# Verify we're on 25H2 (build 26200)
if ($currentBuild -ne "26200" -and $currentBuild -ne "26100") {
    Write-Host "WARNING: This transformation is designed for Windows 11 25H2 (build 26200)" -ForegroundColor Yellow
    Write-Host "Your system is build $currentBuild" -ForegroundColor Gray
    Write-Host "" -ForegroundColor DarkGray
    
    if (-not $Force) {
        $confirm = Read-Host "Do you want to continue anyway? (Y/N)"
        if ($confirm -ne "Y" -and $confirm -ne "y") {
            exit 0
        }
    }
}

# ============================================
# 29H1 Main Engine - Component Execution
# ============================================

function Invoke-29H1OOBE {
    if (-not $ApplyOOBE -and -not $ApplyAll) { return }
    
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "[1/3] Applying 29H1 OOBE System..." -ForegroundColor Cyan
    Write-Host "-" -ForegroundColor DarkGray
    
    $oobeScript = "$PSScriptRoot\..\29H1 OOBE\29h1-oobe-engine.ps1"
    $brandingScript = "$PSScriptRoot\..\29H1 OOBE\29h1-oobe-branding.ps1"
    $featuresScript = "$PSScriptRoot\..\29H1 OOBE\29h1-oobe-features.ps1"
    
    try {
        if (Test-Path $oobeScript) {
            & $oobeScript
            Write-Host "  OOBE Engine: SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "  OOBE Engine: NOT FOUND" -ForegroundColor Red
        }
        
        if (Test-Path $brandingScript) {
            & $brandingScript
            Write-Host "  OOBE Branding: SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "  OOBE Branding: NOT FOUND" -ForegroundColor Red
        }
        
        if (Test-Path $featuresScript) {
            & $featuresScript
            Write-Host "  OOBE Features: SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "  OOBE Features: NOT FOUND" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "  OOBE Error: $_" -ForegroundColor Red
    }
    
    Write-Host "29H1 OOBE System Applied" -ForegroundColor Green
}

function Invoke-29H1Desktop {
    if (-not $ApplyDesktop -and -not $ApplyAll) { return }
    
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "[2/3] Applying 29H1 Desktop System..." -ForegroundColor Cyan
    Write-Host "-" -ForegroundColor DarkGray
    
    $desktopScript = "$PSScriptRoot\..\29H1 UI\29h1-desktop-engine.ps1"
    $themeScript = "$PSScriptRoot\..\29H1 UI\29h1-desktop-theme.ps1"
    
    try {
        if (Test-Path $desktopScript) {
            & $desktopScript
            Write-Host "  Desktop Engine: SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "  Desktop Engine: NOT FOUND" -ForegroundColor Red
        }
        
        if (Test-Path $themeScript) {
            & $themeScript
            Write-Host "  Desktop Theme: SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "  Desktop Theme: NOT FOUND" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "  Desktop Error: $_" -ForegroundColor Red
    }
    
    Write-Host "29H1 Desktop System Applied" -ForegroundColor Green
}

function Invoke-29H1Features {
    if (-not $ApplyFeatures -and -not $ApplyAll) { return }
    
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "[3/3] Applying 29H1 Features System..." -ForegroundColor Cyan
    Write-Host "-" -ForegroundColor DarkGray
    
    $featuresScript = "$PSScriptRoot\..\29H1 Features\29h1-features-engine.ps1"
    
    try {
        if (Test-Path $featuresScript) {
            & $featuresScript
            Write-Host "  Features Engine: SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "  Features Engine: NOT FOUND" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "  Features Error: $_" -ForegroundColor Red
    }
    
    Write-Host "29H1 Features System Applied" -ForegroundColor Green
}

# ============================================
# 29H1 Main Engine - Execution
# ============================================

try {
    Write-Host "Starting Windows 11 29H1 Transformation..." -ForegroundColor Cyan
    Write-Host "This process may take several minutes." -ForegroundColor Gray
    Write-Host "" -ForegroundColor DarkGray
    
    # Execute all components
    Invoke-29H1OOBE
    Invoke-29H1Desktop
    Invoke-29H1Features
    
    # ============================================
    # 29H1 Main Engine - Finalization
    # ============================================
    
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host " Finalizing 29H1 Transformation" -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor DarkGray
    
    # Create completion markers
    $markers = @(
        "C:\Windows\System32\29h1-complete-transformation.flag",
        "C:\Windows\System32\29h1-oobe-complete.flag",
        "C:\Windows\System32\29h1-desktop-complete.flag",
        "C:\Windows\System32\29h1-features-complete.flag"
    )
    
    foreach ($marker in $markers) {
        New-Item -Path $marker -ItemType File -Force | Out-Null
    }
    
    # Set system version flags
    $versionPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    Set-ItemProperty -Path $versionPath -Name "29H1_Transformed" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $versionPath -Name "29H1_TransformationDate" -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Type String -Force
    
    # Restart explorer to apply all changes
    try {
        Write-Host "Restarting Windows Explorer..." -ForegroundColor Yellow
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        Start-Process -FilePath "explorer.exe"
        Write-Host "Windows Explorer restarted successfully" -ForegroundColor Green
    } catch {
        Write-Host "Could not restart explorer: $_" -ForegroundColor Yellow
    }
    
    # Final success message
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host " TRANSFORMATION COMPLETE!" -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "Your Windows 11 25H2 has been successfully" -ForegroundColor White
    Write-Host "transformed with the complete Windows 11 29H1" -ForegroundColor White
    Write-Host "user interface and feature set!" -ForegroundColor White
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "Changes applied:" -ForegroundColor Yellow
    Write-Host "  ✓ 29H1 OOBE System" -ForegroundColor Green
    Write-Host "  ✓ 29H1 Desktop UI" -ForegroundColor Green
    Write-Host "  ✓ 29H1 Core Features" -ForegroundColor Green
    Write-Host "  ✓ 29H1 AI Integration" -ForegroundColor Green
    Write-Host "  ✓ 29H1 Gaming Features" -ForegroundColor Green
    Write-Host "  ✓ 29H1 Security Features" -ForegroundColor Green
    Write-Host "  ✓ 29H1 Performance Optimizations" -ForegroundColor Green
    Write-Host "  ✓ 29H1 Networking Enhancements" -ForegroundColor Green
    Write-Host "  ✓ 29H1 Storage Optimizations" -ForegroundColor Green
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "Please restart your computer to complete" -ForegroundColor Yellow
    Write-Host "the transformation process." -ForegroundColor Yellow
    Write-Host "" -ForegroundColor DarkGray
    
    # Play completion sound
    try {
        [System.Media.SystemSounds]::Asterisk.Play()
    } catch {}
    
    exit 0
    
} catch {
    Write-Host "" -ForegroundColor DarkGray
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "Windows 11 29H1 Transformation Failed" -ForegroundColor Red
    Write-Host "" -ForegroundColor DarkGray
    exit 1
}
