########################################################################################################################################  
Write-Host "done." -ForegroundColor Green
$output | Add-Content $SCCMFile
########################################################################################################################################  
# VARIABLES
########################################################################################################################################
$SQL_Query = "SELECT DISTINCT  
ParentApp.DisplayName ParentAppName,  
ParentAppF.Name ParentAppFolder,  
ParentApp.CreatedBy ParentAppCreatedBy,  
ParentAppDT.DisplayName ParentAppDTName,  
ChildApp.DisplayName ChildAppDisplayName,  
ChildAppF.Name ChildAppFolder,  
ChildAppDT.DisplayName ChildAppDTName  
FROM   
fn_ListApplicationCIs(1033) ParentApp  
LEFT JOIN vFolderMembers ParentAppFM on ParentAppFM.InstanceKey = ParentApp.ModelName  
LEFT JOIN vSMS_Folders ParentAppF on parentAppF.ContainerNodeID = ParentAppFM.ContainerNodeID  
LEFT JOIN fn_ListDeploymentTypeCIs(1033) ParentAppDT on ParentAppDT.AppModelName = ParentApp.ModelName  
LEFT JOIN vSMS_AppRelation_Flat R on R.FromApplicationCIID = ParentApp.CI_ID  
LEFT JOIN fn_ListApplicationCIs(1033) ChildApp on ChildApp.CI_ID = R.ToApplicationCIID And ChildApp.IsLatest = 1  
LEFT JOIN vFolderMembers ChildAppFM on ChildAppFM.InstanceKey = ChildApp.ModelName  
LEFT JOIN vSMS_Folders ChildAppF on ChildAppF.ContainerNodeID = ChildAppFM.ContainerNodeID  
LEFT JOIN fn_ListDeploymentTypeCIs(1033) ChildAppDT on ChildAppDT.AppModelName = ChildApp.ModelName  
WHERE  
ParentApp.IsLatest = 1  
AND ParentAppDT.IsLatest = 1  
AND ChildApp.IsLatest = 1  
AND ChildAppDT.IsLatest = 1  
ORDER BY 1"
##########################################################################

$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
$SCCMFile = "D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\SCCM_Get_Application_Dependacies_Report--$ADate.csv"
If (Test-Path $SCCMFile) { Remove-Item -Path $SCCMFile -Force | Out-Null }
'ParentAppName,ParentAppFolder,ParentAppCreatedBy,ParentAppDTName,ChildAppDisplayName,ChildAppFolder,ChildAppDTName' | Set-Content $SCCMFile

##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'

   $SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
##########################################################################

$output = @()
ForEach ($Check in $SQL_Check)
{
    [string]$ParentAppName       = $Check.ParentAppName
    [string]$ParentAppFolder     = $Check.ParentAppFolder
    [string]$ParentAppCreatedBy  = $Check.ParentAppCreatedBy
    [string]$ParentAppDTName     = $Check.ParentAppDTName
    [string]$ChildAppDisplayName = $Check.ChildAppDisplayName
    [string]$ChildAppFolder      = $Check.ChildAppFolder
    [string]$ChildAppDTName      = $Check.ChildAppDTName

    $output += '"' + $ParentAppName       + '","' + `
                     $ParentAppFolder     + '","' + `
                     $ParentAppCreatedBy  + '","' + `
                     $ParentAppDTName     + '","' + `
                     $ChildAppDisplayName + '","' + `
                     $ChildAppFolder      + '","' + `
                     $ChildAppDTName      + '"'
}
$output | Add-Content $SCCMFile
Write-Host "done." -ForegroundColor Green
