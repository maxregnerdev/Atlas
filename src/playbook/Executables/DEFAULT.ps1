# Windows 11 29H1 Default Configuration Script
# Applies 29H1 default settings to Windows 11 25H2

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
}

Write-Host "=== Windows 11 29H1 Default Configuration ===" -ForegroundColor Cyan

$windir = [Environment]::GetFolderPath('Windows')

# Check if 29H1 transformation is active
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode
    if ($29h1Mode -eq 1) {
        Write-Host "29H1 Mode detected - Applying 29H1 defaults" -ForegroundColor Green
    }
}

# Apply 29H1 default .cmd scripts
$folderItems = Get-ChildItem -Path "$windir\29H1AtlasDesktop\*" -File -Recurse -ErrorAction SilentlyContinue
$pattern = "\(default\)\.cmd"

if ($folderItems) {
    foreach ($script in $folderItems) {
        if ($script.PSChildName -match $pattern) {
            Write-Host "Applying: $($script.PSChildName)" -ForegroundColor Yellow
            Start-Process -FilePath $script.FullName -ArgumentList "/silent /noAction" -Wait
        }
    }
} else {
    # Fallback to AtlasDesktop if 29H1 folder doesn't exist
    $folderItems = Get-ChildItem -Path "$windir\AtlasDesktop\*" -File -Recurse -ErrorAction SilentlyContinue
    foreach ($script in $folderItems) {
        if ($script.PSChildName -match $pattern) {
            Write-Host "Applying (fallback): $($script.PSChildName)" -ForegroundColor Yellow
            Start-Process -FilePath $script.FullName -ArgumentList "/silent /noAction" -Wait
        }
    }
}

# Apply 29H1 specific registry defaults
Write-Host "Applying 29H1 registry defaults..." -ForegroundColor Yellow

# 29H1 Explorer defaults
$explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $explorerPath -Name "Start_ShowAllApps" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecentApps" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "ShowAllFolders" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

# 29H1 Theme defaults
$themePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# 29H1 Performance defaults
$priorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Priority"
Set-ItemProperty -Path $priorityPath -Name "EnableAllPerformanceOptimizations" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

Write-Host "29H1 Default Configuration Complete" -ForegroundColor Green
exit 0
