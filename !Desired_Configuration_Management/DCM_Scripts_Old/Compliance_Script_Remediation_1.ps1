If(!(Test-Path 'C:\Windows\Logs\Software')){New-Item -Path 'C:\Windows\Logs\Software' -ItemType Directory -Force}
}
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Found: $count number of items in the ccmcache and $total total space (in MB) used in the CCMCACHE folder" | Add-Content $log
If(!(Test-Path 'C:\Windows\Logs\Software')){New-Item -Path 'C:\Windows\Logs\Software' -ItemType Directory -Force}
$log = 'C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log'


#######################################################################################################		
    ### Check C:\Windows\CCMCACHE folder size
    $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
    $size = "{0:N0}" -f ($colItems.sum / 1MB)
    $foldersize = $size -replace ',',''
    
    ### DISCOVERY SCRIPT
    	$CMObject = New-Object -com "UIResource.UIResourceMgr"
    	$cacheInfo = $CMObject.GetCacheInfo()
    	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
        If ($objects -eq $null)
        {$count = '0'}
        Else
        {$count = $objects.Count}
    
If (($foldersize -eq '0') -and ($count -eq '0'))
{
    Write-Host "Compliant"
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Compliant - found $count number of items in the ccmcache and $total total space (in MB) used in the CCMCACHE folder" | Add-Content $log
}
Else
{
    Write-Host "Non-Compliant"
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Non-Compliant - found $count number of items in the ccmcache and $total total space (in MB) used in the CCMCACHE folder" | Add-Content $log


    #######################################################################################################
    ### LOCAL - DELETE ALL CACHE ITEMS
    $A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx
    ForEach ($item in $A)
    {
        $CID = $item.CacheId
        $loc = $item.location
        Remove-Item $loc -Recurse -Force
        '\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | Remove-WmiObject
        "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Clearing CacheID: $CID and folder: $loc" | Add-Content $log
    }
    
    #######################################################################################################
    # restart SCCM service
    Restart-Service CcmExec
    start-sleep -Seconds 10
    
If ($total -gt $count)
{
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
    				#Write-Host “Deleting”$Element.ContentID”with version”$Element.ContentVersion -ForegroundColor Red
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
    	
        "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Removed: $Cleaned number of orphaned folders in CCMCACHE" | Add-Content $log
        Start-Sleep -Seconds 60  
}
Else
{
        "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Remediation - No orphaned folder in CCMCACHE" | Add-Content $log
}
    
    
    #######################################################################################################	
    ### Check C:\Windows\CCMCACHE folder size
    $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
    $size = "{0:N0}" -f ($colItems.sum / 1MB)
    $total = $size -replace ',',''
    	
    ### DISCOVERY SCRIPT
    	$CMObject = new-object -com "UIResource.UIResourceMgr"
    	$cacheInfo = $CMObject.GetCacheInfo()
    	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
        If ($objects -eq $null)
        {$count = '0'}
        Else
        {$count = $objects.Count}
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Found: $count number of items in the ccmcache and $total total space (in MB) used in the CCMCACHE folder" | Add-Content $log
}
