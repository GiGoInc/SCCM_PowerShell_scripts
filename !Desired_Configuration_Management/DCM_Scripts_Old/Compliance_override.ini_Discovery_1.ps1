# "override.ini Content" Discovery Script
  }
      {write-host "Not Compliant"}
# "override.ini Content" Discovery Script

$list = '[XRE]
EnableProfileMigrator=false'

$file = 'C:\Program Files\Mozilla Firefox\browser\override.ini'
$file86 = 'C:\Program Files (x86)\Mozilla Firefox\browser\override.ini'

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
