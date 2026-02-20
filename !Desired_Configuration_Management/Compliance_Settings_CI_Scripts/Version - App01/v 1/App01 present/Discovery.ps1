$Computer = "$env:COMPUTERNAME"
}
    'Non-Compliant'
$Computer = "$env:COMPUTERNAME"

    #Create an empty dynamic array
    $Output = @()

    $System = $null
    $mostRecent = $null
    $Chrome = $null
    $F9 = $null
    $Attachmate = $null
    $APP1 = $null
    $AR = $null

	############################################################################################################
	# CHECK OS VERSION
		$output += 'OS Version - '
		Try
		{
			$ErrorActionPreference = "Stop"; #Make all errors terminating
			$System = gwmi -computer $computer Win32_ComputerSystem # normally non-terminating
			$Type = $System.SystemType
			$Output += $Type
		}
		catch
		{
			#Write-Output Caught the exception;
			#Write-Output $Error[0].Exception;
			if ($_.Exception.ErrorCode -eq 0x800706BA)
			{
				$OS86 = "WMI_-_RPC_Server_Unavailable_-_HRESULT:_0x800706BA"
				$Output += $OS86
			}
			ElseIf ($_.Exception.ErrorCode -eq 0x80070005)
			{
				$OS86 = "WMI_-_Access_is_Denied_-_HRESULT:_0x80070005"
				$Output += $OS86
			}
			Else
			{
				$OS86 = "WMI_error_occured"
				$Output += $OS86
			}
		}
		finally
		{
			$ErrorActionPreference = "Continue"; #Reset the error action pref to default
		}    
	
	############################################################################################################
	# APP1 pointing to either COMPUTER129 or COMPUTER132
		$output += 'APP1 - '

		If (!(Test-Path "\\$computer\C$\Usr\Local\BPWCTL.EXE"))
		{
            $APP1 = "No_APP1_install"
			$Output += ("$APP1")
		}
        Else
		{
            $APP1 = "APP1_installed"
			$Output += ("$APP1")
		}

If ($APP1 -eq 'APP1_installed')
{
    'Compliant'
}
Else
{
    'Non-Compliant'
}
