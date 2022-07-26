D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:

CD SS1:

# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "09/01/2014 12:00 AM" -RecurCount 1 -RecurInterval Days

# Defined Device Collections to be created
# STATE
	New-CMDeviceCollection -Name "City1" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Both
	New-CMDeviceCollection -Name "City2" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Both

	Add-CMDeviceCollectionQueryMembershipRule -CollectionName "City1" -QueryExpression "select * from  SMS_R_System inner join SMS_G_System_NETWORK_ADAPTER_CONFIGURATION on SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.ResourceId = SMS_R_System.ResourceId where SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.IPAddress like '192.168.1.%'" -RuleName "Powershell"
	Add-CMDeviceCollectionQueryMembershipRule -CollectionName "City2" -QueryExpression "select * from  SMS_R_System inner join SMS_G_System_NETWORK_ADAPTER_CONFIGURATION on SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.ResourceId = SMS_R_System.ResourceId where SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.IPAddress like '192.168.101.%'" -RuleName "Powershell"

