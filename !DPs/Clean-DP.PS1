#==============================================================
Write-Host "Done" -ForegroundColor Yellow
Write-Host ""
#==============================================================
# AUTHOR:  Tao Yang 
# DATE:    14/11/2010
# Version: 1.0
# COMMENT: Remove all packages from a particular DP (or BDP)
#==============================================================
Param ([string] $DPName)
### Beging Function Libraries
Clear-Host
#Ping Check
Function Ping-Check($computer)
{
	$bPing = $false
	$ping = New-Object Net.NetworkInformation.Ping
	Try {
	$PingResult = $ping.send($computer)
	} Catch {
		#Ping failed
	}
	if ($PingResult -and $PingResult.Status.Tostring().ToLower() -eq "success")
	{
		$bPing = $true
	} else {
		$bPing = $false
	}
	return $bPing
}

#Get OS Architecture
Function Get-OSArch ([string]$ComputerName)
{
	$ObjOS = Get-WmiObject -Query "Select * from Win32_OperatingSystem" -ComputerName $ComputerName -ErrorAction SilentlyContinue
	$arrOSVersion = $ObjOS.Version.split(".")
	If ($arrOSVersion[0] -eq 6)
	{
		#OS is Vista/Win2008 or Win7/Win2008R2
		$OSArch = $objOS.OSArchitecture
	} Else {
		If ($objOS.Caption -contains "x64")
		{
			$OSArch = "64-bit"
		} else {
			$OSArch = "32-bit"
		}
	}
	Return $OSArch
}

#Get all domains in the forest
Function Get-AllDomains
{
	$Root = [ADSI]"LDAP://RootDSE"
	$oForestConfig = $Root.Get("configurationNamingContext")
	$oSearchRoot = [ADSI]("LDAP://CN=Partitions," + $oForestConfig)
	$AdSearcher = [adsisearcher]"(&(objectcategory=crossref)(netbiosname=*))"
	$AdSearcher.SearchRoot = $oSearchRoot
	$domains = $AdSearcher.FindAll()
	return $domains
}

# Search DP from primary sites
Function Get-DP ($arrSCCMSiteInfo, $DPName)
{
	$arrDPs = New-Object System.Collections.ArrayList
	Foreach ($Site in $arrSCCMSiteInfo)
	{
		If ($Site.SiteType -eq "Primary")
		{	
			$bDuplicateDP = $false
			$SiteCode = $Site.SiteCode
			$SearchDPs = Get-WmiObject -Namespace root\sms\site_$SiteCode -Query "SELECT * from SMS_SystemResourcelist WHERE RoleName = 'SMS Distribution Point' AND NALPath LIKE '%$DPName%'" -ComputerName $Site.SMSProvider
			Foreach ($SearchDP in $SearchDPs)
			{
				#make sure this DP is not added already as it will appear multiple times across the hierarchy.
				Foreach ($objDP in $arrDPs)
				{
					$bDuplicateDP = $false
					If ($objDP.ServerRemoteName -ieq $SearchDP.ServerRemoteName -and $objDP.SiteCode -ieq $SearchDP.SiteCode)
					{
						#Duplicate DP found
						$bDuplicateDP = $true
					}
					
				}
				IF ($bDuplicateDP -eq $false)
				{
					[Void]$arrDPs.Add($SearchDP)
				}
			}
			Clear-Variable SearchDP
		}
	}
	#if nothing is found, return a null variable instead of an empty array
	If ($arrDPs.Count -eq 0)
	{
		Return $null
	} else {
		Return ,$arrDPs
	}
}

#Search AD for Management Point computer name
Function Get-MPFromAD ($SiteCode)
{
	$domains = Get-AllDomains
	Foreach ($domain in $domains)
	{
		Try {
			$ADSysMgmtContainer = [ADSI]("LDAP://CN=System Management,CN=System," + "$($Domain.Properties.ncname[0])")
			$AdSearcher = [adsisearcher]"(&(Name=SMS-MP-$SiteCode-*)(objectClass=mSSMSManagementPoint))"
			$AdSearcher.SearchRoot = $ADSysMgmtContainer
			$ADManagementPoint = $AdSearcher.FindONE()
			$MP = $ADManagementPoint.Properties.mssmsmpname[0]
		} Catch {}
	}

	Return $MP
}

