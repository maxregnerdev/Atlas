# Windows 12 OOBE Engine
# Out-of-Box Experience transformation for Windows 12
# Based on the Windows 12 concept from https://windows-12-web.vercel.app/

param(
    [switch]$SkipAll = $true,
    [switch]$CustomBranding = $true,
    [switch]$BypassRequirements = $true,
    [switch]$DarkMode = $true
)

# Windows 12 OOBE Engine Configuration
$Windows12OOBEConfig = @{
    Name = "Windows 12 OOBE Engine"
    Version = "12.0.50023"
    Build = "12.0.50023"
    TargetBuild = "26200"  # Windows 11 25H2
    Author = "immobilesmile70 | he/him"
    ConceptURL = "https://windows-12-web.vercel.app/"
    TransformationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Logging Configuration
$LogPath = "$env:SystemRoot\Logs\Windows12\OOBE"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
$LogFile = "$LogPath\windows12-oobe-engine.log"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARNING") { "Yellow" } elseif ($Level -eq "SUCCESS") { "Green" } else { "Cyan" })
    Add-Content -Path $LogFile -Value $logEntry
}

# Initialize Windows 12 OOBE Transformation
Write-Log "Windows 12 OOBE Engine started" "INFO"
Write-Log "Configuration: $($Windows12OOBEConfig | ConvertTo-Json -Compress)" "INFO"

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Script must be run as Administrator" "ERROR"
    exit 1
}

# Create Windows 12 OOBE Directories
$OOBEPaths = @(
    "$env:SystemRoot\System32\Windows12\OOBE",
    "$env:SystemRoot\System32\Windows12\OOBE\Branding",
    "$env:SystemRoot\System32\Windows12\OOBE\Scripts"
)

foreach ($path in $OOBEPaths) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        Write-Log "Created directory: $path" "INFO"
    }
}

# Set Windows 12 OOBE Registry Flags
$OOBERegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE"
if (-not (Test-Path $OOBERegistryPath)) {
    New-Item -Path $OOBERegistryPath -Force | Out-Null
}

# OOBE Skip Settings
$SkipSettings = @{
    "SkipProductKey" = 1
    "SkipEULA" = 1
    "SkipNetwork" = 1
    "SkipMachineOOBE" = 1
    "SkipUserOOBE" = 1
    "SkipWelcome" = 1
    "SkipCortanaOptIn" = 1
    "SkipOneDrive" = 1
    "SkipPrivacy" = 1
    "SkipRegion" = 1
    "SkipKeyboard" = 1
    "SkipTimeZone" = 1
    "SkipExpressSettings" = 1
    "SkipProvisioning" = 1
}

foreach ($setting in $SkipSettings.Keys) {
    Set-ItemProperty -Path $OOBERegistryPath -Name $setting -Value $SkipSettings[$setting] -Type DWord -Force
}

# OOBE Theme Settings - Windows 12 Style
$ThemeSettings = @{
    "BackgroundColor" = "#000000"
    "TextColor" = "#FFFFFF"
    "AccentColor" = "#0078D4"
    "UseDarkMode" = 1
    "DisableAnimations" = 1
    "EnableTransparency" = 1
}

foreach ($setting in $ThemeSettings.Keys) {
    Set-ItemProperty -Path $OOBERegistryPath -Name $setting -Value $ThemeSettings[$setting] -Type $(if ($ThemeSettings[$setting] -is [int]) { "DWord" } else { "String" }) -Force
}

# Windows 12 Specific OOBE Settings
$Windows12Settings = @{
    "OOBEStyle" = "Windows12"
    "OOBEVersion" = "12.0.50023"
    "Manufacturer" = "Macrohard Corporation"
    "ProductName" = "Windows 12"
}

foreach ($setting in $Windows12Settings.Keys) {
    Set-ItemProperty -Path $OOBERegistryPath -Name $setting -Value $Windows12Settings[$setting] -Type String -Force
}

# OOBE Version Flags
$VersionFlags = @{
    "Windows12_Enabled" = 1
    "Windows12_Version" = "12.0.50023"
    "Windows12_OOBEVersion" = "12.0"
    "Concept_By" = "immobilesmile70"
    "Concept_URL" = "https://windows-12-web.vercel.app/"
}

foreach ($flag in $VersionFlags.Keys) {
    Set-ItemProperty -Path $OOBERegistryPath -Name $flag -Value $VersionFlags[$flag] -Type $(if ($VersionFlags[$flag] -is [int]) { "DWord" } else { "String" }) -Force
}

Write-Log "Windows 12 OOBE registry settings applied" "INFO"

