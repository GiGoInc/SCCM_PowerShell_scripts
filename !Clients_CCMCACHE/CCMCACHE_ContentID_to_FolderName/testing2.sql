SELECT pkg.Name as [Package Name]
	  ,scia.CIVersion
      ,pkg.Version
      ,pkg.PackageID
        ,CASE pkg.PackageType
         WHEN 0 THEN 'Software Distribution Package'
         WHEN 3 THEN 'Driver Package'
         WHEN 4 THEN 'Task Sequence Package'
         WHEN 5 THEN 'Software Update Package'
         WHEN 6 THEN 'Device Settings Package'
         WHEN 7 THEN 'Virtual Package'
         WHEN 257 THEN 'Image Package'
         WHEN 258 THEN 'Boot Image Package'
         WHEN 259 THEN 'OS Install Package'
         END AS [Package Type]
      ,adv.AdvertisementID
      ,tsp.Name as [TS Name]
FROM v_Package pkg
LEFT JOIN v_Advertisement adv on pkg.PackageID=adv.PackageID
LEFT JOIN v_TaskSequencePackageReferences tsr on pkg.PackageID=tsr.RefPackageID
LEFT JOIN v_TaskSequencePackage tsp on tsr.PackageID=tsp.PackageID
LEFT JOIN vSMS_ConfigurationItems_All scia on pkg.SecurityKey=scia.Modelname
WHERE adv.AdvertisementID is null
AND tsp.Name is null
ORDER BY pkg.PackageType



8021x Image Script
SS1002EE
Software Distribution Package
NULL
NULL