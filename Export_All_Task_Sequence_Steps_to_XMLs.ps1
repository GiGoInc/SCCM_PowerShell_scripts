cls
#################################################################
# . GoGo_SCCM_Module.ps1
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:
#################################################################
$TSInfo = Get-CMTaskSequence | select name,PackageID
<#
    name                                               PackageID
    ----                                               ---------
    Gold Image for Dells - SAM - 32-bit * KEEP FOR REF SS100095 
    OBIEE - Test                                       SS1000E2 
    OBIEE - DEV                                        SS1000E3 
    OBIEE - Production                                 SS1000E4 
    EPM-Hyperion - Dev                                 SS1000E5 
    EPM-Hyperion - Test                                SS1000E6 
    EPM-Hyperion - Production                          SS1000E7 
    Gold Image for Dells - SAM - 64-bit * KEEP FOR REF SS100197 
    DELL OSD V1 *Do not delete*                        SS1001D4 
    COM - Operating System Deployment v8.2             SS100323 
    COM - Operating System Deployment v8.4             SS10035B 
    COM - Operating System Deployment v8.5             SS100363 
    COM - Operating System Deployment v8.6             SS1003A7 
    COM - Operating System Deployment v8.7.1           SS1003EB 
    Windows 10 - MDT Newline                           SS100404 
    COM - Operating System Deployment v8.7.2           SS100419 
    COM - Operating System Deployment v8.7.3.1         SS100431 
    RentSys - Test                                     SS10044B 
    CORP - Operating System Deployment v8.7.4.4.2       SS1004CF 
    Install Office 2016 (32-bit)   [Remove existing]   SS1004E6 
    Office 2013 Only                                   SS1004F6 
    Upgrade to Windows 10 v1803                        SS10052C 
    Backup USMT                                        SS10056B 
    Install BIOS Update                                SS10057C 
    Windows 10 - 1803 - 09132018 Wes                   SS10059C 
    C - Test                                     SS1005A6 
    Office 2013 64bit Only                             SS1005B0 
    CORP - Operating System Deployment v8.7.4.5         SS1005B2 
    Department Applications - Mortgage                 SS1005BB 
    Windows 10 Base Applications                       SS1005BC 
    Format Drive                                       SS1005BD 
    Branch Machines                                    SS1005C5 
    Windows 10 - 1803 - HW Build 8.00                  SS1005CF 
    Windows 10 - 1803 - TEST TEST TEST                 SS1005D0 
    Windows 10 All Base Applications                   SS1005D4 
    CORP - Operating System Deployment v8.7.4.4.2- NOAP SS1005D5 
    HW - Windows 7 - OSD v8.7.4.5                      SS1005D7 
    Office 2016 - 64bit                                SS1005D8 
    Office 2016 - 32bit                                SS1005D9 
    Windows 10 - 1803 - HW Build 9.00                  SS1005DC 
    Windows 10 - 1803 - OS ONLY - TEST TEST            SS1005DF 
    ***DO NOT USE*** Windows 10 - 1703 - HW Build      SS1005E0 
    ***DO NOT USE*** Windows 10 - 1709 - HW Build      SS1005E1 
    Windows 10 - IT Tools                              SS1005E2 
    ***DO NOT USE*** Upgrade to Windows 10 v1809       SS1005E3 
    Windows 10 - 1803 - HW Build 10.00                 SS1005E7 
    CORP - Operating System Deployment v8.7.4.4.3       SS1005EC 
    Windows 10 - 1803 -  for Microsoft based off 9.00  SS1005EF 
#>
CD D:
$SiteServer = "sccm1"
$SiteCode = "SS1"

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