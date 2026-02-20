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
PS C:> .\CCMCACHE_last_space_error_from_CAS_log--bsub.ps1" -computer 'Computer1'
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
#Create an empty dynamic array
$Output = @()

    Try
    {
        if (Test-Path -Path "\\$computer\C$\Windows\CCM\logs\CAS.log")
        {
            Try{
            # Check for size of cache
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
            Catch{$output += ("Couldn't find space error in CAS.log"+',')}
            }
        else
        {
            $output += ("Error finding CAS.log")
        }
    }#End Try
    Catch{$output += ("Couldn't connect to CAS.log"+',')}


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
