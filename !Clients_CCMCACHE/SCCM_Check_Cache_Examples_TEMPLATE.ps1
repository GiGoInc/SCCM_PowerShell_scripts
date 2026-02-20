# USE EXAMPE 1 TO INIATE CACHE AND ADD LINE INTO CAS.LOG
#######################################################################################################	
$CacheInfoQuery
# USE EXAMPE 1 TO INIATE CACHE AND ADD LINE INTO CAS.LOG

#######################################################################################################		
### CACHE - DISCOVERY SCRIPT - RUN LOCAL OR PSSESSION
#Example 1
$CMObject = New-Object -ComObject "UIResource.UIResourceMgr"
$CMCacheObjects = $CMObject.GetCacheInfo()
$CMCacheObjects.GetCacheElements()
 

#Example 2
$CacheInfoQuery = Get-WmiObject -Namespace Root\ccm\SoftMgmtAgent -Class CacheInfoEx
$CacheInfoQuery
#######################################################################################################


#######################################################################################################		
### CACHE - DISCOVERY SCRIPT - RUN REMOTELY
#Example 1
$computer = '15QNM12'
$script = {$CMObject = New-Object -ComObject "UIResource.UIResourceMgr"
$CMCacheObjects = $CMObject.GetCacheInfo()
$CMCacheObjects.GetCacheElements()
}
Invoke-Command -ComputerName $omputer -scriptblock $script


#Example 2
$computer = '15QNM12'
$CacheInfoQuery = Get-WmiObject -ComputerName $computer -Namespace Root\ccm\SoftMgmtAgent -Class CacheInfoEx
$CacheInfoQuery
#######################################################################################################	
