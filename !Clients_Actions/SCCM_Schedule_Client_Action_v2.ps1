#========================================================================
}
    List                     {ListIDs}
#========================================================================
# Created with: SAPIEN Technologies, Inc., PrimalForms 2011 v2.0.14
# Created on:   05.12.2011 18:31
# Created by:   Lars Vegar Halvorsen
# Organization: EDB ErgoGroup
# Filename:     TriggerSCCMClientAction.ps1
#========================================================================
param ($trigger)

## Defining action ID's
$HWInventory = "{00000000-0000-0000-0000-000000000001}"
$SWInventory = "{00000000-0000-0000-0000-000000000002}"
$DiscoveryDataRecord = "{00000000-0000-0000-0000-000000000003}"
$MachinePolicyRetrievalEvaluation = "{00000000-0000-0000-0000-000000000021}"
$FileCollection = "{00000000-0000-0000-0000-000000000010}"
$SWMeteringUsageReport = "{00000000-0000-0000-0000-000000000022}"
$WindowsInstallerSourceList = "{00000000-0000-0000-0000-000000000032}"
$SoftwareUpdatesScan = "{00000000-0000-0000-0000-000000000113}"
$SoftwareUpdatesStore = "{00000000-0000-0000-0000-000000000114}"
$SoftwareUpdatesDeployment = "{00000000-0000-0000-0000-000000000108}"

$ListIDs = "List"

function ListIDs ()
{
    get-wmiobject CCM_Scheduler_ScheduledMessage -namespace root\ccm\policy\machine\actualconfig | select-object ScheduledMessageID, TargetEndPoint | where-object {$_.TargetEndPoint -ne "direct:execmgr"}
}

## Connect to WMI
$Computer = gwmi Win32_ComputerSystem
$SMSClient = [wmiclass] ("\\"+$Computer.Name+"\ROOT\ccm:SMS_Client")

## Using trigger method to initiate action
switch ($trigger)
{
    HW                      {$SMSClient.TriggerSchedule($HWInventory)}
    SW                       {$SMSClient.TriggerSchedule($SWInventory)}
    Disc                     {$SMSClient.TriggerSchedule($DiscoveryDataRecord)}
    Machinepolicy     {$SMSClient.TriggerSchedule($MachinePolicyRetrievalEvaluation)}
    FileCol                 {$SMSClient.TriggerSchedule($FileCollection)}
    SWMeter             {$SMSClient.TriggerSchedule($SWMeteringUsageReport)}
    SourceList           {$SMSClient.TriggerSchedule($WindowsInstallerSourceList)}
    Scan                     {$SMSClient.TriggerSchedule($SoftwareUpdatesScan)}
    Store                    {$SMSClient.TriggerSchedule($SoftwareUpdatesStore)}
    Deployment        {$SMSClient.TriggerSchedule($SoftwareUpdatesDeployment)}
    List                     {ListIDs}
}
