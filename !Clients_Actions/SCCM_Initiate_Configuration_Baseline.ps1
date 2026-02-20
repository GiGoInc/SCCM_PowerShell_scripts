$FileLocation = "D:\Powershell\!SCCM_PS_scripts\!Clients_Actions\SCCM_Initiate_Configuration_Baseline_output.txt"
$R | Format-Table
$R = $MC.InvokeMethod($Method, $InParams, $null)
$FileLocation = "D:\Powershell\!SCCM_PS_scripts\!Clients_Actions\SCCM_Initiate_Configuration_Baseline_output.txt"

$A = Get-Date
$Date = $a.ToShortDateString()
$Time = $a.ToShortTimeString()
"WinRM_fix.ps1 - Script start`t|`t$Date $Time" | Add-Content $FileLocation


$Computer = "lac2sp48"

$Baselines = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
ForEach ($BaseLine in $BaseLines)
{
	$BaseLineDN = $BaseLine.DisplayName
	$BaseLineVersion = $BaseLine.Version

	$BaseLineDN
	$BaseLineVersion
}

$Computer = "lac2sp48"
$BaseLineDN = 'Call Center Compliance'
$BaseLineVersion = '2'

$MC = [WmiClass]"\\$Computer\root\ccm\dcm:SMS_DesiredConfiguration"
$Method = "TriggerEvaluation"
$InParams = $mc.psbase.GetMethodParameters($Method)
$InParams.IsEnforced = $true
$InParams.IsMachineTarget = $false
$InParams.Name = "$BaseLineDN"
$InParams.Version = "$BaseLineVersion"
$InParams.PSBase.properties | select Name, Value | format-Table
$R = $MC.InvokeMethod($Method, $InParams, $null)
$R | Format-Table
#########################################################################
#########################################################################

$Computer = "lac2sp48"
$BaseLineDN = 'Call Center Compliance'
$BaseLineVersion = '2'
$Baselines = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
$name = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration | Where-Object { $_.DisplayName -match "<DCM Basline Name>" } | Select-Object -ExpandProperty Name $name
$version = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration | Where-Object { $_.DisplayName -match "<DCM Baseline Name>" } | Select-Object -ExpandProperty Version $version


$MC = [WmiClass]"\\$Computer\root\ccm\dcm:SMS_DesiredConfiguration"
$Method = "TriggerEvaluation" 
$InParams = $mc.psbase.GetMethodParameters($Method)
$InParams.IsEnforced = $true
$InParams.IsMachineTarget = $false
$InParams.Name = "$name"
$InParams.Version = "$version"
$inparams.PSBase.properties | select Name, Value | format-Table
$R = $MC.InvokeMethod($Method, $InParams, $null)
$R | Format-Table
