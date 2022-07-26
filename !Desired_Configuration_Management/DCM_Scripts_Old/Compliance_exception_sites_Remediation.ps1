# "Exception.sites Content" Remediation Script

$list = "file:///
http://192.168.1.10
https://www.salesforce.com/form/conf/demo-marketing.jsp"

try
  {
  New-Item -Path C:\Windows\Sun\Java\Deployment -Force -ItemType Directory
  $list | Out-file C:\Windows\Sun\Java\Deployment\exception.sites -Encoding ASCII -Force
  }
catch
  {$_}