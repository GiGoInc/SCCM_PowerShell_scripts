$Computer = "alc1sp08"

    #Create an empty dynamic array
    $Output = @()

    $System = $null
    $mostRecent = $null
    $Chrome = $null
    $Five9 = $null
    $Attachmate = $null
    $Salespro = $null
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
			$Output += "No_Java_8_versions"
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
			$Output += "No_Chrome_Installs"
		}
	
	
	############################################################################################################
	# CHECK FIVE9 SOFTPHONE
		$output += 'Softphone - '
		$FS = "\\$computer\C$\Program Files\Five9\Five9Softphone-10.0\Five9SoftphoneSupervisor.exe"
		$FSx86 = "\\$computer\C$\Program Files (x86)\Five9\Five9Softphone-10.0\Five9SoftphoneSupervisor.exe"
	
		If (Test-Path $FS)
		{
			$9File = (Get-Item $FS).VersionInfo | Select-Object FileVersion
			$Five9 = $9File.FileVersion
			$Five9 = "$Five9" -replace ', ', '.'
    		If ($9File.length -ne 0){$Output += $Five9}
		}
		ElseIf (Test-Path $FSx86)
		{
			$9File = (Get-Item $FSx86).VersionInfo | Select-Object FileVersion
			$Five9 = $9File.FileVersion
			$Five9 = "$Five9" -replace ', ', '.'
    		If ($9File.length -ne 0){$Output += $Five9}
		}

		If ((!(Test-Path $FS)) -and (!(Test-Path $FSx86)))
		{
			$Output += "No_Five9_Softphone_install"
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
			$Output += "No_Attachmate_installs"
		}

	
	############################################################################################################
	# SalesPro pointing to either LAC2BR01 or LACIBR01
		$output += 'SalesPro - '

		If (!(Test-Path "\\$computer\C$\Usr\Local\BPWCTL.EXE"))
		{
            $Salespro = "No_Salespro_install"
			$Output += ("$Salespro")
		}
        Else
		{
            $Salespro = "Salespro_installed"
			$Output += ("$Salespro")
		}

	# ############################################################################################################
	# # CHECK BIGIP VPN
	# 	$output += 'Big IP - '
	# 	$F5 = "\\$computer\C$\Program Files\F5 VPN\f5fpc.exe"
	# 	$F5x86 = "\\$computer\C$\Program Files (x86)\F5 VPN\f5fpc.exe"
	# 
	# 	If (Test-Path $F5)
	# 	{
	# 		$IPFile = (Get-Item $F5).VersionInfo | Select-Object FileVersion
	# 		[string]$BigIP = $IPFile.FileVersion
	# 		$BigIP = "$BigIP" -replace ', ', '.'
    #         If ($BigIP.length -ne 0){$Output += $BigIP}
	# 	}
	# 	ElseIf (Test-Path $F5x86)
	# 	{
	# 		$IPFile = (Get-Item $F5x86).VersionInfo | Select-Object FileVersion
	# 		[string]$BigIP = $IPFile.FileVersion
	# 		$BigIP = $BigIP -replace ', ', '.'
    #         If ($BigIP.length -ne 0){$Output += $BigIP}
	# 	}
	# 	
    #     If ($BigIP.Length -eq 0)
    #     {
    #         $Output += "No_Big_IP_VPN_installs"
    #     }
	
	
	############################################################################################################
	# CHECK ADOBE READER
		$output += 'Adobe Reader - '

        $ARPaths = "\\$computer\C$\Program Files (x86)\Adobe\*Reader*\Reader\AcroRd32.exe", `
                   "\\$computer\C$\Program Files\Adobe\*Reader*\Reader\AcroRd32.exe"


        ForEach ($ARPath in $ARPaths)
        {
		    IF (Test-Path $ARPath)
		    {
			    $ARFile = Get-ChildItem "$ARPath"
			    $AR = $ARFile.VersionInfo.ProductVersion
                If ($ARFile.length -ne 0){$Output += $AR}
		    }
        }
	
		If ($AR -eq $null)
		{
			$Output += "No_Adobe_Reader_installs"
		}
	
	############################################################################################################
	############################################################################################################
	[string]$string = $Output -join ','
    $string = $string.Replace(' - ,',' - ')



If ($mostRecent -ge '8.0.152' -and $Chrome -ge '67.0.3396.79' -and $Five9 -eq '10.0.1' -and $Attachmate -eq '9.1.1071.0' -and $Salespro -eq 'Salespro_installed' -and $AR -ge '11.0.10.32')
{
    'Compliant'
    $mostRecent
     $Chrome
     $Five9 
     $Attachmate
     $Salespro
     $AR
}
Else
{
    'Non-Compliant'
    $mostRecent
     $Chrome
     $Five9 
     $Attachmate
     $Salespro
     $AR
}