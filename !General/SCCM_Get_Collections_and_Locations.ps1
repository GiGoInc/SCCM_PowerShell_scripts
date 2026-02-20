$FolderLog = 'C:\Temp\SCCM_FolderLog.csv'
}
    "`"$Name`",`"$MemberCount`",`"$CollectionID`",`"$ObjectPath`",`"$LimitToCollectionName`",`"$LimitToCollectionID`",`"$IsBuiltIn`"" | Add-Content $FolderLog
$FolderLog = 'C:\Temp\SCCM_FolderLog.csv'

$SiteCode="XX1"
$SiteServer = "SERVER"
$AllCollections = Get-WmiObject -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer
# $AllCollections.objectpath

"Name,MemberCount,CollectionID,ObjectPath,LimitToCollectionName,LimitToCollectionID,IsBuiltIn" | Set-Content $FolderLog

ForEach ($Collection in $AllCollections)
{
    $Name                  = $Collection.Name
    $MemberCount           = $Collection.MemberCount
    $CollectionID          = $Collection.CollectionID
    $ObjectPath            = $Collection.ObjectPath
    $LimitToCollectionName = $Collection.LimitToCollectionName
    $LimitToCollectionID   = $Collection.LimitToCollectionID
    $IsBuiltIn             = $Collection.IsBuiltIn
    
    "`"$Name`",`"$MemberCount`",`"$CollectionID`",`"$ObjectPath`",`"$LimitToCollectionName`",`"$LimitToCollectionID`",`"$IsBuiltIn`"" | Add-Content $FolderLog
}
