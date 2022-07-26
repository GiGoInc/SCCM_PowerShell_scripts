Import-Module BitsTransfer

$Computers = 'MS1TSP13'


$Log = "\\Computer1\D$\Uber\!Base_Applications\19_SCCM_Client"
ForEach($computer in $computers)
{
    If(test-connection $computer -count 1 -quiet -BufferSize 16)
    {
        $System = gwmi -computer $computer Win32_ComputerSystem # normally non-terminating
        $Type = $System.SystemType

        $Dest = "\\$computer\C$\Temp"
    	If(!(Test-Path $Dest)){New-Item -ItemType Directory -Path $Dest -Force | Out-Null}
        Write-Host "$Computer" -ForegroundColor Cyan
        
	    # 64-bit OS check
	    If ($Type -eq "x64-based PC")
	    {
            $Source1 = '\\Computer1\D$\Uber\!Base_Applications\19_SCCM_Client\ccmsetup_x64\*.*'
            Write-Host "$Computer`t`tCopying tools..." -ForegroundColor Magenta
            Start-BitsTransfer $Source1 $Dest
        }
        Else
        {
            $Source1 = '\\Computer1\D$\Uber\!Base_Applications\19_SCCM_Client\ccmsetup_x86\*.*'
            Write-Host "$Computer`t`tCopying tools..." -ForegroundColor Magenta
            Start-BitsTransfer $Source1 $Dest
        }
    }
    Else
    {
            Write-Host "$Computer`t`tCould not ping..." -ForegroundColor Red
    }
}
