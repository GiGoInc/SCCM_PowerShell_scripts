$PCName = "10.200.190.77"
}
	Get-Service -Name LanmanWorkstation -ComputerName $PC
$PCName = "10.200.190.77"


ForEach ($PC in $PCName)
{
	#Set-Service -Name PeerDistSvc -ComputerName $PC -StartupType Automatic -Status Running
	#Set-Service -Name smstsmgr -ComputerName $PC -StartupType Automatic -Status Running

	Set-Service -Name CmRcService -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name RpcSs -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name RemoteRegistry -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name LanmanServer -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name CcmExec -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name Winmgmt -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name WinRM -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name wuauserv -ComputerName $PC -StartupType Automatic -Status Running
	Set-Service -Name LanmanWorkstation -ComputerName $PC -StartupType Automatic -Status Running



	Get-Service -Name PeerDistSvc -ComputerName $PC
	Get-Service -Name smstsmgr -ComputerName $PC
	Get-Service -Name CmRcService -ComputerName $PC
	Get-Service -Name RpcSs -ComputerName $PC
	Get-Service -Name RemoteRegistry -ComputerName $PC
	Get-Service -Name LanmanServer -ComputerName $PC
	Get-Service -Name CcmExec -ComputerName $PC
	Get-Service -Name Winmgmt -ComputerName $PC
	Get-Service -Name WinRM -ComputerName $PC
	Get-Service -Name wuauserv -ComputerName $PC
	Get-Service -Name LanmanWorkstation -ComputerName $PC
}
