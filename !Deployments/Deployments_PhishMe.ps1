<#    
        Rename this script to reflect Deployment Collection and place on SCCMSERVER E:\Scripts
        For Example: Deployments_PhishMe.ps1

      Collection Name: PhishMe - Current Deployment
        Collection ID: SS100870

    Deployment runs from 03/28 to 04/11
#>
$ErrorActionPreference = 'SilentlyContinue'

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:


$Collections = 'SS10080C;Workstations - Branch;03/28/2017 18:00', `
               'SS1007C2;Workstations - Non-Branch - Group 01;03/28/2017 18:00', `
               'SS1007C3;Workstations - Non-Branch - Group 02;03/28/2017 18:00', `
               'SS1007C4;Workstations - Non-Branch - Group 03;03/28/2017 18:00', `
               'SS1007C5;Workstations - Non-Branch - Group 04;03/29/2017 18:00', `
               'SS1007C6;Workstations - Non-Branch - Group 05;03/29/2017 18:00', `
               'SS1007C7;Workstations - Non-Branch - Group 06;03/29/2017 18:00', `
               'SS1007C8;Workstations - Non-Branch - Group 07;03/30/2017 18:00', `
               'SS1007C9;Workstations - Non-Branch - Group 08;03/30/2017 18:00', `
               'SS1007CA;Workstations - Non-Branch - Group 09;03/30/2017 18:00', `
               'SS1007CB;Workstations - Non-Branch - Group 10;04/03/2017 18:00', `
               'SS1007CC;Workstations - Non-Branch - Group 11;04/03/2017 18:00', `
               'SS1007CD;Workstations - Non-Branch - Group 12;04/03/2017 18:00', `
               'SS1007CE;Workstations - Non-Branch - Group 13;04/04/2017 18:00', `
               'SS1007CF;Workstations - Non-Branch - Group 14;04/04/2017 18:00', `
               'SS1007D0;Workstations - Non-Branch - Group 15;04/04/2017 18:00', `
               'SS1007D1;Workstations - Non-Branch - Group 16;04/05/2017 18:00', `
               'SS1007D2;Workstations - Non-Branch - Group 17;04/05/2017 18:00', `
               'SS1007D3;Workstations - Non-Branch - Group 18;04/05/2017 18:00', `
               'SS1007D4;Workstations - Non-Branch - Group 19;04/06/2017 18:00', `
               'SS1007D5;Workstations - Non-Branch - Group 20;04/06/2017 18:00', `
               'SS1007D6;Workstations - Non-Branch - Group 21;04/06/2017 18:00', `
               'SS1007D7;Workstations - Non-Branch - Group 22;04/10/2017 18:00', `
               'SS1007D8;Workstations - Non-Branch - Group 23;04/10/2017 18:00', `
               'SS1007D9;Workstations - Non-Branch - Group 24;04/10/2017 18:00', `
               'SS1007DA;Workstations - Non-Branch - Group 25;04/11/2017 18:00', `
               'SS1007DB;Workstations - Non-Branch - Group 26;04/11/2017 18:00', `
               'SS1007DC;Workstations - Non-Branch - Group 27;04/11/2017 18:00', `
               'SS1007DF;Workstations - Non-Branch - Not in a Group;04/11/2017 18:00'

$StartDate = (GET-DATE)
    ForEach ($Collection in $Collections)
    {
         $COllID = $Collection.split(';')[0]
           $Name = $Collection.split(';')[1]
           $Time = $Collection.split(';')[2]
        $EndDate = [datetime]$Time
             $TS = NEW-TIMESPAN –Start $StartDate –End $EndDate
        If (($TS.Date -le '0') -and ($TS.Hours -le '0')){Add-CMDeviceCollectionIncludeMembershipRule -CollectionId SS100870 -IncludeCollectionId $CollID}
    }
