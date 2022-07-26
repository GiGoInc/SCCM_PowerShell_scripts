$computer = '37QJG12'

$colItems = (Get-ChildItem "\\$computer\c$\windows\ccmcache" -recurse | Measure-Object -property length -sum)
$size = "{0:N0}" -f ($colItems.sum / 1MB)
$size -replace ',',''