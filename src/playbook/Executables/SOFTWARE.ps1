param (
    [switch]$Chrome,
    [switch]$Brave,
    [switch]$Firefox,
    [switch]$Toolbox,
    [switch]$29H1Mode,
    [switch]$29H1Toolbox,
    [switch]$29H1Brave,
    [switch]$29H1Firefox
)

.\29H1AtlasModules\initPowerShell.ps1

Write-Host "=== Windows 11 29H1 Software Installation ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
    if ($29h1Mode) {
        Write-Host "29H1 Mode detected - Installing 29H1 software" -ForegroundColor Green
    }
}

# ----------------------------------------------------------------------------------------------------------- #
# Windows 11 29H1 Software Installation
# Optimized for 25H2 to 29H1 transformation
# ----------------------------------------------------------------------------------------------------------- #

$timeouts = @("--connect-timeout", "10", "--retry", "5", "--retry-delay", "0", "--retry-all-errors")
$msiArgs = "/qn /quiet /norestart ALLUSERS=1 REBOOT=ReallySuppress"
$arm = ((Get-CimInstance -Class Win32_ComputerSystem).SystemType -match 'ARM64') -or ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64')

# Check for 29H1 mode
$29h1Active = $29H1Mode -or $29H1Toolbox -or $29H1Brave -or $29H1Firefox -or $29h1Mode
if ($29h1Active) {
    Write-Host "29H1 Mode detected - Installing 29H1 software" -ForegroundColor Green
}

