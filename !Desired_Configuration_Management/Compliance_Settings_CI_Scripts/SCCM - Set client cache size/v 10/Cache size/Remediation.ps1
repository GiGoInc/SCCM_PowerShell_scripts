# Remediation
}
    "$PCModel`t$CSize`t$DSize" | Add-Content "C:\Windows\Logs\Software\CCMCACHE_resize.log"
# Remediation
$Cache = Get-WmiObject -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
$CSize = $Cache.Size

$System = Get-WmiObject -Class Win32_ComputerSystem
$PCModel = $System.Model

$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size
$DSize = $disk.Size

If (($CSize -ne '15360') -and ($PCModel -ne 'Latitude E7440')) # Cache is 15GB and Model is not an Ultrabook
{
    $Cache.Size = '15360'
    $Cache.Put()
    Restart-Service -Name CcmExec
    "$(get-date)`tReset cache to 15360" | Add-Content "C:\Windows\Logs\Software\CCMCACHE_resize.log"
}
ElseIf (($CSize -ne '15360') -and ($PCModel -eq 'Latitude E7440') -and ($DSize -ge '70000000000')) # Cache is 15GB and Model is an Ultrabook and the C drive is equal to or larger than 70GB
{
    $Cache.Size = '15360'
    $Cache.Put()
    Restart-Service -Name CcmExec
    "$(get-date)`tReset cache to 15360" | Add-Content "C:\Windows\Logs\Software\CCMCACHE_resize.log"
}
ElseIf (($CSize -ne '5120') -and ($PCModel -eq 'Latitude E7440') -and ($DSize -lt '70000000000')) # Cache is 5GB and Model is an Ultrabook and the C drive is smaller than 70GB
{
    $Cache.Size = '5120'
    $Cache.Put()
    Restart-Service -Name CcmExec
    "$(get-date)`tReset cache to 5120" | Add-Content "C:\Windows\Logs\Software\CCMCACHE_resize.log"
}
Else
{
    "$PCModel`t$CSize`t$DSize" | Add-Content "C:\Windows\Logs\Software\CCMCACHE_resize.log"
}
