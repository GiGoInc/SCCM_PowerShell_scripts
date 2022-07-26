#	2014-10-09	IBL	This script is working as expected.
#					DeploymentList.txt needs to be formatted with each line containing Application Name and Collection ID like the next two lines:
#					.Net 2.0,SCOrch - .Net framework 2.0 for XP
#					.Net 3.5,SCOrch - .Net framework 3.5 for XP
#					DeploymentList.txt can be generated from the exporting and filtering data from the SCCM Console > Monitoring > Deployments


Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Set-Location SS1:


$File = "$PSScriptRoot\DeploymentList.txt"
function RunFunc ($Lines)
{
	$LineSplit = $Lines.split(",")
	$AppName = $LineSplit[0]
	$CollName = $LineSplit[1]
	
	$DeadDate	 = "2015/07/02"
	$DeadTime	 = "12:00"
		
	Set-CMApplicationDeployment -ApplicationName $AppName -CollectionName $CollName -DeadlineDate $DeadDate -DeadlineTime $DeadTime -AppRequiresApproval $False -CreateAlertBaseOnPercentFailure $False -CreateAlertBaseOnPercentSuccess $False -EnableMomAlert $False -OverrideServiceWindow $True -PersistOnWriteFilterDevice $True -PreDeploy $True -RaiseMomAlertsOnFailure $False -RebootOutsideServiceWindow $False -SendWakeUpPacket $True -TimeBaseOn LocalTime -UseMeteredNetwork $True -UserNotification DisplaySoftwareCenterOnly
	Write-Output Set deadline to $DeadDate and $DeadTime for Deployment $AppName to $CollName
}
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:


<#
# Set-CMApplicationDeployment -ApplicationName "`n.Net 2.0" -CollectionName "SCOrch - .Net framework 2.0 for XP" -DeadlineDate "2014/10/09" -DeadlineTime "08:00"
# Set-CMApplicationDeployment -Application "1099 Express Enterprise" -CollectionName "SCOrch - 1099 Express Enterprise" -DeadlineDate 2014/10/09 -DeadlineTime 08:00 -TimeBaseOn LocalTime
# Set-CMApplicationDeployment -ApplicationName ".Net 2.0" -CollectionName "SCOrch - .Net framework 2.0 for XP" -AvaliableDate 2014/10/01 -AvaliableTime 08:00  -DeadlineDate 2014/10/09 -DeadlineTime 08:00 -TimeBaseOn LocalTime



# Set-CMApplicationDeployment PARAMETERS
    -ApplicationName						I.E. - $_.Software
    -CollectionName							I.E. - "Collection Name"
    -AvaliableDate							I.E. - 2014/06/29
    -AvaliableTime							I.E. - 11:22
    -DeadlineDate							I.E. - 2014/06/29
    -DeadlineTime							I.E. - 11:22
    -SendWakeUpPacket						I.E. - $True
    -UserNotification						I.E. - DisplaySoftwareCenterOnly
    -RebootOutsideServiceWindow				I.E. - $True
    -OverrideServiceWindow					I.E. - $True
    -Verbose								I.E. - 

    
    -CollectionName <String>					I.E. - "All Systems"
    -Name <String>							I.E. - "Adobe Reader 11.07"
    -AppRequiresApproval	<Boolean>			I.E. - True | False
    -AvaliableDate <DateTime>				I.E. - YYYY/MM/DD - 2014/07/28  (same format as DeadlineDate)
    -AvaliableTime <DateTime>				I.E. - HH:MM (24hr) - 13:05  (same format as DeadlineTime)
    -Comment <String>						I.E. - "Your comment here"
    -DeadlineDate <DateTime>					I.E. - YYYY/MM/DD - 2014/07/28 (same format as AvaliableDate)
    -DeadlineTime <DateTime>					I.E. - HH:MM (24hr) - 13:05 (same format as AvaliableTime)
    -DeployAction <DeployActionType>			I.E. - Install | Uninstall
    -DeployPurpose <DeployPurposeType>		I.E. - Available | Required
    -EnableMomAlert <Boolean>				I.E. - True | False
    -FailParameterValue <Int32>				I.E. - 	
    -OverrideServiceWindow <Boolean>			I.E. - True | False
    -PersistOnWriteFilterDevice <Boolean>	I.E. - True/False
    -PostponeDate <DateTime>					I.E. - YYYY/MM/DD - 2014/07/28 (same format as AvaliableDate)
    -PostponeTime <DateTime>					I.E. - HH:MM (24hr) - 13:05 (same format as AvaliableTime)
    -PreDeploy <Boolean>						I.E. - True | False
    -RaiseMomAlertsOnFailure <Boolean>		I.E. - True | False
    -RebootOutsideServiceWindow <Boolean>	I.E. - True | False
    -SendWakeUpPacket <Boolean>				I.E. - True | False
    -SuccessParameterValue <Int32>			I.E. - 
    -TimeBaseOn <TimeType>					I.E. - LocalTime | UTC
    -UseMeteredNetwork <Boolean>				I.E. - True | False
    -UserNotification <UserNotificationType>	I.E. - DisplayAll | DisplaySoftwareCenterOnly | HideAll
    -Confirm									I.E. - 
    -WhatIf									I.E. - CommonParameters
#>