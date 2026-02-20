# "File Content" Remediation Script
catch{$_}
}
# "File Content" Remediation Script

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

try
  {
    If (Test-Path 'C:\Program Files (x86)\Google\Chrome\Application')
    {
      New-Item -Path 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences' -Force -ItemType File
      $list | Out-file 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences' -Encoding ASCII -Force
    }
    If (Test-Path 'C:\Program Files\Google\Chrome\Application')
    {
      New-Item -Path 'C:\Program Files\Google\Chrome\Application\master_preferences' -Force -ItemType File
      $list | Out-file 'C:\Program Files\Google\Chrome\Application\master_preferences' -Encoding ASCII -Force
    }
}
catch{$_}
