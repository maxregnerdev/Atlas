# Windows 11 29H1 Disable PnP Devices
# Disables plug and play devices for 29H1 optimization

Write-Host "=== Windows 11 29H1 Disable PnP Devices ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
}

# 29H1: Enhanced device list for better performance
$devices = @(
    # 29H1: Gaming optimizations
    "AMD PSP",
    "AMD SMBus",
    "Base System Device",
    "Composite Bus Enumerator",
    "Direct memory access controller",
    "High precision event timer",
    
    # 29H1: Intel optimizations
    "Intel Management Engine",
    "Intel SMBus",
    "Intel(R) Management Engine Interface",
    "Intel(R) Serial IO UART Host Controller",
    "Intel(R) Serial IO SPI Host Controller",
    
    # 29H1: Legacy devices
    "Legacy device",
    "Microsoft Kernel Debug Network Adapter",
    "Motherboard resources",
    "Numeric Data Processor",
    
    # 29H1: PCI devices
    "PCI Data Acquisition and Signal Processing Controller",
    "PCI Encryption/Decryption Controller",
    "PCI Memory Controller",
    "PCI Simple Communications Controller",
    "PCI standard RAM Controller",
    
    # 29H1: System devices
    "SM Bus Controller",
    "System CMOS/real time clock",
    "System Speaker",
    "System Timer",
    
    # 29H1: Additional devices for power efficiency
    "Generic SuperSpeed USB Hub",
    "USB Root Hub",
    "USB Composite Device",
    "USB Mass Storage Device"
)

Write-Host "Disabling 29H1 PnP devices..." -ForegroundColor Yellow

# 29H1: Disable devices with better error handling
$disabledCount = 0
$errorCount = 0

foreach ($device in $devices) {
    try {
        $foundDevices = Get-PnpDevice -FriendlyName $device -ErrorAction SilentlyContinue
        foreach ($dev in $foundDevices) {
            try {
                Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
                Write-Host "  Disabled: $($dev.FriendlyName)" -ForegroundColor Green
                $disabledCount++
            } catch {
                Write-Warning "  Could not disable $($dev.FriendlyName): $($_.Exception.Message)"
                $errorCount++
            }
        }
    } catch {
        Write-Warning "  Error finding device '$device': $($_.Exception.Message)"
        $errorCount++
    }
}

Write-Host "29H1 PnP Disable Summary:" -ForegroundColor Yellow
Write-Host "  Devices disabled: $disabledCount" -ForegroundColor Green
Write-Host "  Errors encountered: $errorCount" -ForegroundColor Yellow

# 29H1: Additional registry optimizations for PnP
Write-Host "Applying 29H1 PnP registry optimizations..." -ForegroundColor Yellow

# Disable automatic device installation
$pnpPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DevicePath"
Set-ItemProperty -Path $pnpPath -Name "DevicePath" -Value "" -Type String -Force -ErrorAction SilentlyContinue

# Disable Windows Update device driver installation
$wuPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
Set-ItemProperty -Path $wuPath -Name "IncludeDriverUpdates" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# Set 29H1 flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_PnP_Disabled" -Value 1 -Type DWord -Force

Write-Host "29H1 Disable PnP Devices Complete" -ForegroundColor Green
exit 0
