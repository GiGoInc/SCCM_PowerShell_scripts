$SQL_Queryx86 = "SELECT DISTINCT  
}
    $Chrome_Check.Length
$SQL_Queryx86 = "SELECT DISTINCT  
  SYS.Name0
  ,ARP.DisplayName0 As 'Software Name'
  ,ARP.Version0 As 'Version'
  ,ARP.InstallDate0 As 'Installed Date'
  ,'x86' as 'Type'
 FROM 
  dbo.v_R_System As SYS
  INNER JOIN dbo.v_FullCollectionMembership FCM On FCM.ResourceID = SYS.ResourceID 
  INNER JOIN dbo.v_GS_ADD_REMOVE_PROGRAMS As ARP On SYS.ResourceID = ARP.ResourceID 
 WHERE ARP.DisplayName0 = 'Google Chrome'
 ORDER BY 'Installed Date' ASC"

$SQL_Queryx64 = "SELECT DISTINCT  
  SYS.Name0
  ,ARP.DisplayName0 As 'Software Name'
  ,ARP.Version0 As 'Version'
  ,ARP.InstallDate0 As 'Installed Date'
  ,'x64' as 'Type'
 FROM 
  dbo.v_R_System As SYS
  INNER JOIN dbo.v_FullCollectionMembership FCM On FCM.ResourceID = SYS.ResourceID 
  INNER JOIN dbo.v_GS_ADD_REMOVE_PROGRAMS_64 As ARP On SYS.ResourceID = ARP.ResourceID 
 WHERE ARP.DisplayName0 = 'Google Chrome'
 ORDER BY 'Installed Date' ASC"

 ##################################################################################
 ##################################################################################
 $ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$Log = "D:\Powershell\!Parallized_Scripts\Google_Chrome_Installs\Chrome_SCCM_SQL_Check_Results--$ADate.csv"
'Name,Software Name,Type,Modded Version,Installed Date,Status' | Set-Content $Log

       $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'

$SQL_Querys = $SQL_Queryx86,$SQL_Queryx64

ForEach ($SQL_Query in $SQL_Querys)
{
    $Chrome_Check = Invoke-Sqlcmd -AbortOnError `
    -ConnectionTimeout 60 `
    -Database $SQL_DB  `
    -HostName $SQL_Server  `
    -Query $SQL_Query `
    -QueryTimeout 600 `
    -ServerInstance $SQL_Instance

    $i = 1
    $Chrome_Check | % {
        $Name = $_.Name0
        $SoftwareName = $_."Software Name"
        $Version = $_.Version
        $InstalledDate = $_."Installed Date"
        $Type = $_.Type
          
        $V1 = $Version.Split('.')[0]
        $V2 = $Version.Split('.')[1]
        $V3 = $Version.Split('.')[2]
        $V4 = $Version.Split('.')[3]
        $V1 = $V1.PadLeft(3,'0')
        $V4 = $V4.PadLeft(3,'0')
        $NewVer = "$V1.$V2.$V3.$V4"
        If ($NewVer -gt '122.0.6261.111')
        {
            $output += "$Name,$SoftwareName,$Type,$NewVer,$InstalledDate,UPDATED" | Add-Content $Log
            $i++
        }
        Else { $output += "$Name,$SoftwareName,$Type,$NewVer,$InstalledDate,OUTDATED" | Add-Content $Log
         }
    }
    $Chrome_Check.Length
}
