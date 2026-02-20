param (
Move-Collection $SourceContainerNodeID $collID $TargetContainerNodeID

param (
	[string]$sitename,
	[string]$CollectionName
	)

#####
#Functionality: creates a ConfigMgr collection
#Author: David O'Brien
#date: 25.02.2012
#####

Function Create-Collection($CollectionName)
{
    $CollectionArgs = @{
    Name = $CollectionName;
    CollectionType = "2";         # 2 means Collection_Device, 1 means Collection_User
    LimitToCollectionID = "SMS00001"
    }
    Set-WmiInstance -Class SMS_Collection -arguments $CollectionArgs -namespace "root\SMS\Site_$sitename" | Out-Null
}


#####
#Functionality: moves a ConfigMgr collection from one folder to an other
#Author: David O'Brien
#date: 25.02.2012
#####
Function Move-Collection($SourceContainerNodeID,$collID,$TargetContainerNodeID)
{
    $Computer = "."
    $Class = "SMS_ObjectContainerItem"
    $Method = "MoveMembers"
    
    $MC = [WmiClass]"\\$Computer\ROOT\SMS\site_$($sitename):$Class"
    
    $InParams = $mc.psbase.GetMethodParameters($Method)
    
    $InParams.ContainerNodeID = $SourceContainerNodeID #usually 0 when newly created Collection
    $InParams.InstanceKeys = $collID
    $InParams.ObjectType = "5000" #5000 for Collection_Device, 5001 for Collection_User
    $InParams.TargetContainerNodeID = $TargetContainerNodeID #needs to be evaluated
    
    "Calling SMS_ObjectContainerItem. : MoveMembers with Parameters :"
    $inparams.PSBase.properties | select name,Value | format-Table
    
    $R = $mc.PSBase.InvokeMethod($Method, $inParams, $Null)
}



Create-Collection $CollectionName

#evaluate newly created Collection properties, in this case $_.CollectionID is sufficient
$collection = gwmi -Namespace root\sms\site_$sitename -Class SMS_Collection | where {$_.Name -eq "$collectionName"}
$collID = $collection.CollectionID

$SourceContainerNodeID = "0" #usually 0 when newly created Collection
$TargetContainerNodeID = #Needs to be evaluated, depending on where you want to put the collection!

Move-Collection $SourceContainerNodeID $collID $TargetContainerNodeID
