<#
$SQLResults
$SQLResults | Set-Content "D:\2020-02-03--SQL_Checks.csv"
<#
Declare @Date1 datetime = '2019-02-01'
Declare @Date2 datetime = '2019-03-01'

Select	v_GS_OPERATING_SYSTEM.Caption0 as 'Operating System',
		COUNT(v_GS_OPERATING_SYSTEM.Caption0) as 'Install Count - 2019-02-01'
From v_GS_OPERATING_SYSTEM
where v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows XP Professional' and InstallDate0 <= @Date1
	  or
      v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows 7 Enterprise' and InstallDate0 <= @Date1
	  or
	  v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows 10 Enterprise' and InstallDate0 <= @Date1
GROUP BY v_GS_OPERATING_SYSTEM.Caption0
order by Caption0 desc

Select	v_GS_OPERATING_SYSTEM.Caption0 as 'Operating System',
		COUNT(v_GS_OPERATING_SYSTEM.Caption0) as 'Install Count - 2019-03-01'
From v_GS_OPERATING_SYSTEM
where v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows XP Professional' and InstallDate0 <= @Date2
	  or
      v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows 7 Enterprise' and InstallDate0 <= @Date2
	  or
	  v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows 10 Enterprise' and InstallDate0 <= @Date2
GROUP BY v_GS_OPERATING_SYSTEM.Caption0
order by Caption0 desc
#>

$SQL_DB       = 'CM_XX1'
$SQL_Server   = "SERVER"
$SQL_Instance = "SERVER"
$SQL_Table    = 'v_GS_OPERATING_SYSTEM'

$i = 0
$MonthChecks = @()
[datetime]$StartDate = '2018-10-01'
$Current = Get-Date
Do {
    $SQL_Check = $null
    $MonthlyRollup = $StartDate.AddMonths($i)
    $MonthlyRollup = $MonthlyRollup.ToString("yyyy-MM-dd")
    $MonthChecks += $MonthlyRollup
    $i++
    }
While ($Current -ge $MonthlyRollup)

$SQLResultsXP = @()
$SQLResults7 = @()
$SQLResults10 = @()
ForEach ($MonthCheck in $MonthChecks)
{
    $SQL_QueryXP = "Declare @CheckDate datetime = '$MonthCheck'
    Select v_GS_OPERATING_SYSTEM.Caption0 as 'Operating System',COUNT(v_GS_OPERATING_SYSTEM.Caption0) as 'Install Count - $MonthCheck' 
    From v_GS_OPERATING_SYSTEM where v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows XP Professional' and InstallDate0 <= @CheckDate
    GROUP BY v_GS_OPERATING_SYSTEM.Caption0 order by Caption0 desc"
    $SQL_CheckXP = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_QueryXP `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
    $SQLResultsXP += [string]$SQL_CheckXP[1] + ','

   $SQL_Query7 = "Declare @CheckDate datetime = '$MonthCheck'
   Select v_GS_OPERATING_SYSTEM.Caption0 as 'Operating System',COUNT(v_GS_OPERATING_SYSTEM.Caption0) as 'Install Count - $MonthCheck' 
   From v_GS_OPERATING_SYSTEM where v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows 7 Enterprise' and InstallDate0 <= @CheckDate
   GROUP BY v_GS_OPERATING_SYSTEM.Caption0 order by Caption0 desc"
   $SQL_Check7 = Invoke-Sqlcmd -AbortOnError `
       -ConnectionTimeout 60 `
       -Database $SQL_DB  `
       -HostName $SQL_Server  `
       -Query $SQL_Query7 `
       -QueryTimeout 600 `
       -ServerInstance $SQL_Instance
   $SQLResults7 += [string]$SQL_Check7[1] + ','
   
   $SQL_Query10 = "Declare @CheckDate datetime = '$MonthCheck'
   Select v_GS_OPERATING_SYSTEM.Caption0 as 'Operating System',COUNT(v_GS_OPERATING_SYSTEM.Caption0) as 'Install Count - $MonthCheck' 
   From v_GS_OPERATING_SYSTEM where v_GS_OPERATING_SYSTEM.Caption0 like 'Microsoft Windows 10 Enterprise' and InstallDate0 <= @CheckDate
   GROUP BY v_GS_OPERATING_SYSTEM.Caption0 order by Caption0 desc"
   $SQL_Check10 = Invoke-Sqlcmd -AbortOnError `
       -ConnectionTimeout 60 `
       -Database $SQL_DB  `
       -HostName $SQL_Server  `
       -Query $SQL_Query10 `
       -QueryTimeout 600 `
       -ServerInstance $SQL_Instance
   $SQLResults10 += [string]$SQL_Check10[1] + ','
}
$SQLResults = @()
$Months = 'Operating_System,' + $MonthChecks -join ' ' -replace ' ',','
$SQLResults += $months
$SQLResults += 'Windows XP,' + $SQLResultsXP -join ',' -replace ' ',''
$SQLResults += 'Windows 7,' + $SQLResults7 -join ',' -replace ' ',''
$SQLResults += 'Windows 10,' + $SQLResults10 -join ',' -replace ' ',''
$SQLResults | Set-Content "D:\2020-02-03--SQL_Checks.csv"
$SQLResults
