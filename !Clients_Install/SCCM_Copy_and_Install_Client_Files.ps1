$computers = 'L32DG7S3', `
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
    $Sec = $Span.Seconds
$computers = 'L32DG7S3', `
            'LAG6SP13', `
            'FISPC-S2', `
            'L6VF0VL3', `
            'LBK5YJ34'

####################################################################################
####################################################################################
$SSDate = (GET-DATE)

$Source = '\\ILVM02\D$\19_SCCM_Client'
 $total = $computers.count

Import-Module BitsTransfer

####################################################################################
####################################################################################
$i = 1
Foreach ($Computer in $Computers)
{
    $SDate = (GET-DATE)
    $erroractionpreference = 'Stop'
    Try
    {
        If(Test-Connection $computer -count 1 -quiet -BufferSize 16)
        {
            $System = gwmi -computer $computer Win32_ComputerSystem
            $Type = $System.SystemType

            $Dest = "\\$computer\C$\Windows\ccmsetup"
        	If(!(Test-Path $Dest)){New-Item -ItemType Directory -Path $Dest -Force | Out-Null}
            Write-Host "$Computer" -ForegroundColor Cyan
            
            $CCMSource = "$Source\ccmsetup\*.*"
            Write-Host "$Computer`t`tCopying tools..." -ForegroundColor Magenta
            Copy-Item $CCMSource $Dest -Recurse -Force
        }
        Else
        {
                Write-Host "$Computer`t`tCould not ping..." -ForegroundColor Red
        }
    }
    Catch { "$i of $total`t" + $error[0] }
    Finally { $erroractionpreference = 'Continue' }
    $EDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $SDate –End $EDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
}
####################################################################################
####################################################################################
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

    $SEDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $SSDate –End $SEDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
