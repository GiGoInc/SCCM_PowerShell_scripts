# "IE EOL Notifcation" Remediation Script
}
    $_.Exception.Message
# "IE EOL Notifcation" Remediation Script

try
{
if ((test-path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION') -ne $true)
    {New-Item 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION' -Force}
        Set-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION' -Name iexplore.exe -Type DWORD -Value 1 -Force
}
Catch
{
    $_.Exception.Message
}

try
{
if ((test-path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION') -ne $true)
    {New-Item 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION' -Force}
        Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION' -Name iexplore.exe -Type DWORD -Value 1 -Force
}
Catch
{
    $_.Exception.Message
}
