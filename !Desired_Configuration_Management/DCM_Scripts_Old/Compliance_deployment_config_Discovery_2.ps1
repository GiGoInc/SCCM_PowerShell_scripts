# "Deployment.config Content" Discovery script
  }
      {write-host "Not Compliant"}
# "Deployment.config Content" Discovery script

$list = "deployment.system.config=file:///C:/Windows/Sun/Java/Deployment/deployment.properties`r`n
deployment.system.config.mandatory=true"

$file = "C:\Windows\Sun\Java\Deployment\deployment.config"

if ((test-path $file) -eq $true)
  {
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $file | Measure-object -character -ignorewhitespace).Characters))
      {write-host "Compliant"}
    else
      {write-host "Not Compliant"}
  }
