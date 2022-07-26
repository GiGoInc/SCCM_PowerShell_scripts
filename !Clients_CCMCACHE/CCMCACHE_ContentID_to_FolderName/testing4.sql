/*
	Home > ConfigMgr_SS1 > Software Distribution - Application Monitoring > All application deployments (advanced)  
 
v_GS_COMPUTER_SYSTEM.CurrentTimeZone0


*/


select adv.AdvertisementName
      ,pkg.Name as C001
      ,pgm.ProgramName
      ,coll.Name as C002
	  ,adv.PresentTime as 'Creation Time',
		count(*) as 'Total',
		sum(case LastState when 13 then 1 else 0 end) as 'Success',
		sum(case LastAcceptanceState when 0 then 1 else 0 end) as 'No Status',
		sum(case LastState when 8 then 1 else 0 end) as 'Waiting',
		sum(case LastState when 11 then 1 else 0 end) as 'Fail',
		sum(case LastAcceptanceState when 2 then 1 else 0 end) as 'Reject'
	  ,adv.AdvertisementID
from v_Advertisement adv
join v_Package pkg on adv.PackageID=pkg.PackageID
join v_Program pgm on adv.PackageID=pgm.PackageID and adv.ProgramName=pgm.ProgramName
join v_Collection coll on adv.CollectionID=coll.CollectionID
join v_ClientAdvertisementStatus stat on adv.AdvertisementID=stat.AdvertisementID

where DATEDIFF(hour,DATEADD(ss,@__timezoneoffset,stat.LastStatusTime),GETDATE())<168

group by adv.AdvertisementID
        ,adv.AdvertisementName
        ,adv.PresentTime
        ,adv.Comment
        ,pkg.Name
        ,pgm.ProgramName
        ,adv.SourceSite
        ,coll.Name
        ,adv.IncludeSubCollection,
(CASE WHEN adv.IncludeSubCollection!=0 then '*' else '' END),
CASE WHEN AssignedScheduleEnabled != 0 or
(AdvertFlags & 0x720) != 0
THEN '*'
ELSE ''
END,
(case when (0x00001000&ProgramFlags)!=0 then '*' else ' ' end)
order by adv.PresentTime DESC