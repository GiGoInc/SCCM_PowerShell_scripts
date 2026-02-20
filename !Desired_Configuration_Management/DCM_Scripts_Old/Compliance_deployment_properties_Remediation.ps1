# "Deployment.properties Content" Remediation Script
  {$_}
catch
# "Deployment.properties Content" Remediation Script

$list = "deployment.javaws.autodownload=NEVER
deployment.javaws.autodownload.locked
deployment.expiration.check.enabled=FALSE
deployment.security.mixcode=HIDE_RUN
deployment.user.security.exception.sites=C\:/Windows/Sun/Java/Deployment/exception.sites"

try
  {
  New-Item -Path C:\Windows\Sun\Java\Deployment -Force -ItemType Directory
  $list | Out-file C:\Windows\Sun\Java\Deployment\deployment.properties -Encoding ASCII -Force
  }
catch
  {$_}
