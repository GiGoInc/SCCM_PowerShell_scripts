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
	# CHECK FIVE9 SOFTPHONE
		$output += 'Softphone - '

		$F9Paths = "\\$computer\C$\Program Files\Five9\Five9Softphone-10.0\Five9SoftphoneSupervisor.exe", `
		           "\\$computer\C$\Program Files (x86)\Five9\Five9Softphone-10.0\Five9SoftphoneSupervisor.exe"
	

        ForEach ($F9Path in $F9Paths)
        {
		    IF (Test-Path $F9Path)
		    {
			    $F9File = (Get-Item $F9Path).VersionInfo | Select-Object FileVersion
			    $F9 = $F9File.FileVersion
			    $F9 = "$F9" -replace ', ', '.'
    		    If ($F9File.length -ne 0){$Output += $F9}
		    }
        }

		If ($F9 -eq $Null)
		{
			$F9 = "No_Five9_Softphone_install"
		}
	

If ($F9 -eq '10.0.1')
{
    'Compliant'
}
Else
{
    'Non-Compliant'
}
