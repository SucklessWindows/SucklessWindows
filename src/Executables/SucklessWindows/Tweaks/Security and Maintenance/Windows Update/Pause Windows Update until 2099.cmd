@echo off

whoami /user | find /i "S-1-5-18" > nul 2>&1 || (
	call C:\SucklessWindows\Modules\RunAsTI.cmd "%~f0" %*
	exit /b
)

(
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseUpdatesExpiryTime" /t REG_SZ /d "2099-11-11T11:11:11Z" /f
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseFeatureUpdatesEndTime" /t REG_SZ /d "2099-11-11T11:11:11Z" /f
	reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseQualityUpdatesEndTime" /t REG_SZ /d "2099-11-11T11:11:11Z" /f	
) > nul

echo Finished, please reboot your device for changes to apply.
pause
exit /b