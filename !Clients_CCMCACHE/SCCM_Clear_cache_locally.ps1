$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx -Impersonation 3

}
$A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx -Impersonation 3

ForEach ($item in $A)
{
$CID = $item.cacheid
$loc = $item.location
'\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
Remove-Item $loc -recurse
Write-Host "Clearing $loc"
}

