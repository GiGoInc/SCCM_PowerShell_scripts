#Load Powershell from SCCM Console

}
#Load Powershell from SCCM Console
#You can specify Distribution Point and Package ID in .csv file like below:
#   SERVER	        PKGID
#   XYZ.contoso.com	MK10046C
#   ABC.contoso.com	MK100364
 


$SiteCode = "XX1"
$Folder = 'D:\Powershell\!SCCM_PS_scripts'
$ImportFile = "$Folder\Refresh_multiple_package_on_multiple_servers.csv"
$ResultFile = "$Folder\Refresh_multiple_package_on_multiple_servers--Results.txt"

Import-Csv $ImportFile | ForEach {    
    $PackageID = $_.PackageID
    $ServerName= $_.ServerName

    $distpoints = Get-WmiObject -Namespace "root\SMS\Site_$($SiteCode)" -Query "Select * From SMS_DistributionPoint WHERE PackageID='$PackageID' and serverNALPath like '%$ServerName%'" 
           
    $dp=$distpoints
    $dp.RefreshNow = $true  
    $dp.Put() 
    "Package ID:" + $PackageID + " "+ "Refreshed On" + " "+ "Server:" +$ServerName | Out-File -FilePath $ResultFile -Append
}

