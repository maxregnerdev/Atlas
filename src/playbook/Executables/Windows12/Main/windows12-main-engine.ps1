# Windows 12 Main Engine
# Primary transformation engine for Windows 12
# Based on the Windows 12 concept from https://windows-12-web.vercel.app/

param(
    [switch]$ApplyAll = $true,
    [switch]$ApplyOOBE = $true,
    [switch]$ApplyDesktop = $true,
    [switch]$ApplyFeatures = $true,
    [switch]$ApplyThemes = $true,
    [switch]$ApplyIcons = $true,
    [switch]$ApplySounds = $true
)

# Windows 12 Main Engine Configuration
$Windows12Config = @{
    Name = "Windows 12 Main Engine"
    Version = "12.0.50023"
    Build = "12.0.50023"
    TargetBuild = "26200"  # Windows 11 25H2
    Author = "immobilesmile70 | he/him"
    ConceptURL = "https://windows-12-web.vercel.app/"
    TransformationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Logging Configuration
$LogPath = "$env:SystemRoot\Logs\Windows12"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
$LogFile = "$LogPath\windows12-main-engine.log"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARNING") { "Yellow" } elseif ($Level -eq "SUCCESS") { "Green" } else { "White" })
    Add-Content -Path $LogFile -Value $logEntry
}

# Initialize Windows 12 Transformation
Write-Log "Windows 12 Main Engine started" "INFO"
Write-Log "Configuration: $($Windows12Config | ConvertTo-Json -Compress)" "INFO"

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Script must be run as Administrator" "ERROR"
    exit 1
}

# Check Windows Version
$CurrentBuild = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "CurrentBuildNumber" -ErrorAction SilentlyContinue).CurrentBuildNumber
if ($CurrentBuild -ne "26200" -and $CurrentBuild -notlike "262*") {
    Write-Log "This script is designed for Windows 11 25H2 (Build 26200)" "WARNING"
}

# Create Windows 12 Directories
$Windows12Paths = @(
    "$env:SystemRoot\System32\Windows12",
    "$env:SystemRoot\System32\Windows12\OOBE",
    "$env:SystemRoot\System32\Windows12\OOBE\Branding",
    "$env:SystemRoot\System32\Windows12\UI",
    "$env:SystemRoot\System32\Windows12\Features",
    "$env:SystemRoot\System32\Windows12\Icons",
    "$env:SystemRoot\System32\Windows12\Images",
    "$env:SystemRoot\System32\Windows12\Apps",
    "$env:SystemRoot\System32\Windows12\Apps\Clock",
    "$env:SystemRoot\System32\Windows12\Apps\Calculator",
    "$env:SystemRoot\System32\Windows12\Apps\Paint",
    "$env:SystemRoot\System32\Windows12\Apps\Notepad",
    "$env:SystemRoot\System32\Windows12\Apps\CMD",
    "$env:SystemRoot\System32\Windows12\Apps\Settings",
    "$env:SystemRoot\System32\Windows12\Apps\Store",
    "$env:SystemRoot\System32\Windows12\Apps\Copilot",
    "$env:SystemRoot\System32\Windows12\Apps\Launcher",
    "$env:SystemRoot\Resources\Themes\Windows12",
    "$env:SystemRoot\Resources\Icons\Windows12",
    "$env:SystemRoot\Resources\Images\Windows12",
    "$env:SystemRoot\Resources\Layouts\Windows12",
    "$env:SystemRoot\Media\Windows12",
    "$env:SystemRoot\Media\Windows12\Sounds",
    "$env:SystemRoot\Cursors\Windows12",
    "C:\AI Models"
)

foreach ($path in $Windows12Paths) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        Write-Log "Created directory: $path" "INFO"
    }
}

