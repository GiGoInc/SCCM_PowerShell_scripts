$TSName = "Windows 10 - 1709"
$TSN = $TSName.Replace(' ','_')
$DestFile = 'D:\Powershell\!SCCM_PS_scripts\!General\'+$TSN+'_TaskSequence.xml'


<#
"X Dell OSD - SAM TEST v6.1"
"X Dell OSD - SAM PROD v5.7"
"X Dell OSD - SAM PROD v5.6"
"X Dell OSD - SAM PROD v5.9"
"X Dell OSD - SAM PROD v5.9a"
"X Dell OSD - SAM TEST v5.9c"
"X Dell OSD - SAM PROD v6.0"
#>

C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
 
$TS = Get-CMTaskSequence -Name $TSName | select -ExpandProperty Sequence
'<?xml-stylesheet type="text/xsl" href="tsDocumentorv2.xsl"?>' | Add-Content $DestFile
$TS | Add-Content $DestFile


D:
