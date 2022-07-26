# "File Exists" Remediation Script

$ErrorActionPreference = "Stop"

$GUFilex64 = 'C:\Program Files (x86)\Google\Update\GoogleUpdate.exe'
$GUFilex86 = 'C:\Program Files\Google\Update\GoogleUpdate.exe'

if ((Test-Path $GUFilex64) -eq $True)
  {
  try
    {Rename-Item -NewName "$GUFilex64.xxx" -Path $GUFilex64 -Force}
  catch
    { $_.Exception.Message }
  }
else
  {}

# check if deployment.properties file exists, and create/recreate it
if ((Test-Path $GUFilex86) -eq $True)
  {
  try
    {Rename-Item -NewName "$GUFilex86.xxx" -Path $GUFilex86 -Force}
  catch
    { $_.Exception.Message }
  }