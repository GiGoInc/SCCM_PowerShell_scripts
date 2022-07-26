

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
