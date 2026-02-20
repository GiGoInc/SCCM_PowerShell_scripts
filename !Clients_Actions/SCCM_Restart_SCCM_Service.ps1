$computer = 'LACOET04'
Exit-PSSession
Restart-Service CcmExec
$computer = 'LACOET04'





Enter-PSSession -ComputerName $computer
Restart-Service CcmExec
Exit-PSSession
