SELECT v_CIToContent.Content_UniqueID, v_UpdateInfo.Title
FROM CI_ContentPackages
INNER JOIN v_CIToContent ON CI_ContentPackages.Content_UniqueID = v_CIToContent.Content_UniqueID
LEFT OUTER JOIN v_UpdateInfo ON v_CIToContent.CI_ID = v_CIToContent.CI_ID

4ae5f6e6-e699-495c-a570-8430e6d4bcf1	19649	1	3/20/2017 4:36:30 AM	C:\WINDOWS\ccmcache\1z	
3408a14a-e827-49b4-91da-8b8660e8e9ed	1	0	0	True

/*

SELECT v_UpdateInfo.Title
	  ,v_CIToContent.Content_UniqueID
FROM v_CIToContent
JOIN CI_ContentPackages ON v_CIToContent.Content_UniqueID = CI_ContentPackages.Content_UniqueID
JOIN v_UpdateInfo ON v_CIToContent.Content_UniqueID = v_UpdateInfo.CI_ID


*/


SELECT *
FROM v_CIToContent
where Content_UniqueID = '3408a14a-e827-49b4-91da-8b8660e8e9ed'
order by CI_ID


SELECT CI_ID,Modelname, Title
FROM v_UpdateInfo
where CI_ID = '17182124'

SELECT *
FROM CI_ContentPackages
where Content_UniqueID = '3408a14a-e827-49b4-91da-8b8660e8e9ed'



v_UpdateInfo.CI_ID = '17182124'
v_CIToContent.CI_ID = '17182124'

v_CIToContent.Content_UniqueID = '414593a1-1090-46ef-9dd4-c64c7c97299a'
CI_ContentPackages.Content_UniqueID = '414593a1-1090-46ef-9dd4-c64c7c97299a'