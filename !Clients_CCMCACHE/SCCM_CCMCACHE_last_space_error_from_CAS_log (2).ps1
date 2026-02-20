< #
 # SIG  # End signature block
 # G44606cLnmYrU+E=
< #
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,Result

.Example
PS C:> .\CCMCACHE_last_space_error_from_CAS_log--bsub.ps1" -computer 'Computer1'
	Computer1,Yes,PORT=3029
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
    [String]$LogFile = 'C:\Temp\errorlog.txt'
    )

if(test-connection $computer -count 1 -quiet -BufferSize 16)
{
$Output = $null
 #Create an empty dynamic array
$Output = @()

    Try
    {
        if (Test-Path -Path "\\$computer\C$\Windows\CCM\logs\CAS.log")
        {
            Try{
             # Check for size of cache
                $Line = Select-String -Path "\\$computer\C$\Windows\CCM\logs\CAS.log" -pattern "Not enough space in Cache"
                $lastline = $line[-1]
                $s4 = $lastline | out-string
                $s5 = $s4 -replace '[^\p{L}\p{Nd}]' , ';'
                $s5 = $s5 -replace ';;;' , ';'
                $s5 = $s5 -replace ';;' , ';'
                $s5 = $s5 -replace ';;' , ';'
                $s5 = $s5 -replace ';;' , ';'
                $s5 = $s5.TrimStart(';').replace(';C;Windows',':')
                $s5 = $s5 -replace 'Not;enough;space;in;Cache' , ':Not enough space in Cache:'
                $s5 = $s5 -replace ';date;' , ' date:'
                $s5 = $s5 -replace ';component' , ':component'
                $s5 = $s5 -replace ' ;' , ';'
                $s5 = $s5 -replace '; ' , ';'
                $s5 = $s5 -replace ';' , ' '
                $s5 = $s5 -replace ': ' , ':'
                $s5 = $s5 -replace ' :' , ':'
                $s5 = $s5.split(':')
                
                $space = $s5[2]
                 $date = $s5[4].Replace(' ' , '/')
                $output += ($space+','+$date)
            } #End Try
            Catch{$output += ("Couldn't find space error in CAS.log"+',')}
            }
        else
        {
            $output += ("Error finding CAS.log")
        }
    } #End Try
    Catch{$output += ("Couldn't connect to CAS.log"+',')}


    $object = [pscustomobject] @{
        Computer=$computer;
        Responding="Yes";
        String=$("$output")
    }
}
else
{
    $object = [pscustomobject] @{
        Computer=$computer;
        Responding="No";
        String="Couldn't ping PC"
    }
        
}

$object.Computer,$object.Responding,$object.String -join ","
 # SIG  # Begin signature block
 # MIIL1wYJKoZIhvcNAQcCoIILyDCCC8QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
 # gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
 # AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfPZO0Y26tBAu3If5TN8PsHyC
 # UD6gggk4MIIESzCCAzOgAwIBAgITYAAAAALo5xr3zuIi5wAAAAAAAjANBgkqhkiG
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
 # MRYEFPLeSWx7eDdQlcm7ktg2h0juDjc0MA0GCSqGSIb3DQEBAQUABIIBAJdDG+tF
 # Zns4PEK9Ijd/MAhE71ftmhDfJhEkxr4Tmjec2lS6MHYY2pq+D4WVwiaWIf3l0LrN
 # 2iThltavan8AQ6QIKhnj9fllJOGDKmd+8gVAJH7oVh0kuwMgt33V6LJUrpg5qVHL
 # RXONGkDnAJeWjZWgSseXgtSyaqKoivpKjtnEvQ5pOHsgHBGAEe2KrZsebs9tolej
 # F9Tka3Q+KuFCf6BGMUqlxStXQjORH0unRlrXbfonF9ge500fLUKT/fqGFyB3EMDA
 # UaaX4pGVd93jO6uiRW2W+cHwe5AatuZrGX0Vs7a9QA+OVxomuhc9UKDMK9wodJO3
 # G44606cLnmYrU+E=
 # SIG  # End signature block
