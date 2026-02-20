If(!(Test-Path 'C:\Temp')){New-Item -ItemType Directory -Path 'C:\Temp'}
#>
\\COMPUTER00\ROOT\ccm\dcm:SMS_DesiredConfiguration.IsMachineTarget=true,Name="ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Baseline_181bbd84-54a0-4c75-8881-cf72d2a6eb51",Version="3"
If(!(Test-Path 'C:\Temp')){New-Item -ItemType Directory -Path 'C:\Temp'}
#>
\\COMPUTER00\ROOT\ccm\dcm:SMS_DesiredConfiguration.IsMachineTarget=true,Name="ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Baseline_181bbd84-54a0-4c75-8881-cf72d2a6eb51",Version="3"
If(!(Test-Path 'C:\Temp')){New-Item -ItemType Directory -Path 'C:\Temp'}
If(!(Test-Path 'C:\Windows\Logs\Software')){New-Item -ItemType Directory -Path 'C:\Windows\Logs\Software'}
  $File = "D:\Powershell\!SCCM_PS_scripts\!Clients_Actions\SCCM_Clean_Client_Baselines--PCList.txt"
$Output = "D:\Powershell\!SCCM_PS_scripts\!Clients_Actions\SCCM_Clean_Client_Baselines--Results.csv"

Function RunFunc ($Lines)
{
	ForEach ($Computer in $Lines)
	{
        Write-Host "$ADate -- $Computer" -ForegroundColor Yellow
	    $ADate = Get-Date
        # Binding \\$srv\root\ccm:SMS_Client
			$SMSCli = [wmiclass] "\\$Computer\root\ccm:SMS_Client"
		If($SMSCli)
        {
            Write-Host 'Machine Policy Agent Cleanup' -ForegroundColor Magenta
			$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000040}")   # Machine Policy Agent Cleanup
			Start-Sleep -s 10
            Write-Host 'Discovery Data Collection Cycle' -ForegroundColor Magenta
			$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000103}")   # Discovery Data Collection Cycle
			Start-Sleep -s 2
            Write-Host 'Request Machine Assignments' -ForegroundColor Magenta
			$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000021}")   # Request Machine Assignments
			Start-Sleep -s 5
            Write-Host 'Evaluate Machine Policies' -ForegroundColor Magenta
            $SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000022}")	# Evaluate Machine Policies
            Write-Host 'Hardware Inventory' -ForegroundColor Magenta
			$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000110}") 	# Hardware Inventory
			Start-Sleep -s 10
            Write-Host "$ADate -- $Computer"
			"$ADate -- $Computer --Executed" | Add-Content $Output
		}
		Else
        {
            Write-Host "$ADate --  $Computer -- Could not bind WMI class SMS_Client" -ForegroundColor Red
			"$ADate --  $Computer -- Could not bind WMI class SMS_Client" | Add-Content $Output
		}
	}
}
(Get-Content $File) | ForEach-Object {Invoke-Command -ScriptBlock ${Function:RunFunc} -ArgumentList $_}


###########################################################################################################################
###########################################################################################################################


$ADate = Get-Date
$Computer = 'COMPUTER00'

# Delete DCM Key
    Get-WmiObject -ComputerName $Computer -Query "Select * From __Namespace Where Name='dcm'" -Namespace "root\ccm" | Remove-WmiObject -Verbose | Out-Host

# Refresh SCCM Client
    Write-Host "$ADate -- $Computer" -ForegroundColor Yellow

    # Binding \\$srv\root\ccm:SMS_Client
		$SMSCli = [wmiclass] "\\$Computer\root\ccm:SMS_Client"
	If($SMSCli)
    {
        Write-Host 'Machine Policy Agent Cleanup' -ForegroundColor Magenta
		$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000040}")   # Machine Policy Agent Cleanup
		Start-Sleep -s 10
        Write-Host 'Discovery Data Collection Cycle' -ForegroundColor Magenta
		$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000103}")   # Discovery Data Collection Cycle
		Start-Sleep -s 2
        Write-Host 'Request Machine Assignments' -ForegroundColor Magenta
		$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000021}")   # Request Machine Assignments
		Start-Sleep -s 5
        Write-Host 'Evaluate Machine Policies' -ForegroundColor Magenta
        $SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000022}")	# Evaluate Machine Policies
        Write-Host 'Hardware Inventory' -ForegroundColor Magenta
		$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000110}") 	# Hardware Inventory
		Start-Sleep -s 10
        Write-Host "$ADate -- $Computer"
		"$ADate -- $Computer --Executed" | Add-Content $Output
	}
	Else
    {
        Write-Host "$ADate --  $Computer -- Could not bind WMI class SMS_Client" -ForegroundColor Red
		"$ADate --  $Computer -- Could not bind WMI class SMS_Client" | Add-Content $Output
	}


<#
$a = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Query "Select * From SMS_DesiredConfiguration Where Name ='C:\\Test'"
$a | Remove-WMIObject


$a = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Query "Select * From SMS_DesiredConfiguration Where Name ='ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Baseline_d310bd20-3d12-49ef-b6de-e72ea006a944'"
$a | Remove-WMIObject
$a = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Query "Select * From SMS_DesiredConfiguration Where Name ='ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Baseline_181bbd84-54a0-4c75-8881-cf72d2a6eb51'"
$a | Remove-WMIObject

\\COMPUTER00\ROOT\ccm\dcm:
################################################
$Computer = 'COMPUTER00'
$a = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Query "Select * From SMS_DesiredConfiguration"
$a | Remove-WMIObject


# $ns=[WMICLASS]"\\$Computer\root\ccm:__namespace"
$ns=[wmiclass]'root/ccm:__namespace'
$sc=$ns.CreateInstance()
$sc.Name='dcm'
$sc.Put()

$newClass = New-Object System.Management.ManagementClass ("root\ccm\dcm", [String]::Empty, $null)
$newClass["__CLASS"] = "SMS_DesiredConfiguration"
$newClass.Put()
################################################



\\COMPUTER00\ROOT\ccm\dcm:SMS_DesiredConfiguration.IsMachineTarget=true,Name="ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Baseline_d310bd20-3d12-49ef-b6de-e72ea006a944",Version="4"
\\COMPUTER00\ROOT\ccm\dcm:SMS_DesiredConfiguration.IsMachineTarget=true,Name="ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Baseline_181bbd84-54a0-4c75-8881-cf72d2a6eb51",Version="3"
#>
