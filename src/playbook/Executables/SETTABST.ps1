# Windows 11 29H1 Taskbar Pins Configuration
# Sets default taskbar pins for 29H1 transformation

param (
    [string]$Browser
)

Write-Host "=== Windows 11 29H1 Taskbar Pins Configuration ===" -ForegroundColor Cyan

if (!$Browser) {
    # Default 29H1 taskbar pins
    $ArgString = "`"${Env:WinDir}\29H1AtlasModules\Scripts\29H1-taskbarPins.ps1`""
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File $ArgString"
    $Trigger = New-ScheduledTaskTrigger -AtLogon
    $Principal = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Highest

    Register-ScheduledTask -TaskName "29H1TaskBarPinsDefault" -Action $Action -Trigger $Trigger -Principal $Principal -Force
    
    Write-Host "29H1 Default Taskbar Pins scheduled" -ForegroundColor Green
}
else {
    # Browser-specific 29H1 taskbar pins
    $ArgString = "`"${Env:WinDir}\29H1AtlasModules\Scripts\29H1-taskbarPins.ps1`""
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File $ArgString `"$Browser`""
    $Trigger = New-ScheduledTaskTrigger -AtLogon
    $Principal = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Highest

    Register-ScheduledTask -TaskName "29H1TaskBarPins" -Action $Action -Trigger $Trigger -Principal $Principal -Force
    
    Write-Host "29H1 Taskbar Pins for $Browser scheduled" -ForegroundColor Green
}

# Set 29H1 taskbar registry settings
$taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
Set-ItemProperty -Path $taskbarPath -Name "FavoritesChanges" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $taskbarPath -Name "FavoritesResolved" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

# Set 29H1 taskbar appearance
$explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $explorerPath -Name "TaskbarAlignment" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "TaskbarSmallIcons" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $explorerPath -Name "TaskbarGlomLevel" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

# Set 29H1 flag
$29h1Path = "HKLM:\SOFTWARE\AtlasOS\Taskbar"
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Pins_Configured" -Value 1 -Type DWord -Force

Write-Host "29H1 Taskbar Configuration Complete" -ForegroundColor Green
