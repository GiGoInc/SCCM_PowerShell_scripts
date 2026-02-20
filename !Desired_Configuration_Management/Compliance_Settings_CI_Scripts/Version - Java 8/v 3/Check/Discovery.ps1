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
	# CHECK JAVA
		$output += 'Java - '
		IF ((Test-Path "\\$computer\C$\Program Files (x86)\Java\jre*\bin\java.exe") -and ($Type -eq 'x64-based PC'))
		{
            $ErrorActionPreference = 'silentlycontinue'
            $moduleFiles = Get-ChildItem "\\$computer\C$\Program Files (x86)\Java\jre*\bin\java.exe"
            
            # Identify the most recent version available
            $mostRecent = ($moduleFiles |
                Select-Object -ExpandProperty FullName |
                % {$_.replace('\bin','')} | 
                % {$_.replace('jre1.','')} | 
                % {$_.replace('_','.')} | 
                Split-Path -Parent | 
                Split-Path -Leaf |
                %{[version]$_} |
                Sort-Object -Descending |
                Select-Object -First 1).ToString()
            $ErrorActionPreference = 'continue'
            If ($mostRecent.length -ne 0){$Output += $mostRecent}
		}

		IF ((Test-Path "\\$computer\C$\Program Files\Java\jre*\bin\java.exe") -and ($Type -eq 'X86-based PC'))
		{
            $ErrorActionPreference = 'silentlycontinue'
            $moduleFiles = Get-ChildItem "\\$computer\C$\Program Files\Java\jre*\bin\java.exe"
            
            # Identify the most recent version available
            $mostRecent = ($moduleFiles |
                Select-Object -ExpandProperty FullName |
                % {$_.replace('\bin','')} | 
                % {$_.replace('jre1.','')} | 
                % {$_.replace('_','.')} | 
                Split-Path -Parent | 
                Split-Path -Leaf |
                %{[version]$_} |
                Sort-Object -Descending |
                Select-Object -First 1).ToString()
            $ErrorActionPreference = 'continue'
    		If ($mostRecent.length -ne 0){$Output += $mostRecent}
		}

		If ($mostRecent.Length -eq 0)
		{
			$mostRecent = "No_Java_8_versions"
		}

If ($mostRecent -ge '8.0.152')
{
    'Compliant'
}
Else
{
    'Non-Compliant'
}
