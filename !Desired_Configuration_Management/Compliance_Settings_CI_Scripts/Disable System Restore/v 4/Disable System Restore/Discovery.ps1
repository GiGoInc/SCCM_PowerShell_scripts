$TaskService = New-Object -com schedule.service
$TaskService.GetFolder('\Microsoft\Windows\SystemRestore').GetTask('SR').Enabled
$TaskService.Connect($env:COMPUTERNAME)
$TaskService = New-Object -com schedule.service
$TaskService.Connect($env:COMPUTERNAME)
$TaskService.GetFolder('\Microsoft\Windows\SystemRestore').GetTask('SR').Enabled
