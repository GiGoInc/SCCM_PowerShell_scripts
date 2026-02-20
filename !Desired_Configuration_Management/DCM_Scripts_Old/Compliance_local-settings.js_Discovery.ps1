# "local-settings.js Content" Discovery Script
  }
      {write-host "Not Compliant"}
# "local-settings.js Content" Discovery Script

$list = 'pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);'

$file = 'C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js'
$file86 = 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref\local-settings.js'

if ((test-path $file) -eq $true)
  {
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $file | Measure-object -character -ignorewhitespace).Characters))
      {write-host "Compliant"}
    else
      {write-host "Not Compliant"}
  }

if ((test-path $file86) -eq $true)
  {
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $file86 | Measure-object -character -ignorewhitespace).Characters))
      {write-host "Compliant"}
    else
      {write-host "Not Compliant"}
  }
