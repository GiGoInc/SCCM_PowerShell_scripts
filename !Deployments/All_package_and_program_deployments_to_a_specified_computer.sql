/*  All package and program deployments to a specified computer  */
SELECT adv.AdvertisementName AS 'Advertisement Name', 
pkg.Name AS 'Package Name', 
adv.ProgramName AS 'Program Name', 
adv.CollectionID
FROM v_Advertisement  adv 
JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID 
JOIN v_ClientAdvertisementStatus  stat ON stat.AdvertisementID = adv.AdvertisementID 
JOIN v_R_System  sys ON stat.ResourceID=sys.ResourceID 
WHERE sys.Netbios_Name0 = 'computer1'
Order By pkg.Name