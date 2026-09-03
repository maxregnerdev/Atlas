# Windows 11 29H1 Default User Hive Application
# Applies HKCU registry settings to default user for 29H1 transformation

# Load DefaultUser hive
$module = Get-Module -Name "FXPSYaml"
if (!$module) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name FXPSYaml -Force
    Import-Module -Name FXPSYaml
}

Write-Host "=== Windows 11 29H1 Default User Hive Application ===" -ForegroundColor Cyan

$configurationFolder = Join-Path $PSScriptRoot "..\Configuration\tweaks"
$yamlFiles = Get-ChildItem -Path $configurationFolder -Filter *.yml -Recurse
$RegistryPaths = @()

# Check for 29H1 configuration folder
$29h1Config = Join-Path $configurationFolder "29h1"
if (Test-Path $29h1Config) {
    Write-Host "29H1 configuration folder found" -ForegroundColor Yellow
}

foreach ($yamlFile in $yamlFiles) {
    try {
        $yamlContent = Get-Content $yamlFile.FullName -Raw
        $parsedYaml = ConvertFrom-Yaml $yamlContent
        foreach ($entry in $parsedYaml) {
            foreach ($value in $entry.actions.path) {
                if ($value -like 'HKCU') {
                    if (!$RegistryPaths.Contains($value.Substring(4))) { 
                        $RegistryPaths += $value.Substring(4) 
                    }
                }
            }
        }
    } catch {
        Write-Warning "Error processing $($yamlFile.FullName): $_"
    }
}

# Apply 29H1 specific default user settings
Write-Host "Applying 29H1 default user settings..." -ForegroundColor Yellow

# 29H1 Theme settings for default user
$29h1ThemePath = "HKU:\AME_UserHive_Default\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (-not (Test-Path $29h1ThemePath)) {
    New-Item -Path $29h1ThemePath -Force | Out-Null
}
Set-ItemProperty -Path $29h1ThemePath -Name "AppsUseLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $29h1ThemePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $29h1ThemePath -Name "WallpaperStyle" -Value 2 -Type DWord
Set-ItemProperty -Path $29h1ThemePath -Name "ColorPrevalence" -Value 0 -Type DWord

# 29H1 Explorer settings for default user
$29h1ExplorerPath = "HKU:\AME_UserHive_Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (-not (Test-Path $29h1ExplorerPath)) {
    New-Item -Path $29h1ExplorerPath -Force | Out-Null
}
Set-ItemProperty -Path $29h1ExplorerPath -Name "Start_ShowAllApps" -Value 1 -Type DWord
Set-ItemProperty -Path $29h1ExplorerPath -Name "Start_ShowRecentApps" -Value 1 -Type DWord
Set-ItemProperty -Path $29h1ExplorerPath -Name "ShowAllFolders" -Value 1 -Type DWord
Set-ItemProperty -Path $29h1ExplorerPath -Name "TaskbarAlignment" -Value 0 -Type DWord
Set-ItemProperty -Path $29h1ExplorerPath -Name "TaskbarSmallIcons" -Value 1 -Type DWord

# Apply all collected registry paths
foreach ($path in $RegistryPaths) {
    $source = "Registry::HKCU\$path"
    $destination = "Registry::HKU\AME_UserHive_Default\$path"
    
    try {
        $values = Get-ItemProperty -Path $source -ErrorAction SilentlyContinue
        if ($values) {
            foreach ($property in $values.PSObject.Properties) {
                if ($property.Name -ne "PSPath" -and $property.Name -ne "PSParentPath" -and $property.Name -ne "PSChildName" -and $property.Name -ne "PSDrive" -and $property.Name -ne "PSProvider") {
                    if (-not (Test-Path $destination)) {
                        New-Item -Path $destination -Force | Out-Null
                    }
                    if (-not ((Get-ItemProperty $destination -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains $property.Name)) {
                        New-ItemProperty -Path $destination -Name $property.Name -Value $property.Value | Out-Null
                    }
                    else {
                        Set-ItemProperty -Path $destination -Name $property.Name -Value $property.Value
                    }
                }
            }
        }
    } catch {
        Write-Warning "Error applying $path : $_"
    }
}

# Set 29H1 flag in default user hive
$29h1FlagPath = "HKU:\AME_UserHive_Default\SOFTWARE\AtlasOS"
if (-not (Test-Path $29h1FlagPath)) {
    New-Item -Path $29h1FlagPath -Force | Out-Null
}
Set-ItemProperty -Path $29h1FlagPath -Name "29H1_DefaultUser_Applied" -Value 1 -Type DWord -Force

Write-Host "29H1 Default User Hive Application Complete" -ForegroundColor Green
