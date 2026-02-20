$ADSIComputer = [ADSI]("WinNT://$env:COMPUTERNAME,computer") 
If ($Members -contains 'WKSAdmin'){$true}Else{$false}
$Members = $group.psbase.invoke("members")  | ForEach{$_.GetType().InvokeMember("Name",  'GetProperty',  $null,  $_, $null)} 
$ADSIComputer = [ADSI]("WinNT://$env:COMPUTERNAME,computer") 
$group = $ADSIComputer.psbase.children.find('Administrators','Group')
$Members = $group.psbase.invoke("members")  | ForEach{$_.GetType().InvokeMember("Name",  'GetProperty',  $null,  $_, $null)} 
If ($Members -contains 'WKSAdmin'){$true}Else{$false}
