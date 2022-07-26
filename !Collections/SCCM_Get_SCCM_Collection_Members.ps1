$SiteServer = 'SCCMSERVER.Domain.Com'
$SiteCode = 'SS1'
#$cred = Get-credential
$SCCMColls = 'D:\Powershell\!SCCM_PS_scripts\!Collections\SCOrch_Get_Collection_Members--Results.csv'
If (Test-Path $SCCMColls){Remove-Item $SCCMColls}

$CollectionNames = gc "D:\Powershell\!SCCM_PS_scripts\!Collections\SCOrch_Get_Collection_Members--PCList.txt"

Function RunTime
{
    $End = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $Start –End $End
    $Min = $TS.minutes
    $Sec = $TS.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
}

$Start = (GET-DATE)
Write-Host "$(Get-Date)`tBuilding list of Collection Memberships -- Estimated time 3 minutes"
      
ForEach ($CollectionName in $CollectionNames)
{
    #Retrieve SCCM collection by name
    $Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection | where {$_.Name -like "$CollectionName"}
    ForEach ($Item in $Collection)
    {
        $CN = $Item.Name
        $CI = $Item.CollectionID
        "$CI`t$CN" | Add-Content $SCCMColls

        #Retrieve members of collection 
        $SMSMembers = Get-WmiObject -ComputerName $SiteServer -Namespace "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($CI)' order by name" | select Name
        ForEach($Member in $SMSMembers){"$CN,$($Member.Name)" | Add-Content $SCCMColls}
    }
}
Write-Host "$(Get-Date)`tDone building list of Collection Memberships" -ForegroundColor Green
RunTime
Start-Sleep -Seconds 2


<#
$SiteServer = 'SCCMSERVER.Domain.Com'
$SiteCode = 'SS1'
$CollectionID = 'SS100669'
$cred = Get-credential 
#Retrieve SCCM collection by name 
$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection -Credential $cred  | where {$_.Name -eq "$CollectionName"} 
#Retrieve members of collection 
$SMSMemebers = Get-WmiObject -ComputerName $SiteServer -Credential $cred -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID= $CollectionID order by name" | select Name
#>