@echo off

(
	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f
	reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f
	reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f
	reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d "0" /f
) > nul

if "%~1"=="/silent" exit /b

choice /c:yn /n /m "Finished, would you like to logout to apply the changes? [Y/N] "
if %ERRORLEVEL% == 1 logoff
exit /b