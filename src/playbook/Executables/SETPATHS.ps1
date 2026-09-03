# Windows 11 29H1 Path Configuration Script
# Fixes registry paths for 29H1 transformation on 25H2

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
    exit
}

Write-Host "=== Windows 11 29H1 Path Configuration ===" -ForegroundColor Cyan

$windir = [Environment]::GetFolderPath('Windows')

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
}

# 29H1: Check both AtlasDesktop and 29H1AtlasDesktop paths
$desktops = @("29H1AtlasDesktop", "AtlasDesktop")

foreach ($desktop in $desktops) {
    $rootPath = "HKLM:\SOFTWARE\AtlasOS\Services"
    
    if (Test-Path $rootPath) {
        $registryKeys = Get-ChildItem -Path $rootPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer }
        
        $valueName = "path"
        foreach ($key in $registryKeys) {
            try {
                $path = (Get-ItemProperty -Path $key.PSPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
                
                if ($path) {
                    Write-Output "Checking path: $path"
                    
                    # Check for both desktop folders
                    if ($path -notlike "$windir\$desktop\*" -and $path -notlike "$windir\29H1AtlasDesktop\*") {
                        $marker = "$desktop\\"
                        $index = $path.IndexOf($marker)
                        if ($index -ge 0) {
                            $result = $path.Substring($index + $marker.Length)
                            $newPath = "$windir\$desktop\$result"
                            Set-ItemProperty -Path $key.PSPath -Name $valueName -Value $newPath
                            Write-Host "Updated: $path -> $newPath" -ForegroundColor Green
                        }
                    }
                }
            } catch {
                Write-Warning "Error processing $($key.PSPath): $_"
            }
        }
    }
}

# 29H1: Additional path fixes for system32
$system32 = [Environment]::GetFolderPath('System')
$29h1Folders = @("29H1", "29H1AtlasDesktop", "29H1AtlasModules")

foreach ($folder in $29h1Folders) {
    $folderPath = Join-Path $system32 $folder
    if (Test-Path $folderPath) {
        Write-Host "29H1 folder found: $folderPath" -ForegroundColor Yellow
    }
}

# Set 29H1 paths flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Paths_Configured" -Value 1 -Type DWord -Force

Write-Host "29H1 Path Configuration Complete" -ForegroundColor Green
exit 0
