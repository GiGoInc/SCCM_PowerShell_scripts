# Get CCMCache path
    If($OldCache) { $false } else { $true }
    #report old Items
# Get CCMCache path
    $Cachepath = ([wmi]"ROOT\ccm\SoftMgmtAgent:CacheConfig.ConfigKey='Cache'").Location
    
    #Get Items not referenced for more than 30 days
    $OldCache = Get-WmiObject -Query "SELECT * FROM CacheInfoEx" -namespace "ROOT\ccm\SoftMgmtAgent" | 
    Where-Object { ([datetime](Date) - ([System.Management.ManagementDateTimeConverter]::ToDateTime($_.LastReferenced))).Days -gt 30  }
    
    #report old Items
    If($OldCache) { $false } else { $true }
