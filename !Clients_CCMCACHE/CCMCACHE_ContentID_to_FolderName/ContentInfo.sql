SELECT LP.DisplayName,
CP.CI_ID,
CPS.PkgID,
CPS.ContentSubFolder
FROM dbo.CI_ContentPackages CPS
INNER JOIN dbo.CIContentPackage CP
ON CPS.PkgID = CP.PkgID
LEFT OUTER JOIN dbo.CI_LocalizedProperties LP
ON CP.CI_ID = LP.CI_ID
ORDER BY LP.LocaleID DESC