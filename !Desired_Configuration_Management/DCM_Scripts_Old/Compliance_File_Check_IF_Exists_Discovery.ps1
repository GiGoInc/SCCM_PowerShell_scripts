# "Java Deployment Files" Discovery Script
  {write-host "Not-Compliant"}
else
# "Java Deployment Files" Discovery Script

$Path1 = "$env:windir\Sun\Java\Deployment"
$Path2 = "$env:windir\Sun\Java\Deployment\deployment.properties"
$Path3 = "$env:windir\Sun\Java\Deployment\deployment.config"
$Path4 = "$env:windir\Sun\Java\Deployment\exception.sites"

if ((Test-Path $Path1) -eq $true -and (Test-Path $Path2) -eq $true -and (Test-Path $Path3) -eq $true -and (Test-Path $Path4) -eq $true)
  {
    write-host "Compliant"
  }
else
  {write-host "Not-Compliant"}
