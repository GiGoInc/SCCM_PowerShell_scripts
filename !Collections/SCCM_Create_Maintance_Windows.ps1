<#	COMMENTS!!!!

Change all the Maintenace Windows collections to a standard nameing convention like "MaintWindowCollection - (

 all the maintance windows names on the collections to a standard like "Maintance Window"

Get the Maintenance Windows for a list of CollectionIDs
Get-Content "E:\Packages\Powershell_Scripts\MainWindowCollectionIDs.txt" | % {Get-CMMaintenanceWindow -CollectionId $_}
#>

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:
cls



#Modify existing Maintenance Window
$Schedule = New-CMSchedule -DayOfWeek Sunday -DurationCount 6 -DurationInterval Hours -WeekOrder Third -Start "5/16/2014 11:00 PM"
$Collection = Get-CMDeviceCollection -Name "Branch Workstations - 3rd Friday"
Set-CMMaintenanceWindow -CollectionID SS100083 -Schedule $Schedule -Name "3rd Friday"


CD E:


<#	COMMENTS!!!!!

$File = "E:\Packages\Powershell_Scripts\MainWindowCollectionIDs.txt"
function RunFunc ($Lines)
{
	Get-CMMaintenanceWindow -CollectionId SS100083
	Set-CMDeploymentType -ApplicationName $AppName -DeploymentTypeName $PKGName –MsiOrScriptInstaller -MaximumAllowedRunTimeMinutes 30
	Write-Output Set Application $AppName DeploymentType $PKGName
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:



SS1000A0
Description            : Occurs the Third Sunday of every 1 months effective 9/9/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : Alabama Call Center
RecurrenceType         : 4
ServiceWindowID        : {010AB467-B781-45A1-8FB4-56B2ADA1F26A}
ServiceWindowSchedules : 02899ADE48211600
ServiceWindowType      : 1
StartTime              : 9/9/2013 8:00:00 PM

SS100083
Description            : Occurs the Third Sunday of every 1 months effective 5/16/2014 11:00 PM
Duration               : 360
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Friday
RecurrenceType         : 4
ServiceWindowID        : {9D5025D4-C542-47E1-80BF-B9F8656B2B1D}
ServiceWindowSchedules : 02F05B0030211600
ServiceWindowType      : 1
StartTime              : 5/16/2014 11:00:00 PM

Description            : Occurs the Third Saturday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Saturday
RecurrenceType         : 4
ServiceWindowID        : {BDC50188-AC3E-4089-8787-CD29681FA9FB}
ServiceWindowSchedules : 02905B1E48271600
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

SS10007E
Description            : Occurs the Third Monday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Monday
RecurrenceType         : 4
ServiceWindowID        : {5642955E-AF66-48D4-9FA0-E2EC7A504688}
ServiceWindowSchedules : 028E5ADE48221600
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

Description            : Occurs the Third Tuesday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Tuesday
RecurrenceType         : 4
ServiceWindowID        : {F47796FF-15DD-4B82-B86A-AA50E6CC0586}
ServiceWindowSchedules : 02905B1E48231600
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

SS10007C
Description            : Occurs the Third Sunday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Sunday
RecurrenceType         : 4
ServiceWindowID        : {465DBF17-DC35-4CA5-9008-A333EFDA24D2}
ServiceWindowSchedules : 02905B1E48211600
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

Description            : Occurs the Third Saturday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Saturday
RecurrenceType         : 4
ServiceWindowID        : {E5F2E6DB-9A7E-46B5-8E1F-15695216B06A}
ServiceWindowSchedules : 028E5ADE48271600
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

SS10007D
Description            : Occurs the Third Sunday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Sunday
RecurrenceType         : 4
ServiceWindowID        : {C5AB400B-3005-436D-8030-1EBF5D8E436F}
ServiceWindowSchedules : 028E5ADE48211600
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

Description            : Occurs the Third Monday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Monday
RecurrenceType         : 4
ServiceWindowID        : {D553F3DA-647F-4FC2-A95B-3B9E1CB5DF08}
ServiceWindowSchedules : 02905B1E48221600
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

SS100082
Description            : Occurs the Third Thursday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Thursday
RecurrenceType         : 4
ServiceWindowID        : {3226536B-7717-4C1A-B60D-F5677187A581}
ServiceWindowSchedules : 028E5ADE48251600
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

Description            : Occurs the Third Friday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Friday
RecurrenceType         : 4
ServiceWindowID        : {914874CD-A712-4E58-BAB1-0D58EABA965E}
ServiceWindowSchedules : 02905B1E48261600
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

SS100080
Description            : Occurs the Third Wednesday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Wednesday
RecurrenceType         : 4
ServiceWindowID        : {1B1D708A-24FF-407F-AF58-B793B4A14A09}
ServiceWindowSchedules : 02905B1E48241600
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

Description            : Occurs the Third Tuesday of every 1 month(s) effective 5/14/2013 8:00 PM
Duration               : 540
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Tuesday
RecurrenceType         : 4
ServiceWindowID        : {81A4F864-1F65-44A1-84CE-FBF6257F30ED}
ServiceWindowSchedules : 028E5AC048231600
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

SS100081
Description            : Occurs the Third Thursday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Thursday
RecurrenceType         : 4
ServiceWindowID        : {284A11F8-64E9-4354-A567-98D659BD2270}
ServiceWindowSchedules : 02905B1E48251600
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

Description            : Occurs the Third Wednesday of every 1 month(s) effective 5/14/2013 8:00 PM
Duration               : 540
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Wednesday
RecurrenceType         : 4
ServiceWindowID        : {76CBB265-E104-4A42-B671-E674F47EB5EC}
ServiceWindowSchedules : 028E5AC048241600
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

SS100088
Description            : Occurs the Fourth Saturday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Saturday
RecurrenceType         : 4
ServiceWindowID        : {8E1D51B0-B918-416C-A576-BF57A7BEC1E5}
ServiceWindowSchedules : 02905B1E48271800
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

Description            : Occurs the Fourth Friday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Friday
RecurrenceType         : 4
ServiceWindowID        : {ED5BD27E-6940-4727-BD71-3739F85ADC27}
ServiceWindowSchedules : 028E5ADE48261800
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

SS10007F
Description            : Occurs the Fourth Tuesday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Tuesday
RecurrenceType         : 4
ServiceWindowID        : {269B2C63-C04C-4B88-8380-3683869289F3}
ServiceWindowSchedules : 02905B1E48231800
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

Description            : Occurs the Fourth Monday of every 1 months effective 4/22/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Monday
RecurrenceType         : 4
ServiceWindowID        : {810DCA09-D656-4720-AAF1-5E4FD12FDAD0}
ServiceWindowSchedules : 02964ADE48221800
ServiceWindowType      : 1
StartTime              : 4/22/2013 8:00:00 PM

SS100087
Description            : Occurs the Fourth Friday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Friday
RecurrenceType         : 4
ServiceWindowID        : {B18634C1-48DA-426F-BB79-20779D322B88}
ServiceWindowSchedules : 02905B1E48261800
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

Description            : Occurs the Fourth Thursday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Thursday
RecurrenceType         : 4
ServiceWindowID        : {BC73330C-8F0C-4686-9ADB-361D6B341A06}
ServiceWindowSchedules : 028E5ADE48251800
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

SS100085
Description            : Occurs the Fourth Wednesday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Wednesday
RecurrenceType         : 4
ServiceWindowID        : {06B68913-EEF9-44B2-BB10-9E9CC3B8C29C}
ServiceWindowSchedules : 02905B1E48241800
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

Description            : Occurs the Fourth Tuesday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Tuesday
RecurrenceType         : 4
ServiceWindowID        : {7B11CEA7-192.-4EB3-A6B8-D7927ABBD05F}
ServiceWindowSchedules : 028E5ADE48231800
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

SS100086
Description            : Occurs the Fourth Wednesday of every 1 months effective 5/14/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Wednesday
RecurrenceType         : 4
ServiceWindowID        : {87A6A0AD-175B-41C2-8AC0-F36C89C0959E}
ServiceWindowSchedules : 028E5ADE48241800
ServiceWindowType      : 1
StartTime              : 5/14/2013 8:00:00 PM

Description            : Occurs the Fourth Thursday of every 1 months effective 5/16/2014 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Thursday
RecurrenceType         : 4
ServiceWindowID        : {9892DD05-2640-4CFB-8600-0F1D72C846BC}
ServiceWindowSchedules : 02905B1E48251800
ServiceWindowType      : 1
StartTime              : 5/16/2014 8:00:00 PM

SS100174
Description            : Occurs the Fourth Saturday of every 1 months effective 5/21/2014 1:00 PM
Duration               : 990
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Saturday
RecurrenceType         : 4
ServiceWindowID        : {016BA89E-6C71-4957-A9C8-EBA7D20E38EA}
ServiceWindowSchedules : 01B55B1E80271800
ServiceWindowType      : 4
StartTime              : 5/21/2014 1:00:00 PM

Description            : Occurs the Fourth Sunday of every 1 months effective 5/21/2014 12:00 AM
Duration               : 1440
IsEnabled              : True
IsGMT                  : False
Name                   : 4th Sunday
RecurrenceType         : 4
ServiceWindowID        : {D7F18A9F-7B0D-48E8-B364-5C88EE47D285}
ServiceWindowSchedules : 00155B00C0211800
ServiceWindowType      : 1
StartTime              : 5/21/2014 12:00:00 AM

SS10010D
Description            : Occurs the Third Saturday of every 1 months effective 2/15/2014 6:00 PM
Duration               : 360
IsEnabled              : True
IsGMT                  : False
Name                   : 3rd Saturday 6PM - 12AM
RecurrenceType         : 4
ServiceWindowID        : {59DB0AA1-2B73-4B7A-BD68-F32429D17E0E}
ServiceWindowSchedules : 024F2B0030271600
ServiceWindowType      : 4
StartTime              : 2/15/2014 6:00:00 PM

SS1000A1
Description            : Occurs the Third Friday of every 1 months effective 9/9/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : Louisiana Call Center
RecurrenceType         : 4
ServiceWindowID        : {56D593D4-9B47-48EC-9830-3FD87C486326}
ServiceWindowSchedules : 02899ADE48261600
ServiceWindowType      : 1
StartTime              : 9/9/2013 8:00:00 PM

SS1000E1
Description            : Occurs the Second Friday of every 1 months effective 9/30/2013 6:00 PM
Duration               : 690
IsEnabled              : True
IsGMT                  : False
Name                   : 2nd Friday
RecurrenceType         : 4
ServiceWindowID        : {C3B9E194-1D3C-42A9-86D3-F0E0C36ACD36}
ServiceWindowSchedules : 025E9ADE58261400
ServiceWindowType      : 1
StartTime              : 9/30/2013 6:00:00 PM

SS1000E2
Description            : Occurs the Second Saturday of every 1 months effective 5/16/2013 1:00 PM
Duration               : 600
IsEnabled              : True
IsGMT                  : False
Name                   : 2nd Saturday
RecurrenceType         : 4
ServiceWindowID        : {EDF33E11-5BEE-4577-8472-7E6F766525B7}
ServiceWindowSchedules : 01B05AC050271400
ServiceWindowType      : 1
StartTime              : 5/16/2013 1:00:00 PM

SS1000E0
Description            : Occurs the Second Thursday of every 1 months effective 5/15/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 2nd Thursday
RecurrenceType         : 4
ServiceWindowID        : {541626CC-7100-49B0-B0D6-EBF16EC0BF6C}
ServiceWindowSchedules : 028F5ADE48251400
ServiceWindowType      : 1
StartTime              : 5/15/2013 8:00:00 PM

SS1000E3
Description            : Occurs the Second Wednesday of every 1 months effective 5/16/2013 8:00 PM
Duration               : 570
IsEnabled              : True
IsGMT                  : False
Name                   : 2nd Wednesday
RecurrenceType         : 4
ServiceWindowID        : {231DB628-0528-4709-A891-A7CCDBD646EB}
ServiceWindowSchedules : 02905ADE48241400
ServiceWindowType      : 1
StartTime              : 5/16/2013 8:00:00 PM

SS1000E4
SS10007B
Description            : Occurs on 4/26/2019 8:00 PM
Duration               : 480
IsEnabled              : True
IsGMT                  : False
Name                   : Future Dated Window
RecurrenceType         : 1
ServiceWindowID        : {02C930F5-0D93-41A2-B2DB-190246EA1944}
ServiceWindowSchedules : 029A4C4040080000
ServiceWindowType      : 1
StartTime              : 4/26/2019 8:00:00 PM

SS10007A
SS100084
Description            : Occurs on 1/1/2019 1:00 AM
Duration               : 180
IsEnabled              : True
IsGMT                  : False
Name                   : Future Maint. Window
RecurrenceType         : 1
ServiceWindowID        : {D7E21E00-4A0F-4C02-9F75-4689FB671744}
ServiceWindowSchedules : 00211C4018080000
ServiceWindowType      : 1
StartTime              : 1/1/2019 1:00:00 AM

#>
