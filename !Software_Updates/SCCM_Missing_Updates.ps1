$GetRowInfo_Server = 'SERVER'
    
    
$GetRowInfo_Server = 'SERVER'
$GetRowInfo_Instance = 'SERVER'
$GetRowInfo_DB = 'CM_XX1'

$GetRowInfo_Query = "SELECT dbo.v_R_System.Netbios_Name0 AS [Computer Name]
    ,COUNT(dbo.v_UpdateComplianceStatus.Status) AS [Updates Missing]
    ,dbo.v_GS_WORKSTATION_STATUS.LastHWScan
FROM dbo.v_R_System
INNER JOIN dbo.v_UpdateComplianceStatus ON dbo.v_R_System.ResourceID = dbo.v_UpdateComplianceStatus.ResourceID
INNER JOIN dbo.v_UpdateInfo ON dbo.v_UpdateComplianceStatus.CI_ID = dbo.v_UpdateInfo.CI_ID
INNER JOIN dbo.v_StateNames ON dbo.v_UpdateComplianceStatus.LastEnforcementMessageID = dbo.v_StateNames.StateID
LEFT OUTER JOIN dbo.v_GS_WORKSTATION_STATUS ON dbo.v_UpdateComplianceStatus.ResourceID = dbo.v_GS_WORKSTATION_STATUS.ResourceID
WHERE (dbo.v_UpdateComplianceStatus.Status = 2) AND (dbo.v_StateNames.TopicType = 402)
GROUP BY dbo.v_R_System.Netbios_Name0 , dbo.v_GS_WORKSTATION_STATUS.LastHWScan
ORDER BY [Updates Missing], [Computer Name]"

Function RunTime
{
    $End = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $Start –End $End
    $Min = $TS.minutes
    $Sec = $TS.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Magenta
}
    
$GetRowInfo_QueryInvoke = Invoke-Sqlcmd -AbortOnError `
				-ConnectionTimeout 60 `
				-Database $GetRowInfo_DB  `
				-HostName $GetRowInfo_Server  `
				-Query $GetRowInfo_Query `
				-QueryTimeout 1200 `
                -ServerInstance $GetRowInfo_Instance

$DestFile = 'D:\Powershell\!SCCM_PS_scripts\!Software_Updates\SCCM_Missing_Updates.csv'
$Start = (GET-DATE)
Write-host "Getting SQL info...Starting..." -ForegroundColor Yellow
Write-host "Estimated Time to Complete: 10 minutes..." -ForegroundColor Cyan 
$GetRowInfo_QueryInvoke | Add-Content $DestFile
RunTime 
    
    
