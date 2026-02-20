$Cache = Get-WmiObject -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
}
    Write-Host 'Non-Compliant'
$Cache = Get-WmiObject -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
If ($Cache.Size -eq '15360')
{
    Write-Host 'Compliant'
}
Else
{
    Write-Host 'Non-Compliant'
}
