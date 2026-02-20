cls
Write-Host "done..." -ForegroundColor Green
}
cls
##############################
C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:

$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
  $Log = "D:\Powershell\!SCCM_PS_scripts\!Collections\Get_CollectionMembership_by_Query\Get_Maintenance_Windows_for_Device_Collections_$ADate.csv"
'Collection Name,MW Name,MW Start Time,MW Description' | Set-Content $Log

#######################################################################

Write-Host "Getting all Device collections...." -ForegroundColor Yellow
$Collections = Get-CMCollection -CollectionType Device

#######################################################################

Write-Host "Getting Maintenance Windows from" $Collections.count "Collections...." -ForegroundColor Cyan
ForEach ($Collection in $Collections)
{
    $MWs = Get-CMMaintenanceWindow -CollectionName $Collection.Name | Where-Object { $_.IsEnabled }
    ForEach ($MW in $MWs)
    {
        $Collection.Name + ',' + $MW.Name + ',' + $MW.StartTime + ',' + $MW.Description | Add-Content $Log
    }
}
Write-Host "done..." -ForegroundColor Green
