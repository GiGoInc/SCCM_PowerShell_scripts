$Cache = Get-WmiObject -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
If ($Cache.Size -eq '15360')
{
    $Cache.Size = '15360'
    $Cache.Put()
    Restart-Service -Name CcmExec
}