# LabConfig Bypass for Windows 12
if ($BypassRequirements) {
    Write-Log "Applying LabConfig bypass..." "INFO"
    
    $LabConfigPath = "HKLM:\SYSTEM\Setup\LabConfig"
    if (-not (Test-Path $LabConfigPath)) {
        New-Item -Path $LabConfigPath -Force | Out-Null
    }
    
    $BypassFlags = @{
        "BypassTPMCheck" = 1
        "BypassSecureBootCheck" = 1
        "BypassRAMCheck" = 1
        "BypassStorageCheck" = 1
        "BypassCPUCheck" = 1
        "BypassDiskSpaceCheck" = 1
        "BypassNetwork" = 1
        "BypassBitLockerCheck" = 1
    }
    
    foreach ($flag in $BypassFlags.Keys) {
        Set-ItemProperty -Path $LabConfigPath -Name $flag -Value $BypassFlags[$flag] -Type DWord -Force
    }
    
    Write-Log "LabConfig bypass applied" "INFO"
}

# Setup Bypass for Windows 12
$SetupPath = "HKLM:\SYSTEM\Setup"
if (-not (Test-Path $SetupPath)) {
    New-Item -Path $SetupPath -Force | Out-Null
}

$SetupFlags = @{
    "OOBEInProgress" = 0
    "SetupInProgress" = 0
    "SetupType" = 0
    "CmdLine" = ""
    "SetupPhase" = 0
    "SetupFlags" = 0
}

foreach ($flag in $SetupFlags.Keys) {
    Set-ItemProperty -Path $SetupPath -Name $flag -Value $SetupFlags[$flag] -Type $(if ($SetupFlags[$flag] -is [int]) { "DWord" } else { "String" }) -Force
}

Write-Log "Setup bypass applied" "INFO"

# Windows 12 OOBE Privacy Configuration
$PrivacyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
if (-not (Test-Path $PrivacyPath)) {
    New-Item -Path $PrivacyPath -Force | Out-Null
}

$PrivacySettings = @{
    "AllowTelemetry" = 0
    "DisableEnterpriseAuthProxy" = 1
    "MaxTelemetryAllowed" = 0
    "DisableTelemetryOptInChangeNotification" = 1
}

foreach ($setting in $PrivacySettings.Keys) {
    Set-ItemProperty -Path $PrivacyPath -Name $setting -Value $PrivacySettings[$setting] -Type DWord -Force
}

Write-Log "Windows 12 OOBE privacy settings applied" "INFO"

# Diagnostic Tracking
$DiagTrackPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack"
if (-not (Test-Path $DiagTrackPath)) {
    New-Item -Path $DiagTrackPath -Force | Out-Null
}

Set-ItemProperty -Path $DiagTrackPath -Name "ShowedToastAtLevel" -Value 4 -Type DWord -Force
Set-ItemProperty -Path $DiagTrackPath -Name "DiagTrackServiceEnabled" -Value 0 -Type DWord -Force

Write-Log "Diagnostic tracking settings applied" "INFO"

# Location Services
$LocationPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Capabilities\Location"
if (-not (Test-Path $LocationPath)) {
    New-Item -Path $LocationPath -Force | Out-Null
}

Set-ItemProperty -Path $LocationPath -Name "LocationEnabled" -Value 0 -Type DWord -Force

Write-Log "Location services disabled" "INFO"

# Privacy Settings
$PrivacyPath2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
if (-not (Test-Path $PrivacyPath2)) {
    New-Item -Path $PrivacyPath2 -Force | Out-Null
}

$PrivacySettings2 = @{
    "TailoredExperiencesWithDiagnosticData" = 0
    "TailoredExperiencesWithDiagnosticDataEnabled" = 0
    "PublishUserActivities" = 0
    "ActivityHistoryEnabled" = 0
    "EnableActivityFeed" = 0
    "AllowInputPersonalization" = 0
    "AllowClipboardHistory" = 0
    "AllowCloudClipboard" = 0
}

foreach ($setting in $PrivacySettings2.Keys) {
    Set-ItemProperty -Path $PrivacyPath2 -Name $setting -Value $PrivacySettings2[$setting] -Type DWord -Force
}

Write-Log "Privacy settings applied" "INFO"

