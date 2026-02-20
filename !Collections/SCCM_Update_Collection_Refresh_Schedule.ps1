$Collections1 = 'BIOS - DELL LATITUDE 5500', 
$Collections2 | % { $_;Set-CMDeviceCollection -Name "$_" -RefreshSchedule $Schedule2 -RefreshType Periodic }

$Collections1 = 'BIOS - DELL LATITUDE 5500', 
'BIOS - DELL LATITUDE 5510', 
'BIOS - DELL LATITUDE 5520', 
'BIOS - DELL LATITUDE 5530', 
'BIOS - DELL LATITUDE 5540', 
'BIOS - DELL LATITUDE 5550', 
'BIOS - DELL LATITUDE 7390', 
'BIOS - DELL LATITUDE 7400 2-IN-1', 
'BIOS - DELL LATITUDE 7420', 
'BIOS - DELL LATITUDE 7430', 
'BIOS - DELL LATITUDE 7440', 
'BIOS - DELL LATITUDE 7450', 
'BIOS - DELL OPTIPLEX 7000', 
'BIOS - DELL OPTIPLEX 7010 SFF', 
'BIOS - DELL OPTIPLEX 7020 SFF', 
'BIOS - DELL OPTIPLEX 7070', 
'BIOS - DELL OPTIPLEX 7080', 
'BIOS - DELL OPTIPLEX 7090', 
'BIOS - DELL PRECISION 7440', 
'BIOS - DELL PRECISION 7740'

$Collections2 = 'LOGGED OFF - BIOS - DELL LATITUDE 5500', 
'LOGGED OFF - BIOS - DELL LATITUDE 5510', 
'LOGGED OFF - BIOS - DELL LATITUDE 5520', 
'LOGGED OFF - BIOS - DELL LATITUDE 5530', 
'LOGGED OFF - BIOS - DELL LATITUDE 5540', 
'LOGGED OFF - BIOS - DELL LATITUDE 5550', 
'LOGGED OFF - BIOS - DELL LATITUDE 7390', 
'LOGGED OFF - BIOS - DELL LATITUDE 7400 2-IN-1', 
'LOGGED OFF - BIOS - DELL LATITUDE 7420', 
'LOGGED OFF - BIOS - DELL LATITUDE 7430', 
'LOGGED OFF - BIOS - DELL LATITUDE 7440', 
'LOGGED OFF - BIOS - DELL LATITUDE 7450', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7000', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7010 SFF', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7020 SFF', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7070', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7080', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7090', 
'LOGGED OFF - BIOS - DELL PRECISION 7440', 
'LOGGED OFF - BIOS - DELL PRECISION 7740'


$Sched1DateTime = Get-Date -UFormat "%Y/%m/%d 08:00:00"
$Sched2DateTime = Get-Date -UFormat "%Y/%m/%d 08:30:00"



# Collections Update Schedules
$Schedule1 = New-CMSchedule -DurationInterval Hours `
                            -DurationCount 0 `
							-RecurInterval Hours `
							-RecurCount 4 `
							-Start $Sched1DateTime

# Collections Update Schedules
$Schedule2 = New-CMSchedule -DurationInterval Hours `
                            -DurationCount 0 `
							-RecurInterval Hours `
							-RecurCount 4 `
							-Start $Sched2DateTime


$Collections1 | % { $_;Set-CMDeviceCollection -Name "$_" -RefreshSchedule $Schedule1 -RefreshType Periodic }

$Collections2 | % { $_;Set-CMDeviceCollection -Name "$_" -RefreshSchedule $Schedule2 -RefreshType Periodic }
