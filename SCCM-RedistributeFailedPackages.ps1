Function Redistribute-Content {
Redistribute-Content -SiteCode XX1

Function Redistribute-Content {
    [CMDletBinding()]
    param (
    [Parameter(Mandatory=$True)]
    [ValidateNotNullorEmpty()]
    [String]$DistributionPoint,
    [Parameter(Mandatory=$True)]
    [ValidateNotNullorEmpty()]
    [String]$SiteCode
    )
    Process {
    $query = 'SELECT * FROM SMS_PackageStatusDistPointsSummarizer WHERE State = 2 OR State = 3'
    $Packages = Get-WmiObject -Namespace "root\SMS\Site_$($SiteCode)" -Query $query | Select-Object PackageID, @{N='DistributionPoint';E={$_.ServerNalPath.split('\')[2]}}
    $FailedPackages = $Packages | Where-Object {$_.DistributionPoint -like "$DistributionPoint"} | Select-Object -ExpandProperty PackageID
    foreach ($PackageID in $FailedPackages) {
        $List = Get-WmiObject -Namespace "root\SMS\Site_$($SiteCode)" -Query "Select * From SMS_DistributionPoint WHERE PackageID='$PackageID' AND ServerNALPath like '%$DistributionPoint%'"
        $List.RefreshNow = $True
        $List.Put()
        }
    }
}


Redistribute-Content -SiteCode XX1
