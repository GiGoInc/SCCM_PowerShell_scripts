D:
CD E:

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:


Set-CMDeploymentType -ApplicationName "PSTools" -DeploymentTypeName "Install" -MaximumAllowedRunTimeMinutes 30

CD E:
