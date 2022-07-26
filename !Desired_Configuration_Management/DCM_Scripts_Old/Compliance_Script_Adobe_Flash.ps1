# Compliance File Content - Remediation

$Path1 = "$env:windir\System32\Macromed\Flash"
$Path2 = "$env:windir\SYSWOW64\Macromed\Flash"
$File1 = "mms.cfg"

$FilePath1 = "$Path1\$File1"
$FilePath2 = "$Path2\$File1"

$Text1 = "AutoUpdateDisable = 1
AutoUpdateInterval = 365
SilentAutoUpdateEnable = false"

$Type1 = "Directory"


try{
New-Item -Path $Path1 -Force -ItemType $Type1
$Text1 | Out-file $FilePath1 -Encoding UTF8 -Force
}catch{$_}

try{
New-Item -Path $Path2 -Force -ItemType $Type1
$Text1 | Out-file $FilePath2 -Encoding UTF8 -Force
}catch{$_}