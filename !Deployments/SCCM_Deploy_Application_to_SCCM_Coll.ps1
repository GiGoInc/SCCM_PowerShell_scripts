#	2014-10-08	IBL	This script is working as expected.

#	$CollName = "Test - Isaac's VMs"
#	$CollID = "SS100176"
#	$File = "E:\Packages\Powershell_Scripts\applist.txt"

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

    $File = "E:\Packages\Powershell_Scripts\applist.txt"
$CollName = "Test - Isaac's VMs"
  $CollID = "SS100176"
	
function AppDeploy ($AppName)
{
	$ADate = Get-Date -UFormat "%Y/%m/%d"
	$ATime = Get-Date -UFormat "%R"

	$DAction = "Install"
	$Comm = "Deployment from POWERSHELL of $AppName to $CollName"

$DeploymentHash = @{
					CollectionName = $CollName
					Name = $AppName
					AvaliableDate = $ADate
					AvaliableTime = $ATime
					Comment = $Comm
					DeployAction = $DAction
					EnableMomAlert = $False
					FailParameterValue = 40
					OverrideServiceWindow = $True
					PersistOnWriteFilterDevice = $False
					PreDeploy = $True
					RaiseMomAlertsOnFailure = $False
					RebootOutsideServiceWindow = $True
					SendWakeUpPacket = $True
					TimeBaseOn = "LocalTime"
					UseMeteredNetwork = $True
					UserNotification = "DisplaySoftwareCenterOnly"
                    }
Write-Output Comment - $Comm
Start-CMApplicationDeployment @DeploymentHash

}

				
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:AppDeploy} -ArgumentList $_}




#  Start-CMApplicationDeployment PARAMETERS
#  -CollectionName <String>					I.E. - "All Systems"
#  -Name <String>							I.E. - "Adobe Reader 11.07"
#  -AppRequiresApproval	<Boolean>			I.E. - True | False
#  -AvaliableDate <DateTime>				I.E. - YYYY/MM/DD - 2014/07/28  (same format as DeadlineDate)
#  -AvaliableTime <DateTime>				I.E. - HH:MM (24hr) - 13:05  (same format as DeadlineTime)
#  -Comment <String>						I.E. - "Your comment here"
#  -DeadlineDate <DateTime>					I.E. - YYYY/MM/DD - 2014/07/28 (same format as AvaliableDate)
#  -DeadlineTime <DateTime>					I.E. - HH:MM (24hr) - 13:05 (same format as AvaliableTime)
#  -DeployAction <DeployActionType>			I.E. - Install | Uninstall
#  -DeployPurpose <DeployPurposeType>		I.E. - Available | Required
#  -EnableMomAlert <Boolean>				I.E. - True | False
#  -FailParameterValue <Int32>				I.E. - 	
#  -OverrideServiceWindow <Boolean>			I.E. - True | False
#  -PersistOnWriteFilterDevice <Boolean>	I.E. - True/False
#  -PostponeDate <DateTime>					I.E. - YYYY/MM/DD - 2014/07/28 (same format as AvaliableDate)
#  -PostponeTime <DateTime>					I.E. - HH:MM (24hr) - 13:05 (same format as AvaliableTime)
#  -PreDeploy <Boolean>						I.E. - True | False
#  -RaiseMomAlertsOnFailure <Boolean>		I.E. - True | False
#  -RebootOutsideServiceWindow <Boolean>	I.E. - True | False
#  -SendWakeUpPacket <Boolean>				I.E. - True | False
#  -SuccessParameterValue <Int32>			I.E. - 
#  -TimeBaseOn <TimeType>					I.E. - LocalTime | UTC
#  -UseMeteredNetwork <Boolean>				I.E. - True | False
#  -UserNotification <UserNotificationType>	I.E. - DisplayAll | DisplaySoftwareCenterOnly | HideAll
#  -Confirm									I.E. - 
#  -WhatIf									I.E. - CommonParameters
