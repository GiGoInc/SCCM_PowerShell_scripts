$ErrorActionPreference = 'SilentlyContinue'
}
}
$ErrorActionPreference = 'SilentlyContinue'
$Installs = "C:\Program Files\Google\Chrome\Application\chrome.exe", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$NewInstalls = "C:\Program Files\Google\Chrome\Application\new_chrome.exe", "C:\Program Files (x86)\Google\Chrome\Application\new_chrome.exe"

ForEach ($Install in $Installs)
{
IF (Test-Path $Install)
{
$install
ForEach ($NewInstall in $NewInstalls)
{
IF (Test-Path $NewInstall)
{
$NewInstall
$Processes = Get-WmiObject -Class Win32_Process -Filter "name='chrome.exe'"
foreach ($process in $processes)
{
$returnval = $process.terminate()
$processid = $process.handle
}
If ((Test-Path $Install) -and (Test-Path $NewInstall)) { Remove-Item $Install -Force }
Start-Sleep -Seconds 1
If (Test-Path $NewInstall) { Rename-Item $NewInstall 'chrome.exe' -Force }
}
}
}
}
