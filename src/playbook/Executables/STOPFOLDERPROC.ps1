# Windows 11 29H1 Stop Folder Processes
# Stops processes running from 29H1 folders during transformation

Write-Host "=== Windows 11 29H1 Stop Folder Processes ===" -ForegroundColor Cyan

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
}

$windir = [Environment]::GetFolderPath('Windows')

# 29H1: Include 29H1 folders in target roots
$targetRoots = @(
    Join-Path $windir '29H1AtlasModules'
    Join-Path $windir '29H1AtlasDesktop'
    Join-Path $windir 'AtlasModules'
    Join-Path $windir 'AtlasDesktop'
) | ForEach-Object {
    try {
        ([System.IO.Path]::GetFullPath($_)).TrimEnd('\')
    }
    catch {
        $null
    }
} | Where-Object { $_ }

if (-not $targetRoots) { 
    Write-Host "No target roots found, exiting" -ForegroundColor Yellow
    exit 0
}

Write-Host "29H1 Target roots: $($targetRoots -join ', ')" -ForegroundColor Gray

function Stop-ProcessesUnderRoots {
    param([string[]]$RootsLower)

    foreach ($proc in Get-Process -ErrorAction SilentlyContinue) {
        if (-not $proc.Path) { continue }

        $procPath = try {
            ([System.IO.Path]::GetFullPath($proc.Path)).ToLowerInvariant()
        }
        catch {
            continue
        }

        foreach ($root in $RootsLower) {
            if ($procPath.StartsWith($root)) {
                try {
                    Write-Host "Stopping process: $($proc.ProcessName) (ID: $($proc.Id))" -ForegroundColor Gray
                    Stop-Process -Id $proc.Id -Force -ErrorAction Stop
                    Wait-Process -Id $proc.Id -ErrorAction SilentlyContinue -Timeout 5
                }
                catch {
                    Write-Warning "Could not stop process $($proc.ProcessName): $_"
                    continue
                }

                break
            }
        }
    }
}

function Stop-TasksUnderRoots {
    param([string[]]$RootsLower)

    try {
        Import-Module ScheduledTasks -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        Write-Warning "ScheduledTasks module not available, using fallback"
    }

    $tasks = @()
    try {
        $tasks = Get-ScheduledTask -ErrorAction Stop
    }
    catch {
        $tasks = @()
    }

    foreach ($task in $tasks) {
        $matchesRoot = $false

        foreach ($action in $task.Actions) {
            $execute = $null
            if ($action.PSObject.Properties.Match('Execute').Count) {
                $execute = $action.Execute
            }
            elseif ($action.PSObject.Properties.Match('Path').Count) {
                $execute = $action.Path
            }

            if (-not $execute) { continue }

            $executeLower = try {
                ([System.IO.Path]::GetFullPath($execute)).ToLowerInvariant()
            }
            catch {
                $null
            }

            if (-not $executeLower) { continue }

            foreach ($root in $RootsLower) {
                if ($executeLower.StartsWith($root)) {
                    $matchesRoot = $true
                    break
                }
            }

            if ($matchesRoot) { break }
        }

        if (-not $matchesRoot) { continue }

        try {
            Write-Host "Stopping scheduled task: $($task.TaskName)" -ForegroundColor Gray
            Stop-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
        }
        catch {
            Write-Warning "Could not stop task $($task.TaskName): $_"
        }
    }

    # 29H1: Stop Force Timer Resolution tasks
    foreach ($candidate in @('Force Timer Resolution', '\Force Timer Resolution', '29H1 Force Timer Resolution')) {
        & schtasks.exe /End /TN $candidate 1>$null 2>$null
    }
}

$rootsLower = $targetRoots | ForEach-Object { ($_ + '\').ToLowerInvariant() }

Write-Host "Stopping processes under 29H1 roots..." -ForegroundColor Yellow
Stop-ProcessesUnderRoots -RootsLower $rootsLower

Write-Host "Stopping scheduled tasks under 29H1 roots..." -ForegroundColor Yellow
Stop-TasksUnderRoots -RootsLower $rootsLower

# 29H1: Handle SetTimerResolution.exe
$timerExePath = Join-Path $windir '29H1AtlasModules\Tools\29H1-SetTimerResolution.exe'
if (Test-Path $timerExePath) {
    try {
        $stream = [System.IO.File]::Open($timerExePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        $stream.Dispose()
    }
    catch {
        Write-Host "Timer resolution file locked, retrying..." -ForegroundColor Gray
        Stop-ProcessesUnderRoots -RootsLower $rootsLower
        Start-Sleep -Milliseconds 500
    }
} else {
    # Fallback to original path
    $timerExePath = Join-Path $windir 'AtlasModules\Tools\SetTimerResolution.exe'
    if (Test-Path $timerExePath) {
        try {
            $stream = [System.IO.File]::Open($timerExePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            $stream.Dispose()
        }
        catch {
            Stop-ProcessesUnderRoots -RootsLower $rootsLower
            Start-Sleep -Milliseconds 500
        }
    }
}

# Set 29H1 flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Processes_Stopped" -Value 1 -Type DWord -Force

Write-Host "29H1 Stop Folder Processes Complete" -ForegroundColor Green
exit 0
