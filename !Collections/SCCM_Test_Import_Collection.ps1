D:
# select * from SMS_R_System where SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.IPAddress like "10.225.15.%"

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:

CD XX1:

# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "09/01/2014 9:00 PM" -DayOfWeek Monday -RecurCount 1 

# Defined Device Collections to be created
New-CMDeviceCollection -Name"Cottage Hill" -LimitingCollectionName"XX100010" -RefreshSchedule $Schedule1 -RefreshType Both


# Defined Query Rule for Device Collections
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName1" -QueryExpression "select * from SMS_R_System where SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.IPAddress like '10.225.15.%'" -RuleName "QueryRuleName1"

# select * from SMS_R_System where SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.IPAddress like "10.225.15.%"
