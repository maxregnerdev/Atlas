# Windows 11 29H1 Desktop Engine
# Complete desktop transformation system for 29H1 experience

param(
    [switch]$ApplyTheme = $true,
    [switch]$ConfigureStartMenu = $true,
    [switch]$ConfigureTaskbar = $true,
    [switch]$ConfigureExplorer = $true,
    [switch]$ConfigureDisplay = $true
)

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Administrator rights required" -ForegroundColor Red
    exit 1
}

Write-Host "=== Windows 11 29H1 Desktop Engine Starting ===" -ForegroundColor Cyan

# ============================================
# 29H1 Desktop - Theme System
# ============================================

function Apply-29H1Theme {
    if (-not $ApplyTheme) { return }
    
    Write-Host "Applying 29H1 Theme..." -ForegroundColor Yellow
    
    try {
        # Set 29H1 dark theme
        $themePath = "$env:windir\Resources\Themes\29h1-dark.theme"
        
        # If custom theme doesn't exist, create it
        if (-not (Test-Path $themePath)) {
            Write-Host "  Creating 29H1 theme file..." -ForegroundColor Gray
            
            $themeContent = @"
[Theme]
DisplayName=@%SystemRoot%\System32\shell32.dll,-14000
ThemeID=29H1-Dark
Author=Microsoft
Description=Windows 11 29H1 Dark Theme

[VisualStyles]
Path=%ResourceDir%\Themes\Aero\Aero.msstyles
ColorStyle=NormalColor
Size=NormalSize
AutoColorization=1
ColorizationColor=0x0078D4

[Sounds]
DefaultValue=%SystemRoot%\Media\Windows Default
Path=%ResourceDir%\Themes\29h1\29h1.scheme

[Boot]
Screensaver=0
SCRNSAVE.EXE=
Wallpaper=
WallpaperStyle=2
TileWallpaper=0
WallpaperOriginX=0
WallpaperOriginY=0
Pattern=
ScreenSaveActive=0
ScreenSaverIsSecure=0
ScreenSaverTimeout=0
WaitToKillAppTimeout=2000
WaitToKillServiceTimeout=2000
WaitToKill=2000
ShellState=29H1
"@
            
            New-Item -Path $themePath -ItemType File -Force | Out-Null
            $themeContent | Out-File -FilePath $themePath -Encoding UTF8 -Force
        }
        
        # Apply the theme
        try {
            Set-Theme -Path $themePath
            Write-Host "  29H1 theme applied" -ForegroundColor Gray
        } catch {
            Write-Host "  Theme application: $_" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "  Theme error: $_" -ForegroundColor Yellow
    }
    
    # Set dark mode
    $personalizePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
    
    # Enable transparency
    Set-ItemProperty -Path $personalizePath -Name "EnableTransparency" -Value 1 -Type DWord -Force
    
    # Set accent colors
    $dwmPath = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"
    Set-ItemProperty -Path $dwmPath -Name "AccentColor" -Value 4278190080 -Type DWord -Force
    Set-ItemProperty -Path $dwmPath -Name "AccentColorInactive" -Value 2147483648 -Type DWord -Force
    
    Write-Host "29H1 Theme Applied" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - Start Menu Configuration
# ============================================

function Configure-29H1StartMenu {
    if (-not $ConfigureStartMenu) { return }
    
    Write-Host "Configuring 29H1 Start Menu..." -ForegroundColor Yellow
    
    $explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # 29H1 Start Menu Features
    Set-ItemProperty -Path $explorerPath -Name "Start_Layout" -Value "29H1" -Type String -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowAllApps" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecentApps" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecommendations" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowStartEverywhere" -Value 1 -Type DWord -Force
    
    # Disable Start menu recommendations
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowUserCloudSync" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowMyGames" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowMyApps" -Value 0 -Type DWord -Force
    
    # Custom Start Menu Layout
    try {
        $layoutPath = "$PSScriptRoot\..\..\Layouts\29h1-start-layout.xml"
        $defaultUserPath = "$env:SystemDrive\Users\Default"
        
        if (Test-Path $layoutPath) {
            Import-StartLayout -LayoutPath $layoutPath -MountPath $defaultUserPath
            Write-Host "  29H1 Start menu layout imported" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Start layout: $_" -ForegroundColor Yellow
    }
    
    Write-Host "29H1 Start Menu Configured" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - Taskbar Configuration
# ============================================

function Configure-29H1Taskbar {
    if (-not $ConfigureTaskbar) { return }
    
    Write-Host "Configuring 29H1 Taskbar..." -ForegroundColor Yellow
    
    $explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # Taskbar Position and Size
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAlignment" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarSmallIcons" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarGlomLevel" -Value 2 -Type DWord -Force
    
    # Enable 29H1 Taskbar Features
    Set-ItemProperty -Path $explorerPath -Name "Taskbar29H1Enabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAutoHide" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAlwaysOnTop" -Value 1 -Type DWord -Force
    
    # Taskbar Items
    Set-ItemProperty -Path $explorerPath -Name "ShowTaskView" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowCortanaButton" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowSearchButton" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowWindowsChatButton" -Value 0 -Type DWord -Force
    
    # Search Box
    $searchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force
    
    Write-Host "29H1 Taskbar Configured" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - File Explorer Configuration
# ============================================

function Configure-29H1Explorer {
    if (-not $ConfigureExplorer) { return }
    
    Write-Host "Configuring 29H1 File Explorer..." -ForegroundColor Yellow
    
    $explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # 29H1 Explorer Features
    Set-ItemProperty -Path $explorerPath -Name "Explorer29H1Enabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_Layout" -Value "29H1" -Type String -Force
    
    # View Settings
    Set-ItemProperty -Path $explorerPath -Name "ShowAllFolders" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Hidden" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowSuperHidden" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "HideFileExt" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowInfoTip" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowPreviewHandlers" -Value 1 -Type DWord -Force
    
    # Navigation Pane
    Set-ItemProperty -Path $explorerPath -Name "NavPaneShowAllFolders" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "NavPaneExpandToCurrentFolder" -Value 1 -Type DWord -Force
    
    # Default View
    Set-ItemProperty -Path $explorerPath -Name "FolderType" -Value "Generic" -Type String -Force
    
    # Disable Cloud Content
    Set-ItemProperty -Path $explorerPath -Name "ShowSyncProviderNotifications" -Value 0 -Type DWord -Force
    
    # Enable new 29H1 Explorer features
    Set-ItemProperty -Path $explorerPath -Name "EnableSnapAssistFlyout" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "EnableClassicContextMenu" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 File Explorer Configured" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - Display Configuration
# ============================================

function Configure-29H1Display {
    if (-not $ConfigureDisplay) { return }
    
    Write-Host "Configuring 29H1 Display Settings..." -ForegroundColor Yellow
    
    # Font Settings
    $desktopPath = "HKCU:\Control Panel\Desktop\WindowMetrics"
    Set-ItemProperty -Path $desktopPath -Name "Shell Icon Size" -Value "32" -Type String -Force
    
    # Font Smoothing
    $fontPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $fontPath -Name "FontSmoothing" -Value "2" -Type DWord -Force
    Set-ItemProperty -Path $fontPath -Name "FontSmoothingOrientation" -Value "1" -Type DWord -Force
    Set-ItemProperty -Path $fontPath -Name "FontSmoothingType" -Value "2" -Type DWord -Force
    Set-ItemProperty -Path $fontPath -Name "FontSmoothingGamma" -Value "1000" -Type DWord -Force
    
    # Display Settings
    Set-ItemProperty -Path $desktopPath -Name "WallpaperStyle" -Value "2" -Type String -Force
    Set-ItemProperty -Path $desktopPath -Name "TileWallpaper" -Value "0" -Type String -Force
    
    # Set 29H1 Wallpaper
    try {
        $wallpaperPath = "$env:windir\AtlasModules\Wallpapers\29h1-dark.png"
        if (Test-Path $wallpaperPath) {
            Set-ItemProperty -Path $desktopPath -Name "Wallpaper" -Value $wallpaperPath -Type String -Force
            Write-Host "  29H1 wallpaper applied" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Wallpaper: $_" -ForegroundColor Yellow
    }
    
    # High DPI Settings
    $graphicsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"
    Set-ItemProperty -Path $graphicsPath -Name "EnableHighDPI" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Display Configured" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - Context Menu
# ============================================

function Configure-29H1ContextMenu {
    Write-Host "Configuring 29H1 Context Menu..." -ForegroundColor Yellow
    
    $explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # Enable new 29H1 context menu
    Set-ItemProperty -Path $explorerPath -Name "ContextMenu29H1" -Value 1 -Type DWord -Force
    
    # Show classic context menu with Shift+RightClick
    Set-ItemProperty -Path $explorerPath -Name "ShowClassicContextMenu" -Value 1 -Type DWord -Force
    
    # Context Menu Settings
    Set-ItemProperty -Path $explorerPath -Name "ExtendedUIHoverTime" -Value 500 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_LargeMFU" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_MediumMFU" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Context Menu Configured" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - System Icons
# ============================================

function Configure-29H1SystemIcons {
    Write-Host "Configuring 29H1 System Icons..." -ForegroundColor Yellow
    
    $explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    
    # System Tray
    Set-ItemProperty -Path $explorerPath -Name "EnableAutoTray" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowAllTray" -Value 1 -Type DWord -Force
    
    # Disable Balloon Tips
    $advancedPath = "$explorerPath\Advanced"
    Set-ItemProperty -Path $advancedPath -Name "EnableBalloonTips" -Value 0 -Type DWord -Force
    
    # Desktop Icons
    $desktopPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    Set-ItemProperty -Path $desktopPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 1 -Type DWord -Force  # Computer
    Set-ItemProperty -Path $desktopPath -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 0 -Type DWord -Force  # Network
    Set-ItemProperty -Path $desktopPath -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Type DWord -Force  # Recycle Bin
    
    Write-Host "29H1 System Icons Configured" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - Window Management
# ============================================

function Configure-29H1WindowManagement {
    Write-Host "Configuring 29H1 Window Management..." -ForegroundColor Yellow
    
    $explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # Enable new 29H1 window management
    Set-ItemProperty -Path $explorerPath -Name "WindowManagement29H1" -Value 1 -Type DWord -Force
    
    # Snap Features
    Set-ItemProperty -Path $explorerPath -Name "EnableSnapAssistFlyout" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "DisableSnapAssist" -Value 0 -Type DWord -Force
    
    # Window Arrangement
    Set-ItemProperty -Path $explorerPath -Name "WindowArrangementActive" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Window Management Configured" -ForegroundColor Green
}

# ============================================
# 29H1 Desktop - Main Execution
# ============================================

try {
    Write-Host "Starting 29H1 desktop transformation..." -ForegroundColor Cyan
    
    # Execute all configuration functions
    Apply-29H1Theme
    Configure-29H1StartMenu
    Configure-29H1Taskbar
    Configure-29H1Explorer
    Configure-29H1Display
    Configure-29H1ContextMenu
    Configure-29H1SystemIcons
    Configure-29H1WindowManagement
    
    # Create completion marker
    $marker = "$env:USERPROFILE\AppData\Local\29h1-desktop-complete.flag"
    New-Item -Path $marker -ItemType File -Force | Out-Null
    
    Write-Host "=== 29H1 Desktop Engine Completed Successfully ===" -ForegroundColor Green
    Write-Host "All 29H1 desktop configurations have been applied." -ForegroundColor Green
    
    # Restart explorer to apply all changes
    try {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process -FilePath "explorer.exe"
        Write-Host "Explorer restarted to apply all desktop changes" -ForegroundColor Gray
    } catch {
        Write-Host "Could not restart explorer: $_" -ForegroundColor Yellow
    }
    
    exit 0
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "29H1 Desktop Engine Failed" -ForegroundColor Red
    exit 1
}
