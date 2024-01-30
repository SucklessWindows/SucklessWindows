@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

move "Wallpapers" "C:\Windows\Wallpapers" /Y
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "" /f 
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "C:\Windows\Wallpapers\img.png" /f 
reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 2 /f

RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True

:: Set sound scheme to 'No Sounds'
reg add "HKU\%~1\AppEvents\Schemes" /ve /d ".None" /f > nul
PowerShell -NoP -C "New-PSDrive HKU Registry HKEY_USERS; Get-ChildItem -Path 'HKU:\%~1\AppEvents\Schemes\Apps' | Get-ChildItem | Get-ChildItem | Where-Object {$_.PSChildName -eq '.Current'} | Set-ItemProperty -Name '(Default)' -Value ''" > nul
