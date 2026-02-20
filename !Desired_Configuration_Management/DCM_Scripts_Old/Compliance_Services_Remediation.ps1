# "Set Service and state" Remediation Script
Catch{$_.Exception.Message}
}
# "Set Service and state" Remediation Script

$DN1 = 'Google Update Service (gupdate)'
$Name1 = 'gupdate'

$DN2 = 'Google Update Service (gupdatem)'
$Name2 = 'gupdatem'

# Stop/disable Google services
try
{
    if (Get-Service -DisplayName $DN1 -ErrorAction SilentlyContinue)
    {
        Stop-Service -DisplayName $DN1 -Force
        Set-Service -Name $Name1 -StartupType Disabled -Status Stopped
    }
}
Catch{$_.Exception.Message}

try
{
    if (Get-Service -DisplayName $DN2 -ErrorAction SilentlyContinue)
    {
        Stop-Service -DisplayName $DN2 -Force
        Set-Service -Name $Name2 -StartupType Disabled -Status Stopped
    }
}
Catch{$_.Exception.Message}
