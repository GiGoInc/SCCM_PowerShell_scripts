#Title:Delete computer records from specific collection .
}
    
#Title:Delete computer records from specific collection .
#Author:Eswar Koneti
#dated:19-Sep-2014
#Contact via: www.eskonr.com
param(
[String[]] $Collections
)

foreach ($CollectionID in $Collections)
{

	#*****************************common functions start here******************************************
	#if you are not running the script on your SCCM Server(SMS provider),you will have to provide the SCCM server name here. Replace Localhost with your SCCM server
	$SMSProvider = "localhost"
	 Function Get-SiteCode
	{
	$wqlQuery = “SELECT * FROM SMS_ProviderLocation”
	$a = Get-WmiObject -Query $wqlQuery -Namespace “root\sms” -ComputerName $SMSProvider
	#Write-Output $a
	$a | ForEach-Object {
	if($_.ProviderForLocalSite)
	{
	$script:SiteCode = $_.SiteCode
	}
	}
	}
	Get-SiteCode
	#Import the CM12 Powershell cmdlets
	if (-not (Test-Path -Path $SiteCode))
	{
	Write-Verbose "$(Get-Date):   CM12 module has not been imported yet, will import it now."
	Import-Module ($env:SMS_ADMIN_UI_PATH.Substring(0,$env:SMS_ADMIN_UI_PATH.Length – 5) + '\ConfigurationManager.psd1') | Out-Null
	}
	#CM12 cmdlets need to be run from the CM12 drive
	Set-Location "$($SiteCode):" | Out-Null
	if (-not (Get-PSDrive -Name $SiteCode))
	{
	Write-Error "There was a problem loading the Configuration Manager powershell module and accessing the site's PSDrive."
	exit 1
	}
	#***************Common functions ends here************************************************************

	$GetCOLL=Get-WmiObject -Class SMS_collection -Namespace root\SMS\Site_$SiteCode -Filter "CollectionID = '$CollectionID'"

	if ($GetCOLL) {
	#get count of resources from the given collection
	$collectioncount = (Get-WmiObject -Class SMS_FullCollectionMembership -Namespace root\SMS\Site_$SiteCode -Filter "CollectionID = '$CollectionID'"| Measure-Object).Count

	#check if the collection is blank or any resources exist
	if ($collectioncount -gt 0)
		{
		 #Get list of computers
		 $compobject=Get-WmiObject -Class SMS_FullCollectionMembership -Namespace root\SMS\Site_$SiteCode -Filter "CollectionID = '$CollectionID'"
		 
			  foreach ($pc in $compobject)
			  {
			 $pcname=$pc.Name
			 $pcname +" will be deleted from " + $CollectionID | out-file -FilePath "$($PSScriptRoot)\Deletion_script_Ran_at $(get-date -f yyyy-MM-dd).txt" -append
			 $comp=get-wmiobject -query "select * from SMS_R_SYSTEM WHERE Name='$Pcname'" -computername $SMSProvider -namespace "ROOT\SMS\site_$sitecode"
			 $comp.psbase.delete()
			 }
			 #Update the collection
		Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='$CollectionID'" -Name RequestRefresh -ComputerName $SMSProvider

		 }
		 }
		 #If the Supplied collection not found--Deleted for some Reason
		  else
		 {
		 "collectionID "+$CollectionID+" Not found" | out-file -FilePath "$($PSScriptRoot)\Deletion_script_Ran_at $(get-date -f yyyy-MM-dd).txt" -append
		 }
    
}
