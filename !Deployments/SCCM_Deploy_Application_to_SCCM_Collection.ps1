$SiteCode = "XX1"
#>

$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"
$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer }
Set-Location "$($SiteCode):"
######################################################################################################
######################################################################################################

$Collections = 'WORKSTATION - GROUP 01;CISCO IRONPORT ENCRYPTION PLUGIN', `
               'WORKSTATION - GROUP 02;CISCO IRONPORT ENCRYPTION PLUGIN', `
               'WORKSTATION - GROUP 03;CISCO IRONPORT ENCRYPTION PLUGIN', `
               'WORKSTATION - GROUP 04;CISCO IRONPORT ENCRYPTION PLUGIN', `
               'WORKSTATION - GROUP 05;CISCO IRONPORT ENCRYPTION PLUGIN', `
               'WORKSTATION - GROUP 06;CISCO IRONPORT ENCRYPTION PLUGIN'

ForEach ($Coll in $Collections)
{
    $CollName = $Coll.Split(';')[0]
     $AppName = $Coll.Split(';')[1]
	   $ADate = Get-Date -UFormat "%Y/%m/%d %R"
        If ($CollName -eq 'Workstation - Group 01'){$CollID = 'XX101653'}
        If ($CollName -eq 'Workstation - Group 02'){$CollID = 'XX101654'}
        If ($CollName -eq 'Workstation - Group 03'){$CollID = 'XX101655'}
        If ($CollName -eq 'Workstation - Group 04'){$CollID = 'XX101656'}
        If ($CollName -eq 'Workstation - Group 05'){$CollID = 'XX101657'}
        If ($CollName -eq 'Workstation - Group 06'){$CollID = 'XX101658'}
        $DDate = $null
        If ($CollName -eq 'Workstation - Group 01'){$DDate = '07/23/2024 20:00'}
        If ($CollName -eq 'Workstation - Group 02'){$DDate = '07/24/2024 20:00'}
        If ($CollName -eq 'Workstation - Group 03'){$DDate = '07/25/2024 20:00'}
        If ($CollName -eq 'Workstation - Group 04'){$DDate = '07/29/2024 20:00'}
        If ($CollName -eq 'Workstation - Group 05'){$DDate = '07/30/2024 20:00'}
        If ($CollName -eq 'Workstation - Group 06'){$DDate = '07/31/2024 20:00'}
    	
    
    $DAction = "Uninstall"
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
