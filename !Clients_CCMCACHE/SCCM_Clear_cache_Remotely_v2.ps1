$computer = '1NLML12'
Exit-PSSession

$computer = '1NLML12'

Start-Process C:\WINDOWS\SYSWOW64\cmtrace.exe "\\$COMPUTER\C$\wINDOWS\CCM\LOGS\CAS.LOG"

New-PSSession -ComputerName $computer
Enter-PSSession -ComputerName $computer


#######################################################################################################		
### DISCOVERY SCRIPT
	$CMObject = new-object -com "UIResource.UIResourceMgr"
	$cacheInfo = $CMObject.GetCacheInfo()
	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
	$objects
	$objects.Count



#######################################################################################################
### CLEANUP - DELETE ALL ITEMS
	#Connect to Resource Manager COM Object
	$CMObject = new-object -com "UIResource.UIResourceMgr"
	$cacheInfo = $CMObject.GetCacheInfo()
	#Enum Cache elements and delete everything
	$cacheinfo.GetCacheElements() | foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}



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
### LOCAL - DELETE ALL CACHE ITEMS
cacls 'C:\wINDOWS\CCMCACHE' /E /T /C /P BuiltIn\Users:F

$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx

ForEach ($item in $A)
{
    $CID = $item.cacheid
    $loc = $item.location
    [wmi]'\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
    #Remove-Item $loc -Recurse -Force
    Write-Host "Clearing $loc"
}




#######################################################################################################
### LOCAL - DELETE ALL CACHE ITEMS
# cacls 'C:\wINDOWS\CCMCACHE' /E /T /C /P BuiltIn\Users:F

$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx

ForEach ($item in $A)
{
    $CID = $item.cacheid
    $loc = $item.location
    Remove-Item $loc -Recurse -Force
    [wmi]'\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
    Write-Host "Clearing $loc"
}

#####
Remove-Item "C:\Windows\ccmcache\1d" -recurse
 [wmi]'ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId="3d614ec7-4a8d-42a7-ac3b-5831be6bb0c2"' | remove-wmiobject
 Remove-Item "C:\Windows\ccmcache\v" -recurse
 [wmi]'ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId="1ab0ef3e-89ab-4243-ab5a-d58810aed07d"' | remove-wmiobject


Exit-PSSession
