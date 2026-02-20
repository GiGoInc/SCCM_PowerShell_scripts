#	$CollName = "Test - SuperUser's VMs"
#>

#	$CollName = "Test - SuperUser's VMs"
#	$CollID = "XX100176"
#	$File = "E:\Packages\Powershell_Scripts\applist.txt"


#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path

C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:


$File = Get-Content ("$CurrentDirectory\!Deploy_Application_to_SCCM_Collection_PCList.txt")
ForEach ($item in $File)
{
     $AppName = $Item.Split(',')[0]
    $CollName = $Item.Split(',')[1]
      $CollID = $Item.Split(',')[2]
       $ADate = $Item.Split(',')[3]
       $ATime = $Item.Split(',')[4]
       $DDate = $Item.Split(',')[5]

    	$DAction = "Install"
    	$Comm = "Deployment from POWERSHELL of $AppName to $CollName"
    
    $DeploymentHash = @{
                        CollectionName = $CollName
                        Name = $AppName
                        AppRequiresApproval = $False
                        AvaliableDate = $ADate
                        AvaliableTime = $ATime
                        Comment = $Comm
                        DeadlineDateTime = [DateTime]$DDate
                        DeployAction = $DAction
                        DeployPurpose = "Required"
                        EnableMomAlert = $False
                        FailParameterValue = "99"
                        OverrideServiceWindow = $False
                        PersistOnWriteFilterDevice = $False
                        PreDeploy = $True
                        RaiseMomAlertsOnFailure = $False
                        RebootOutsideServiceWindow = $False
                        SendWakeUpPacket = $True
                        SuccessParameterValue = "90"
                        TimeBaseOn = "LocalTime"
                        UseMeteredNetwork = $True
                        UserNotification = "HideAll"
                        }
    Write-Output Comment - $Comm
    Start-CMApplicationDeployment @DeploymentHash
    
}



<#

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

#>
