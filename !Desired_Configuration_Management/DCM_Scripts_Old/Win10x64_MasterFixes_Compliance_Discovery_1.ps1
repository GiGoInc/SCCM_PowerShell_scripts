# Compliance_Master_Fixes_Discovery.ps1


# Compliance_Master_Fixes_Discovery.ps1
    $log = 'C:\Windows\Logs\Software'
    if(!(Test-Path -Path $log )){New-Item -ItemType directory -Path $log}
    
    $logfile = "$log\MasterFix_Check.txt"


# Disable Firewall
    $np = Get-NetFirewallProfile -All | select Name,Enabled
    If ($np.Enabled -contains "True")
    {
        "Non-Compliant`tFound firewall rule(s) still enabled." | Add-Content $logfile
        $np | Add-Content $logfile
    }
    Else
    {
        "Compliant:`tAll firewall rules are disabled." | Add-Content $logfile
    }


# PowerShell - Set Execution Policy to RemoteSigned
    $ep = Get-ExecutionPolicy
    If ($ep -eq 'RemoteSigned')
    {
        "Compliant:`tPowerShell Execution Policy is set to RemoteSigned" | Add-Content $logfile
    }
    Else
    {
        "Non-Compliant`tPowerShell Execution Policy is not set to RemoteSigned. Currently set to: $ep" | Add-Content $logfile
        "" | Add-Content $logfile
    }

# Enable PSRemoting
    # POWERSHELL ENABLE-PSREMOTING -SKIPNETWORKPROFILECHECK -FORCE
    # @echo %time:~0,8%	*	Enabled PSRemoting/WinRM  >> C:\Windows\Logs\Software\Win10x64_MasterFixes.log


# Allow RemoteRPC 
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"
    $RegKey1 = "fDenyTSConnections"
    $RegType1 = "DWORD"
    $RegValue1 = "0"
    
    $RegKey2 = "AllowRemoteRPC"
    $RegType2 = "DWORD"
    $RegValue2 = "1"
    
    try
    {
        $check1 = Get-ItemProperty $RegPath -Name $RegKey1
        $check2 = Get-ItemProperty $RegPath -Name $RegKey2
        If (($check1.$RegKey1 –eq 0) -and ($check2.$RegKey2 –eq 1))
        {
            "Compliant:`tRemoteRPC set" | Add-Content $logfile
        }
        Else
        {
        $val1 = $check1.$RegKey1
        $val2 = $check2.$RegKey2
            If ($check1.$RegKey1 –ne 0)
            {
                "Non-Compliant:`tRemoteRPC not set. $RegPath\$RegKey1 is not $RegValue1"  | Add-Content $logfile
                "" | Add-Content $logfile
            }
            If ($check2.$RegKey2 –ne 1)
            {
                "Non-Compliant:`tRemoteRPC not set. $RegPath\$RegKey2 is not $RegValue2"  | Add-Content $logfile
                "" | Add-Content $logfile
            }
        }
    }
    Catch
    {
        $_.Exception.Message
    }


# Enable Remote Registry and set service to Auto
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\services\RemoteRegistry"
    $RegKey1 = "Start"
    $RegType1 = "DWORD"
    $RegValue1 = "2"
    
    
    # Compliance - Enable Remote Registry
        try
        {
            $check1 = Get-ItemProperty $RegPath -Name $RegKey1
            If ($check1.$RegKey1 –eq 2)
            {
                "Compliant:`tRemote Registry Enabled" | Add-Content $logfile
            }
            Else
            {
                "Non-Compliant:`tRemote Registry - $RegPath\$RegKey1 is not $RegValue1"  | Add-Content $logfile
                "" | Add-Content $logfile
            }
        }
        Catch
        {
            $_.Exception.Message
        }
    

    # Compliance - Remote Registry started
        try
        {
            $a = Get-Service -DisplayName ("Remote Registry")
            If ($a.status -eq "Running")
            {
                "Compliant:`tRemote Registry - started" | Add-Content $logfile
            }
            Else
            {
                "Non-Compliant:`tRemote Registry service is not started"  | Add-Content $logfile
                "" | Add-Content $logfile           
            }
        }
        Catch
        {
            $_.Exception.Message
        }
        

    # Compliance - Remote Registry set to Auto        
        try
        {
            $a = Get-WmiObject -Query "Select StartMode From Win32_Service Where Name='remoteregistry'"
            If ($a.startmode -eq "Auto")
            {
                "Compliant:`tRemote Registry set to automatically start" | Add-Content $logfile
            }
            Else
            {
                "Non-Compliant:`tRemote Registry service is not set to automatically start"  | Add-Content $logfile
                "" | Add-Content $logfile           
            }
        }
        Catch
        {
            $_.Exception.Message
        }


