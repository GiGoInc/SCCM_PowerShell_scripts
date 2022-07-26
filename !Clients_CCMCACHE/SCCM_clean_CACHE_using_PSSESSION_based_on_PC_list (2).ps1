 # Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path

$sessions = Get-Content "$CurrentDirectory\SCCM_clean_CACHE_using_PSSESSION_based_on_PC_list--PCList.txt" | % { New-PSSession -ComputerName $_ -ThrottleLimit 60 }


foreach($session in $sessions)
{
    $pc = $session.computername
    Write-Host ""
    Write-Host "Starting work on $pc ...."
    try
    {
        $ErrorActionPreference = "Stop";  #Make all errors terminating

       Invoke-Command -session $session -scriptblock {
        $pc = $session.computername
		$log = 'C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log'
		 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #		
         # # # # # # # # Check C:\Windows\CCMCACHE folder size
        $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse)
        $filecount = $colitems | Measure-Object -property length -sum 2>$Null
        If ($filecount -ne $Null)
        {
            $foldersize = "{0:N0}" -f ($b.sum / 1MB)
            $fc = $b.Count
             # $foldersize = $size -replace ',' , ' '
            If (($foldersize -gt '0') -and ($fc -ne '0'))
            {
                Write-Host "`tCCMCACHE folder - " -NoNewline
                Write-Host "$foldersize MB " -ForegroundColor Green -NoNewline 
                Write-Host "used and " -NoNewline
                Write-Host "$fc files " -ForegroundColor Green
				Write-Host "`t.....STUFF TO CLEAN, MAYBE?" -ForegroundColor Red
                 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #		
                 # # # # # # # # CACHE - DISCOVERY SCRIPT
                $objects = $null
                $count = $null
                	$CMObject = new-object -com "UIResource.UIResourceMgr"
                	$cacheInfo = $CMObject.GetCacheInfo()
                	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
                	If ($objects -eq $null)
                	{$count = '0'}
                	Else
                	{$count = $objects.Count}
					Write-Host "`tCross check ----- " -NoNewline 
					Write-Host "$foldersize MB " -ForegroundColor Green -NoNewline 
					Write-Host "used in CCMCACHE folder and " -NoNewline 
					Write-Host "$count items " -ForegroundColor Green -NoNewline 
					Write-Host "in INTERNAL CACHE."
                "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - There is $foldersize MB of space used in the CCMCACHE folder and there are $count items in CACHE." | Add-Content $log
            }
        }
        Else
        {
            $fc = $colitems.Count
            Write-Host ""
            Write-Host "`tCCMCACHE folder - " -NoNewline 
            Write-Host "$fc " -ForegroundColor Green -NoNewline 
            Write-Host "files in C:\Windows\CCMCACHE but size check failed, it's assumed " -NoNewline 
            Write-Host "the folders are all empty." -ForegroundColor Red
            "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $fc folders in C:\Windows\CCMCACHE but size check failed, it's assumed the folders are all empty." | Add-Content $log
        }
 # # # # # # # # CACHE - DISCOVERY SCRIPT
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
		Write-Host ""
		Write-host "`tINTERNAL DB - " -NoNewline
		Write-host "$count items " -ForegroundColor Green -NoNewline
		Write-host "in the internal SCCM client CACHE."

 # # # # # # # # CAS.log - DISCOVERY SCRIPT
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
		$s2 = $s2 -replace ';by;tes;',' bytes:'
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
		  $bytes = $s3[1].Replace(' bytes used for cached' , '')
		  $total = $s3[2].Replace(' total' , '')
		 $active = $s3[3].Replace(' active' , '')
		   $tomb = $s3[4].Replace(' tombstoned' , '')
		$expired = $s3[5].Replace(' expired' , '')
		   $date = $s3[7].Replace(' ' , '/')
		$btoMB = "{0:N0}" -f ($bytes / 1MB)

            < #
            "S3[0]"+$s3[0] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[1]"+$s3[1] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[2]"+$s3[2] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[3]"+$s3[3] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[4]"+$s3[4] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[5]"+$s3[5] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[6]"+$s3[6] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[7]"+$s3[7] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[8]"+$s3[8] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[9]"+$s3[9] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "S3[10]"+$s3[10] | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            
            "bytes - "+$bytes | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "total - "+$total | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "active - "+$active | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "tomb - "+$tomb | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "expired - "+$expired | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "date - "+$date | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
            "btoMB - "+ $btoMB | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
             #>

		Write-host "`tCAS.LOG ----- " -NoNewline
		Write-host "$btoMB MB " -ForegroundColor Green -NoNewline
		Write-host "-- " -NoNewline
		Write-host "$total total item(s)" -ForegroundColor Green -NoNewline
		Write-host "..." -NoNewline
		Write-host "$active active" -ForegroundColor Green -NoNewline
		Write-host ", " -NoNewline
		Write-host "$tomb tombstoned" -ForegroundColor Green -NoNewline
		Write-host ", and " -NoNewline
		Write-host "$expired expired " -ForegroundColor Green -NoNewline
		Write-host "item(s) in the CACHE."
	
		Write-host "`tCAS.LOG ----- " -NoNewline
		Write-host "$foldersize MB" -ForegroundColor Green -NoNewline
		Write-host " -- " -NoNewline
		Write-host "$count item(s) " -ForegroundColor Green -NoNewline
		Write-host "total in the CCMCACHE folder."
		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $count items in the CCMCACHE and $foldersize MB used in the CCMCACHE folder" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $bytes MB used by $total total item(s)...$active active, $tomb tombstoned, and $expired expired item(s) in the CACHE." | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"

		If ((($foldersize -ne '0') -and ($count -eq '0')) -or (($fc -ne '0') -and ($foldersize -eq '0')))
		{
			Write-Host ""
			Write-Host "`tThere is data in the C:\Windows\CCMCACHE folder but nothing in CACHE..."
			Write-Host "`tOR"
			Write-Host "`tthere are folders in C:\Windows\CCMCACHE folder but they are all zero bytes."
			Write-Host ""
			Write-Host "We need to cleanup the orphaned folders" -ForegroundColor Green
			Write-Host ""
			Write-Host ""
		}
		If (($foldersize -ne '0') -and ($bytes -ne '0'))
		{
			Write-Host "`tCCMCACHE - There is data in the C:\Windows\CCMCACHE folder and there are items in CACHE"
			Write-Host "`tWe need to cleanup both." -ForegroundColor Green
			Write-Host ""
			Write-Host ""
		}

 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
     # # # CLEANUP BOTH
        If (($total -ne '0') -and ($count -ne '0'))
        {
			 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
			 # # # LOCAL - DELETE ALL CACHE ITEMS
            Write-Host "`tDeleting all CACHE items..." -ForegroundColor Red

			$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx
			If ($A -eq $Null)
			{
					Write-Host "`tSCCM CACHE is empty"
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
					 # Write-Host "`tClearing $CID and $loc"
					"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Clearing $CID and $loc" | Add-Content $log
				}
			
				 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
				 # Restart SCCM service
                Write-Host "`tRestarting CCMEXEC service, sleeping for 10...." -ForegroundColor Red
				Restart-Service CcmExec

				"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Restarted CCMEXEC service, sleeping for 10...." | Add-Content $log
				start-sleep -Seconds 10
                Write-Host "`tRestarted CCMEXEC service...." -ForegroundColor Green
			}
        }
		ElseIf ($total -gt $count)
        {
             # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
             # ALTERNATE CLEANUP - FROM SCCM CLIENT CENTER - CLEANUP ORPHANED ITEMS
            Write-Host "`tCleaning up Orphaned folder only..." -ForegroundColor Red

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
            			 # Write-Host "Deleting"$Element.ContentID"with version"$Element.ContentVersion -ForegroundColor Red
            			
            			Remove-Item $Element.Location -Recurse -Force
            			$Element.Delete()
            			$Cleaned++
            		}
            	}
            }
             # Cleanup Orphaned Folders in ccmcache
            $UsedFolders = $CacheElements | % { Select-Object -inputobject $_.Location }
            [string]$CCMCache = ([wmi]"ROOT\ccm\SoftMgmtAgent:CacheConfig.ConfigKey='Cache'").Location
            if($CCMCache.EndsWith('ccmcache'))
            {
            	Get-ChildItem($CCMCache) |  ?{ $_.PSIsContainer } | WHERE { $UsedFolders -notcontains $_.FullName } | % { Remove-Item $_.FullName -recurse ; $Cleaned++ }
            }
				 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
				 # restart SCCM service
                Write-Host "`tRestarting CCMEXEC service, sleeping for 10...." -ForegroundColor Red
				Restart-Service CcmExec

				"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Restarted CCMEXEC service, sleeping for 10...." | Add-Content $log
				start-sleep -Seconds 10
                Write-Host "`tRestarted CCMEXEC service...." -ForegroundColor Green

                Write-Host "`tCleaned $Cleaned orphaned folders in CCMCACHE"
                "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Cleaned $Cleaned orphaned folders in CCMCACHE" | Add-Content $log
		}
        Else
        {
            Write-Host "Sessionname $session is cleared"
        }

     # # # # # # # # CACHE - DISCOVERY SCRIPT
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
    Write-Host ""
    Write-Host "Final Check " -NoNewline -ForegroundColor Yellow
    Write-Host " - There are now " -NoNewline
    Write-host "$count items " -ForegroundColor Green -NoNewline
    Write-host "in the internal SCCM client CACHE." -NoNewline


     # # # # # # # # CAS.log - DISCOVERY SCRIPT
    start-sleep -Seconds 3
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
		$s2 = $s2 -replace ';by;tes;',' bytes:'
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
		$btoMB = "{0:N0}" -f ($bytes / 1MB)

		Write-host "`tCAS.LOG ----- " -NoNewline
		Write-host "$btoMB MB " -ForegroundColor Green -NoNewline
		Write-host "-- " -NoNewline
		Write-host "$total total item(s)" -ForegroundColor Green -NoNewline
		Write-host "..." -NoNewline
		Write-host "$active active" -ForegroundColor Green -NoNewline
		Write-host ", " -NoNewline
		Write-host "$tomb tombstoned" -ForegroundColor Green -NoNewline
		Write-host ", and " -NoNewline
		Write-host "$expired expired " -ForegroundColor Green -NoNewline
		Write-host "item(s) in the CACHE."
	
		Write-host "`tCAS.LOG ----- " -NoNewline
		Write-host "$foldersize MB" -ForegroundColor Green -NoNewline
		Write-host " -- " -NoNewline
		Write-host "$count item(s) " -ForegroundColor Green -NoNewline
		Write-host "total in the CCMCACHE folder."
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $count items in the CCMCACHE and $foldersize MB used in the CCMCACHE folder" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $bytes MB used by $total total item(s)...$active active, $tomb tombstoned, and $expired expired item(s) in the CACHE." | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
    }
    }catch{
         #Write-Output Caught the exception;
         #Write-Output $Error[0].Exception;
        if($_.Exception.ErrorCode -eq 0x800706BA){Write-Host "`tWMI_-_RPC_Server_Unavailable_-_HRESULT:_0x800706BA"}		
        ElseIf($_.Exception.ErrorCode -eq 0x80070005){Write-Host "`tWMI_-_Access_is_Denied_-_HRESULT:_0x80070005"}
        Else{Write-Host "`tWMI_error_occured"}
    }finally{
        $ErrorActionPreference = "Continue";  #Reset the error action pref to default
    }
}

