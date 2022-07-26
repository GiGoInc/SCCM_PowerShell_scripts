Configuration ConfigMgrHealthCheck
{

[Parameter(Mandatory=$True)]
[string]$CMInstallArguments

    Package ConfigMgrClient
    {
        Ensure = “Present”
        Path = “\\modelsc02\smsClient\ccmsetup.exe”
        Arguments = $CMInstallArguments
        Name = “Configuration Manager Client”
        # Logpath = “c:\users\tim.mintner\desktop”
        ProductId = “D6804B3A-BFEC-4AB4-BFA5-FD9BECC80630”
    }
    
    Service BITS
    {
        Name = “BITS”
        StartupType = “Automatic”
        State = “Running”
    }
    
    Service winmgmt
    {
        Name = “winmgmt”
        StartupType = “Automatic”
        State = “Running”
    }
    
    Service wuauserv
    {
        Name = “wuauserv”
        StartupType = “Automatic”
        State = “Running”
    }
    
    Service lanmanserver
    {
        Name = “lanmanserver”
        StartupType = “Automatic”
        State = “Running”
    }
    
    Service RpcSs
    {
        Name = “RpcSs”
        StartupType = “Automatic”
        State = “Running”
    }
    
    Service ccmexec
    {
        Name = “ccmexec”
        StartupType = “Automatic”
        State = “Running”
    }
    
    Service lanmanworkstation
    {
        Name = “lanmanworkstation”
        StartupType = “Automatic”
        State = “Running”
    }
    Service CryptSvc
    {
        Name = “CryptSvc”
        StartupType = “Automatic”
        State = “Running”
    }
    Service ProtectedStorage
    {
        Name = “ProtectedStorage”
        StartupType = “Automatic”
        State = “Running”
    }
    Service PolicyAgent
    {
        Name = “PolicyAgent”
        StartupType = “Automatic”
        State = “Running”
    }
    Service RemoteRegistry
    {
        Name = “RemoteRegistry”
        StartupType = “Automatic”
        State = “Running”
    }
    
    Registry EnableDCOM
    {
        Ensure = “Present”
        Key = “HKEY_Local_Machine\SOFTWARE\Microsoft\Ole”
        ValueName = “EnableDCOM”
        ValueData = “Y”
        Force = $true
    }
}

ConfigMgrHealthCheck -CMInstallArguments “/mp:modelsc02” -OutputPath .\
#Start-DscConfiguration -path .\ -verbose