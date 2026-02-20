$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
Write-Host "done." -ForegroundColor Green
}
$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
$FileName = "D:\Powershell\!SCCM_PS_scripts\!Collections\Maintenance_Windows\03__Get_CollectionMembership_by_Query_$ADate.csv"
'Collection Name and Query Name,Count,ResourceID,ResourceType,Name,SMS_Unique_ID,Resource_Domain,Client' | Set-Content $FileName

####################################################################################################################################################
####################################################################################################################################################
$FDate = Get-Date -Format "yyyy-MM-dd"
$SQL_Queries = Get-Content "D:\Powershell\!SCCM_PS_scripts\!Collections\Maintenance_Windows\02__Get_Collection_Membership_Queries_$FDate.txt"
##########################################################################

ForEach ($SQL_Query in $SQL_Queries)
 {
    ##########################################################################
          $SQL_DB = 'CM_XX1'
      $SQL_Server = 'SERVER'
    $SQL_Instance = 'SERVER'
    ##########################################################################
       $SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
            -Database $SQL_DB  `
            -HostName $SQL_Server  `
            -Query $SQL_Query `
            -QueryTimeout 600 `
            -ServerInstance $SQL_Instance
            Start-Sleep -Milliseconds 500
    ##########################################################################
        $Count = $SQL_Check.count
        $FName = $SQL_Query.split('*/')[2].trim().replace(' ','_')

        $output = @()
        ForEach ($Check in $SQL_Check)
        {
                $ResourceID   = $Check.Resourceid
            $ResourceType     = $Check.ResourceType
            $Name             = $Check.Name0
            $SMS_Unique_ID    = $Check.SMS_Unique_Identifier0
            $Resource_Domain  = $Check.Resource_Domain_OR_Workgr0
            $Client           = $Check.Client0

            $output += '"' +    $FName + '","' + `
                                $Count + '","' + ` 
                                $ResourceID + '","' + ` 
                                $ResourceType  + '","' + `  
                                $Name + '","' + `           
                                $SMS_Unique_ID + '","' + `   
                                $Resource_Domain + '","' + `
                                $Client + '"'
        }
    ##########################################################################
    $ErrorActionPreference = 'Stop'
    Try 
    {
        $String = $output[0].split(',')[1].replace('"','').PadLeft(4,'0') + " --- " + $output[0].split(',')[0].replace('"','')
        Write-Host "$String" -ForegroundColor Yellow
        $output | Add-Content $FileName
        #Write-Host "$FileName....done." -ForegroundColor Green
    }
    Catch
    {
        $String = $SQL_Query.split('/')[1]
        Write-Host "0000 --- Error pulling Query - $String" -ForegroundColor Red
        "Error pulling Query - $String,0000" | Add-Content $FileName
        #Write-Host "$FileName....done." -ForegroundColor Green       
    }
    Finally { $ErrorActionPreference = 'SilentlyContinue' }
}
Write-Host "done." -ForegroundColor Green
