# "local-settings.js Content" Remediation Script
  {$_}
catch
# "local-settings.js Content" Remediation Script

$list = 'pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);'

try
  {
  If (Test-Path 'C:\Program Files\Mozilla Firefox')
  {
  New-Item -Path 'C:\Program Files\Mozilla Firefox\defaults\pref' -Force -ItemType Directory
  $list | Out-file 'C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js'-Encoding ASCII -Force
  }
  
  If (Test-Path 'C:\Program Files (x86)\Mozilla Firefox')
  {
  New-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref' -Force -ItemType Directory
  $list | Out-file 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref\local-settings.js'-Encoding ASCII -Force
  }
  } 
catch
  {$_}
