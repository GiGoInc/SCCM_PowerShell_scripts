# Discovery
}
    Write-Host "Non-Compliant - $PCModel - $CSize - $DSize"
# Discovery
$Cache = Get-WmiObject -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
$CSize = $Cache.Size

$System = Get-WmiObject -Class Win32_ComputerSystem
$PCModel = $System.Model

$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size
$DSize = $disk.Size

If (($CSize -eq '15360') -and ($PCModel -ne 'Latitude E7440')) # Cache is 15GB and Model is not an Ultrabook
{
    Write-Host 'Compliant'
}
ElseIf (($CSize -eq '15360') -and ($PCModel -eq 'Latitude E7440') -and ($DSize -ge '70000000000')) # Cache is 15GB and Model is an Ultrabook and the C drive is equal to or larger than 70GB
{
    Write-Host 'Compliant'
}
ElseIf (($CSize -eq '5120') -and ($PCModel -eq 'Latitude E7440') -and ($DSize -lt '70000000000')) # Cache is 5GB and Model is an Ultrabook and the C drive is smaller than 70GB
{
    Write-Host 'Compliant'
}
Else
{
    Write-Host "Non-Compliant - $PCModel - $CSize - $DSize"
}