#Retrieve SCCM Site Server Address From MP
Function Get-SiteInfoFromMP ($strMP)
{
	Try {
		$OSArch = Get-OSArch $strMP
		$RegType = [Microsoft.Win32.RegistryHive]::LocalMachine
		IF ($OSArch -eq "32-bit")
		{
			$strMPIdentificationKeyPath = "SOFTWARE\Microsoft\SMS\Identification"
			$strMPKeyPath = "SOFTWARE\Microsoft\SMS\MP"
		} Else {
			$strMPIdentificationKeyPath = "SOFTWARE\Wow6432Node\Microsoft\SMS\Identification"
			$strMPKeyPath = "SOFTWARE\Wow6432Node\Microsoft\SMS\MP"
		}
		#Firstly get Site server name
		$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegType, $strMP)
		$regKey = $regKey.OpenSubKey($strMPIdentificationKeyPath)
		
		If ($regKey)
		{
			$SiteServer = $regKey.GetValue("Site Server")
		}
		
		#Then get SQL server and Database name
		$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegType, $strMP)
		$regKey = $regKey.OpenSubKey($strMPKeyPath)
		
		If ($regKey)
		{
			$SQLServer = $regKey.GetValue("SQL Server Name")
			$DBName = $regKey.GetValue("Database Name")
		}
	} Catch {
		#Unable to connect to Management Point $strMP`.
	}
	$objSiteInfoFromMP = New-Object psobject
	Add-Member -InputObject $objSiteInfoFromMP -MemberType NoteProperty -Name SiteServer -Value $SiteServer
	Add-Member -InputObject $objSiteInfoFromMP -MemberType NoteProperty -Name SQLServer -Value $SQLServer
	Add-Member -InputObject $objSiteInfoFromMP -MemberType NoteProperty -Name Database -Value $DBName
	Return $objSiteInfoFromMP
}

#Retrieve Site Server details from the site server
Function Get-SiteServerInfo ($SiteServer)
{
	Try {	
		$objSite = New-object psobject
		$OSArch = Get-OSArch $SiteServer
		$RegType = [Microsoft.Win32.RegistryHive]::LocalMachine
		IF ($OSArch -eq "32-bit")
		{
			$strSiteServerIdentificationKeyPath = "SOFTWARE\Microsoft\SMS\Identification"
			$strSiteServerKeyPath = "SOFTWARE\Microsoft\SMS\Operations Management\SMS Server Role\SMS Site Server"
		} Else {
			$strSiteServerIdentificationKeyPath = "SOFTWARE\Wow6432Node\Microsoft\SMS\Identification"
			$strSiteServerKeyPath = "SOFTWARE\Wow6432Node\Microsoft\SMS\Operations Management\SMS Server Role\SMS Site Server"
		}
		$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegType, $SiteServer)
		$regKey = $regKey.OpenSubKey($strSiteServerIdentificationKeyPath)
		If ($regKey)
		{
			$ParentSiteCode = $regKey.GetValue("Parent Site Code")
			$SiteServerDomain = $regKey.GetValue("Site Server Domain")
			$SiteName = $regKey.GetValue("Site name")
			$SiteCode = $regKey.GetValue("Site Code")
		}
		Clear-Variable regKey
		$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegType, $SiteServer)
		$regKey = $regKey.OpenSubKey($strSiteServerKeyPath)
		If ($regKey)
		{
			$SiteType = $regKey.GetValue("Site Type")
			$CentralSite = $regKey.GetValue("Central Site")
			$Version = $regKey.GetValue("Version")
			
			#Convert site type from Dword to string
			Switch ($SiteType)
			{
				1 {$SiteType = "Primary"}
				2 {$SiteType = "Secondary"}
			}
			
			#Convert Central Site from Dword to boolean
			Switch ($CentralSite)
			{
				0 {$CentralSite = $false}
				1 {$CentralSite = $true}
			}
		}
		Add-Member -InputObject $objSite -membertype noteproperty -name SiteServer -value $SiteServer
		Add-Member -InputObject $objSite -membertype noteproperty -name ParentSiteCode -value $ParentSiteCode
		Add-Member -InputObject $objSite -membertype noteproperty -name SiteServerDomain -value $SiteServerDomain
		Add-Member -InputObject $objSite -membertype noteproperty -name SiteName -value $SiteName
		Add-Member -InputObject $objSite -membertype noteproperty -name SiteCode -value $SiteCode
		Add-Member -InputObject $objSite -membertype noteproperty -name SiteType -value $SiteType
		Add-Member -InputObject $objSite -membertype noteproperty -name IsCentralSite -value $CentralSite
		Add-Member -InputObject $objSite -membertype noteproperty -name SiteVersion -value $Version
	} Catch {
		#Unable to connect to the Site Server
	}
	Return $objSite
}

Function Get-SMSProviderAddress ($SiteServer)
{
	Try {
		$ProviderAddress = (Get-WmiObject -Namespace root\SMS SMS_ProviderLocation -ComputerName $SiteServer).Machine
	} Catch {
		#Unable to connect to site server's WMI
	}
	Return $ProviderAddress
}

