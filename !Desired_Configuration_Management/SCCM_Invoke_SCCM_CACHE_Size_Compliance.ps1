<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,User Name,Operating System,OS Type,Serial,Hard Drive Name,Firmware

.Example
PS C:\> .\CCMCACHE_run_DCM_size_change--bsub.ps1 -computer 'Computer1'
	Computer1,Yes,Computer1,DOMAIN\user1,S-1-5-21-3460299977-1648588825-1751037255-8956,09/29/2015 08:22:08,True
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
    [String]$LogFile = 'C:\Scripts\AD_Files\errorlog.txt',
	$command=$nothing
	)

if(test-connection $computer -count 1 -quiet -BufferSize 16)
{
#Create an empty dynamic array
$object = [pscustomobject] @{}

		#Adjusting ErrorActionPreference to stop on all errors
		$TempErrAct = $ErrorActionPreference
		$ErrorActionPreference = "Stop"
		#Exclude Local System, Local Service & Network Service
    Try
        {
		    # Binding \\$PC\root\ccm:SMS_Client
            $SMSCli = [wmiclass] "\\$computer\root\ccm:SMS_Client"
		    if($SMSCli){  
		    	$SMSCli.TriggerSchedule('{00000000-0000-0000-0000-000000000021}') | Out-Null  # Request Machine Assignments
		    	Write-Host "Executed - Request Machine Assignments"
		    	$SMSCli.TriggerSchedule('{00000000-0000-0000-0000-000000000022}') | Out-Null  # Evaluate Machine Policies
		    	Write-Host "Executed - Evaluate Machine Policies"
		    	$SMSCliDCM = [wmiclass] "\\$computer\root\ccm\dcm:SMS_DesiredConfiguration"
		    	$SMSCliDCM.TriggerEvaluation('ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Baseline_53c5a704-3175-46d6-aed9-584209aacfad', '3', $True , $True) | Out-Null  # Trigger Cache Resize baseline
		    	Write-Host "Executed - Triggered DCM baseline for CACHE resize"
		    }
		    else
            {
		    	Write-Host "Could not bind WMI class SMS_Client"
		    }
        }#End Try
        Catch{
               #Write-Output "Caught the exception";
               #Write-Output $Error[0].Exception;
                If ($_.Exception.Message -ne '0')
                {
		    	    Write-Host "WMI - Error: $_"
                }
            }#End Catch
		#Resetting ErrorActionPref
		$ErrorActionPreference = $TempErrAct
}
else
{
    $object = [pscustomobject] @{
    Computer=$computer;
    Responding="No";
    Data="Couldn't ping PC"
    }
}

$object | format-table -a


Write-Host ""
Read-Host -Prompt 'Press Enter to exit...'


