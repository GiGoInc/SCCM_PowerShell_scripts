<#


<#


<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,User Name,Operating System,OS Type,Serial,Hard Drive Name,Firmware

.Example
PS C:\> .\Get_ccmcache_size--bsub.ps1 -computer 'Computer1'
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
$object = [pscustomobject] @{
Computer=$computer;
Responding="Yes";
Output=$(
		#Adjusting ErrorActionPreference to stop on all errors
		$TempErrAct = $ErrorActionPreference
		$ErrorActionPreference = "Stop"
		#Exclude Local System, Local Service & Network Service
    Try
        {
            # Discovery
            $Cache = Get-WmiObject -ComputerName $computer -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
            $CSize = $Cache.Size
            
            $System = Get-WmiObject -ComputerName $computer  -Class Win32_ComputerSystem
            $PCModel = $System.Model
            
            $disk = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size
            $DSize = $disk.Size
            
            $colItems = (Get-ChildItem "\\$computer\c$\windows\ccmcache" -recurse | Measure-Object -property length -sum)
            $size = "{0:N0}" -f ($colItems.sum / 1MB)
            $FSize = $size -replace ',',''

            $output = "$CSize"+','+"$FSize"

            $output

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



