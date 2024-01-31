3@echo off
set version=23.12
for /f "tokens=2 delims==" %%i in ('wmic os get BuildNumber /value ^| find "="') do set "build=%%i"
if %build% gtr 19045 ( set "w11=true" )

:: Update Health Tools
msiexec /X{43D501A5-E5E3-46EC-8F33-9E15D2A2CBD5} /qn /norestart >NUL 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\UpdateHealthTools" /f >NUL 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\rempl" /f >NUL 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\CloudManagedUpdate" /f >NUL 2>nul
rmdir /s /q "%ProgramW6432%\\Microsoft Update Health Tools" >NUL 2>nul

:: PC Health Check
msiexec /X{804A0628-543B-4984-896C-F58BF6A54832} /qn /norestart >NUL 2>nul
rmdir /s /q "%ProgramW6432%\\PCHealthCheck" >NUL 2>nul

:: Windows Installation Assistant
"%ProgramFiles(x86)%\WindowsInstallationAssistant\Windows10UpgraderApp.exe" /SunValley /ForceUninstall >NUL 2>nul
rmdir /s /q "%ProgramFiles(x86)%\WindowsInstallationAssistant" >NUL 2>nul

@REM PowerShell -NonInteractive -NoLogo -NoP -C "Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod" >NUL 2>nul

echo Configuring power settings
powercfg /hibernate off >NUL 2>nul
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >NUL 2>nul
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 3ff9831b-6f80-4830-8178-736cd4229e7b >NUL 2>nul
powercfg -changename 3ff9831b-6f80-4830-8178-736cd4229e7b "Ultra Performance" "Windows's Ultimate Performance with additional changes." >NUL 2>nul
powercfg -s 3ff9831b-6f80-4830-8178-736cd4229e7b >NUL 2>nul
powercfg -setacvalueindex scheme_current sub_processor PERFINCPOL 2 >NUL 2>nul
powercfg -setacvalueindex scheme_current sub_processor PERFDECPOL 1 >NUL 2>nul
powercfg -setacvalueindex scheme_current sub_processor PERFINCTHRESHOLD 10 >NUL 2>nul
powercfg -setacvalueindex scheme_current sub_processor PERFDECTHRESHOLD 8 >NUL 2>nul
powercfg /setactive scheme_current >NUL 2>nul

PowerShell -NonInteractive -NoLogo -NoP -C "& {$cpu = Get-CimInstance Win32_Processor; $cpuName = $cpu.Name; if ($cpu.Manufacturer -eq 'GenuineIntel') { if ($cpuName.Substring(0, 2) -eq 'In') { Write-Host 'Detected Intel CPU older than 10th generation.' } else { $cpuGen = [int]($cpuName.Substring(0, 2)); if ($cpuGen -gt 11) { Write-Host 'Optimizing Ultra powerplan for 12th generation or later Intel CPUs'; powercfg -changename 3ff9831b-6f80-4830-8178-736cd4229e7b 'Ultra Performance' 'Windows''s Ultimate Performance with optimized settings for newer Intel CPUs.'; powercfg -s 3ff9831b-6f80-4830-8178-736cd4229e7b; powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 0; powercfg -setacvalueindex scheme_current sub_processor SCHEDPOLICY 2; powercfg /setactive scheme_current }}};}"

echo Configuring tasks
schtasks /change /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /disable >NUL 2>nul
schtasks /change /tn "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" /disable >NUL 2>nul
schtasks /change /tn "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" /disable >NUL 2>nul
schtasks /change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /disable >NUL 2>nul
schtasks /change /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /disable >NUL 2>nul
schtasks /change /tn "\Microsoft\Windows\Application Experience\AitAgent" /disable >NUL 2>nul
schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable >NUL 2>nul
wevtutil sl Microsoft-Windows-SleepStudy/Diagnostic /q:false >NUL 2>nul
wevtutil sl Microsoft-Windows-Kernel-Processor-Power/Diagnostic /q:false >NUL 2>nul
wevtutil sl Microsoft-Windows-UserModePowerService/Diagnostic /q:false >NUL 2>nul

echo Optimizing NTFS settings
fsutil behavior set disableLastAccess 1 >NUL 2>nul
fsutil behavior set disable8dot3 1 >NUL 2>nul

echo Configuring teredo
netsh interface Teredo set state type=default >NUL 2>nul
netsh interface Teredo set state servername=default >NUL 2>nul

echo Configuring Windows settings
net accounts /maxpwage:unlimited
  
PowerShell -NonInteractive -NoLogo -NoProfile -Command "Disable-MMAgent -mc"
PowerShell -NonInteractive -NoLogo -NoProfile -Command "Disable-WindowsErrorReporting"
powershell -NonInteractive -NoLogo -NoProfile Set-ProcessMitigation -Name vgc.exe -Enable CFG
:: - !cmd: {exeDir: true, command: '@echo Disable-MMAgent -MC; ForEach($v in (Get-Command -Name "Set-ProcessMitigation").Parameters["Disable"].Attributes.ValidValues){Set-ProcessMitigation -System -Disable $v.ToString().Replace(" ", "").Replace("`n", "")}; rm $PSCommandPath> MC_PM.ps1'}
:: - !run: {exeDir: true, exe: 'powershell -windowstyle hidden -ExecutionPolicy Bypass -C "& ''./MC_PM.ps1''"'}
setx DOTNET_CLI_TELEMETRY_OPTOUT 1
setx POWERSHELL_TELEMETRY_OPTOUT 1

echo Configuring StartMenu

