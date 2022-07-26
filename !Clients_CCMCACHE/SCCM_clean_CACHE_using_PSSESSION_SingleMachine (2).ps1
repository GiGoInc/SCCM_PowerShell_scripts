< #
CACHE - means CACHE that SCCM client sees in internally
CCMCACHE - the 'C:\Windows\CCMCACHE' folder

Issues I've seen:
1) CACHE has items taking up space that are not physically in the CCMCACHE folder.
        This means that the some cleanup tasks won't remove these items as they don't show up internally and the CCMCACHE 
        is using space that the CACHE doesn't see internally to remove.
        Worst case - SCCM thinks there is no space in the CCMCACHE folder to apply installs.
        Error in CAS.log - "Not enough space in Cache"
2) CCMCACHE has folders that are not in the CACHE 
        This means that there are folders in the 'C:\Windows\CCMCACHE' folder that don't exist in the CACHE to be remediated/removed
        Worst case - SCCM will never clean the CCMCACHE folder completely, so there is always data in the folder taking up hard drive space
        Error in CAS.log - Log shows that the CACHE is clean, but there is still space being used on hard drive
3) CCMCACHE has folders but $foldersize is zero
        This means that there are folders in the 'C:\Windows\CCMCACHE' folder that may have only have temp files in that are zero bytes.
        Worst case - SCCM will never clean the CCMCACHE folder completely, so there is always some folders that accumulate but have no space in them
        Error in CAS.log - Log shows that the CACHE is clean, but there is still space being used on hard drive

LARELT01
MSRELT04
BH20B42
F7QL32
H9HTP12


------------------------------------
psexec \\H9HTP12 -h -d powershell.exe "enable-psremoting -force"
psexec \\H9HTP12 -s winrm.cmd quickconfig -q
pause
-------------------
psexec \\F7QL32 cmd
powershell.exe "enable-psremoting -force"
winrm.cmd quickconfig -q
net stop WinRM
net start WinRM
exit
------------------------------------ #>


$ErrorActionPreference = "Stop"
$errorCode = $null

$computer = '425FX12'

Try{New-PSSession -ComputerName $computer
     # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #		
     # # # Get logs
    Start-Process C:\WINDOWS\SYSWOW64\cmtrace.exe "\\$COMPUTER\C$\Windows\CCM\LOGS\CAS.LOG"
    Start-Process explorer.exe "\\$COMPUTER\C$\Windows\CCMCACHE"
    If(!(Test-Path "\\$COMPUTER\C$\Windows\Logs\Software")){New-Item -Path "\\$COMPUTER\C$\Windows\Logs\Software" -ItemType Directory -Force}
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Start SCCM_clean_CACHE_using_PSSESSION_SingleMachine" | Add-Content "\\$COMPUTER\C$\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
    Start-Process C:\WINDOWS\SYSWOW64\cmtrace.exe "\\$COMPUTER\C$\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
     # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #	
     # # # Start PSSESSION
    Enter-PSSession -ComputerName $computer
    start-sleep -Seconds 5
    Write-Host "In Session...."
}Catch{
    If ($errorcode -ne 0){
        $es = [string]$error[0]
        If ($es -like "*The client cannot connect to the destination specified in the request*"){
            Write-Host ""
            Write-Host ""
            Write-Host "$Computer"  -ForegroundColor green  -nonewline
            Write-Host " - WINRM IS INACCESSIBLE" -ForegroundColor Red
        }}}
Finally{$ErrorActionPreference = "Continue"}
 # # # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  # # #
 # # # STEP 1 IS EVERYTHING ABOVE THIS COMMENT BLOCK  # # #
 # # # STEP 1 IS EVERYTHING ABOVE THIS COMMENT BLOCK  # # #
 # # # STEP 1 IS EVERYTHING ABOVE THIS COMMENT BLOCK  # # #
 # # # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  # # #



 # # # vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv  # # #
 # # # STEP 2 IS EVERYTHING BELOW THIS COMMENT BLOCK  # # #
 # # # STEP 2 IS EVERYTHING BELOW THIS COMMENT BLOCK  # # #
 # # # STEP 2 IS EVERYTHING BELOW THIS COMMENT BLOCK  # # #
 # # # vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv  # # #
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #	
 # # # # # # # # C:\Windows\CCMCACHE - DISCOVERY SCRIPT
    $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse)
    $filecount = $colitems | Measure-Object -property length -sum 2>$Null
    If ($filecount -ne $Null)
    {
        $foldersize = "{0:N0}" -f ($filecount.sum / 1MB)
        $fc = $filecount.Count
        If (($foldersize -gt '0') -and ($fc -ne '0'))
        {
            Write-Host "" -NoNewline
            Write-Host "CCMCACHE folder - " -NoNewline
            Write-Host "$foldersize MB " -ForegroundColor Green -NoNewline 
            Write-Host "used and " -NoNewline
            Write-Host "$fc files " -ForegroundColor Green

             #Write-Host ".....STUFF TO CLEAN, MAYBE?" -ForegroundColor Red



             # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #		
             # # # # # # # # Check C:\Windows\CCMCACHE folder size
            $objects = $null
              $count = $null
            	$CMObject = new-object -com "UIResource.UIResourceMgr"
            	$cacheInfo = $CMObject.GetCacheInfo()
            	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
            	If ($objects -eq $null)
            	{$count = '0'}
            	Else
            	{$count = $objects.Count}
                Write-Host "Cross check ----- " -NoNewline 
                Write-Host "$foldersize MB " -ForegroundColor Green -NoNewline 
                Write-Host "used in CCMCACHE folder and " -NoNewline 
                Write-Host "$count items " -ForegroundColor Green -NoNewline 
                Write-Host "in INTERNAL CACHE."
            "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - There is $foldersize megabytes of space used in the CCMCACHE folder and there are $count items in CACHE." | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
        }
    }
    Else
    {
        $fc = $colitems.Count
            Write-Host "CCMCACHE folder - " -NoNewline 
            Write-Host "$fc " -ForegroundColor Green -NoNewline 
            Write-Host "files in C:\Windows\CCMCACHE but size check failed, it's assumed " -NoNewline 
            Write-Host "the folders are all empty." -ForegroundColor Red
            "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $fc folders in C:\Windows\CCMCACHE but size check failed, it's assumed the folders are all empty." | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
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
    Write-host "INTERNAL DB ----- " -NoNewline
    Write-host "$count items " -ForegroundColor Green -NoNewline
    Write-host "in the internal SCCM client CACHE." -NoNewline

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
      $bytes = $s3[1].Replace(' bytes' , '')
      $total = $s3[3].Replace(' total' , '')
     $active = $s3[4].Replace(' active' , '')
       $tomb = $s3[5].Replace(' tombstoned' , '')
    $expired = $s3[6].Replace(' expired' , '')
       $date = $s3[8].Replace(' ' , '/')
       $btoMB = "{0:N0}" -f ($bytes / 1MB)

    Write-Host ""
    Write-host "CAS.LOG --------- " -NoNewline
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

    Write-host "CAS.LOG --------- " -NoNewline
    Write-host "$foldersize MB" -ForegroundColor Green -NoNewline
    Write-host " -- " -NoNewline
    Write-host "$count item(s) " -ForegroundColor Green -NoNewline
    Write-host "total in the CCMCACHE folder."
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $count items in the CCMCACHE and $foldersize MB used in the CCMCACHE folder" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Intial Discovery - Found $btoMB megabytes used by $total total item(s)...$active active, $tomb tombstoned, and $expired expired item(s) in the CACHE." | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"

    If ((($foldersize -ne '0') -and ($count -eq '0')) -or (($fc -ne '0') -and ($foldersize -eq '0')))
    {
        Write-Host ""
        Write-Host "CCMCACHE - There is data in the C:\Windows\CCMCACHE folder but nothing in CACHE..."
        Write-Host "OR"
        Write-Host "there are folders in C:\Windows\CCMCACHE folder but they are all zero bytes."
        Write-Host ""
        Write-Host "We need to cleanup the orphaned folders" -ForegroundColor Green
        Write-Host ""
        Write-Host ""
    }
    If (($foldersize -ne '0') -and ($bytes -ne '0'))
    {
        Write-Host "CCMCACHE - There is data in the C:\Windows\CCMCACHE folder and there are items in CACHE"
        Write-Host "We need to cleanup both." -ForegroundColor Green
        Write-Host ""
        Write-Host ""
    }

 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
     # # # CLEANUP BOTH
         # Some Active, some Tombstoned, and some Expired
        If (($total -ne '0') -and ($count -ne '0'))
        {		
        	$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx
        	If ($A -eq $Null)
        	{
        			Write-Host "SCCM CACHE is empty"
        			"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   SCCM Cache is empty" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"    
        	}
        	Else
        	{
        		ForEach ($item in $A)
        		{
        			$CID = $item.CacheId
        			$loc = $item.location
        			Remove-Item $loc -Recurse -Force 2>$Null
        			'\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
        			Write-Host "Clearing $CID and $loc"
        			"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Clearing $CID and $loc" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
                    start-sleep -milliseconds 500
        		}
        	
        		 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
        		 # restart SCCM service
        		Restart-Service CcmExec
        		Write-Host "Restarted CCMEXEC service, sleeping for 10...."
        		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Restarted CCMEXEC service, sleeping for 10 seconds...." | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
        		start-sleep -Seconds 10
        		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Done restarting CCMEXEC service...." | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
        	}
        }
        Else{
        		Write-Host "No folders in CCMCACHE and no CACHE items in client CACHE"
        		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   No orphaned folders in CCMCACHE" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
        }
   # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
     # # # CLEANUP ORPHANED FOLDERS
        If ((($foldersize -ne '0') -and ($count -eq '0')) -or (($fc -ne '0') -and ($foldersize -eq '0'))) {	
        		 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
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
        						
        						Remove-Item $Element.Location -recurse -Force
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
        				Get-ChildItem($CCMCache) |  ?{ $_.PSIsContainer } | WHERE { $UsedFolders -notcontains $_.FullName } | % { Remove-Item $_.FullName -recurse -force; $Cleaned++ }
        			}
        			
        			Write-Host "Cleaned $Cleaned orphaned folders in CCMCACHE" -ForegroundColor Red
        			"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Cleaned $Cleaned orphaned folders in CCMCACHE" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
        }
        Else{
        		Write-Host "No orphaned folder in CCMCACHE" -ForegroundColor Green
        		"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   No orphaned folders in CCMCACHE" | Add-Content "C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
        }
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
     # # # Check C:\Windows\CCMCACHE folder size
    $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse)
    $b = $colitems | Measure-Object -property length -sum 2>$Null
    If ($b -ne $Null)
    {
        Write-Host "CollItems not Null"
        $size = "{0:N0}" -f ($b.sum / 1MB)
        $fc = $b.Count
        $foldersize = $size -replace ',' , ' '
        If (($size -gt '0') -and ($fc -ne '0'))
        {
            Write-Host "Stuff to clean, maybe?" -ForegroundColor Green
             # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #		
             # # # CACHE - DISCOVERY SCRIPT
            $objects = $null
              $count = $null
            	$CMObject = new-object -com "UIResource.UIResourceMgr"
            	$cacheInfo = $CMObject.GetCacheInfo()
            	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
            	If ($count -eq $null)
            	{$count = '0'}
            	Else
            	{$count = $objects.Count}
            Write-host "There is $foldersize megabytes of space used in the CCMCACHE folder and there are $count items in CACHE."
        }
    }
    Else
    {
        $fc = $colitems.Count
        Write-Host ""
        Write-Host "Found $fc folders in C:\Windows\CCMCACHE but size check failed, it's assumed the folders are all empty." -ForegroundColor Green
    }

Exit-PSSession
 # SIG  # Begin signature block
 # MIIL1wYJKoZIhvcNAQcCoIILyDCCC8QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
 # gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
 # AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqIWZ7YDo4sBSuMsNWnmKXykw
 # QwKgggk4MIIESzCCAzOgAwIBAgITYAAAAALo5xr3zuIi5wAAAAAAAjANBgkqhkiG
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
 # MRYEFKUW87Hg/WgagYENnTdEVXSQgQ20MA0GCSqGSIb3DQEBAQUABIIBABIjYW14
 # nkfF1hlC8OvTzxJp6A45BU3EYOQBkmanOqhKFYQW6zt0J3tfBVgkT+tmPJ0EbEJ4
 # RmjL3g3uTsUx+wkmAGxQrQTRZYE9tRxZU7SD81xaOfqnxXjMAatwCt4amMiy73bj
 # cuGk/yW3auS5FXfihM7aEH2u7wOilqPVuUYceSuPSaegVn/azGs6ianmcFNeugtK
 # eq4PMvzMo1nOwJSyyHaBgTiliaWqIEznbsPm6tE68BoCijxziuVUyyZryhGfLeZw
 # RN0IJUEZZFrhda2AM/CnfSox3P5bZygEcy829afAwXR2L4rn2Fr4gbI7mk1FpCiu
 # RQx/1nKwRWcn6Bo=
 # SIG  # End signature block
