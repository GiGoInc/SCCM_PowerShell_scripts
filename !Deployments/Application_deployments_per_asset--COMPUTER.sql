/*  Application deployments per asset -- COMPUTER */
SELECT ds.SoftwareName AS SoftwareName, 
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
WHERE Client0 = 1 AND sd.Netbios_Name0 = 'computer1'
order by SoftwareName