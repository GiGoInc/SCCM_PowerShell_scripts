#	2014-09-25	IBL	This script is working as expected.
#					app_deploymenttypes.txt needs to be formatted with each line containing Application name and DeploymentTypeName with a comma between like the next two lines:
#					.Net 2.0,.Net 2.0
#					.Net 3.5,.Net 3.5
#					app_deploymenttypes.txt can be generated from SCCM_Export_Application_DeploymentType_Names.ps1

C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$File = "C:\!Powershell\!SCCM_PS_scripts\SCCM_Export_Application_DeploymentType_Names_list.txt"
function RunFunc ($Lines)
{
	$DTs = Get-CMDeploymentType -ApplicationName $Lines
	foreach($DT in $DTs)
		{
		# $DT.LocalizedDisplayName
			Write-Output "Application name is: $Lines and DeploymentTypeName is: $DT.LocalizedDisplayName"
			#$Output = $Lines $DT.LocalizedDisplayName
			$Lines,$DT.LocalizedDisplayName -join ',' | Add-Content "C:\!Powershell\!SCCM_PS_scripts\SCCM_Export_Application_DeploymentType_Names_LOG.csv"
		}
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD C: