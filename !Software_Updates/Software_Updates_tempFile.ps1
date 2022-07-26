# Load SQL 2014 Module
    If (Test-Path "C:\Program Files\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1")
    {
        Write-host "Loading SQL 2014 x64 Module" -ForegroundColor Cyan
        Import-Module "C:\Program Files\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1"
    }

# Load SQL 2016 Module
    If (Test-Path "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1")
    {
        Write-host "Loading SQL 2014 x86 Module" -ForegroundColor Cyan
        Import-Module "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1"
    }

Function RunTime
{
    $End = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $Start –End $End
    $Min = $TS.minutes
    $Sec = $TS.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
}



$ConnectionTimeout   = '60'
$GetSQLInfo_Server   = 'sccmserverdb'
$GetSQLInfo_Instance = 'sccmserverdb'
$GetSQLInfo_DB       = 'CM_SS1'
$QueryTimeout        = '600'

$GetSQLInfo_Query = "
Declare @CollID nvarchar (255),@SUG nvarchar(255);
Set @CollID='SS100010';set @SUG='ADR: Software Updates - All Branch Workstations';
--CollID=Collection ID and SUG=Software update group Name

Select resourceid,
       ui.DatePosted,
       ui.Title,
	   ui.IsDeployed,
	   ucs.status,
	   ui.Severity,
	   ui.IsSuperseded,
	   ui.IsExpired,
	   ui.islatest
From v_UpdateInfo ui
inner JOIN v_Update_ComplianceStatus ucs on ucs.CI_ID = ui.CI_ID
JOIN v_BundledConfigurationItems bci on ui.CI_ID = bci.BundledCI_ID 
Where bci.CI_ID = (SELECT CI_ID FROM v_AuthListInfo where title = @SUG)
and
ui.IsLatest='1'
"

Write-Host 'Executing script....' -foregroundcolor Cyan
$GetSQLInfo_QueryInvoke = Invoke-Sqlcmd -AbortOnError `
                                        -ConnectionTimeout $ConnectionTimeout `
                                        -Database $GetSQLInfo_DB  `
                                        -HostName $GetSQLInfo_Server  `
                                        -Query $GetSQLInfo_Query `
                                        -QueryTimeout $QueryTimeout `
                                        -ServerInstance $GetSQLInfo_Instance



$TitleCount = $GetSQLInfo_QueryInvoke | % {$_.resourceid,$_.DatePosted,$_.Title,$_.IsDeployed,$_.status,$_.Severity,$_.IsSuperseded,$_.IsExpired,$_.islatest -join ',' | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Software_Updates\Query.csv'}


$GetSQLInfo_QueryInvoke | group | % { $h = @{} } { $h[$_.DatePosted] = $_.Count } { $h }

$Titles = $GetSQLInfo_QueryInvoke | select-object Title -Unique
$Titles.count


ForEach ($Item in $GetSQLInfo_QueryInvoke) 
{
    $resourceid   = $Item.resourceid
    $DatePosted   = $Item.DatePosted
    $Title        = $Item.Title
    $IsDeployed   = $Item.IsDeployed
    $status       = $Item.status
    $Severity     = $Item.Severity
    $IsSuperseded = $Item.IsSuperseded
    $IsExpired    = $Item.IsExpired
    $islatest     = $Item.islatest



}




| % {$_.resourceid,$_.DatePosted,$_.Title,$_.IsDeployed,$_.status,$_.Severity,$_.IsSuperseded,$_.IsExpired,$_.islatest -join ',' | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Software_Updates\Query.csv'}




<#
$Start = (GET-DATE)
Write-Host "$(Get-Date)`tBuilding export of SQL to CSV - Estimated time forever"
$GetSQLInfo_QueryInvoke | foreach-object -begin {clear-host;$I=0;$out=""} -process { `
$_.resourceid,$_.DatePosted,$_.Title,$_.IsDeployed,$_.status,$_.Severity,$_.IsSuperseded,$_.IsExpired,$_.islatest -join ',' | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Software_Updates\Query2.csv'; `
$I = $I+1;Write-Progress -Activity "Searching Events" -Status "Progress:" -PercentComplete ($I/$Events.count*100)} -end {$out}
RunTime



$GetSQLInfo_QueryInvoke | % {$_.resourceid,$_.DatePosted,$_.Title,$_.IsDeployed,$_.status,$_.Severity,$_.IsSuperseded,$_.IsExpired,$_.islatest -join ',' | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Software_Updates\Query.csv'}




            # PROGRESS INDICATOR - START
                $ErrorActionPreference ='SilentlyContinue'
        	    $Counter = 0
                ForEach ($Item In $GetSQLInfo_QueryInvoke)
                {
                	## -- Calculate The Percentage Completed
                	$Counter++
                	[Int]$Percentage = ($Counter/$GetSQLInfo_QueryInvoke.Count)*100
                	$ProgressBar_GetRows.Value = $Percentage
                	#$ObjLabel.Text = "Recursive Search: Writing Names of All Files Found Inside $Path"
                	$ObjForm.Refresh()
                	Start-Sleep -Milliseconds 50
                	# -- $Item.Name
                	#"`t" + $Item.Path
                	Write-host "Counter: $Counter" -ForegroundColor Red
                }
                $ErrorActionPreference ='Continue'
            # PROGRESS INDICATOR - END
#>