if exist "!SystemDrive!\Windows\StartMenuLayout.xml" echo del /q /f "!SystemDrive!\Windows\StartMenuLayout.xml" & del /q /f "!SystemDrive!\Windows\StartMenuLayout.xml"
@REM copy /y "Layout.xml" "!SystemDrive!\Windows\StartMenuLayout.xml"
@REM taskkill /f /im "SearchApp.exe"

mkdir "%SYSTEMDRIVE%\Users\Default\AppData\Local\Microsoft\Windows\Shell" 2>nul
copy /y "StartMenu\LayoutModification.xml" "%SYSTEMDRIVE%\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
copy /y "StartMenu\LayoutModification.json" "%SYSTEMDRIVE%\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.json"
copy /y "StartMenu\DefaultLayouts.xml" "%SYSTEMDRIVE%\Users\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml"

mkdir "%SYSTEMDRIVE%\Users\Default\AppData\Local\Packages\%%d\LocalState" 2>nul
copy /y "StartMenu\settings.json" "%SYSTEMDRIVE%\Users\Default\AppData\Local\Packages\%%d\LocalState\settings.json"

for /f "usebackq tokens=2 delims=\" %%a in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	@REM If the "Volatile Environment" key exists, that means it is a proper user. Built in accounts/SIDs do not have this key.
	reg query "HKEY_USERS\%%a" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > nul 2>&1
	if not !errorlevel! == 1 (
		for /f "usebackq tokens=3* delims= " %%b in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Local AppData" 2^>nul ^| findstr /r /x /c:".*Local AppData[ ]*REG_SZ[ ].*"`) do (
			echo copy /y "LayoutModification.xml" "%%c\Microsoft\Windows\Shell\LayoutModification.xml"
			copy /y "StartMenu\LayoutModification.xml" "%%c\Microsoft\Windows\Shell\LayoutModification.xml"
			echo copy /y "StartMenu\LayoutModification.json" "%%c\Microsoft\Windows\Shell\LayoutModification.json"
			copy /y "StartMenu\LayoutModification.json" "%%c\Microsoft\Windows\Shell\LayoutModification.json"
			echo copy /y "StartMenu\DefaultLayouts.xml" "%%c\Microsoft\Windows\Shell\DefaultLayouts.xml"
			copy /y "StartMenu\DefaultLayouts.xml" "%%c\Microsoft\Windows\Shell\DefaultLayouts.xml"

			@REM Clear start menu pinned items
			for /f "usebackq delims=" %%d in (`dir /b "%%c\Packages" /a:d ^| findstr /c:"Microsoft.Windows.StartMenuExperienceHost"`) do (
				for /f "usebackq delims=" %%e in (`dir /b "%%c\Packages\%%d\LocalState" /a:-d ^| findstr /R /c:"start.\.bin" /c:"start\.bin"`) do (
					echo del /q /f "%%c\Packages\%%d\LocalState\%%e"
					del /q /f "%%c\Packages\%%d\LocalState\%%e"
				)
			)



			@REM This is not an ideal place to put this, but it works
			for /f "usebackq delims=" %%d in (`dir /b "%%c\Packages" /a:d ^| findstr /c:"Microsoft.DesktopAppInstaller"`) do (
				mkdir "%%c\Packages\%%d\LocalState" 2>nul
				echo copy /y "settings.json" "%%c\Packages\%%d\LocalState\settings.json"
				copy /y "settings.json" "%%c\Packages\%%d\LocalState\settings.json"
			)

			@REM echo del /q /f "%%c\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\LocalState\DeviceSearchCache\SettingsCache.txt"
			@REM del /q /f "%%c\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\LocalState\DeviceSearchCache\SettingsCache.txt"
			@REM echo copy /y "SettingsCache.txt" "%%c\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\LocalState\DeviceSearchCache\SettingsCache.txt"
			@REM copy /y "SettingsCache.txt" "%%c\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\LocalState\DeviceSearchCache\SettingsCache.txt"
		)
		@REM echo reg add "HKU\%%a\SOFTWARE\Policies\Microsoft\Windows\Explorer" /f
		@REM reg add "HKU\%%a\SOFTWARE\Policies\Microsoft\Windows\Explorer" /f
		@REM echo reg add "HKU\%%a\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "LockedStartLayout" /t REG_DWORD /d "0" /f
		@REM reg add "HKU\%%a\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "LockedStartLayout" /t REG_DWORD /d "0" /f
		@REM echo reg add "HKU\%%a\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "StartLayoutFile" /t REG_SZ /d "C:\Windows\StartMenuLayout.xml" /f
		@REM reg add "HKU\%%a\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "StartLayoutFile" /t REG_SZ /d "C:\Windows\StartMenuLayout.xml" /f
		for /f "usebackq delims=" %%c in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" ^| findstr /c:"start.tilegrid"`) do (
			echo reg delete "%%c" /f
			reg delete "%%c" /f
		)

		@REM Needed for 23H2, removing StartMenu AppX cache is also required
		reg delete "HKU\%%a\Software\Microsoft\Windows\CurrentVersion\Start" /v "Config" /f
	)
)

::PowerShell -NoP -C "Import-StartLayout -LayoutPath '!SystemDrive!\Windows\StartMenuLayout.xml' -MountPath $env:SystemDrive\\"
::reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /f
::reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "StartLayoutFile" /t REG_SZ /d "!SystemDrive!\Windows\StartMenuLayout.xml" /f

for %%i in (
	"WebExperienceHostApp.exe"
	"WebExperienceHost.dll"
	"SystemSettingsExtensions.dll"
	"WsxPackManager.dll"
) do (
	if exist "!SystemDrive!\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\%%i.bak" del /q /f "!SystemDrive!\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\%%i.bak"

	if exist "!SystemDrive!\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\%%i" (
		ren "!SystemDrive!\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\%%i" "%%i.bak"
	)
)