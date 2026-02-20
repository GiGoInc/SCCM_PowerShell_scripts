# Use saved password are $Cred

&amp;rs%3ACommand=Render&amp;rs%3AFormat=XML&amp;rs%3ASessionID=xv2f2dildph1ib55ofnrr145&amp;rc%3ASchema=True" 
# Use saved password are $Cred

&amp;rs%3ACommand=Render&amp;rs%3AFormat=XML&amp;rs%3ASessionID=xv2f2dildph1ib55ofnrr145&amp;rc%3ASchema=True" 
# Use saved password are $Cred
$username = "DOMAIN\SUPERUSER"
$password = cat "D:\Powershell\securestring.txt" | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password



$ComputerName = "PC1"
$destination = "D:\Powershell\!SCCM_PS_scripts\Report_Subscriptions\SCCM_The_Works.csv"

invoke-webrequest "http://SERVER/ReportServer?%2fConfigMgr_XX1%2FDOMAIN%20Part2%2FCOM%20-%20Software%20Updates%20Compliance%20-%20Management%20Report&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $destination 
# http://SERVER/ReportServer?%2   ****REPLACE WITH REPORT NAME***   &rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $destination


<Report xsi:schemaLocation="COM_x0020_-_x0020_Software_x0020_Updates_x0020_Compliance_x0020_-_x0020_Management_x0020_Report 

http://SERVER/ReportServer?%2F

ConfigMgr_XX1%2FDOMAIN%20Part2%2FCOM%20-%20Software%20Updates%20Compliance%20-%20Management%20Report


&amp;rs%3ACommand=Render&amp;rs%3AFormat=XML&amp;rs%3ASessionID=xv2f2dildph1ib55ofnrr145&amp;rc%3ASchema=True" 

