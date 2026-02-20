# "Enterprise Mode" Remediation Script
}
    $_.Exception.Message
# "Enterprise Mode" Remediation Script
        <#
        1) HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode\SiteList
      1.5) HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode\Enable
        4) HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\EnterpriseMode\SiteList
        2) HKCU\Software\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode\SiteList
        3) HKCU\Software\Microsoft\Internet Explorer\Main\EnterpriseMode\SiteList

# "Compatibility Mode" Remediation Script
#>


 $EMLocation = 'file://C:/Misc/sites.xml'
# $EMLocation = 'http://em.DOMAIN.COM/sites.xml'
# $EMLocation = 'http://XXXXdsweb1/sites.xml'



try
{
 # 1) HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode
    if ((test-path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode') -ne $true)
    {
            New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Force
    }
    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name SiteList -Type String -Value $EMLocation -Force

 # 1.5) HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\EnterpriseMode
    if ((test-path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode') -ne $true)
    {
            New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Force
    }
    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name Enable -Type String -Value $EMLocation -Force
    
 # 2) HKCU\Software\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode
    if ((test-path 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode') -ne $true)
    {
            New-Item 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Force
    }
    Set-ItemProperty 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name SiteList -Type String -Value $EMLocation -Force

 # 3) HKCU\Software\Microsoft\Internet Explorer\Main\EnterpriseMode
    if ((test-path 'HKLM:\Software\Microsoft\Internet Explorer\Main\EnterpriseMode') -ne $true)
    {
            New-Item 'HKLM:\Software\Microsoft\Internet Explorer\Main\EnterpriseMode' -Force
    }
    Set-ItemProperty 'HKLM:\Software\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name SiteList -Type String -Value $EMLocation -Force

 # 4) HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\EnterpriseMode
    if ((test-path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\EnterpriseMode') -ne $true)
    {
            New-Item 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\EnterpriseMode' -Force
    }
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name SiteList -Type String -Value $EMLocation -Force
}
Catch
{
    $_.Exception.Message
}
