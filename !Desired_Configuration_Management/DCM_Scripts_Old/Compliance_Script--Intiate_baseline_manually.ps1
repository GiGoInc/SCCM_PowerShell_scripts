#$Computers = 'CR45Z12','CQY4Z12','COMPUTER71','CJ3LM02','CAUDEVCLXAK','C62XQ22','C62RQ22','BK60B42','BK5Y942','BK43B42','CONVERT01'
}
    }
#$Computers = 'CR45Z12','CQY4Z12','COMPUTER71','CJ3LM02','CAUDEVCLXAK','C62XQ22','C62RQ22','BK60B42','BK5Y942','BK43B42','CONVERT01'
}
    }
#$Computers = 'CR45Z12','CQY4Z12','COMPUTER71','CJ3LM02','CAUDEVCLXAK','C62XQ22','C62RQ22','BK60B42','BK5Y942','BK43B42','CONVERT01'
#$Computer = 'COMPUTER71'


# '447RH72','LAG0SP07','HRKYN32','COMPUTER356','BCYYQ22'

# '12DPL32','79CNM12','ALC1SP42','ALP2ET05','C8LJG12','F4VPL32','LAC2SP13'
#'12DPL32','1669L12','26XZP12',cls'27RNM12','3GD3N12','3MBNM12','41QNM12','6QHNH12','79CNM12','7BDNH12','COMPUTER33','8GXZP12','ALC1SP42','ALP2ET05','BXM9G12','C8LJG12','F4VPL32','F7W1H12','FFFNH12','HBBNH12','HHBNH12','JVKFJ12','LAC2SP13','LAC2SP13','LACSLT04','LAFILT03','LAISLT02','LAISLT05','LOANER12','XXXXLT23','XXXXOT02','MSIDLT05'
#$computers = '41QNM12','6QHNH12','79CNM12','7BDNH12','COMPUTER33','8GXZP12','ALC1SP42','ALP2ET05','BXM9G12','C8LJG12','F4VPL32','F7W1H12','FFFNH12','HBBNH12','HHBNH12','JVKFJ12','LAC2SP13','LAC2SP13','LACSLT04','LAFILT03','LAISLT02','LAISLT05','LOANER12','XXXXLT23','XXXXOT02','MSIDLT05'



$computers = '6QHNH12','1669L12','41QNM12','12DPL32','ALC1SP42'
<#

$computer = 'LAC2SP13'
Start-Process C:\WINDOWS\SYSWOW64\cmtrace.exe "\\$COMPUTER\C$\Windows\CCM\LOGS\CAS.LOG"
Start-Process explorer.exe "\\$COMPUTER\C$\Windows\CCMCACHE"

If(!(Test-Path "\\$COMPUTER\C$\Windows\Logs\Software")){New-Item -Path "\\$COMPUTER\C$\Windows\Logs\Software" -ItemType Directory -Force}
"$(get-date -format MM/dd/yyy)  *  $(get-date -format HH:mm:ss)   ****   Start SCCM_clean_CACHE_using_PSSESSION_SingleMachine" | Add-Content "\\$COMPUTER\C$\Windows\Logs\Software\SCCM_client_cache_cleanup.log"
 Start-Process C:\WINDOWS\SYSWOW64\cmtrace.exe "\\$COMPUTER\C$\Windows\Logs\Software\SCCM_client_cache_cleanup.log"

#>

ForEach ($computer in $Computers)
{

    ############################################################################
    # Initiate Client Actions
    Import-Module C:\Scripts\!Modules\CMClient.psm1	
    
    Write-Output "Pinging...`t$Computer"
    $ping = gwmi Win32_PingStatus -filter "Address='$Computer'"
    if($ping.StatusCode -eq 0)
    {
        $pcip=$ping.ProtocolAddress;
        Write-Output "Starting SCCM Action - Data Discovery Cycle...."
		Invoke-CMClientDiscoveryDataCycle -Computername $Computer -AsJob
		Start-Sleep -Seconds 2
				Write-Output "Starting SCCM Action - Client Hardware Inventory...."
				Invoke-CMClientHardwareInventory -Computername $Computer  -AsJob
					Write-Output "Starting SCCM Action - Update Deployment Evaluation...."
					Invoke-CMClientUpdateDeploymentEvaluation -Computername $Computer -AsJob
        Write-Output "Complete...."
        Write-Output ""
    }Else{Write-Output "$Computer unpingable"}

        
    ############################################################################
    # Check Application Baselines
    Try
    {
        $ErrorActionPreference = "Stop"
        $errorCode = $null
        $Baselines = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
        ForEach ($B in $Baselines)
        {
            $Dname = $b.DisplayName
            $Name = $b.Name
            Write-Output "DCM - $DName"
        }

        ############################################################################
        # Run Application Baselines
        $Baselines = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
        If ($baselines.DisplayName -eq 'SCCM Clean CACHE')
        {
            Write-Host "Found 'SCCM Clean CACHE' baseline"
            $BS = $Baselines | % { ([wmiclass]"\\$Computer\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) }
        }
    }
    Catch
    {
        If ($errorcode -ne 0)
        {
            $es = [string]$error[0]
            If ($es -like "*Cannot index into null array*")
            {
                Write-Host "$Computer"  -ForegroundColor green  -nonewline
                Write-Host " - can't connect to WMI" -ForegroundColor Red
            }
            ElseIf ($es -like "*The RPC server is unavailable*")
            {
                Write-Host "$Computer"  -ForegroundColor Green  -nonewline
                Write-Host " - RPC server is unavailable" -ForegroundColor Red
                Write-Host "Can't initiate DCM baseline" -ForegroundColor Green
            }
        }
    }
    Finally
    {
        $ErrorActionPreference = "Continue";
    }
}
