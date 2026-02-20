$ErrorActionPreference = 'Stop'
Read-Host -Prompt 'Press Enter to exit...'

$ErrorActionPreference = 'Stop'
Try{Import-Module ActiveDirectory}
Catch{
    If($_.Exception.ErrorCode -ne 0)
    {
        # Write-Host $_.Exception.ErrorCode
        $oops = 'happened'
    }
}
Finally{$ErrorActionPreference = "Continue"}

$Entry = $null
$Data = @()
$L = $null
$Item = $null

$Computer = $env:COMPUTERNAME
$UserInfoFile = New-Item -type file -force "C:\Temp\UserInfo2.csv"
$ppath2 = "$computer\c$\Users"
$profileaccess2 = Test-Path \\$ppath2



If ($profileaccess2 -eq "TRUE")
{
    $profileNames = Get-Item "\\$ppath2\*"
    foreach ($profilename in $profilenames)
    {
        $accountName = (get-item $profilename).PSChildName
        $lastaccesstime = (get-item $profilename).LastAccessTime | 	Get-Date  –f "MM/dd/yyyy"
        $Data += "$lastaccesstime,$accountName"
    }
    # SORT DATA
    $Lines = @()
    $separator = ','
    $Data | % {
        $Stuff = $($_ -split $separator)
        [DateTime]$P1 = $Stuff[0]
        $P2 = $Stuff[1]
        $o = New-Object PSObject -property @{Date = $P1; User = $P2; FullLine = $_}
        $Lines += , $o
    }
    $SortedStrings = $Lines | sort Date, User | select -ExpandProperty FullLine

    Write-Host ''
    ForEach ($Entry in $SortedStrings)
    {
        ForEach ($Item in $entry)
        {
            $Items = $entry.split(',')
            $LogonDate = $Items[0]
            $LogonUser = $Items[1]

            #$User = Get-ADUser aUSER1 -Properties DisplayName | select DisplayName
            #$DisplayName = $User.DisplayName
            Write-Host "`t$LogonDate" -NoNewline -ForegroundColor Green
                If ($oops -eq 'happened')
                {
                    Write-Host "`t$LogonUser" -ForegroundColor Yellow
                }
                Else
                {
                    Write-Host "`t$LogonUser" -NoNewline -ForegroundColor Yellow
                    Write-Host "`t--`t$DisplayName" -ForegroundColor Cyan
                }
            Write-Host "`t----------------------------------" -ForegroundColor Magenta
        }
    }
}
Else
{
    Write-Host -ForegroundColor Red "Can't access Computer -> $computer"
    "$Computer" | Out-File FailedComputers_File -Encoding ASCII -Append
}

Read-Host -Prompt 'Press Enter to exit...'
