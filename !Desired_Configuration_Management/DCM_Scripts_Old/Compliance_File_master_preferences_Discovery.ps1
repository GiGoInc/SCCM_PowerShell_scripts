# "File Content" Discovery Script
{write-host "Not Compliant"}
Else
# "File Content" Discovery Script

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

if ((test-path $filex64) -eq $true)
{
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $filex64 | Measure-object -character -ignorewhitespace).Characters)){write-host "Compliant"}
    Else{write-host "Not Compliant"}
}
Elseif ((test-path $filex86) -eq $true)
{
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $filex86 | Measure-object -character -ignorewhitespace).Characters)){write-host "Compliant"}
    Else{write-host "Not Compliant"}
}
Else
{write-host "Not Compliant"}
