# "Deployment.properties Content" Discovery Script
  }
      {write-host "Not Compliant"}
# "Deployment.properties Content" Discovery Script

$list = "deployment.javaws.autodownload=NEVER
deployment.javaws.autodownload.locked
deployment.expiration.check.enabled=FALSE
deployment.security.mixcode=HIDE_RUN
deployment.user.security.exception.sites=C\:/Windows/Sun/Java/Deployment/exception.sites"

$file = "C:\Windows\Sun\Java\Deployment\deployment.properties"

if ((test-path $file) -eq $true)
  {
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $file | Measure-object -character -ignorewhitespace).Characters))
      {write-host "Compliant"}
    else
      {write-host "Not Compliant"}
  }
