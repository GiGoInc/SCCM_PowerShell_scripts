# Use saved password are $Cred
$username = "Domain\user1"
$password = cat "D:\Powershell\securestring.txt" | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password



$ComputerName = "6DJS182"
$destination = "D:\Powershell\!SCCM_PS_scripts\Report_Subscriptions\SCCM_The_Works.csv"

invoke-webrequest "http://sccmserverdb/ReportServer?%2fConfigMgr_SS1%2FCorp%20Name%2FCOM%20-%20Software%20Updates%20Compliance%20-%20Management%20Report&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $destination 
# http://sccmserverdb/ReportServer?%2   ****REPLACE WITH REPORT NAME***   &rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $destination


<Report xsi:schemaLocation="DOMAIN_x0020_-_x0020_Software_x0020_Updates_x0020_Compliance_x0020_-_x0020_Management_x0020_Report 

http://sccmserverdb/ReportServer?%2F

ConfigMgr_SS1%2FCorp%20Name%2FCOM%20-%20Software%20Updates%20Compliance%20-%20Management%20Report


&amp;rs%3ACommand=Render&amp;rs%3AFormat=XML&amp;rs%3ASessionID=xv2f2dildph1ib55ofnrr145&amp;rc%3ASchema=True" 

