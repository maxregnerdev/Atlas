# Windows 11 29H1 OOBE Engine
# Complete OOBE system for 29H1 experience on 25H2
# This is the main engine that transforms the OOBE experience

param(
    [switch]$SkipAll = $false,
    [switch]$CustomBranding = $true,
    [switch]$Enable29H1Features = $true
)

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator" -ForegroundColor Red
    exit 1
}

Write-Host "=== Windows 11 29H1 OOBE Engine Starting ===" -ForegroundColor Cyan

# ============================================
# 29H1 OOBE - Registry Configuration
# ============================================

function Set-29H1OOBERegistry {
    Write-Host "Configuring 29H1 OOBE Registry Settings..." -ForegroundColor Yellow
    
    # Skip OOBE requirements
    $labConfigPath = "HKLM:\SYSTEM\Setup\LabConfig"
    Set-ItemProperty -Path $labConfigPath -Name "BypassTPMCheck" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $labConfigPath -Name "BypassSecureBootCheck" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $labConfigPath -Name "BypassRAMCheck" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $labConfigPath -Name "BypassStorageCheck" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $labConfigPath -Name "BypassCPUCheck" -Value 1 -Type DWord -Force
    
    # OOBE Customization
    $oobePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
    Set-ItemProperty -Path $oobePath -Name "DisableAnimations" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $oobePath -Name "SkipProductKey" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $oobePath -Name "SkipEULA" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $oobePath -Name "SkipNetwork" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $oobePath -Name "SkipMachineOOBE" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $oobePath -Name "SkipCortanaOptIn" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $oobePath -Name "SkipOneDrive" -Value 1 -Type DWord -Force
    
    # 29H1 Theme
    Set-ItemProperty -Path $oobePath -Name "BackgroundColor" -Value "#000000" -Type String -Force
    Set-ItemProperty -Path $oobePath -Name "TextColor" -Value "#FFFFFF" -Type String -Force
    Set-ItemProperty -Path $oobePath -Name "UseDarkMode" -Value 1 -Type DWord -Force
    
    # Privacy Settings
    $privacyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    Set-ItemProperty -Path $privacyPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $privacyPath -Name "DisableEnterpriseAuthProxy" -Value 1 -Type DWord -Force
    
    $locationPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Capabilities\Location"
    Set-ItemProperty -Path $locationPath -Name "LocationEnabled" -Value 0 -Type DWord -Force
    
    Write-Host "29H1 OOBE Registry Settings Applied" -ForegroundColor Green
}

# ============================================
# 29H1 OOBE - Branding System
# ============================================

function Set-29H1OOBEBranding {
    Write-Host "Applying 29H1 OOBE Branding..." -ForegroundColor Yellow
    
    # Create directories
    $oobeDir = "C:\Windows\System32\oobe"
    $backgroundsDir = "$oobeDir\backgrounds"
    $infoDir = "$oobeDir\info"
    
    if (-not (Test-Path $backgroundsDir)) { New-Item -ItemType Directory -Path $backgroundsDir -Force | Out-Null }
    if (-not (Test-Path $infoDir)) { New-Item -ItemType Directory -Path $infoDir -Force | Out-Null }
    
    # Copy custom 29H1 assets
    $scriptDir = $PSScriptRoot
    $assetsDir = Join-Path $scriptDir "..\..\Images\29H1"
    
    # Copy background
    $bgSource = "$assetsDir\29h1-oobe-background.jpg"
    $bgDest = "$backgroundsDir\29h1-background.jpg"
    if (Test-Path $bgSource) { Copy-Item -Path $bgSource -Destination $bgDest -Force }
    
    # Copy logo
    $logoSource = "$assetsDir\29h1-logo.png"
    $logoDest = "$infoDir\logo.png"
    if (Test-Path $logoSource) { Copy-Item -Path $logoSource -Destination $logoDest -Force }
    
    # Create custom welcome.xml
    $welcomeContent = @"
<?xml version="1.0" encoding="utf-8"?>
<OOBE>
  <Welcome>
    <Title>Welcome to Windows 11 29H1</Title>
    <Subtitle>Next Generation Experience</Subtitle>
    <Description>Experience the future of Windows with enhanced performance, privacy, and customization.</Description>
    <Brand>29H1</Brand>
    <Version>29H1</Version>
  </Welcome>
  <Settings>
    <Theme>Dark</Theme>
    <Animation>Disabled</Animation>
    <Telemetry>Disabled</Telemetry>
  </Settings>
</OOBE>
"@
    
    $welcomeFile = "$infoDir\welcome.xml"
    $welcomeContent | Out-File -FilePath $welcomeFile -Encoding utf8 -Force
    
    Write-Host "29H1 OOBE Branding Applied" -ForegroundColor Green
}

# ============================================
# 29H1 OOBE - Feature Engine
# ============================================

function Enable-29H1OOBEFeatures {
    Write-Host "Enabling 29H1 OOBE Features..." -ForegroundColor Yellow
    
    # Enable AI Integration
    $aiPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AI"
    Set-ItemProperty -Path $aiPath -Name "EnableWindowsAI" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $aiPath -Name "EnableOnDeviceAI" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    
    # Enable Copilot
    $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $explorerPath -Name "EnableCopilot" -Value 1 -Type DWord -Force
    
    # Enable Gaming Features
    $graphicsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"
    Set-ItemProperty -Path $graphicsPath -Name "EnableAutoHDR" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableDirectStorage" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableVRR" -Value 1 -Type DWord -Force
    
    # Enable Performance Features
    $gameUXPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameUX"
    Set-ItemProperty -Path $gameUXPath -Name "GameModeEnabled" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 OOBE Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 OOBE - Main Execution
# ============================================

try {
    Write-Host "Starting 29H1 OOBE Transformation..." -ForegroundColor Cyan
    
    # Execute all functions
    Set-29H1OOBERegistry
    Set-29H1OOBEBranding
    Enable-29H1OOBEFeatures
    
    # Create completion marker
    $markerPath = "C:\Windows\System32\oobe\29h1-engine-complete.flag"
    New-Item -Path $markerPath -ItemType File -Force | Out-Null
    
    Write-Host "=== 29H1 OOBE Engine Completed Successfully ===" -ForegroundColor Green
    Write-Host "All 29H1 OOBE features have been applied to your system." -ForegroundColor Green
    
    exit 0
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "29H1 OOBE Engine Failed" -ForegroundColor Red
    exit 1
}
