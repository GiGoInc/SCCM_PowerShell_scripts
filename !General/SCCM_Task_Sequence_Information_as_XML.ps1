$TSName = "Windows 10 - MDT TS"
D:

$TSName = "Windows 10 - MDT TS"
$TS = $TSName.Replace(' ','_')
$DestFile = '.\'+$TSName+'_TaskSequence.xml'


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
Set-Location XX1:
 
$TS = Get-CMTaskSequence -Name $TSName | select -ExpandProperty Sequence
Write-Output '<?xml-stylesheet type="text/xsl" href="tsDocumentorv2.xsl"?>' | Out-File $DestFile
Write-Output $TS | Out-File $DestFile -Append


D:
