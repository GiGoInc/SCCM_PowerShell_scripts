$computer = 'LACOET04'





Enter-PSSession -ComputerName $computer
Restart-Service CcmExec
Exit-PSSession