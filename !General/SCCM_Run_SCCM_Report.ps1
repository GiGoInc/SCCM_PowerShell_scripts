# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"

# Variables for file log creation
$SCCMFile = "$CurrentDirectory\SCCM_Report.csv"

$Start = 'http://sccmserver/ReportServer?%2FConfigMgr_SS1%2F'
$Path = 'Software%20Distribution%20-%20Application%20Monitoring%2F'
$Report1 = 'All%20application%20deployments%20(basic)&FourthParameter=0&ThirdParameter='
$CollectionName = 'SS100504'
$Report2 = '&TimeFrame=30&ChooseBy=Collection&SecondParameter=%25&SuccessPct=0&Administrator=All&rs%3AParameterLanguage=en-US'
$End = '&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False'


# Generate SCCM Report to current directory
#Invoke-WebRequest "http://sccmserver/ReportServer?%2fConfigMgr_SS1%2fCorp+Name%2fCOM+-+The+Works+(PC+to+User+to+Model+to+OS+to+Client+Status)&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $SCCMFile

Invoke-WebRequest $Start$Path$Report1$CollectionName$Report2$End -credential $creds -outfile $SCCMFile -TimeoutSec 600

#'http://sccmserver/ReportServer?%2FConfigMgr_SS1%2FSoftware%20Distribution%20-%20Application%20Monitoring%2FAll%20application%20deployments%20(basic)&FourthParameter=0&ThirdParameter=SS100504&TimeFrame=30&ChooseBy='+$CollectionName+'&SecondParameter=%25&SuccessPct=0&Administrator=All&rs%3AParameterLanguage=en-US&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False' -credential $creds -outfile $SCCMFile

#Invoke-WebRequest 'http://sccmserver/ReportServer?%2FConfigMgr_SS1%2FSoftware%20Distribution%20-%20Application%20Monitoring%2FAll%20application%20deployments%20(basic)&FourthParameter=0&ThirdParameter=SS100504&TimeFrame=30&ChooseBy=Collection&SecondParameter=%25&SuccessPct=0&Administrator=All&rs%3AParameterLanguage=en-US'

<#
Adobe Reader 11.10 - Group 01	SS100504
Adobe Reader 11.10 - Group 02	SS100505
Adobe Reader 11.10 - Group 03	SS100506
Adobe Reader 11.10 - Group 04	SS100508
Adobe Reader 11.10 - Group 05	SS100507
Adobe Reader 11.10 - Group 06	SS100509
Adobe Reader 11.10 - Group 07	SS10050B
Adobe Reader 11.10 - Group 08	SS10050C
Adobe Reader 11.10 - Group 09	SS10050D

http://sccmserver/ReportServer?%2FConfigMgr_SS1%2FSoftware%20Distribution%20-%20Application%20Monitoring%2FAll%20application%20deployments%20(basic)&FourthParameter=0&ThirdParameter=SS100504&TimeFrame=30&ChooseBy=Collection&SecondParameter=%25&SuccessPct=0&Administrator=All&rs%3AParameterLanguage=en-US

#>