$de = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators,group" 
$de.psbase.Invoke("Add",([ADSI]"WinNT://DOMAIN/WKSAdmin").path)
$de = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators,group" 
$de = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators,group" 
$de.psbase.Invoke("Add",([ADSI]"WinNT://DOMAIN/WKSAdmin").path)
