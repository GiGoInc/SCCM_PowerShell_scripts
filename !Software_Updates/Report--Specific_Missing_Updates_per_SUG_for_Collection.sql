Declare @CollID nvarchar (255),@SUG nvarchar(255);
Set @CollID='SS1008BB';set @SUG='ADR: Software Updates - Servers';
set @title='Security Update for Windows Server 2008 R2 x64 Edition (KB2992611)'
--CollID=Collection ID , SUG=Software update group Name and Title= Name of Software update title

Select sys.Name0,sys.User_Name0,os.Caption0 [OS],ws.LastHWScan,uss.LastScanTime [Last SUScan],os.LastBootUpTime0
From v_UpdateInfo ui
JOIN v_Update_ComplianceStatus ucs on ucs.CI_ID = ui.CI_ID
JOIN v_BundledConfigurationItems bci on ui.CI_ID = bci.BundledCI_ID 
JOIN v_FullCollectionMembership fcm on ucs.ResourceID = fcm.ResourceID
join v_R_System sys on sys.ResourceID=ucs.ResourceID
join v_GS_OPERATING_SYSTEM OS on os.ResourceID=ucs.ResourceID
join v_GS_WORKSTATION_STATUS WS on ws.ResourceID=ucs.ResourceID
right join v_UpdateScanStatus uss on uss.ResourceID=ucs.ResourceID
where bci.CI_ID = (SELECT CI_ID FROM v_AuthListInfo where title=@SUG)
and fcm.CollectionID =@CollID
AND UCS.Status='2'
and ui.Title=@title
group by 
sys.Name0,sys.User_Name0,os.Caption0,ws.LastHWScan,os.LastBootUpTime0,uss.LastScanTime
order by 1