# Windows 12 OOBE Branding Configuration
if ($CustomBranding) {
    Write-Log "Applying Windows 12 custom branding..." "INFO"
    
    $BrandingPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
    if (-not (Test-Path $BrandingPath)) {
        New-Item -Path $BrandingPath -Force | Out-Null
    }
    
    $BrandingInfo = @{
        "Logo" = "C:\Windows\System32\Windows12\OOBE\Branding\logo.png"
        "Manufacturer" = "Macrohard Corporation"
        "Model" = "Windows 12"
        "SupportHours" = "24/7"
        "SupportPhone" = "+1 (800) MACROHARD"
        "SupportURL" = "https://www.macrohard.com/windows/12"
        "OEMLogo" = "C:\Windows\System32\Windows12\OOBE\Branding\logo.png"
    }
    
    foreach ($info in $BrandingInfo.Keys) {
        Set-ItemProperty -Path $BrandingPath -Name $info -Value $BrandingInfo[$info] -Type String -Force
    }
    
    Write-Log "Windows 12 branding applied" "INFO"
}

# Create Windows 12 OOBE Branding Files
$BrandingFiles = @{
    "$env:SystemRoot\System32\Windows12\OOBE\Branding\logo.png" = @"
    Windows 12 Logo Placeholder
    Replace with actual logo from https://windows-12-web.vercel.app/
    Concept by: immobilesmile70 | he/him
"@
    "$env:SystemRoot\System32\Windows12\OOBE\Branding\background.jpg" = @"
    Windows 12 OOBE Background Placeholder
    Replace with actual background from https://windows-12-web.vercel.app/
    Concept by: immobilesmile70 | he/him
"@
    "$env:SystemRoot\System32\Windows12\OOBE\Branding\wallpaper.jpg" = @"
    Windows 12 OOBE Wallpaper Placeholder
    Replace with actual wallpaper from https://windows-12-web.vercel.app/
    Concept by: immobilesmile70 | he/him
"@
    "$env:SystemRoot\System32\Windows12\OOBE\Branding\windows12-logo.png" = @"
    Windows 12 Logo for OOBE
    Replace with actual logo from https://windows-12-web.vercel.app/
    Concept by: immobilesmile70 | he/him
"@
}

foreach ($file in $BrandingFiles.Keys) {
    if (-not (Test-Path $file)) {
        $BrandingFiles[$file] | Out-File -FilePath $file -Encoding UTF8
        Write-Log "Created branding file: $file" "INFO"
    }
}

# Create Windows 12 OOBE Completion Markers
$OOBEMarkers = @(
    "$env:SystemRoot\System32\windows12-oobe-complete.flag",
    "$env:SystemRoot\System32\windows12-oobe-branding-complete.flag",
    "$env:SystemRoot\System32\windows12-oobe-bypass-complete.flag"
)

foreach ($marker in $OOBEMarkers) {
    if (-not (Test-Path $marker)) {
        New-Item -Path $marker -ItemType File -Force | Out-Null
        Write-Log "Created OOBE completion marker: $marker" "INFO"
    }
}

# Create Windows 12 OOBE Visual Style Configuration
$VisualStylePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\VisualStyle"
if (-not (Test-Path $VisualStylePath)) {
    New-Item -Path $VisualStylePath -Force | Out-Null
}

$VisualStyleSettings = @{
    "BorderColor" = "#0078D4"
    "BorderWidth" = 2
    "RoundedCorners" = 12
    "ShadowEffect" = 1
    "Transparency" = 1
}

foreach ($setting in $VisualStyleSettings.Keys) {
    Set-ItemProperty -Path $VisualStylePath -Name $setting -Value $VisualStyleSettings[$setting] -Type $(if ($VisualStyleSettings[$setting] -is [int]) { "DWord" } else { "String" }) -Force
}

# Button Style
$ButtonStylePath = "$VisualStylePath\Button"
if (-not (Test-Path $ButtonStylePath)) {
    New-Item -Path $ButtonStylePath -Force | Out-Null
}

$ButtonStyleSettings = @{
    "PrimaryColor" = "#0078D4"
    "PrimaryHover" = "#47A3FF"
    "PrimaryPressed" = "#005A9E"
    "SecondaryColor" = "#333333"
    "SecondaryHover" = "#444444"
    "SecondaryPressed" = "#222222"
    "TextColor" = "#FFFFFF"
    "BorderRadius" = 8
}

foreach ($setting in $ButtonStyleSettings.Keys) {
    Set-ItemProperty -Path $ButtonStylePath -Name $setting -Value $ButtonStyleSettings[$setting] -Type $(if ($ButtonStyleSettings[$setting] -is [int]) { "DWord" } else { "String" }) -Force
}

# Input Style
$InputStylePath = "$VisualStylePath\Input"
if (-not (Test-Path $InputStylePath)) {
    New-Item -Path $InputStylePath -Force | Out-Null
}

