<#
$object.Computer,$object.Responding,$object.Output -join ","

<#
$object.Computer,$object.Responding,$object.Output -join ","

<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,User Name,Operating System,OS Type,Serial,Hard Drive Name,Firmware

.Example
PS C:\> .\CCMCACHE_clear_and_log--bsub.ps1 -computer 'Computer1'
	Computer1,Yes,Computer1,DOMAIN\SUPERUSER,S-1-5-21-3460299977-1648588825-1751037255-95761,09/29/2015 08:22:08,True
#>
[CmdletBinding()]
param(
    # Support for multiple computers from the pipeline
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in computer name and press Enter to execute')]
    [string]$computer,

    # Switch to turn on Error Logging
    [Switch]$ErrorLog,
    [String]$LogFile = 'C:\Scripts\AD_Files\errorlog.txt'
    )

if(test-connection $computer -count 1 -quiet -BufferSize 16)
{
    Try
        {
            New-PSSession -ComputerName $computer
            Enter-PSSession -ComputerName $computer
            start-sleep -Seconds 10

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
        }#End Try
        Catch{
               #Write-Output "Caught the exception";
               #Write-Output $Error[0].Exception;
                If ($_.Exception.Message -Like "*Some or all identity references could not be translated*")
                {
                    $size = "Unable to Translate $UserSID - Try filtering the SID by using the -FilterSID parameter."
                }
                ElseIf($_.Exception.ErrorCode -eq "0x800706BA")
                {
                  $size = "WMI - RPC Server Unavailable - HRESULT: 0x800706BA"
                }
                ElseIf($_.Exception.ErrorCode -eq "0x80070005")
                {
                  $size = "WMI - Access is Denied - HRESULT: 0x80070005"
                }
            }#End Catch
		#Resetting ErrorActionPref
		$ErrorActionPreference = $TempErrAct

    $object = [pscustomobject] @{
    Computer=$computer;
    Responding="Yes";
    Output=$(
    		#Adjusting ErrorActionPreference to stop on all errors
    		$TempErrAct = $ErrorActionPreference
    		$ErrorActionPreference = "Stop"
    		#Exclude Local System, Local Service & Network Service
    )
    }
}
else
{
    $object = [pscustomobject] @{
    Computer=$computer;
    Responding="No";
    Output="Couldn't ping PC"
    }
}

$object.Computer,$object.Responding,$object.Output -join ","
