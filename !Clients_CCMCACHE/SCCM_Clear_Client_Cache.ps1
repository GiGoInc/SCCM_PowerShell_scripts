#Connect to Resource Manager COM Object


#Connect to Resource Manager COM Object
$resman = new-object -com "UIResource.UIResourceMgr"
$cacheInfo = $resman.GetCacheInfo()
#Enum Cache elements, compare date, and delete older than 60 days
$cacheinfo.GetCacheElements()  | foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}



