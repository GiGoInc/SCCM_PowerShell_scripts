Declare @CollID nvarchar (255),@SUG nvarchar(255);
Set @CollID='SS100010';set @SUG='ADR: Software Updates - All Branch Workstations';
--CollID=Collection ID and SUG=Software update group Name

Select ui.DatePosted AS 'Date Posted',
	ui.Title,
	ui.ArticleID,
	ui.BulletinID,
	ui.DateRevised,
	ui.IsDeployed as 'Deployed',
	ucs.status as 'Required'
From v_UpdateInfo ui
JOIN v_Update_ComplianceStatus ucs on ucs.CI_ID = ui.CI_ID
JOIN v_BundledConfigurationItems bci on ui.CI_ID = bci.BundledCI_ID 
JOIN v_FullCollectionMembership fcm on ucs.ResourceID = fcm.ResourceID
join v_R_System sys on sys.ResourceID=ucs.ResourceID
Where bci.CI_ID = (SELECT CI_ID FROM v_AuthListInfo where title = @SUG)
and
fcm.CollectionID = @CollID
and
ui.IsDeployed='1'
and
ucs.status = '2'
and
ui.IsExpired = '0'
AND
ui.IsSuperseded = '0'