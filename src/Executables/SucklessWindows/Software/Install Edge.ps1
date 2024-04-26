Set-ExecutionPolicy unrestricted
Write-Host "Installing Microsoft Edge..." -ForegroundColor Cyan

Write-Host "Downloading..."
Invoke-WebRequest 'https://go.microsoft.com/fwlink/?linkid=2109047&Channel=Stable&language=en&brand=M100' -OutFile $env:temp\edge.exe

Write-Host "Installing..."
Start-Process "$env:temp\edge.exe"

Write-Host "Installed Microsoft Edge" -ForegroundColor Green