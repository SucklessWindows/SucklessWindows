@echo off
SETLOCAL ENABLEDELAYEDEXPANSION


:: Clear lockscreen cache
for /d %%x in ("!ProgramData!\Microsoft\Windows\SystemData\*") do (
	for /d %%y in ("%%x\ReadOnly\LockScreen_*") do (
		rd /s /q "%%y" 
	)
)

:: Set sound scheme to 'No Sounds'
reg add "HKU\%~1\AppEvents\Schemes" /ve /d ".None" /f > nul
PowerShell -NoP -C "New-PSDrive HKU Registry HKEY_USERS; Get-ChildItem -Path 'HKU:\%~1\AppEvents\Schemes\Apps' | Get-ChildItem | Get-ChildItem | Where-Object {$_.PSChildName -eq '.Current'} | Set-ItemProperty -Name '(Default)' -Value ''" > nul

:: Clean sth

del /q /f "%~2\Microsoft\Windows\Themes\TranscodedWallpaper" > nul 2>&1
rmdir /q /s "%~2\Microsoft\Windows\Themes\CachedFiles" > nul 2>&1