# "Enterprise Mode" Discovery Script

if ((test-path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode") -eq $true)
   {
   try
     {
       $Check = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name SiteList
       if ($Check.SiteList –eq "http://webserver/sites.xml")
          {Write-Host 'Compliant'}
       else
          {Write-Host 'Non-Compliant'}
      }
    catch
      {Write-Host 'Non-Compliant'}
    } 
else {Write-Host 'Non-Compliant'}