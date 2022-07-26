# "Java AutoUpdate" Remediation Script

$OSArchitecture = Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture

# Set 32-bit registry in 64-bit OS 
If($OSArchitecture.OSArchitecture -ne "32-bit")
    {
    try
    {
    if ((test-path 'HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy') -ne $true)
      {New-Item 'HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy' -Force}
    Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy' -Name EnableAutoUpdateCheck -Type DWORD -Value 0 -Force
    Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy' -Name EnableJavaUpdate -Type DWORD -Value 0 -Force
    Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy' -Name NotifyDownload -Type DWORD -Value 0 -Force
    Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Javasoft\Java Update\Policy' -Name NotifyInstall -Type DWORD -Value 0 -Force
    }
    Catch
    {
    $_.Exception.Message
    }
    }
# Set 32-bit registry
else
    {
    try
    {
    if ((test-path 'HKLM:\SOFTWARE\Javasoft\Java Update\Policy') -ne $true)
      {New-Item 'HKLM:\SOFTWARE\Javasoft\Java Update\Policy' -Force}
    Set-ItemProperty 'HKLM:\SOFTWARE\JavaSoft\Java Update\Policy' -Name EnableAutoUpdateCheck -Type DWORD -Value 0 -Force
    Set-ItemProperty 'HKLM:\SOFTWARE\JavaSoft\Java Update\Policy' -Name EnableJavaUpdate -Type DWORD -Value 0 -Force
    Set-ItemProperty 'HKLM:\SOFTWARE\JavaSoft\Java Update\Policy' -Name NotifyDownload -Type DWORD  -Value 0 -Force
    Set-ItemProperty 'HKLM:\SOFTWARE\JavaSoft\Java Update\Policy' -Name NotifyInstall -Type DWORD -Value 0 -Force
    }
    catch
    {
    $_.Exception.Message
    }
    }