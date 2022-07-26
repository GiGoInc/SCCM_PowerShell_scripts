/*  Application deployments per asset -- USER */
SELECT ds.SoftwareName AS SoftwareName, 
ds.CollectionID,
ds.CollectionName,
ad.MachineName,
ad.UserName,
dbo.fn_GetAppState(ad.ComplianceState, ad.EnforcementState, cia.OfferTypeID, 1, ad.DesiredState, ad.IsApplicable) AS EnforcementState
FROM v_CollectionExpandedUserMembers  cm
INNER JOIN v_R_User  ud ON ud.ResourceID= cm.UserItemKey
INNER JOIN v_DeploymentSummary ds ON ds.CollectionID = cm.SiteID
LEFT JOIN v_AppIntentAssetData  ad ON ad.UserName = 'domain\user2' AND ad.AssignmentID = ds.AssignmentID
INNER JOIN v_CIAssignment  cia ON cia.AssignmentID = ds.AssignmentID
WHERE ud.Unique_User_Name0 = 'domain\user2' AND ds.FeatureType = 1
order by SoftwareName