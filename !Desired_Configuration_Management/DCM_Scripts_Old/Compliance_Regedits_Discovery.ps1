# "Registry" Discovery Script

$OSArchitecture = Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture
$ErrorActionPreference = "Stop"

$RegPath1x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome"
$RegPath2x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome\Update"
$RegPath3x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Update"

$RegPath1x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$RegPath2x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome\Update"
$RegPath3x86 = "HKLM:\SOFTWARE\Policies\Google\Update"

$RegPath4 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdate"
$RegPath5 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdatem"

# Check 32-bit registry in 64-bit OS
If($OSArchitecture.OSArchitecture -eq "64-bit")
{
    if ((test-path $RegPath1x64) -eq $true)
    {
        try
        {
            $ROSU = 'RestoreOnStartupURLs\'
            $RegCheck1x64 = Get-ItemProperty $RegPath1x64 -Name BookmarkBarEnabled, `
            DefaultBrowserSettingEnabled, `
            DefaultGeolocationSetting, `
            DnsPrefetchingEnabled, `
            HomepageLocation, `
            MetricsReportingEnabled, `
            $ROSU, `
            SearchSuggestEnabled, `
            ShowHomeButton, `
            SyncDisabled
            $RegCheck2x64 = Get-ItemProperty $RegPath2x64 -Name UpdateDefault
            $RegCheck3x64 = Get-ItemProperty $RegPath3x64 -Name AutoUpdateCheckPeriodMinutes
            $RegCheck4 = Get-ItemProperty $RegPath4 -Name Start
            $RegCheck5 = Get-ItemProperty $RegPath5 -Name Start
            
            if (`
			($RegCheck1x64.BookmarkBarEnabled -eq '1') -and `
            ($RegCheck1x64.DefaultBrowserSettingEnabled -eq '0') -and `
            ($RegCheck1x64.DefaultGeolocationSetting -eq '2') -and `
            ($RegCheck1x64.DnsPrefetchingEnabled -eq '0') -and `
            ($RegCheck1x64.HomepageLocation -eq 'http://thesource/') -and `
            ($RegCheck1x64.MetricsReportingEnabled -eq '0') -and `
            ($RegCheck1x64.$ROSU -eq 'http://thesource/') -and `
            ($RegCheck1x64.SearchSuggestEnabled -eq '0') -and `
            ($RegCheck1x64.ShowHomeButton -eq '1') -and `
            ($RegCheck1x64.SyncDisabled -eq '1') -and `
            ($RegCheck2x64.UpdateDefault -eq '0') -and `
            ($RegCheck3x64.AutoUpdateCheckPeriodMinutes -eq '0') -and `
            ($RegCheck4.Start -eq '4') -and `
            ($RegCheck5.Start -eq '4'))
                {Write-Host 'Compliant'}
            else
                {Write-Host 'Non-Compliant'}
        }
        Catch{$_.Exception.Message}
    }
}
ElseIf($OSArchitecture.OSArchitecture -eq "32-bit")
{
    if ((test-path $RegPath1x86) -eq $true)
    {
        try
        {
            $ROSU = 'RestoreOnStartupURLs\'
            $RegCheck1x86 = Get-ItemProperty $RegPath1x86 -Name BookmarkBarEnabled, `
            DefaultBrowserSettingEnabled, `
            DefaultGeolocationSetting, `
            DnsPrefetchingEnabled, `
            HomepageLocation, `
            MetricsReportingEnabled, `
            $ROSU, `
            SearchSuggestEnabled, `
            ShowHomeButton, `
            SyncDisabled
            $RegCheck2x86 = Get-ItemProperty $RegPath2x86 -Name UpdateDefault
            $RegCheck3x86 = Get-ItemProperty $RegPath3x86 -Name AutoUpdateCheckPeriodMinutes
            $RegCheck4 = Get-ItemProperty $RegPath4 -Name Start
            $RegCheck5 = Get-ItemProperty $RegPath5 -Name Start
            
            if (`
			($RegCheck1x86.BookmarkBarEnabled -eq '1') -and `
            ($RegCheck1x86.DefaultBrowserSettingEnabled -eq '0') -and `
            ($RegCheck1x86.DefaultGeolocationSetting -eq '2') -and `
            ($RegCheck1x86.DnsPrefetchingEnabled -eq '0') -and `
            ($RegCheck1x86.HomepageLocation -eq 'http://thesource/') -and `
            ($RegCheck1x86.MetricsReportingEnabled -eq '0') -and `
            ($RegCheck1x86.$ROSU -eq 'http://thesource/') -and `
            ($RegCheck1x86.SearchSuggestEnabled -eq '0') -and `
            ($RegCheck1x86.ShowHomeButton -eq '1') -and `
            ($RegCheck1x86.SyncDisabled -eq '1') -and `
            ($RegCheck2x86.UpdateDefault -eq '0') -and `
            ($RegCheck3x86.AutoUpdateCheckPeriodMinutes -eq '0') -and `
            ($RegCheck4.Start -eq '4') -and `
            ($RegCheck5.Start -eq '4'))
                {Write-Host 'Compliant'}
            else
                {Write-Host 'Non-Compliant'}
        }
        Catch{$_.Exception.Message}
    }
}
Else
{
    Write-Host 'Error finding OS level'
}
