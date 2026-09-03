.\29H1AtlasModules\initPowerShell.ps1

Write-Host "=== Windows 11 29H1 LibreWolf Installation ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
    if ($29h1Mode) {
        Write-Host "29H1 Mode detected - Installing 29H1 optimized LibreWolf" -ForegroundColor Green
    }
}

$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$timeouts = @("--connect-timeout", "10", "--retry", "5", "--retry-delay", "0", "--retry-all-errors")

# Initial variables
$drive = Get-SystemDrive
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = [Environment]::GetFolderPath("CommonPrograms")
$programs = [Environment]::GetFolderPath("ProgramFiles")
$updaterPath = "$programs\LibreWolf\librewolf-winupdater"
$librewolfPath = "$programs\LibreWolf"

Write-Host "Getting the latest LibreWolf download link for 29H1..." -ForegroundColor Yellow
$gitLabId = '44042130'
$librewolfVersion = (Invoke-RestMethod "https://gitlab.com/api/v4/projects/$gitLabId/releases")[0].Name
if ([string]::IsNullOrEmpty($librewolfVersion)) {
	Write-Error "GitLab API returned nothing!"
	exit 1
}
Write-Host "Latest LibreWolf version: $librewolfVersion" -ForegroundColor Gray
$librewolfFileName = "librewolf-$librewolfVersion-windows-x86_64-setup.exe"
$librewolfDownload = "https://gitlab.com/api/v4/projects/$gitLabId/packages/generic/librewolf/$librewolfVersion/$librewolfFileName"

Write-Host "Downloading LibreWolf for 29H1..." -ForegroundColor Yellow
$outputLibrewolf = "$drive\$librewolfFileName"
curl.exe -LSs "$librewolfDownload" -o "$outputLibrewolf" $timeouts

Write-Host "Installing LibreWolf for 29H1..." -ForegroundColor Yellow
Start-Process -Wait -FilePath $outputLibrewolf -ArgumentList "/S"
if (!(Test-Path $librewolfPath)) {
	throw "Installing LibreWolf silently failed."
}

Write-Host "Creating LibreWolf Desktop shortcut for 29H1" -ForegroundColor Yellow
New-Shortcut -Source "$librewolfPath\librewolf.exe" -Destination "$desktop\LibreWolf.lnk" -WorkingDir $librewolfPath


Write-Host "Installing LibreWolf-WinUpdater for 29H1..." -ForegroundColor Yellow
Write-Host "Getting LibreWolf-WinUpdater download link..." -ForegroundColor Yellow
$librewolfUpdaterURI = "https://codeberg.org/api/v1/repos/ltguillaume/librewolf-winupdater/releases?draft=false&pre-release=false&page=1&limit=1"
$librewolfUpdaterDownload = (Invoke-RestMethod -Uri "$librewolfUpdaterURI").Assets |
	Where-Object { $_.name -like "*.zip" } |
	Select-Object -ExpandProperty browser_download_url

Write-Host "Downloading LibreWolf WinUpdater for 29H1..." -ForegroundColor Yellow
$outputLibrewolfUpdater = "$drive\librewolf-winupdater.zip"
curl.exe -LSs "$librewolfUpdaterDownload" -o "$outputLibrewolfUpdater" $timeouts

Write-Host "Extracting LibreWolf-WinUpdater for 29H1..." -ForegroundColor Yellow
Expand-Archive -Path $outputLibrewolfUpdater -DestinationPath "$programs\LibreWolf\librewolf-winupdater" -Force

Write-Host "Adding 29H1 automatic updater task..." -ForegroundColor Yellow
foreach ($User in (Get-CimInstance -ClassName Win32_UserAccount -Filter "Disabled=False").Name) {
	$Action   = New-ScheduledTaskAction -Execute "$updaterPath\LibreWolf-WinUpdater.exe" -Argument "/Scheduled"
	$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable
	$7Hours   = New-ScheduledTaskTrigger -Once -At (Get-Date -Minute 0 -Second 0).AddHours(1) -RepetitionInterval (New-TimeSpan -Hours 7)
	$AtLogon  = New-ScheduledTaskTrigger -AtLogOn
	$AtLogon.Delay = 'PT1M'
	Register-ScheduledTask -TaskName "LibreWolf WinUpdater ($User)" -Action $Action -Settings $Settings -Trigger $7Hours,$AtLogon -User $User -RunLevel Highest -Force | Out-Null	
}

Write-Host "Adding LibreWolf WinUpdater shortcut for 29H1..." -ForegroundColor Yellow
New-Shortcut -Source "$updaterPath\Librewolf-WinUpdater.exe" -Destination "$startMenu\LibreWolf\LibreWolf WinUpdater.lnk" -WorkingDir $librewolfPath

# Finish
Write-Host "Removing temp files..." -ForegroundColor Yellow
Remove-Item "$outputLibrewolf" -Force
Remove-Item "$outputLibrewolfUpdater" -Force

# Set 29H1 LibreWolf flag
$29h1Path = "HKLM:\SOFTWARE\AtlasOS\LibreWolf"
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Installed" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $29h1Path -Name "Version" -Value $librewolfVersion -Type String -Force

Write-Host "29H1 LibreWolf Installation Complete" -ForegroundColor Green