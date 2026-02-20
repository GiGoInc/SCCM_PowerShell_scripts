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
	# CHECK ATTACHMATE
		$output += 'Attachmate - '

        $ATPaths = "\\$computer\C$\aextra\extra.exe", `
                   "\\$computer\C$\Program Files\EXTRA!\extra.exe", `
                   "\\$computer\C$\Program Files (x86)\Attachmate\EXTRA!\extra.exe", `
                   "\\$computer\C$\Program Files\Attachmate\EXTRA!\extra.exe"


        ForEach ($ATPath in $ATPaths)
        {
		    IF (Test-Path $AtPath)
		    {
		    	$AtFile = Get-ChildItem $AtPath
		    	$Attachmate = $AtFile.VersionInfo.ProductVersion
    	    	If ($AtFile.length -ne 0){$Output += $Attachmate}
		    }
        }

		If ($Attachmate -eq $null)
		{
			$Attachmate = "No_Attachmate_installs"
		}

If ($Attachmate -eq '9.1.1071.0')
{
    'Compliant'
}
Else
{
    'Non-Compliant'
}