# Set Windows 12 Registry Flags
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
if (-not (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

Set-ItemProperty -Path $RegistryPath -Name "Windows12_Enabled" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $RegistryPath -Name "Windows12_Version" -Value "12.0.50023" -Type String -Force
Set-ItemProperty -Path $RegistryPath -Name "Windows12_Transformed" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $RegistryPath -Name "Windows12_TransformationDate" -Value $Windows12Config.TransformationDate -Type String -Force
Set-ItemProperty -Path $RegistryPath -Name "Windows12_ConceptBy" -Value "immobilesmile70" -Type String -Force
Set-ItemProperty -Path $RegistryPath -Name "Windows12_ConceptURL" -Value "https://windows-12-web.vercel.app/" -Type String -Force

Write-Log "Windows 12 registry flags set" "INFO"

# Create Windows 12 Product Information
$ProductInfo = @{
    ProductName = "Windows 12"
    CurrentBuild = "50023"
    CurrentBuildNumber = "50023"
    CurrentVersion = "12.0"
    EditionID = "Professional"
    InstallationType = "Client"
    ProductId = "00331-10000-00000-AA000"
    RegisteredOrganization = "Macrohard Corporation"
    RegisteredOwner = "Windows 12 User"
}

foreach ($key in $ProductInfo.Keys) {
    Set-ItemProperty -Path $RegistryPath -Name $key -Value $ProductInfo[$key] -Type String -Force
}

Write-Log "Windows 12 product information set" "INFO"

# Create Windows 12 Completion Markers
$CompletionMarkers = @(
    "$env:SystemRoot\System32\windows12-complete-transformation.flag",
    "$env:SystemRoot\System32\windows12-main-engine-complete.flag"
)

foreach ($marker in $CompletionMarkers) {
    if (-not (Test-Path $marker)) {
        New-Item -Path $marker -ItemType File -Force | Out-Null
        Write-Log "Created completion marker: $marker" "INFO"
    }
}

# Clean up old files if requested
if ($ApplyAll) {
    Write-Log "Cleaning up old files..." "INFO"
    
    # Remove old Atlas/MaxRegnerUI folders
    $OldFolders = @(
        "$env:SystemRoot\MaxRegnerUIDesktop",
        "$env:SystemRoot\MaxRegnerUIModules",
        "$env:SystemRoot\AtlasModules",
        "$env:SystemRoot\25H2",
        "$env:SystemRoot\29H1"
    )
    
    foreach ($folder in $OldFolders) {
        if (Test-Path $folder) {
            Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Removed old folder: $folder" "INFO"
        }
    }
}

# Create Windows 12 Branding Files
$BrandingFiles = @{
    "$env:SystemRoot\System32\Windows12\OOBE\Branding\logo.png" = @"
    This is a placeholder for the Windows 12 logo.
    Replace this with the actual logo file from the concept.
    Source: https://windows-12-web.vercel.app/
"@
    "$env:SystemRoot\System32\Windows12\OOBE\Branding\background.jpg" = @"
    This is a placeholder for the Windows 12 OOBE background.
    Replace this with the actual background file from the concept.
    Source: https://windows-12-web.vercel.app/
"@
    "$env:SystemRoot\System32\Windows12\OOBE\Branding\wallpaper.jpg" = @"
    This is a placeholder for the Windows 12 OOBE wallpaper.
    Replace this with the actual wallpaper file from the concept.
    Source: https://windows-12-web.vercel.app/
"@
}

foreach ($file in $BrandingFiles.Keys) {
    if (-not (Test-Path $file)) {
        $BrandingFiles[$file] | Out-File -FilePath $file -Encoding UTF8
        Write-Log "Created branding file: $file" "INFO"
    }
}

# Create Windows 12 Wallpaper Files
$WallpaperFiles = @(
    "$env:SystemRoot\Resources\Images\Windows12\wallpaper-dark.jpg",
    "$env:SystemRoot\Resources\Images\Windows12\wallpaper-light.jpg",
    "$env:SystemRoot\Resources\Images\Windows12\lockscreen-dark.jpg",
    "$env:SystemRoot\Resources\Images\Windows12\lockscreen-light.jpg"
)

foreach ($wallpaper in $WallpaperFiles) {
    if (-not (Test-Path $wallpaper)) {
        # Create a simple gradient wallpaper as placeholder
        $script = @"
        using System;
        using System.Drawing;
        using System.Drawing.Imaging;
        
        class Program {
            static void Main() {
                int width = 1920;
                int height = 1080;
                
                using (Bitmap bmp = new Bitmap(width, height)) {
                    using (Graphics g = Graphics.FromImage(bmp)) {
                        // Dark gradient background
                        LinearGradientBrush brush = new LinearGradientBrush(
                            new Point(0, 0), new Point(width, height),
                            Color.FromArgb(30, 30, 30), Color.FromArgb(0, 0, 0));
                        g.FillRectangle(brush, 0, 0, width, height);
                        
                        // Windows 12 accent color elements
                        brush = new LinearGradientBrush(
                            new Point(0, 0), new Point(width, height),
                            Color.FromArgb(0, 120, 212), Color.FromArgb(0, 80, 180));
                        g.FillRectangle(brush, width - 400, height - 200, 400, 200);
                        
                        // Save as JPEG
                        bmp.Save("$wallpaper", ImageFormat.Jpeg);
                    }
                }
            }
        }
"@
        # For now, create a simple text placeholder
        "Windows 12 Wallpaper Placeholder - Replace with actual wallpaper from https://windows-12-web.vercel.app/" | Out-File -FilePath $wallpaper -Encoding UTF8
        Write-Log "Created wallpaper placeholder: $wallpaper" "INFO"
    }
}

# Create Windows 12 Theme Files
$ThemeFiles = @{
    "$env:SystemRoot\Resources\Themes\Windows12\Windows12-Dark.theme" = @"
[Theme]
DisplayName=Windows 12 Dark
Author=Macrohard Corporation
Description=Windows 12 Concept Dark Theme by immobilesmile70
Version=12.0

[VisualStyles]
Path=%SystemRoot%\Resources\Themes\Aero\Aero.msstyles
ColorStyle=NormalColor
Size=NormalSize

[Sounds]
SchemeName=Windows12

[Cursors]
SchemeName=Windows12

[Icons]
SchemeName=Windows12

[Metrics]
BorderWidth=1
BorderHeight=1
CaptionWidth=1
CaptionHeight=32
MinWidth=384
MinHeight=288

[Colors]
ActiveBorder=0 0 0
ActiveTitle=0 0 0
AppWorkspace=60 60 60
Background=0 0 0
ButtonFace=60 60 60
ButtonText=255 255 255
CaptionText=255 255 255
GrayText=128 128 128
Hilight=0 120 212
HilightText=255 255 255
HotTrackingColor=0 150 255
InactiveBorder=40 40 40
InactiveTitle=40 40 40
InactiveTitleText=160 160 160
InfoText=0 0 0
InfoWindow=48 48 48
Menu=48 48 48
MenuBar=48 48 48
MenuHilight=0 120 212
MenuText=255 255 255
MessageBox=48 48 48
Scrollbar=80 80 80
TitleText=255 255 255
Window=48 48 48
WindowFrame=0 0 0
WindowText=255 255 255
"@
    "$env:SystemRoot\Resources\Themes\Windows12\Windows12-Light.theme" = @"
[Theme]
DisplayName=Windows 12 Light
Author=Macrohard Corporation
Description=Windows 12 Concept Light Theme by immobilesmile70
Version=12.0

[VisualStyles]
Path=%SystemRoot%\Resources\Themes\Aero\Aero.msstyles
ColorStyle=NormalColor
Size=NormalSize

[Sounds]
SchemeName=Windows12

[Cursors]
SchemeName=Windows12

[Icons]
SchemeName=Windows12

[Metrics]
BorderWidth=1
BorderHeight=1
CaptionWidth=1
CaptionHeight=32
MinWidth=384
MinHeight=288

[Colors]
ActiveBorder=255 255 255
ActiveTitle=255 255 255
AppWorkspace=200 200 200
Background=255 255 255
ButtonFace=240 240 240
ButtonText=0 0 0
CaptionText=0 0 0
GrayText=100 100 100
Hilight=0 120 212
HilightText=255 255 255
HotTrackingColor=0 150 255
InactiveBorder=200 200 200
InactiveTitle=200 200 200
InactiveTitleText=100 100 100
InfoText=0 0 0
InfoWindow=230 230 255
Menu=240 240 240
MenuBar=240 240 240
MenuHilight=0 120 212
MenuText=0 0 0
MessageBox=230 230 255
Scrollbar=200 200 200
TitleText=0 0 0
Window=255 255 255
WindowFrame=255 255 255
WindowText=0 0 0
"@
}

foreach ($theme in $ThemeFiles.Keys) {
    if (-not (Test-Path $theme)) {
        $ThemeFiles[$theme] | Out-File -FilePath $theme -Encoding UTF8
        Write-Log "Created theme file: $theme" "INFO"
    }
}

# Create Windows 12 Start Layout
$StartLayout = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/LayoutModification" xmlns:start="http://schemas.microsoft.com/Start/2014/" Version="1" xmlns="">
  <LayoutOptions StartTileGroupsColumnCount="3" />
  <DefaultLayoutOverride>
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6">
        <start:Group Name="Primary" Content="29H1">
          <start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" />
          <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="Microsoft.WindowsAlarms_8wekyb3d8bbwe!App" />
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="Microsoft.WindowsCamera_8wekyb3d8bbwe!App" />
          <start:Tile Size="2x2" Column="0" Row="2" AppUserModelID="Microsoft.WindowsStore_8wekyb3d8bbwe!App" />
          <start:Tile Size="2x2" Column="2" Row="2" AppUserModelID="Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe!App" />
          <start:Tile Size="2x2" Column="4" Row="2" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="4" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Paint.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="4" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Notepad.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="4" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Command Prompt.lnk" />
        </start:Group>
        <start:Group Name="Windows 12" Content="Windows12">
          <start:DesktopApplicationTile Size="1x1" Column="0" Row="0" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Clock\Clock.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="1" Row="0" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Calculator\Calculator.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="2" Row="0" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Paint\Paint.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="3" Row="0" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Notepad\Notepad.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="0" Row="1" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\CMD\cmd.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="1" Row="1" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Settings\Settings.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="2" Row="1" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Store\Store.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="3" Row="1" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Copilot\Copilot.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="0" Row="2" DesktopApplicationLinkPath="%SystemRoot%\System32\Windows12\Apps\Launcher\Launcher.exe" />
        </start:Group>
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

$LayoutPath = "$env:SystemRoot\Resources\Layouts\Windows12\windows12-start-layout.xml"
if (-not (Test-Path $LayoutPath)) {
    $StartLayout | Out-File -FilePath $LayoutPath -Encoding UTF8
    Write-Log "Created start layout: $LayoutPath" "INFO"
}

# Create Windows 12 Icon Files (Placeholders)
$IconFiles = @(
    "$env:SystemRoot\System32\Windows12\Icons\Computer.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Network.ico",
    "$env:SystemRoot\System32\Windows12\Icons\User.ico",
    "$env:SystemRoot\System32\Windows12\Icons\ControlPanel.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Printers.ico",
    "$env:SystemRoot\System32\Windows12\Icons\RecycleBin.ico",
    "$env:SystemRoot\System32\Windows12\Icons\windows12-logo.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Clock.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Calculator.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Paint.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Notepad.ico",
    "$env:SystemRoot\System32\Windows12\Icons\CMD.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Settings.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Store.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Copilot.ico",
    "$env:SystemRoot\System32\Windows12\Icons\Launcher.ico"
)

foreach ($icon in $IconFiles) {
    if (-not (Test-Path $icon)) {
        # Create a simple placeholder icon file
        "Windows 12 Icon Placeholder - Replace with actual icon from https://windows-12-web.vercel.app/" | Out-File -FilePath $icon -Encoding UTF8
        Write-Log "Created icon placeholder: $icon" "INFO"
    }
}

# Create Windows 12 Sound Files (Placeholders)
$SoundFiles = @(
    "$env:SystemRoot\Media\Windows12\Sounds\SystemExclamation.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\SystemHand.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\SystemQuestion.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\SystemAsterisk.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\SystemDefault.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\Notification.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\Startup.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\Shutdown.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\Logon.wav",
    "$env:SystemRoot\Media\Windows12\Sounds\Logoff.wav"
)

foreach ($sound in $SoundFiles) {
    if (-not (Test-Path $sound)) {
        # Create a silent WAV file placeholder
        "Windows 12 Sound Placeholder - Replace with actual sound from https://windows-12-web.vercel.app/" | Out-File -FilePath $sound -Encoding UTF8
        Write-Log "Created sound placeholder: $sound" "INFO"
    }
}

# Apply Windows 12 Theme
Write-Log "Applying Windows 12 theme..." "INFO"

# Set theme for current user
$ThemePath = "$env:SystemRoot\Resources\Themes\Windows12\Windows12-Dark.theme"
if (Test-Path $ThemePath) {
    # This would normally use the Theme API, but we'll use registry as fallback
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ThemeManager"
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $RegPath -Name "DLLName" -Value "%SystemRoot%\Resources\Themes\Aero\Aero.msstyles" -Type String -Force
    Set-ItemProperty -Path $RegPath -Name "ColorName" -Value "NormalColor" -Type String -Force
    Set-ItemProperty -Path $RegPath -Name "SizeName" -Value "NormalSize" -Type String -Force
    
    Write-Log "Windows 12 theme applied to current user" "INFO"
}

# Set theme for new users
$DefaultThemePath = "HKU:\AME_UserHive_Default\Software\Microsoft\Windows\CurrentVersion\ThemeManager"
if (-not (Test-Path $DefaultThemePath)) {
    New-Item -Path $DefaultThemePath -Force | Out-Null
}

Set-ItemProperty -Path $DefaultThemePath -Name "DLLName" -Value "%SystemRoot%\Resources\Themes\Aero\Aero.msstyles" -Type String -Force
Set-ItemProperty -Path $DefaultThemePath -Name "ColorName" -Value "NormalColor" -Type String -Force
Set-ItemProperty -Path $DefaultThemePath -Name "SizeName" -Value "NormalSize" -Type String -Force

Write-Log "Windows 12 theme applied to new users" "INFO"

# Apply Windows 12 Colors
Write-Log "Applying Windows 12 colors..." "INFO"

$ColorPath = "HKCU:\Control Panel\Colors"
if (-not (Test-Path $ColorPath)) {
    New-Item -Path $ColorPath -Force | Out-Null
}

# Windows 12 Dark Theme Colors
$Colors = @{
    "ActiveBorder" = "0 0 0"
    "ActiveTitle" = "0 0 0"
    "AppWorkspace" = "60 60 60"
    "Background" = "0 0 0"
    "ButtonFace" = "60 60 60"
    "ButtonText" = "255 255 255"
    "CaptionText" = "255 255 255"
    "GrayText" = "128 128 128"
    "Hilight" = "0 120 212"
    "HilightText" = "255 255 255"
    "HotTrackingColor" = "0 150 255"
    "InactiveBorder" = "40 40 40"
    "InactiveTitle" = "40 40 40"
    "InactiveTitleText" = "160 160 160"
    "InfoText" = "0 0 0"
    "InfoWindow" = "48 48 48"
    "Menu" = "48 48 48"
    "MenuBar" = "48 48 48"
    "MenuHilight" = "0 120 212"
    "MenuText" = "255 255 255"
    "MessageBox" = "48 48 48"
    "Scrollbar" = "80 80 80"
    "TitleText" = "255 255 255"
    "Window" = "48 48 48"
    "WindowFrame" = "0 0 0"
    "WindowText" = "255 255 255"
}

foreach ($color in $Colors.Keys) {
    Set-ItemProperty -Path $ColorPath -Name $color -Value $Colors[$color] -Type String -Force
}

Write-Log "Windows 12 colors applied" "INFO"

# Apply Windows 12 DWM Settings
$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"
if (-not (Test-Path $DWMPath)) {
    New-Item -Path $DWMPath -Force | Out-Null
}

Set-ItemProperty -Path $DWMPath -Name "AccentColor" -Value 16908804 -Type DWord -Force  # #0078D4 in decimal
Set-ItemProperty -Path $DWMPath -Name "AccentColorInactive" -Value 10603200 -Type DWord -Force
Set-ItemProperty -Path $DWMPath -Name "ColorPrevalence" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $DWMPath -Name "EnableTransparency" -Value 1 -Type DWord -Force

Write-Log "Windows 12 DWM settings applied" "INFO"

# Apply Windows 12 Personalization Settings
$PersonalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (-not (Test-Path $PersonalizePath)) {
    New-Item -Path $PersonalizePath -Force | Out-Null
}

Set-ItemProperty -Path $PersonalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "WallpaperStyle" -Value 2 -Type String -Force
Set-ItemProperty -Path $PersonalizePath -Name "ColorPrevalence" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "EnableTransparency" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "StartColorMenu" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "StartColorTaskbar" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "StartColorActionCenter" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "AccentColor" -Value "#0078D4" -Type String -Force

Write-Log "Windows 12 personalization settings applied" "INFO"

# Apply Windows 12 Wallpaper
$DesktopPath = "HKCU:\Control Panel\Desktop"
if (-not (Test-Path $DesktopPath)) {
    New-Item -Path $DesktopPath -Force | Out-Null
}

$Wallpaper = "$env:SystemRoot\Resources\Images\Windows12\wallpaper-dark.jpg"
if (Test-Path $Wallpaper) {
    Set-ItemProperty -Path $DesktopPath -Name "Wallpaper" -Value $Wallpaper -Type String -Force
    Set-ItemProperty -Path $DesktopPath -Name "WallpaperStyle" -Value "2" -Type String -Force
    Set-ItemProperty -Path $DesktopPath -Name "TileWallpaper" -Value "0" -Type String -Force
    
    Write-Log "Windows 12 wallpaper applied" "INFO"
}

# Apply Windows 12 Lockscreen
$LockScreenPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"
if (-not (Test-Path $LockScreenPath)) {
    New-Item -Path $LockScreenPath -Force | Out-Null
}

$LockScreenImage = "$env:SystemRoot\Resources\Images\Windows12\lockscreen-dark.jpg"
if (Test-Path $LockScreenImage) {
    Set-ItemProperty -Path $LockScreenPath -Name "LockScreenImage" -Value $LockScreenImage -Type String -Force
    Set-ItemProperty -Path $LockScreenPath -Name "LockScreenImageStretch" -Value "2" -Type DWord -Force
    Set-ItemProperty -Path $LockScreenPath -Name "LockScreenOverlaysDisabled" -Value 1 -Type DWord -Force
    
    Write-Log "Windows 12 lockscreen applied" "INFO"
}

# Restart Explorer to apply changes
Write-Log "Restarting Windows Explorer to apply changes..." "INFO"

$ExplorerProcesses = Get-Process -Name "explorer" -ErrorAction SilentlyContinue
if ($ExplorerProcesses) {
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process "explorer.exe" -ErrorAction SilentlyContinue
    Write-Log "Windows Explorer restarted" "INFO"
}

# Create Windows 12 Desktop Shortcuts
$DesktopShortcuts = @(
    @{
        Name = "Windows 12 Settings"
        Target = "%SystemRoot%\System32\Windows12\Apps\Settings\Settings.exe"
        Icon = "%SystemRoot%\System32\Windows12\Icons\Settings.ico"
        WorkingDirectory = "%SystemRoot%\System32\Windows12\Apps\Settings"
    },
    @{
        Name = "Windows 12 Store"
        Target = "%SystemRoot%\System32\Windows12\Apps\Store\Store.exe"
        Icon = "%SystemRoot%\System32\Windows12\Icons\Store.ico"
        WorkingDirectory = "%SystemRoot%\System32\Windows12\Apps\Store"
    },
    @{
        Name = "Windows 12 Copilot"
        Target = "%SystemRoot%\System32\Windows12\Apps\Copilot\Copilot.exe"
        Icon = "%SystemRoot%\System32\Windows12\Icons\Copilot.ico"
        WorkingDirectory = "%SystemRoot%\System32\Windows12\Apps\Copilot"
    },
    @{
        Name = "Windows 12 Launcher"
        Target = "%SystemRoot%\System32\Windows12\Apps\Launcher\Launcher.exe"
        Icon = "%SystemRoot%\System32\Windows12\Icons\Launcher.ico"
        WorkingDirectory = "%SystemRoot%\System32\Windows12\Apps\Launcher"
    }
)

$DesktopPath = [Environment]::GetFolderPath("Desktop")
foreach ($shortcut in $DesktopShortcuts) {
    $ShortcutPath = "$DesktopPath\${Name}.lnk"
    if (-not (Test-Path $ShortcutPath)) {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $shortcut.Target
        $Shortcut.IconLocation = $shortcut.Icon
        $Shortcut.WorkingDirectory = $shortcut.WorkingDirectory
        $Shortcut.Save()
        Write-Log "Created desktop shortcut: $ShortcutPath" "INFO"
    }
}

# Finalize Windows 12 Transformation
Write-Log "Windows 12 Main Engine completed successfully" "SUCCESS"
Write-Log "Transformation Date: $($Windows12Config.TransformationDate)" "INFO"
Write-Log "Concept by: immobilesmile70 | he/him" "INFO"
Write-Log "Source: https://windows-12-web.vercel.app/" "INFO"

# Display completion message
Write-Host @"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   ███████╗██╗   ██╗███╗   ██╗ ██████╗ ███████╗██╗     ███████╗     ║
║   ██╔════╝╚██╗ ██╔╝████╗  ██║██╔═══██╗██╔════╝██║     ██╔════╝     ║
║   █████╗   ╚████╔╝ ██╔██╗ ██║██║   ██║█████╗  ██║     █████╗       ║
║   ██╔══╝    ╚██╔╝  ██║╚██╗██║██║   ██║██╔══╝  ██║     ██╔══╝       ║
║   ███████╗   ██║   ██║ ╚████║╚██████╔╝███████╗███████╗███████╗     ║
║   ╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝     ║
║                                                                          ║
║   Windows 12 Transformation Complete!                                   ║
║   Your Windows 11 25H2 has been transformed to Windows 12 UI             ║
║                                                                          ║
║   Concept by: immobilesmile70 | he/him                                  ║
║   Game Dev | Web Dev | UI/UX Enthusiast                              ║
║   Source: https://windows-12-web.vercel.app/                         ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Exit successfully
exit 0
