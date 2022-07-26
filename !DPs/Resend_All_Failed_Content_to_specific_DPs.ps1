# UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT
[string]$SiteServer = "SCCMSERVER.Domain.Com"
[string]$SiteCode = "SS1"
[int32]$WarnThreshold = 3



# Get all valid packages from the primary site server
$Namespace = "root\SMS\Site_" + $SiteCode

# Get all distribution points
Write-Host "Getting all valid distribution points... " -NoNewline
$DistributionPoints = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'"
Write-Host ([string]($DistributionPoints.count) + " distribution points found.")
Write-Host ""


$CheckDPs = 'FISPC-E1.Domain.Com', `
            'FISPC-I6.Domain.Com', `
            'FISPC-L6.Domain.Com', `
            'FISPC-N6.Domain.Com', `
            'FISPC-O4.Domain.Com', `
            'FISPC-PD.Domain.Com', `
            'FISPC-PV2.Domain.Com', `
            'FISPC-Q9.Domain.Com', `
            'FISPC-RA01.Domain.Com', `
            'FISPC-S1.Domain.Com', `
            'FISPC-S5.Domain.Com', `
            'FISPC-S6.Domain.Com', `
            'MSLBET02.Domain.Com'

<#
'FLMASM01.Domain.Com', `
'FLMBSM01.Domain.Com', `
'LAALSM01.Domain.Com', `
'LALOSM01.Domain.Com'

'LAWKSM01.Domain.Com', `
'LAWTSM01.Domain.Com', `
'MSCHSM01.Domain.Com', `
'MSHNSM01.Domain.Com', `
'MSKLSM01.Domain.Com', `
'MSPCSM01.Domain.Com', `
'sccmserver3.Domain.Com'
#>

# $CheckDPs = 'lalosm01.Domain.Com'

ForEach ($DPFQDN in $DistributionPoints.name)
{
    Write-Host "Checking $DPFQDN"
    If ($DPFQDN -in $CheckDPs)
    {
        #Get-WmiObject -ComputerName 'SCCMSERVER' -Namespace root\sms\site_$SiteCode -Class sms_packagestatusDistPointsSummarizer | Where-Object State -EQ 3 | Where-Object SourceNALPath -Match $DPFQDN
        $Failures = Get-WmiObject -ComputerName 'SCCMSERVER' -Namespace root\sms\site_$SiteCode -Class sms_packagestatusDistPointsSummarizer | Where-Object State -ne 0 | Where-Object SourceNALPath -Match $DPFQDN
        foreach ($Failure in $Failures)
        {
            $FailedPackageIDs = $Failure.PackageID
            #Write-Output "Failed PackageID: $PackageID"
            ForEach ($PackageID in $FailedPackageIDs)
            {
                Write-Host "Checking $DPFQDN - found bad package $PackageID"
                $DP = Get-WmiObject -ComputerName 'SCCMSERVER' -Namespace root\sms\site_$SiteCode -Class sms_distributionpoint | Where-Object ServerNalPath -match $DPFQDN | Where-Object PackageID -EQ $PackageID
                $DP.RefreshNow = $true
                $DP.put()
            }
        }
    }
}

<#
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$DPFQDN = 'LAQ5SM01.Domain.Com'
$Log = "D:\$DPFQDN--ContentStatus--$ADate.csv"

"Server,PackageID,State" | Set-Content $Log
$output = @()
$Info = Get-WmiObject -ComputerName 'SCCMSERVER' -Namespace root\sms\site_SS1 -Class sms_packagestatusDistPointsSummarizer | Where-Object State -ne 0 | Where-Object SourceNALPath -Match $DPFQDN
foreach ($Failure in $Info)
{
    Write-Host "$DPFQDN,$($Failure.packageid),$($Failure.state)"
    $output += "$DPFQDN,$($Failure.packageid),$($Failure.state)"
}
 $output | ogv
 $output | Add-Content $Log
 #>
