Import-Module BitsTransfer
}
    }
Import-Module BitsTransfer

$Computers = 'COMPUTER528'


$Log = "D:\19_SCCM_Client"
$Source = '\\ILVM02\D$\19_SCCM_Client'

ForEach($computer in $computers)
{
    If(Test-Connection $computer -count 1 -quiet -BufferSize 16)
    {
        $System = gwmi -computer $computer Win32_ComputerSystem # normally non-terminating
        $Type = $System.SystemType

        $Dest = "\\$computer\C$\Temp"
    	If(!(Test-Path $Dest)){New-Item -ItemType Directory -Path $Dest -Force | Out-Null}
        Write-Host "$Computer" -ForegroundColor Cyan
        
	    # 64-bit OS check
	    If ($Type -eq "x64-based PC")
	    {
            $Source1 = "$Source\ccmsetup_x64\*.*"
            Write-Host "$Computer`t`tCopying tools..." -ForegroundColor Magenta
            Start-BitsTransfer $Source1 $Dest
        }
        Else
        {
            $Source1 = "$Source\ccmsetup_x64\ccmsetup_x86\*.*"
            Write-Host "$Computer`t`tCopying tools..." -ForegroundColor Magenta
            Start-BitsTransfer $Source1 $Dest
        }
    }
    Else
    {
            Write-Host "$Computer`t`tCould not ping..." -ForegroundColor Red
    }
}
