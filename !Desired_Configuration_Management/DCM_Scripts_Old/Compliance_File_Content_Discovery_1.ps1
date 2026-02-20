# Compliance File Content - Discovery
{write-host "Not Compliant"}
Else
# Compliance File Content - Discovery

$Path1 = "$env:windir\System32\Macromed\Flash"
$Path2 = "$env:windir\SYSWOW64\Macromed\Flash"
$File1 = "mms.cfg"

$FilePath1 = "$Path1\$File1"
$FilePath2 = "$Path2\$File1"

$list = 'AutoUpdateDisable = 1
AutoUpdateInterval = 365
SilentAutoUpdateEnable = false'


if ((test-path $FilePath1) -eq $true)
{
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $FilePath1 | Measure-object -character -ignorewhitespace).Characters)){write-host "Compliant"}
    Else{write-host "Not Compliant"}
}
Elseif ((test-path $FilePath2) -eq $true)
{
    if ((($list | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $FilePath2 | Measure-object -character -ignorewhitespace).Characters)){write-host "Compliant"}
    Else{write-host "Not Compliant"}
}
Else
{write-host "Not Compliant"}
