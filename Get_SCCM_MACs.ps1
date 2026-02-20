$SQL_Query = "select v_R_SYSTEM.ResourceID,
} 
    }
$SQL_Query = "select v_R_SYSTEM.ResourceID,
v_R_SYSTEM.ResourceType,
v_R_SYSTEM.Name0,
v_R_SYSTEM.SMS_Unique_Identifier0,
v_R_SYSTEM.Resource_Domain_OR_Workgr0,
v_R_SYSTEM.Client0,
v_GS_NETWORK_ADAPTER.TimeStamp,
v_GS_NETWORK_ADAPTER.Description0,
v_GS_NETWORK_ADAPTER.MACAddress0
from v_R_System 
inner join v_GS_NETWORK_ADAPTER on v_GS_NETWORK_ADAPTER.ResourceID = v_R_System.ResourceId"
##################################################################################
##################################################################################
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$Log = "D:\Powershell\!SCCM_PS_scripts\Get_SCCM_MACs--$ADate.csv"
'Resource ID,Resource Type,Name,Resource Domain,Client,Description,MACAddress,NIC TimeStamp' | Set-Content $Log

       $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'

$SQL_Querys = $SQL_Query

ForEach ($SQL_Query in $SQL_Querys)
{
    $Check = Invoke-Sqlcmd -AbortOnError `
    -ConnectionTimeout 60 `
    -Database $SQL_DB  `
    -HostName $SQL_Server  `
    -Query $SQL_Query `
    -QueryTimeout 600 `
    -ServerInstance $SQL_Instance

    $i = 1
    $Check | % {
        $ResourceID                 = $_.ResourceID
        $ResourceType               = $_.ResourceType
        $Name0                      = $_.Name0
        $Resource_Domain_OR_Workgr0 = $_.Resource_Domain_OR_Workgr0
        $Client0                    = $_.Client0
        $TimeStamp                  = $_.TimeStamp
        $Description0               = $_.Description0
        $MACAddress0                = $_.MACAddress0


        If (($Description0 -eq "MICROSOFT FAILOVER CLUSTER VIRTUAL ADAPTER") -or
            ($Description0 -eq "MICROSOFT ISATAP ADAPTER") -or
            ($Description0 -eq "MICROSOFT KERNEL DEBUG NETWORK ADAPTER") -or
            ($Description0 -eq "MICROSOFT KM-TEST LOOPBACK ADAPTER") -or
            ($Description0 -eq "MICROSOFT NETWORK ADAPTER MULTIPLEXOR DRIVER") -or
            ($Description0 -eq "MICROSOFT TEREDO TUNNELING ADAPTER") -or
            ($Description0 -eq "MICROSOFT TUN MINIPORT ADAPTER") -or
            ($Description0 -eq "MICROSOFT WI-FI DIRECT VIRTUAL ADAPTER") -or
            ($Description0 -eq "BLACKBERRY ENTERPRISE VIRTUAL PRIVATE NETWORK") -or
            ($Description0 -eq "BLUETOOTH DEVICE (PERSONAL AREA NETWORK)") -or
            ($Description0 -eq "WAN MINIPORT (GRE)") -or
            ($Description0 -eq "WAN MINIPORT (IKEV2)") -or
            ($Description0 -eq "WAN MINIPORT (IP)") -or
            ($Description0 -eq "WAN MINIPORT (IPV6)") -or
            ($Description0 -eq "WAN MINIPORT (L2TP)") -or
            ($Description0 -eq "WAN MINIPORT (NETWORK MONITOR)") -or
            ($Description0 -eq "WAN MINIPORT (PPPOE)") -or
            ($Description0 -eq "WAN MINIPORT (PPTP)") -or
            ($Description0 -eq "WAN MINIPORT (SSTP)") -or
            ($Description0 -eq "THUNDERBOLT(TM) NETWORKING") -or
            ($Description0 -eq "USBNCM HOST DEVICE") -or
            ($Description0 -eq "VERIFONE RNDIS 6.0") -or
            ($Description0 -eq "VIRTUALBOX BRIDGED NETWORKING DRIVER MINIPORT") -or
            ($Description0 -eq "RAS ASYNC ADAPTER") -or
            ($Description0 -eq "IBM USB REMOTE NDIS NETWORK DEVICE") -or
            ($Description0 -eq "DISPLAYLINK NETWORK ADAPTER NCM") -or
            ($Description0 -eq "VIRTUALBOX HOST-ONLY ETHERNET ADAPTER") -or
            ($Description0 -eq "REMOTE NDIS BASED INTERNET SHARING DEVICE") -or
            ($Description0 -eq "REMOTE NDIS COMPATIBLE DEVICE") -or
            ($Description0 -eq "TAP-WIN32 ADAPTER V9") -or
            ($Description0 -like "WI-FI 6"))
            {}
            Else
            { "`"$ResourceID`",`"$ResourceType`",`"$Name0`",`"$Resource_Domain_OR_Workgr0`",`"$Client0`",`"$Description0`",`"$MACAddress0`",`"$TimeStamp`"" } # | Add-Content $Log }
        $i++
    }
} 