#Get all SCCM Site object from AD
Function Get-AllSCCMSiteCodeFromAD
{
	$arrSCCMSiteCodes = New-Object system.Collections.ArrayList
	$domains = Get-AllDomains
	Foreach ($domain in $domains)
	{
		Try {
			$ADSysMgmtContainer = [ADSI]("LDAP://CN=System Management,CN=System," + "$($Domain.Properties.ncname[0])")
			$AdSearcher = [adsisearcher]"(objectClass=mSSMSSite)"
			$AdSearcher.SearchRoot = $ADSysMgmtContainer
			$ADSCCMSites = $AdSearcher.FindALL()
			Foreach ($site in $ADSCCMSites)
			{
				$strSiteCode = $($site.Properties.mssmssitecode).ToUpper()
				if (!$arrSCCMSiteCodes.Contains($strSiteCode))
				{
					[Void]$arrSCCMSiteCodes.Add($strSiteCode)
				}
			}
		} Catch {}
	}

	Return ,$arrSCCMSiteCodes
}

#Gather all SCCM site details from AD, MP and SiteServer
Function Gather-AllActiveSCCMSiteDetails
{
	$arrSCCMSiteCodes = Get-AllSCCMSiteCodeFromAD
	$arrSCCMSiteInfo = New-Object system.Collections.ArrayList
	Foreach ($SiteCode in $arrSCCMSiteCodes)
	{
		$bActiveSite = $true
		
		#Get MP name
		$MP = Get-MPFromAD $SiteCode
		
		#If MP is pingable, get site server name
		IF (Ping-Check $MP)
		{
			$objSiteInfoFromMP = Get-SiteInfoFromMP $MP
			$SiteServer = $objSiteInfoFromMP.SiteServer
			$SQLServer = $objSiteInfoFromMP.SQLServer
			$Database = $objSiteInfoFromMP.Database
		} else {
			$bActiveSite = $false
		}
		#If Site server name is successfully retrieved from MP, connect and get SMS Provider name and other site info
		If ($bActiveSite -and $SiteServer)
		{
			$SiteInfo = Get-SiteServerInfo $SiteServer
			If ($SiteInfo.SiteType -eq "Primary")
			{
				$SMSProvider = Get-SMSProviderAddress $SiteServer
			} Else {
				$SMSProvider = "N/A"
			}
		} else {
			$bActiveSite = $false
		}
		
		#if site info and smsprovider address is not retrieved, set bActiveSite to false
		If (!$SMSProvider -or !$SiteInfo)
		{
			$bActiveSite = $false
		}
		#Finally, consolidate results and save in a psobject if bActiveSite is true
		If ($bActiveSite)
		{
			$objSiteInfo = New-Object psobject
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SiteCode -value $SiteCode
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SiteServer -value $SiteServer
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name ManagementPoint -value $MP
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SMSProvider -value $SMSProvider
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SQLServer -value $SQLServer
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name Database -value $Database
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name ParentSiteCode -value $SiteInfo.ParentSiteCode
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SiteServerDomain -value $SiteInfo.SiteServerDomain
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SiteName -value $SiteInfo.SiteName
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SiteType -value $SiteInfo.SiteType
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name IsCentralSite -value $SiteInfo.IsCentralSite
			Add-Member -InputObject $objSiteInfo -membertype noteproperty -name SiteVersion -value $SiteInfo.SiteVersion
			[Void]$arrSCCMSiteInfo.Add($objSiteInfo)
			Remove-Variable objSiteInfo, MP, SiteServer, SMSProvider, SQLServer, Database, SiteInfo, bActiveSite
		}
	}
	Return ,$arrSCCMSiteInfo
}


#Get all packages assigned to a DP
Function Get-AllDPAssignedPackages ($DPName, $SiteCode, $SMSProvider)
{
	$PackagesInDP = Get-WmiObject -Namespace root\sms\site_$SiteCode -Query "Select * from SMS_DistributionPoint Where ServerNALPath LIKE '%$DPName%'" -ComputerName $SMSProvider
	Return $PackagesInDP
}

#Get a specific package that's assigned to a DP
Function Get-SpecificDPAssignedPackage ($DPName, $PackageID, $SiteCode, $SMSProvider)
{
	$PackageInDP =  Get-WmiObject -Namespace root\sms\site_$SiteCode -Query "Select * from SMS_DistributionPoint Where ServerNALPath LIKE '%$DPName%' AND PackageID = '$PackageID'" -ComputerName $SMSProvider
	Return $PackageInDP
}

