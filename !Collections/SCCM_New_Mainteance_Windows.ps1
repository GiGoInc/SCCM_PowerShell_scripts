D:
#>
RemoteLocale Workstation Test - Central Underwriting Workstations Test - 3rd Saturday	XX10043B
D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

$COLLID = "XX10043A"
$Day2 = "5"
$Day3 = "6"
$Day4 = "7"
$Day5 = "8"

$Schedule2 = New-CMSchedule -DayOfMonth $Day2 -DurationCount 9 -DurationInterval Hours -RecurCount 1  -Start ([Datetime]"20:00")
$Schedule3 = New-CMSchedule -DayOfMonth $Day3 -DurationCount 9 -DurationInterval Hours -RecurCount 1  -Start ([Datetime]"20:00")
$Schedule4 = New-CMSchedule -DayOfMonth $Day4 -DurationCount 9 -DurationInterval Hours -RecurCount 1  -Start ([Datetime]"20:00")
$Schedule5 = New-CMSchedule -DayOfMonth $Day5 -DurationCount 9 -DurationInterval Hours -RecurCount 1  -Start ([Datetime]"20:00")

New-CMMaintenanceWindow -CollectionID $COLLID -Schedule $Schedule2 -Name $Day2
New-CMMaintenanceWindow -CollectionID $COLLID -Schedule $Schedule3 -Name $Day3
New-CMMaintenanceWindow -CollectionID $COLLID -Schedule $Schedule4 -Name $Day4
New-CMMaintenanceWindow -CollectionID $COLLID -Schedule $Schedule5 -Name $Day5

CD E:
<#
#Occurs day 3 of every 2 months effective 10/17/2013 1:00 PM
$Schedule = New-CMSchedule -DurationCount 1 -DurationInterval Hours -RecurCount 2 -DayOfMonth 3 -Start ([Datetime]"13:00")
$Collection = Get-CMDeviceCollection -Name "MW 1 - Windows Servers"
New-CMMaintenanceWindow -CollectionID $Collection.CollectionID -Schedule $Schedule -Name "TEST 1"

#Occurs the First Thursday of every 2 months effective 10/17/2013 1:00 PM
$Schedule = New-CMSchedule -DurationCount 1 -DurationInterval Hours -RecurCount 2 -DayOfWeek 4 -WeekOrder First -Start ([Datetime]"13:00")
$Collection = Get-CMDeviceCollection -Name "MW 1 - Windows Servers"
New-CMMaintenanceWindow -CollectionID $Collection.CollectionID -Schedule $Schedule -Name "TEST 2"

#Occurs the last day of every 4 months effective 10/17/2013 1:00 PM
$Schedule = New-CMSchedule -DurationInterval Days -DurationCount 2 -RecurCount 4 -LastDayOfMonth -Start ([Datetime]"13:00")
$Collection = Get-CMDeviceCollection -Name "MW 2 - LOB Servers"
New-CMMaintenanceWindow -CollectionID $Collection.CollectionID -Schedule $Schedule -Name "TEST 3"


RemoteLocale Workstation Test - 15th	XX100429
RemoteLocale Workstation Test - 16th	XX10042A
RemoteLocale Workstation Test - 17th	XX123456
RemoteLocale Workstation Test - 18th	XX10042C
RemoteLocale Workstation Test - 19th	XX10042D
RemoteLocale Workstation Test - 20th	XX10042E
RemoteLocale Workstation Test - 21st	XX10042F
RemoteLocale Workstation Test - 22nd	XX123456
RemoteLocale Workstation Test - 23rd	XX100431
RemoteLocale Workstation Test - 24th	XX100432
RemoteLocale Workstation Test - 25th	XX100433
RemoteLocale Workstation Test - 26th	XX100434
RemoteLocale Workstation Test - 27th	XX100435
RemoteLocale Workstation Test - 28th	XX100436
RemoteLocale Workstation Test - 1st	XX100437
RemoteLocale Workstation Test - 2nd	XX100438
RemoteLocale Workstation Test - 3rd	XX100439
RemoteLocale Workstation Test - 4th	XX10043A
RemoteLocale Workstation Test - Central Underwriting Workstations Test - 3rd Saturday	XX10043B
#>
