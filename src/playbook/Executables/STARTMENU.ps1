# Windows 11 29H1 Start Menu Configuration
# Configures Start Menu for 29H1 transformation on 25H2

.\29H1AtlasModules\initPowerShell.ps1

Write-Host "=== Windows 11 29H1 Start Menu Configuration ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
    if ($29h1Mode) {
        Write-Host "29H1 Mode detected - Applying 29H1 Start Menu configuration" -ForegroundColor Green
    }
}

foreach ($userKey in (Get-RegUserPaths).PsPath) {
    $default = if ($userKey -match 'AME_UserHive_Default') { $true }
    $sid = Split-Path $userKey -Leaf

    # Get Local AppData
    $appData = if ($default) {
        Get-UserPath -Folder 'F1B32785-6FBA-4FCF-9D55-7B8E7F157091'
    } else {
        (Get-ItemProperty "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name 'Local AppData' -EA 0).'Local AppData'
    }
    
    Write-Host "Configuring Start Menu for '$sid'..." -ForegroundColor Yellow
    if ([string]::IsNullOrEmpty($appData) -or !(Test-Path $appData)) {
        Write-Error "Couldn't find AppData value for $sid!"
    } else {
        # 29H1: Use 29H1 layout if available
        $29h1Layout = "29h1-Layout.xml"
        $defaultLayout = "Layout.xml"
        
        $layoutToUse = if (Test-Path $29h1Layout) { $29h1Layout } else { $defaultLayout }
        
        Write-Host "Copying 29H1 layout XML: $layoutToUse" -ForegroundColor Gray
        Copy-Item -Path $layoutToUse -Destination "$appData\Microsoft\Windows\Shell\LayoutModification.xml" -Force
        
        # Apply 29H1 specific registry settings
        $startPath = "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        if (-not (Test-Path $startPath)) {
            New-Item -Path $startPath -Force | Out-Null
        }
        
        # 29H1 Start Menu settings
        Set-ItemProperty -Path $startPath -Name "Start_ShowAllApps" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $startPath -Name "Start_ShowRecentApps" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $startPath -Name "Start_ShowRecommendations" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $startPath -Name "Start_ShowUserCloudSync" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        
        if (!$default) {
            Write-Host "Clearing Start Menu pinned items for 29H1" -ForegroundColor Gray

            $packages = Get-ChildItem -Path "$appData\Packages" -Directory -EA 0 | Where-Object { $_.Name -match "Microsoft.Windows.StartMenuExperienceHost" }
            foreach ($package in $packages) {
                $bins = Get-ChildItem -Path "$appData\Packages\$($package.Name)\LocalState" -File -EA 0 | Where-Object { $_.Name -like "start*.bin" }
                foreach ($bin in $bins.FullName) {
                    Remove-Item -Path $bin -Force -EA 0
                }
            }
        }
    }

    if (!$default) {
        Write-Host "Clearing default 'tilegrid' for 29H1" -ForegroundColor Gray
        $tilegrid = Get-ChildItem -Path "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse -EA 0 | Where-Object { $_.Name -match "start.tilegrid" }    
        foreach ($key in $tilegrid) {
            Remove-Item -Path $key.PSPath -Force -EA 0
        }
    }

    # 29H1: Remove advertisements/stubs from Start Menu
    Write-Host "Removing advertisements/stubs from Start Menu (29H1)" -ForegroundColor Gray
    Remove-ItemProperty -Path "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name 'Config' -Force -EA 0
    
    # 29H1: Disable Start Menu recommendations
    Remove-ItemProperty -Path "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name 'ShowRecommendations' -Force -EA 0
    
    # 29H1: Enable all apps view
    Set-ItemProperty -Path "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_ShowAllApps" -Value 1 -Type DWord -Force -EA 0
}

# Set 29H1 Start Menu flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_StartMenu_Configured" -Value 1 -Type DWord -Force

Write-Host "29H1 Start Menu Configuration Complete" -ForegroundColor Green
exit 0
