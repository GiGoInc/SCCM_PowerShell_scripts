# // Kudos
(Get-Content $File) | ForEach-Object {Invoke-Command -ScriptBlock ${function:ReadLines} -ArgumentList $_}
}
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
$ADVID = "XX120525"



cd 'D:\Powershell\!SCCM_PS_scripts\!Clients_Actions'                              # // Change directory to script dir
$File = ".\SCCM_rerun_sccm_advertisement_on_client--PCList.txt"                   # // Computername on which the magic takes place ( . is the local computer)

Function ReadLines ($Computer)
{
    $CurrentRepeatRunBehaviour = ""                                               # // Variable to store your current repeat run behaviour (mostly RerunIfFail)

    # // Should check if the computer is already online or not.
    # // Query the CCM_Softwaredistribution class to set the ADV_RepeatRunBehavior. This variable defines, when your advertisement has to rerun
    # // Mostly, this key has the value "RerunIfFail"
    # Try-Catch block starts
    $ErrorActionPreference = 'Stop'
    Try{ 
        $Advertisement = Get-WmiObject -query "SELECT * FROM CCM_Softwaredistribution WHERE ADV_AdvertisementID LIKE '$($ADVID)' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $Computer -Authentication PacketPrivacy -Impersonation Impersonate 
            # -> if returnvalue.length == 1
        # // Store your current ADV_RepeatRunBehavior value
        $CurrentRepeatRunBehaviour = $Advertisement.ADV_RepeatRunBehavior             # // Set the ADV_RepeatRunBehavior to RerunAlways. We set this back to its previous value after triggering the SCCM_Client to rerun your advertisement
                                                                                      
        $Advertisement.ADV_RepeatRunBehavior = "RerunAlways"                          
        $Advertisement.put()                                                          # // Commit your changes
 
        # // Get the ScheduledMessageID. You need this ID to trigger the scheduler to process your advertisement to rerun
        $ScheduledMessageID = (Get-WmiObject -query "SELECT ScheduledMessageID FROM CCM_Scheduler_ScheduledMessage WHERE ScheduledMessageID LIKE '$($ADVID)-%' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $Computer -Authentication PacketPrivacy -Impersonation Impersonate).ScheduledMessageID
        # -> if != ""
 

        $SMSClient = [WmiClass]"\\$($Computer)\ROOT\ccm:SMS_Client"                  # // Get Root Namespace of your SMS_Client for triggering the rerun   
        $ParameterList = $SMSClient.psbase.GetMethodParameters("TriggerSchedule")    # // Get the ParameterList from the TriggerSchedule method
        $ParameterList.sScheduleID = $ScheduledMessageID                             # // Set sScheduleID to your previously determined ScheduledMessageID    
        $SMSClient.psbase.InvokeMethod("TriggerSchedule",$ParameterList,$NULL)       # // Invoke the TriggerSchedule WMI Method and commit your ParameterList (which only contains your ScheduledMessageID)
        Start-Sleep -Seconds 3                                                       # // After triggering the TriggerSchedule your advertisement will rerun immediately, but lets wait a sec or two
 
        # // Reset the ADV_RepeatRunBehaviour field of CCM_Softwaredistribution, so no undesired advertise will rerun
        # // Query your CCM_Softwaredistribution
        $Advertisement = get-wmiobject -query "SELECT * FROM CCM_Softwaredistribution WHERE ADV_AdvertisementID LIKE '$($ADVID)' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $Computer -Authentication PacketPrivacy -Impersonation Impersonate
   
        $Advertisement.ADV_RepeatRunBehavior = $CurrentRepeatRunBehaviour            # // Set the ADV_RepeatRunBehavior to the previous value
        $Advertisement.put()                                                         # // Commit changes 
                                                                                     # // YAY, we are done!
                                                                                     # // Party!
                                                                                     # //    
    }
    Catch [System.Exception]
    {
        $oops = [string]($Oops = $error[0] -split "`r`n")[0]
        $Computer + $Oops
    }
    Finally { $ErrorActionPreference = "Continue" }


}
(Get-Content $File) | ForEach-Object {Invoke-Command -ScriptBlock ${function:ReadLines} -ArgumentList $_}
