# ==============================================================================================

[void][System.Windows.Forms.MessageBox]::Show($output , "$($DisplayName) Folder Path")
# ==============================================================================================
# 
# NAME: Get-SccmObjFolderPath
# 
# AUTHOR: Duncan Russell, http://www.sysadmintechnotes.com
# DATE  : 8/29/2013
# 
# COMMENT: 
# 
# ==============================================================================================
param ([string]$ObjectId,
[string]$ObjectTypeName,
[string]$DisplayName,
[string]$BaseTableColumn
)
 
############################################
#
# Change for your own environment
#

$SiteCode = "[MYSITECODE]"
$CMProvider = "[MYCMPROVIDER]"

#
############################################

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$PathArray = @()

# query WMI for the object, to see if it is in the SMS_ObjectContainerItem class (meaning it is in a folder)
$SourceFolder = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace root\sms\site_$SiteCode -Filter "InstanceKey = '$($ObjectId)' AND ObjectTypeName = '$($ObjectTypeName)'" -ComputerName $CMProvider).ContainerNodeId

if (($SourceFolder -ne 0) -and ($SourceFolder -ne $null))
{
	# recurse through SMS_ObjectContainerNode class to find folder path back to the root node

	while ($SourceFolder -ne 0)
	{
		$ObjectNode = (Get-WmiObject -Class SMS_ObjectContainerNode -Namespace root\sms\site_$SiteCode -Filter "ContainerNodeId = '$($SourceFolder)'" -ComputerName $CMProvider)
		$PathArray = ,"$($ObjectNode.Name)" + $PathArray
		$SourceFolder = $ObjectNode.ParentContainerNodeId
		$ObjectNode = $null
	}
	
	# make it pretty
	for ($i=0; $i -lt $PathArray.count; $i++)
	{
		if($i -gt 0)
		{
			$PathArray[$i] = " " * $i * 5 + "-> " + $PathArray[$i]
		}
	}
	[string]$sep = "`n"
	$output = [string]::join($sep, $PathArray)
}
elseif ($SourceFolder -eq $null)
{
	# see if it is an actual object, which means it is at the root node of its location
	switch -wildcard ($ObjectTypeName)
	{
		'sms_collection_*' {$ObjectTypeName = "sms_collection"}
	}
	# TODO: use switch to find SMS_COLLECTION_USER or SMS_COLLECTION_DEVICE, change to SMS_COLLECTION (get rid of $BaseTable param)
	$c = (Get-WmiObject -Class $ObjectTypeName -Namespace root\sms\site_$SiteCode -Filter "$($BaseTableColumn) = '$($ObjectId)'" -ComputerName $CMProvider) | measure
	if ($c.count -gt 0)
	{
		$output = "$($DisplayName) is at the root node."
	}
	else
	{
		$output = "ERROR: $($DisplayName) not found."
	}
}


[void][System.Windows.Forms.MessageBox]::Show($output , "$($DisplayName) Folder Path")

