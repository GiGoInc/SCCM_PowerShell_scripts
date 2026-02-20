#	2014-09-25	IBL	This script is working as expected.


#	2014-09-25	IBL	This script is working as expected.
#					applist.txt needs to be formatted with each line containing Application name like the next two lines:
#					.Net 2.0
#					.Net 3.5
#					applist.txt can be generated from exporting and filtering Applications from SCM Console > Monitoring > Distribution Status > Content Status

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

$File = "E:\Packages\Powershell_Scripts\applist.txt"
function RunFunc ($Lines)
{
	$DTs = Get-CMDeploymentType -ApplicationName $Lines
	foreach($DT in $DTs)
	{
	# $DT.LocalizedDisplayName
		Write-Output Application name is: $Lines and DeploymentTypeName is: $DT.LocalizedDisplayName
		$Output = $Lines $DT.LocalizedDisplayName
		$Lines,$DT.LocalizedDisplayName -join ',' | Add-Content "E:\Packages\Powershell_Scripts\SCCM_appplications_and_Package_Names2.txt"
	}
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:












