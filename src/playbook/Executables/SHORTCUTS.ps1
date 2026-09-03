# Windows 11 29H1 Shortcuts Configuration
# Creates desktop and Start Menu shortcuts for 29H1 transformation

.\29H1AtlasModules\initPowerShell.ps1

Write-Host "=== Windows 11 29H1 Shortcuts Configuration ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
    if ($29h1Mode) {
        Write-Host "29H1 Mode detected - Creating 29H1 shortcuts" -ForegroundColor Green
    }
}

$windir = [Environment]::GetFolderPath('Windows')

Write-Host "Creating 29H1 Desktop & Start Menu shortcuts..." -ForegroundColor Yellow

# 29H1: Check for 29H1 desktop path
$29h1Desktop = "$windir\29H1AtlasDesktop"
$defaultDesktop = "$windir\AtlasDesktop"

$desktopPath = if (Test-Path $29h1Desktop) { $29h1Desktop } else { $defaultDesktop }

# Default user
$29h1Shortcut = "$(Get-UserPath)\29H1AtlasOS.lnk"
$defaultShortcut = "$(Get-UserPath)\AtlasOS.lnk"

try {
    New-Shortcut -Source $desktopPath -Destination $29h1Shortcut -Icon "$windir\29H1AtlasModules\Other\29h1-folder.ico,0" -ErrorAction SilentlyContinue
    if (-not (Test-Path $29h1Shortcut)) {
        New-Shortcut -Source $desktopPath -Destination $defaultShortcut -Icon "$windir\AtlasModules\Other\atlas-folder.ico,0" -ErrorAction SilentlyContinue
    }
} catch {
    Write-Warning "Could not create default shortcut: $_"
}

# Copy shortcut to every user
foreach ($userKey in (Get-RegUserPaths -NoDefault).PsPath) {
    try {
        $folders = Get-ItemProperty -path "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -EA 0
        $deskPath = $folders.Desktop
        if (Test-Path $deskPath -PathType Container) {
            Write-Host "Copying 29H1 Desktop shortcut for '$userKey'..." -ForegroundColor Gray
            if (Test-Path $29h1Shortcut) {
                Copy-Item $29h1Shortcut -Destination $deskPath -Force -EA 0
            } elseif (Test-Path $defaultShortcut) {
                Copy-Item $defaultShortcut -Destination $deskPath -Force -EA 0
            }
        } else {
            Write-Warning "Desktop path not found for '$userKey', shortcuts can't be copied."
        }
    } catch {
        Write-Warning "Error copying shortcuts for $userKey : $_"
    }
}

# 29H1 Start menu shortcut
$startMenuPath = "$([Environment]::GetFolderPath('CommonStartMenu'))\Programs"
Write-Host "Creating 29H1 Start Menu shortcut..." -ForegroundColor Gray

try {
    if (Test-Path $29h1Shortcut) {
        Copy-Item $29h1Shortcut -Destination $startMenuPath -Force -EA 0
    } elseif (Test-Path $defaultShortcut) {
        Copy-Item $defaultShortcut -Destination $startMenuPath -Force -EA 0
    }
} catch {
    Write-Warning "Could not create Start Menu shortcut: $_"
}

# 29H1: Create services restore shortcut
Write-Host "Creating 29H1 services restore shortcut..." -ForegroundColor Gray

$29h1Troubleshooting = "$desktopPath\9. Troubleshooting"
$29h1Advanced = "$desktopPath\6. Advanced Configuration"

if (Test-Path $29h1Troubleshooting) {
    $servicesCmd = "$29h1Troubleshooting\29H1-Set services to defaults.cmd"
    $servicesLnk = "$29h1Advanced\Services\29H1-Set services to defaults.lnk"
    
    if (-not (Test-Path "$29h1Advanced\Services")) {
        New-Item -ItemType Directory -Path "$29h1Advanced\Services" -Force | Out-Null
    }
    
    try {
        New-Shortcut -Source $servicesCmd -Destination $servicesLnk -ErrorAction SilentlyContinue
    } catch {
        Write-Warning "Could not create services shortcut: $_"
    }
} else {
    # Fallback to original paths
    $desktop = "$windir\MaxRegnerUIDesktop"
    if (Test-Path $desktop) {
        New-Shortcut -Source "$desktop\9. Troubleshooting\Set services to defaults.cmd" -Destination "$desktop\6. Advanced Configuration\Services\Set services to defaults.lnk" -ErrorAction SilentlyContinue
    }
}

# 29H1: Create additional 29H1 shortcuts
Write-Host "Creating additional 29H1 shortcuts..." -ForegroundColor Gray

# Create 29H1 Settings shortcut
$29h1Settings = "$startMenuPath\29H1 Settings.lnk"
try {
    New-Shortcut -Source "ms-settings:" -Destination $29h1Settings -Icon "imageres.dll,102" -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Could not create 29H1 Settings shortcut: $_"
}

# Set 29H1 flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Shortcuts_Created" -Value 1 -Type DWord -Force

Write-Host "29H1 Shortcuts Configuration Complete" -ForegroundColor Green
exit 0
