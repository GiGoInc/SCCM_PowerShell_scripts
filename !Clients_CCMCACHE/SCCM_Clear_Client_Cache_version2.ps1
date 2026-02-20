<#
foreach{$cacheInfo.DeleteCacheElement($_.CacheElementID)} 
$cacheinfo.GetCacheElements()  |
<#
.SYNOPSIS
    Clears all Packages from the Configuration Manager Client Cache.
.DESCRIPTION
    Clears all Packages from the Configuration Manager Client Cache.
.EXAMPLE
    .\clear-ClientCache.ps1
.NOTES
    Author: David O'Brien, david.obrien@sepago.de
    Version: 1.0
    Change history
        07.02.2013 - first release
        Requirements: installed ConfigMgr Agent on local machine
#>


[CmdletBinding()]
$UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
$Cache = $UIResourceMgr.GetCacheInfo()
$CacheElements = $Cache.GetCacheElements()
foreach ($Element in $CacheElements)
    {
        Write-Verbose "Deleting CacheElement with PackageID $($Element.ContentID)"
        Write-Verbose "in folder location $($Element.Location)"
        $Cache.DeleteCacheElement($Element.CacheElementID)
    }


#Connect to Resource Manager COM Object
$resman=new-object-com"UIResource.UIResourceMgr"
$cacheInfo=$resman.GetCacheInfo()
#Enum Cache elements, compare date, and delete older than 60 days
$cacheinfo.GetCacheElements()  |
foreach{$cacheInfo.DeleteCacheElement($_.CacheElementID)} 
