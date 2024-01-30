@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

robocopy "Wallpapers" "%windir%\Wallpapers" /E /IM /IT /NP
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "" /f 
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "C:\Windows\Wallpapers\img.png" /f 
reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 2 /f

:: Clear lockscreen cache
for /d %%x in ("!ProgramData!\Microsoft\Windows\SystemData\*") do (
	for /d %%y in ("%%x\ReadOnly\LockScreen_*") do (
		rd /s /q "%%y" 
	)
)


rmdir /q /s "!appdata!\Microsoft\Windows\Themes"
rundll32.exe user32.dll, UpdatePerUserSystemParameters

@REM if not "%~1"=="AME_UserHive_Default" (
@REM 	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\%~1" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f > nul
@REM )
@REM reg add "HKU\%~1\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f > nul

:: Set sound scheme to 'No Sounds'
reg add "HKU\%~1\AppEvents\Schemes" /ve /d ".None" /f > nul
PowerShell -NoP -C "New-PSDrive HKU Registry HKEY_USERS; Get-ChildItem -Path 'HKU:\%~1\AppEvents\Schemes\Apps' | Get-ChildItem | Get-ChildItem | Where-Object {$_.PSChildName -eq '.Current'} | Set-ItemProperty -Name '(Default)' -Value ''" > nul
