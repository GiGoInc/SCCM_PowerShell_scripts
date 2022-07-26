Function Get-PackageID
{
$SiteCode = "SS1"
$SiteServer = "SCCMSERVER"
$Application = "SalesPro Base Install for TS"

   Try{
        $APPQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_ApplicationLatest `
        -ComputerName $SiteServer -ErrorAction STOP -Filter "LocalizedDisplayName='$Application'"

        Try{
        $PackageIDQuery = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Class SMS_ContentPackage `
        -ComputerName $SiteServer -ErrorAction STOP -Filter "SecurityKey='$($APPQuery.ModelName)'"
        Write-Output "Application" $APPQuery.LocalizedDisplayName "PackageID is:" $PackageIDQuery.PackageID
        }
       Catch{
            $_.Exception.Message
       }
   }
   Catch{
        $_.Exception.Message
   }

}
Get-PackageID


<#	Encore Teller for TS - Test
SalesPro Base Install for TS	SS1001CF
Encore Teller for TS - Test	SS100241
PS E:\packages\powershell_scripts>

#>
