$computer = $env:COMPUTERNAME
(gc $Log) | ? { -not [String]::IsNullOrWhiteSpace($_) } | set-content $Log
$Updates | Out-File $Log -Encoding ascii
$computer = $env:COMPUTERNAME
$ADateStart = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')
If(!(Test-Path 'C:\Temp')){New-Item -ItemType Directory -Path 'C:\Temp'}
$Log = "C:\Temp\$($computer)_updates__$ADateStart.csv"
$Updates = wmic qfe get /format:csv
$Updates | Out-File $Log -Encoding ascii
(gc $Log) | ? { -not [String]::IsNullOrWhiteSpace($_) } | set-content $Log
