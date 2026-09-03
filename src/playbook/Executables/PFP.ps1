# Windows 11 29H1 Profile Pictures Configuration
# Sets default 29H1 profile pictures for all user accounts

Add-Type -AssemblyName System.Drawing

Write-Host "=== Windows 11 29H1 Profile Pictures Configuration ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
}

# Try to load 29H1 specific user image, fallback to default
$29h1UserImage = ".\29H1-user.png"
$userImage = ".\user.png"

if (Test-Path $29h1UserImage) {
    $img = [System.Drawing.Image]::FromFile((Get-Item $29h1UserImage))
    Write-Host "Using 29H1 user image" -ForegroundColor Yellow
} else {
    $img = [System.Drawing.Image]::FromFile((Get-Item $userImage))
    Write-Host "Using default user image" -ForegroundColor Yellow
}

# 29H1 Profile Picture Resolutions
$resolutions = @{
    "user.png" = 448
    "user.bmp" = 448
    "guest.png" = 448
    "guest.bmp" = 448
    "user-192.png" = 192
    "user-48.png" = 48
    "user-40.png" = 40
    "user-32.png" = 32
    "29h1-user.png" = 448
    "29h1-user-192.png" = 192
    "29h1-user-48.png" = 48
    "29h1-user-40.png" = 40
    "29h1-user-32.png" = 32
}

# Set default 29H1 profile pictures
$appData = [Environment]::GetFolderPath('CommonApplicationData')
$profileDir = "$appData\Microsoft\User Account Pictures"

# Create directory if it doesn't exist
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

foreach ($image in $resolutions.Keys) {
    $resolution = $resolutions[$image]
    
    try {
        $a = New-Object System.Drawing.Bitmap($resolution, $resolution)
        $graph = [System.Drawing.Graphics]::FromImage($a)
        $graph.DrawImage($img, 0, 0, $resolution, $resolution)
        $a.Save("$profileDir\$image")
        Write-Host "Created: $image ($resolution x $resolution)" -ForegroundColor Gray
    } catch {
        Write-Host "Error creating $image : $_" -ForegroundColor Red
    }
}

# Set 29H1 profile picture registry settings
$profilePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $profilePath -Name "UseOEMLogonImage" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# Set 29H1 flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_ProfilePictures_Configured" -Value 1 -Type DWord -Force

Write-Host "29H1 Profile Pictures Configuration Complete" -ForegroundColor Green
exit 0
