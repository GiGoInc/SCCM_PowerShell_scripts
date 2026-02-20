cls
Write-Host "done..." -ForegroundColor Green
}
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


$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
  $Log = "D:\Powershell\!SCCM_PS_scripts\!Collections\Maintenance_Windows\01__Get_Maintenance_Windows_for_Device_Collections_$ADate.csv"
'Collection Name,MW Name,MW Start Time,MW Description' | Set-Content $Log

#######################################################################

Write-Host "Getting all Device collections...." -ForegroundColor Yellow
$Collections = Get-CMCollection -CollectionType Device
$total = $collections.count
#######################################################################
$i = 1
Write-Host "Getting Maintenance Windows from" $Collections.count "Collections...." -ForegroundColor Cyan
ForEach ($Collection in $Collections)
{
    $MWs = Get-CMMaintenanceWindow -CollectionName $Collection.Name | Where-Object { $_.IsEnabled }
    ForEach ($MW in $MWs)
    {
        "$i of $total`t$($Collection.Name) "
        $Collection.Name + ',' + $MW.Name + ',' + $MW.StartTime + ',' + $MW.Description | Add-Content $Log
    }
    $i++
}
Write-Host "done..." -ForegroundColor Green
