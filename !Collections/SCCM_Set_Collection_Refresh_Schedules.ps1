C:\
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

##########################################################################################################################################
##########################################################################################################################################

#$CollName = 'SDG-.NET FRAMEWORK 4.8 USERS'

$Collections = Get-Content "D:\Powershell\!SCCM_PS_scripts\!Collections\SCCM_Set_Collection_Refresh_Schedules.txt"
$Schedule1 = New-CMSchedule -Start (Get-Date) -RecurInterval Hours -RecurCount 1
$i = 1
$Total = $Collections.Count
ForEach ($CollName in $Collections){"Setting $i of $Total -- $CollName";Set-CMCollection -Name $CollName -RefreshSchedule $Schedule1 -RefreshType Both;$i++}