#	2014-10-09	IBL	This script is working as expected.
#					DeploymentList.txt needs to be formatted with each line containing Collection ID like the next two lines:
#					SS100045
#					SS100027
#					DeploymentList.txt can be generated from the exporting and filtering data from the SCCM Console > Monitoring > Deployments

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

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