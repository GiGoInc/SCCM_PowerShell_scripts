cls
$ADateS = Get-Date
Write-Host "$(Get-date) --- starting..." -ForegroundColor Green
$LogFolder = 'D:\Powershell\!SCCM_PS_scripts\Users_to_SCCM_Groups'

$Users = 'user1','user12','user13'

$Total = $Users.length
Write-Host "Checking $Total users..." -ForegroundColor Magenta
$i = 1
ForEach ($UserID in $Users)
{
    "Checking $i of $total"
    $Output = @()
    $output += "$UserID"
    ########################################
    $SQL_Query = "SELECT ds.SoftwareName AS SoftwareName, 
                  ds.CollectionID,
                  ds.CollectionName,
                  ad.MachineName,
                  ad.UserName,
                  dbo.fn_GetAppState(ad.ComplianceState, ad.EnforcementState, cia.OfferTypeID, 1, ad.DesiredState, ad.IsApplicable) AS EnforcementState
                  FROM v_CollectionExpandedUserMembers  cm
                  INNER JOIN v_R_User  ud ON ud.ResourceID= cm.UserItemKey
                  INNER JOIN v_DeploymentSummary ds ON ds.CollectionID = cm.SiteID
                  LEFT JOIN v_AppIntentAssetData  ad ON ad.UserName = 'Domain\$UserID' AND ad.AssignmentID = ds.AssignmentID
                  INNER JOIN v_CIAssignment  cia ON cia.AssignmentID = ds.AssignmentID
                  WHERE ud.Unique_User_Name0 = 'Domain\$UserID' AND ds.FeatureType = 1
                  order by SoftwareName"

          $DB = 'CM_SS1'
      $Server = 'sccmserverdb'
       $Query = $SQL_Query
    $Instance = 'sccmserverdb'

    # Run SQl
    $QueryInvoke = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $DB  `
        -HostName $Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $Instance
    # $QueryInvoke.SoftwareName
    ########################################
    ForEach ($Item in $QueryInvoke)
    {
        If ($Item.CollectionName -match 'SDG*')
        {
            $Output += $Item.CollectionName + ' -- ' + $Item.SoftwareName
        }
    }
    $string = $Output | Select -Unique
    $string -join "," | Add-Content "$LogFolder\Users_to_SCCM_Groups---SQL_FAST--Results__$ADate.csv"
    $i++
}
# FINALLY - Write Time
    Write-Host "$(Get-date) --- done..."
    $ADateE = Get-Date
    $t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
    $min = $t.Minutes
    $sec = $t.seconds
    Write-Host "Script ran:`t$min minutes and $sec seconds."


<#
########################################
# Single User Check - START
$UserID = 'LPHILLI'
########################################
# SCCM Module - Check
Write-Host "Checking via SCCM Module..." -ForegroundColor Magenta
    $Output1 = @()
    $AN = (Get-SCCMUserCollectionDeployment -UserName "$UserID" -SiteCode 'SS1' -ComputerName 'sccmserver' | sort TargetName) 
    ForEach ($App in $AN)
    {
        If ($App.CollectionName -match 'SDG*')
        {
            $Output1 += $($App.CollectionName) + ' -- ' + $($App.targetname)
        }
    }
    $Output1 | Select -Unique
########################################
# SQL Query - Check
    Write-Host "`nChecking via SQL Query..." -ForegroundColor Yellow
    $Output2 = @()
    $SQL_Query = "SELECT ds.SoftwareName AS SoftwareName, 
                  ds.CollectionID,
                  ds.CollectionName,
                  ad.MachineName,
                  ad.UserName,
                  dbo.fn_GetAppState(ad.ComplianceState, ad.EnforcementState, cia.OfferTypeID, 1, ad.DesiredState, ad.IsApplicable) AS EnforcementState
                  FROM v_CollectionExpandedUserMembers  cm
                  INNER JOIN v_R_User  ud ON ud.ResourceID= cm.UserItemKey
                  INNER JOIN v_DeploymentSummary ds ON ds.CollectionID = cm.SiteID
                  LEFT JOIN v_AppIntentAssetData  ad ON ad.UserName = 'Domain\$UserID' AND ad.AssignmentID = ds.AssignmentID
                  INNER JOIN v_CIAssignment  cia ON cia.AssignmentID = ds.AssignmentID
                  WHERE ud.Unique_User_Name0 = 'Domain\$UserID' AND ds.FeatureType = 1
                  order by SoftwareName"

          $DB = 'CM_SS1'
      $Server = 'sccmserverdb'
       $Query = $SQL_Query
    $Instance = 'sccmserverdb'
    # Run SQl
    $QueryInvoke = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $DB  `
        -HostName $Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $Instance
ForEach ($Item in $QueryInvoke)
{
    If ($Item.CollectionName -match 'SDG*')
    {
        $Output2 += $Item.CollectionName + ' -- ' + $Item.SoftwareName
    }
}
$Output2 | Select -Unique
########################################
#>
