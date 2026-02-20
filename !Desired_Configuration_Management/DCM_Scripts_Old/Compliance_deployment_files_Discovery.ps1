# "Java Deployment Files" Discovery Script
  {write-host "Not-Compliant"}
else
# "Java Deployment Files" Discovery Script

if ((Test-Path $env:windir\Sun\Java\Deployment) -eq $true -and `
(Test-Path $env:windir\Sun\Java\Deployment\deployment.properties) -eq $true -and `
(Test-Path $env:windir\Sun\Java\Deployment\deployment.config) -eq $true -and `
(Test-Path $env:windir\Sun\Java\Deployment\exception.sites) -eq $true)
  {
    write-host "Compliant"
  }
else
  {write-host "Not-Compliant"}
