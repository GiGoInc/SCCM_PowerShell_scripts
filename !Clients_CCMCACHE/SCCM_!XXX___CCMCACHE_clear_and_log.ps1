<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,User Name,Operating System,OS Type,Serial,Hard Drive Name,Firmware

.Example
PS C:\> .\CCMCACHE_clear_and_log--bsub.ps1 -computer 'Computer1'
	Computer1,Yes,Computer1,DOMAIN\user1,S-1-5-21-3460299977-1648588825-1751037255-95761,09/29/2015 08:22:08,True
#>
[CmdletBinding()]
param(
    # Support for multiple computers from the pipeline
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in computer name and press Enter to execute')]
    [string]$computer,

    # Switch to turn on Error Logging
    [Switch]$ErrorLog,
    [String]$LogFile = 'C:\Scripts\AD_Files\errorlog.txt',
	$command=$nothing
	)

if(test-connection $computer -count 1 -quiet -BufferSize 16)
{
    Try
        {
            New-PSSession -ComputerName $computer
            Enter-PSSession -ComputerName $computer
            start-sleep -Seconds 10

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
            	$count = $objects.Count
            Write-Host ""
            Write-Host "Found $count items in the ccmcache totalling $total MB"
            "$(get-date -format MM/dd/yyy)`t*`t$(get-date -format HH:mm:ss)`t****`tFound $count items in the ccmcache totalling $total MB" | Add-Content $log
            
            
            #######################################################################################################
            ### LOCAL - DELETE ALL CACHE ITEMS
            # cacls 'C:\wINDOWS\CCMCACHE' /E /T /C /P BuiltIn\Users:F
            
            $A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx
            
            ForEach ($item in $A)
            {
                $CID = $item.CacheId
                $loc = $item.location
                Remove-Item $loc -Recurse -Force
                '\ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
                Write-Host "Clearing $CID and $loc"
                "$(get-date -format MM/dd/yyy)`t*`t$(get-date -format HH:mm:ss)`t****`tClearing $CID and $loc" | Add-Content $log
            }
            
            #######################################################################################################
            # restart SCCM service
            Restart-Service CcmExec
            Write-Host "Restarted CCMEXEC service, sleeping for 10...."
            start-sleep -Seconds 10
            
            
            #######################################################################################################	
            ### Check C:\Windows\CCMCACHE folder size
            $colItems = (Get-ChildItem "C:\windows\ccmcache" -recurse | Measure-Object -property length -sum)
            $size = "{0:N0}" -f ($colItems.sum / 1MB)
            $total = $size -replace ',',''
            	
            ### DISCOVERY SCRIPT
            	$CMObject = new-object -com "UIResource.UIResourceMgr"
            	$cacheInfo = $CMObject.GetCacheInfo()
            	$objects = $cacheinfo.GetCacheElements() | select-object location, CacheElementID, ContentSize | sort location
            	$count = $objects.Count
                Write-Host "Found $count items in the ccmcache totalling $total MB"
                "$(get-date -format MM/dd/yyy)`t*`t$(get-date -format HH:mm:ss)`t****`tFound $count items in the ccmcache totalling $total MB" | Add-Content $log
        }#End Try
        Catch{
               #Write-Output "Caught the exception";
               #Write-Output $Error[0].Exception;
                If ($_.Exception.Message -Like "*Some or all identity references could not be translated*")
                {
                    Write-Host "Unable to Translate $UserSID - Try filtering the SID by using the -FilterSID parameter."
                }
                ElseIf($_.Exception.ErrorCode -eq "0x800706BA")
                {
                  Write-Host "WMI - RPC Server Unavailable - HRESULT: 0x800706BA"
                }
                ElseIf($_.Exception.ErrorCode -eq "0x80070005")
                {
                  Write-Host "WMI - Access is Denied - HRESULT: 0x80070005"
                }
            }#End Catch
		#Resetting ErrorActionPref
		$ErrorActionPreference = $TempErrAct

    	$object = [pscustomobject] @{}
    		#Adjusting ErrorActionPreference to stop on all errors
    		$TempErrAct = $ErrorActionPreference
    		$ErrorActionPreference = "Stop"
    		#Exclude Local System, Local Service & Network Service
}
else
{
    $object = [pscustomobject] @{
    Computer=$computer;
    Responding="No";
    Data="Couldn't ping PC"
    }
}
Exit-PSSession

$object | format-table -a

Write-Host ""
Read-Host -Prompt 'Press Enter to exit...'



