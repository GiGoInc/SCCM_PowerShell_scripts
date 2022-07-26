# // Kudos
# // Author: Marco Di Feo
# // Website: http://www.marco-difeo.de
# // Scriptname: rerun_sccm_advertisement_on_client.ps1
# //
# // Usage: This script can be modified to fit your needs
# // Pingback: http://marco-difeo.de/2011/10/13/powershell-sccm-readvertise-a-previously-installed-softwarepackage-remotly/
# //
# // #######################################################################################
# // Declaration
# // #######################################################################################
 
# // Your SCCM advertisementID
$ADVID = "SS1200C9"


# // Computername on which the magic takes place ( . is the local computer)
$File = ".\RemoteComputers.txt"

# ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"

function ReadLines ($Computer)
{
# // #######################################################################################
# // Script start
# // #######################################################################################
#
# // Variable to store your current repeat run behaviour (mostly RerunIfFail)
$CurrentRepeatRunBehaviour = ""
# // Should check if the computer is already online or not.
# // Query the CCM_Softwaredistribution class to set the ADV_RepeatRunBehavior. This variable defines, when your advertisement has to rerun
# // Mostly, this key has the value "RerunIfFail"
$Advertisement = get-wmiobject -query "SELECT * FROM CCM_Softwaredistribution WHERE ADV_AdvertisementID LIKE '$($ADVID)' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $Computer -Authentication PacketPrivacy -Impersonation Impersonate
# -> if returnvalue.length == 1
# // Store your current ADV_RepeatRunBehavior value
$CurrentRepeatRunBehaviour = $Advertisement.ADV_RepeatRunBehavior
# // Set the ADV_RepeatRunBehavior to RerunAlways. We set this back to its previous value after triggering the SCCM_Client to rerun your advertisement
$Advertisement.ADV_RepeatRunBehavior = "RerunAlways"
# // Commit your changes
$Advertisement.put()
 
# // Get the ScheduledMessageID. You need this ID to trigger the scheduler to process your advertisement to rerun
$ScheduledMessageID = (get-wmiobject -query "SELECT ScheduledMessageID FROM CCM_Scheduler_ScheduledMessage WHERE ScheduledMessageID LIKE '$($ADVID)-%' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $Computer -Authentication PacketPrivacy -Impersonation Impersonate).ScheduledMessageID
# -> if != ""
 
# // Get Root Namespace of your SMS_Client for triggering the rerun
$SMSClient = [WmiClass]"\\$($Computer)\ROOT\ccm:SMS_Client"
# // Get the ParameterList from the TriggerSchedule method
$ParameterList = $SMSClient.psbase.GetMethodParameters("TriggerSchedule")
# // Set sScheduleID to your previously determined ScheduledMessageID
$ParameterList.sScheduleID = $ScheduledMessageID
# // Invoke the TriggerSchedule WMI Method and commit your ParameterList (which only contains your ScheduledMessageID)
$SMSClient.psbase.InvokeMethod("TriggerSchedule",$ParameterList,$NULL)
 
# // After triggering the TriggerSchedule your advertisement will rerun immediately, but lets wait a sec or two
sleep 3
 
# // Reset the ADV_RepeatRunBehaviour field of CCM_Softwaredistribution, so no undesired advertise will rerun
# // Query your CCM_Softwaredistribution
$Advertisement = get-wmiobject -query "SELECT * FROM CCM_Softwaredistribution WHERE ADV_AdvertisementID LIKE '$($ADVID)' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $Computer -Authentication PacketPrivacy -Impersonation Impersonate
# // Set the ADV_RepeatRunBehavior to the previous value
$Advertisement.ADV_RepeatRunBehavior = $CurrentRepeatRunBehaviour
# // Commit changes
$Advertisement.put()
# // YAY, we are done!
# // Party!
# //

}
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:ReadLines} -ArgumentList $_}