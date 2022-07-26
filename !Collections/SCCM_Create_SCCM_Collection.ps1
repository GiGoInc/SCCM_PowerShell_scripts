#SCCM Module
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

# Collections Update Schedules
$Schedule1 = New-CMSchedule -Start "07/02/2019 8:30 AM" -RecurCount 3 -RecurInterval Days
# $Comments = "Created by Automated PowerShell script - 07/02/2019 - Isaac"

$CollList = Get-Content "D:\Powershell\!SCCM_PS_scripts\!Collections\SCCM_Create_Collection--PCList.txt"

ForEach ($Item in $CollList)
{	
    $CollName = $Item.split(',')[0]
    $Comments = $Item.split(',')[1] 
    # Defined Device Collections to be created	
        New-CMDeviceCollection -Name $CollName -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Both -Comment $Comments
    
    # Defined Query Rule for Device Collections
        # Add-CMDeviceCollectionQueryMembershipRule -CollectionName "Test - All Dell TS Machines" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CorpName on SMS_G_System_CorpName.ResourceID = SMS_R_System.ResourceId where SMS_G_System_CorpName.TS_Name Like '%'" -RuleName "QueryRuleName1"
}
CD C: