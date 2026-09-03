param (
	[Parameter( Mandatory = $True )]
	[string]$FilePath
)

if (Test-Path $FilePath) { exit }

.\29H1AtlasModules\initPowerShell.ps1

Write-Host "=== Windows 11 29H1 Backup Script ===" -ForegroundColor Cyan

$content = [System.Collections.Generic.List[string]]::new()
$content.Add("Windows Registry Editor Version 5.00")
$content.Add("; Windows 11 29H1 Service Backup")
$content.Add("; Generated for 25H2 to 29H1 transformation")
$content.Add("")

# Check for 29H1 mode
$29h1Path = "HKLM:\SOFTWARE\AtlasOS"
$29h1Mode = $false
if (Test-Path $29h1Path) {
    $29h1Mode = (Get-ItemProperty -Path $29h1Path -Name "29H1_Mode" -ErrorAction SilentlyContinue).29H1_Mode -eq 1
    if ($29h1Mode) {
        Write-Host "29H1 Mode detected - Creating 29H1 backup" -ForegroundColor Green
    }
}

# 29H1: Backup all services
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services" | ForEach-Object {
	try {
		$values = Get-ItemProperty -Path $_.PSPath -Name 'Start', 'Description' -EA Stop
		
		# 29H1: Keep Defender and security services
		if ($values.Description -notmatch 'Windows Defender' -and $values.Description -notmatch 'Core Isolation' -and $values.Description -notmatch 'Device Guard') {
			$content.Add("")
			$content.Add("[$($_.Name)]")
			$content.Add('"Start"=dword:0000000' + $values.Start)
			
			# Backup DisplayName if available
			if ($values.DisplayName) {
				$content.Add('"DisplayName"="' + $values.DisplayName + '"')
			}
			
			# Backup other important values
			$allValues = Get-ItemProperty -Path $_.PSPath
			$allValues.PSObject.Properties | Where-Object { $_.Name -ne 'PSPath' -and $_.Name -ne 'PSParentPath' -and $_.Name -ne 'PSChildName' -and $_.Name -ne 'PSDrive' -and $_.Name -ne 'PSProvider' } | ForEach-Object {
				if ($_.Value -ne $null) {
					$content.Add('"' + $_.Name + '"="' + $_.Value + '"')
				}
			}
		} else {
			Write-Output "Preserving $($_.Name) for 29H1 security..." -ForegroundColor Yellow
		}
	} catch {}
}

# Add 29H1 specific backup information
$content.Add("")
$content.Add("")
$content.Add("; 29H1 Backup Information")
$content.Add("; Backup Date: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
$content.Add("; Target Build: 26200 (25H2)")
$content.Add("; Transformation: Windows 11 29H1")
$content.Add("; Mode: " + ($29h1Mode ? "29H1" : "25H2"))

# Set-Content can only do UTF8 with BOM, which doesn't work with reg.exe
[System.IO.File]::WriteAllLines($FilePath, $content, (New-Object System.Text.UTF8Encoding $false))

Write-Host "29H1 Backup Complete: $FilePath" -ForegroundColor Green

# Set 29H1 backup flag
if (-not (Test-Path $29h1Path)) { New-Item -Path $29h1Path -Force | Out-Null }
Set-ItemProperty -Path $29h1Path -Name "29H1_Backup_Complete" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $29h1Path -Name "BackupDate" -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Type String -Force
