[__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
$CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
ForEach ($CacheItem in $CacheInfo) {$null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))}