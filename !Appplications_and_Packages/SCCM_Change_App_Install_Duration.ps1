#	2014-09-25	IBL	This script is working as expected.
CD C:
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
#	2014-09-25	IBL	This script is working as expected.
#					app_deploymenttypes.txt needs to be formatted with each line containing Application name and DeploymentTypeName with a comma between like the next two lines:
#					.Net 2.0,.Net 2.0
#					.Net 3.5,.Net 3.5
#					SCCM_Export_Application_DeploymentType_Names_LOG.csv can be generated from SCCM_Export_Application_DeploymentType_Names.ps1



C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

$File = 'C:\!Powershell\!SCCM_PS_scripts\SCCM_Export_Application_DeploymentType_Names_LOG.csv'
function RunFunc ($Lines)
{
	$LineSplit = $Lines.split(",")
	$AppName = $LineSplit[0]
	$PKGName = $LineSplit[1]
	Set-CMDeploymentType -ApplicationName $AppName -DeploymentTypeName $PKGName –MsiOrScriptInstaller -MaximumAllowedRunTimeMinutes 15
	Write-Output "Set Application $AppName DeploymentType $PKGName"

    Update-CMDistributionPoint -ApplicationName "$AppName" -DeploymentTypeName "$PKGName"
	Write-Output "Update DP for aplication $AppName DeploymentType $PKGName"
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD C:
