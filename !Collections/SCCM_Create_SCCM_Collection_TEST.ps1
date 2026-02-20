D:
CD E:

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:

CD XX1:

# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "09/01/2014 12:00 AM" -RecurCount 1 -RecurInterval Days


# Defined Device Collections to be created
New-CMDeviceCollection -Name "AppProfile - Wholesale - LOB - Lafayette - Morgan City" -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Both

# Defined Query Rule for Device Collections
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "AppProfile - Wholesale - LOB - Lafayette - Morgan City" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_DOMAINHolding on SMS_G_System_DOMAINHolding.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DOMAINHolding.AppProfile ='Wholesale - West - Central Florida'" -RuleName "QueryRuleName1"

CD E:
