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
$SQL_Queries = "D:\Powershell\!SCCM_PS_scripts\!Collections\Maintenance_Windows\Get_All_Collection_Membership_Queries_$ADate.txt"
If (!(Test-Path $SQL_Queries)) { New-Item -Path $SQL_Queries -ItemType File -Force }
$Null | Set-Content $SQL_Queries

Write-Host "Getting all Device collections...." -ForegroundColor Yellow
$Collections = Get-CMCollection -CollectionType Device
$total = $collections.count

$i = 1
$total = $Collections.count
ForEach ($Collection in $Collections)
{
    $CollName =  $($Collection.Name)
    Try
    {
        $Query = $Null
        $Query = Get-CMDeviceCollectionQueryMembershipRule -CollectionName "$CollName"
        If ($Query -ne $null)
        {
                 [string]$QueryExp = $($Query.QueryExpression)
            [string]$QueryRuleName = $($Query.RuleName)

            $QueryExp = $QueryExp -replace '"',"'"
            $QueryExp = $QueryExp -replace 'SMS_','v_'
            $QueryExp = $QueryExp -replace 'v_R_System.Name','v_R_System.Name0'
            $QueryExp = $QueryExp -replace 'v_R_System.Client','v_R_System.Client0'
            $QueryExp = $QueryExp -replace 'v_R_System.SMSUniqueIdentifier','v_R_System.SMS_Unique_Identifier0'
            $QueryExp = $QueryExp -replace 'v_R_System.ResourceDomainORWorkgroup','v_R_System.Resource_Domain_OR_Workgr0'

            Write-Host "$i of $total`t--- $CollName`t--- $QueryRuleName" -ForegroundColor Green
           '/* ' + "$i of $total -- $($Collection.Name)" + ' --- ' + $QueryRuleName + ' */ ' + $QueryExp  | Add-Content $SQL_Queries
        }     
    }
    Catch
    {
        Write-Host "$i of $total`t---$($Collection.Name)`t-`tSomething went wrong" -ForegroundColor Red
        "$i of $total`t$Collection`tSomething went wrong"  | Add-Content $SQL_Queries
    }
$i++
}              
