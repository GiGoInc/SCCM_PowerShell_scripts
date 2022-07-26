D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$COLLID = "SS10043A"
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


Branch Workstation Test - 15th	SS100429
Branch Workstation Test - 16th	SS10042A
Branch Workstation Test - 17th	SS10042B
Branch Workstation Test - 18th	SS10042C
Branch Workstation Test - 19th	SS10042D
Branch Workstation Test - 20th	SS10042E
Branch Workstation Test - 21st	SS10042F
Branch Workstation Test - 22nd	SS100430
Branch Workstation Test - 23rd	SS100431
Branch Workstation Test - 24th	SS100432
Branch Workstation Test - 25th	SS100433
Branch Workstation Test - 26th	SS100434
Branch Workstation Test - 27th	SS100435
Branch Workstation Test - 28th	SS100436
Branch Workstation Test - 1st	SS100437
Branch Workstation Test - 2nd	SS100438
Branch Workstation Test - 3rd	SS100439
Branch Workstation Test - 4th	SS10043A
Branch Workstation Test - Central Underwriting Workstations Test - 3rd Saturday	SS10043B
#>