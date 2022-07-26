# Use saved password are $Cred
$username = "Domain\user1"
$password = cat "D:\Powershell\securestring.txt" | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$ComputerName = "6DJS182"

$Parameters = @{
  "APPID" = '17140907' # IE11 with Pre-Reqs
}
Invoke-WebRequest 'http://sccmserverdb/ReportServer?%2fConfigMgr_SS1%2FCorp+Name%2fCOM+-+Application+Deployment+Status+by+Application+Name&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False' -Body $Parameters  -credential $cred -outfile "D:\Projects\Internet_Explorer_11\!Remediation\Application Deployment Status - IE11 with Pre-Reqs.xls" # <-- optional, Get is the default


$Parameters = @{
  "APPID" = '17142302' # IE11 Monthly Rollup
}
Invoke-WebRequest 'http://sccmserverdb/ReportServer?%2fConfigMgr_SS1%2FCorp+Name%2fCOM+-+Application+Deployment+Status+by+Application+Name&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False' -Body $Parameters  -credential $cred -outfile "D:\Projects\Internet_Explorer_11\!Remediation\Application Deployment Status - IE11 Monthly Rollup.xls"  # <-- optional, Get is the default

break
<#
#########################################################################

$destination = "D:\Powershell\!SCCM_PS_scripts\Report_Subscriptions\SCCM_The_Works.csv"
$Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
$Parameters['Application Name'] = 'Internet Explorer 11 with Pre-Reqs'
#foreach($Child in @('Abe','Karen','Joe')) {
#    $Parameters.Add('Children', $Child)
#}

$Request = [System.UriBuilder]"http://sccmserverdb/ReportServer?%2Corp+Name%2fCOM+-+Application+Deployment+Status+by+Application+Name&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False"
$Request.Query = $Parameters.ToString()
Invoke-WebRequest -Uri $Request.Uri -Method Get # <-- optional, Get is the default
#>