$SDate = $(Get-Date)
$SSDate = $(Get-Date)
$ADateStart = $(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')
Write-Host "$SDate -- Script starting...runtime approx three minutes" -ForegroundColor Magenta
$Log = "D:\Powershell\!SCCM_PS_scripts\!Software_Updates\Software_Update_Group_Counts_results_$ADateStart.csv"
#######################################
$SQL_Query = "select AL.Title [SU Group],
count(DISTINCT upd.CI_ID ) 'Software updates Count',
count(upd.CI_ID ) 'Content downloaded Count'
from vSMS_CIRelation as cr
INNER JOIN fn_ListUpdateCIs(1033) upd ON  upd.CI_ID = cr.ToCIID AND cr.RelationType = 1
INNER JOIN v_CIToContent CC ON cc.CI_ID=upd.CI_ID
INNER JOIN v_AuthListInfo AL ON al.CI_ID =cr.FromCIID
where CC.ContentDownloaded='1'
GROUP BY AL.Title
ORDER BY 1"

      $SQL_DB = 'CM_SS1'
  $SQL_Server = 'sccmdb1'
$SQL_Instance = 'sccmdb1'
$SQL_Check = Invoke-Sqlcmd -AbortOnError `
    -ConnectionTimeout 60 `
    -Database $SQL_DB  `
    -HostName $SQL_Server  `
    -Query $SQL_Query `
    -QueryTimeout 600 `
    -ServerInstance $SQL_Instance

$Output = @()
$Output += 'SU Group,Software updates Count,Content downloaded Count'
$SQL_Check | % {
$Output += $_."SU Group" + ',' +
           $_."Software updates Count" + ',' +
           $_."Content downloaded Count"
}
$Output | Set-Content $Log


#########################################
$SEDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SSDate –End $SEDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tTotal script ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan

