# Windows 11 29H1 OOBE Features Engine
# Complete feature implementation for 29H1 OOBE

param(
    [switch]$EnableAll = $true,
    [switch]$EnableAI = $true,
    [switch]$EnableGaming = $true,
    [switch]$EnableSecurity = $true,
    [switch]$EnablePerformance = $true
)

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Administrator rights required" -ForegroundColor Red
    exit 1
}

Write-Host "=== 29H1 OOBE Features Engine Starting ===" -ForegroundColor Cyan

# ============================================
# 29H1 Features - AI Integration
# ============================================

function Enable-29H1AIIntegration {
    if (-not $EnableAI) { return }
    
    Write-Host "Enabling 29H1 AI Integration..." -ForegroundColor Yellow
    
    # Windows AI Platform
    $aiPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AI"
    
    try {
        Set-ItemProperty -Path $aiPath -Name "EnableWindowsAI" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $aiPath -Name "EnableOnDeviceAI" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $aiPath -Name "EnableAIModelDownloads" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $aiPath -Name "AIModelStoragePath" -Value "C:\AI Models" -Type String -Force -ErrorAction SilentlyContinue
        
        Write-Host "  Windows AI Platform enabled" -ForegroundColor Gray
    } catch {
        Write-Host "  Windows AI Platform: $_" -ForegroundColor Yellow
    }
    
    # Copilot Integration
    $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $explorerPath -Name "EnableCopilot" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "CopilotTaskbarEnabled" -Value 1 -Type DWord -Force
    
    # AI Search
    $searchPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "EnableAISearch" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $searchPath -Name "EnableAISuggestions" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $searchPath -Name "EnableAIContentRecommendations" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 AI Integration Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Gaming
# ============================================

function Enable-29H1GamingFeatures {
    if (-not $EnableGaming) { return }
    
    Write-Host "Enabling 29H1 Gaming Features..." -ForegroundColor Yellow
    
    $graphicsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"
    
    # Auto HDR
    Set-ItemProperty -Path $graphicsPath -Name "EnableAutoHDR" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableAutoHDRForAll" -Value 1 -Type DWord -Force
    
    # DirectStorage
    Set-ItemProperty -Path $graphicsPath -Name "EnableDirectStorage" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableDirectStorageForAll" -Value 1 -Type DWord -Force
    
    # Variable Refresh Rate
    Set-ItemProperty -Path $graphicsPath -Name "EnableVRR" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableVRRForAll" -Value 1 -Type DWord -Force
    
    # DirectX 12 Ultimate
    $dxPath = "HKLM:\SOFTWARE\Microsoft\DirectX"
    Set-ItemProperty -Path $dxPath -Name "EnableDX12Ultimate" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $dxPath -Name "EnableDX12UltimateFeatures" -Value 1 -Type DWord -Force
    
    # Additional Graphics Features
    Set-ItemProperty -Path $graphicsPath -Name "EnableVariableRateShading" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableMeshShading" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableSamplerFeedback" -Value 1 -Type DWord -Force
    
    # Game Mode
    $gameUXPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameUX"
    Set-ItemProperty -Path $gameUXPath -Name "GameModeEnabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $gameUXPath -Name "EnableAllGamingFeatures" -Value 1 -Type DWord -Force
    
    # Hardware Accelerated GPU Scheduling
    Set-ItemProperty -Path $graphicsPath -Name "EnableHardwareAcceleratedGPUScheduling" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Gaming Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Security
# ============================================

function Enable-29H1SecurityFeatures {
    if (-not $EnableSecurity) { return }
    
    Write-Host "Enabling 29H1 Security Features..." -ForegroundColor Yellow
    
    # Virtualization Based Security
    $vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
    Set-ItemProperty -Path $vbsPath -Name "Enabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $vbsPath -Name "EnableVBS29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $vbsPath -Name "MemoryIntegrityEnabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $vbsPath -Name "EnableAllSecurityFeatures" -Value 1 -Type DWord -Force
    
    # Core Isolation
    $corePath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\LsaCfg"
    Set-ItemProperty -Path $corePath -Name "Enabled" -Value 1 -Type DWord -Force
    
    # Secure Boot
    $secureBootPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State"
    Set-ItemProperty -Path $secureBootPath -Name "UEFISecureBootEnabled" -Value 1 -Type DWord -Force
    
    # TPM 2.0
    $tpmPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceGuard\Scenarios\SystemGuard"
    Set-ItemProperty -Path $tpmPath -Name "EnableTPM20" -Value 1 -Type DWord -Force
    
    # Control Flow Guard
    $kernelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel"
    Set-ItemProperty -Path $kernelPath -Name "EnableUltraGuard" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Security Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Performance
# ============================================

function Enable-29H1PerformanceFeatures {
    if (-not $EnablePerformance) { return }
    
    Write-Host "Enabling 29H1 Performance Features..." -ForegroundColor Yellow
    
    # Ultimate Performance Power Plan
    try {
        $ultimateGUID = "e9a42b89-d57a-4b9f-abc1-7088f7bb4308"
        powercfg /duplicatescheme $ultimateGUID 2>$null
        powercfg /setactive $ultimateGUID 2>$null
        Write-Host "  Ultimate Performance power plan activated" -ForegroundColor Gray
    } catch {
        Write-Host "  Power plan: $_" -ForegroundColor Yellow
    }
    
    # Power Settings
    try {
        powercfg /change /standby-timeout-ac 0
        powercfg /change /standby-timeout-dc 0
        powercfg /change /hibernate-timeout-ac 0
        powercfg /change /hibernate-timeout-dc 0
        powercfg /change /monitor-timeout-ac 0
        powercfg /change /monitor-timeout-dc 0
        Write-Host "  Power timeouts disabled" -ForegroundColor Gray
    } catch {
        Write-Host "  Power settings: $_" -ForegroundColor Yellow
    }
    
    # Disable Power Throttling
    $powerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647c-c1df-4637-891a-dec35c318583"
    Set-ItemProperty -Path $powerPath -Name "Attributes" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $powerPath -Name "SettingIndex" -Value 0 -Type DWord -Force
    
    # Performance Optimizations
    $priorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Priority"
    Set-ItemProperty -Path $priorityPath -Name "EnableAllPerformanceOptimizations" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $priorityPath -Name "EnableDynamicTick" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $priorityPath -Name "EnableTimerCoalescing" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $priorityPath -Name "EnablePowerEfficiencyDiagnostics" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Performance Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Networking
# ============================================

function Enable-29H1NetworkingFeatures {
    Write-Host "Enabling 29H1 Networking Features..." -ForegroundColor Yellow
    
    $tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    
    # TCP/IP Optimizations
    Set-ItemProperty -Path $tcpipPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "TcpWindowSize" -Value 65535 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "DefaultTTL" -Value 64 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "EnableAllNetworkingFeatures" -Value 1 -Type DWord -Force
    
    # Enable IPv6
    $tcpip6Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
    Set-ItemProperty -Path $tcpip6Path -Name "DisabledComponents" -Value 0 -Type DWord -Force
    
    # Enable QUIC and HTTP/3
    $quicPath = "HKLM:\SYSTEM\CurrentControlSet\Services\MsQuic\Parameters"
    Set-ItemProperty -Path $quicPath -Name "EnableQuic" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $quicPath -Name "EnableHttp3" -Value 1 -Type DWord -Force
    
    # QoS Optimizations
    $qosPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS"
    Set-ItemProperty -Path $qosPath -Name "Do not reserve bandwidth" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Networking Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Storage
# ============================================

function Enable-29H1StorageFeatures {
    Write-Host "Enabling 29H1 Storage Features..." -ForegroundColor Yellow
    
    $fileSystemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    
    # Enable all storage features
    Set-ItemProperty -Path $fileSystemPath -Name "EnableAllStorageFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fileSystemPath -Name "EnableNTFSCompression" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fileSystemPath -Name "EnableNTFSEncryption" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fileSystemPath -Name "EnableNTFSSparse" -Value 1 -Type DWord -Force
    
    # NTFS Optimizations
    try {
        fsutil behavior set disablelastaccess 1
        fsutil behavior set disablecompression 0
        fsutil behavior set disableencryption 0
        Write-Host "  NTFS optimizations applied" -ForegroundColor Gray
    } catch {
        Write-Host "  NTFS: $_" -ForegroundColor Yellow
    }
    
    # Storage Sense
    $storagePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters"
    Set-ItemProperty -Path $storagePath -Name "StoragePolicy" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Storage Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Audio
# ============================================

function Enable-29H1AudioFeatures {
    Write-Host "Enabling 29H1 Audio Features..." -ForegroundColor Yellow
    
    $audioPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Audio"
    
    # Enable all audio features
    Set-ItemProperty -Path $audioPath -Name "EnableAllAudioFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableSpatialAudio" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableDolbyAtmos" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableDTSX" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableHighQualityAudio" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Audio Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - UI Capabilities
# ============================================

function Enable-29H1UIFeatures {
    Write-Host "Enabling 29H1 UI Features..." -ForegroundColor Yellow
    
    $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # New 29H1 UI Features
    Set-ItemProperty -Path $explorerPath -Name "Start_Layout" -Value "29H1" -Type String -Force
    Set-ItemProperty -Path $explorerPath -Name "Taskbar29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Explorer29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "WindowManagement29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ContextMenu29H1" -Value 1 -Type DWord -Force
    
    # Start Menu
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowAllApps" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecentApps" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecommendations" -Value 0 -Type DWord -Force
    
    # Taskbar
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAlignment" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarSmallIcons" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarGlomLevel" -Value 2 -Type DWord -Force
    
    # Search
    $searchPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force
    
    Write-Host "29H1 UI Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Main Execution
# ============================================

try {
    Write-Host "Starting 29H1 features transformation..." -ForegroundColor Cyan
    
    # Execute feature enablement
    Enable-29H1AIIntegration
    Enable-29H1GamingFeatures
    Enable-29H1SecurityFeatures
    Enable-29H1PerformanceFeatures
    Enable-29H1NetworkingFeatures
    Enable-29H1StorageFeatures
    Enable-29H1AudioFeatures
    Enable-29H1UIFeatures
    
    # Create completion marker
    $marker = "C:\Windows\System32\29h1-features-complete.flag"
    New-Item -Path $marker -ItemType File -Force | Out-Null
    
    Write-Host "=== 29H1 Features Engine Completed Successfully ===" -ForegroundColor Green
    Write-Host "All 29H1 features have been enabled on your system." -ForegroundColor Green
    
    # Restart explorer to apply UI changes
    try {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Process -FilePath "explorer.exe"
        Write-Host "Explorer restarted to apply UI changes" -ForegroundColor Gray
    } catch {
        Write-Host "Could not restart explorer: $_" -ForegroundColor Yellow
    }
    
    exit 0
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "29H1 Features Engine Failed" -ForegroundColor Red
    exit 1
}
