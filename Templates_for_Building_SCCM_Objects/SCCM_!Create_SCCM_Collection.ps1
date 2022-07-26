#SCCM Module
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:


# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "01/11/2016 12:00 AM" -RecurCount 1 -RecurInterval Days

$CollList = Get-Content "C:\!Powershell\!SCCM_PS_scripts\!Create_SCCM_Collection_PCList.txt"

ForEach ($CollName in $CollList)
{	
# Defined Device Collections to be created	
New-CMDeviceCollection -Name $CollName -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Both -Comment "created Jan 11, 2016 for Seagate firmware updates"

# Defined Query Rule for Device Collections
#Add-CMDeviceCollectionQueryMembershipRule -CollectionName "Test - All Dell TS Machines" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CORPORATENAME on SMS_G_System_CORPORATENAME.ResourceID = SMS_R_System.ResourceId where SMS_G_System_CORPORATENAME.TS_Name Like '%'" -RuleName "QueryRuleName1"

}

CD C: