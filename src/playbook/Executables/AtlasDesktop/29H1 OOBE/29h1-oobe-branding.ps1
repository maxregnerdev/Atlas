# Windows 11 29H1 OOBE Branding System
# Complete branding implementation for 29H1 OOBE

param(
    [string]$BackgroundPath = "",
    [string]$LogoPath = "",
    [string]$WelcomeText = "Welcome to Windows 11 29H1"
)

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Administrator rights required" -ForegroundColor Red
    exit 1
}

Write-Host "=== 29H1 OOBE Branding System Starting ===" -ForegroundColor Magenta

# ============================================
# 29H1 Branding - File System Setup
# ============================================

function Initialize-29H1BrandingDirectories {
    Write-Host "Initializing 29H1 branding directories..." -ForegroundColor Yellow
    
    $directories = @(
        "C:\Windows\System32\oobe\backgrounds",
        "C:\Windows\System32\oobe\info",
        "C:\Windows\System32\oobe\themes",
        "C:\Windows\System32\oobe\assets",
        "C:\Windows\System32\oobe\29h1"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "Created: $dir" -ForegroundColor Gray
        }
    }
    
    Write-Host "29H1 branding directories initialized" -ForegroundColor Green
}

# ============================================
# 29H1 Branding - Asset Deployment
# ============================================

function Deploy-29H1BrandingAssets {
    Write-Host "Deploying 29H1 branding assets..." -ForegroundColor Yellow
    
    $scriptDir = $PSScriptRoot
    $sourceDir = Join-Path $scriptDir "..\..\Images\29H1"
    
    # Asset mappings
    $assets = @(
        @{ Source = "29h1-oobe-background.jpg"; Destination = "C:\Windows\System32\oobe\backgrounds\29h1-bg.jpg" },
        @{ Source = "29h1-oobe-background-dark.jpg"; Destination = "C:\Windows\System32\oobe\backgrounds\29h1-bg-dark.jpg" },
        @{ Source = "29h1-logo.png"; Destination = "C:\Windows\System32\oobe\info\logo.png" },
        @{ Source = "29h1-logo-icon.png"; Destination = "C:\Windows\System32\oobe\info\icon.png" },
        @{ Source = "29h1-watermark.png"; Destination = "C:\Windows\System32\oobe\assets\watermark.png" },
        @{ Source = "29h1-theme.css"; Destination = "C:\Windows\System32\oobe\themes\29h1.css" }
    )
    
    foreach ($asset in $assets) {
        $sourcePath = Join-Path $sourceDir $asset.Source
        $destPath = $asset.Destination
        
        if (Test-Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host "Deployed: $($asset.Source) -> $($asset.Destination)" -ForegroundColor Gray
        } else {
            Write-Host "Missing asset: $($asset.Source)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "29H1 branding assets deployed" -ForegroundColor Green
}

# ============================================
# 29H1 Branding - XML Configuration
# ============================================

function Create-29H1WelcomeXML {
    Write-Host "Creating 29H1 welcome configuration..." -ForegroundColor Yellow
    
    $welcomePath = "C:\Windows\System32\oobe\info\welcome.xml"
    
    $welcomeXML = @"
<?xml version="1.0" encoding="UTF-8"?>
<OOBEConfiguration>
    <Branding>
        <ProductName>Windows 11 29H1</ProductName>
        <ProductVersion>29H1</ProductVersion>
        <Manufacturer>Microsoft</Manufacturer>
        <Theme>Dark</Theme>
        <BackgroundImage>29h1-bg-dark.jpg</BackgroundImage>
        <LogoImage>logo.png</LogoImage>
    </Branding>
    <WelcomeScreen>
        <Title>Welcome to Windows 11 29H1</Title>
        <Subtitle>Next Generation Windows Experience</Subtitle>
        <Description>Experience the future of Windows with enhanced performance, privacy, and customization.</Description>
        <AnimationEnabled>false</AnimationEnabled>
        <VoiceEnabled>false</VoiceEnabled>
    </WelcomeScreen>
    <Settings>
        <TelemetryEnabled>false</TelemetryEnabled>
        <LocationEnabled>false</LocationEnabled>
        <DiagnosticsEnabled>false</DiagnosticsEnabled>
        <CortanaEnabled>false</CortanaEnabled>
        <OneDriveEnabled>false</OneDriveEnabled>
        <MicrosoftAccountRequired>false</MicrosoftAccountRequired>
    </Settings>
    <FeatureFlags>
        <Feature name="AIIntegration" enabled="true" />
        <Feature name="Copilot" enabled="true" />
        <Feature name="AutoHDR" enabled="true" />
        <Feature name="DirectStorage" enabled="true" />
        <Feature name="GameMode" enabled="true" />
        <Feature name="VRR" enabled="true" />
    </FeatureFlags>
</OOBEConfiguration>
"@
    
    $welcomeXML | Out-File -FilePath $welcomePath -Encoding UTF8 -Force
    Write-Host "29H1 welcome.xml created" -ForegroundColor Green
}

# ============================================
# 29H1 Branding - Registry Configuration
# ============================================

function Configure-29H1BrandingRegistry {
    Write-Host "Configuring 29H1 branding registry..." -ForegroundColor Yellow
    
    # OOBE Branding Settings
    $oobePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
    
    Set-ItemProperty -Path $oobePath -Name "ProductName" -Value "Windows 11 29H1" -Type String -Force
    Set-ItemProperty -Path $oobePath -Name "ProductVersion" -Value "29H1" -Type String -Force
    Set-ItemProperty -Path $oobePath -Name "BrandImage" -Value "C:\Windows\System32\oobe\info\logo.png" -Type String -Force
    Set-ItemProperty -Path $oobePath -Name "Background" -Value "C:\Windows\System32\oobe\backgrounds\29h1-bg-dark.jpg" -Type String -Force
    
    # System Branding
    $systemPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    Set-ItemProperty -Path $systemPath -Name "ShellState" -Value "29H1" -Type String -Force
    
    # Custom OEM Information
    $oemPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
    Set-ItemProperty -Path $oemPath -Name "Logo" -Value "C:\Windows\System32\oobe\info\logo.png" -Type String -Force
    Set-ItemProperty -Path $oemPath -Name "Manufacturer" -Value "Windows 11 29H1" -Type String -Force
    Set-ItemProperty -Path $oemPath -Name "Model" -Value "29H1 Experience" -Type String -Force
    
    Write-Host "29H1 branding registry configured" -ForegroundColor Green
}

# ============================================
# 29H1 Branding - CSS Theme
# ============================================

function Create-29H1ThemeCSS {
    Write-Host "Creating 29H1 theme CSS..." -ForegroundColor Yellow
    
    $cssPath = "C:\Windows\System32\oobe\themes\29h1.css"
    
    $cssContent = @"
/* Windows 11 29H1 OOBE Theme */

:root {
    --29h1-primary-color: #0078d4;
    --29h1-secondary-color: #00bcf2;
    --29h1-accent-color: #00ff88;
    --29h1-background-color: #000000;
    --29h1-text-color: #ffffff;
    --29h1-subtext-color: #a0a0a0;
    --29h1-border-color: #202020;
    --29h1-hover-color: #1a1a1a;
}

body {
    background-color: var(--29h1-background-color);
    color: var(--29h1-text-color);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 0;
    overflow: hidden;
}

.oobe-container {
    background: linear-gradient(135deg, var(--29h1-background-color) 0%, #0a0a0a 100%);
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.welcome-title {
    font-size: 36px;
    font-weight: 600;
    color: var(--29h1-text-color);
    margin-bottom: 16px;
    text-align: center;
    text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}

.welcome-subtitle {
    font-size: 24px;
    color: var(--29h1-subtext-color);
    margin-bottom: 32px;
    text-align: center;
}

.welcome-description {
    font-size: 16px;
    color: var(--29h1-subtext-color);
    max-width: 600px;
    text-align: center;
    line-height: 1.6;
}

.29h1-logo {
    width: 120px;
    height: 120px;
    margin-bottom: 48px;
    animation: fadeIn 0.8s ease-in;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-20px); }
    to { opacity: 1; transform: translateY(0); }
}

.progress-container {
    margin-top: 60px;
    width: 100%;
    max-width: 400px;
}

.progress-bar {
    height: 4px;
    background-color: var(--29h1-border-color);
    border-radius: 2px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--29h1-primary-color), var(--29h1-secondary-color));
    width: 0%;
    transition: width 0.3s ease;
}

.button-29h1 {
    background: linear-gradient(135deg, var(--29h1-primary-color), var(--29h1-secondary-color));
    color: white;
    border: none;
    padding: 12px 32px;
    font-size: 16px;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s ease;
    margin: 8px;
}

.button-29h1:hover {
    background: linear-gradient(135deg, var(--29h1-secondary-color), var(--29h1-primary-color));
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,120,212,0.4);
}

.button-29h1:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}
"@
    
    $cssContent | Out-File -FilePath $cssPath -Encoding UTF8 -Force
    Write-Host "29H1 theme CSS created" -ForegroundColor Green
}

# ============================================
# 29H1 Branding - Main Execution
# ============================================

try {
    Write-Host "Starting 29H1 branding transformation..." -ForegroundColor Cyan
    
    Initialize-29H1BrandingDirectories
    Deploy-29H1BrandingAssets
    Create-29H1WelcomeXML
    Configure-29H1BrandingRegistry
    Create-29H1ThemeCSS
    
    # Create completion marker
    $marker = "C:\Windows\System32\oobe\29h1-branding-complete.flag"
    New-Item -Path $marker -ItemType File -Force | Out-Null
    
    Write-Host "=== 29H1 Branding System Completed Successfully ===" -ForegroundColor Green
    Write-Host "All 29H1 branding assets and configurations have been applied." -ForegroundColor Green
    
    exit 0
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "29H1 Branding System Failed" -ForegroundColor Red
    exit 1
}
