$Log = 'D:\Projects\SCCM_Monthly_Application_Update_from_SoftwareUpdates\Uninstall_strings.csv'
'Name,Uninstall String' | Set-Content $Log 

$A = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString


ForEach ($Item in $A)
{
    $Name = $Item.DisplayName
    $UString = $Item.UninstallString

    If ($Name -ne $Null){'"'+$Name+'","'+$UString+'"' | Add-Content $Log}
}