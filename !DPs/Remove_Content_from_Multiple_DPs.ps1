#try
#{
# make sure we have access to CM commands before we continue
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" -ErrorAction Stop
#Create-UtilityForm
#}
#catch
#{
#[System.Windows.Forms.MessageBox]::Show("Failed to set CM site drive. Are you sure you are running this from SCCM01 and the console is up to date?" , "Fail!")
# exit
#}



# Get all distribution points
Write-Host "Getting all valid distribution points... " -NoNewline
$DistributionPoints = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'"
Write-Host ([string]($DistributionPoints.count) + " distribution points found.")
Write-Host ""

$IDs = 'SS100003', `
'SS100350', `
'SS1004A6', `
'SS100581', `
'SS1004E2', `
'SS10045F', `
'SS100611', `
'SS10060D'


clear
Write-Host "`nAre you sure you want to remove " -NoNewline -ForegroundColor Red
Write-Host "$Application " -ForegroundColor Yellow -NoNewline
Write-Host "from the Distribution Points?`n" -ForegroundColor Red
Read-Host -Prompt "Press any key to continue or CTRL+C to quit"

ForEach ($DP in $DPs)
{
    ForEach ($ID in $IDs)
    {
        # Remove-CMContentDistribution -ApplicationName $Application -DistributionPointName $DP -Force
        Remove-CMContentDistribution -PackageId $ID -DistributionPointName $DP -Force
    }
}
