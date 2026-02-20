#	2014-10-09	IBL	This script is working as expected.
CD E:
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
#	2014-10-09	IBL	This script is working as expected.
#					DeploymentList.txt needs to be formatted with each line containing Collection ID like the next two lines:
#					XX100045
#					XX100027
#					DeploymentList.txt can be generated from the exporting and filtering data from the SCCM Console > Monitoring > Deployments

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

$File = "E:\Packages\Powershell_Scripts\CollectionNames.txt"
function RunFunc ($Lines)
{
	$DeadlineDate	 = "2014/10/09"
	$DeadlineTime	 = "08:00"
	
	$Output = Get-CMDeployment -CollectionName $Lines
	$Output | Add-Content "E:\Packages\Powershell_Scripts\Deployment_Properties.txt"
}
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:
