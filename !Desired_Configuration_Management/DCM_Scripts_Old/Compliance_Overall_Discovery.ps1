# "Overall/Combined Checks" Discovery Script
    {write-host "Not Compliant"}
Else
# "Overall/Combined Checks" Discovery Script

$OSArchitecture = Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture
$ErrorActionPreference = "Stop"

$list = '{
	"homepage": "http://thesource",
	"homepage_is_newtabpage": false,
	"browser": {
		"show_home_button": true,
		"check_default_browser": false
	},
	"bookmark_bar": {
		"show_on_all_tabs": true
	},
	"distribution": {
		"suppress_first_run_bubble": true,
		"show_welcome_page": false,
		"skip_first_run_ui": true,
		"import_history": false,
		"import_bookmarks": false,
		"import_bookmarks_from_file" : "",
		"import_home_page": true,
		"import_search_engine": false
	},
	"sync_promo": {
		"user_skipped": true
	},
	"first_run_tabs": [
		"http://thesource"
	]
}'

$filex64 = 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences'
$filex86 = 'C:\Program Files\Google\Chrome\Application\master_preferences'

$GUFilex64 = 'C:\Program Files (x86)\Google\Update\GoogleUpdate.exe'
$GUFilex86 = 'C:\Program Files\Google\Update\GoogleUpdate.exe'

$DN1 = 'Google Update Service (gupdate)'
$Name1 = 'gupdate'

$DN2 = 'Google Update Service (gupdatem)'
$Name2 = 'gupdatem'

$RegPath1x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome"
$RegPath2x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome\Update"
$RegPath3x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Update"

$RegPath1x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$RegPath2x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome\Update"
$RegPath3x86 = "HKLM:\SOFTWARE\Policies\Google\Update"

$RegPath4 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdate"
$RegPath5 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdatem"


$f = 0 # f = files
$x = 0 # x = services are Stopped
$y = 0 # y = services are not Stopped
$r = 0 # r = regedits


# CHECK FILES
    if (((Test-Path $filex64) -eq $true -and ((Test-Path $GUFilex64) -ne $true) -and ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $filex64 | Measure-object -character -ignorewhitespace).Characters))) -or `
        ((Test-Path $filex86) -eq $true -and ((Test-Path $GUFilex86) -ne $true) -and ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $filex86 | Measure-object -character -ignorewhitespace).Characters))))
        {$f++}


# CHECK SERVICES
    if (Get-Service -DisplayName $DN1 -ErrorAction SilentlyContinue)
    {
        $Sr1 = (Get-Service -DisplayName $DN1)
        If ($Sr1.Status -eq 'Stopped'){$x++}
        If ($Sr1.Status -ne 'Stopped'){$y++}
    }

    if (Get-Service -DisplayName $DN2 -ErrorAction SilentlyContinue)
    {
        $Sr2 = (Get-Service -DisplayName $DN2)
        If ($Sr2.Status -eq 'Stopped'){$x++}
        If ($Sr2.Status -ne 'Stopped'){$y++}
    }

# CHECK REGDITS
    if ((test-path $RegPath1x64) -eq $true)
    {
        try
        {
            $ROSU = 'RestoreOnStartupURLs\'
            $RegCheck1x64 = Get-ItemProperty $RegPath1x64 -Name `
			BookmarkBarEnabled, `
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
            {$r++}
        }
        catch{}
    }
    Elseif ((test-path $RegPath1x86) -eq $true)
    {
        try
        {
            $ROSU = 'RestoreOnStartupURLs\'
            $RegCheck1x64 = Get-ItemProperty $RegPath1x64 -Name `
			BookmarkBarEnabled, `
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
            {$r++}
        }
        catch{}
    }


If (($f -eq 1) -and (($x -gt 0) -and ($y -eq 0)) -and ($r -eq 1))
    {write-host "Compliant"}
Else
    {write-host "Not Compliant"}
