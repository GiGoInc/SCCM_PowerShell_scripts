$computer = 'XXXXET93'
#>
[wmi]'ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId="a7c7c9d2-9d10-4b3e-9ab3-8e7d436e8c54"' | remove-wmiobject
$computer = 'XXXXET93'
$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx  -Impersonation 3 -ComputerName $computer


ForEach ($item in $A)
{
$CID = $item.cacheid
$loc = $item.location
$RP = $loc.ToString().split('C:')[2]
$folder = "\\$computer\C$"+"$RP"
'\\'+$computer+'\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
Remove-Item $folder -Recurse -Force
Write-host "Removing $folder"
}



<#

#Connect to Resource Manager COM Object
$resman = new-object -com "UIResource.UIResourceMgr"
$cacheInfo = $resman.GetCacheInfo()
#Enum Cache elements and delete all
$cacheinfo.GetCacheElements()  | foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}


###### Another script
([wmi]"ROOT\ccm:SMS_Client=@").ClientVersion
([wmiclass]"ROOT\ccm:SMS_Client").GetAssignedSite().sSiteCode
([wmi]"ROOT\ccm:SMS_Authority.Name='SMS:XX1'").CurrentManagementPoint
$a = get-wmiobject -query "SELECT * FROM CacheInfoEx" -namespace "\\$computer\ROOT\ccm\SoftMgmtAgent"
ForEach ($item in $list)
{
Remove-Item "C:\WINDOWS\ccmcache\$item" -recurse
}

[wmi]'ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId="7c382899-26bd-4bab-9fbd-9dbc0671b369"' | remove-wmiobject
Cannot find path 'C:\WINDOWS\ccmcache\32' because it does not exist.
Remove-Item "C:\WINDOWS\ccmcache\32" -recurse
[wmi]'ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId="a7c7c9d2-9d10-4b3e-9ab3-8e7d436e8c54"' | remove-wmiobject
#>
