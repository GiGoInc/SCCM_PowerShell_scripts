#Populate the below Variables with dyamic data from your orchestrator workflow or set it statically in the code.
}
	}
#Populate the below Variables with dyamic data from your orchestrator workflow or set it statically in the code.
$SCCMServer = "SCCMServerName"
$SmsSiteCode = "SiteName"
$CollectionID = "CollectionID"
$ComputerName = "ClientName"

$Collection = Get-WmiObject -Namespace "root\SMS\Site_$SmsSiteCode" -Query "select * from SMS_Collection Where SMS_Collection.CollectionID='$CollectionID'" -computername $SCCMServer

$Collection.Get()
ForEach ($Rule in $($Collection.CollectionRules | Where {$_.RuleName -eq "$ComputerName"}))
{
	# Get the SMS_R_System object for the rule
	$ComputerObject = Get-WmiObject -Namespace "root\SMS\Site_$SmsSiteCode" -Query "select * from SMS_R_System where Name='$ComputerName'" -computername $SCCMServer
	$ResourceID = $ComputerObject.ResourceID
	$smsObject = Get-WmiObject -Namespace "root\SMS\Site_$SmsSiteCode" -Query "Select * From SMS_R_System Where ResourceID='$ResourceID'" -computername $SCCMServer
	
	# If the resource is a agent
	if($smsObject.Name -eq "$ComputerName")
	{
		#Delete the membership rule
		$Collection.DeleteMemberShipRule($Rule) | out-null
	}
}
