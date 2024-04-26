@echo off

whoami /user | find /i "S-1-5-18" > nul 2>&1 || (
	call C:\SucklessWindows\Modules\RunAsTI.cmd "%~f0" %*
	exit /b
)

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f > nul

echo Finished, please reboot your device for changes to apply.
pause
exit /b