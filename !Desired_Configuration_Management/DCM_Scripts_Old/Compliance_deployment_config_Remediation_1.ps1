# "Deployment.config Content" Remediation script

$list = "deployment.system.config=file:///C:/Windows/Sun/Java/Deployment/deployment.properties
deployment.system.config.mandatory=true"
try
  {
  New-Item -Path C:\Windows\Sun\Java\Deployment -Force -ItemType Directory
  $list | Out-file C:\Windows\Sun\Java\Deployment\deployment.config -Encoding ASCII -Force
  }
catch
  {$_}