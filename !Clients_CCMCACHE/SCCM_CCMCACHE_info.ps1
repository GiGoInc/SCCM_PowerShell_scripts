<#
$object.Computer,$object.Responding,$object.String -join ","

<#
$object.Computer,$object.Responding,$object.String -join ","

<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,Result

.Example
PS C:> .\CCMCACHE_info--bsub.ps1" -computer 'Computer1'
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
    [String]$LogFile = 'C:\Temp\errorlog.txt',
	$Command = "nothing"
)
    )
$ErrorActionPreference = "Continue"

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

# Check C:\Windows\CCMCACHE folder for size and subfolder count
    Try{
        If (Test-Path -Path "\\$computer\c$\windows\ccmcache")
        {
            $colItems = (Get-ChildItem "\\$computer\c$\windows\ccmcache" -recurse)
            $b = $colitems | Measure-Object -property length -sum 2>$Null
            If ($b -ne $Null)
            {
                $size = "{0:N0}" -f ($b.sum / 1MB)
                $fc = $b.Count
                $foldersize = $size -replace ',' , ''
        		# CCMCACHE folder size is larger than 0kb and there are more than zero subfolders
        		# Returning size of CCMCACHE folder and number of subfolders
                $output += ($foldersize+','+$fc+',')
            }
        	Else
        	{
        		$fc = $colitems.Count
        		$output += ($foldersize+','+$fc+',')
        	}
        }
        Else{$output += ("Couldn't find CCMCACHE"+',,')}
    }#End Try
    Catch{$output += ("Couldn't find CCMCACHE"+',,')}
    Finally{$ErrorActionPreference = "Continue";} #Reset the error action pref to default

# Check internal SCCM cache, which adds an informational line in the C:\Windows\CCM\Logs\CAS.LOG
    Try{
        $ErrorActionPreference = "Stop"
        $errorCode = $null
        $script = {$CMObject = New-Object -ComObject "UIResource.UIResourceMgr"
        $CMCacheObjects = $CMObject.GetCacheInfo()
        #$CMCacheObjects.GetCacheElements()
        }
            Invoke-Command -ComputerName $computer -scriptblock $script 2>$Null
        }
        Catch
        {
            If ($errorcode -ne 0)
            {
                $es = [string]$error[0]
                If ($es -like "*The client cannot connect to the destination specified in the request*")
                {
                    $output += ("WINRM error - can't initiate CACHE check"+',')
                }
            }
        
        }
        Finally
        {
            $ErrorActionPreference = "Continue";
        }


    Try{
        If (Test-Path -Path "\\$computer\C$\Windows\CCM\logs\CAS.log")
        {
            # Check for size of cache
            Try{
                # REPLACE commands don't match the SingleMachine synatx because of the leading computername
                # BSUB ------ \\ALK9WS09\C$\Windows\CCM\logs\CAS.log:106:<![LOG[CacheManager: There are currently 1200671744........
                # PSSESSION - C:\Windows\CCM\logs\CAS.log:106:<![LOG[CacheManager: There are currently 1200671744 bytes....
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
                
                  $bytez = $s3[2].Replace(' bytes used for cached' , '')
                  $total = $s3[3].Replace(' total' , '')
                 $active = $s3[4].Replace(' active' , '')
                   $tomb = $s3[5].Replace(' tombstoned' , '')
                $expired = $s3[6].Replace(' expired' , '')
                   $date = $s3[8].Replace(' ' , '/')
                   $bytes = "{0:N0}" -f ($bytez / 1MB)
                   $MB = $MB.replace(',','')
                $output += ($MB+','+$total+','+$active+','+$tomb+','+$expired+','+$date+',')
            }#End Try
            Catch{$output += ("Couldn't find Cache size in CAS.log"+',')}
            Finally{$ErrorActionPreference = "Continue";} #Reset the error action pref to default

            # Check for space error in cache
            Try{
                $Line = Select-String -Path "\\$computer\C$\Windows\CCM\logs\CAS.log" -pattern "Not enough space in Cache"
                $lastline = $line[-1]
                $s4 = $lastline | out-string
                $s5 = $s4 -replace '[^\p{L}\p{Nd}]' , ';'
                $s5 = $s5 -replace ';;;' , ';'
                $s5 = $s5 -replace ';;' , ';'
                $s5 = $s5 -replace ';;' , ';'
                $s5 = $s5 -replace ';;' , ';'
                $s5 = $s5.TrimStart(';').replace(';C;Windows',':')
                $s5 = $s5 -replace 'Not;enough;space;in;Cache' , ':Not enough space in Cache:'
                $s5 = $s5 -replace ';date;' , ' date:'
                $s5 = $s5 -replace ';component' , ':component'
                $s5 = $s5 -replace ' ;' , ';'
                $s5 = $s5 -replace '; ' , ';'
                $s5 = $s5 -replace ';' , ' '
                $s5 = $s5 -replace ': ' , ':'
                $s5 = $s5 -replace ' :' , ':'
                $s5 = $s5.split(':')
                $space = $s5[2]
                 $date = $s5[4].Replace(' ' , '/')
                $output += ($space+','+$date)
            }#End Try
            Catch{$output += ("No space error in CAS.log")}
            Finally{$ErrorActionPreference = "Continue";} #Reset the error action pref to default
        }
        Else{$output += ("Error finding CAS.log")}


        $object = [pscustomobject] @{
            Computer=$computer;
            Responding="Yes";
            String=$("$output")}
    }#End Try
    Catch{$output += ("Couldn't CAS.log"+',')}
    Finally{$ErrorActionPreference = "Continue";} #Reset the error action pref to default
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
