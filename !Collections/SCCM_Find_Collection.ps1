param($collectionid,$Direction)
if ($direction -eq "down") {FindCollectionDown $collectionid} 
if ($direction -eq "up") {FindCollectionUP $collectionid}
param($collectionid,$Direction)

$script:siteserver = "SERVER"
$script:sitecode = "XX1"
function FindCollectionDown
{
param($parentcollID)

$subcollections = Get-WmiObject -ComputerName $script:siteserver -namespace root\sms\site_$Script:sitecode -query "select * from sms_collection where collectionid in (select subcollectionid from sms_collecttosubcollect where parentcollectionid = '$parentcollID')"
if ($subcollections -ne $null)
{
foreach ($subcoll in $subcollections)
{
Write-Output $subcoll.name
FindCollectionDown $subcoll.collectionid
}
}
}

function FindCollectionUP
{
param($collID)
do
{
$parentColl = (Get-WmiObject -ComputerName $script:siteserver -namespace root\sms\site_$Script:sitecode -query "select name from sms_collection where collectionid in (select parentcollectionid from sms_collecttosubcollect where subcollectionid = '$collid')").name
$collID = (Get-WmiObject -ComputerName $script:siteserver -namespace root\sms\site_$Script:sitecode -query "select collectionid from sms_collection where name = '$parentcoll'").collectionid
Write-Output $ParentColl

}
while ($parentColl -ne "Root Collection")

}

if ($direction -eq "up") {FindCollectionUP $collectionid}
if ($direction -eq "down") {FindCollectionDown $collectionid} 
