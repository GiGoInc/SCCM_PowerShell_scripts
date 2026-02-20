$PP = cmd /c $env:SystemRoot\System32\powercfg.exe $args '/GETACTIVESCHEME'
If ($PP -eq 'Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)'){'Compliant'}Else{'Non-Compliant'}
$PP = cmd /c $env:SystemRoot\System32\powercfg.exe $args '/GETACTIVESCHEME'
$PP = cmd /c $env:SystemRoot\System32\powercfg.exe $args '/GETACTIVESCHEME'
If ($PP -eq 'Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)'){'Compliant'}Else{'Non-Compliant'}
