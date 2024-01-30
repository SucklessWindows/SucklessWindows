@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

robocopy "Wallpapers" "C:\Windows\Wallpapers" /E /IM /IT /NP
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "" /f 
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "C:\Windows\Wallpapers\img.png" /f 
reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 2 /f

rundll32.exe user32.dll, UpdatePerUserSystemParameters

:: Set sound scheme to 'No Sounds'
reg add "HKU\%~1\AppEvents\Schemes" /ve /d ".None" /f > nul
PowerShell -NoP -C "New-PSDrive HKU Registry HKEY_USERS; Get-ChildItem -Path 'HKU:\%~1\AppEvents\Schemes\Apps' | Get-ChildItem | Get-ChildItem | Where-Object {$_.PSChildName -eq '.Current'} | Set-ItemProperty -Name '(Default)' -Value ''" > nul
