@echo off

(
	reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "1" /f
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "1" /f
	reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "1" /f
	reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask" /t REG_BINARY /d "9E1E078012000000" /f
) > nul

if "%~1"=="/silent" exit /b

choice /c:yn /n /m "Finished, would you like to logout to apply the changes? [Y/N] "
if %ERRORLEVEL% == 1 logoff
exit /b