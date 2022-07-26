# "Java Deployment Files" Remediation Script #

$ErrorActionPreference = "Stop"

# check if $env:windir\Sun\Java\Deployment exists, if not create it
if ((Test-Path $env:windir\Sun\Java\Deployment) -eq $false)
  {
#  write-host "$env:windir\Sun\Java\Deployment doesn't exist.  Let's create it..."
  try
    { New-Item -Path $env:windir\Sun\Java\Deployment -ItemType Directory -Force -ErrorAction Stop | Out-Null }
  catch
    { $_.Exception.Message }
  }
else
  {}

# check if deployment.properties file exists, and create/recreate it
if ((Test-Path $env:windir\Sun\Java\Deployment\deployment.properties) -eq $true)
  {
  try
    { Remove-Item $env:windir\Sun\Java\Deployment\deployment.properties -Force -ErrorAction Stop | Out-Null }
  catch
    { $_.Exception.Message }
  }
try
  {
  New-Item -Path $env:windir\Sun\Java\Deployment -Name deployment.properties -ItemType File -Force -Value `
"deployment.javaws.autodownload=NEVER
deployment.javaws.autodownload.locked
deployment.expiration.check.enabled=FALSE
deployment.security.mixcode=HIDE_RUN
deployment.user.security.exception.sites=C\:/Windows/Sun/Java/Deployment/exception.sites" | Out-Null
  }
  catch
  { $_.Exception.Message }

# check if deployment.config file exists, and create/recreate it
if ((Test-Path $env:windir\Sun\Java\Deployment\deployment.config) -eq $true)
  {
  try
    { Remove-Item $env:windir\Sun\Java\Deployment\deployment.config -Force -ErrorAction Stop | Out-Null }
  catch
    { $_.Exception.Message }
  }
try
  {
  New-Item -Path $env:windir\Sun\Java\Deployment -Name deployment.config -ItemType File -Force -Value `
"deployment.system.config=file:///C:/Windows/Sun/Java/Deployment/deployment.properties
deployment.system.config.mandatory=true" | Out-Null
  }
  catch
  { $_.Exception.Message }

# check if exception.sites file exists, and create/recreate it
if ((Test-Path $env:windir\Sun\Java\Deployment\exception.sites) -eq $true)
  {
  try
    { Remove-Item $env:windir\Sun\Java\Deployment\exception.sites -Force -ErrorAction Stop | Out-Null }
  catch
    { $_.Exception.Message }
  }
try
  {
  New-Item -Path $env:windir\Sun\Java\Deployment -Name exception.sites -ItemType File -Force -Value `
  "file:///
http://192.168.1.10
https://www.salesforce.com/form/conf/demo-marketing.jsp" | Out-Null
  }
  catch
  { $_.Exception.Message }