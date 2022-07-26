<#
.Synopsis
This script runs the Invoke-Parallel.ps1 module.

It passses the following parameters:
$Subscript - the matching "%SCRIPTNAME%--bsub.ps1" script (i.e. SCCM_Check_PkgLib--bsub.ps1)
$Computers - list of machine names
-runspacetimeout - amount of time for each Runspace
-throttle - number of concurrent RunSpaces
$Destfile - timestamped CSV with header and output of the "%SCRIPTNAME%--bsub.ps1"

The data follows comma separated order:
PC Name,Online,Result,Version

.Example
PS C:\> . SCCM_Check_PkgLib--based_on_PCList.ps1
	PC Name,Online,Result,Version
	Computer1,Yes,Computer1,no 'Application Data' folders found
	Computer2,Yes,Computer2,no 'Application Data' folders found
#>
[CmdletBinding()]
param([int]$Timeout = 360,
    [int]$Throttle = 250,
	$Command = "nothing"
)

# Load Modules
. 'C:\Scripts\!Modules\Invoke-Parallel.ps1'	#Script to run check concurrently

# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$Log = "C:\Scripts\PowerShell_SCCM_Check_PkgLib-log.log"                            # Logfile
    $ADateS = Get-Date                                     # Logfile
$ADateStart = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')

"$CurrentDirectory\$ScriptName`tstart time`t$ADateStart" | Add-Content $Log

#####################################################################################################################################
$ADateS1 = Get-Date
$DPsFile = "$CurrentDirectory\PCList.txt"
$Null | Set-Content $DPsFile
#############################################################
GoGo_SCCM_Module.ps1
$DPList = Get-CMDistributionPoint | Select-Object NetworkOsPath
$DPList = $DPList.NetworkOsPath | sort
ForEach ($Item in $DPList)
{
    $item.replace('\\','') | Add-Content "$DPsFile"
}
#############################################################
# FINALLY - Write Time
$ADateE1 = Get-Date
$t = NEW-TIMESPAN –Start $ADateS1 –End $ADateE1 | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
Write-Host "`nPart1 ran for:" -nonewline
Write-Host "`t$min minutes and $sec seconds." -ForegroundColor Magenta
#####################################################################################################################################
$SubScript = "$CurrentDirectory\SCCM_Check_PkgLib--bsub.ps1"
 $DestFile = "$CurrentDirectory\SCCM_Check_PkgLib--Results_$ADateStart.csv"
$Computers = Get-Content "$DPsFile"

#Create Header line on results log
"PC Name,Online,Result,Version" | Set-Content $DestFile

#Run this
Invoke-Parallel -scriptfile $SubScript -inputobject $Computers -runspaceTimeout $Timeout -throttle $Throttle| Add-Content $DestFile

# WRITE LOG FILE
  $ADateE2 = Get-Date
  $ADateEnd = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
  "$CurrentDirectory\$ScriptName`tScript end time`t$ADateEnd"| Add-Content $Log
$t = NEW-TIMESPAN –Start $ADateS2 –End $ADateE2 | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
"$CurrentDirectory\$ScriptName`tran $min minutes and $sec seconds." | Add-Content $Log