# Disable System Restore
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
    $RegKey1 = "DisableSR"
    $RegType1 = "DWORD"
    $RegValue1 = "1"
    
    
    # Compliance - Enable Remote Registry
        try
        {
            $check1 = Get-ItemProperty $RegPath -Name $RegKey1
            If ($check1.$RegKey1 –eq 1)
            {
                "Compliant:`tSystem Restore disabled" | Add-Content $logfile
            }
            Else
            {
                "Non-Compliant:`tSystem Restore not disabled - $RegPath\$RegKey1 is not $RegValue1"  | Add-Content $logfile
                "" | Add-Content $logfile
            }
        }
        Catch
        {
            $_.Exception.Message
        }


# Add WKSAdmin to local Administrators group
    $b = net localgroup administrators
    If($b -contains "DOMAIN\WKSAdmin")
    {
        "Compliant:`tWKSAdmin is part of the local Admin group"  | Add-Content $logfile
    }
    Else
    {
        "Non-Compliant:`tWKSAdmin is NOT part of the local Admin group"  | Add-Content $logfile
        "" | Add-Content $logfile
    }


# Disable WindowsConsumerFeatures - Start Menu junk
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $RegKey1 = "DisableWindowsConsumerFeatures"
    $RegType1 = "DWORD"
    $RegValue1 = "1"

        try
        {
            $check1 = Get-ItemProperty $RegPath -Name $RegKey1
            If ($check1.$RegKey1 –eq 1)
            {
                "Compliant:`tWindowsConsumerFeatures are disabled" | Add-Content $logfile
            }
            Else
            {
                "Non-Compliant:`tWindowsConsumerFeatures are not disabled - $RegPath\$RegKey1 is not $RegValue1"  | Add-Content $logfile
                "" | Add-Content $logfile
            }
        }
        Catch
        {
            $_.Exception.Message
        }


# Do not display last logged on user
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $RegKey1 = "dontdisplaylastusername"
    $RegType1 = "DWORD"
    $RegValue1 = "1"

        try
        {
            $check1 = Get-ItemProperty $RegPath -Name $RegKey1
            If ($check1.$RegKey1 –eq 1)
            {
                "Compliant:`tDisplay last logged on username is disabled" | Add-Content $logfile
            }
            Else
            {
                "Non-Compliant:`tDisplay last logged on username is not disabled - $RegPath\$RegKey1 is not $RegValue1"  | Add-Content $logfile
                "" | Add-Content $logfile
            }
        }
        Catch
        {
            $_.Exception.Message
        }


# Sets Preferred Power Plan to High Performance
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}"
    $RegKey1 = "PreferredPlan"
    $RegType1 = "Reg_SZ"
    $RegValue1 = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

        try
        {
            $check1 = Get-ItemProperty $RegPath -Name $RegKey1
            If ($check1.$RegKey1 –eq "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c")
            {
                "Compliant:`tPreferred Power plan is set" | Add-Content $logfile
            }
            Else
            {
                "Non-Compliant:`tPreferred Power plan - $RegPath\$RegKey1 is not $RegValue1"  | Add-Content $logfile
                "" | Add-Content $logfile
            }
        }
        Catch
        {
            $_.Exception.Message
        }

# Sets Power Plan to High Performance
    $d = gwmi -NS root\cimv2\power -Class win32_PowerPlan
    foreach ($item in $d)
    {
        If (($item.ElementName -eq "High performance") -and ($item.IsActive -eq "High performance"))
        {
            "Compliant:`tPreferred Power plan is set to High Performance" | Add-Content $logfile
        }
        Elseif (($item.ElementName -ne "High performance") -and ($item.IsActive -eq "High performance"))
        {
            "Non-Compliant:`tPreferred Power plan is set to"+$item.ElementName  | Add-Content $logfile
            "" | Add-Content $logfile
        }
    }


# Check Installed AppxPackages
    $c = Get-AppxPackage -AllUsers
    "" | Add-Content $logfile
    "Installed AppX Packages:" | Add-Content $logfile
    $c.name | Sort-Object -Unique | Add-Content $logfile
    "" | Add-Content $logfile


