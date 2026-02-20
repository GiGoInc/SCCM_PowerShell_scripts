#Function to use in a script in interactive mode
}
	Invoke-Command -ComputerName $Computer -ScriptBlock{{(New-Object -ComObject CPApplet.cpAppletMgr).GetClientActions() | ForEach-Object {$_.PerformAction()}}}
#Function to use in a script in interactive mode
Function UpdateClient {(New-Object -ComObject CPApplet.cpAppletMgr).GetClientActions() | Where-Object {$_.Name -like "Application Global Evaluation Task*" -or $_.Name -like "Request & Evaluate*"} | ForEach-Object {
Write-Output "Starting ConfigMgr action: $($_.Name)"
$_.PerformAction()}}

#Silent OneLiner with WinRM and CSV file
foreach ($Computer in Get-Content C:\temp\ClientFix.csv)
{
	Write-Output $computer
	Invoke-Command -ComputerName $Computer -ScriptBlock{{(New-Object -ComObject CPApplet.cpAppletMgr).GetClientActions() | ForEach-Object {$_.PerformAction()}}}
}
