,PackageID
,Name
,Version
,Language
,Manufacturer
,Description
,PkgSourceFlag
,PkgSourcePath
,StoredPkgPath
,SourceVersion
,SourceDate
,ShareType
,ShareName
,SourceSite
,ForcedDisconnectEnabled
,ForcedDisconnectNumRetries
,ForcedDisconnectDelay
,Priority
,PreferredAddressType
,IgnoreAddressSchedule
,LastRefreshTime
,PkgFlags
,MIFFilename
,MIFPublisher
,MIFName
,MIFVersion
,ActionInProgress
,ImageFlags
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
,SecurityKey
,ObjectTypeID