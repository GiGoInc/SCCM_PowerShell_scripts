$Computer = 'COMPUTER77'
$Content | Add-Content $Log
'FEATURETYPETEXT,DEPLOYMENTNAME,TARGETNAME,TARGETSUBNAME,COLLECTIONID,COLLECTIONNAME,DEPLOYMENTID,DEPLOYMENTTYPEID' | Set-Content $Log
$Computer = 'COMPUTER77'

##########################################################################
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$Log = "D:\Powershell\!SCCM_PS_scripts\$ADate--All_Deployments_for-$computer.csv"
$Null | Set-Content $Log
##########################################################################
$SQL_Query = "select
DeploymentID,
DeploymentTypeID,
Case
when ds.FeatureType = 1 then 'Application'
when ds.FeatureType = 2 then 'Program'
when ds.FeatureType = 3 then 'MobileProgram'
when ds.FeatureType = 4 then 'Script'
when d.DeploymentTypeID = 5 then 'SoftwareUpdate'
when ds.FeatureType = 6 then 'Baseline'
when ds.FeatureType = 7 then 'TaskSequence'
when ds.FeatureType = 8 then 'ContentDistribution'
when ds.FeatureType = 9 then 'DistributionPointGroup'
when ds.FeatureType = 10 then 'DistributionPointHealth'
when ds.FeatureType = 11 then 'ConfigurationPolicy'
when ds.FeatureType = 28 then 'AbstractConfigurationItem'
end as 'FeatureTypeText'
,DeploymentName
, TargetName
, TargetSubName
, d.CollectionID
, d.CollectionName
from v_R_System s
inner join CollectionMembers cm on s.ResourceID = cm.MachineID
inner join fn_ListDeployments(1033) d on cm.SiteID = d.CollectionID
left join v_DeploymentSummary ds on ds.SoftwareName = d.TargetName
where s.Name0 = '$Computer'
order by DeploymentName"
##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'
##########################################################################
    $SQL_Check = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
#$SQL_Check | Out-File "D:\Powershell\!SCCM_PS_scripts\All_Deployments_for_a_device.csv"
##########################################################################
ForEach ($Check in $SQL_Check)
{
    If (($Check.FeatureTypeText -notmatch 'BASELINE') -and `
        ($Check.FeatureTypeText -notmatch 'TASKSEQUENCE') -and `
        ($Check.FeatureTypeText -notmatch 'SoftwareUpdate'))
    {
        If ($Check.FeatureTypeText -is [DBNull]){ $Check.FeatureTypeText = 'NULL'}
        $Check.FEATURETYPETEXT + ',' + $Check.DEPLOYMENTNAME + ',' + $Check.TARGETNAME + ',' + $Check.TARGETSUBNAME + ',' + $Check.COLLECTIONID + ',' + $Check.COLLECTIONNAME + ',' + $Check.DEPLOYMENTID + ',' + $Check.DEPLOYMENTTYPEID | Add-Content $Log
    }
}
$Content = Get-Content -Path $Log | sort -Unique
'FEATURETYPETEXT,DEPLOYMENTNAME,TARGETNAME,TARGETSUBNAME,COLLECTIONID,COLLECTIONNAME,DEPLOYMENTID,DEPLOYMENTTYPEID' | Set-Content $Log
$Content | Add-Content $Log
