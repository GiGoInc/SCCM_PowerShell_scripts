$ErrorActionPreference = 'SilentlyContinue'
}
    Write-Host "Not-Compliant"
$ErrorActionPreference = 'SilentlyContinue'
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

$Path1 = "$env:systemroot\System32\OneDriveSetup.exe"
$Path2 = "$env:systemroot\SysWOW64\OneDriveSetup.exe"
$Path3 = "$env:localappdata\Microsoft\OneDrive"
$Path4 = "$env:programdata\Microsoft OneDrive"
$Path5 = "C:\OneDriveTemp"
$Path6 = "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

$Path7 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
$Path8 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$Path9 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"


$Num = 0
If ((Test-Path $Path1) -eq $false){$Num++}
If ((Test-Path $Path2) -eq $false){$Num++}
If ((Test-Path $Path3) -eq $false){$Num++}
If ((Test-Path $Path4) -eq $false){$Num++}
If ((Test-Path $Path5) -eq $false){$Num++}
If ((Test-Path $Path6) -eq $false){$Num++}
If ((Test-Path $Path7) -eq $true ){$Num++}

$val8 = Get-ItemProperty -Path $Path8 -Name 'System.IsPinnedToNameSpaceTree'
If($val8."System`.IsPinnedToNameSpaceTree" -eq 0){$Num++}

$val9 = Get-ItemProperty -Path $Path9 -Name 'System.IsPinnedToNameSpaceTree'
If($val9."System`.IsPinnedToNameSpaceTree" -eq 0){$Num++}


If ($Num -eq 9)
{
    Write-Host "Compliant"
}
Else
{
    Write-Host "Not-Compliant"
}
