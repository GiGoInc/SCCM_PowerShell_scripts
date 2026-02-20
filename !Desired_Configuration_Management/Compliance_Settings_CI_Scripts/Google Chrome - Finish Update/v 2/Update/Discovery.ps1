$New = $null
}
'Non-Compliant'
$New = $null
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
$New = 'Found'
}
}
}
}
If ($New -eq $null)
{
'Compliant'
}
Else
{
'Non-Compliant'
}
