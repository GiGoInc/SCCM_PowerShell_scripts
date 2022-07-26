D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:


Set-CMDeploymentType -ApplicationName "PSTools" -DeploymentTypeName "Install" -MaximumAllowedRunTimeMinutes 30

CD E: