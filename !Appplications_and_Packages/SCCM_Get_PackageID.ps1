Function Get-PackageID
#>

Function Get-PackageID
{
$SiteCode = "XX1"
$SiteServer = "SERVER"
$Application = "APP1 Base Install for TS"

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


<#	APPLICATION01 APP2 for TS - Test
APP1 Base Install for TS	XX1001CF
APPLICATION01 APP2 for TS - Test	XX100241
PS E:\packages\powershell_scripts>

#>
