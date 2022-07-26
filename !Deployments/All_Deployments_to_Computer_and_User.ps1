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


$Computer = 'Computer1'
$System = gwmi -computer $computer Win32_ComputerSystem # normally non-terminating
$User = $System.UserName

# $User = 'DOMAIN\user2'

$LogFolder = 'C:\Temp\'
$LogFile = $Computer + "__" + $User.replace('DOMAIN\','') + "--All_Deployments_to_Computer_and_User--Results.csv"
$Log = $LogFolder + $LogFile
If(!(Test-Path $LogFolder)){New-Item -ItemType Directory -Path $LogFolder}


##############################################################################
      $GetSQLInfo_DB = 'CM_SS1'
  $GetSQLInfo_Server = 'sccmserver'
$GetSQLInfo_Instance = 'sccmserver'

##############################################################################
# All package and program deployments to a specified computer 
    $Q_All_PACK_PROG_deploys_to_COMPUTER = "SELECT 
        adv.AdvertisementName AS 'Advertisement Name', 
        pkg.Name AS 'Package Name', 
        adv.ProgramName AS 'Program Name', 
        adv.CollectionID
        FROM v_Advertisement  adv 
        JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID 
        JOIN v_ClientAdvertisementStatus  stat ON stat.AdvertisementID = adv.AdvertisementID 
        JOIN v_R_System  sys ON stat.ResourceID=sys.ResourceID 
        WHERE sys.Netbios_Name0 = '$Computer'
        Order By pkg.Name"

    $Result_All_PACK_PROG_deploys_to_COMPUTER = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $GetSQLInfo_DB  `
        -HostName $GetSQLInfo_Server  `
        -Query $Q_All_PACK_PROG_deploys_to_COMPUTER `
        -QueryTimeout 600 `
        -ServerInstance $GetSQLInfo_Instance
    # $Result_All_PACK_PROG_deploys_to_COMPUTER

##############################################################################
# All package and program deployments to a specified user
    $Q_All_PACK_PROG_deploys_to_user = "SELECT 
        adv.AdvertisementName AS 'Advertisement Name', 
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

##############################################################################
# Application deployments per asset - COMPUTER
    $Q_App_deployments_per_asset__COMPUTER = "SELECT ds.SoftwareName AS SoftwareName, 
        ds.CollectionID,
        ds.CollectionName,
        ad.MachineName,
        ad.UserName,
        dbo.fn_GetAppState(ad.ComplianceState, ad.EnforcementState, cia.OfferTypeID, 1, ad.DesiredState, ad.IsApplicable) AS EnforcementState
        FROM v_R_System  sd
        INNER JOIN v_FullCollectionMembership  cm ON cm.ResourceID = sd.ResourceID
        INNER JOIN v_DeploymentSummary ds ON ds.CollectionID = cm.CollectionID AND ds.FeatureType = 1
        LEFT JOIN v_AppIntentAssetData  ad ON ad.MachineID = cm.ResourceID AND ad.AssignmentID = ds.AssignmentID
        INNER JOIN v_CIAssignment  cia ON cia.AssignmentID = ds.AssignmentID
        WHERE Client0 = 1 AND sd.Netbios_Name0 = '$Computer'
        Order By SoftwareName"
    
    $Result_App_deployments_per_asset__COMPUTER = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $GetSQLInfo_DB  `
        -HostName $GetSQLInfo_Server  `
        -Query $Q_App_deployments_per_asset__COMPUTER `
        -QueryTimeout 600 `
        -ServerInstance $GetSQLInfo_Instance
    # $Result_App_deployments_per_asset__COMPUTER

##############################################################################
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
    # $Result_App_deployments_per_asset__USER
##############################################################################


$Array = @()
#$Array += "Type,CollectionID,Collection Name,Advertisement Name,Package/Software Name,Program Name,EnforcementState"
$Array += "Type,CollectionID,Collection Name,Package/Software Name,Program Name,EnforcementState"

ForEach ($Package in $Result_All_PACK_PROG_deploys_to_COMPUTER)
{
      $CollID = $Package.CollectionID 
     $AdvName = $Package.'Advertisement Name'
     $PkgName = $Package.'Package Name'
    $ProgName = $Package.'Program Name'
    #$Array += "Package Deploy to Computer,$CollID,,$AdvName,$PkgName,$ProgName"
    $Array += "Package Deploy to Computer,$CollID,,$PkgName,$ProgName"
}

ForEach ($UPackage in $Result_All_PACK_PROG_deploys_to_user)
{
      $PUCollID = $UPackage.CollectionID 
     $PUAdvName = $UPackage.'Advertisement Name'
     $PUPkgName = $UPackage.'Package Name'
    $PUProgName = $UPackage.'Program Name'
    #$Array += "Package Deploy to User,$PUCollID,,$PUAdvName,$PUPkgName,$PUProgName"
    $Array += "Package Deploy to User,$PUCollID,,$PUPkgName,$PUProgName"
}

ForEach ($App in $Result_App_deployments_per_asset__COMPUTER)
{
      $CollID = $App.CollectionID 
    $CollName = $App.CollectionName
     $AppName = $App.SoftwareName
     $Enforce = $App.EnforcementState
     If ($Enforce -eq '1000'){$Enforce = 'Installed'}
     If ($Enforce -eq '2001'){$Enforce = 'Waiting for content'}
     If ($Enforce -eq '2009'){$Enforce = 'Content downloaded'}
     If ($Enforce -eq '2013'){$Enforce = 'Content downloaded'}
     If ($Enforce -eq '3000'){$Enforce = 'Not Applicable'}
     If ($Enforce -eq '3001'){$Enforce = 'Content downloaded'}
     If ($Enforce -eq '3001'){$Enforce = 'Host Platform Not Applicable'}
     If ($Enforce -eq '5001'){$Enforce = 'Evaluation failed'}
     If ($Enforce -eq '5003'){$Enforce = 'Failed to locate content'}		 
    #$Array += "Application Deploy to Computer,$CollID,$CollName,,$AppName,,$Enforce"
    $Array += "Application Deploy to Computer,$CollID,$CollName,$AppName,,$Enforce"
}

ForEach ($App in $Result_App_deployments_per_asset__USER)
{
      $AUCollID = $App.CollectionID 
    $AUCollName = $App.CollectionName
     $AUAppName = $App.SoftwareName
     $AUEnforce = $App.EnforcementState
     If ($AUEnforce -eq '1000'){$AUEnforce = 'Installed'}
     If ($AUEnforce -eq '2001'){$AUEnforce = 'Waiting for content'}
     If ($AUEnforce -eq '2009'){$AUEnforce = 'Content downloaded'}
     If ($AUEnforce -eq '2013'){$AUEnforce = 'Content downloaded'}
     If ($AUEnforce -eq '3000'){$AUEnforce = 'Not Applicable'}
     If ($AUEnforce -eq '3001'){$AUEnforce = 'Content downloaded'}
     If ($AUEnforce -eq '3001'){$AUEnforce = 'Host Platform Not Applicable'}
     If ($AUEnforce -eq '5001'){$AUEnforce = 'Evaluation failed'}
     If ($AUEnforce -eq '5002'){$AUEnforce = 'Deployment failed'}
     If ($AUEnforce -eq '5003'){$AUEnforce = 'Failed to locate content'}
    #$Array += "Application Deploy to User,$AUCollID,$AUCollName,,$AUAppName,,$AUEnforce"
    $Array += "Application Deploy to User,$AUCollID,$AUCollName,$AUAppName,,$AUEnforce"
}

$Array | Set-Content $Log
Write-Host "`nOutput written to: " -NoNewline
Write-Host $Log -ForegroundColor Green