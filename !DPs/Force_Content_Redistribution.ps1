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

$SiteCode = "SS1"

$DPs = 'SCCMSERVER1', `
			'SCCMSERVER2', `
			'SCCMSERVER3'


ForEach ($ServerFQDN in $DPs)
{
    #$ServerFQDN = "mshnsm01.Domain.Com"
    $TimeNow = Date
    $TimeInTen = $TimeNow.AddMinutes(10)
    $ValidationSchedule = New-CMSchedule -Start $TimeInTen -DayOfWeek $($TimeNow.DayOfWeek)
    Set-CMDistributionPoint -SiteCode $SiteCode -SiteSystemServerName $ServerFQDN -ValidateContentSchedule $ValidationSchedule
    Write-Host "Validation Scheduled for $($TimeInTen) on $($ServerFQDN)"
}

D:

