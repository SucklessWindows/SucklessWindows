@echo off
setlocal EnableDelayedExpansion

whoami /user | find /i "S-1-5-18" > nul 2>&1 || (
	call C:\SucklessWindows\Modules\RunAsTI.cmd "%~f0" %*
	exit /b
)

sc config WSearch start=disabled > nul
sc stop WSearch > nul 2>&1

echo Finished.
pause
exit /b