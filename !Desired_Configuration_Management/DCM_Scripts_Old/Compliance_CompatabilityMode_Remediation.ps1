# "Compatibility Mode" Remediation Script
}
    $_.Exception.Message
# "Compatibility Mode" Remediation Script

try
{
    if ((test-path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation') -ne $true)
    {
        New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation' -Force
    }
    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation' -Name IntranetCompatibilityMode -Type DWORD -Value 0 -Force
}
Catch
{
    $_.Exception.Message
}
