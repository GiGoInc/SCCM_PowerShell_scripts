If(!(Test-Path 'C:\Windows\Logs\Software')){New-Item -Path 'C:\Windows\Logs\Software' -ItemType Directory -Force}
}
        }
If(!(Test-Path 'C:\Windows\Logs\Software')){New-Item -Path 'C:\Windows\Logs\Software' -ItemType Directory -Force}
$log = 'C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log'


#######################################################################################################		
    ### C:\Windows\CCMCACHE - DISCOVERY SCRIPT
    $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
    $size = "{0:N0}" -f ($colItems.sum / 1MB)
    $foldersize = $size -replace ',' , ' '
    #Write-host "There is $foldersize space used in the CCMCACHE folder."
    
    ### CACHE - DISCOVERY SCRIPT
    $objects = $null
      $count = $null
    	$CMObject = new-object -com "UIResource.UIResourceMgr"
    	$cacheInfo = $CMObject.GetCacheInfo()
    	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
        $count = $objects.Count
    	If ($count -eq $null)
    	{$count = '0'}
    	Else
    	{$count = $objects.Count}
        #Write-host "There are $count items in CACHE."
    
    ### CAS.log - DISCOVERY SCRIPT
    # Extracting line from CAS.log that DISCOVERY script just found
      $Line = Select-String -Path "C:\Windows\CCM\logs\CAS.log" -pattern 'CacheManager: There are currently'
      $lastline = $line[-1]
      $s1 = $lastline | out-string
      $s2 = $s1 -replace '[^\p{L}\p{Nd}]' , ';'
      $s2 = $s2 -replace ';;;' , ';'
      $s2 = $s2 -replace ';;' , ';'
      $s2 = $s2 -replace ';;' , ';'
      $s2 = $s2 -replace ';;' , ';'
      $s2 = $s2.TrimStart(';').replace(';C;Windows',':')
      $s2 = $s2 -replace 'There;are;currently;' , ':'
      $s2 = $s2 -replace ';bytes;',' bytes:'
      $s2 = $s2 -replace 'content;items;' , ':'
      $s2 = $s2 -replace ';total;' , ' total:'
      $s2 = $s2 -replace ';active;' , ' active:'
      $s2 = $s2 -replace ';tombstoned;' , ' tombstoned:'
      $s2 = $s2 -replace ';expired;' , ' expired:'
      $s2 = $s2 -replace ';date;' , ' date:'
      $s2 = $s2 -replace ';component' , ':component'
      $s2 = $s2 -replace ' ;' , ';'
      $s2 = $s2 -replace '; ' , ';'
      $s2 = $s2 -replace ';' , ' '
      $s2 = $s2 -replace ': ' , ':'
      $s2 = $s2 -replace ' :' , ':'
      $s3 = $s2.split(':')
    
      $bytes = $s3[1].Replace(' bytes' , '')
      $total = $s3[3].Replace(' total' , '')
     $active = $s3[4].Replace(' active' , '')
       $tomb = $s3[5].Replace(' tombstoned' , '')
    $expired = $s3[6].Replace(' expired' , '')
       $date = $s3[8].Replace(' ' , '/')

    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $count items in the ccmcache and $foldersize MB used in the CCMCACHE folder" | Add-Content $log
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $bytes bytes used by $total total item(s)...$active active, $tomb tombstoned, and $expired expired item(s) in the cache." | Add-Content $log
 



If (($foldersize -eq '0') -and ($bytes -eq '0')){
    Write-Host "Compliant"
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Compliant - found $count number of items in the ccmcache and $total total space (in MB) used in the CCMCACHE folder" | Add-Content $log
}
ElseIf (($foldersize -ne '0') -and ($bytes -ne '0'))
{
    Write-Host "Non-Compliant"
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Non-Compliant - found $count number of items in the ccmcache and $total total space (in MB) used in the CCMCACHE folder" | Add-Content $log
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Remediation - Non-Compliant - There is data in the C:\Windows\CCMCACHE folder and items in CACHE, so we need to cleanup both." | Add-Content $log

    #######################################################################################################
    ### LOCAL - DELETE ALL CACHE ITEMS
        # Some Active, some Tombstoned, and some Expired
        If (($total -ne '0') -and ($count -ne '0')){		
        	$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx
        	If ($A -eq $Null)
        	{
        			#Write-Host "SCCM CACHE is empty"
        			"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   SCCM Cache is empty" | Add-Content $log    
        	}
        	Else
        	{
        		ForEach ($item in $A)
        		{
        			$CID = $item.CacheId
        			$loc = $item.location
        			Remove-Item $loc -Recurse -Force
        			'\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
        			#Write-Host "Clearing $CID and $loc"
        			"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Clearing $CID and $loc" | Add-Content $log
                    start-sleep -milliseconds 500
        		}
        	
        		#######################################################################################################
        		# restart SCCM service
        		Restart-Service CcmExec
        		#Write-Host "Restarted CCMEXEC service, sleeping for 120...."
        		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Restarted CCMEXEC service, sleeping for 120 seconds...." | Add-Content $log
        		start-sleep -Seconds 120
        	}
        }
        Else
        {
            #Write-Host "No folders in CCMCACHE and no CACHE items in client CACHE"
            "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   No orphaned folders in CCMCACHE" | Add-Content $log
        }
}
ElseIf (($foldersize -ne '0') -and ($bytes -eq '0')){
    Write-Host "Non-Compliant"
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Remediation - Non-Compliant - found $count number of items in the ccmcache and $total total space (in MB) used in the CCMCACHE folder" | Add-Content $log
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Remediation - Non-Compliant - There is data in the C:\Windows\CCMCACHE folder but nothing in CACHE, so we need to cleanup the orphaned folders" | Add-Content $log


    # Orphaned folders - Found space used in CCMCACHE and ZERO items in CACHE
        If (($foldersize -ne '0') -and ($count -eq '0')){	
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
        						"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Deleting $Element.ContentID with version $Element.ContentVersion" | Add-Content $log
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
        			
        			#Write-Host "Cleaned $Cleaned orphaned folders in CCMCACHE"
        			"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Cleaned $Cleaned orphaned folders in CCMCACHE" | Add-Content $log
        }
        Else{
        		#Write-Host "No orphaned folder in CCMCACHE"
        		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   No orphaned folders in CCMCACHE" | Add-Content $log
        }
}