# SIG # Begin signature block
# MIIL1wYJKoZIhvcNAQcCoIILyDCCC8QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIx7ydtBDx0Fq/GtZsckUTaHH
# P+ugggk4MIIESzCCAzOgAwIBAgITYAAAAALo5xr3zuIi5wAAAAAAAjANBgkqhkiG
# 9w0BAQsFADBNMRMwEQYKCZImiZPyLGQBGRYDaGhjMRowGAYKCZImiZPyLGQBGRYK
# bGlnaHRob3VzZTEaMBgGA1UEAxMRSGFuY29ja0hvbGRpbmctQ0EwCOMNMTUwNzA2
# MDAzODU3WhcNMTgwNzA2MDA0ODU3WjBRMRMwEQYKCZImiZPyLGQBGRYDaGhjMRow
# GAYKCZImiZPyLGQBGRYKTGlnaHRob3VzZTEeMBwGA1UEAxMVTGlnaHRob3VzZS1J
# c3N1aW5nLUNBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvOCM8Abe
# vAuzzTJ2MhJF6qvHhe+JSsHI7Vgccd08sxJx+eNhLpKD0uoKWtm46p1v+UAOCmkn
# 3YpFY5wa+3Mes0qN8VFPVwP5X0Yt+LSFTDfe1isep1IvRE0yLS+pGRpBjfxGNaTo
# fSAgen59febWONZMhruaZj+mTtWnTAyG3GVx9vc+IsCy6tzCKnI5y8wHbhzXJWkg
# tDyNCKezKG0kQNwFsIkFD5ct8B/t+usXslRn6dwsl6+XyGOBUzN+JeAa6d+hTkGd
# wDI6ettJKAhObVt43yAKrS2Sp5jK8jYr3Chd4ihY07AJiNKZY3Viyee8LhYwFGBs
# YTwn7D7oMBPGzQIDAQABo4IBHjCCARowEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0O
# BBYEFLabqenPYAe4WPfQgCgAJSFgNJJEMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIA
# QwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFEsg
# CoPhlYMO3GmKgcWFEiYtcIeUMEAGA1UdHwQ5MDcwNaAzoDGGL2h0dHA6Ly9wa2ku
# bGlnaHRob3VzZS5oaGMvSGFuY29ja0hvbGRpbmctQ0EuY3JsMEsGCCsGAQUFBwEB
# BD8wPTA7BggrBgEFBQcwAoYvaHR0cDovL3BraS5saWdodGhvdXNlLmhoYy9IYW5j
# b2NrSG9sZGluZy1DQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAGk6JuBNfWgfDjKd
# fgFafQQ7Ztc2YnoIPhLwB9+F7lgtslRw/gpffFASoUsnfTcAjtlnuJ6h//UmdD64
# r1gOSp5pfGBsEXYYArgG8HuIo/QSgN4KAwVF0xfAMxg1n3fMgJiIvs1vDt6d8yq4
# z85Mm/zj65un4l+LH3aD0JDtFDfa1bVSONQWRpsPtnP8vP3cwM74+UKJMeoGrn3b
# Yi2/2SLvE6nJKZ4jApWC/Rbk+Ak1QqJua1hIDR8JD7qKiN6cNhmUf5dUyCGUnQzJ
# Q8RR69JgnhidKRRj91b92WV6rK8agCto3J//1dPXxHsdSue2hOhCsX79sVEjHtTY
# 3zrNHlIwggTlMIIDzaADAgECAhM5AABHOi79c75LLPyQAAAAAEc6MA0GCSqGSIb3
# DQEBCwUAMFExEzARBgoJkiaJk/IsZAEZFgNoaGMxGjAYBgoJkiaJk/IsZAEZFgpM
# aWdodGhvdXNlMR4wHAYDVQQDExVMaWdodGhvdXNlLUlzc3VpbmctQ0EwCOMNMTYw
# NTIwMjAzMDQ5WhcNMTgwNTIwMjA0MDQ5WjB5MRMwEQYKCZImiZPyLGQBGRYDaGhj
# MRowGAYKCZImiZPyLGQBGRYKTGlnaHRob3VzZTEVMBMGA1UECxMMRG9tYWluIFVz
# ZXJzMRQwEgYDVQQLEwtUUyBBY2NvdW50czEZMBcGA1UEAxMQTGFjYXlvLCBJc2Fh
# YyBUUzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK0veyKOJyfC/+nO
# mB6ljyJCGe/WSOJ5qjB/8ISbkJ3mKeI5HxlJT0AFJDShF4yHlDYWkJ+9pSXmg4xW
# FeMKVD0lTqu2pmCVe986QZbyaxFSPc4oi5G+VYMaaNUFUbpkCFIbr2bqrg8d6l5j
# pbH0ttw0autvg/+JZjRDBtY2vlXzLishErUupkRr6xVGWQgtqkXP1A/8yjGMM0V1
# 3Cyzzcz1FckN1/uEUY1lHmpllG2Mrey8yOf7RYKsycSv1R59EMw9FZswVXp0OQwV
# X4aLa/ZKukm5FdejHq8Hxh36JAPzdi/6E0XJnAWem0EOzncMMBU7vzYF02k/w20V
# VKMRhQcCAwEAAaOCAYwwggGIMAsGA1UdDwQEAwIHgDA8BgkrBgEEAYI3FQcELzAt
# BiUrBgEEAYI3FQiGqYN3hPWSRK2DH4P5wySGrNM4WoTuuHCEndtCAgFkAgECMB0G
# A1UdDgQWBBRQD9TQh0w/6+zEtE1Ck8qpPhgGVDAfBgNVHSMEGDAWgBS2m6npz2AH
# uFj30IAoACUhYDSSRDBEBgNVHR8EPTA7MDmgN6A1hjNodHRwOi8vcGtpLmxpZ2h0
# aG91c2UuaGhjL0xpZ2h0aG91c2UtSXNzdWluZy1DQS5jcmwwTwYIKwYBBQUHAQEE
# QzBBMD8GCCsGAQUFBzAChjNodHRwOi8vcGtpLmxpZ2h0aG91c2UuaGhjL2xpZ2h0
# aG91c2UtaXNzdWluZy1jYS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYJKwYB
# BAGCNxUKBA4wDDAKBggrBgEFBQcDAzAyBgNVHREEKzApoCcGCisGAQQBgjcUAgOg
# GQwXVFMwMTAzODhATGlnaHRob3VzZS5oaGMwDQYJKoZIhvcNAQELBQADggEBACKb
# nE2IKJXqnPcAmYcXdCnjVHjOwNCescgAsUhrCzS9UCk5KIcT6nqQNu48SoaT+RL+
# xdoDbfpL/walrDLoLK3O976kdslhosNQ3y3QUo8U86UwA4ERuzTxcQZ8kBjdzj9Y
# 4xChQYJwrMWiIinzSFakaKOw06QOrvWIOhDha0/ajiI8B3Lgc5lmH9jOVcDIO3Yv
# fVy2avQlvnacREhPDbWzNU/SgcN8hFR4zeZ0nq9VlPmZIrKdzEYuyLkSRzeDa52w
# moMlWDCH4sjR4h+WOy2ywLS/yp2ucgDvtWktKplHxD0+IM4U4KivuU9WTGdH023U
# PXBV8slOxdyt7zFb36UxggIJMIICBQIBATBoMFExEzARBgoJkiaJk/IsZAEZFgNo
# aGMxGjAYBgoJkiaJk/IsZAEZFgpMaWdodGhvdXNlMR4wHAYDVQQDExVMaWdodGhv
# dXNlLUlzc3VpbmctQ0ECEzkAAEc6Lv1zvkss/JAAAAAARzowCQYFKw4DAhoFAKB4
# MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQB
# gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkE
# MRYEFIJJ8lZyiubr8iCyV5sKI/bj7y8yMA0GCSqGSIb3DQEBAQUABIIBAJcbLlD4
# q6fBcEl9hRN2WHUq8XkWe1qGra4s4yWGIJHGeQCL25g447nxNftCnIQV52+G884m
# uLCb5Lfw61L9MTuHp5gqVurZFWl1PFgw5iaoWo6Eu1itOXNxsnnS1pOb5cS+ZVzH
# DvjdEt/ZDujtZ2pWHPpxpjVM+QjAOqDYGYPAGKbji2Red/tCcpr1zKpecy1Lx2JB
# aBiysGVvz9Y3EtxbOchjVUAjQeGhmbs+sClwgjkJNEdeiAusbEey1rkxJ8q+1Ahu
# rHEoypLw98eA9bEriCViUHMjhOKGjP0cDLPJ3IF/pTRu/hgu/VczKxIB7ysQ0j3H
# d6mpyOeNoouduQw=
# SIG # End signature block
