# Compliance Check if file exists - Discovery

$Path1 = "$env:windir\System32\Macromed\Flash"
$Path2 = "$env:windir\SYSWOW64\Macromed\Flash"
$File1 = "mms.cfg"

$FilePath1 = "$Path1\$File1"
$FilePath2 = "$Path2\$File1"

if ((Test-Path $FilePath1) -eq $true -and (Test-Path $FilePath2) -eq $true)
  {
    write-host "Compliant"
  }
else
  {write-host "Not-Compliant"}