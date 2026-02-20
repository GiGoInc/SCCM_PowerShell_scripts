<#


<#


<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,Result

.Example
PS C:> .\CCMCACHE_get_last_size_from_CAS_log--bsub.ps1" -computer 'Computer1'
	Computer1,Yes,PORT=3029
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
    [String]$LogFile = 'C:\Temp\errorlog.txt'
    )

if(test-connection $computer -count 1 -quiet -BufferSize 16)
{
$Output = $null
$S1 = $null
$S2 = $null
$S3 = $null
$S4 = $null
$S5 = $null
$S6 = $null



#Create an empty dynamic array
$Output = @()

    Try{
    If (Test-Path -Path "\\$computer\c$\windows\ccmcache")
    {
    $colItems = (Get-ChildItem "\\$computer\c$\windows\ccmcache" -recurse | Measure-Object -property length -sum)
    $size = "{0:N0}" -f ($colItems.sum / 1MB)
    $s = $size -replace ',',''
    $output += ($s+',')
	start-sleep -seconds 5
    }
    Else{$output += ("Couldn't find CCMCACHE"+',')}
    }#End Try
    Catch{$output += ("Couldn't find CCMCACHE"+',')}


    ### CACHE - DISCOVERY SCRIPT
    $objects = $null
      $count = $null
    	$CMObject = new-object -com "UIResource.UIResourceMgr"
    	$cacheInfo = $CMObject.GetCacheInfo()
    	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
        $count = $objects.Count


    if (Test-Path -Path "\\$computer\C$\Windows\CCM\logs\CAS.log")
    {
        Try{
        # Check for size of cache
            $Line = Select-String -Path "\\$computer\C$\Windows\CCM\logs\CAS.log" -pattern 'CacheManager: There are currently'
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
            
            $bytes = $s3[2].Replace(' bytes' , '')
            $total = $s3[4].Replace(' total' , '')
           $active = $s3[5].Replace(' active' , '')
             $tomb = $s3[6].Replace(' tombstoned' , '')
          $expired = $s3[7].Replace(' expired' , '')
             $date = $s3[9].Replace(' ' , '/')

             #$bytes,$total,$active,$tomb,$expired,$date

             $output += ($s+','+$bytes+','+$total+','+$active+','+$tomb+','+$expired+','+$date)

        }#End Try
        Catch{$output += ("Couldn't find Cache size in CAS.log"+',')}
    }
    else
    {
        $output += ("Error finding CAS.log")
    }

    $object = [pscustomobject] @{
        Computer=$computer;
        Responding="Yes";
        String=$("$output")
    }
}
else
{
    $object = [pscustomobject] @{
        Computer=$computer;
        Responding="No";
        String="Couldn't ping PC"
    }
        
}

$object.Computer,$object.Responding,$object.String -join ","