#Get package details
Function Get-PackageInfo ($PackageID, $SiteCode, $SMSProvider)
{
	$ObjPkgBaseClass = Get-WmiObject -Namespace root\sms\Site_$SiteCode -Query "SELECT * FROM SMS_PackageBaseClass WHERE PackageID='$PackageID'" -ComputerName $SMSProvider
	$objPkgInfo = New-Object psobject
	Switch ($ObjPkgBaseClass.PackageType)
	{
		0 {$strPkgType="Regular software distribution package"}
		3 {$strPkgType="Driver package"}
		4 {$strPkgType="Task sequence package"}
		5 {$strPkgType="Software update package"}
		6 {$strPkgType="Device setting package"}
		257 {$strPkgType="Image package"}
		258 {$strPkgType="Boot image package"}
		259 {$strPkgType="Operating system install package"}
		default {$strPkgType="Unknown"}
	}
	Add-Member -InputObject $objPkgInfo -membertype noteproperty -name PackageID -value $ObjPkgBaseClass.PackageID
	Add-Member -InputObject $objPkgInfo -membertype noteproperty -name PackageName -value $ObjPkgBaseClass.Name
	Add-Member -InputObject $objPkgInfo -membertype noteproperty -name PackageType -value $strPkgType
	Add-Member -InputObject $objPkgInfo -membertype noteproperty -name SourceSite -value $ObjPkgBaseClass.SourceSite
	Add-Member -InputObject $objPkgInfo -membertype noteproperty -name SourceVersion -value $ObjPkgBaseClass.SourceVersion
	Return $objPkgInfo
}
### End Fucntion Libraries

#1. Get all active/accessible SCCM sites
Write-Host "Collecting SCCM site information..." -ForegroundColor Yellow
Write-Host ""
$arrSCCMSiteInfo = Gather-AllActiveSCCMSiteDetails

Write-Host "The following SCCM sites are discovered:" -ForegroundColor Yellow
If ($arrSCCMSiteInfo.Count -gt 0)
{
	$arrSCCMSiteInfo | Format-Table -AutoSize
} else {
	Write-Host "None" -ForegroundColor Red
}


#2. Search the DP from each primary sites from all sites retrieved from step 1
Write-Host "Searching the distribution point across SCCM Infrastructures..." -ForegroundColor Yellow
Write-Host ""
$arrDPs = Get-DP $arrSCCMSiteInfo $DPName