$InputStyleSettings = @{
    "BackgroundColor" = "#1C1C1C"
    "BorderColor" = "#444444"
    "FocusBorderColor" = "#0078D4"
    "TextColor" = "#FFFFFF"
    "PlaceholderColor" = "#888888"
    "BorderRadius" = 6
}

foreach ($setting in $InputStyleSettings.Keys) {
    Set-ItemProperty -Path $InputStylePath -Name $setting -Value $InputStyleSettings[$setting] -Type $(if ($InputStyleSettings[$setting] -is [int]) { "DWord" } else { "String" }) -Force
}

# Animation Settings
$AnimationPath = "$VisualStylePath\Animations"
if (-not (Test-Path $AnimationPath)) {
    New-Item -Path $AnimationPath -Force | Out-Null
}

$AnimationSettings = @{
    "EnableEntranceAnimations" = 1
    "EnableExitAnimations" = 1
    "AnimationDuration" = 300
    "AnimationEasing" = "EaseInOut"
}

foreach ($setting in $AnimationSettings.Keys) {
    Set-ItemProperty -Path $AnimationPath -Name $setting -Value $AnimationSettings[$setting] -Type $(if ($AnimationSettings[$setting] -is [int]) { "DWord" } else { "String" }) -Force
}

Write-Log "Windows 12 OOBE visual style applied" "INFO"

# Create Windows 12 OOBE Text Customization
$OOBETextPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\Text"
if (-not (Test-Path $OOBETextPath)) {
    New-Item -Path $OOBETextPath -Force | Out-Null
}

$OOBETextSettings = @{
    "WelcomeTitle" = "Welcome to Windows 12"
    "WelcomeSubtitle" = "The future of computing"
    "SetupCompleteTitle" = "Windows 12 is ready"
    "SetupCompleteSubtitle" = "Enjoy your new experience"
    "ProductName" = "Macrohard Windows 12"
    "VersionString" = "Version 12.0.50023"
    "Copyright" = "(c) Macrohard Corporation. Some rights reserved."
    "BuildString" = "12.0.50023.1000"
}

foreach ($setting in $OOBETextSettings.Keys) {
    Set-ItemProperty -Path $OOBETextPath -Name $setting -Value $OOBETextSettings[$setting] -Type String -Force
}

Write-Log "Windows 12 OOBE text customization applied" "INFO"

# Create Windows 12 OOBE System Configuration
$OOBESystemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\OOBE"
if (-not (Test-Path $OOBESystemPath)) {
    New-Item -Path $OOBESystemPath -Force | Out-Null
}

$OOBESystemSettings = @{
    "SkipWelcome" = 1
    "SkipEULA" = 1
    "SkipProductKey" = 1
    "SkipNetwork" = 1
    "SkipMachineOOBE" = 1
    "SkipUserOOBE" = 1
}

foreach ($setting in $OOBESystemSettings.Keys) {
    Set-ItemProperty -Path $OOBESystemPath -Name $setting -Value $OOBESystemSettings[$setting] -Type DWord -Force
}

# OOBE Completion Settings
$OOBECompletionPath = "HKLM:\SYSTEM\Setup\OOBE"
if (-not (Test-Path $OOBECompletionPath)) {
    New-Item -Path $OOBECompletionPath -Force | Out-Null
}

$OOBECompletionSettings = @{
    "Complete" = 1
    "SkipWelcome" = 1
    "SkipEULA" = 1
}

foreach ($setting in $OOBECompletionSettings.Keys) {
    Set-ItemProperty -Path $OOBECompletionPath -Name $setting -Value $OOBECompletionSettings[$setting] -Type DWord -Force
}

Write-Log "Windows 12 OOBE system configuration applied" "INFO"

# Finalize Windows 12 OOBE Transformation
Write-Log "Windows 12 OOBE Engine completed successfully" "SUCCESS"
Write-Log "Transformation Date: $($Windows12OOBEConfig.TransformationDate)" "INFO"
Write-Log "Concept by: immobilesmile70 | he/him" "INFO"
Write-Log "Source: https://windows-12-web.vercel.app/" "INFO"

# Display completion message
Write-Host @"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   Windows 12 OOBE Transformation Complete!                               ║
║                                                                          ║
║   Your Windows 11 25H2 OOBE has been transformed to Windows 12 style     ║
║   Including custom branding, bypass settings, and visual styling        ║
║                                                                          ║
║   Concept by: immobilesmile70 | he/him                                  ║
║   Game Dev | Web Dev | UI/UX Enthusiast                              ║
║   Source: https://windows-12-web.vercel.app/                         ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Exit successfully
exit 0
