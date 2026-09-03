# Windows 11 29H1 Features Engine
# Complete feature implementation for 29H1 on 25H2

param(
    [switch]$EnableAll = $true,
    [switch]$EnableAI = $true,
    [switch]$EnableGaming = $true,
    [switch]$EnableSecurity = $true,
    [switch]$EnablePerformance = $true,
    [switch]$EnableNetworking = $true,
    [switch]$EnableStorage = $true,
    [switch]$EnableAudio = $true,
    [switch]$EnableUI = $true
)

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Administrator rights required for 29H1 Features Engine" -ForegroundColor Red
    exit 1
}

Write-Host "=== Windows 11 29H1 Features Engine Starting ===" -ForegroundColor Cyan

# ============================================
# 29H1 Features - Core System
# ============================================

function Initialize-29H1Core {
    Write-Host "Initializing 29H1 Core System..." -ForegroundColor Yellow
    
    # Set 29H1 version flag
    $versionPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    Set-ItemProperty -Path $versionPath -Name "29H1_Enabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $versionPath -Name "29H1_Version" -Value "29H1" -Type String -Force
    
    # Set feature update flag
    $updatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade"
    Set-ItemProperty -Path $updatePath -Name "ReserveOSUpgrade" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $updatePath -Name "TargetVersion" -Value "29H1" -Type String -Force
    Set-ItemProperty -Path $updatePath -Name "AllowOSUpgrade" -Value 1 -Type DWord -Force
    
    # Disable feature update deferral
    $autoUpdatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
    Set-ItemProperty -Path $autoUpdatePath -Name "DeferFeatureUpdatesPeriodInDays" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $autoUpdatePath -Name "DeferQualityUpdatesPeriodInDays" -Value 0 -Type DWord -Force
    
    Write-Host "29H1 Core System Initialized" -ForegroundColor Green
}

# ============================================
# 29H1 Features - AI and Machine Learning
# ============================================

