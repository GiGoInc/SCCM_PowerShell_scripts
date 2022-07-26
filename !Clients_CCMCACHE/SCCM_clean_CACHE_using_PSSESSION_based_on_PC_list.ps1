$sessions = Get-Content "C:\!Powershell\!SCCM_PS_scripts\Cleanup_SCCM_cache\pc.txt" | % { New-PSSession -ComputerName $_ -ThrottleLimit 60 }

foreach($session in $sessions)
{
    Write-Host "Starting work on $session...."
    try
    {
        $ErrorActionPreference = "Stop"; #Make all errors terminating

       Invoke-Command -session $session -scriptblock {
    
		$log = 'C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log'
		#######################################################################################################		
		### Check C:\Windows\CCMCACHE folder size
		$colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
		$size = "{0:N0}" -f ($colItems.sum / 1MB)
		$total = $size -replace ',',''
		
		### DISCOVERY SCRIPT
			$CMObject = new-object -com "UIResource.UIResourceMgr"
			$cacheInfo = $CMObject.GetCacheInfo()
			$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
			$objects
			If ($objects -eq $null)
			{$count = '0'}
			Else
			{$count = $objects.Count}
		Write-Host "Found $count items in the ccmcache and $total MB used in the CCMCACHE folder"
		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Found $count items in the ccmcache and $total MB used in the CCMCACHE folder" | Add-Content $log
    
        If (($total -ne '0') -and ($count -ne '0'))
        {		
			#######################################################################################################
			### LOCAL - DELETE ALL CACHE ITEMS
			
			$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx
			If ($A -eq $Null)
			{
					Write-Host "SCCM CACHE is empty"
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
					Write-Host "Clearing $CID and $loc"
					"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Clearing $CID and $loc" | Add-Content $log
				}
			
				#######################################################################################################
				# restart SCCM service
				Restart-Service CcmExec
				Write-Host "Restarted CCMEXEC service, sleeping for 10...."
				"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Restarted CCMEXEC service, sleeping for 10...." | Add-Content $log
				start-sleep -Seconds 10
			}
        }
		ElseIf ($total -gt $count)
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
            
            Write-Host "Cleaned $Cleaned orphaned folders in CCMCACHE"
            "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Cleaned $Cleaned orphaned folders in CCMCACHE" | Add-Content $log
		}
        Else
        {
            Write-Host "$session is cleared"
        }
    }
    }catch{
        #Write-Output Caught the exception;
        #Write-Output $Error[0].Exception;
        if($_.Exception.ErrorCode -eq 0x800706BA){Write-Host "WMI_-_RPC_Server_Unavailable_-_HRESULT:_0x800706BA"}		
        ElseIf($_.Exception.ErrorCode -eq 0x80070005){Write-Host "WMI_-_Access_is_Denied_-_HRESULT:_0x80070005"}
        Else{Write-Host "WMI_error_occured"}
    }finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}


<#

ForEach ($computer in $computers)
{
    #Start-Process C:\WINDOWS\SYSWOW64\cmtrace.exe "\\$COMPUTER\C$\wINDOWS\CCM\LOGS\CAS.LOG"
    #New-PSSession -ComputerName $computer
    Enter-PSSession -ComputerName $computer
    

    $log = 'C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log'
    #######################################################################################################		
    ### Check C:\Windows\CCMCACHE folder size
    $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
    $size = "{0:N0}" -f ($colItems.sum / 1MB)
    $total = $size -replace ',',''
    
    ### DISCOVERY SCRIPT
    	$CMObject = new-object -com "UIResource.UIResourceMgr"
    	$cacheInfo = $CMObject.GetCacheInfo()
    	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
    	$objects
    	$count = $objects.Count
    Write-Host "Found $count items in the ccmcache totalling $total MB"
    "$(get-date -format MM/dd/yyy)`t*`t$(get-date -format HH:mm:ss)`t****`tFound $count items in the ccmcache totalling $total MB" | Add-Content $log
    
    
    #######################################################################################################
    ### LOCAL - DELETE ALL CACHE ITEMS
    # cacls 'C:\wINDOWS\CCMCACHE' /E /T /C /P BuiltIn\Users:F
    
    $A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx
    
    ForEach ($item in $A)
    {
        $CID = $item.CacheId
        $loc = $item.location
        Remove-Item $loc -Recurse -Force
        '\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
        Write-Host "Clearing $CID and $loc"
        "$(get-date -format MM/dd/yyy)`t*`t$(get-date -format HH:mm:ss)`t****`tClearing $CID and $loc" | Add-Content $log
    }
    
    #######################################################################################################
    # restart SCCM service
    Restart-Service CcmExec
    Write-Host "Restarted CCMEXEC service, sleeping for 10...."
    start-sleep -Seconds 10
    
    
    #######################################################################################################	
    ### Check C:\Windows\CCMCACHE folder size
    $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
    $size = "{0:N0}" -f ($colItems.sum / 1MB)
    $total = $size -replace ',',''
    	
    ### DISCOVERY SCRIPT
    	$CMObject = new-object -com "UIResource.UIResourceMgr"
    	$cacheInfo = $CMObject.GetCacheInfo()
    	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
    	$objects
    	$count = $objects.Count
    Write-Host "Found $count items in the ccmcache totalling $total MB"
    "$(get-date -format MM/dd/yyy)`t*`t$(get-date -format HH:mm:ss)`t****`tFound $count items in the ccmcache totalling $total MB" | Add-Content $log
    
    
    Exit-PSSession
}
#>