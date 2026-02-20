$sessions = Get-Content "C:\!Projects\Adobe_Flash\pc.txt" | % { New-PSSession -ComputerName $_ -ThrottleLimit 100}
}
    }
$sessions = Get-Content "C:\!Projects\Adobe_Flash\pc.txt" | % { New-PSSession -ComputerName $_ -ThrottleLimit 100}

foreach($session in $sessions)
{
    Write-Host "Starting work on $session...."
    try
    {
        $ErrorActionPreference = "Stop"; #Make all errors terminating

       Invoke-Command -session $session -scriptblock {
            # Compliance_File_Check_IF_Exists_Discovery.ps1
             $RegPath1x64 = "HKLM:\SOFTWARE\Wow6432Node\Macromedia\FlashPlayerActiveX"
              $RegKey1x64 = "Version"
             $RegType1x64 = "String"
            $RegValue1x64 = "21.0.0.242"
            
             $RegPath2x64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{FA944726-00F8-43B5-BB97-33E6FF409C22}"
              $RegKey2x64 = "DisplayName"
             $RegType2x64 = "String"
            $RegValue2x64 = "21.0.0.242"
           
             $RegPath1x86 = "HKLM:\SOFTWARE\Macromedia\FlashPlayerActiveX"
              $RegKey1x86 = "Version"
             $RegType1x86 = "String"
            $RegValue1x86 = "21.0.0.242"
            
             $RegPath2x86 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FA944726-00F8-43B5-BB97-33E6FF409C22}"
              $RegKey2x86 = "DisplayName"
             $RegType2x86 = "String"
            $RegValue2x86 = "21.0.0.242"
            [int]$x = '0'
            
            # Compliance Regedit - Discovery Script
            $RegCheck1x64 = Get-ItemProperty $RegPath1x64 -Name $RegKey1x64 2>$null
            If (($RegCheck1x64.$RegKey1x64 -ne $null) -and ($RegCheck1x64.$RegKey1x64 -ge "21.0.0.242")){$global:x++}

            $RegCheck2x64 = Get-ItemProperty $RegPath2x64 -Name $RegKey2x64 2>$null
            If (($RegCheck2x64.$RegKey2x64 -ne $null) -and ($RegCheck2x64.$RegKey2x64 -ge "21.0.0.242")){$global:x++}
           
            $RegCheck1x86 = Get-ItemProperty $RegPath1x86 -Name $RegKey1x86 2>$null
            If (($RegCheck1x86.$RegKey1x86 -ne $null) -and ($RegCheck1x86.$RegKey1x86 -ge "21.0.0.242")){$global:x++}
            
            $RegCheck2x86 = Get-ItemProperty $RegPath2x86 -Name $RegKey2x86 2>$null
            If (($RegCheck2x86.$RegKey2x86 -ne $null) -and ($RegCheck2x86.$RegKey2x86 -ge "21.0.0.242")){$global:x++}

            #If ($x -gt '2')
            #{
            $PC = $session.ComputerName
                Write-Host "$PC found $x"
            #}
        }
    }catch{
        #Write-Output Caught the exception;
        #Write-Output $Error[0].Exception;
        if($_.Exception.ErrorCode -eq 0x800706BA){Write-Host "WMI_-_RPC_Server_Unavailable_-_HRESULT:_0x800706BA"}		
        ElseIf($_.Exception.ErrorCode -eq 0x80070005){Write-Host "WMI_-_Access_is_Denied_-_HRESULT:_0x80070005"}
        Else{Write-Host "WMI_error_occured"}
    }finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}
