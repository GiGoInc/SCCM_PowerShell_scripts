$Computers = 'L6TQVTG3', `
}
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
$Computers = 'L6TQVTG3', `
'LG921PC2', `
'LBW52R93', `
'ALK3CC04', `
'XXXXPSTOOLS31', `
'L160H3X2', `
'LAS1SP10', `
'FLMDET03', `
'L1TYC3X2', `
'LB0HW433', `
'L7GVXHL3', `
'L5L2YMG3', `
'MSHNSP12', `
'LGV436Y2', `
'LH4ZV533', `
'LAE8SP09', `
'LAF9SP30', `
'LH2ZGFG3', `
'LAF4SP21', `
'LBLX0P13', `
'MSGPSP16', `
'L685Y473', `
'LG79W433'

$total = $computers.count
$SCCMShare = "D:\Uber\!Base_Applications\19_SCCM_Client\ccmsetup"

$i = 1
Foreach ($Computer in $Computers)
{
    $SDate = (GET-DATE)
    $DestShare = "\\$computer\C$\Windows\"
    $erroractionpreference = 'Stop'
    Try
    {
        # Test if computer is online
        $Alive = Test-Connection -ComputerName $Computer -Quiet
        If ($Alive)
        {
            If (Test-Path $DestShare)
            {
                # Copy CCMSETUP folder
                "$i of $total`t$Computer`tUpdating files..."
                Copy-Item -Path $SCCMshare -Destination $DestShare -Recurse -Force
                #Install x64 Client
                "$i of $total`t$Computer`tInstalling client..."
                Invoke-Command -ComputerName $Computer -ScriptBlock {Start-Process -FilePath 'C:\windows\ccmsetup\ccmsetup.exe' -ArgumentList ('/BITSPriority:FOREGROUND SMSMP=SERVER.DOMAIN.COM /forceinstall /mp:SERVER.DOMAIN.COM smssitecode=XX1 fsp=SERVER.DOMAIN.COM SMSCACHESIZE=30720') -Wait}       
            }
            Else { "$i of $total`t$Computer`tFailed to find $DestShare..." }    
        }
        Else { "$i of $total`t$Computer`tUnpingable" }
    }
    Catch { "$i of $total`t" + $error[0] }
    Finally { $erroractionpreference = 'Continue' }
    $i++
    $EDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $SDate –End $EDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
}
