# Windows 11 29H1 Accounts Page Configuration
# Remove ads and configure Accounts page for 29H1

Write-Host "=== Windows 11 29H1 Accounts Page Configuration ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
}

# Variables
$windir = [Environment]::GetFolderPath('Windows')
$settingsExtensions = (Get-ChildItem "$windir\SystemApps" -Recurse -EA 0).FullName | Where-Object { $_ -like '*wsxpacks\Account\SettingsExtensions.json*' }
$arm = ((Get-CimInstance -Class Win32_ComputerSystem).SystemType -match 'ARM64') -or ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64')

# 29H1: Check for 29H1 specific settings
if ($settingsExtensions.Count -eq 0) {
    # Try 29H1 path
    $settingsExtensions = (Get-ChildItem "$windir\SystemApps" -Recurse -EA 0).FullName | Where-Object { $_ -like '*29h1*wsxpacks\Account\SettingsExtensions.json*' }
    
    if ($settingsExtensions.Count -eq 0) {
        Write-Output "Settings extensions not found. User might be on unsupported build."
        Write-Output "Exiting..." -ForegroundColor Yellow
        exit
    }
}

# Finds velocity IDs listed in 'Accounts' wsxpack
function Find-VelocityID($Node) {
    $ids = @()
    if ($Node -is [PSCustomObject]) {
        # If the node is a PSObject, go through through its properties
        foreach ($property in $Node.PSObject.Properties) {
            if ($property.Name -eq 'velocityKey' -and $property.Value.id) {
                $ids += $property.Value.id
            }
            $ids += Find-VelocityID -Node $property.Value
        }
    } elseif ($Node -is [Array]) {
        # If the node is an array, go through its elements
        foreach ($element in $Node) {
            $ids += Find-VelocityID -Node $element
        }
    }

    return $ids
}

$ids = @()
foreach ($settingsJson in $settingsExtensions) {
    try {
        $ids += Find-VelocityID -Node $(Get-Content -Path $settingsJson | ConvertFrom-Json)
    } catch {
        Write-Warning "Error processing $settingsJson : $_"
    }
}

# No IDs check
if ($ids.Count -le 0) {
    Write-Output "No velocity IDs were found." -ForegroundColor Yellow
    exit 1
}

# 29H1: Configure Accounts page
Write-Host "Configuring 29H1 Accounts page..." -ForegroundColor Yellow

# Hide 'Microsoft account' page in Settings for 29H1
$settingsPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Settings\SettingsPageVisibility"
if (-not (Test-Path $settingsPath)) {
    New-Item -Path $settingsPath -Force | Out-Null
}

# 29H1: Hide Microsoft account promotion
Set-ItemProperty -Path $settingsPath -Name "ms-settings:account" -Value "Hide" -Type String -Force -ErrorAction SilentlyContinue

# Hide Microsoft account sign-in page
Set-ItemProperty -Path $settingsPath -Name "ms-settings:yourinfo" -Value "Hide" -Type String -Force -ErrorAction SilentlyContinue

# 29H1: Show local account settings
Set-ItemProperty -Path $settingsPath -Name "ms-settings:signinoptions" -Value "Show" -Type String -Force -ErrorAction SilentlyContinue

# Disable Microsoft account suggestions in 29H1
$explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $explorerPath -Name "Start_ShowUserCloudSync" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# 29H1: Configure account settings
$accountPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users"
if (-not (Test-Path $accountPath)) {
    New-Item -Path $accountPath -Force | Out-Null
}

# Set 29H1 flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Accounts_Configured" -Value 1 -Type DWord -Force

Write-Host "29H1 Accounts Page Configuration Complete" -ForegroundColor Green
exit 0
