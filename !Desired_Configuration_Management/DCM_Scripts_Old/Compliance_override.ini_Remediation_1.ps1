# "override.ini Content" Remediation Script
  {$_}
catch
# "override.ini Content" Remediation Script

$list = '[XRE]
EnableProfileMigrator=false'

try
  {
  If (Test-Path 'C:\Program Files\Mozilla Firefox')
  {
  New-Item -Path 'C:\Program Files\Mozilla Firefox\browser' -Force -ItemType Directory
  $list | Out-file 'C:\Program Files\Mozilla Firefox\browser\override.ini'-Encoding ASCII -Force
  }
  
  If (Test-Path 'C:\Program Files (x86)\Mozilla Firefox')
  {
  New-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\browser' -Force -ItemType Directory
  $list | Out-file 'C:\Program Files (x86)\Mozilla Firefox\browser\override.ini'-Encoding ASCII -Force
  }
  } 
catch
  {$_}
