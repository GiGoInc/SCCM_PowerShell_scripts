# Get CCMCache path
	$objects = $cacheinfo.GetCacheElements()
	$cacheInfo = $CMObject.GetCacheInfo()
# Get CCMCache path
    $Cachepath = ([wmi]"ROOT\ccm\SoftMgmtAgent:CacheConfig.ConfigKey='Cache'").Location
    
    #Get Items not referenced for more than 30 days
    $OldCache = Get-WmiObject -query "SELECT * FROM CacheInfoEx" -namespace "ROOT\ccm\SoftMgmtAgent" | Where-Object { ([datetime](Date) - ([System.Management.ManagementDateTimeConverter]::ToDateTime($_.LastReferenced))).Days -gt 30  }
    
    #delete Items on Disk
    $OldCache | % { Remove-Item -Path $_.Location -Recurse -Force -ea SilentlyContinue }
    #delete Items on WMI
    $OldCache | Remove-WmiObject
    
    #Get all cached Items from Disk
    $CacheFoldersDisk = (Get-ChildItem $Cachepath).FullName
    #Get all cached Items from WMI
    $CacheFoldersWMI = get-wmiobject -Query "SELECT * FROM CacheInfoEx" -Namespace "ROOT\ccm\SoftMgmtAgent"
    
    #Remove orphaned Folders from Disk
    $CacheFoldersDisk | % { If($_ -notin $CacheFoldersWMI.Location) { Remove-Item -path $_ -Recurse -Force -ea SilentlyContinue} }
    
    #Remove orphaned WMI Objects
    $CacheFoldersWMI| % { If($_.Location -notin $CacheFoldersDisk) { $_ | Remove-WmiObject }}

# Restart-Service CcmExec | Out-Null
Start-Sleep -Seconds 20
######## CACHE - DISCOVERY SCRIPT
$objects = $null
  $count = $null
	$CMObject = new-object -com "UIResource.UIResourceMgr"
	$cacheInfo = $CMObject.GetCacheInfo()
	$objects = $cacheinfo.GetCacheElements()
