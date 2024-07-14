$ErrorActionPreference = 'SilentlyContinue'
# As cleanmgr has multiple processes, there's no point in making the window hidden as it won't apply
function Invoke-SWDiskCleanup {
	# Kill running cleanmgr instances, as they will prevent new cleanmgr from starting
	Get-Process -Name cleanmgr -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
	# Disk Cleanup preset
	# 2 = enabled
	# 0 = disabled
	$baseKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
	$regValues = @{
        "Active Setup Temp Folders"      = 2
        "BranchCache"                    = 2
        "Compress Old Files"             = 2
        "D3D Shader Cache"               = 2
        "Delivery Optimization Files"    = 2
        "Device Driver Packages"         = 2
        "Diagnostic Data Viewer database files" = 2
        "Downloaded Program Files"       = 2
        "Feedback Hub Archive log files" = 2
        "Internet Cache Files"           = 2
        "Language Pack"                  = 0
        "Offline Pages Files"            = 2
        "Old ChkDsk Files"               = 2
        "Offline Files"                  = 2
        "Previous Installations"         = 2
        "Recycle Bin"                    = 0
        "RetailDemo Offline Content"     = 2
        "Setup Log Files"                = 2
        "System error memory dump files" = 2
        "System error minidump files"    = 2
        "Thumbnail Cache"                = 2
        "Temporary Files"                = 2
        "Temporary Offline Files"        = 2
        "Temporary Internet Files"       = 2
        "Temporary Setup Files"          = 2
        "Temporary Sync Files"           = 2
        "Update Cleanup"                 = 2
        "Update package Backup Files"    = 2
        "Upgrade Discarded Files"        = 2
        "User file versions"             = 2
        "Windows Defender"               = 2
        "Windows Error Reporting Files"  = 2
        "Windows Reset Log Files"        = 2
        "Windows Upgrade Log Files"      = 2    
	}
	foreach ($entry in $regValues.GetEnumerator()) {
		$key = "$baseKey\$($entry.Key)"

		if (!(Test-Path $key)) {
			Write-Output "'$key' not found, not configuring it."
		} else {
			Set-ItemProperty -Path "$baseKey\$($entry.Key)" -Name 'StateFlags2408' -Value $entry.Value -Type DWORD
		}
	}

	# Run preset 64 (0-65535)
	Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:2408 /Autoclean" 2>&1 | Out-Null
}

# Check for other installations of Windows
# If so, don't cleanup as it will also cleanup other drives
$excludedDrive = "C"
$drives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.Name -ne $excludedDrive }
foreach ($drive in $drives) {
    if (!(Test-Path -Path $(Join-Path -Path $drive.Root -ChildPath 'Windows') -PathType Container)) {
        Invoke-SWDiskCleanup
    }
}

Write-Host "Cleaning up Event Logs"
Get-EventLog -LogName * | ForEach-Object { Clear-EventLog $_.Log }

Write-Host "Disabling Reserved Storage"
Set-WindowsReservedStorageState -State Disabled

Stop-Service -Name "bits" -Force | Out-Null
Stop-Service -Name "appidsvc" -Force | Out-Null
Stop-Service -Name "dps" -Force | Out-Null
Stop-Service -Name "wuauserv" -Force | Out-Null
Stop-Service -Name "cryptsvc" -Force | Out-Null

Write-Host "Cleaning up leftovers"
$foldersToRemove = @(
    "CbsTemp",
    "Logs",
    "SoftwareDistribution",
    "System32\LogFiles",
    "System32\LogFiles\WMI,"
    "System32\SleepStudy",
    "System32\sru",
    "System32\WDI\LogFiles",
    "System32\winevt\Logs",
    "SystemTemp",
    "Temp"

    # "WinSxS\Backup"
    # "Panther",
    # "Prefetch"
)

foreach ($folderName in $foldersToRemove) {
    $folderPath = Join-Path $env:SystemRoot $folderName
    if (Test-Path $folderPath) {
        Remove-Item -Path "$folderPath\*" -Force -Recurse | Out-Null
    }
}

# Remove-Item -Path "C:\Program Files\WindowsApps\MicrosoftWindows.Client.WebExperience*" -Recurse -Force

Get-ChildItem -Path "$env:SystemRoot" -Filter *.log -File -Recurse -Force | Remove-Item -Recurse -Force | Out-Null

Write-Host "Cleaning up %TEMP%"
Get-ChildItem -Path "$env:TEMP" -Exclude "AME" | Remove-Item -Recurse -Force

# Just in case
Start-ScheduledTask -TaskPath "\Microsoft\Windows\DiskCleanup\" -TaskName "SilentCleanup"

# Write-Host "Cleaning up Retail Demo Content"
# Start-ScheduledTask -TaskPath "\Microsoft\Windows\RetailDemo\" -TaskName "CleanupOfflineContent"

# Write-Host "Cleaning up the WinSxS Components"
# DISM /Online /Cleanup-Image /StartComponentCleanup

$edgeUpdatePath = ${env:ProgramFiles(x86)} + "\Microsoft\EdgeUpdate\Download"
if (Test-Path -Path $edgeUpdatePath) {
    Remove-Item -Path $edgeUpdatePath -Force -Recurse | Out-Null
}