D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$File = "E:\Packages\applist.txt"

	
function DeployRemove ($AppName)
{
	$ADate = Get-Date -UFormat "%Y/%m/%d"
	$ATime = Get-Date -UFormat "%R"
	$CollName = "Test - Isaac's VMs"
	$CollID = "SS100176"
	#$AppName = "Dymo Labels"
	$DAction = "Install"
	$Comm = "Deployment from POWERSHELL to $CollName of $AppName"


$DeploymentHash = @{
					CollectionName = $CollName
					ApplicationName = $AppName
                    }
					
Write-Output Collname - $CollName
Write-Output CollID - $CollID
Write-Output AppName - $AppName
Write-Output AvailableDate -  $ADate
Write-Output AvailableTime - $ATime
Write-Output Comment - $Comm
Write-Output DeployAction - $DAction
					
Remove-CMDeployment @DeploymentHash -force

}					
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:DeployRemove} -ArgumentList $_}




#  Remove-CMDeployment PARAMETERS
#  -ApplicationName <String>	I.E. - "Adobe Reader 11.07"
#  -CollectionName <String>		I.E. - "All Systems"
#  -Force						I.E. - "All Systems"
#  -Confirm						I.E. - 
#  -WhatIf						I.E. - CommonParameters