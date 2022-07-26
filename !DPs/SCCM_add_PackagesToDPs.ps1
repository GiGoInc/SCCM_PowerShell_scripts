###########################################################
# AUTHOR  : Marius / Hican - http://www.hican.nl - @hicannl
# DATE    : 30-08-2012
# COMMENT : This script adds Packages to DistributionPoints
#           (DPs) in SCCM 2012, based on an input file.
###########################################################

#ERROR REPORTING ALL
Set-StrictMode -Version latest

$script_parent = Split-Path -Parent $MyInvocation.MyCommand.Definition
$csv_path      = $script_parent + "\add_PackagesToDPs.input"
$csv_import    = Import-Csv $csv_path
$sitecode      = "P01"
$siteserver    = "<SERVER>"

Write-Output "`r"

ForEach ($item In $csv_import)
{
  If ($item.Implement.ToLower() -eq "y")
  {
    $packageID = GWMI -Namespace "ROOT\SMS\Site_$sitecode" -ComputerName $siteserver -Query `
	"SELECT PackageID FROM SMS_Package WHERE Name = '$($item.PackageName)'"

    If ($packageID -ne "" -And $packageID -ne $Null)
    {
      $NALPaths = GWMI -Namespace "ROOT\SMS\Site_$sitecode" -ComputerName $siteserver -Query `
      "SELECT * FROM SMS_SystemResourceList WHERE RoleName = 'SMS Distribution Point' AND NALPath NOT LIKE '%PXE%'"

      ForEach ($NALPath In $NALPaths)
      {
        $dpClass             = [WMIClass] "\\$($siteserver)\ROOT\SMS\Site_$($sitecode):SMS_DistributionPoint"
        $addDP               = $dpClass.CreateInstance()
        $addDP.PackageID     = $packageID.PackageID
        $addDP.SiteCode      = $NALPath.SiteCode
        $addDP.ServerNALPath = $NALPath.NALPath
        $addDP.RefreshNow    = $True
        $dpPath              = $addDP.Put()

        Write-Output "[INFO]`tDistribution Point [$($item.PackageName)] added to Package [$($item.PackageName)]" -foregroundcolor Green
      }
    }
    Else
    {
      Write-Output "[ERROR]`tPackage [$($item.PackageName)] doesn't exist, DP's couldn't be added / updated" -foregroundcolor Red
    }
  }
  Else
  {
    Write-Output "[WARN]`tProcessing is disabled for Package [$($item.PackageName)]" -foregroundcolor Yellow
  }
}

Write-Output "`r"