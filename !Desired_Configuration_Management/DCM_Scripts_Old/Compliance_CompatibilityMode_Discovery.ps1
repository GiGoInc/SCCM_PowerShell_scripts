# "Compatibility Mode" Discovery Script
else {Write-Host 'Compliant'}
    }
# "Compatibility Mode" Discovery Script

if ((test-path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation") -eq $true)
   {
   try
     {
       $Check = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation' -Name IntranetCompatibilityMode
       if ($Check.IntranetCompatibilityMode –eq 0)
          {Write-Host 'Compliant'}
       else
          {Write-Host 'Non-Compliant'}
      }
    catch
      {Write-Host 'Non-Compliant'}
    }
else {Write-Host 'Compliant'}
