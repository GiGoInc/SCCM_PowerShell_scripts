# "Java AutoUpdate" Discovery Script

$OSArchitecture = Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture
$ErrorActionPreference = "Stop"

# Check 32-bit registry in 64-bit OS
If($OSArchitecture.OSArchitecture -ne "32-bit")
    {
      if ((test-path "HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy") -eq $true)
         {
         try
           {
             $UpdateCheck = Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy' -Name EnableAutoUpdateCheck, EnableJavaUpdate, NotifyDownload, NotifyInstall
             if (($UpdateCheck.EnableAutoUpdateCheck –eq 0) –and ($UpdateCheck.EnableJavaUpdate -eq 0) –and ($UpdateCheck.NotifyDownload -eq 0) -and ($UpdateCheck.NotifyInstall -eq 0))
                {Write-Host 'Compliant'}
             else
                {Write-Host 'Non-Compliant'}
            }
          catch
            {Write-Host 'Non-Compliant'}
          } 
      else {Write-Host 'Non-Compliant'}
    }
# Check registry in 32-bit OS
else
    { 
       if ((test-path "HKLM:\SOFTWARE\Javasoft\Java Update\Policy") -eq $true)
         {
         try
           {
             $UpdateCheck = Get-ItemProperty 'HKLM:\SOFTWARE\JavaSoft\Java Update\Policy' -Name EnableAutoUpdateCheck, EnableJavaUpdate, NotifyDownload, NotifyInstall
             if (($UpdateCheck.EnableAutoUpdateCheck –eq 0) –and ($UpdateCheck.EnableJavaUpdate -eq 0) –and ($UpdateCheck.NotifyDownload -eq 0) -and ($UpdateCheck.NotifyInstall -eq 0))
                {Write-Host 'Compliant'}
             else
                {Write-Host 'Non-Compliant'}
            }
         catch
           {Write-Host 'Non-Compliant'} 
          }
       else {Write-Host 'Non-Compliant'}
     }