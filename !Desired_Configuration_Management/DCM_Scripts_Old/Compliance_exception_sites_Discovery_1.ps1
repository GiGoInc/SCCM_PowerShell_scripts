# "exception.sites Content" Discovery Script

$list = "file:///
http://192.168.1.10
https://www.salesforce.com/form/conf/demo-marketing.jsp"
$file = "C:\Windows\Sun\Java\Deployment\exception.sites"

if ((test-path $file) -eq $true)
  {
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -le ((Get-content $file | Measure-object -character -ignorewhitespace).Characters))
      {write-host "Compliant"}
    else
      {write-host "Not Compliant"}
  }