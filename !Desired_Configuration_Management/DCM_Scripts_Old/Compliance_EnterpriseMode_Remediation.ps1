# "Enterprise Mode" Remediation Script
}
    $_.Exception.Message
# "Enterprise Mode" Remediation Script

try
{
    if ((test-path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode') -ne $true)
    {
        New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Force
    }
    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name SiteList -Type String -Value "http://XXXXdsweb1/sites.xml" -Force
}
Catch
{
    $_.Exception.Message
}
