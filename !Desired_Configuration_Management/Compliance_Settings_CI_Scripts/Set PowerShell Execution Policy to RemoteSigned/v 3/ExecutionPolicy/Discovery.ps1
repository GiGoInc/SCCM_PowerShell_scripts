$Path = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
If($val."ExecutionPolicy" -eq 'RemoteSigned'){'Compliant'}Else{'Not-Compliant'}
$val = Get-ItemProperty -Path $Path -Name 'ExecutionPolicy'
$Path = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
$val = Get-ItemProperty -Path $Path -Name 'ExecutionPolicy'
If($val."ExecutionPolicy" -eq 'RemoteSigned'){'Compliant'}Else{'Not-Compliant'}
