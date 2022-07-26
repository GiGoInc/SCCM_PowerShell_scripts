Function Invoke-BLEvaluation
{
	param (
		[String][Parameter(Mandatory = $true, Position = 1)]
		$ComputerName,
		[String][Parameter(Mandatory = $False, Position = 2)]
		$BLName
	)
	If ($BLName -eq $Null)
	{
		$Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
	}
	Else
	{
		$Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration | Where-Object { $_.DisplayName -like $BLName }
	}
	
	$Baselines | % {
		([wmiclass]"\\$ComputerName\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version)
		
	}
}

$File = "D:\Powershell\!SCCM_PS_scripts\!Desired_Configuration_Management\SCCM_Invoke_Baseline--PCList.txt"

$Computers = Get-Content $File
$i = 1
$total = $Computers.Count
ForEach ($Computer in $Computers)
{
    if (test-connection $computer -count 1 -quiet -BufferSize 16)
    {
        write-host "$i of $total`t$Computer..." -foregroundcolor green
        Invoke-BLEvaluation -ComputerName "$Computer" -BLName 'EDGE (CHROMIUM) CONFIGURATIONS'
    }
    ELSE
    {
        write-host "$i of $total`t$Computer...Couldn't ping PC" -foregroundcolor yellow
    }
    $i++
}