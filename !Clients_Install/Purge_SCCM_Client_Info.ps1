Net stop "SMS Agent Host"
Net start "SMS Agent Host"
Get-ChildItem -Path cert:\LocalMachine\SMS\* | Remove-Item
Net stop "SMS Agent Host"
Remove-Item -Path "$env:SystemRoot\SMSCFG.ini" -Force
Get-ChildItem -Path cert:\LocalMachine\SMS\* | Remove-Item
Net start "SMS Agent Host"