If ($arrDPs.Count -gt 0)
{
	Write-Host "The following Distribution Points are found:" -ForegroundColor Yellow
	$arrDPs | Format-Table ServerName, SiteCode, ResourceType -AutoSize
	Write-Host ""
	
	Foreach ($DP in $arrDPs)
	{
		Write-Host "Searching for packages assigned to $($DP.ServerRemotename)..." -ForegroundColor Yellow
		Write-Host ""
		#Firstly find the site of which the DP belongs to
		Foreach ($Site in $arrSCCMSiteInfo)
		{
			if ($Site.sitecode -eq $DP.SiteCode)
			{
				$objHomeSite = $Site
			}
		}
		#Secondly, if the DP belongs to a secondary site, find it's primary site
		If ($objHomeSite.SiteType -eq "Secondary")
		{
			Foreach ($Site in $arrSCCMSiteInfo)
			{
				if ($Site.SiteCode -eq $objHomeSite.ParentSiteCode)
				{
					$objHomePrimarySite = $Site
				}
			}
		} else {
			$objHomePrimarySite = $objHomeSite
		}
		
		#Then find all packages assigned to the DP
		$PackagesInDP = Get-AllDPAssignedPackages $DP.ServerName $objHomePrimarySite.SiteCode $objHomePrimarySite.SMSProvider
		If ($PackageInDP.count -gt 0)
		{
			Write-Host "The following Packages are assigned to the Distribution Point $($DP.Servername)`:" -ForegroundColor Yellow
			$PackagesInDP | Format-Table PackageID, SiteCode, SiteName, SourceSite, Status
			
			#Finally, collect package details for summary reporting and delete each packge from the source site
			$arrSuccessfulPkgInfo = New-Object System.Collections.ArrayList
			$arrFailedPkgInfo = New-Object System.Collections.ArrayList
			Foreach ($Package in $PackagesInDP)
			{
				$objPkgInfo = Get-PackageInfo $Package.PackageID $objHomePrimarySite.SiteCode $objHomePrimarySite.SMSProvider
				If ($Package.SourceSite -eq $objHomePrimarySite.SiteCode)
				{
					#Package assignment is from the primary site of which the DP belongs to, remove from the home SMS Provider
					Write-Host "Deleting $($Package.PackageID) on $($DP.ServerName) from $($objHomePrimarySite.SiteCode)`..." -ForegroundColor Green
					Try {
						$Package.delete()
						[Void]$arrSuccessfulPkgInfo.Add($objPkgInfo)
					} Catch
					{
						[Void]$arrFailedPkgInfo.Add($objPkgInfo)
						Write-Error " - Unable to delete $($Package.PackageID) on $($DPinfo.Name) from $($Package.SourceSite)!"
					}
				} else {
					#Delete the package from the site where the assignment was made
					$PkgSourceSite = $Package.SourceSite
					
					#Search package source site info from the site info collected in step 1
					Foreach ($SiteInfo in $arrSCCMSiteInfo)
					{
						If ($SiteInfo.SiteCode -ieq $PkgSourceSite)
						{
							$PkgSourceSiteSMSProvider = $SiteInfo.SMSProvider
						}
					}
					$SourcePackage = Get-SpecificDPAssignedPackage $DP.ServerName $Package.PackageID $PkgSourceSite $PkgSourceSiteSMSProvider
					If ($SourcePackage -ne $null)
					{
						Write-Host "Deleting $($SourcePackage.PackageID) on $($DPinfo.Name) from $PkgSourceSite`..." -ForegroundColor Green
						Try {
							$SourcePackage.delete()
							[Void]$arrSuccessfulPkgInfo.Add($objPkgInfo)
						} Catch
						{
							[Void]$arrFailedPkgInfo.Add($objPkgInfo)
							Write-Error " - Unable to delete $($SourcePackage.PackageID) on $($DPinfo.Name) from $PkgSourceSite!"
						}
					}
				}
				Remove-Variable objPkgInfo
			}
			Write-Host ""
			#In the end, display successful and failed packages
			Write-Host "The following packages have been SUCCESSFULLY deleted:" -ForegroundColor Green
			If ($arrSuccessfulPkgInfo.count -gt 0)
			{
				$arrSuccessfulPkgInfo | Format-Table * -AutoSize
			} else {
				Write-Host "None" -ForegroundColor Red
			}
			Write-Host ""
			
			Write-Host "The following packages could not be deleted:" -ForegroundColor Red
			If ($arrFailedPkgInfo.count -gt 0)
			{
				$arrFailedPkgInfo | Format-Table * -AutoSize
			} else {
				Write-Host "None" -ForegroundColor Green
				Write-Host ""
			}
			
			#Verify and double check the site provider, make sure all packages are removed.
			Write-Host "Wait for 15 seconds and check for packages again..." -ForegroundColor Yellow
			Start-Sleep -Seconds 15
			$PackagesStillInDP = Get-AllDPAssignedPackages $DP.ServerName $objHomePrimarySite.SiteCode $objHomePrimarySite.SMSProvider
			if ($PackagesStillInDP.count -gt 0)
			{
				#there are still packages assigned to DP.
				$arrPkgInfoStillInDP = New-Object system.Collections.ArrayList
				Foreach ($Package in $PackagesStillInDP)
				{
					$objPkgInfo = Get-PackageInfo $Package.PackageID $objHomePrimarySite.SiteCode $objHomePrimarySite.SMSProvider
					[Void]$arrPkgInfoStillInDP.Add($objPkgInfo)
				}
			}
		} else {
			Write-Host "No packages assigned to $($DP.ServerName)." -ForegroundColor Green
		}
	}
} else {
	Write-Host "No Distribution Point found that matches name $DPName`!" -ForegroundColor Red
}

#If there are still outstanding packages, display instruction on how to remove from database
If ($arrPkgInfoStillInDP.count -gt 0)
{
$strSQLQueryTemplate = @"
USE $($objHomePrimarySite.Database)
DELETE FROM PkgServers WHERE NALPath LIKE `'`%$DPName%' 
DELETE FROM PkgStatus WHERE PkgServer LIKE `'`%$DPName%'
DELETE FROM ContentDPMap WHERE ServerPath LIKE `'`%$DPName%'
"@

Write-Host "The following packages still exists in database:" -ForegroundColor Yellow
$arrPkgInfoStillInDP | Format-Table -AutoSize

Write-Host "Run below SQL query on the site databases server $($objHomePrimarySite.SQLServer) to remove packages:" -ForegroundColor Red
Write-Host $strSQLQueryTemplate -ForegroundColor Yellow
Write-Host ""
Write-Host "*Note* - Directly removing records from database is not supported by Microsoft." -ForegroundColor Red
}

Write-Host ""
Write-Host "Done" -ForegroundColor Yellow
