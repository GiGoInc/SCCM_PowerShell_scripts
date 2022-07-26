# PC = 5JNNM12 or blnnm12
# ADVID = SS100310
# Advertisement Name = Optiplex E5540 - NIC update


<#

\\77VPK32\c$\Windows\System32\drivers
\\16ZQL32\c$\Windows\System32\drivers
\\15QNM12\c$\Windows\System32\drivers
\\5JNNM12\c$\Windows\System32\drivers
\\2PPXK32\c$\Windows\System32\drivers


\c$\Windows\System32\drivers\e1d62x64.sys


Modified date:	9/5/2013 8:54am
version:		12.6.51.9427

Modified date:	9/14/2014 7:12pm
version:		12.12.50.7205


Modified date:	9/5/2015 11:09pm
version:		12.13.17.4
#>


[CmdletBinding()]
param(
    # Support for multiple computers from the pipeline
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in computer name and press Enter to execute')]
    [string]$PC,
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Put in the AdvertisementID and press Enter to execute')]
    [string]$ADVID
    )

# Reset CCMEXEC service
    (Get-WmiObject Win32_Service -filter "name='CcmExec'" -ComputerName $PC).StopService()
        Start-Sleep -Seconds 5
    (Get-WmiObject Win32_Service -filter "name='CcmExec'" -ComputerName $PC).StartService()
        Start-Sleep -Seconds 5
    Get-Service -Name CcmExec -ComputerName $PC

# Run Advertisement
    $CurrentRepeatRunBehaviour = ""
    $Advertisement = get-wmiobject -query "SELECT * FROM CCM_Softwaredistribution WHERE ADV_AdvertisementID LIKE '$($ADVID)' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $PC -Authentication PacketPrivacy -Impersonation Impersonate
    $CurrentRepeatRunBehaviour = $Advertisement.ADV_RepeatRunBehavior
    $Advertisement.ADV_RepeatRunBehavior = "RerunAlways"
    $Advertisement.put()
     
    $ScheduledMessageID = (get-wmiobject -query "SELECT ScheduledMessageID FROM CCM_Scheduler_ScheduledMessage WHERE ScheduledMessageID LIKE '$($ADVID)-%' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $PC -Authentication PacketPrivacy -Impersonation Impersonate).ScheduledMessageID
    
    $SMSClient = [WmiClass]"\\$($PC)\ROOT\ccm:SMS_Client"
    $ParameterList = $SMSClient.psbase.GetMethodParameters("TriggerSchedule")
    $ParameterList.sScheduleID = $ScheduledMessageID
    $SMSClient.psbase.InvokeMethod("TriggerSchedule",$ParameterList,$NULL)
    sleep 3
     
    $Advertisement = get-wmiobject -query "SELECT * FROM CCM_Softwaredistribution WHERE ADV_AdvertisementID LIKE '$($ADVID)' " -namespace "root\CCM\Policy\Machine\ActualConfig" -Computer $PC -Authentication PacketPrivacy -Impersonation Impersonate
    $Advertisement.ADV_RepeatRunBehavior = $CurrentRepeatRunBehaviour
    $Advertisement.put()
 
    Start-Process -FilePath C:\Windows\SysWOW64\cmtrace.exe -ArgumentList """\\$PC\c$\Windows\CCM\Logs\CAS.log"" ""\\$PC\c$\Windows\CCM\Logs\AppDiscovery.log"" ""\\$PC\c$\Windows\CCM\Logs\Ccm32BitLauncher.log"" ""\\$PC\c$\Windows\CCM\Logs\execmgr.log"""


<#
    Set-Service -Name PeerDistSvc -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name smstsmgr -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name CmRcService -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name RpcSs -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name RemoteRegistry -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name LanmanServer -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name CcmExec -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name Winmgmt -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name WinRM -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name wuauserv -ComputerName $PC -StartupType Automatic -Status Running
    Set-Service -Name LanmanWorkstation -ComputerName $PC -StartupType Automatic -Status Running
    
    Get-Service -Name PeerDistSvc -ComputerName $PC
    Get-Service -Name smstsmgr -ComputerName $PC
    Get-Service -Name CmRcService -ComputerName $PC
    Get-Service -Name RpcSs -ComputerName $PC
    Get-Service -Name RemoteRegistry -ComputerName $PC
    Get-Service -Name LanmanServer -ComputerName $PC
    Get-Service -Name CcmExec -ComputerName $PC
    Get-Service -Name Winmgmt -ComputerName $PC
    Get-Service -Name WinRM -ComputerName $PC
    Get-Service -Name wuauserv -ComputerName $PC
    Get-Service -Name LanmanWorkstation -ComputerName $PC
#>