<#


<#


<#
.Synopsis
This script runs the Invoke-Parallel.ps1 module.

It passses the following parameters:
$Subscript - the matching "%SCRIPTNAME%--bsub.ps1" script (i.e. SCCM_Check_WMI--bsub.ps1)
$Computers - list of machine names
-runspacetimeout - amount of time for each Runspace
-throttle - number of concurrent RunSpaces
$Destfile - timestamped CSV with header and output of the "%SCRIPTNAME%--bsub.ps1"

The data follows comma separated order:
PC Name,Online,PC Name (2),LastLoggedOn User,User SID,Last Logon Time,Logged In

.Example
PS C:\> .\SCCM_Check_WMI--based_on_PCList.ps1
	PC Name,Online,PC Name (2),LastLoggedOn User,User SID,Last Logon Time,Logged In
	Computer1,Yes,Computer1,DOMAIN\user1,S-1-5-21-3460299977-12345678901-234567890-12345,09/29/2015 08:22:08,True
	Computer2,Yes,Computer2,DOMAIN\User2,S-1-5-21-3460299977-98765432109-876543210-98765,09/29/2015 08:11:53,False
#>
[CmdletBinding()]
param([int]$Timeout = 60,
    [int]$Throttle = 400,
	$Command = "nothing"
)

# Load Modules
. 'C:\Scripts\!Modules\Invoke-Parallel.ps1'	#Script to run check concurrently

# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$Log = "C:\Scripts\PowerShell_log.log"                     # Logfile
    $ADateS = Get-Date                                     # Logfile
$ADateStart = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')

"$CurrentDirectory\$ScriptName`tstart time`t$ADateStart" | Add-Content $Log


            $SubScript = "$CurrentDirectory\SCCM_Check_WMI--bsub.ps1"
             $DestFile = "$CurrentDirectory\SCCM_Check_WMI--Results_$ADateStart.csv"
$Computers = get-Content "$CurrentDirectory\SCCM_Check_WMI--PCList.txt"
            $Failedlog = "$CurrentDirectory\SCCM_Check_WMI--Fails_$ADateStart.csv"

#Create Header line on results log
"PC Name,Online,CCMCACHE folder size,Persistent Cache size" | Set-Content $DestFile

# Run this
Invoke-Parallel -scriptfile $SubScript -inputobject $Computers -runspaceTimeout $Timeout -throttle $Throttle| Add-Content $DestFile


Write-Host "Building list of Time-outs..."
start-sleep -seconds 5
$lines = Get-Content "C:\temp\log.log"
ForEach ($midstring in $Lines)
{
	$string = $midstring.Replace(":'",',').replace('"','').Replace(';Removing','').Replace(';',',').Replace("'",'')
    $string | Select-String -pattern "TimedOut" | Add-Content -Path $Failedlog
}

# WRITE LOG FILE
  $ADateE = Get-Date
  $ADateEnd = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
  "$CurrentDirectory\$ScriptName`tScript end time`t$ADateEnd"| Add-Content $Log
$t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
"$CurrentDirectory\$ScriptName`tran $min minutes and $sec seconds." | Add-Content $Log



