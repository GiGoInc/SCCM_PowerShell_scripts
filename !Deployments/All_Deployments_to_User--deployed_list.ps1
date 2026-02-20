# Load SQL 2014 Module
Write-Host $Log -ForegroundColor Green
Write-Host "`nOutput written to: " -NoNewline
# Load SQL 2014 Module
If (Test-Path "C:\Program Files\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1")
{
    # Write-host "Loading SQL 2014 x64 Module" -ForegroundColor Cyan
    Import-Module "C:\Program Files\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1"
}

# Load SQL 2016 Module
If (Test-Path "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1")
{
    # Write-host "Loading SQL 2014 x86 Module" -ForegroundColor Cyan
    Import-Module "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\PowerShell\Modules\SQLPS\SQLPS.PS1"
}
##############################################################################################################################################
###################################################################################################################
###################################################################################
$User = 'DOMAIN\aUSER1'
$LogFolder = 'C:\Temp\'
###################################################################################
###################################################################################################################
##############################################################################################################################################
$LogFile = "" + $User.replace('DOMAIN\','') + "--All_Deployments_to_User--Results.csv"
$Log = $LogFolder + $LogFile
If(!(Test-Path $LogFolder)){New-Item -ItemType Directory -Path $LogFolder}
      $GetSQLInfo_DB = 'CM_XX1'
  $GetSQLInfo_Server = 'SERVER'
$GetSQLInfo_Instance = 'SERVER'
<##############################################################################
#  Doesn't seem to work, I assume the query is incorrect, as there should be at least one package deployed to a SDG group
# All package and program deployments to a specified user
    $Q_All_PACK_PROG_deploys_to_user = "SELECT adv.AdvertisementName AS 'Advertisement Name', 
        pkg.Name AS 'Package Name', 
        adv.ProgramName AS 'Program Name', 
        adv.CollectionID
        FROM v_Advertisement  adv 
        JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID 
        JOIN v_ClientAdvertisementStatus  stat on stat.AdvertisementID = adv.AdvertisementID
        JOIN v_ClassicDeploymentAssetDetails  cdad ON cdad.DeploymentID = adv.AdvertisementID 
        WHERE cdad.UserName = '$User'
        Order By pkg.Name"
    
    $Result_All_PACK_PROG_deploys_to_user = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $GetSQLInfo_DB  `
        -HostName $GetSQLInfo_Server  `
        -Query $Q_All_PACK_PROG_deploys_to_user `
        -QueryTimeout 600 `
        -ServerInstance $GetSQLInfo_Instance
    # $Result_All_PACK_PROG_deploys_to_user
##############################################################################>
# Application deployments per asset - USER
    $Q_App_deployments_per_asset__USER = "SELECT ds.SoftwareName AS SoftwareName, 
        ds.CollectionID,
        ds.CollectionName,
        ad.MachineName,
        ad.UserName,
        dbo.fn_GetAppState(ad.ComplianceState, ad.EnforcementState, cia.OfferTypeID, 1, ad.DesiredState, ad.IsApplicable) AS EnforcementState
        FROM v_CollectionExpandedUserMembers  cm
        INNER JOIN v_R_User  ud ON ud.ResourceID= cm.UserItemKey
        INNER JOIN v_DeploymentSummary ds ON ds.CollectionID = cm.SiteID
        LEFT JOIN v_AppIntentAssetData  ad ON ad.UserName = '$User' AND ad.AssignmentID = ds.AssignmentID
        INNER JOIN v_CIAssignment  cia ON cia.AssignmentID = ds.AssignmentID
        WHERE ud.Unique_User_Name0 = '$User' AND ds.FeatureType = 1
        Order By SoftwareName"
    
    $Result_App_deployments_per_asset__USER = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $GetSQLInfo_DB  `
        -HostName $GetSQLInfo_Server  `
        -Query $Q_App_deployments_per_asset__USER `
        -QueryTimeout 600 `
        -ServerInstance $GetSQLInfo_Instance

$Array = @()
$Array += "Type,CollectionID,Collection Name,Package/Software Name,Program Name"
<##############################################################################
#  Doesn't seem to work, I assume the query is incorrect, as there should be at least one package deployed to a SDG group
ForEach ($UPackage in $Result_All_PACK_PROG_deploys_to_user)
{
      $PUCollID = $UPackage.CollectionID 
     $PUAdvName = $UPackage.'Advertisement Name'
     $PUPkgName = $UPackage.'Package Name'
    $PUProgName = $UPackage.'Program Name'
    $Array += "Package Deploy to User,$PUCollID,,$PUPkgName,$PUProgName"
}
##############################################################################>
ForEach ($App in $Result_App_deployments_per_asset__USER)
{
      $AUCollID = $App.CollectionID 
    $AUCollName = $App.CollectionName
     $AUAppName = $App.SoftwareName
    $Array += "Application Deploy to User,$AUCollID,$AUCollName,$AUAppName"
}
# WRITE LOG
$Array | Set-Content $Log
Write-Host "`nOutput written to: " -NoNewline
Write-Host $Log -ForegroundColor Green
