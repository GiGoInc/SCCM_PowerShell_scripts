cls


cls
##############################
# Add Required Type Libraries
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
############################

C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:

##############################

$Packages = '.Net Framework 4.7.2 for Task Sequence',
'8021x Image Script',
'Adobe Acrobat 10 and 11 Removal',
'Appx Removal',
'Bomgar Jump Client Install',
'Channel United Device Manager',
'Clean OSD Cache',
'DSS Trips 2019 Backout',
'Dell Dynamic Driver Injection',
'Dell Dynamic Patch Injection',
'Dell OSD - MDT 2013',
'Dell OSD - Settings Package',
'EVault Outlook Regedit',
'APPLICATION01 F5 Config',
'APPLICATION01 Regasm',
'APPLICATION01 APP2 Savings Bond Update',
'APPLICATION01ClearMDB',
'Enterprise Vault Discovery Accelerator',
'FIS Certs for Trust',
'Final Actions',
'Flexterm Training Fix',
'HW - Templates for Office',
'Image 8021x test',
'ImageCheck',
'Import Custom Drivers',
'Intel Management Engine Components Installer PVT7D_WIN64_2302.4.5.0_A10',
'Intel SCS Discovery',
'Internet Explorer - VGX.dll Unregister',
'MTS Deployment Summary',
'Network Adapter - Disable sleep',
'OSDPC',
'Office 2010 - updated MSP',
'Onevinn Windows 10 Upgrade Tools v2.3.18326.1',
'PowerPivot Fix for x64 OS',
'PromptForPassword',
'QC Excel plugin and Sprinter uninstaller',
'QMM Disable',
'RETIRED - Win10 Driver - Dell Optiplex 7010 -- A01',
'RETIRED - Win10 Driver - Dell Optiplex 7070 -- A00',
'Remove ISA1 Regkey',
'RemoveSS',
'Rename Computer',
'SCOM 2007 Agent Removal',
'SMB 1 Patch for Server 2003 SP2 x86',
'Send Email',
'SetupDiag 1.4.0.0',
'Start Menu Configuration',
'TSGUI_x64',
'APP2H',
'Tlr4Win.exe Update - 07/15/2019',
'Training ReCopy Config file',
'Training APP2',
'TrustDesk Update - 2019-02-15',
'TrustDesk Update',
'USMT',
'USMT.McAfee',
'Ugreen USB to Serial Adapter for Windows 10',
'UnProvision Intel AMT and LMS',
'Uninstall DLP Again',
'Uninstall KB3203467',
'Uninstall Old Bridger Insight',
'Uninstall Outlook Patch',
'User State Migration Tool for Windows',
'VMware vmnext',
'Visual C PlusPlus for New Install',
'WINPE 10.0 Driver -- A15',
'Win10UpgradeScripts',
'Windows 10 - Custom Upgrade SplashScreen',
'Windows 10 - Default App Associations',
'Windows 10 - MDT Settings - 8450',
'Windows 10 - OSD Profiles',
'Windows 10 - Office Scrub',
'Windows 10 - SMB1',
'Windows 10 - USMT',
'Windows 10 - Upgrade Emails',
'Windows 10 APPLICATION01ClearMDB',
'Windows 10 MDT Settings Package R02',
'Windows 10 MDT Settings Package',
'Windows 10 MDT Toolkit Files Package - TEST',
'Windows 7 - Lockscreen and Wallpaper',
'Windows Update Agent - x64 Patches',
'Windows Update Agent - x86 Patches'
#################################################################
#################################################################

$ADate = Get-Date -Format "yyyy_MM-dd"
$i = 1
$total = $Packages.count
ForEach ($Package in $Packages)
{
    $ModName = $Package.Replace('/','-')
    "$i of $total --exporting $Package..."
    Get-CMPackage -Name "$Package" -Fast | Export-CMPackage -Path "D:\Powershell\!SCCM_PS_scripts\SCCM_Exported_Apps_Packages\$ADate--$ModName.zip" -WithContent $False  -Comment "Package export" -Force 
    $i++
}


