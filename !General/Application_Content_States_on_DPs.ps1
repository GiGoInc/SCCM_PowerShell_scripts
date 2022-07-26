$(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')
$PackageStatusDistPointsSummarizer = Get-WmiObject -ComputerName 'SCCMSERVER.Domain.Com' -Namespace root\sms\site_SS1 -Query "SELECT * FROM SMS_PackageStatusDistPointsSummarizer"
$(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')

"Server`tPackageID`tStatus" | Set-Content 'D:\Powershell\!SCCM_PS_scripts\!General\Failed_Content_log.txt'
ForEach ($Summary in $PackageStatusDistPointsSummarizer)
{
    $ServerNALPath = $Summary.ServerNALPath.split('\')[2]
    $State = $Summary.State
    $PackageID = $Summary.PackageID

    "$ServerNALPath`t$PackageID`t$State" | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!General\Failed_Content_log.txt'
}
$(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')