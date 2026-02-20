# UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT
}
    }
# UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT
[string]$SiteServer = "SERVER.DOMAIN.COM"
[string]$SiteCode = "XX1"
[int32]$WarnThreshold = 3



# Get all valid packages from the primary site server
$Namespace = "root\SMS\Site_" + $SiteCode

# Get all distribution points
Write-Host "Getting all valid distribution points... " -NoNewline
$DistributionPoints = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'"
Write-Host ([string]($DistributionPoints.count) + " distribution points found.")
Write-Host ""

ForEach ($DPFQDN in $DistributionPoints.name)
{
    Write-Host "Checking $DPFQDN"
    #Get-WmiObject -ComputerName 'SERVER' -Namespace root\sms\site_$SiteCode -Class sms_packagestatusDistPointsSummarizer | Where-Object State -EQ 3 | Where-Object SourceNALPath -Match $DPFQDN
    $Failures = Get-WmiObject -ComputerName 'SERVER' -Namespace root\sms\site_$SiteCode -Class sms_packagestatusDistPointsSummarizer | Where-Object State -EQ 3 | Where-Object SourceNALPath -Match $DPFQDN
    foreach ($Failure in $Failures)
    {
        $FailedPackageIDs = $Failure.PackageID
        #Write-Output "Failed PackageID: $PackageID"
        ForEach ($PackageID in $FailedPackageIDs)
        {
            If ($PackageID -eq 'XX100501')
            {
                Write-Host "Checking $DPFQDN - found bad package $PackageID"
                $DP = Get-WmiObject -ComputerName 'SERVER' -Namespace root\sms\site_$SiteCode -Class sms_distributionpoint | Where-Object ServerNalPath -match $DPFQDN | Where-Object PackageID -EQ $PackageID
                $DP.RefreshNow = $true
                $DP.put()
            }
        }
    }
}
