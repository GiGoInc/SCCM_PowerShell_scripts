<#
.Synopsis
This script runs the Invoke-Parallel.ps1 module.

It passses the following parameters:
$Subscript - the matching "%SCRIPTNAME%--bsub.ps1" script (i.e. SCCM_Check_WMI--bsub.ps1)
$Computers - list of machine names
-runspacetimeout - amount of time for each Runspace
-throttle - number of concurrent RunSpaces
$Destfile - timestamped CSV with header and output of the "%SCRIPTNAME%--bsub.ps1"

The data follows comma separated order:
PC Name,Online,PC Name (2),LastLoggedOn User,User SID,Last Logon Time,Logged In

.Example
PS C:\> .\SCCM_Check_WMI--based_on_PCList.ps1
	PC Name,Online,PC Name (2),LastLoggedOn User,User SID,Last Logon Time,Logged In
	Computer1,Yes,Computer1,DOMAIN\user1,S-1-5-21-3460299977-12345678901-234567890-12345,09/29/2015 08:22:08,True
	Computer2,Yes,Computer2,DOMAIN\User2,S-1-5-21-3460299977-98765432109-876543210-98765,09/29/2015 08:11:53,False
#>
[CmdletBinding()]
param([int]$Timeout = 60,
    [int]$Throttle = 400,
	$Command = "nothing"
)

# Load Modules
. 'C:\Scripts\!Modules\Invoke-Parallel.ps1'	#Script to run check concurrently

# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$Log = "C:\Scripts\PowerShell_log.log"                     # Logfile
    $ADateS = Get-Date                                     # Logfile
$ADateStart = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')

"$CurrentDirectory\$ScriptName`tstart time`t$ADateStart" | Add-Content $Log


            $SubScript = "$CurrentDirectory\SCCM_Check_WMI--bsub.ps1"
             $DestFile = "$CurrentDirectory\SCCM_Check_WMI--Results_$ADateStart.csv"
$Computers = get-Content "$CurrentDirectory\SCCM_Check_WMI--PCList.txt"
            $Failedlog = "$CurrentDirectory\SCCM_Check_WMI--Fails_$ADateStart.csv"

#Create Header line on results log
"PC Name,Online,CCMCACHE folder size,Persistent Cache size" | Set-Content $DestFile

# Run this
Invoke-Parallel -scriptfile $SubScript -inputobject $Computers -runspaceTimeout $Timeout -throttle $Throttle| Add-Content $DestFile


Write-Host "Building list of Time-outs..."
start-sleep -seconds 5
$lines = Get-Content "C:\temp\log.log"
ForEach ($midstring in $Lines)
{
	$string = $midstring.Replace(":'",',').replace('"','').Replace(';Removing','').Replace(';',',').Replace("'",'')
    $string | Select-String -pattern "TimedOut" | Add-Content -Path $Failedlog
}

# WRITE LOG FILE
  $ADateE = Get-Date
  $ADateEnd = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
  "$CurrentDirectory\$ScriptName`tScript end time`t$ADateEnd"| Add-Content $Log
$t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
"$CurrentDirectory\$ScriptName`tran $min minutes and $sec seconds." | Add-Content $Log



# SIG # Begin signature block
# MIIL1wYJKoZIhvcNAQcCoIILyDCCC8QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpVz9Z7bx3Ktskk8p/+ws7IOR
# Lp2gggk4MIIESzCCAzOgAwIBAgITYAAAAALo5xr3zuIi5wAAAAAAAjANBgkqhkiG
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
# MRYEFBXwzEIfiE+IgDhj8wnvoYYJGobJMA0GCSqGSIb3DQEBAQUABIIBAESznDVR
# WUy4LpnYN/2C56bYwX3wS9eyxmoei1wyr3WwvsY55eFMUSYkwMcMDMNOVRTaV0i2
# aksGhFpKsA0m6EsJ9wETrgFtj8UbK+isTbevM6JCbIjlpR9Ela2pWpZV368gq/Sy
# XB/Wt0MgOIuEJUdHAr9hXM/4v0L9V/cji90LprzmqkGfL4Edt9PvQc/lyYa+LAZ8
# rfMKUx6FF6p8eJRZYottkTAGENTT3hNvGf/zV1+GyErnAxTYmWwN/BtP/3MsD1Eu
# ySm3eZF5UB2qvqpH31WoP1xyKbww6knA1TahRVjD4eyBYM9j2CIvo5ebX0Z13y9h
# t5ni0KMwib8PFg4=
# SIG # End signature block
