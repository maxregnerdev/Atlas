# MaxRegnerUI System-Wide Icon Replacement Script
# Replaces Windows system icons with MaxRegnerUI custom icon pack

$ErrorActionPreference = "Stop"

# MaxRegnerUI Configuration
$maxregneruiName = "MaxRegnerUI"
$maxregneruiVersion = "1.0.0"
$maxregneruiIconsDir = "$env:ProgramData\$maxregneruiName\Icons"
$maxregneruiThemesDir = "$env:ProgramData\$maxregneruiName\Themes"
$systemRoot = $env:SystemRoot

# Ensure directories exist
if (-not (Test-Path $maxregneruiIconsDir)) {
    New-Item -ItemType Directory -Path $maxregneruiIconsDir -Force | Out-Null
}

# Create registry entries for MaxRegnerUI
New-Item -Path "HKLM:\SOFTWARE\$maxregneruiName" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\$maxregneruiName" -Name "Version" -Value $maxregneruiVersion -Type String -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\$maxregneruiName" -Name "Installed" -Value 1 -Type DWORD -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\$maxregneruiName" -Name "IconPack" -Value "Enabled" -Type String -Force

# Apply MaxRegnerUI theme
$themePath = "$systemRoot\Resources\Themes\maxregnerui-dark.theme"
if (Test-Path $themePath) {
    try {
        $regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager"
        New-Item -Path $regPath -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name "DLLName" -Value "$systemRoot\resources\themes\Aero\Aero.msstyles" -Type String -Force
        Set-ItemProperty -Path $regPath -Name "ColorName" -Value "NormalColor" -Type String -Force
        Set-ItemProperty -Path $regPath -Name "SizeName" -Value "NormalSize" -Type String -Force
        
        # Set theme for current user
        $currentTheme = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager" -ErrorAction SilentlyContinue
        if ($currentTheme -eq $null) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager" -Force | Out-Null
        }
        
        Write-Host "[$maxregneruiName] Theme applied: maxregnerui-dark" -ForegroundColor Cyan
    } catch {
        Write-Host "[$maxregneruiName] Theme apply error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Apply MaxRegnerUI wallpaper
$wallpaperPath = "$systemRoot\AtlasModules\Wallpapers\maxregnerui-dark.png"
if (Test-Path $wallpaperPath) {
    try {
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $wallpaperPath -Type String -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "2" -Type String -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Type String -Force
        
        # Update user profile
        $code = @'
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
    
    public const uint SPI_SETDESKWALLPAPER = 0x0014;
    public const uint SPIF_UPDATEINIFILE = 0x01;
    public const uint SPIF_SENDCHANGE = 0x02;
    
    public static void SetWallpaper(string path) {
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    }
}
'@
        Add-Type -TypeDefinition $code -Language CSharp
        [Wallpaper]::SetWallpaper($wallpaperPath)
        
        Write-Host "[$maxregneruiName] Wallpaper applied: $wallpaperPath" -ForegroundColor Cyan
    } catch {
        Write-Host "[$maxregneruiName] Wallpaper apply error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Apply MaxRegnerUI icon overrides via registry
$iconRegistry = @{
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" = @{
        "3" = "$systemRoot\AtlasModules\Other\maxregnerui-folder.ico,0"
        "4" = "$systemRoot\AtlasModules\Other\maxregnerui-folder.ico,0"
    }
}

foreach ($regPath in $iconRegistry.Keys) {
    New-Item -Path $regPath -Force | Out-Null
    foreach ($entry in $iconRegistry[$regPath].GetEnumerator()) {
        Set-ItemProperty -Path $regPath -Name $entry.Key -Value $entry.Value -Type String -Force
    }
}

# File association icons
$fileAssociations = @{
    ".txt" = "$systemRoot\AtlasModules\Other\maxregnerui-folder.ico,0"
    ".exe" = "$systemRoot\AtlasModules\Other\maxregnerui-folder.ico,0"
    ".bat" = "$systemRoot\AtlasModules\Other\maxregnerui-folder.ico,0"
}

foreach ($ext in $fileAssociations.Keys) {
    $regPath = "HKCU:\SOFTWARE\Classes\$ext\DefaultIcon"
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name "(Default)" -Value $fileAssociations[$ext] -Type String -Force
}

# Clear icon cache
$iconCachePaths = @(
    "$env:LOCALAPPDATA\IconCache.db",
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*",
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache*"
)

foreach ($cachePath in $iconCachePaths) {
    if (Test-Path $cachePath) {
        Remove-Item $cachePath -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# Create MaxRegnerUI desktop shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$maxregneruiDesktop = "$systemRoot\AtlasDesktop"

if (Test-Path $maxregneruiDesktop) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$desktopPath\$maxregneruiName.lnk")
    $Shortcut.TargetPath = $maxregneruiDesktop
    $Shortcut.IconLocation = "$systemRoot\AtlasModules\Other\maxregnerui-folder.ico,0"
    $Shortcut.Save()
}

# Set MaxRegnerUI environment variables
[Environment]::SetEnvironmentVariable("MAXREGNERUI_VERSION", $maxregneruiVersion, "Machine")
[Environment]::SetEnvironmentVariable("MAXREGNERUI_INSTALLED", "1", "Machine")

# Restart explorer to apply changes
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer.exe

Write-Host "[$maxregneruiName] MaxRegnerUI icon pack and theme installed successfully!" -ForegroundColor Green
Write-Host "[$maxregneruiName] Version: $maxregneruiVersion" -ForegroundColor Cyan
