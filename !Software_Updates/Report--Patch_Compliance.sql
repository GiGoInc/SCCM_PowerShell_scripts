select
      CS.Name0,
      CS.UserName0,
case
when (sum(case when UCS.status=2 then 1 else 0 end))>0 then ((cast(sum(case when UCS.status=2 then 1 else 0 end)as varchar(10))))
else 'Good Client'
end as '# of Patches Required',
      ws.lasthwscan as 'Last HW scan',
      FCM.collectionID--,
from v_UpdateComplianceStatus UCS
left outer join dbo.v_GS_COMPUTER_SYSTEM  CS on CS.ResourceID = UCS.ResourceID
join v_CICategories_All catall2 on catall2.CI_ID=UCS.CI_ID
join v_CategoryInfo catinfo2 on catall2.CategoryInstance_UniqueID = catinfo2.CategoryInstance_UniqueID and catinfo2.CategoryTypeName='UpdateClassification'
left join v_gs_workstation_status ws on ws.resourceid=CS.resourceid
left join v_fullcollectionmembership FCM on FCM.resourceid=CS.resourceid
Where
      UCS.Status = '2'
and FCM.collectionid = 'SMS00001'
Group by
      CS.Name0,
      CS.UserName0,
      ws.lasthwscan,
      FCM.collectionID
Order by
      CS.Name0,
      CS.UserName0,
      ws.lasthwscan,
      FCM.collectionID