Write-host ""
 # SIG  # Begin signature block
 # MIIL1wYJKoZIhvcNAQcCoIILyDCCC8QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
 # gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
 # AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtggPqNmJASI2KTaJZRudpuXM
 # 4yGgggk4MIIESzCCAzOgAwIBAgITYAAAAALo5xr3zuIi5wAAAAAAAjANBgkqhkiG
 # 9w0BAQsFADBNMRMwEQYKCZImiZPyLGQBGRYDaGhjMRowGAYKCZImiZPyLGQBGRYK
 # bGlnaHRob3VzZTEaMBgGA1UEAxMRSGFuY29ja0hvbGRpbmctQ0EwCOMNMTUwNzA2
 # MDAzODU3WhcNMTgwNzA2MDA0ODU3WjBRMRMwEQYKCZImiZPyLGQBGRYDaGhjMRow
 # GAYKCZImiZPyLGQBGRYKTGlnaHRob3VzZTEeMBwGA1UEAxMVTGlnaHRob3VzZS1J
 # c3N1aW5nLUNBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvOCM8Abe
 # vAuzzTJ2MhJF6qvHhe+JSsHI7Vgccd08sxJx+eNhLpKD0uoKWtm46p1v+UAOCmkn
 # 3YpFY5wa+3Mes0qN8VFPVwP5X0Yt+LSFTDfe1isep1IvRE0yLS+pGRpBjfxGNaTo
 # fSAgen59febWONZMhruaZj+mTtWnTAyG3GVx9vc+IsCy6tzCKnI5y8wHbhzXJWkg
 # tDyNCKezKG0kQNwFsIkFD5ct8B/t+usXslRn6dwsl6+XyGOBUzN+JeAa6d+hTkGd
 # wDI6ettJKAhObVt43yAKrS2Sp5jK8jYr3Chd4ihY07AJiNKZY3Viyee8LhYwFGBs
 # YTwn7D7oMBPGzQIDAQABo4IBHjCCARowEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0O
 # BBYEFLabqenPYAe4WPfQgCgAJSFgNJJEMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIA
 # QwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFEsg
 # CoPhlYMO3GmKgcWFEiYtcIeUMEAGA1UdHwQ5MDcwNaAzoDGGL2h0dHA6Ly9wa2ku
 # bGlnaHRob3VzZS5oaGMvSGFuY29ja0hvbGRpbmctQ0EuY3JsMEsGCCsGAQUFBwEB
 # BD8wPTA7BggrBgEFBQcwAoYvaHR0cDovL3BraS5saWdodGhvdXNlLmhoYy9IYW5j
 # b2NrSG9sZGluZy1DQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAGk6JuBNfWgfDjKd
 # fgFafQQ7Ztc2YnoIPhLwB9+F7lgtslRw/gpffFASoUsnfTcAjtlnuJ6h//UmdD64
 # r1gOSp5pfGBsEXYYArgG8HuIo/QSgN4KAwVF0xfAMxg1n3fMgJiIvs1vDt6d8yq4
 # z85Mm/zj65un4l+LH3aD0JDtFDfa1bVSONQWRpsPtnP8vP3cwM74+UKJMeoGrn3b
 # Yi2/2SLvE6nJKZ4jApWC/Rbk+Ak1QqJua1hIDR8JD7qKiN6cNhmUf5dUyCGUnQzJ
 # Q8RR69JgnhidKRRj91b92WV6rK8agCto3J//1dPXxHsdSue2hOhCsX79sVEjHtTY
 # 3zrNHlIwggTlMIIDzaADAgECAhM5AABHOi79c75LLPyQAAAAAEc6MA0GCSqGSIb3
 # DQEBCwUAMFExEzARBgoJkiaJk/IsZAEZFgNoaGMxGjAYBgoJkiaJk/IsZAEZFgpM
 # aWdodGhvdXNlMR4wHAYDVQQDExVMaWdodGhvdXNlLUlzc3VpbmctQ0EwCOMNMTYw
 # NTIwMjAzMDQ5WhcNMTgwNTIwMjA0MDQ5WjB5MRMwEQYKCZImiZPyLGQBGRYDaGhj
 # MRowGAYKCZImiZPyLGQBGRYKTGlnaHRob3VzZTEVMBMGA1UECxMMRG9tYWluIFVz
 # ZXJzMRQwEgYDVQQLEwtUUyBBY2NvdW50czEZMBcGA1UEAxMQTGFjYXlvLCBJc2Fh
 # YyBUUzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK0veyKOJyfC/+nO
 # mB6ljyJCGe/WSOJ5qjB/8ISbkJ3mKeI5HxlJT0AFJDShF4yHlDYWkJ+9pSXmg4xW
 # FeMKVD0lTqu2pmCVe986QZbyaxFSPc4oi5G+VYMaaNUFUbpkCFIbr2bqrg8d6l5j
 # pbH0ttw0autvg/+JZjRDBtY2vlXzLishErUupkRr6xVGWQgtqkXP1A/8yjGMM0V1
 # 3Cyzzcz1FckN1/uEUY1lHmpllG2Mrey8yOf7RYKsycSv1R59EMw9FZswVXp0OQwV
 # X4aLa/ZKukm5FdejHq8Hxh36JAPzdi/6E0XJnAWem0EOzncMMBU7vzYF02k/w20V
 # VKMRhQcCAwEAAaOCAYwwggGIMAsGA1UdDwQEAwIHgDA8BgkrBgEEAYI3FQcELzAt
 # BiUrBgEEAYI3FQiGqYN3hPWSRK2DH4P5wySGrNM4WoTuuHCEndtCAgFkAgECMB0G
 # A1UdDgQWBBRQD9TQh0w/6+zEtE1Ck8qpPhgGVDAfBgNVHSMEGDAWgBS2m6npz2AH
 # uFj30IAoACUhYDSSRDBEBgNVHR8EPTA7MDmgN6A1hjNodHRwOi8vcGtpLmxpZ2h0
 # aG91c2UuaGhjL0xpZ2h0aG91c2UtSXNzdWluZy1DQS5jcmwwTwYIKwYBBQUHAQEE
 # QzBBMD8GCCsGAQUFBzAChjNodHRwOi8vcGtpLmxpZ2h0aG91c2UuaGhjL2xpZ2h0
 # aG91c2UtaXNzdWluZy1jYS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYJKwYB
 # BAGCNxUKBA4wDDAKBggrBgEFBQcDAzAyBgNVHREEKzApoCcGCisGAQQBgjcUAgOg
 # GQwXVFMwMTAzODhATGlnaHRob3VzZS5oaGMwDQYJKoZIhvcNAQELBQADggEBACKb
 # nE2IKJXqnPcAmYcXdCnjVHjOwNCescgAsUhrCzS9UCk5KIcT6nqQNu48SoaT+RL+
 # xdoDbfpL/walrDLoLK3O976kdslhosNQ3y3QUo8U86UwA4ERuzTxcQZ8kBjdzj9Y
 # 4xChQYJwrMWiIinzSFakaKOw06QOrvWIOhDha0/ajiI8B3Lgc5lmH9jOVcDIO3Yv
 # fVy2avQlvnacREhPDbWzNU/SgcN8hFR4zeZ0nq9VlPmZIrKdzEYuyLkSRzeDa52w
 # moMlWDCH4sjR4h+WOy2ywLS/yp2ucgDvtWktKplHxD0+IM4U4KivuU9WTGdH023U
 # PXBV8slOxdyt7zFb36UxggIJMIICBQIBATBoMFExEzARBgoJkiaJk/IsZAEZFgNo
 # aGMxGjAYBgoJkiaJk/IsZAEZFgpMaWdodGhvdXNlMR4wHAYDVQQDExVMaWdodGhv
 # dXNlLUlzc3VpbmctQ0ECEzkAAEc6Lv1zvkss/JAAAAAARzowCQYFKw4DAhoFAKB4
 # MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQB
 # gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkE
 # MRYEFDPH6IfxZ/NQOBdfugONfZOeD/sxMA0GCSqGSIb3DQEBAQUABIIBAAAGJxSp
 # zOZmofSFEnYX8fsayE7Bmhjh38JVbP090IVqfIXUAFYtovITj6lXX3R7oEkIP6lp
 # raZVdfzDd7fRDEO/Pp7aeUxh2nmF4/9sWQrKIMGXwLeQKuCPksf9f5UiKXig+yMf
 # L+J59vL4/Zf8+UPFXEnSX/VmbSdxlTdoDjfJph1N5WWVTVQXDK+yXStNTpEdLMBz
 # gsXiuMLxUz5gdmeSQ4t9psch3r0TL0jcZ/F0K4BQ1KCLCHZF9oW2RqDPZldxAntz
 # G7cfhljnagIPlyLlyOOf19xLsFAOOVpE3QEqx3hvRt6i+zhuVkeYN0wNr4JsIMXE
 # 40SOtcm2bNCtOUY=
 # SIG  # End signature block
