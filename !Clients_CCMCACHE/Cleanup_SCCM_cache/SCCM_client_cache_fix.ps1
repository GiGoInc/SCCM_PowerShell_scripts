#######################################################################################################
### DELETE ITEMS THAT ARE 60 DAYS OR OLDER
	#Connect to Resource Manager COM Object
	$resman = new-object -com "UIResource.UIResourceMgr"
	$cacheInfo = $resman.GetCacheInfo()
	#Enum Cache elements, compare date, and delete older than 60 days
	$cacheinfo.GetCacheElements()  | 
		where-object {$_.LastReferenceTime -lt (get-date).AddDays(-10)} | 
		foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}


#######################################################################################################		
### DISCOVERY SCRIPT
	$CMObject = new-object -com "UIResource.UIResourceMgr"
	$cacheInfo = $CMObject.GetCacheInfo()
	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize
	$objects


#######################################################################################################
### CLEANUP - DELETE ALL ITEMS
	#Connect to Resource Manager COM Object
	$resman = new-object -com "UIResource.UIResourceMgr"
	$cacheInfo = $resman.GetCacheInfo()
	#Enum Cache elements, compare date, and delete everything
	$cacheinfo.GetCacheElements() | foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}


#######################################################################################################
# CHECK FOR PERSISTENT CACHE ITEMS
	$A = Get-WmiObject -Namespace 'root\ccm\SoftMgmtAgent' -Query 'SELECT ContentID,Location FROM CacheInfoEx WHERE PersistInCache = 0'
	foreach ($item in $A)
	{
		$CID = $item.ContentId
		$loc = $item.location
		Write-Host "$CID`t$loc"
	}


#######################################################################################################
# ALTERNATE CLEANUP - FROM SCCM CLIENT CENTER - CLEANUP ORPHANED ITEMS
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
				Write-Host “Deleting”$Element.ContentID”with version”$Element.ContentVersion -ForegroundColor Red
				
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


#######################################################################################################
#######################################################################################################
#######################################################################################################


<#
Location                                                  CacheElementId                                                                                        ContentSize
--------                                                  --------------                                                                                        -----------
C:\Windows\ccmcache\8k                                    {004EB26A-0003-427A-A023-8A392655A5D8}                                                                       1041
C:\Windows\ccmcache\8j                                    {D44AC464-4A6E-4C04-AA9F-847153CA0C82}                                                                      45520
C:\Windows\ccmcache\8s                                    {AD710671-67C5-420F-A8E4-A8534E574CA3}                                                                      20461
C:\Windows\ccmcache\8i                                    {8F5D99AD-8E6A-4B60-AFDD-EACD8AD25334}                                                                       5839
C:\Windows\ccmcache\8l                                    {6399E6E3-B6F3-46E2-886E-096D5685D45B}                                                                      94105
C:\Windows\ccmcache\8q                                    {E505DB0A-57D3-47F2-AB69-2700AFB9F185}                                                                       7154
C:\Windows\ccmcache\8n                                    {B15300D5-470E-49CE-A850-78587772C6D1}                                                                      86349
C:\Windows\ccmcache\8u                                    {D4F89A6B-2688-4ACD-BDFB-FB404B26C376}                                                                       3514
C:\Windows\ccmcache\8h                                    {761C6BFB-7086-45CD-B976-100A4CF422CF}                                                                     100737
C:\Windows\ccmcache\8m                                    {1B8776F1-6F40-44A6-8788-20083C7977BB}                                                                      53254
C:\Windows\ccmcache\8o                                    {79AC475C-44C1-4602-9DF1-FD3883D018B6}                                                                     163428
C:\Windows\ccmcache\8r                                    {3EFF50E7-18ED-4311-A826-CBEA9A206D42}                                                                      22539
C:\Windows\ccmcache\8p                                    {E1525B60-1413-41B1-8E19-B1760B94521F}                                                                      13667

###### That is the output from the above "discovery" command, it found 13 CacheElementId(s) with non-existent Location(folders in C:\Windows\ccmcache).
###### The CCMCACHE folder was completly empty.
###### When I tried to "cleanup" them using the following script:

#Connect to Resource Manager COM Object
$resman = new-object -com "UIResource.UIResourceMgr"
$cacheInfo = $resman.GetCacheInfo()
#Enum Cache elements, compare date, and delete everything
$cacheinfo.GetCacheElements() | foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}


###### I got the following two line errors in CAS.log for each item:
CacheManager: Some contents in the folder C:\Windows\ccmcache\8s could not be deleted
Error: DeleteDirectory:- Failed to delete Directory C:\Windows\ccmcache\8i with Error 0x00000002.

###### I recreated the folders and ran the "cleanup" command again, and got the following for each item, basically it removed the item from the cache.


Removed Content ID Mapping for SS100327.2	ContentAccess	4/29/2016 2:52:25 PM	4840 (0x12E8)
CacheManager: There are currently 258957312 bytes used for cached content items (4 total, 1 active, 3 tombstoned, 0 expired).	ContentAccess	4/29/2016 2:52:25 PM	4840 (0x12E8)
CacheManager: There are currently 258957312 bytes used for cached content items (4 total, 1 active, 3 tombstoned, 0 expired).	ContentAccess	4/29/2016 2:52:25 PM	4840 (0x12E8)
Raising event:
[SMS_CodePage(437), SMS_LocaleID(1033)]
instance of SoftDistContentRemovedEvent
{
	CacheFreeSize = "4873";
	CacheTotalSize = "5120";
	ClientID = "GUID:5ECB776C-E0CB-41D8-AA32-F0249B449DA1";
	DateTime = "20160429195225.188000+000";
	MachineName = "6DJS182V2";
	PackageId = "SS100327";
	PackageName = "SS100327";
	PackageVersion = "2";
	ProcessID = 3868;
	SiteCode = "SS1";
	ThreadID = 4840;
};
	ContentAccess	4/29/2016 2:52:25 PM	4840 (0x12E8)
Successfully submitted event to the Status Agent.	ContentAccess	4/29/2016 2:52:25 PM	4840 (0x12E8)


###### When I ran the discovery script again, it was clean/empty.

#>
