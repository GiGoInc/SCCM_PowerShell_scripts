Declare @CollID nvarchar (255),@SUG nvarchar(255);
Set @CollID='SS1008BB';set @SUG='ADR: Software Updates - Servers';
--CollID=Collection ID and SUG=Software update group Name

Select top 5 CAST(DATEPART(yyyy,ui.DatePosted) AS varchar(255)) + '-' + RIGHT('0' + CAST(DATEPART(mm, ui.DatePosted) AS VARCHAR(255)), 2) AS MonthPosted,
ui.Title, ui.ArticleID, ui.BulletinID, ui.DateRevised,
case when ui.IsDeployed='1' then 'Yes' else 'No' end as 'Deployed',
--SUM (CASE WHEN ucs.status=3 or ucs.status=1 then 1 ELSE 0 END ) as 'Installed/Not Required',
sum( case When ucs.status=2 Then 1 ELSE 0 END ) as 'Required'
From v_UpdateInfo ui
JOIN v_Update_ComplianceStatus ucs on ucs.CI_ID = ui.CI_ID --AND ui.IsExpired = 0 AND ui.IsSuperseded = 0
--If you want display the expired and superdeded patches, remove the -- line in the above query
JOIN v_BundledConfigurationItems bci on ui.CI_ID = bci.BundledCI_ID 
JOIN v_FullCollectionMembership fcm on ucs.ResourceID = fcm.ResourceID
join v_R_System sys on sys.ResourceID=ucs.ResourceID
where bci.CI_ID = (SELECT CI_ID FROM v_AuthListInfo where title=@SUG)
and fcm.CollectionID =@CollID 
group by CAST(DATEPART(yyyy,ui.DatePosted) AS varchar(255)) + '-' + RIGHT('0' + CAST(DATEPART(mm, ui.DatePosted) AS VARCHAR(255)), 2),
ui.Title, ui.ArticleID, ui.BulletinID, ui.DateRevised, ui.IsDeployed
order by sum( case When ucs.status=2 Then 1 ELSE 0 END ) desc