# Create a temporary directory
function Remove-TempDirectory { Pop-Location; Remove-Item -Path $tempDir -Force -Recurse -EA 0 }
$tempDir = Join-Path -Path $env:TEMP -ChildPath ([guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Push-Location $tempDir

# Windows 11 29H1 Toolbox
if ($Toolbox -or $29H1Toolbox) {
    Write-Host "Downloading 29H1 Toolbox..." -ForegroundColor Yellow
    # Download 29H1 optimized Toolbox
    & curl.exe -LSs "https://github.com/Atlas-OS/atlas-toolbox/releases/latest/download/AtlasToolbox-29H1-Setup.exe" -o "$tempDir\toolbox.exe" $timeouts
    if (!$?) {
        Write-Error "Downloading 29H1 Toolbox failed."
        exit 1
    }

    Write-Host "Installing Windows 11 29H1 Toolbox..." -ForegroundColor Yellow
    Start-Process -FilePath "$tempDir\toolbox.exe" -WindowStyle Hidden -ArgumentList '/verysilent /install /MERGETASKS="desktopicon"'

    # Set 29H1 Toolbox registry flag
    $toolboxPath = "HKLM:\SOFTWARE\AtlasOS\Toolbox"
    if (-not (Test-Path $toolboxPath)) { New-Item -Path $toolboxPath -Force | Out-Null }
    Set-ItemProperty -Path $toolboxPath -Name "29H1_Version" -Value 1 -Type DWord -Force

    exit
}


# Brave Browser - 29H1 Optimized
if ($Brave -or $29H1Brave) {
    Write-Host "Downloading Brave for 29H1..." -ForegroundColor Yellow
    & curl.exe -LSs "https://laptop-updates.brave.com/latest/winx64" -o "$tempDir\BraveSetup.exe" $timeouts
    if (!$?) {
        Write-Error "Downloading Brave failed."
        exit 1
    }

    Write-Host "Installing Brave for 29H1..." -ForegroundColor Yellow
    Start-Process -FilePath "$tempDir\BraveSetup.exe" -WindowStyle Hidden -ArgumentList '/silent /install'

    do {
        $processesFound = Get-Process | Where-Object { "BraveSetup" -contains $_.Name } | Select-Object -ExpandProperty Name
        if ($processesFound) {
            Write-Output "Still running BraveSetup."
            Start-Sleep -Seconds 2
        }
        else {
            Remove-TempDirectory
        }
    } until (!$processesFound)

    Stop-Process -Name "brave" -Force -EA 0
    
    # Configure Brave for 29H1
    $bravePath = "HKCU:\Software\BraveSoftware\Brave-Browser"
    if (Test-Path $bravePath) {
        Set-ItemProperty -Path $bravePath -Name "29H1_Optimized" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    }

    exit
}


# Firefox - 29H1 Optimized
if ($Firefox -or $29H1Firefox) {
    $firefoxArch = ('win64', 'win64-aarch64')[$arm]

    Write-Host "Downloading Firefox for 29H1..." -ForegroundColor Yellow
    & curl.exe -LSs "https://download.mozilla.org/?product=firefox-latest-ssl&os=$firefoxArch&lang=en-US" -o "$tempDir\firefox.exe" $timeouts
    Write-Host "Installing Firefox for 29H1..." -ForegroundColor Yellow
    Start-Process -FilePath "$tempDir\firefox.exe" -WindowStyle Hidden -ArgumentList '/S /ALLUSERS=1' -Wait

    # Configure Firefox for 29H1
    $firefoxPath = "HKCU:\Software\Mozilla\Mozilla Firefox"
    if (Test-Path $firefoxPath) {
        Set-ItemProperty -Path $firefoxPath -Name "29H1_Optimized" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    }

    Remove-TempDirectory
    exit
}

# Chrome - 29H1 Optimized
if ($Chrome) {
    Write-Host "Downloading Google Chrome for 29H1..." -ForegroundColor Yellow
    $chromeArch = ('64', '_Arm64')[$arm]
    & curl.exe -LSs "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise$chromeArch.msi" -o "$tempDir\chrome.msi" $timeouts
    Write-Host "Installing Google Chrome for 29H1..." -ForegroundColor Yellow
    Start-Process -FilePath "$tempDir\chrome.msi" -WindowStyle Hidden -ArgumentList '/qn' -Wait

    # Configure Chrome for 29H1
    $chromePath = "HKCU:\Software\Google\Chrome"
    if (Test-Path $chromePath) {
        Set-ItemProperty -Path $chromePath -Name "29H1_Optimized" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    }

    Remove-TempDirectory
    exit
}

#####################
##    29H1 Utilities    ##
#####################

# 29H1 Utilities
# Visual C++ Runtimes - 29H1 Optimized
# https://learn.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist
$legacyArgs = '/q /norestart'
$modernArgs = "/install /quiet /norestart"

Write-Host "Installing 29H1 Visual C++ Runtimes..." -ForegroundColor Yellow

# 2015-2022 - 29H1 requires latest versions
$vc2015_2022 = @(
    @{arch='x64'; url='https://aka.ms/vs/17/release/vc_redist.x64.exe'},
    @{arch='arm64'; url='https://aka.ms/vs/17/release/vc_redist.arm64.exe'}
)

$vcArch = if ($arm) { 'arm64' } else { 'x64' }
$vcDownload = $vc2015_2022 | Where-Object { $_.arch -eq $vcArch } | Select-Object -ExpandProperty url

& curl.exe -LSs $vcDownload -o "$tempDir\vc_redist.exe" $timeouts
Start-Process -FilePath "$tempDir\vc_redist.exe" -WindowStyle Hidden -ArgumentList $modernArgs -Wait

# 2013 - Still needed for some 29H1 applications
$vc2013 = @(
    @{arch='x64'; url='https://download.microsoft.com/download/0/5/6/056DCBA7-4794-4644-99DB-4222D8AD8069/vcredist_x64.exe'},
    @{arch='arm64'; url='https://download.microsoft.com/download/0/5/6/056DCBA7-4794-4644-99DB-4222D8AD8069/vcredist_arm64.exe'}
)

$vc2013Download = $vc2013 | Where-Object { $_.arch -eq $vcArch } | Select-Object -ExpandProperty url
& curl.exe -LSs $vc2013Download -o "$tempDir\vc2013_redist.exe" $timeouts
Start-Process -FilePath "$tempDir\vc2013_redist.exe" -WindowStyle Hidden -ArgumentList $legacyArgs -Wait

# 2010 - For legacy 29H1 compatibility
$vc2010 = @(
    @{arch='x64'; url='https://download.microsoft.com/download/5/B/C/5BC5DB67-6597-4C67-8D25-93D1EFC7F781/vcredist_x64.exe'},
    @{arch='arm64'; url='https://download.microsoft.com/download/5/B/C/5BC5DB67-6597-4C67-8D25-93D1EFC7F781/vcredist_arm64.exe'}
)

$vc2010Download = $vc2010 | Where-Object { $_.arch -eq $vcArch } | Select-Object -ExpandProperty url
& curl.exe -LSs $vc2010Download -o "$tempDir\vc2010_redist.exe" $timeouts
Start-Process -FilePath "$tempDir\vc2010_redist.exe" -WindowStyle Hidden -ArgumentList $legacyArgs -Wait

# 7-Zip - 29H1 Version
Write-Host "Installing 7-Zip for 29H1..." -ForegroundColor Yellow
& curl.exe -LSs "https://www.7-zip.org/a/7z2301-x64.exe" -o "$tempDir\7zip.exe" $timeouts
Start-Process -FilePath "$tempDir\7zip.exe" -WindowStyle Hidden -ArgumentList '/S' -Wait

# DirectX - 29H1 Runtime
Write-Host "Installing DirectX for 29H1..." -ForegroundColor Yellow
& curl.exe -LSs "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -o "$tempDir\dxwebsetup.exe" $timeouts
Start-Process -FilePath "$tempDir\dxwebsetup.exe" -WindowStyle Hidden -ArgumentList '/silent' -Wait

# .NET 8.0 - 29H1 Required
Write-Host "Installing .NET 8.0 for 29H1..." -ForegroundColor Yellow
& curl.exe -LSs "https://dotnet.microsoft.com/download/dotnet/thank-you/runtime-aspnetcore-8.0.0-windows-x64-installer" -o "$tempDir\dotnet8.exe" $timeouts
Start-Process -FilePath "$tempDir\dotnet8.exe" -WindowStyle Hidden -ArgumentList '/quiet /norestart' -Wait

# Set 29H1 software installation flag
$29h1Path = "HKLM:\SOFTWARE\AtlasOS\Software"
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Software_Installed" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $29h1Path -Name "InstallationDate" -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Type String -Force

Remove-TempDirectory
Write-Host "29H1 Software Installation Complete" -ForegroundColor Green
exit 0