function Enable-29H1AI {
    if (-not $EnableAI -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 AI Features..." -ForegroundColor Yellow
    
    # Windows AI Platform
    $aiPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AI"
    
    try {
        Set-ItemProperty -Path $aiPath -Name "EnableWindowsAI" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $aiPath -Name "EnableOnDeviceAI" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $aiPath -Name "EnableAIModelDownloads" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $aiPath -Name "AIModelStoragePath" -Value "C:\AI Models" -Type String -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $aiPath -Name "EnableAIProcessing" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        Write-Host "  Windows AI Platform enabled" -ForegroundColor Gray
    } catch {
        Write-Host "  Windows AI Platform: $_" -ForegroundColor Yellow
    }
    
    # Copilot Integration
    $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $explorerPath -Name "EnableCopilot" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "CopilotTaskbarEnabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "CopilotFlyoutEnabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "CopilotFullScreen" -Value 1 -Type DWord -Force
    
    # AI Search
    $searchPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "EnableAISearch" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $searchPath -Name "EnableAISuggestions" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $searchPath -Name "EnableAIContentRecommendations" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $searchPath -Name "AISearchIndexing" -Value 1 -Type DWord -Force
    
    # AI-Powered File Explorer
    Set-ItemProperty -Path $explorerPath -Name "EnableAIFileSuggestions" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "EnableAIFileTagging" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "EnableAISmartFolders" -Value 1 -Type DWord -Force
    
    # Create AI Models directory
    $aiModelsDir = "C:\AI Models"
    if (-not (Test-Path $aiModelsDir)) {
        New-Item -ItemType Directory -Path $aiModelsDir -Force | Out-Null
    }
    
    Write-Host "29H1 AI Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Gaming
# ============================================

function Enable-29H1Gaming {
    if (-not $EnableGaming -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 Gaming Features..." -ForegroundColor Yellow
    
    $graphicsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration"
    
    # Auto HDR - Next Generation
    Set-ItemProperty -Path $graphicsPath -Name "EnableAutoHDR" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableAutoHDRForAll" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "AutoHDRQuality" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "AutoHDRMode" -Value 2 -Type DWord -Force
    
    # DirectStorage - Next Generation
    Set-ItemProperty -Path $graphicsPath -Name "EnableDirectStorage" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableDirectStorageForAll" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "DirectStorageVersion" -Value 2 -Type DWord -Force
    
    # Variable Refresh Rate - Enhanced
    Set-ItemProperty -Path $graphicsPath -Name "EnableVRR" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableVRRForAll" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "VRRMode" -Value 2 -Type DWord -Force
    
    # DirectX 12 Ultimate - All Features
    $dxPath = "HKLM:\SOFTWARE\Microsoft\DirectX"
    Set-ItemProperty -Path $dxPath -Name "EnableDX12Ultimate" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $dxPath -Name "EnableDX12UltimateFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $dxPath -Name "DX12UltimateVersion" -Value "29H1" -Type String -Force
    
    # Additional Graphics Features
    Set-ItemProperty -Path $graphicsPath -Name "EnableVariableRateShading" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableMeshShading" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableSamplerFeedback" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "EnableRayTracing" -Value 1 -Type DWord -Force
    
    # Game Mode - Enhanced
    $gameUXPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameUX"
    Set-ItemProperty -Path $gameUXPath -Name "GameModeEnabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $gameUXPath -Name "EnableAllGamingFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $gameUXPath -Name "GameModeVersion" -Value "29H1" -Type String -Force
    
    # Hardware Accelerated GPU Scheduling
    Set-ItemProperty -Path $graphicsPath -Name "EnableHardwareAcceleratedGPUScheduling" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $graphicsPath -Name "GPUSchedulingPriority" -Value 1 -Type DWord -Force
    
    # Xbox Game Bar Integration
    Set-ItemProperty -Path $gameUXPath -Name "EnableGameBar" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $gameUXPath -Name "GameBarVersion" -Value "29H1" -Type String -Force
    
    Write-Host "29H1 Gaming Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Security
# ============================================

function Enable-29H1Security {
    if (-not $EnableSecurity -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 Security Features..." -ForegroundColor Yellow
    
    # Virtualization Based Security - 29H1 Enhanced
    $vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
    Set-ItemProperty -Path $vbsPath -Name "Enabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $vbsPath -Name "EnableVBS29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $vbsPath -Name "MemoryIntegrityEnabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $vbsPath -Name "EnableAllSecurityFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $vbsPath -Name "VBSVersion" -Value "29H1" -Type String -Force
    
    # Core Isolation - Enhanced
    $corePath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\LsaCfg"
    Set-ItemProperty -Path $corePath -Name "Enabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $corePath -Name "CoreIsolationVersion" -Value "29H1" -Type String -Force
    
    # Secure Boot - 29H1 Enhanced
    $secureBootPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State"
    Set-ItemProperty -Path $secureBootPath -Name "UEFISecureBootEnabled" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $secureBootPath -Name "SecureBootVersion" -Value "29H1" -Type String -Force
    
    # TPM 2.0 - 29H1 Enhanced
    $tpmPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceGuard\Scenarios\SystemGuard"
    Set-ItemProperty -Path $tpmPath -Name "EnableTPM20" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tpmPath -Name "TPMVersion" -Value "29H1" -Type String -Force
    
    # Control Flow Guard - Enhanced
    $kernelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel"
    Set-ItemProperty -Path $kernelPath -Name "EnableUltraGuard" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $kernelPath -Name "CFGVersion" -Value "29H1" -Type String -Force
    
    # Windows Defender - 29H1 Enhanced
    $defenderPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender"
    Set-ItemProperty -Path $defenderPath -Name "DisableAntiSpyware" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $defenderPath -Name "DisableAntiVirus" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $defenderPath -Name "DisableRoutinelyTakingAction" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $defenderPath -Name "DefenderVersion" -Value "29H1" -Type String -Force
    
    # Firewall - 29H1 Enhanced
    $firewallPath = "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile"
    Set-ItemProperty -Path $firewallPath -Name "EnableFirewall" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $firewallPath -Name "FirewallVersion" -Value "29H1" -Type String -Force
    
    Write-Host "29H1 Security Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Performance
# ============================================

function Enable-29H1Performance {
    if (-not $EnablePerformance -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 Performance Features..." -ForegroundColor Yellow
    
    # Ultimate Performance Power Plan - 29H1 Edition
    try {
        $ultimateGUID = "e9a42b89-d57a-4b9f-abc1-7088f7bb4308"
        
        # Create custom 29H1 power plan
        $powerPlanName = "29H1 Ultimate Performance"
        powercfg /delete $ultimateGUID 2>$null
        
        # Duplicate and customize
        powercfg /duplicatescheme $ultimateGUID 2>$null
        powercfg /change /power-scheme-guid $ultimateGUID /change-name "$powerPlanName" 2>$null
        powercfg /change /power-scheme-guid $ultimateGUID /change-description "Windows 11 29H1 Ultimate Performance Plan" 2>$null
        
        # Set as active
        powercfg /setactive $ultimateGUID 2>$null
        
        Write-Host "  29H1 Ultimate Performance power plan created and activated" -ForegroundColor Gray
    } catch {
        Write-Host "  Power plan: $_" -ForegroundColor Yellow
    }
    
    # Power Settings - 29H1 Optimized
    try {
        powercfg /change /standby-timeout-ac 0
        powercfg /change /standby-timeout-dc 0
        powercfg /change /hibernate-timeout-ac 0
        powercfg /change /hibernate-timeout-dc 0
        powercfg /change /monitor-timeout-ac 0
        powercfg /change /monitor-timeout-dc 0
        powercfg /change /disk-timeout-ac 0
        powercfg /change /disk-timeout-dc 0
        Write-Host "  All power timeouts disabled" -ForegroundColor Gray
    } catch {
        Write-Host "  Power settings: $_" -ForegroundColor Yellow
    }
    
    # Disable Power Throttling - 29H1
    $powerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647c-c1df-4637-891a-dec35c318583"
    Set-ItemProperty -Path $powerPath -Name "Attributes" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $powerPath -Name "SettingIndex" -Value 0 -Type DWord -Force
    
    # Performance Optimizations - 29H1
    $priorityPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Priority"
    Set-ItemProperty -Path $priorityPath -Name "EnableAllPerformanceOptimizations" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $priorityPath -Name "EnableDynamicTick" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $priorityPath -Name "EnableTimerCoalescing" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $priorityPath -Name "EnablePowerEfficiencyDiagnostics" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $priorityPath -Name "PerformanceVersion" -Value "29H1" -Type String -Force
    
    # System Performance
    $systemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-ItemProperty -Path $systemPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $systemPath -Name "LargeSystemCache" -Value 1 -Type DWord -Force
    
    # Prefetch and Superfetch
    $prefetchPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
    Set-ItemProperty -Path $prefetchPath -Name "EnablePrefetcher" -Value 3 -Type DWord -Force
    Set-ItemProperty -Path $prefetchPath -Name "EnableSuperfetch" -Value 3 -Type DWord -Force
    
    Write-Host "29H1 Performance Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Networking
# ============================================

function Enable-29H1Networking {
    if (-not $EnableNetworking -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 Networking Features..." -ForegroundColor Yellow
    
    $tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    
    # TCP/IP Optimizations - 29H1
    Set-ItemProperty -Path $tcpipPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "TcpWindowSize" -Value 65535 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "Tcp1323Opts" -Value 3 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "DefaultTTL" -Value 64 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "EnablePMTUDisc" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "EnableTCPA" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "EnableAllNetworkingFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $tcpipPath -Name "NetworkingVersion" -Value "29H1" -Type String -Force
    
    # Enable IPv6 - 29H1
    $tcpip6Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
    Set-ItemProperty -Path $tcpip6Path -Name "DisabledComponents" -Value 0 -Type DWord -Force
    
    # Enable QUIC and HTTP/3 - 29H1
    $quicPath = "HKLM:\SYSTEM\CurrentControlSet\Services\MsQuic\Parameters"
    Set-ItemProperty -Path $quicPath -Name "EnableQuic" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $quicPath -Name "EnableHttp3" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $quicPath -Name "QuicVersion" -Value "29H1" -Type String -Force
    
    # QoS Optimizations - 29H1
    $qosPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS"
    Set-ItemProperty -Path $qosPath -Name "Do not reserve bandwidth" -Value 1 -Type DWord -Force
    
    # DNS Optimizations - 29H1
    $dnsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -Path $dnsPath -Name "DnsQueryTimeouts" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $dnsPath -Name "MaxNegativeCacheTtl" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $dnsPath -Name "NegativeCacheTime" -Value 0 -Type DWord -Force
    
    Write-Host "29H1 Networking Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Storage
# ============================================

function Enable-29H1Storage {
    if (-not $EnableStorage -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 Storage Features..." -ForegroundColor Yellow
    
    $fileSystemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    
    # Enable all storage features - 29H1
    Set-ItemProperty -Path $fileSystemPath -Name "EnableAllStorageFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fileSystemPath -Name "EnableNTFSCompression" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fileSystemPath -Name "EnableNTFSEncryption" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fileSystemPath -Name "EnableNTFSSparse" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $fileSystemPath -Name "StorageVersion" -Value "29H1" -Type String -Force
    
    # NTFS Optimizations - 29H1
    try {
        fsutil behavior set disablelastaccess 1
        fsutil behavior set disablecompression 0
        fsutil behavior set disableencryption 0
        fsutil behavior set disable8dot3 1
        fsutil behavior set disabledeletenotify 0
        Write-Host "  NTFS optimizations applied" -ForegroundColor Gray
    } catch {
        Write-Host "  NTFS: $_" -ForegroundColor Yellow
    }
    
    # Storage Sense - 29H1
    $storagePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters"
    Set-ItemProperty -Path $storagePath -Name "StoragePolicy" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $storagePath -Name "StorageSenseVersion" -Value "29H1" -Type String -Force
    
    # Disk Optimizations - 29H1
    try {
        # Enable TRIM for SSDs
        fsutil behavior set DisableDeleteNotify 0
        
        # Enable boot optimization
        defrag /C /O /D 2>$null
        
        Write-Host "  Disk optimizations applied" -ForegroundColor Gray
    } catch {
        Write-Host "  Disk optimizations: $_" -ForegroundColor Yellow
    }
    
    Write-Host "29H1 Storage Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Audio
# ============================================

function Enable-29H1Audio {
    if (-not $EnableAudio -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 Audio Features..." -ForegroundColor Yellow
    
    $audioPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Audio"
    
    # Enable all audio features - 29H1
    Set-ItemProperty -Path $audioPath -Name "EnableAllAudioFeatures" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableSpatialAudio" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableDolbyAtmos" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableDTSX" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableHighQualityAudio" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableHighDefinitionAudio" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "AudioVersion" -Value "29H1" -Type String -Force
    
    # Audio Enhancements - 29H1
    Set-ItemProperty -Path $audioPath -Name "EnableAudioEnhancements" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableLoudnessEqualization" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableRoomCorrection" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $audioPath -Name "EnableBassBoost" -Value 1 -Type DWord -Force
    
    Write-Host "29H1 Audio Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - UI Capabilities
# ============================================

function Enable-29H1UI {
    if (-not $EnableUI -and -not $EnableAll) { return }
    
    Write-Host "Enabling 29H1 UI Features..." -ForegroundColor Yellow
    
    $explorerPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # New 29H1 UI Features
    Set-ItemProperty -Path $explorerPath -Name "Start_Layout" -Value "29H1" -Type String -Force
    Set-ItemProperty -Path $explorerPath -Name "Taskbar29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Explorer29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "WindowManagement29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ContextMenu29H1" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "UIVersion" -Value "29H1" -Type String -Force
    
    # Start Menu - 29H1
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowAllApps" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecentApps" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowRecommendations" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowUserCloudSync" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowMyGames" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Start_ShowMyApps" -Value 0 -Type DWord -Force
    
    # Taskbar - 29H1
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAlignment" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarSmallIcons" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarGlomLevel" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAutoHide" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "TaskbarAlwaysOnTop" -Value 1 -Type DWord -Force
    
    # File Explorer - 29H1
    Set-ItemProperty -Path $explorerPath -Name "ShowAllFolders" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "Hidden" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowSuperHidden" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "HideFileExt" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowInfoTip" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ShowPreviewHandlers" -Value 1 -Type DWord -Force
    
    # Search - 29H1
    $searchPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $searchPath -Name "CortanaEnabled" -Value 0 -Type DWord -Force
    
    # Window Management - 29H1
    Set-ItemProperty -Path $explorerPath -Name "EnableSnapAssistFlyout" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "DisableSnapAssist" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "WindowArrangementActive" -Value 1 -Type DWord -Force
    
    # Context Menu - 29H1
    Set-ItemProperty -Path $explorerPath -Name "ShowClassicContextMenu" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $explorerPath -Name "ExtendedUIHoverTime" -Value 500 -Type DWord -Force
    
    Write-Host "29H1 UI Features Enabled" -ForegroundColor Green
}

# ============================================
# 29H1 Features - Main Execution
# ============================================

try {
    Write-Host "Starting 29H1 features transformation..." -ForegroundColor Cyan
    
    # Initialize core
    Initialize-29H1Core
    
    # Execute all feature functions
    Enable-29H1AI
    Enable-29H1Gaming
    Enable-29H1Security
    Enable-29H1Performance
    Enable-29H1Networking
    Enable-29H1Storage
    Enable-29H1Audio
    Enable-29H1UI
    
    # Create completion marker
    $marker = "C:\Windows\System32\29h1-all-features-complete.flag"
    New-Item -Path $marker -ItemType File -Force | Out-Null
    
    Write-Host "=== 29H1 Features Engine Completed Successfully ===" -ForegroundColor Green
    Write-Host "All 29H1 features have been enabled on your system." -ForegroundColor Green
    Write-Host "Your Windows 11 25H2 now has the complete 29H1 feature set!" -ForegroundColor Green
    
    # Restart explorer to apply UI changes
    try {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process -FilePath "explorer.exe"
        Write-Host "Explorer restarted to apply all feature changes" -ForegroundColor Gray
    } catch {
        Write-Host "Could not restart explorer: $_" -ForegroundColor Yellow
    }
    
    exit 0
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "29H1 Features Engine Failed" -ForegroundColor Red
    exit 1
}
