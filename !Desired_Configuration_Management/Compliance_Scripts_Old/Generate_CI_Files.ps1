
# netsh interface set interface name = '+"""$NICname"""+' newname = "DataNetwork"
# NETSH to SET new name on NIC


#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path





$file = Get-Content ("$CurrentDirectory\NIC_Check_Results.csv")
ForEach ($line in $file)
{
            $string = $line.split(',')
         $Servername = $string[0]
             $Online = $string[1]
           $IndexNum = $string[2]
    $OperatingSystem = $string[3]
            $NICName = $string[4]
        $Description = $string[5]
          $IPAddress = $string[6]
          $IPPartial = $string[7]
            $Gateway = $string[8]

 # SiteCode
    $SiteCode = $Servername.substring(0,4)

 # Server Type
    $SType = $Servername.substring($Servername.length - 4, 4)

 # Gateway Partial
    $SType = $Servername.substring($Servername.length - 4, 4)


# Create SiteCode Folders
If (!(Test-Path "$CurrentDirectory\$SiteCode")){New-Item -Path "$CurrentDirectory\$SiteCode" -ItemType Directory}

# Copy IPUPDATE.CMD to $SITECODE folder
If (!(Test-Path "$CurrentDirectory\$SiteCode\ipupdate.cmd")){Copy-Item -Path "$CurrentDirectory\ipupdate.cmd" -Destination "$CurrentDirectory\$SiteCode"}


# Write-Output "Servername = $ServerName"

# Create SiteCode.txt file
If (!(Test-Path "$CurrentDirectory\$SiteCode\sitecode.txt")){New-Item -Path "$CurrentDirectory\$SiteCode\sitecode.txt" -ItemType File}
    $Sitecode | Set-Content "$CurrentDirectory\$SiteCode\sitecode.txt"



If ($Servername -eq "$SiteCode"+"BR01")
{
    # Write-Output "BR01 Servername = $ServerName"
 $BR01_File = "$CurrentDirectory\$SiteCode\"+"BR01.txt"
    # GENERATE BR01 FILES
    'pushd interface ip ' | Set-Content $BR01_File
    'set address name = '+"""$NICname"""+' source = static addr = '+$IPAddress+' mask = 255.255.255.128 ' | Add-Content $BR01_File
    'set address name = '+"""$NICname"""+' gateway = '+$Gateway+' gwmetric = 1 ' | Add-Content $BR01_File
    'set dns name = '+"""$NICname"""+' source = static addr = 10.190.1.114 ' | Add-Content $BR01_File
    'add dns name = '+"""$NICname"""+' addr = 10.4.110.114 ' | Add-Content $BR01_File
    'set wins name = '+"""$NICname"""+' source = static addr = 10.190.1.114 ' | Add-Content $BR01_File
    'add wins name = '+"""$NICname"""+' addr = 10.4.110.114 ' | Add-Content $BR01_File
    'popd ' | Add-Content $BR01_File
}

If ($Servername -eq "$SiteCode"+"BR02")
{
    # Write-Output "BR02 Servername = $ServerName"
 $BR02_File = "$CurrentDirectory\$SiteCode\"+"BR02.txt"
    If ($OperatingSystem -eq "Microsoft(R) Windows(R) Server 2003 Standard Edition")
    {
    # GENERATE BR02 FILES FOR 2003
        'pushd interface ip ' | Set-Content $BR02_File
        'set address name = '+"""$NICname"""+' source = static addr = '+$IPAddress+' mask = 255.255.255.128 ' | Add-Content $BR02_File
        'set address name = '+"""$NICname"""+' gateway = '+$Gateway+' gwmetric = 1 ' | Add-Content $BR02_File
        'set dns name = '+"""$NICname"""+' source = static addr = 10.190.1.114 ' | Add-Content $BR02_File
        'add dns name = '+"""$NICname"""+' addr = 10.4.110.114 ' | Add-Content $BR02_File
        'set wins name = '+"""$NICname"""+' source = static addr = 10.190.1.114 ' | Add-Content $BR02_File
        'add wins name = '+"""$NICname"""+' addr = 10.4.110.114 ' | Add-Content $BR02_File
        'popd' | Add-Content $BR02_File
    }
    ELSE
    {
        # GENERATE BR02 FILES FOR 2008
        'pushd interface ipv4 ' | Set-Content $BR02_File
        'set address name='+"""$NICname"""+' address='+$IPAddress+' mask=255.255.255.128 gateway='+$Gateway+' gwmetric=1 ' | Add-Content $BR02_File 
        'set dns name='+"""$NICname"""+' source=static addr=10.190.1.114 ' | Add-Content $BR02_File 
        'add dns name='+"""$NICname"""+' address=10.4.110.114 ' | Add-Content $BR02_File 
        'set wins name='+"""$NICname"""+' source=static address=10.190.1.114 ' | Add-Content $BR02_File 
        'add wins name='+"""$NICname"""+' address=10.4.110.114 ' | Add-Content $BR02_File 
        'popd ' | Add-Content $BR02_File
    }
}

If ($Servername -eq "$SiteCode"+"SM01")
{
    # Write-Output "SM01 Servername = $ServerName"
 $SM01_File = "$CurrentDirectory\$SiteCode\"+"SM01.txt"
    # GENERATE SM01 FILES
    'pushd interface ipv4 ' | Set-Content $SM01_File  
    'set address name='+"""$NICname"""+' address='+$IPAddress+' mask=255.255.255.128 gateway='+$Gateway+' gwmetric=1 ' | Add-Content $SM01_File  
    'set dns name='+"""$NICname"""+' source=static addr=10.190.1.114 ' | Add-Content $SM01_File  
    'add dns name='+"""$NICname"""+' address=10.4.110.114 ' | Add-Content $SM01_File  
    'set wins name='+"""$NICname"""+' source=static address=10.190.1.114 ' | Add-Content $SM01_File  
    'add wins name='+"""$NICname"""+' address=10.4.110.114 ' | Add-Content $SM01_File 
    'popd ' | Add-Content $SM01_File
}

 $IMM_File = "$CurrentDirectory\$SiteCode\"+"IMM.txt"
 # GENERATE IMM FILES
 ' ' | Set-Content $IMM_File 
 'telnet '+$IPPartial+'.10 ' | Add-Content $IMM_File 
 'ifconfig eth0 -c static -i '+$IPPartial+'.249 -g '+$IPPartial+'.241 -s 255.255.255.240 -n '+$SiteCode+'imm1 -ipv6 disabled ' | Add-Content $IMM_File 
 'resetsp ' | Add-Content $IMM_File  
 '  ' | Add-Content $IMM_File  
 '**if older IMM, you may need to delete the "-ipv6 disabled" from the command line. ' | Add-Content $IMM_File  
 '  ' | Add-Content $IMM_File 
 'Login ' | Add-Content $IMM_File 
 'userid: USERID	** case sensitive ** ' | Add-Content $IMM_File  
 'pw: thAm3WrA	** or the default PASSW0RD ** ' | Add-Content $IMM_File  
 
 
 $VMA_File = "$CurrentDirectory\$SiteCode\"+"VMA.txt" 
 # GENERATE VMA FILES
 ' ' | Set-Content $VMA_File
 'putty '+$IPPartial+'.11 ' | Add-Content $VMA_File 
 'userid: vi-admin ' | Add-Content $VMA_File 
 'pw: apcmeup1 ' | Add-Content $VMA_File 
 'cd /opt/vmware/vma/bin/ ' | Add-Content $VMA_File 
 'sudo ./vmware-vma-netconf.pl	-prompts for password again ' | Add-Content $VMA_File 
 'pw: apcmeup1 ' | Add-Content $VMA_File 
 ' ' | Add-Content $VMA_File
 'set mask to 255.255.255.128 ' | Add-Content $VMA_File 
 'set gateway to .1 ' | Add-Content $VMA_File 
 'IP should be .11 ' | Add-Content $VMA_File 
 ' ' | Add-Content $VMA_File 
 ' ' | Add-Content $VMA_File 
 '**you must type "yes" or "no" on each question ' | Add-Content $VMA_File 
 ' ' | Add-Content $VMA_File 
 '**On some VMA appliances, the path might be different: ' | Add-Content $VMA_File 
 'cd /opt/vmware/vima/bin ' | Add-Content $VMA_File 
 'sudo ./vmware-vima-netconf.pl ' | Add-Content $VMA_File


             $string = $Null
         $Servername = $Null
             $Online = $Null
           $IndexNum = $Null
    $OperatingSystem = $Null
            $NICName = $Null
        $Description = $Null
          $IPAddress = $Null
          $IPPartial = $Null
            $Gateway = $Null

}




