# Windows 11 29H1 Disk Cleanup Script
# Enhanced cleanup for 25H2 to 29H1 transformation

.\29H1AtlasModules\initPowerShell.ps1

Write-Host "=== Windows 11 29H1 Disk Cleanup ===" -ForegroundColor Cyan

function Invoke-29H1DiskCleanup {
    # Kill running cleanmgr instances
    Get-Process -Name cleanmgr -EA 0 | Stop-Process -Force -EA 0
    
    # 29H1 Enhanced Disk Cleanup preset
    # StateFlags0064: 2 = enabled, 0 = disabled
    # 29H1 keeps D3D Shader Cache for gaming performance
    $baseKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
    
    $regValues = @{
        # 29H1: Enable aggressive cleanup
        "Active Setup Temp Folders"             = 2
        "BranchCache"                           = 2
        "D3D Shader Cache"                      = 2  # 29H1: Keep for gaming
        "Delivery Optimization Files"           = 2
        "Diagnostic Data Viewer database files" = 2
        "Downloaded Program Files"              = 2
        "Internet Cache Files"                  = 2
        "Language Pack"                         = 2  # 29H1: Remove unused languages
        "Old ChkDsk Files"                      = 2
        "Recycle Bin"                           = 0  # 29H1: Keep user control
        "RetailDemo Offline Content"            = 2
        "Setup Log Files"                       = 2
        "System error memory dump files"        = 2
        "System error minidump files"           = 2
        "Temporary Files"                       = 2
        "Thumbnail Cache"                       = 2
        "Update Cleanup"                        = 2  # 29H1: Aggressive update cleanup
        "User file versions"                    = 2
        "Windows Error Reporting Files"         = 2
        "Windows Defender"                      = 0  # 29H1: Keep Defender enabled
        "Temporary Sync Files"                  = 2
        "Device Driver Packages"                = 2
        
        # 29H1 Specific
        "Windows Upgrade Log Files"             = 2
        "Previous Windows Installations"        = 2
        "Windows ESD Installation Files"        = 2
    }
    
    Write-Host "Configuring 29H1 cleanup settings..." -ForegroundColor Yellow
    
    foreach ($entry in $regValues.GetEnumerator()) {
        $key = "$baseKey\$($entry.Key)"
        
        if (!(Test-Path $key)) {
            Write-Output "'$key' not found, creating..."
            New-Item -Path $key -Force | Out-Null
        }
        
        Set-ItemProperty -Path "$baseKey\$($entry.Key)" -Name 'StateFlags0064' -Value $entry.Value -Type DWORD
    }

    # Run preset 64 for 29H1
    Write-Host "Running 29H1 disk cleanup..." -ForegroundColor Yellow
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:64" -Wait
    
    # 29H1: Additional cleanup
    Write-Host "Running 29H1 additional cleanup..." -ForegroundColor Yellow
    
    # Clean Windows Update cache
    Stop-Service -Name wuauserv -Force -EA 0
    Stop-Service -Name bits -Force -EA 0
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Force -Recurse -EA 0
    Start-Service -Name wuauserv -EA 0
    Start-Service -Name bits -EA 0
    
    # Clean Temp folders
    Remove-Item -Path "C:\Windows\Temp\*" -Force -Recurse -EA 0
    Remove-Item -Path "$env:TEMP\*" -Force -Recurse -EA 0
    
    # Clean Prefetch
    Remove-Item -Path "C:\Windows\Prefetch\*" -Force -Recurse -EA 0
    
    # 29H1: Clean old Windows installations
    $oldWindows = Get-ChildItem -Path "C:\Windows.old*" -Directory -EA 0
    foreach ($old in $oldWindows) {
        Write-Host "Removing old Windows installation: $($old.FullName)" -ForegroundColor Gray
        Remove-Item -Path $old.FullName -Force -Recurse -EA 0
    }
    
    Write-Host "29H1 Disk Cleanup Complete" -ForegroundColor Green
}

# Check for other installations of Windows
$otherWindows = Get-WmiObject -Class Win32_OperatingSystem | Where-Object { $_.InstallDate -ne (Get-CimInstance Win32_OperatingSystem).InstallDate }

if ($otherWindows) {
    Write-Host "Other Windows installations detected, skipping cleanup to preserve data" -ForegroundColor Yellow
} else {
    Invoke-29H1DiskCleanup
}

# Set 29H1 cleanup flag
$29h1Path = "HKLM:\SOFTWARE\AtlasOS\Cleanup"
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Cleanup_Complete" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $29h1Path -Name "CleanupDate" -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Type String -Force

exit 0
