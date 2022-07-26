D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:

CD SS1:

# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Monday -RecurCount 1 
$Schedule2 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Tuesday -RecurCount 1 
$Schedule3 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Wednesday -RecurCount 1 

# Defined Device Collections to be created
New-CMDeviceCollection -Name "CollectionName1" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule1 -RefreshType Periodic
New-CMDeviceCollection -Name "CollectionName2" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule2 -RefreshType Periodic
New-CMDeviceCollection -Name "CollectionName3" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule3 -RefreshType Periodic


# Defined Query Rule for Device Collections
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName1" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup1'" -RuleName "QueryRuleName1"
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName2" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup2'" -RuleName "QueryRuleName2"
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName3" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup3'" -RuleName "QueryRuleName3"



# Defined User Collections to be created
New-CMUserCollection -Name "CollectionName1" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule1 -RefreshType Periodic
New-CMUserCollection -Name "CollectionName2" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule2 -RefreshType Periodic
New-CMUserCollection -Name "CollectionName3" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule3 -RefreshType Periodic

# Defined Query Rule for User Collections
Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName1" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup1'" -RuleName "QueryRuleName1"
Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName2" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup2'" -RuleName "QueryRuleName2"
Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName3" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup3'" -RuleName "QueryRuleName3"