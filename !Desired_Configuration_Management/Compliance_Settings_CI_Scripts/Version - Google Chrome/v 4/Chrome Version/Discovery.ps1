$Computer = "$env:COMPUTERNAME"
}
    'Non-Compliant'
$Computer = "$env:COMPUTERNAME"

    #Create an empty dynamic array
    $Output = @()

    $System = $null
    $mostRecent = $null
    $Chrome = $null
    $Five9 = $null
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
	# CHECK CHROME
		$output += 'Chrome - '
		$Chrome = "\\$computer\C$\Program Files\Google\Chrome\Application\chrome.exe"
		$Chromex86 = "\\$computer\C$\Program Files (x86)\Google\Chrome\Application\chrome.exe"
	
		IF (Test-Path $Chrome)
		{
			$CFile = (Get-Item $Chrome).VersionInfo | Select-Object FileVersion
			$Chrome = $CFile.FileVersion
			$Chrome = "$Chrome" -replace ', ', '.'
            If ($CFile.length -ne 0){$Output += $Chrome}
		}
		ElseIf (Test-Path $Chromex86)
		{
			$CFile = (Get-Item $Chromex86).VersionInfo | Select-Object FileVersion
			$Chrome = $CFile.FileVersion
			$Chrome = "$Chrome" -replace ', ', '.'
            If ($CFile.length -ne 0){$Output += $Chrome}
		}
	
		If ((!(Test-Path $Chrome)) -and (!(Test-Path $Chromex86)))
		{
			$Chrome = "No_Chrome_Installs"
		}

If ($Chrome -ge '67.0.3396.79')
{
    'Compliant'
}
Else
{
    'Non-Compliant'
}
