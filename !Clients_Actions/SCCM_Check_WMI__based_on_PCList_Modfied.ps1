[CmdletBinding()]
param([int]$Timeout = 60,
    [int]$Throttle = 400,
	$Command = "nothing"
)
# Load Modules
. 'C:\Scripts\!Modules\Invoke-Parallel.ps1'	#Script to run check concurrently
. 'C:\Scripts\!Modules\Invoke-Pingv2.ps1'


# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$Log = "C:\Scripts\PowerShell_log.log" 							# Logfile
    $ADateS = Get-Date
$ADateStart = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')

"C:\!Powershell\!Parallized_Scripts\$ScriptName`tstart time`t$ADateStart" | Add-Content $Log

  $listping = "C:\Temp\ListPing.txt"
 $Computers = get-Content "$CurrentDirectory\SCCM_Check_WMI--PCList.txt"
  $DestFile = "$CurrentDirectory\SCCM_Check_WMI--Results_$ADateStart.csv"
 $Failedlog = "$CurrentDirectory\SCCM_Check_WMI--Fails_$ADateStart.csv"
$Responding = "$CurrentDirectory\ListPing.txt"
 $SubScript = "$CurrentDirectory\SCCM_Check_WMI--bsub.ps1"
$DNSRecords = "$CurrentDirectory\DNS_Check_$ADateStart.csv"

  If (Test-Path $listping){Remove-Item $listping -Force}
  If (Test-Path $DestFile){Remove-Item $DestFile -Force}
 If (Test-Path $Failedlog){Remove-Item $Failedlog -Force}
If (Test-Path $Responding){Remove-Item $Responding -Force}
 If (Test-Path $SubScript){Remove-Item $SubScript -Force}
If (Test-Path $DNSRecords){Remove-Item $DNSRecords -Force}


# Ping Machines and only return Responding
$Computers | Invoke-Ping | Add-Content $listping
Write-Host "Building list of Responding..."
start-sleep -seconds 5
$lines = Get-Content $listping
ForEach ($line in $Lines)
{
	If ($line -match "Responding")
    {
        $PC = $line.Split(',')[0]
        $pc | Add-Content $Responding
    }
}


# Get Responding list and check them
$Good = get-Content $Responding
Write-host "$Good.count machines responding"

#Create Header line on results log
"PC Name,Online,CCMCACHE folder size,Persistent Cache size" | Set-Content $DestFile

# Run this
Invoke-Parallel -scriptfile $SubScript -inputobject $Good -runspaceTimeout $Timeout -throttle $Throttle| Add-Content $DestFile


Write-Host "Building list of Time-outs..."
start-sleep -seconds 5
$lines = Get-Content "C:\temp\log.log"
ForEach ($midstring in $Lines)
{
	$string = $midstring.Replace(":'",',').replace('"','').Replace(';Removing','').Replace(';',',').Replace("'",'')
    $string | Select-String -pattern "TimedOut" | Add-Content -Path $Failedlog
}

#Check DNS Records
ForEach ($computer in $Good)
{
    $IP = [System.Net.Dns]::GetHostAddresses("$computer").IPAddressToString
    "$Computer,$IP" | Add-Content $DNSRecords
}