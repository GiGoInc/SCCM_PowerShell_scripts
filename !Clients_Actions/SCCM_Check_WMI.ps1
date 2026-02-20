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
#Create an empty dynamic array
$Output = @()
    
    #Adjusting ErrorActionPreference to stop on all errors
    $TempErrAct = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    Try
    {
        $ErrorActionPreference = "Stop"; #Make all errors terminating
        $CCM = Get-WmiObject -Namespace 'root\ccm' -Class 'SMS_Client' -Impersonation 3 -ComputerName $computer
        $Output += "$CCM.ClientVersion"
    }
    Catch
    {
        if($_.Exception.ErrorCode -ccontains "0x80010108")
        {
            $Output += "WMI doesn't have the Instance for SMS_Client. Repair needed"
            # Invoke-Expression ("msiexec.exe /fpecms '{343D4507-997F-4553-9F86-2BB81F19A05E}'")
            # Invoke-Command -ScriptBlock {msiexec.exe /fpecms '{343D4507-997F-4553-9F86-2BB81F19A05E}'} -ComputerName $computer
        }
        ElseIf($_.Exception.ErrorCode -ne '0')
        {
            $Output += $_
        }
    }
    Finally
    {
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }

	$object = [pscustomobject] @{
		Computer=$computer;
		Responding="Yes";
		File=$("$Output")
	}
}
ELSE
{
	$object = [pscustomobject] @{
	Computer=$computer;
	Responding="No";
	File="Couldn't ping PC"
	}
}

$object.Computer,$object.Responding,$object.File -join ","



