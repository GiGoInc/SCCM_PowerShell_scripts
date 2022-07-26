# "Files Exists" Discovery Script

$GUFilex64 = 'C:\Program Files (x86)\Google\Update\GoogleUpdate.exe'
$GUFilex86 = 'C:\Program Files\Google\Update\GoogleUpdate.exe'

if ((Test-Path $GUFilex64) -eq $true -or (Test-Path $GUFilex86) -eq $true)
  {
    write-host "Non-Compliant"
  }
else
  {write-host "Compliant"}