<#
number of paths
paths (seperated by special charecter, maybe a ';'


# Compliance Check if file exists - Discovery
        $PS1File = 'C:\!Powershell\Compliance_Scripts\Compliance_File_Check_IF_Exists_Discovery--AutoGenerated.ps1'
        '$Path1 = "$env:windir\Sun\Java\Deployment"' | Add-Content $PS1File
        '$Path2 = "$env:windir\Sun\Java\Deployment\deployment.properties"' | Add-Content $PS1File
        '$Path3 = "$env:windir\Sun\Java\Deployment\deployment.config"' | Add-Content $PS1File
        '$Path4 = "$env:windir\Sun\Java\Deployment\exception.sites"' | Add-Content $PS1File
        'if ((Test-Path $Path1) -eq $true -and (Test-Path $Path2) -eq $true -and (Test-Path $Path3) -eq $true -and (Test-Path $Path4) -eq $true)' | Add-Content $PS1File
        '{' | Add-Content $PS1File
        'write-host "Compliant"' | Add-Content $PS1File
        '}' | Add-Content $PS1File
        'else' | Add-Content $PS1File
        '{write-host "Not-Compliant"}' | Add-Content $PS1File


# Compliance Check if file exists - Remediation
        $PS1File = 'C:\!Powershell\Compliance_Scripts\Compliance_File_Check_IF_Exists_Remediation--AutoGenerated.ps1'
        '# "Deployment Files" Remediation Script' | Add-Content $PS1File
        '$ErrorActionPreference = "Stop"' | Add-Content $PS1File
        '$Path1 = "$env:windir\Sun\Java\Deployment"' | Add-Content $PS1File
        '$File1 = "deployment.properties"' | Add-Content $PS1File
        '$File2 = "deployment.config"' | Add-Content $PS1File
        '$File3 = "exception.sites"' | Add-Content $PS1File
        '$Text1 = "deployment.javaws.autodownload=NEVER' | Add-Content $PS1File
        'deployment.javaws.autodownload.locked' | Add-Content $PS1File
        'deployment.expiration.check.enabled=FALSE' | Add-Content $PS1File
        'deployment.security.mixcode=HIDE_RUN' | Add-Content $PS1File
        'deployment.user.security.exception.sites=C\:/Windows/Sun/Java/Deployment/exception.sites"' | Add-Content $PS1File
        '$Text2 = "deployment.system.config=file:///C:/Windows/Sun/Java/Deployment/deployment.properties' | Add-Content $PS1File
        'deployment.system.config.mandatory=true"' | Add-Content $PS1File
        '$Text3 = "file:///' | Add-Content $PS1File
        'http://10.13.1.10' | Add-Content $PS1File
        'http://10.13.1.13' | Add-Content $PS1File
        'http://10.200.191.239/metasys/' | Add-Content $PS1File
        'http://10.200.26.10' | Add-Content $PS1File
        'http://10.200.43.10' | Add-Content $PS1File
        'http://10.200.45.10' | Add-Content $PS1File
        'http://10.220.30.10' | Add-Content $PS1File
        'http://10.254.230' | Add-Content $PS1File
        'http://10.3.35.19' | Add-Content $PS1File
        'http://10.3.57.163:8080' | Add-Content $PS1File
        'http://10.3.57.176:8080' | Add-Content $PS1File
        'http://10.3.57.53' | Add-Content $PS1File
        'http://10.3.57.60' | Add-Content $PS1File
        'http://10.3.57.60:9090/' | Add-Content $PS1File
        'http://10.3.58.61' | Add-Content $PS1File
        'http://10.3.58.61:9111' | Add-Content $PS1File
        'http://10.3.58.61:9111/reporter/' | Add-Content $PS1File
        'http://10.3.58.61:9111/reporter/client.jsp' | Add-Content $PS1File
        'http://10.3.59.163:8080' | Add-Content $PS1File
        'http://10.4.139.20' | Add-Content $PS1File
        'http://10.4.139.20/' | Add-Content $PS1File
        'http://10.50.10.10:3940/' | Add-Content $PS1File
        'http://10.50.30.107' | Add-Content $PS1File
        'http://10.90.0.90' | Add-Content $PS1File
        'http://192.17.102.220' | Add-Content $PS1File
        'http://192.17.116.0' | Add-Content $PS1File
        'http://192.17.116.236' | Add-Content $PS1File
        'http://192.22.106.225/db/Part2Part2/Graphics/Main_Page' | Add-Content $PS1File
        'http://192.22.106.225/stations/Part2Part2/html/SiteTreeIE.html' | Add-Content $PS1File
        'http://192.24.112.244' | Add-Content $PS1File
        'http://192.31.128.249' | Add-Content $PS1File
        'http://192.31.150.10/' | Add-Content $PS1File
        'http://RemoteLocalestaffing' | Add-Content $PS1File
        'http://RemoteLocalestaffing.com' | Add-Content $PS1File
        'http://RemoteLocalestaffing/' | Add-Content $PS1File
        'http://RemoteLocalestaffing/portal.aspx' | Add-Content $PS1File
        'http://RemoteLocalestaffing/security/secured/security.aspx?showcancel=False&today=True&title=Log%20In&secure=True&usersessiononly=True&redirect=/portal.aspx' | Add-Content $PS1File
        'http://RemoteLocalestaffingtest' | Add-Content $PS1File
        'http://citizenstraining.com' | Add-Content $PS1File
        'http://dataport.emma.msrb.org/AboutDataport.aspx?ReturnUrl=%2fSubmission%2fContinuingDisclosureDocumentManagement.aspx' | Add-Content $PS1File
        'http://eb90.elearn.ihost.com' | Add-Content $PS1File
        'http://hbonline' | Add-Content $PS1File
        'http://hbonline/creditcard/home/print.aspx?CreditCard=4802390000523826&StartDate=8%2f6%2f2014&EndDate=2%2f2%2f2015' | Add-Content $PS1File
        'http://home.quodd.com' | Add-Content $PS1File
        'http://jasperreports.sourceforge.net' | Add-Content $PS1File
        'http://XXXXazrcm:8080/RCM/CaseDetails.go' | Add-Content $PS1File
        'http://XXXXctrld1' | Add-Content $PS1File
        'http://XXXXhydevweb1:10080' | Add-Content $PS1File
        'http://XXXXhytstweb1:10080' | Add-Content $PS1File
        'http://XXXXhyweb1:10080' | Add-Content $PS1File
        'http://XXXXhyweb1:10080/easconsole/console.html' | Add-Content $PS1File
        'http://XXXXofdevobi1:9704/' | Add-Content $PS1File
        'http://XXXXprm2:8080' | Add-Content $PS1File
        'http://XXXXprm2:8080/PRMClient/PrmClient.jnlp' | Add-Content $PS1File
        'http://XXXXsfg01:8080' | Add-Content $PS1File
        'http://XXXXsfgcc01:5080' | Add-Content $PS1File
        'http://XXXXsfgcc01:5080/' | Add-Content $PS1File
        'http://XXXXsfgcc01:5080/webstart/CC GUI large.jnlp' | Add-Content $PS1File
        'http://XXXXsfgtst01:8080' | Add-Content $PS1File
        'http://XXXXsfgtstcc01:5080' | Add-Content $PS1File
        'http://XXXXsfgtstcc01:5080/' | Add-Content $PS1File
        'http://SERVER.DOMAIN.COM' | Add-Content $PS1File
        'http://msocca01:10129' | Add-Content $PS1File
        'http://msocca01:8080' | Add-Content $PS1File
        'http://msocca01:8080/wcc/loginui.faces?requestID=46D8BA980786551E8CBCAAD8138A58D52F97E03759278B32C9E97DC85097F458' | Add-Content $PS1File
        'http://SERVER' | Add-Content $PS1File
        'http://msohfd01' | Add-Content $PS1File
        'http://msohfd01/aathinclient/bouncy.jnlp' | Add-Content $PS1File
        'http://msohfd01/aathingclient/accountanalysis.jnlp' | Add-Content $PS1File
        'http://sun.security.validator.ValidatorException' | Add-Content $PS1File
        'http://thesource' | Add-Content $PS1File
        'http://trainingmagnetwork.com/lessons/1315/view?no_header=true&slide=1' | Add-Content $PS1File
        'http://wnbwt01:7099/wrc/bin/OnDemandWRCReport/Eal5odq4Fr6.wlp;jsessionid=E093E284924BC38663DD74EAB9686630?new=1' | Add-Content $PS1File
        'http://wnbyh01:8080/' | Add-Content $PS1File
        'http://wnbyh01:8080/bsa_WNB/' | Add-Content $PS1File
        'http://wnbyh01:8080/bsa_WNB/case.jnlp' | Add-Content $PS1File
        'http://wolferesearch' | Add-Content $PS1File
        'http://www.mycrosspoint.org/' | Add-Content $PS1File
        'http://www.socialsecurity.gov' | Add-Content $PS1File
        'http://www.socialsecurity.gov/employer/accuwage/' | Add-Content $PS1File
        'http://www.verizonwireless.com/' | Add-Content $PS1File
        'http://www.verizonwireless.com/b2c/employee/eleuLanding.jsp' | Add-Content $PS1File
        'https://*.ibm.com' | Add-Content $PS1File
        'https://*.moppssc.com' | Add-Content $PS1File
        'https://*.streetscape.com' | Add-Content $PS1File
        'https://10.13.1.10' | Add-Content $PS1File
        'https://10.13.1.13' | Add-Content $PS1File
        'https://10.13.1.13:8080' | Add-Content $PS1File
        'https://10.14.1.15' | Add-Content $PS1File
        'https://10.160.6.120' | Add-Content $PS1File
        'https://10.3.10.22' | Add-Content $PS1File
        'https://10.3.15.60' | Add-Content $PS1File
        'https://10.3.35.32' | Add-Content $PS1File
        'https://10.3.37.21' | Add-Content $PS1File
        'https://10.3.40.70' | Add-Content $PS1File
        'https://10.3.40.70:10000/Konfigurator' | Add-Content $PS1File
        'https://10.3.81.11/' | Add-Content $PS1File
        'https://10.50.11.9/' | Add-Content $PS1File
        'https://10.50.11.9/hmc/connect' | Add-Content $PS1File
        'https://192.22.107.227' | Add-Content $PS1File
        'https://adpeet2.adp.com' | Add-Content $PS1File
        'https://adpeet2.adp.com/67da2p/applications/suitenav/navigation.do' | Add-Content $PS1File
        'https://app.avention.com' | Add-Content $PS1File
        'https://atlftpl.verint.com' | Add-Content $PS1File
        'https://RemoteLocalestaffing/' | Add-Content $PS1File
        'https://ccweb.co.galveston.tc.us' | Add-Content $PS1File
        'https://chapel.globalfxservices.com' | Add-Content $PS1File
        'https://default' | Add-Content $PS1File
        'https://docdirect.streetscape.com' | Add-Content $PS1File
        'https://encompass360.elliemae.com' | Add-Content $PS1File
        'https://guiwebtest.investor.sungard.com/hhf/webstart.jnlp' | Add-Content $PS1File
        'https://DOMAIN.service-now.com/navpage.do' | Add-Content $PS1File
        'https://DOMAIN.taleo.net' | Add-Content $PS1File
        'https://maps.googleapis.com/maps/api/js?key=AIzaSyB83CvL0MhHpuMgTHb1ph8H_larknMcAvY&sensor=true' | Add-Content $PS1File
        'https://moveit.weiland-wfg.com' | Add-Content $PS1File
        'https://XXXXepo1' | Add-Content $PS1File
        'https://XXXXIPS01' | Add-Content $PS1File
        'https://SERVER.DOMAIN.COM' | Add-Content $PS1File
        'https://SERVER.DOMAIN.COM' | Add-Content $PS1File
        'https://SERVER.DOMAIN.COM' | Add-Content $PS1File
        'https://SERVER.DOMAIN.COM' | Add-Content $PS1File
        'https://my.statestreet' | Add-Content $PS1File
        'https://my.statestreet.com/' | Add-Content $PS1File
        'https://ouconnect.oracle.com' | Add-Content $PS1File
        'https://ouconnect.oracle.com/' | Add-Content $PS1File
        'https://powermanager.mortgagewebcenter.com/' | Add-Content $PS1File
        'https://powermanager.mortgagewebcenter.com/Include/Utilities/ClientSide/ExportApplet/JavaPowUpload.jar' | Add-Content $PS1File
        'https://reportinganalytics-cl13.taleo.net' | Add-Content $PS1File
        'https://reportinganalytics-cl13.taleo.net/InfoViewApp/listing/' | Add-Content $PS1File
        'https://reportinganalytics-cl13.taleo.net/InfoViewApp/listing/main.do?appKind=InfoView&service=%2FInfoViewApp%2Fcommon%2FappService.do' | Add-Content $PS1File
        'https://res.cisco.com/envelopeopener' | Add-Content $PS1File
        'https://sas.elluminate.com/site/external/recording/playback/link/meeting.jnlp?suid=M.5C2AEDC0D2DEA412982DDAE98B133B&sid=2010436' | Add-Content $PS1File
        'https://secure2.benefitfocus.com' | Add-Content $PS1File
        'https://sfx.DOMAIN.COM/courier/web/1000@/wmLogin.html' | Add-Content $PS1File
        'https://sfx.DOMAIN.COM/courier/web/1000@1abf20e9b60f6e2a872f8382e4ab3905/wmCompose.html' | Add-Content $PS1File
        'https://streetscape' | Add-Content $PS1File
        'https://wffnet.wellsfargo.com/ilonline/funding/wff_index.html' | Add-Content $PS1File
        'https://www.estarstation.com' | Add-Content $PS1File
        'https://www.estarstation.com/' | Add-Content $PS1File
        'https://www.estarstation.com/nsscma/index.jsp' | Add-Content $PS1File
        'https://www.estarstation.com/nsscms/index.jsp' | Add-Content $PS1File
        'https://www.go-retire.com' | Add-Content $PS1File
        'https://www.msrb.org/msrb1/control/default.asp' | Add-Content $PS1File
        'https://www.officialcheck.com' | Add-Content $PS1File
        'https://www.salesforce.com/form/conf/demo-marketing.jsp"' | Add-Content $PS1File
        '' | Add-Content $PS1File
        '' | Add-Content $PS1File
        '# check if $Path1 exists, if not create it' | Add-Content $PS1File
        'if ((Test-Path $Path1) -eq $false)' | Add-Content $PS1File
        '  {' | Add-Content $PS1File
        '#  write-host "$Path1 does not exist. Create it..."' | Add-Content $PS1File
        '  try' | Add-Content $PS1File
        '    { New-Item -Path $Path1 -ItemType Directory -Force -ErrorAction Stop | Out-Null }' | Add-Content $PS1File
        '  catch' | Add-Content $PS1File
        '    { $_.Exception.Message }' | Add-Content $PS1File
        '  }' | Add-Content $PS1File
        'else' | Add-Content $PS1File
        '  {}' | Add-Content $PS1File
        '# check if $File1 file exists, and create/recreate it' | Add-Content $PS1File
        'if ((Test-Path $Path1\$File1) -eq $true)' | Add-Content $PS1File
        '  {' | Add-Content $PS1File
        '  try' | Add-Content $PS1File
        '    { Remove-Item $Path1\$File1 -Force -ErrorAction Stop | Out-Null }' | Add-Content $PS1File
        '  catch' | Add-Content $PS1File
        '    { $_.Exception.Message }' | Add-Content $PS1File
        '  }' | Add-Content $PS1File
        'try' | Add-Content $PS1File
        '  {' | Add-Content $PS1File
        '  New-Item -Path $Path1 -Name $File1 -ItemType File -Force -Value $Text1 | Out-Null' | Add-Content $PS1File
        '  }' | Add-Content $PS1File
        '  catch' | Add-Content $PS1File
        '  { $_.Exception.Message }' | Add-Content $PS1File
        '# check if $File2 file exists, and create/recreate it' | Add-Content $PS1File
        'if ((Test-Path $Path1\$File2) -eq $true)' | Add-Content $PS1File
        '  {' | Add-Content $PS1File
        '  try' | Add-Content $PS1File
        '    { Remove-Item $Path1\$File2 -Force -ErrorAction Stop | Out-Null }' | Add-Content $PS1File
        '  catch' | Add-Content $PS1File
        '    { $_.Exception.Message }' | Add-Content $PS1File
        '  }' | Add-Content $PS1File
        'try' | Add-Content $PS1File
        '  {' | Add-Content $PS1File
        '  New-Item -Path $Path1 -Name $File2 -ItemType File -Force -Value $Text2 | Out-Null' | Add-Content $PS1File
        '  }' | Add-Content $PS1File
        '  catch' | Add-Content $PS1File
        '  { $_.Exception.Message }' | Add-Content $PS1File
        '# check if $File3 file exists, and create/recreate it' | Add-Content $PS1File
        'if ((Test-Path $Path1\$File3) -eq $true)' | Add-Content $PS1File
        '  {' | Add-Content $PS1File
        '  try' | Add-Content $PS1File
        '    { Remove-Item $Path1\$File3 -Force -ErrorAction Stop | Out-Null }' | Add-Content $PS1File
        '  catch' | Add-Content $PS1File
        '    { $_.Exception.Message }' | Add-Content $PS1File
        '  }' | Add-Content $PS1File
        'try' | Add-Content $PS1File
        '  {' | Add-Content $PS1File
        '  New-Item -Path $Path1 -Name $File3 -ItemType File -Force -Value $Test3 | Out-Null' | Add-Content $PS1File
        '}catch{$_.Exception.Message}' | Add-Content $PS1File


# Compliance File Content - Remediation
        $PS1File = 'C:\!Powershell\Compliance_Scripts\Compliance_File_Content_Remediation--AutoGenerated.ps1'
        '# File Content - Remediation script' | Add-Content $PS1File
        '$Path1 = "$env:windir\Sun\Java\Deployment"' | Add-Content $PS1File
        '$File2 = "deployment.config"' | Add-Content $PS1File
        '$Text2 = "deployment.system.config=file:///C:/Windows/Sun/Java/Deployment/deployment.properties' | Add-Content $PS1File
        'deployment.system.config.mandatory=true"' | Add-Content $PS1File
        '$list = "deployment.system.config=file:///C:/Windows/Sun/Java/Deployment/deployment.properties' | Add-Content $PS1File
        'deployment.system.config.mandatory=true"' | Add-Content $PS1File
        'try{' | Add-Content $PS1File
        'New-Item -Path $Path1 -Force -ItemType Directory' | Add-Content $PS1File
        '$list | Out-file $Path1\deployment.config -Encoding ASCII -Force' | Add-Content $PS1File
        '}catch{$_}' | Add-Content $PS1File


# Compliance File Content - Discovery
        $PS1File = 'C:\!Powershell\Compliance_Scripts\Compliance_File_Content_Discovery--AutoGenerated.ps1'
        '# File Content - Discovery script' | Add-Content $PS1File
        '$Path1 = "$env:windir\Sun\Java\Deployment"' | Add-Content $PS1File
        '$File2 = "deployment.config"' | Add-Content $PS1File
        '$Text2 = "deployment.system.config=file:///C:/Windows/Sun/Java/Deployment/deployment.properties' | Add-Content $PS1File
        'deployment.system.config.mandatory=true"' | Add-Content $PS1File
        '$FilePath = "$Path1\$File2"' | Add-Content $PS1File
        'if ((test-path $FilePath) -eq $true)' | Add-Content $PS1File
        '{if ((($Text2 | Measure-Object -character -ignorewhitespace).Characters) -eq ((Get-content $FilePath | Measure-object -character -ignorewhitespace).Characters))' | Add-Content $PS1File
        '{write-host "Compliant"}' | Add-Content $PS1File
        'else' | Add-Content $PS1File
        '{write-host "Not Compliant"}}' | Add-Content $PS1File


# Compliance Regedit - Remediation
    $PS1File = 'C:\!Powershell\Compliance_Scripts\Compliance_Regedit_Remediation--AutoGenerated.ps1'
    '# Compliance Regedit - Remediation Script' | Add-Content $PS1File
    '$RegPath1 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION"' | Add-Content $PS1File
    '$RegPath2 = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION"' | Add-Content $PS1File
    '$RegKey1 = "iexplore.exe"' | Add-Content $PS1File
    '$RegKey2 = "iexplore.exe"' | Add-Content $PS1File
    '$RegType1 = "DWORD"' | Add-Content $PS1File
    '$RegType2 = "DWORD"' | Add-Content $PS1File
    '$RegValue1 = "1"' | Add-Content $PS1File
    '$RegValue2 = "1"' | Add-Content $PS1File
    'try' | Add-Content $PS1File
    '{if ((test-path $RegPath1) -ne $true)' | Add-Content $PS1File
    '{New-Item $RegPath1 -Force}' | Add-Content $PS1File
    'Set-ItemProperty $RegPath1 -Name $RegKey1 -Type $RegType1 -Value $RegValue1 -Force}' | Add-Content $PS1File
    'Catch{$_.Exception.Message}' | Add-Content $PS1File
    'try' | Add-Content $PS1File
    '{if ((test-path $RegPath2) -ne $true)' | Add-Content $PS1File
    '{New-Item $RegPath2 -Force}' | Add-Content $PS1File
    'Set-ItemProperty $RegPath2 -Name $RegKey2 -Type $RegType2 -Value $RegValue2 -Force}' | Add-Content $PS1File
    'Catch{$_.Exception.Message}' | Add-Content $PS1File


# Compliance Regedit - Discovery
        $PS1File = 'C:\!Powershell\Compliance_Scripts\Compliance_Regedit_Discovery--AutoGenerated.ps1'
        '$RegPath1 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION"' | Add-Content $PS1File
        '$RegPath2 = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION"' | Add-Content $PS1File
        '$RegKey1 = "iexplore`.exe"' | Add-Content $PS1File
        '$RegKey2 = "iexplore`.exe"' | Add-Content $PS1File
        '$RegType1 = "DWORD"' | Add-Content $PS1File
        '$RegType2 = "DWORD"' | Add-Content $PS1File
        '$RegValue1 = "1"' | Add-Content $PS1File
        '$RegValue2 = "1"' | Add-Content $PS1File
        '# Compliance Regedit - Discovery Script' | Add-Content $PS1File
        'try' | Add-Content $PS1File
        '{$UpdateCheck86 = Get-ItemProperty $RegPath1 -Name $RegKey1' | Add-Content $PS1File
        '$UpdateCheck = Get-ItemProperty $RegPath2 -Name $RegKey2' | Add-Content $PS1File
        'If (($UpdateCheck.$RegKey2 –eq 1) -and ($UpdateCheck.$RegKey2 –eq 1))' | Add-Content $PS1File
        '{Write-Host "Compliant"}' | Add-Content $PS1File
        'Else{Write-Host "Non-Compliant"}}' | Add-Content $PS1File
        'Catch{$_.Exception.Message}' | Add-Content $PS1File


#>






# NETSH to SET new name on NIC
# netsh interface set interface name = '+"""$NICname"""+' newname = "DataNetwork"
