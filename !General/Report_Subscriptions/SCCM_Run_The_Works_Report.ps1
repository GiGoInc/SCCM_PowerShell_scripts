# Use saved password are $Cred
#>

# Use saved password are $Cred
#>

# Use saved password are $Cred
$username = "DOMAIN\SUPERUSER"
<# ######################################################

Syntax for specific Reports
http://SERVER/ReportServer?%2   ****REPLACE WITH REPORT NAME***   &rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $destination

###################################################### #>

$password = cat "D:\Powershell\securestring.txt" | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password



$ComputerName = "PC1"
$destination = "D:\Powershell\!SCCM_PS_scripts\Report_Subscriptions\SCCM_The_Works.csv"

invoke-webrequest "http://SERVER/ReportServer?%2fConfigMgr_XX1%2FDOMAIN%20Part2%2FCOM%20-%20Software%20Updates%20Compliance%20-%20Management%20Report&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $destination 

break
##############################################################################################################################################################
# Use saved password are $Cred
$username = "DOMAIN\SUPERUSER"
$password = cat "D:\Powershell\securestring.txt" | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password



$ComputerName = "PC1"
$destination = "D:\Powershell\!SCCM_PS_scripts\Report_Subscriptions\SCCM_The_Works.csv"

invoke-webrequest "http://SERVER/ReportServer?%2fConfigMgr_XX1%2FDOMAIN%20Part2%2FCOM%20-%20Software%20Updates%20Compliance%20-%20Management%20Report&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $destination 

break
##############################################################################################################################################################
http://SERVER/ReportServer?%2ConfigMgr_NR1%2fAsset+Intelligence%2fHardware+05A+-+Console+users+on+a+specific+computer&Name=$ComputerName&rs:Comm and=Render&rc:toolbar=false&rs:Format=CSV" 


<Report xsi:schemaLocation="COM_x0020_-_x0020_Software_x0020_Updates_x0020_Compliance_x0020_-_x0020_Management_x0020_Report 

http://SERVER/ReportServer?%2F

ConfigMgr_XX1%2FDOMAIN%20Part2%2FCOM%20-%20Software%20Updates%20Compliance%20-%20Management%20Report


&amp;rs%3ACommand=Render&amp;rs%3AFormat=XML&amp;rs%3ASessionID=xv2f2dildph1ib55ofnrr145&amp;rc%3ASchema=True" 





$ComputerName = "BGF4B42"
$destination = "D:\!Powershell\!SCCM_PS_scripts\Report_Subscriptions\SCCM_The_Works.csv"

invoke-webrequest "http://SERVER/ReportServer?%2fConfigMgr_XX1%2fDOMAIN+Part2%2fCOM+-+The+Works+(PC+to+User+to+Model+to+OS+to+Client+Status)&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $destination 


<# ORIGINAL CODE INFORMATION
http://tomorrow.uspeoples.org/2014/02/powershell-downloading-csvs-from-sccm.html

Here's an example:

invoke-webrequest "http://sccmserver/ReportServer?%2fConfigMgr_NR1%2fAsset+Intelligence%2fSoftware+02E+-+Installed+software+on+a+specific+computer&Name=$ComputerName&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $destination 

This will download a report about all of the software loaded on one computer and place it into a CSV file.  All you'd have to do is $software = import-csv $destination 

Another example reports about all the software that starts when the computer is powered on:
iwr "http://sccmserver/ReportServer?%2fConfigMgr_NR1%2fAsset+Intelligence%2fSoftware+04C+-+Software+configured+to+automatically+run+on+a+specific+computer&Name=$ComputerName&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $autodestination

A third example reports about what computers and IPs are currently on a subnet:

iwr -credential $creds "http://sccmserver/ReportServer?%2fConfigMgr_NR1%2fNetwork%2fIP+-+Computers+in+a+specific+subnet&variable=192.168.0.0&rs:Command=Render&rc:toolbar=false&rs:Format=CSV" -outfile $oursubnet

Here I get the network card information for a computer:
iwr -credential $creds "http://sccmserver/ReportServer?%2fConfigMgr_NR1%2fHardware+-+Network+Adapter%2fNetwork+adapter+information+for+a+specific+computer&variable=$ComputerName&rs:Command=Render&rc:toolbar=false&rs:Format=CSV&quo t; -outfile $NICDestination

A report about the users of a certain computer:
iwr -credential $creds "http://sccmserver/ReportServer?%2fConfigMgr_NR1%2fAsset+Intelligence%2fHardware+05A+-+Console+users+on+a+specific+computer&Name=$ComputerName&rs:Comm and=Render&rc:toolbar=false&rs:Format=CSV" -outfile $cache

A computer hardware report about a certain computer:
iwr -credential $creds "http://sccmserver/ReportServer?%2fConfigMgr_NR1%2fHardware +-+General%2fComputer+information+for+a+specific+computer&variable=$ComputerName&rs:Command=Render&rc:toolbar=false&rs:Format=CSV" -outfile $HWDestination

Disk information report about a certain computer:

iwr -credential $creds "http://sccmserver/ReportServer?%2fConfigMgr_NR1%2fHardware +-+Disk%2fDisk+information+for+a+specific+computer+-+Physical+disks&variable=$ComputerName&rs:Command=Render&rc:toolbar=false&rs:Format=CSV" -outfile $diskdestination

#"http://SERVER/ReportServer?%2fConfigMgr_XX1%2fAsset+Intelligence%2fSoftware+02E+-+Installed+software+on+a+specific+computer&Name=$ComputerName&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $destination 
#"http://SERVER/ReportServer?%2fConfigMgr_XX1%2fDOMAIN+Part2%2fCOM+-+The+Works+(PC+to+User+to+Model+to+OS+to+Client+Status)&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $destination 


#>
