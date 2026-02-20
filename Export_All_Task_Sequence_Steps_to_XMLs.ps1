cls
#>
Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "SetSequence" -ArgumentList @($TaskSequenceResult.TaskSequence, $TaskSequencePackage)
cls
#################################################################
# . GoGo_SCCM_Module.ps1
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:
#################################################################
$TSInfo = Get-CMTaskSequence | select name,PackageID
<#
    name                                               PackageID
    ----                                               ---------
    Gold Image for Dells - SAM - 32-bit * KEEP FOR REF XX100095 
    OBIEE - Test                                       XX1000E2 
    OBIEE - DEV                                        XX1000E3 
    OBIEE - Production                                 XX1000E4 
    EPM-Hyperion - Dev                                 XX1000E5 
    EPM-Hyperion - Test                                XX1000E6 
    EPM-Hyperion - Production                          XX1000E7 
    Gold Image for Dells - SAM - 64-bit * KEEP FOR REF XX100197 
    DELL OSD V1 *Do not delete*                        XX1001D4 
    COM - Operating System Deployment v8.2             XX100323 
    COM - Operating System Deployment v8.4             XX10035B 
    COM - Operating System Deployment v8.5             XX100363 
    COM - Operating System Deployment v8.6             XX1003A7 
    COM - Operating System Deployment v8.7.1           XX1003EB 
    Windows 10 - MDT Newline                           XX100404 
    COM - Operating System Deployment v8.7.2           XX100419 
    COM - Operating System Deployment v8.7.3.1         XX100431 
    RentSys - Test                                     XX10044B 
    HWC - Operating System Deployment v8.7.4.4.2       XX1004CF 
    Install Office 2016 (32-bit)   [Remove existing]   XX1004E6 
    Office 2013 Only                                   XX1004F6 
    Upgrade to Windows 10 v1803                        XX10052C 
    Backup USMT                                        XX10056B 
    Install BIOS Update                                XX10057C 
    Windows 10 - 1803 - 09132018 Wes                   XX10059C 
    Clayton - Test                                     XX1005A6 
    Office 2013 64bit Only                             XX1005B0 
    HWC - Operating System Deployment v8.7.4.5         XX1005B2 
    Department Applications - Mortgage                 XX1005BB 
    Windows 10 Base Applications                       XX1005BC 
    Format Drive                                       XX1005BD 
    RemoteLocale Machines                                    XX1005C5 
    Windows 10 - 1803 - HW Build 8.00                  XX1005CF 
    Windows 10 - 1803 - TEST TEST TEST                 XX1005D0 
    Windows 10 All Base Applications                   XX1005D4 
    HWC - Operating System Deployment v8.7.4.4.2- NOAP XX1005D5 
    HW - Windows 7 - OSD v8.7.4.5                      XX1005D7 
    Office 2016 - 64bit                                XX1005D8 
    Office 2016 - 32bit                                XX1005D9 
    Windows 10 - 1803 - HW Build 9.00                  XX1005DC 
    Windows 10 - 1803 - OS ONLY - TEST TEST            XX1005DF 
    ***DO NOT USE*** Windows 10 - 1703 - HW Build      XX1005E0 
    ***DO NOT USE*** Windows 10 - 1709 - HW Build      XX1005E1 
    Windows 10 - IT Tools                              XX1005E2 
    ***DO NOT USE*** Upgrade to Windows 10 v1809       XX1005E3 
    Windows 10 - 1803 - HW Build 10.00                 XX1005E7 
    HWC - Operating System Deployment v8.7.4.4.3       XX1005EC 
    Windows 10 - 1803 -  for Microsoft based off 9.00  XX1005EF 
#>
CD D:
$SiteServer = "SERVER"
$SiteCode = "XX1"

ForEach ($TS in $TSInfo)
{
    $PackageID = $TS.packageid
    $PackageID
    # Get SMS_TaskSequencePackage WMI object
    $TaskSequencePackage = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Filter "PackageID like '$PackageID'"
    $TaskSequencePackage.Get()
     
    # Get SMS_TaskSequence WMI object from TaskSequencePackage
    $TaskSequence = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "GetSequence" -ArgumentList $TaskSequencePackage
     
    # Convert WMI object to XML
    $TaskSequenceResult = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequence -ComputerName $SiteServer -Name "SaveToXml" -ArgumentList $TaskSequence.TaskSequence
    $TaskSequenceXML = $TaskSequenceResult.ReturnValue
     
    $TaskSequenceXML | Set-Content "D:\Projects\SCCM_Stuff\Task_Sequences_Exported\$PackageID.xml"
 }
<#
# Amend variable for Apply Operating System step with new PackageID
$ApplyOperatingSystemVariableNode = Select-Xml -Xml $TaskSequenceXML -XPath "//variable[contains(@name,'ImagePackageID')]"
$ApplyOperatingSystemVariableNode.Node.'#text' = $ApplyOperatingSystemVariableNode.Node.'#text' -replace "[A-Z0-9]{3}[A-F0-9]{5}", "P0100011"
 
# Amend command line for Apply Operating System step with new PackageID
$ApplyOperatingSystemCommandLineNode = Select-Xml -Xml $TaskSequenceXML -XPath "//step[contains(@name,'Apply Operating System')]"
$ApplyOperatingSystemCommandLineNode.Node.action = $ApplyOperatingSystemCommandLineNode.Node.action -replace "[A-Z0-9]{3}[A-F0-9]{5}", "P0100011"
 
# Convert XML back to SMS_TaskSequencePackage WMI object
$TaskSequenceResult = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "ImportSequence" -ArgumentList $TaskSequenceXML.OuterXml
 
# Update SMS_TaskSequencePackage WMI object
Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "SetSequence" -ArgumentList @($TaskSequenceResult.TaskSequence, $TaskSequencePackage)
#>
