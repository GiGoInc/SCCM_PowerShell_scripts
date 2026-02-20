$computer = 'PC1'
$Result | Select-Object -ExpandProperty SiteSystems -Unique

$computer = 'PC1'
$Result | Select-Object -ExpandProperty SiteSystems -Unique

$computer = 'PC1'


$SCCMServer = 'SERVER'
$WMIParams = @{
    ComputerName = $SCCMServer
    Namespace    = 'root\SMS\site_XX1'
}


$Client = Get-WmiObject @WMIParams -Query "SELECT * FROM SMS_R_System WHERE Name='$Computer' AND IPSubnets != ''"
Write-host "Computer $($Client.Name), IPSubnets $($Client.IPSubnets)"

$Result = Foreach ($S in ($Client.IPSubnets | where {($_ -NE '192.168.1.0') -and ($_ -NE '0.0.0.0') -and 
    ($_ -NE '128.0.0.0') -and ($_ -NE '169.254.0.0') -and ($_ -NE '64.0.0.0')})) {
    Write-HOST "Check IP '$S'"
    Get-WmiObject @WMIParams -Query "SELECT Displayname, SiteSystems, Value, DefaultSiteCode FROM SMS_Boundary WHERE Value = '$S'"
}

$Result | Select-Object -ExpandProperty SiteSystems -Unique
