$SDate = $(Get-Date)
$SDate = $(Get-Date)
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan
$SDate = $(Get-Date)
$SSDate = $(Get-Date)
Write-Host "$SDate -- Script starting..." -ForegroundColor Magenta
#######################################
. "C:\Scripts\!Modules\GoGoSCCM_Module_client.ps1"
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location -Path "$($SiteCode.Name):\"
#######################################
$Folder = 'D:\Powershell\!SCCM_PS_scripts\!DPs\Get_DP_Space'
$ADateStart = $(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')
      $Log = "$Folder\Get_DP_Space-Results--$ADateStart.csv"
    $TSLog = "$Folder\Get_DP_Space_TS_Results.csv"
$FinalFile = "$Folder\Get_DP_Space-Results--$ADateStart.xlsx"
#########################################################################################
Write-Host "Getting DP list..." -ForegroundColor cyan	
$DPsInfo = Get-CMDistributionPoint -AllSite
$DPs = $($DPsInfo.NetworkOSPath).replace('\\','')
$DPs | Set-Content "$Folder\Get_DP_Space--DP_List.txt"
#########################################################################################
'DP,Drive Letter,Total Space (GB),Free Space (GB)' | Set-Content $Log

$i = 1
$Total = $DPs.count
Write-Host "Checking $total DPs..." -ForegroundColor Cyan	
$DPs | % {
    # Write-Host "$i of $total -- $_" -ForegroundColor Cyan
	$SQL_Query = "select B.ServerName,
                    A.Status,
                    A.SiteCode,
                    A.Drive,
                    A.ObjectType,
                    A.PercentFree,
                    100 - A.PercentFree as PercentUsed,
                    A.BytesTotal/1024/1024 AS 'Total Size (GB)',
                    A.BytesFree/1024/1024 AS 'Space Free (GB)',
                    A.AvailablePkgShareDrivesList,
                    A.AvailableContentLibDrivesList
                    from v_DistributionPointDriveInfo A
                    inner join v_DistributionPointInfo B on A.NALPath = B.NALPath
                    where B.ServerName in ('$_')"
    
          $SQL_DB = 'CM_XX1'
      $SQL_Server = 'SERVER'
    $SQL_Instance = 'SERVER'
    $SQL_Check = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
    #########################################
    ForEach ($Item in $SQL_Check)
    {
        $Item.ServerName + ','+  `
        $Item.Drive + ','+  `
        $Item.'Total Size (GB)' + ','+  `
        $Item.'Space Free (GB)'| Add-Content $Log
    }
    $i++
}
######################################################################################	
######################################################################################
$SEDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SSDate –End $SEDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan
$SDate = $(Get-Date)
