SELECT 
CI.CI_ID,
(SUM(FileSize)/1024)/1 as 'Size in KB',
CI.ArticleID,
CI.BulletinID,
LOC.DisplayName,
CI.CustomSeverity,
CI.Severity,
CI.MaxExecutionTime,
TYP.CategoryTypeName,
TYP.CategoryInstanceName,
Case (UI.IsDeployed)
	When 0 Then 'No' 
	Else 'Yes' 
End as 'Deployed',
Case(UI.IsExpired)
	When 0 Then 'No' 
	Else 'Yes' 
End as 'Expired',
CASE(UI.Severity)
	When 2 Then 'Low'
	When 6 Then 'Moderate'
	When 8 Then 'Important' 
	When 10 Then 'Critical' 
	Else 'NA'
End as 'Severity',
UI.DatePosted,
CASE(ui.IsSuperseded)
	When 0 Then 'No' 
	Else 'Yes' 
End as 'Superseded'

FROM v_UpdateContents
JOIN v_UpdateCIs ON v_UpdateCIs.CI_ID = v_UpdateContents.CI_ID
JOIN CI_ContentFiles ON v_UpdateContents.content_id = CI_ContentFiles.Content_ID
JOIN CI_UpdateCIs AS CI ON CI.CI_ID = v_UpdateContents.CI_ID
LEFT JOIN v_LocalizedCIProperties_SiteLoc AS LOC ON LOC.CI_ID=ci.CI_ID
LEFT JOIN v_CICategoryInfo TYP ON TYP.CI_ID=ci.CI_ID AND TYP.CategoryTypeName = 'UpdateClassification'
LEFT JOIN CI_UpdateInfo INF ON inf.CI_ID=ci.CI_ID
LEFT JOIN v_UpdateInfo UI ON UI.CI_ID = ci.CI_ID
WHERE UI.DatePosted BETWEEN '1/1/2013' AND '12/31/2021'

GROUP BY 
CI.CI_ID ,
CI.ArticleID,
CI.BulletinID,
LOC.DisplayName,
CI.CustomSeverity,
CI.Severity,
CI.MaxExecutionTime,
TYP.CategoryTypeName,
TYP.CategoryInstanceName,
Case (UI.IsDeployed)
	When 0 Then 'No' 
	Else 'Yes' 
End,
Case(UI.IsExpired)
	When 0 Then 'No' 
	Else 'Yes' 
End,
CASE(UI.Severity)
	When 2 Then 'Low'
	When 6 Then 'Moderate'
	When 8 Then 'Important' 
	When 10 Then 'Critical' 
	Else 'NA'
End,
UI.DatePosted,
CASE(UI.IsSuperseded)
	When 0 Then 'No' 
	Else 'Yes' 
End
ORDER BY DatePosted desc