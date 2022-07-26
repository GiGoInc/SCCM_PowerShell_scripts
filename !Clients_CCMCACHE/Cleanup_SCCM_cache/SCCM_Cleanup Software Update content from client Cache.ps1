#Title:Delete Software update folders from ccmcache folder on Configmgr 2012 Client
#Author:Eswar Koneti
#dated:06-June-2015
#blog: www.eskonr.com

$CMObject = new-object -com "UIResource.UIResourceMgr"
$cacheInfo = $CMObject.GetCacheInfo()
$objects = $cacheinfo.GetCacheElements()  |
 where-object {$_.ContentId.Length -ne 8 -and  $_.ContentId -notlike 'conten*'} |
   select-object location, CacheElementID, ContentSize 
   
    if ($objects.count -gt 1) 
   {
    $objects |Format-Table -Wrap -AutoSize| tee-object -filepath "C:\windows\temp\cacheremoval.log"
  
#Now calculate the total space freed
$sum = $objects | Measure-Object -Sum -Property ContentSize 
$sum1=[math]::round($sum.sum/1024,2)
" 
Freed Space  $sum1 MB" | Out-File "C:\windows\temp\cacheremoval.log" -Append
#delete the software update folders from ccmcache folder

 ForEach ($Item in $objects)
         {
            $cacheInfo.DeleteCacheElement($item.CacheElementID)  
          }
          
}   
       
          
