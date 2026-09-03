# Windows 11 29H1 Default Configuration Script
# Applies 29H1 default settings to Windows 11 25H2

.\29H1AtlasModules\initPowerShell.ps1

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
}

Write-Host "=== Windows 11 29H1 Default Configuration ===" -ForegroundColor Cyan

$windir = [Environment]::GetFolderPath('Windows')

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
    if ($29h1Mode) {
        Write-Host "29H1 Mode detected - Applying 29H1 defaults" -ForegroundColor Green
    }
}

# Apply 29H1 default .cmd scripts
# Check 29H1AtlasDesktop first, then fallback to AtlasDesktop
$desktopFolders = @("29H1AtlasDesktop", "AtlasDesktop")
$pattern = "\(default\)\.cmd"
$scriptsFound = $false

foreach ($desktopFolder in $desktopFolders) {
    $folderPath = Join-Path $windir $desktopFolder
    if (Test-Path $folderPath) {
        $folderItems = Get-ChildItem -Path "$folderPath\*" -File -Recurse -ErrorAction SilentlyContinue
        foreach ($script in $folderItems) {
            if ($script.PSChildName -match $pattern) {
                if ($desktopFolder -eq "29H1AtlasDesktop") {
                    Write-Host "Applying 29H1: $($script.PSChildName)" -ForegroundColor Yellow
                } else {
                    Write-Host "Applying (fallback): $($script.PSChildName)" -ForegroundColor Gray
                }
                Start-Process -FilePath $script.FullName -ArgumentList "/silent /noAction" -Wait
                $scriptsFound = $true
            }
        }
        if ($scriptsFound) { break }
    }
}

if (-not $scriptsFound) {
    Write-Host "No default scripts found in 29H1AtlasDesktop or AtlasDesktop" -ForegroundColor Yellow
}

# Apply 29H1 specific registry defaults
Write-Host "Applying 29H1 registry defaults..." -ForegroundColor Yellow

# 29H1 Explorer defaults
$explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $explorerPath -Name "Start_ShowAllApps" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecentApps" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "ShowAllFolders" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "TaskbarAlignment" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "TaskbarSmallIcons" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

# 29H1 Theme defaults
$themePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# 29H1 Performance defaults
$priorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Priority"
Set-ItemProperty -Path $priorityPath -Name "EnableAllPerformanceOptimizations" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

# 29H1 Search defaults
$searchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
Set-ItemProperty -Path $searchPath -Name "AllowCortana" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $searchPath -Name "DisableWebSearch" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

# Set 29H1 default configuration flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Defaults_Configured" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $29h1Path -Name "DefaultsDate" -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Type String -Force

Write-Host "29H1 Default Configuration Complete" -ForegroundColor Green
exit 0
