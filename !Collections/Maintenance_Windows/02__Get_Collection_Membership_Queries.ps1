cls
}              
$i++
cls
##############################
$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"

$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer 
}
Set-Location "$($SiteCode):\"


$ADate = Get-Date -Format "yyyy-MM-dd"
$SQL_Queries = "D:\Powershell\!SCCM_PS_scripts\!Collections\Maintenance_Windows\02__Get_Collection_Membership_Queries_$ADate.txt"
$Null | Set-Content $SQL_Queries

$Collections = 'ADR COLLECTION - RemoteLocale WORKSTATIONS - TEST', `
               'RemoteLocale WORKSTATION - 01ST', `
               'RemoteLocale WORKSTATION - 02ND', `
               'RemoteLocale WORKSTATION - 03RD', `
               'RemoteLocale WORKSTATION - 04TH', `
               'RemoteLocale WORKSTATION - 19TH', `
               'RemoteLocale WORKSTATION - 20TH', `
               'RemoteLocale WORKSTATION - 21ST', `
               'RemoteLocale WORKSTATION - 22ND', `
               'RemoteLocale WORKSTATION - 23RD', `
               'RemoteLocale WORKSTATION - 24TH', `
               'RemoteLocale WORKSTATION - 25TH', `
               'RemoteLocale WORKSTATION - 26TH', `
               'RemoteLocale WORKSTATION - 27TH', `
               'RemoteLocale WORKSTATION - 28TH', `
               'RemoteLocale WORKSTATION - 4TH SUNDAY', `
               'RemoteLocale WORKSTATION - CENTRAL UNDERWRITING - 3RD SATURDAY', `
               'RemoteLocale WORKSTATION TEST - 15TH', `
               'RemoteLocale WORKSTATION TEST - 16TH', `
               'RemoteLocale WORKSTATION TEST - 17TH', `
               'RemoteLocale WORKSTATION TEST - 18TH', `
               'RemoteLocale WORKSTATIONS MAINT. WINDOW'

$i = 1
$total = $Collections.count
ForEach ($Collection in $Collections)
{
    Try
    {
        $Query = Get-CMDeviceCollectionQueryMembershipRule -CollectionName "$Collection"

        "$i of $total`t--- $Collection"
        #$Query.QueryExpression
        #''
        [string]$QueryExp = $($Query.QueryExpression)
        $QueryExp = $QueryExp -replace '"',"'"
        $QueryExp = $QueryExp -replace 'SMS_','v_'
        $QueryExp = $QueryExp -replace 'v_R_System.Name','v_R_System.Name0'
        $QueryExp = $QueryExp -replace 'v_R_System.Client','v_R_System.Client0'
        $QueryExp = $QueryExp -replace 'v_R_System.SMSUniqueIdentifier','v_R_System.SMS_Unique_Identifier0'
        $QueryExp = $QueryExp -replace 'v_R_System.ResourceDomainORWorkgroup','v_R_System.Resource_Domain_OR_Workgr0'

       '/* ' + $Collection + ' --- ' + $Query.RuleName + ' */ ' + $QueryExp  | Add-Content $SQL_Queries      
    }
    Catch
    {
        Write-Host "$i of $total`t--- $Collection`t-`tSomething went wrong" -ForegroundColor Red
        "$i of $total`t$Collection`tSomething went wrong"  | Add-Content $SQLQueries
    }
$i++
}              
