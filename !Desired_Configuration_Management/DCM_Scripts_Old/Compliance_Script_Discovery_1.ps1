If(!(Test-Path 'C:\Windows\Logs\Software')){New-Item -Path 'C:\Windows\Logs\Software' -ItemType Directory -Force}
}
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Discovery - Non-Compliant - Found $count items in the ccmcache totalling $total MB." | Add-Content $log
If(!(Test-Path 'C:\Windows\Logs\Software')){New-Item -Path 'C:\Windows\Logs\Software' -ItemType Directory -Force}
$log = 'C:\Windows\Logs\Software\SCCM_client_cache_cleanup.log'

#######################################################################################################		
### Check C:\Windows\CCMCACHE folder size
$colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
$size = "{0:N0}" -f ($colItems.sum / 1MB)
$total = $size -replace ',',''

### DISCOVERY SCRIPT
	$CMObject = new-object -com "UIResource.UIResourceMgr"
	$cacheInfo = $CMObject.GetCacheInfo()
	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
    If ($objects -eq $null)
    {$count = '0'}
    Else
    {$count = $objects.Count}

    "$(get-date -format MM/dd/yyy)`t*`t$(get-date -format HH:mm:ss)   ****   Discovery - Found $count items in the ccmcache totalling $total MB." | Add-Content $log

If (($total -eq '0') -and ($count -eq '0'))
{
    Write-Host "Compliant"
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Discovery - Compliant - found $count items in the ccmcache totalling $total MB." | Add-Content $log
}
Else
{

    Write-Host "Non-compliant"
    "$(Get-Date -format MM/dd/yyy)`t*`t$(Get-Date -format HH:mm:ss)   ****   Discovery - Non-Compliant - Found $count items in the ccmcache totalling $total MB." | Add-Content $log
}
