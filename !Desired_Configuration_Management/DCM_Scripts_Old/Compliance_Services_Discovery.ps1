# "Check Service and state" Discovery Script
Catch{$_.Exception.Message}
}
# "Check Service and state" Discovery Script

$DN1 = 'CUDeviceManager'
$Name1 = 'CUDeviceManager'

Try
{
    $x = 0 # services are Stopped
    $y = 0 # services are not Stopped
    if (Get-Service -DisplayName $DN1 -ErrorAction SilentlyContinue)
    {
        $Sr1 = (Get-Service -DisplayName $DN1)
        If ($Sr1.Status -eq 'Stopped'){$x++}
        If ($Sr1.Status -ne 'Stopped'){$y++}
    }
    If ($y -eq 0){write-host "Compliant"}
    Else{write-host "Not Compliant"}
}
Catch{$_.Exception.Message}
