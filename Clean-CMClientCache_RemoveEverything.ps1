[__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
ForEach ($CacheItem in $CacheInfo) {$null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))}
$CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
[__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
$CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
ForEach ($CacheItem in $CacheInfo) {$null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))}
