<#    
    }
        If (($TS.Date -le '0') -and ($TS.Hours -le '0')){Add-CMDeviceCollectionIncludeMembershipRule -CollectionId XX100870 -IncludeCollectionId $CollID}
<#    
        Rename this script to reflect Deployment Collection and place on SERVER E:\Scripts
        For Example: Deployments_PhishMe.ps1

      Collection Name: PhishMe - Current Deployment
        Collection ID: XX100870

    Deployment runs from 03/28 to 04/11
#>
$ErrorActionPreference = 'SilentlyContinue'

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:


$Collections = 'XX10080C;Workstations - RemoteLocale;03/28/2017 18:00', `
               'XX1007C2;Workstations - Non-RemoteLocale - Group 01;03/28/2017 18:00', `
               'XX1007C3;Workstations - Non-RemoteLocale - Group 02;03/28/2017 18:00', `
               'XX1007C4;Workstations - Non-RemoteLocale - Group 03;03/28/2017 18:00', `
               'XX1007C5;Workstations - Non-RemoteLocale - Group 04;03/29/2017 18:00', `
               'XX1007C6;Workstations - Non-RemoteLocale - Group 05;03/29/2017 18:00', `
               'XX1007C7;Workstations - Non-RemoteLocale - Group 06;03/29/2017 18:00', `
               'XX1007C8;Workstations - Non-RemoteLocale - Group 07;03/30/2017 18:00', `
               'XX1007C9;Workstations - Non-RemoteLocale - Group 08;03/30/2017 18:00', `
               'XX1007CA;Workstations - Non-RemoteLocale - Group 09;03/30/2017 18:00', `
               'XX1007CB;Workstations - Non-RemoteLocale - Group 10;04/03/2017 18:00', `
               'XX1007CC;Workstations - Non-RemoteLocale - Group 11;04/03/2017 18:00', `
               'XX1007CD;Workstations - Non-RemoteLocale - Group 12;04/03/2017 18:00', `
               'XX1007CE;Workstations - Non-RemoteLocale - Group 13;04/04/2017 18:00', `
               'XX1007CF;Workstations - Non-RemoteLocale - Group 14;04/04/2017 18:00', `
               'XX1007D0;Workstations - Non-RemoteLocale - Group 15;04/04/2017 18:00', `
               'XX1007D1;Workstations - Non-RemoteLocale - Group 16;04/05/2017 18:00', `
               'XX1007D2;Workstations - Non-RemoteLocale - Group 17;04/05/2017 18:00', `
               'XX1007D3;Workstations - Non-RemoteLocale - Group 18;04/05/2017 18:00', `
               'XX1007D4;Workstations - Non-RemoteLocale - Group 19;04/06/2017 18:00', `
               'XX1007D5;Workstations - Non-RemoteLocale - Group 20;04/06/2017 18:00', `
               'XX1007D6;Workstations - Non-RemoteLocale - Group 21;04/06/2017 18:00', `
               'XX1007D7;Workstations - Non-RemoteLocale - Group 22;04/10/2017 18:00', `
               'XX1007D8;Workstations - Non-RemoteLocale - Group 23;04/10/2017 18:00', `
               'XX1007D9;Workstations - Non-RemoteLocale - Group 24;04/10/2017 18:00', `
               'XX1007DA;Workstations - Non-RemoteLocale - Group 25;04/11/2017 18:00', `
               'XX1007DB;Workstations - Non-RemoteLocale - Group 26;04/11/2017 18:00', `
               'XX1007DC;Workstations - Non-RemoteLocale - Group 27;04/11/2017 18:00', `
               'XX1007DF;Workstations - Non-RemoteLocale - Not in a Group;04/11/2017 18:00'

$StartDate = (GET-DATE)
    ForEach ($Collection in $Collections)
    {
         $COllID = $Collection.split(';')[0]
           $Name = $Collection.split(';')[1]
           $Time = $Collection.split(';')[2]
        $EndDate = [datetime]$Time
             $TS = NEW-TIMESPAN –Start $StartDate –End $EndDate
        If (($TS.Date -le '0') -and ($TS.Hours -le '0')){Add-CMDeviceCollectionIncludeMembershipRule -CollectionId XX100870 -IncludeCollectionId $CollID}
    }
