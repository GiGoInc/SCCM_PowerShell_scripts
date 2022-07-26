Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" -ErrorAction Stop

# Get all valid packages from the primary site server
$Namespace = "root\SMS\Site_" + $SiteCode

# UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT
[string]$SiteCode = 'SS1'

############################################################################################################################
[string]$SiteServer = 'sccmserver3.Domain.Com'
############################################################################################################################


$TimeNow = Date
$TimeInTen = $TimeNow.AddMinutes(1)
$ValidationSchedule = New-CMSchedule -Start $TimeInTen -DayOfWeek $($TimeNow.DayOfWeek)
Set-CMDistributionPoint -SiteCode $SiteCode -SiteSystemServerName $SiteServer -ValidateContentSchedule $ValidationSchedule
Write-Host "`nValidation schedule changed to " -NoNewline -ForegroundColor Red
Write-Host "$($ValidationSchedule.StartTime) " -NoNewline -ForegroundColor Yellow
Write-Host "on " -NoNewline -ForegroundColor Red 
Write-Host "$($SiteServer)`n" -ForegroundColor Yellow

<#
	Here’s a quick list of the package status codes when distributing content to Distribution Points.

	0 - PKG_STATUS_NONE
	1 - PKG_STATUS_SENT
	2 - PKG_STATUS_RECEIVED
	3 - PKG_STATUS_INSTALLED
	4 - PKG_STATUS_RETRY
	5 - PKG_STATUS_FAILED
	6 - PKG_STATUS_REMOVED
	7 - PKG_STATUS_PENDING_REMOVE // Not used.
	8 - PKG_STATUS_REMOVE_FAILED
	9 - PKG_STATUS_RETRY_REMOVE
#>


<# RESET TO SUNDAY AT 5AM
    $ValidationSchedule2 = New-CMSchedule -Start '05:00:00' -DayOfWeek Sunday
    Set-CMDistributionPoint -SiteCode $SiteCode -SiteSystemServerName $SiteServer -ValidateContentSchedule $ValidationSchedule2
    Write-Host "`nValidation schedule changed to " -NoNewline -ForegroundColor Red
    Write-Host "$($ValidationSchedule2.StartTime) " -NoNewline -ForegroundColor Yellow
    Write-Host "on " -NoNewline -ForegroundColor Red 
    Write-Host "$($SiteServer)`n" -ForegroundColor Yellow
#>

<#
    D:\Powershell\!SCCM_PS_scripts\!DPs\Repair_DP_Content_Library_Inconsistencies.ps1
        Getting package list from PkgLib on sccmserver3 ... 26 packages found.
        Refreshing WMI package list from sccmserver3 ... 51 packages found.
        Number of invalid packages exceeds threshold [26 invalid].
        Warning: Proceed with removing invalid PkgLib packages on sccmserver3?
        Yes or No: yes
        Removing invalid package SS100118 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100185 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100200 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1004A1 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1004A2 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100520 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100580 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100581 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005A0 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005AD from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005C6 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005C7 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005C9 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005D6 from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005DE from PkgLib on sccmserver3 -Done
        Removing invalid package SS1005FE from PkgLib on sccmserver3 -Done
        Removing invalid package SS100605 from PkgLib on sccmserver3 -Done
        Removing invalid package SS10060A from PkgLib on sccmserver3 -Done
        Removing invalid package SS10060B from PkgLib on sccmserver3 -Done
        Removing invalid package SS10060C from PkgLib on sccmserver3 -Done
        Removing invalid package SS10060D from PkgLib on sccmserver3 -Done
        Removing invalid package SS100611 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100633 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100634 from PkgLib on sccmserver3 -Done
        Removing invalid package SS100638 from PkgLib on sccmserver3 -Done
        Removing invalid package SS10064E from PkgLib on sccmserver3 -Done
Still shows 102 failed 102 packages of 137, 35 ok
    D:\Powershell\!SCCM_PS_scripts\!DPs\Reschedule_Content_Validation_on_DP.ps1
#>

