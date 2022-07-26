Net stop "SMS Agent Host"
Remove-Item -Path "$env:SystemRoot\SMSCFG.ini" -Force
Get-ChildItem -Path cert:\LocalMachine\SMS\* | Remove-Item
Net start "SMS Agent Host"