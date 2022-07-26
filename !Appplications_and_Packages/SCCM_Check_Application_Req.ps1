<#

#>

[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
 
$SiteServer = "SCCMSERVER"
$SiteCode = "SS1"

Set-Location SS1:
CD SS1:

$DeploymentTypes = Get-CMDeploymentType -ApplicationName "Visio Standard 2013"
$SDMPackageXML = $DeploymentTypes | Select SDMPackageXML -ExpandProperty SDMPackageXML
$DTInfo = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($SDMPackageXML)	
$DTRequirement = $DTInfo[0]
$DTInstaller = $DTRequirement | Select title -ExpandProperty title
$DTInstaller