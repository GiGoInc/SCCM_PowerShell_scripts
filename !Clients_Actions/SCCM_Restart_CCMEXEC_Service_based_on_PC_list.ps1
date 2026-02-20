$sessions = Get-Content "C:\!Powershell\!SCCM_PS_scripts\Cleanup_SCCM_cache\SCCM_clean_CACHE_using_PSSESSION_based_on_PC_list--PCList.txt" | % { New-PSSession -ComputerName $_ -ThrottleLimit 60 }
Write-host ""

$sessions = Get-Content "C:\!Powershell\!SCCM_PS_scripts\Cleanup_SCCM_cache\SCCM_clean_CACHE_using_PSSESSION_based_on_PC_list--PCList.txt" | % { New-PSSession -ComputerName $_ -ThrottleLimit 60 }


foreach($session in $sessions)
{
    $pc = $session.computername
    Write-Host ""
    Write-Host "Starting work on $pc ...."
    try
    {
        $ErrorActionPreference = "Stop"; #Make all errors terminating

       Invoke-Command -session $session -scriptblock {
        $pc = $session.computername
		$log = 'C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log'
		#######################################################################################################		
        ######## Check C:\Windows\CCMCACHE folder size
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
                #######################################################################################################		
                ######## CACHE - DISCOVERY SCRIPT
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
######## CACHE - DISCOVERY SCRIPT
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

######## CAS.log - DISCOVERY SCRIPT
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

            <#
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


    #######################################################################################################
    # Restart SCCM service
    Write-Host "`tRestarting CCMEXEC service...." -ForegroundColor Red
    Restart-Service CcmExec
    
    "$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Restarted CCMEXEC service, sleeping for 10...." | Add-Content $log
    #start-sleep -Seconds 10
    Write-Host "`tRestarted CCMEXEC service...." -ForegroundColor Green


    }
    }catch{
        #Write-Output Caught the exception;
        #Write-Output $Error[0].Exception;
        if($_.Exception.ErrorCode -eq 0x800706BA){Write-Host "`tWMI_-_RPC_Server_Unavailable_-_HRESULT:_0x800706BA"}		
        ElseIf($_.Exception.ErrorCode -eq 0x80070005){Write-Host "`tWMI_-_Access_is_Denied_-_HRESULT:_0x80070005"}
        Else{Write-Host "`tWMI_error_occured"}
    }finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}

Write-host ""
