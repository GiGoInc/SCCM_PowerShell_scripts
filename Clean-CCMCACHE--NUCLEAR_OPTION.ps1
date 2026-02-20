#([wmiclass]"ROOT\ccm:SMS_Client").GetAssignedSite().sSiteCode
"Cleaned Items:" + $Cleaned
}
#([wmiclass]"ROOT\ccm:SMS_Client").GetAssignedSite().sSiteCode
#([wmi]"ROOT\ccm:SMS_Client=@").ClientVersion
#([wmiclass]"ROOT\ccm:SMS_Client").GetAssignedSite().sSiteCode
#([wmi]"ROOT\ccm:SMS_Authority.Name='SMS:XX1'").CurrentManagementPoint
$WMICheck = get-wmiobject -query "SELECT * FROM CacheInfoEx" -namespace "ROOT\ccm\SoftMgmtAgent"
ForEach ($Item in $WMICheck)
{
    $Location = $Item.Location
    $CacheID = $Item.cacheID
    Remove-Item "$Location" -recurse
    $WMIItem = 'ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId="'+$CacheID+'"'
    [wmi]$WMIItem | remove-wmiobject
}
######################################################################################################################
# Cleanup Orphaned Items
######################################################################################################################
$CacheElements =  get-wmiobject -query "SELECT * FROM CacheInfoEx" -namespace "ROOT\ccm\SoftMgmtAgent"
$ElementGroup = $CacheElements | Group-Object ContentID
[int]$Cleaned = 0;

#Cleanup CacheItems where ContentFolder does not exist
$CacheElements | where {!(Test-Path $_.Location)} | % { $_.Delete(); $Cleaned++ }
$CacheElements = get-wmiobject -query "SELECT * FROM CacheInfoEx" -namespace "ROOT\ccm\SoftMgmtAgent"

foreach ($ElementID in $ElementGroup) 
{
    if ($ElementID.Count -gt 1) 
    {
        $max = ($ElementID.Group.ContentVer| Measure-Object -Maximum).Maximum

        $ElementsToRemove = $CacheElements | where {$_.contentid -eq $ElementID.Name -and $_.ContentVer-ne $Max}
        foreach ($Element in $ElementsToRemove) 
        {
            write-host “Deleting”$Element.ContentID”with version”$Element.ContentVersion -ForegroundColor Red

            Remove-Item $Element.Location -recurse
            $Element.Delete()
            $Cleaned++
        }
    } 
}
#Cleanup Orphaned Folders in ccmcache
$UsedFolders = $CacheElements | % { Select-Object -inputobject $_.Location }
[string]$CCMCache = ([wmi]"ROOT\ccm\SoftMgmtAgent:CacheConfig.ConfigKey='Cache'").Location
if($CCMCache.EndsWith('ccmcache'))
{
    Get-ChildItem($CCMCache) |  ?{ $_.PSIsContainer } | WHERE { $UsedFolders -notcontains $_.FullName } | % { Remove-Item $_.FullName -recurse ; $Cleaned++ }
}
"Cleaned Items:" + $Cleaned
