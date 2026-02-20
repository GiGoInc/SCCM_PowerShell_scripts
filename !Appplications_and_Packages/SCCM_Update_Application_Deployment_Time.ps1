cls
}

cls
C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
## Connect to ConfigMgr Site 
Set-Location XX1:
CD XX1:
############################################################
############################################################
  
$AppInfo = 
'Dell BIOS Latitude_5500_1.25.0;Pilot - Dell BIOS Latitude 5500 1.25.0', 
'Dell BIOS Latitude_5510_1.23.1;Pilot - Dell BIOS Latitude 5510 1.23.0', 
'Dell BIOS Latitude_5520 - 1.32.1;Pilot - Dell BIOS Latitude 5520 1.32.1', 
'Dell BIOS Latitude_5530_1.18.0;Pilot - Dell BIOS Latitude 5530 1.18.0', 
'Dell BIOS Latitude_5540_1.9.0;Pilot - Dell BIOS Latitude 5540 1.9.0', 
'Dell BIOS Latitude_5580_1.32.2;Pilot - Dell BIOS Latitude 5580 1.32.2', 
'Dell BIOS Latitude_7420 1.30.1;Pilot - Dell BIOS Latitude 7420 1.30.0', 
'Dell BIOS Latitude_7430_1.18.0;Pilot - Dell BIOS Latitude 7430 1.18.0', 
'Dell BIOS Optiplex_7000_1.18.1;Pilot - Dell BIOS Optiplex 7000 1.18.1', 
'Dell BIOS Optiplex_7040 _1.24.0;Pilot - Dell BIOS Optiplex 7040 1.24.0', 
'Dell BIOS Optiplex_7050_1.24.0;Pilot - Dell BIOS Optiplex 7050 1.24.0', 
'Dell BIOS Optiplex_7070 - 1.22.0;Pilot - Dell BIOS Optiplex 7070 1.22.0', 
'Dell BIOS Optiplex_7090 1.19.0;Pilot - Dell BIOS Optiplex 7090 1.19.0', 
'Dell BIOS Precision 7740_1.29.0;Pilot - Dell BIOS Precision 7740 1.27.0'


ForEach ($Item in $AppInfo)
{
       $AppName = $item.split(';')[0]
    $Collection = $item.split(';')[1]
        
    "Setting: $AppName...."
    $AppDeployTime = $(Get-Date).Date + '18:00:00'
    $NewScheduleDeadline = New-CMSchedule -Start $AppDeployTime -Nonrecurring
    Set-CMApplicationDeployment -ApplicationName $AppName -CollectionName $Collection -DeadlineDateTime $AppDeployTime


}
