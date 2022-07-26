#	$CollName = "Test - Isaac's VMs"
#	$CollID = "SS100176"
#	$File = "E:\Packages\Powershell_Scripts\applist.txt"

# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location SS1:
    CD SS1:


 $File = Get-Content "D:\Powershell\!SCCM_PS_scripts\!Collections\SCCM_Add_Direct_PC_Membership_to_Device_Collection--PCList.txt"
      $ResourceIDs = "D:\Powershell\!SCCM_PS_scripts\!Collections\SCCM_Add_Direct_PC_Membership_to_Device_Collection--ResourceList.txt"
"" | Set-Content $ResourceIDs


# $ADateS = Get-Date
# Write-Host "Getting ResourceID from PC Names...will take a few minutes based on number of PC Names"
#     ForEach ($item in $File)
#     {
#         $CollID = $Item.Split(';')[0]
#         $PCName = $Item.Split(';')[1]
#         $RES = Get-CMDevice -Name $PCName | Select $_.ResourceID
#         $ResourceID = $RES.ResourceID
#     
#         "$CollID;$ResourceID" | Add-Content $ResourceIDs
#     }
# Write-Host "Done..."
# # FINALLY - Write Time
#     $ADateE = Get-Date
#     $t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
#     $min = $t.Minutes
#     $sec = $t.seconds
#     Write-Host "`nScript ran: $min minutes and $sec seconds." -ForegroundColor Cyan
# #################################################################################################################################

# $File2 = Get-Content $ResourceIDs

$ADateS = Get-Date
Write-Host "Adding ResourceIDs to Collections via Direct Membership...will take a few minutes based on number of PC Names"
    ForEach ($item in $File)
    {
        $CollID = $Item.Split(';')[0]
        $ResourceID = $Item.Split(';')[1]

        If (($CollID -ne $null) -and ($ResourceID -ne $Null))
        {
            $DeploymentHash = @{
                                CollectionId = $CollID
                                ResourceID = $(Get-CMDevice -Name $Computer).ResourceID
                                }    
            Add-CMDeviceCollectionDirectMembershipRule @DeploymentHash
        }
    }
Write-Host "Done..."
# FINALLY - Write Time
    $ADateE = Get-Date
    $t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
    $min = $t.Minutes
    $sec = $t.seconds
    Write-Host "`nScript ran: $min minutes and $sec seconds." -ForegroundColor Cyan


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