#	2014-09-25	IBL	This script is working as expected.
CD E:
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
#	2014-09-25	IBL	This script is working as expected.
#					app_deploymenttypes.txt needs to be formatted with each line containing Application name and DeploymentTypeName with a comma between like the next two lines:
#					.Net 2.0,.Net 2.0
#					.Net 3.5,.Net 3.5
#					app_deploymenttypes.txt can be generated from Write_to_file_Application_DeploymentType_Names.ps1



D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

$File = "E:\Packages\Powershell_Scripts\app_deploymenttypes.txt"
function RunFunc ($Lines)
{
	$LineSplit = $Lines.split(",")
	$AppName = $LineSplit[0]
	$PKGName = $LineSplit[1]
	Set-CMDeploymentType -ApplicationName $AppName -DeploymentTypeName $PKGName –MsiOrScriptInstaller -MaximumAllowedRunTimeMinutes 30
	Write-Output Set Application $AppName DeploymentType $PKGName
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:
