# Note: If you want incremental updating enabled on the Collections you can set the –RefreshType to Both instead of Periodic.  


# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "07/11/2017 8:00 PM" -DayOfWeek Monday -RecurCount 1 
	# $Schedule2 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Tuesday -RecurCount 1 
	# $Schedule3 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Wednesday -RecurCount 1 
	# $Schedule4 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Thursday -RecurCount 1 
	# $Schedule5 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Friday -RecurCount 1 
	# $Schedule6 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Saturday -RecurCount 1 
	# $Schedule7 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Sunday -RecurCount 1 

# Defined Device Collections to be created
    New-CMDeviceCollection -Name "CollectionName1" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "CollectionName2" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule2 -RefreshType Periodic
    New-CMDeviceCollection -Name "CollectionName3" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule3 -RefreshType Periodic
    New-CMDeviceCollection -Name "CollectionName4" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule4 -RefreshType Periodic
    New-CMDeviceCollection -Name "CollectionName5" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule5 -RefreshType Periodic
    New-CMDeviceCollection -Name "CollectionName6" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule6 -RefreshType Periodic
    New-CMDeviceCollection -Name "CollectionName7" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule7 -RefreshType Periodic

# Defined Query Rule for Device Collections
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName1" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup1'" -RuleName "QueryRuleName1"
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName2" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup2'" -RuleName "QueryRuleName2"
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName3" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup3'" -RuleName "QueryRuleName3"
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName4" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup4'" -RuleName "QueryRuleName4"
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName5" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup5'" -RuleName "QueryRuleName5"
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName6" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup6'" -RuleName "QueryRuleName6"
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "CollectionName7" -QueryExpression "select *  from  SMS_R_System where SMS_R_System.SystemGroupName = 'DOMAIN\\SecurityGroup7'" -RuleName "QueryRuleName7"



# Defined User Collections to be created
    New-CMUserCollection -Name "CollectionName1" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMUserCollection -Name "CollectionName2" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule2 -RefreshType Periodic
    New-CMUserCollection -Name "CollectionName3" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule3 -RefreshType Periodic
    New-CMUserCollection -Name "CollectionName4" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule4 -RefreshType Periodic
    New-CMUserCollection -Name "CollectionName5" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule5 -RefreshType Periodic
    New-CMUserCollection -Name "CollectionName6" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule6 -RefreshType Periodic
    New-CMUserCollection -Name "CollectionName7" -LimitingCollectionName "LimitingCollection" -RefreshSchedule $Schedule7 -RefreshType Periodic

# Defined Query Rule for User Collections
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName1" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup1'" -RuleName "QueryRuleName1"
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName2" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup2'" -RuleName "QueryRuleName2"
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName3" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup3'" -RuleName "QueryRuleName3"
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName4" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup4'" -RuleName "QueryRuleName4"
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName5" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup5'" -RuleName "QueryRuleName5"
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName6" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup6'" -RuleName "QueryRuleName6"
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName7" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup7'" -RuleName "QueryRuleName7"