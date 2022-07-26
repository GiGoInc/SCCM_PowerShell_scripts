<#	
    $CollName = "Test - Isaac's VMs"
    $CollID = "SS100176"
    $File = "E:\Packages\Powershell_Scripts\applist.txt"


    Collection	                CollID	    MemberCount
    INFOSEC - DG01              SS100F57	26
    INFOSEC - DG02              SS100F88	33
    INFOSEC - DG03              SS100F94	42
    INFOSEC - DG04              SS100FB9	92
    INFOSEC - DG05              SS100FC1	96
    INFOSEC - DG06              SS100FC6	117
    INFOSEC - DG07              SS100FCB	167
    INFOSEC - DG08              SS100FD6	395
    INFOSEC - DG09              SS100FD7	494
    INFOSEC - DG10              SS101162	344
    INFOSEC - DG11              SS101163	465
    INFOSEC - DG12              SS101164	490
    INFOSEC - DG13              SS101167	723
    INFOSEC - DG14              SS101165	302
    INFOSEC - DG15              SS101166	1092
    INFOSEC - DG16 - CLEANUP	SS100FFB	289

    'INFOSEC - DG01;SS100F57;Teams;02/13/2022 08:00', `
    'INFOSEC - DG02;SS100F88;Teams;02/13/2022 08:00', `
    'INFOSEC - DG03;SS100F94;Teams;02/13/2022 08:00', `
    'INFOSEC - DG04;SS100FB9;Teams;02/16/2022 20:00', `
    'INFOSEC - DG05;SS100FC1;Teams;02/21/2022 20:00', `
    'INFOSEC - DG06;SS100FC6;Teams;02/22/2022 20:00', `
    'INFOSEC - DG07;SS100FCB;Teams;02/23/2022 20:00', `
    'INFOSEC - DG08;SS100FD6;Teams;02/23/2022 20:00', `
    'INFOSEC - DG09;SS100FD7;Teams;02/28/2022 20:00', `
    'INFOSEC - DG10;SS101162;Teams;02/28/2022 20:00', `
    'INFOSEC - DG11;SS101163;Teams;02/28/2022 20:00', `
    'INFOSEC - DG12;SS101164;Teams;03/02/2022 20:00', `
    'INFOSEC - DG13;SS101167;Teams;03/02/2022 20:00', `
    'INFOSEC - DG14;SS101165;Teams;03/02/2022 20:00', `
    'INFOSEC - DG15;SS101166;Teams;03/02/2022 20:00', `
    'InfoSec - DG16 - Cleanup;SS100FFB;Teams;03/02/2022 20:00'
#>


#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path

C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

# $ItemList = (Collection Name);(Collection ID);(Application Name)

$ItemList = 'InfoSec - DG16 - Cleanup;SS100FFB;Teams;03/02/2022 20:00'


ForEach ($Item in $ItemList)
{
    $CollName = $Item.Split(';')[0]
      $CollID = $Item.Split(';')[1]
     $AppName = $Item.Split(';')[2]
       $DDate = $Item.Split(';')[3]

	   $ADate = Get-Date -UFormat "%Y/%m/%d %R"

    	$DAction = "Instal"
    	$Comm = "Deployment from POWERSHELL of $AppName to $CollName"
    
    $DeploymentHash = @{
                        Name = $AppName
                        AvailableDateTime = [DateTime]$DDate
                        CollectionName = $CollName
                        Comment = $Comm
                        DeadlineDateTime = [DateTime]$DDate
                        DeployAction = $DAction
                        DeployPurpose = 'Required'
					     EnableSoftDeadline = $True 						
                        FailParameterValue = '99'
                        OverrideServiceWindow = $True
                        PersistOnWriteFilterDevice = $False
                        PreDeploy = $True
                        RebootOutsideServiceWindow = $True
                        SendWakeupPacket = $True
                        SuccessParameterValue = '90'
                        TimeBaseOn = 'LocalTime'
						 UseMeteredNetwork = $True
                        UserNotification = 'HideAll'
                        }
    Write-Host "Collection Info - $CollName`t$DDate"
    Write-Host "Comment - $Comm"
    New-CMApplicationDeployment @DeploymentHash | Out-Null

###########################################################################
##  EXCLUDE COLLECTION
###########################################################################

    Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $CollName -ExcludeCollectionName "Teams - Machine-Wide Installer"


###########################################################################
##  SET COLLECTION REFRESH SCHEDULE
###########################################################################

    $Schedule1 = New-CMSchedule -Start (Get-Date) -RecurInterval Days -RecurCount 1
    "Setting $CollName - refrsh schedule"
    Set-CMCollection -Name $CollName -RefreshSchedule $Schedule1 -RefreshType Both

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