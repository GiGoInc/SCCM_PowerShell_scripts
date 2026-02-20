Function CheckReportSubscriptions
}
    $subscriptions | select Path, report, Description, Owner, SubscriptionID, lastexecuted,Status | where {$_.owner -eq $currentOwner}
Function CheckReportSubscriptions
{
    # Parameters:  
    #    currentOwner - DOMAIN\USER that owns the subscriptions you wish to change  
    #    server        - server and instance name (e.g. myserver/reportserver or myserver/reportserver_db2)  
    #    site        - use "/" for default native mode site  
    Param(  
        [string]$currentOwner,  
        [string]$server,  
        [string]$site  
    )  
 

    $rs2010 = New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
    $subscriptions += $rs2010.ListSubscriptions($site);  
      
    Write-Host " "  
    Write-Host " "  
    Write-Host "----- $currentOwner's Subscriptions: "  
    $subscriptions | select Path, report, Description, Owner, SubscriptionID, lastexecuted,Status | where {$_.owner -eq $currentOwner}
}
