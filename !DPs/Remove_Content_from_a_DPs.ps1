Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
D:
Remove-CMContentDistribution -PackageId $ID -DistributionPointName $DP -Force
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" -ErrorAction Stop

############################################################################################################################
$ID = 'XX100118'
$DP = 'SERVER.DOMAIN.COM'
############################################################################################################################

Remove-CMContentDistribution -PackageId $ID -DistributionPointName $DP -Force
D:
