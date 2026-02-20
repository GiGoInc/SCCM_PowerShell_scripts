# Note: If you want incremental updating enabled on the Collections you can set the –RefreshType to Both instead of Periodic.  
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName7" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup7'" -RuleName "QueryRuleName7"
    Add-CMUserCollectionQueryMembershipRule -CollectionName "CollectionName6" -QueryExpression "select *  from  SMS_R_User where SMS_R_User.UserGroupName = 'DOMAIN\\SecurityGroup6'" -RuleName "QueryRuleName6"
# Note: If you want incremental updating enabled on the Collections you can set the –RefreshType to Both instead of Periodic.  

<#
    New-CMDeviceCollection -Name "Dell Inc. Latitude 5290 2-IN-1" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 5480" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 7390" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 7480" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 9510" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude E5550" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude E5570" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude E7470" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude XPS 13" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude XPS 15 (9575)" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Ddell Inc. Optiplex 7450 AIO" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Precision 3630 TOWER" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Precision 7740" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Lenovo Thinkpad P43s" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Lenovo Thinkpad X1 Carbon" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Newline" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "VMWARE Virtual Machine" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic

#>

############################################################################################
############################################################################################

$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"

$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer 
}
Set-Location "$($SiteCode):\"


############################################################################################
############################################################################################


# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "02/23/2023 8:00 AM" -DayOfWeek Monday -RecurCount 1 
	# $Schedule2 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Tuesday -RecurCount 1 
	# $Schedule3 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Wednesday -RecurCount 1 
	# $Schedule4 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Thursday -RecurCount 1 
	# $Schedule5 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Friday -RecurCount 1 
	# $Schedule6 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Saturday -RecurCount 1 
	# $Schedule7 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Sunday -RecurCount 1 

# Defined Device Collections to be created
    New-CMDeviceCollection -Name "Dell Inc. Latitude 5290 2-IN-1" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 5480" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 7390" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 7480" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude 9510" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude E5550" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude E5570" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude E7470" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude XPS 13" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Latitude XPS 15 (9575)" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Ddell Inc. Optiplex 7450 AIO" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Precision 3630 TOWER" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Dell Inc. Precision 7740" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Lenovo Thinkpad P43s" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Lenovo Thinkpad X1 Carbon" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "Newline" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic
    New-CMDeviceCollection -Name "VMWARE Virtual Machine" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Periodic

# Defined Query Rule for Device Collections
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude 5290 2-IN-1' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%5290 2-IN-1%"' -RuleName 'Dell Inc. Latitude 5290 2-IN-1'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude 5480' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%5480%"' -RuleName 'Dell Inc. Latitude 5480'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude 7390' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%7390%"' -RuleName 'Dell Inc. Latitude 7390'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude 7480' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%7480%"' -RuleName 'Dell Inc. Latitude 7480'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude 9510' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%9510%"' -RuleName 'Dell Inc. Latitude 9510'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude E5550' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%E5550%"' -RuleName 'Dell Inc. Latitude E5550'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude E5570' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%E5570%"' -RuleName 'Dell Inc. Latitude E5570'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude E7470' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%E7470%"' -RuleName 'Dell Inc. Latitude E7470'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude XPS 13' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%XPS 13%"' -RuleName 'Dell Inc. Latitude XPS 13'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Latitude XPS 15 (9575)' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%9575%"' -RuleName 'Dell Inc. Latitude XPS 15 (9575)'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Optiplex 7450 AIO' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%7450 AIO%"' -RuleName 'Ddell Inc. Optiplex 7450 AIO'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Precision 3630 TOWER' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%3630 TOWER%"' -RuleName 'Dell Inc. Precision 3630 TOWER'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Dell Precision 7740' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%7740%"' -RuleName 'Dell Inc. Precision 7740'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Lenovo Thinkpad P43s' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%20RH000JUS%" or SMS_G_System_COMPUTER_SYSTEM.Model like "%20RH000PUS%"' -RuleName 'Lenovo Thinkpad P43s'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Lenovo Thinkpad X1 Carbon' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%344834U%"' -RuleName 'Lenovo Thinkpad X1 Carbon'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'Newline' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%To be filled by O.E.M.%"' -RuleName 'Newline'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName 'VMWARE Virtual Machine' -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like "%VMWARE Virtual Machine%"' -RuleName 'VMWARE Virtual Machine'


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
