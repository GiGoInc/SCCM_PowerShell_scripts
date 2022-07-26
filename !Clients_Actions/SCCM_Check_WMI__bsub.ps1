[CmdletBinding()]
param(
    # Support for multiple computers from the pipeline
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in computer name and press Enter to execute')]
    [string]$computer,

    # Switch to turn on Error Logging
    [Switch]$ErrorLog,
    [String]$LogFile = 'C:\Scripts\AD_Files\errorlog.txt'
    )

Function CheckDNS
{ 
    Try
    {
        $a = [System.Net.Dns]::GetHostAddresses($Computer)
        ForEach ($b in $a)
        {
            If ($b.Address -ne $Null)
            {
                $IP = $b.IPAddressToString
                Write-host "IP Address:    " -NoNewline
                Write-Host "$IP" -ForegroundColor Green
            }
        }
    }
    Catch
    {
    If($_.Exception.ErrorCode -ne '0')
        {
            $IP = $_
            Write-Host "IP Address: $IP" -ForegroundColor Red
        }
    }
    Finally
    {
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}

Function CheckClientVersion
{
    #Create an empty dynamic array
    $Output = @()
    
    #Adjusting ErrorActionPreference to stop on all errors
    $TempErrAct = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    Try
    {
        $ErrorActionPreference = "Stop"; #Make all errors terminating
        $CCM = Get-WmiObject -Namespace 'root\ccm' -Class 'SMS_Client' -Impersonation 3 -ComputerName $computer
        $Ver = $CCM.ClientVersion
            Write-host "SCCM Version:  " -NoNewline
            Write-Host $Ver -ForegroundColor Green
    }
    Catch
    {
        if($_.Exception.ErrorCode -ccontains "0x80010108")
        {
            Write-host "WMI doesn't have the Instance for SMS_Client. Repair needed"
            # Invoke-Expression ("msiexec.exe /fpecms '{343D4507-997F-4553-9F86-2BB81F19A05E}'")
            # Invoke-Command -ScriptBlock {msiexec.exe /fpecms '{343D4507-997F-4553-9F86-2BB81F19A05E}'} -ComputerName $computer
        }
        ElseIf($_.Exception.ErrorCode -ne '0')
        {
            $Ver = $_
            Write-host "SCCM Version:  " -NoNewline
            Write-Host $Ver -ForegroundColor Red
        }
    }
    Finally
    {
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}

Function CheckClientCache
{ 
    Try
    {
    		$objects = $null
    		$count = $null
            $ts = $null
            $cacheInfo = $null
            $CMObject = new-object -com "UIResource.UIResourceMgr"
            $cacheInfo = $CMObject.GetCacheInfo()
            $count = $cacheInfo.Count
            $ts = $cacheInfo.TotalSize
            If ($ts -eq $null)
            {
                $ts = '0'
            }
            Else
            {
                $ts = $cacheInfo.TotalSize 
            }
            If ($count -eq $null)
            {
                $count = '0'
            }
            Else
            {
                $count = $cacheInfo.Count
            }
    		Write-host "SCCM Database: " -NoNewline
    		Write-host "$ts Total Size" -ForegroundColor Green

    		Write-host "SCCM Database: " -NoNewline
    		Write-host "$count Items" -ForegroundColor Green
    }
    Catch
    {
    If($_.Exception.ErrorCode -ne '0')
        {
            Write-Host $_
        }
    }
    Finally
    {
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}

Function CheckCCMService
{ 
    Try
    {
        $a = Get-Service -ComputerName $computer -Name CcmExec -ErrorAction Stop
            Write-host "SCCM service:  " -NoNewline
            Write-Host "Running" -ForegroundColor Green
    }
    Catch
    {
    If($_.Exception.ErrorCode -ne '0')
        {
            Write-host "SCCM service:  " -NoNewline
            Write-Host $_ -ForegroundColor Red
        }
    }
    Finally
    {
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}


If(Test-Connection $computer -count 1 -quiet -BufferSize 16)
{
    Write-Host ""
    Write-Host "Checking $computer..." -ForegroundColor Cyan

    CheckDNS
    CheckClientVersion
    CheckClientCache
    CheckCCMService
}
ELSE
{
	$object = [pscustomobject] @{
	Computer=$computer;
	Responding="No";
	File="Couldn't ping PC"
	}
}







