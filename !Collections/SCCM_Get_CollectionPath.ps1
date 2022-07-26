param([string]$CentralSiteServer,[string[]]$CollectionID)
	Function Get-CollectionName ($CollectionID)
	{
		$CollectionName = (Get-WmiObject -ComputerName $CentralSiteProvider -Namespace root\sms\site_$CentralSiteCode -Query "Select * from SMS_Collection where CollectionID = '$CollectionID'").name
		Return $CollectionName
	}
	Function Get-ParentCollectionID ($subCollectionID)
	{
		$arrParentCollectionID =@()
		$objCollectToSubCollect = Get-WmiObject -ComputerName $CentralSiteProvider -Namespace root\sms\site_$CentralSiteCode -Query "Select * from SMS_CollectToSubCollect where SubCollectionID = '$subCollectionID'"
		if (($objCollectToSubCollect.GetType()).IsArray -eq $true)
		{
			Foreach ($item in $objCollectToSubCollect)
			{
				$arrParentCollectionID += $item.ParentCollectionID
			}
		} else {
			$arrParentCollectionID += $objCollectToSubCollect.ParentCollectionID
		}
		Return $arrParentCollectionID
	}
	
	Function Get-CollectionPathObject ($strBaseCollectionPath, $CollectionID)
	{
		$CollectionName = Get-CollectionName $CollectionID
		if ($strBaseCollectionPath -eq $null) {$strBaseCollectionPath = "$CollectionName($CollectionID)"}
		$arrParentID = Get-ParentCollectionID $CollectionID
		$arrObjPath = @()
		Foreach ($CollectionID in $arrParentID)
		{
			$ParentCollectionName = Get-CollectionName $CollectionID
			$strCollectionPath = "$ParentCollectionName($CollectionID)\"+$strBaseCollectionPath
			$objCollectionPath = New-Object psobject
			Add-Member -InputObject $objCollectionPath -membertype noteproperty -name CollectionPath -value $strCollectionPath
			Add-Member -InputObject $objCollectionPath -MemberType NoteProperty -Name ParentCollectionID -Value $CollectionID
			$arrObjPath += $objCollectionPath
		}
		Return $arrObjPath
	}

	$objSite = Get-WmiObject -ComputerName $CentralSiteServer -Namespace root\sms -query "Select * from SMS_ProviderLocation WHERE ProviderForLocalSite = True"
	$CentralSiteCode= $objSite.SiteCode
	$CentralSiteProvider = $objSite.Machine
	
	$arrObjCollectionPath = new-object System.Collections.ArrayList
	$bFinished = $false
	$arrPath = Get-CollectionPathObject $strCollectionPath $CollectionID

	Foreach ($item in $arrPath) {$arrObjCollectionPath.Add($item) | Out-Null}
	Remove-Variable arrPath
	Do{
		$arrObjTempNew = @()
		$arrObjTempOld = @()
		Foreach ($item in $arrObjCollectionPath)
		{
				$objCollectionPath = Get-CollectionPathObject $item.CollectionPath $item.ParentCollectionID
				Foreach ($objPath in $objCollectionPath) {$arrObjTempNew += $objPath}
				$arrObjTempNew += $objCollectionPath
				$arrObjTempOld += $item
		}
		Foreach ($OldItem in $arrObjTempOld) {$arrObjCollectionPath.Remove($OldItem)}
		Foreach ($NewItem in $arrObjTempNew) {If (!($arrObjCollectionPath.Contains($NewItem))) {$arrObjCollectionPath.Add($NewItem) | Out-Null}}
		Remove-Variable arrObjTempOld
		Remove-Variable arrObjTempNew

		$AllReachedTop = $true
		Foreach ($item in $arrObjCollectionPath)
		{
			if ($($item.ParentCollectionID) -ne "COLLROOT") {$AllReachedTop = $false}
		}
		IF ($AllReachedTop -eq $true) {$bFinished = $true}
	} While ($bFinished -ne $true)
$arrOutput = @()
Foreach ($item in $arrObjCollectionPath) {$arrOutput += $item.CollectionPath}
$arrOutput | fl *