<#################################
    D:\Powershell\!SCCM_PS_scripts\!DPs\Remove_Unknown_Content_from_DP.ps1
        Found 102 failed packages

        DP                      PackageId Action 
        --                      --------- ------ 
        sccmserver3.Domain.Com SS10000A  Removed
        sccmserver3.Domain.Com SS1000DC  Removed
        sccmserver3.Domain.Com SS1000FA  Removed
        sccmserver3.Domain.Com SS100164  Removed
        sccmserver3.Domain.Com SS10017E  Removed
        sccmserver3.Domain.Com SS1001B5  Removed
        sccmserver3.Domain.Com SS100251  Removed
        sccmserver3.Domain.Com SS10026A  Removed
        sccmserver3.Domain.Com SS100274  Removed
        sccmserver3.Domain.Com SS100289  Removed
        sccmserver3.Domain.Com SS10028F  Removed
        sccmserver3.Domain.Com SS100290  Removed
        sccmserver3.Domain.Com SS100291  Removed
        sccmserver3.Domain.Com SS1002A7  Removed
        sccmserver3.Domain.Com SS1002AD  Removed
        sccmserver3.Domain.Com SS1002AE  Removed
        sccmserver3.Domain.Com SS1002CE  Removed
        sccmserver3.Domain.Com SS1002D0  Removed
        sccmserver3.Domain.Com SS1002D9  Removed
        sccmserver3.Domain.Com SS1002DA  Removed
        sccmserver3.Domain.Com SS10030C  Removed
        sccmserver3.Domain.Com SS10030D  Removed
        sccmserver3.Domain.Com SS100310  Removed
        sccmserver3.Domain.Com SS100311  Removed
        sccmserver3.Domain.Com SS100312  Removed
        sccmserver3.Domain.Com SS100334  Removed
        sccmserver3.Domain.Com SS10033D  Removed
        sccmserver3.Domain.Com SS10033E  Removed
        sccmserver3.Domain.Com SS10034F  Removed
        sccmserver3.Domain.Com SS100364  Removed
        sccmserver3.Domain.Com SS100365  Removed
        sccmserver3.Domain.Com SS10037C  Removed
        sccmserver3.Domain.Com SS10038A  Removed
        sccmserver3.Domain.Com SS1003A0  Removed
        sccmserver3.Domain.Com SS1003BD  Removed
        sccmserver3.Domain.Com SS1003C8  Removed
        sccmserver3.Domain.Com SS1003CA  Removed
        sccmserver3.Domain.Com SS1003CB  Removed
        sccmserver3.Domain.Com SS1003D4  Removed
        sccmserver3.Domain.Com SS1003F4  Removed
        sccmserver3.Domain.Com SS1003FD  Removed
        sccmserver3.Domain.Com SS1003FE  Removed
        sccmserver3.Domain.Com SS100409  Removed
        sccmserver3.Domain.Com SS10040F  Removed
        sccmserver3.Domain.Com SS100410  Removed
        sccmserver3.Domain.Com SS100411  Removed
        sccmserver3.Domain.Com SS10042B  Removed
        sccmserver3.Domain.Com SS100430  Removed
        sccmserver3.Domain.Com SS10045B  Removed
        sccmserver3.Domain.Com SS10045F  Removed
        sccmserver3.Domain.Com SS100462  Removed
        sccmserver3.Domain.Com SS100463  Removed
        sccmserver3.Domain.Com SS100464  Removed
        sccmserver3.Domain.Com SS100478  Removed
        sccmserver3.Domain.Com SS10047C  Removed
        sccmserver3.Domain.Com SS100482  Removed
        sccmserver3.Domain.Com SS100487  Removed
        sccmserver3.Domain.Com SS100489  Removed
        sccmserver3.Domain.Com SS10048A  Removed
        sccmserver3.Domain.Com SS100491  Removed
        sccmserver3.Domain.Com SS100499  Removed
        sccmserver3.Domain.Com SS10049A  Removed
        sccmserver3.Domain.Com SS10049B  Removed
        sccmserver3.Domain.Com SS10049D  Removed
        sccmserver3.Domain.Com SS1004A5  Removed
        sccmserver3.Domain.Com SS1004A6  Removed
        sccmserver3.Domain.Com SS1004A7  Removed
        sccmserver3.Domain.Com SS1004A8  Removed
        sccmserver3.Domain.Com SS1004A9  Removed
        sccmserver3.Domain.Com SS1004B2  Removed
        sccmserver3.Domain.Com SS1004B8  Removed
        sccmserver3.Domain.Com SS1004B9  Removed
        sccmserver3.Domain.Com SS1004BB  Removed
        sccmserver3.Domain.Com SS1004CC  Removed
        sccmserver3.Domain.Com SS1004CD  Removed
        sccmserver3.Domain.Com SS1004E0  Removed
        sccmserver3.Domain.Com SS1004E1  Removed
        sccmserver3.Domain.Com SS1004E2  Removed
        sccmserver3.Domain.Com SS100500  Removed
        sccmserver3.Domain.Com SS100507  Removed
        sccmserver3.Domain.Com SS10050D  Removed
        sccmserver3.Domain.Com SS100511  Removed
        sccmserver3.Domain.Com SS100515  Removed
        sccmserver3.Domain.Com SS10051A  Removed
        sccmserver3.Domain.Com SS100524  Removed
        sccmserver3.Domain.Com SS100531  Removed
        sccmserver3.Domain.Com SS100532  Removed
        sccmserver3.Domain.Com SS100534  Removed
        sccmserver3.Domain.Com SS10054E  Removed
        sccmserver3.Domain.Com SS10054F  Removed
        sccmserver3.Domain.Com SS100557  Removed
        sccmserver3.Domain.Com SS10056A  Removed
        sccmserver3.Domain.Com SS10056F  Removed
        sccmserver3.Domain.Com SS100570  Removed
        sccmserver3.Domain.Com SS1005AF  Removed
        sccmserver3.Domain.Com SS1005B3  Removed
        sccmserver3.Domain.Com SS1005E8  Removed
        sccmserver3.Domain.Com SS1005EE  Removed
        sccmserver3.Domain.Com SS1005F1  Removed
        sccmserver3.Domain.Com SS1005F6  Removed
        sccmserver3.Domain.Com SS1005F7  Removed
        sccmserver3.Domain.Com SS100603  Removed

Removed 102 failed packages of 137, 35 remaining
    D:\Powershell\!SCCM_PS_scripts\!DPs\Reschedule_Content_Validation_on_DP.ps1
        Validation schedule changed to 06/25/2019 13:46:13 on sccmserver3.Domain.Com


#>