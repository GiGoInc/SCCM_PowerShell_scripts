Function FireSubscription
}
    $subscriptions | select Status, Path, report, Description, Owner, SubscriptionID, EventType, lastexecuted | where {$_.SubscriptionID -eq $subscriptionid} 
Function FireSubscription
{
    # Parameters  
    #    server         - server and instance name (e.g. myserver/reportserver or myserver/reportserver_db2)  
    #    site           - use $null for a native mode server  
    #    subscriptionid - subscription guid  
      
    Param(  
      [string]$server,  
      [string]$site,  
      [string]$subscriptionid  
      )  
      
    $rs2010 = New-WebServiceProxy -Uri "http://$server/ReportService2010.asmx" -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;  
    #event type is case sensative to what is in the rsreportserver.config  
    $rs2010.FireEvent("TimedSubscription",$subscriptionid,$site)  
      
    Write-Host " "  
    Write-Host "----- Subscription ($subscriptionid) status: "  
    #get list of subscriptions and filter to the specific ID to see the Status and LastExecuted  
    Start-Sleep -s 6 # slight delay in processing so ListSubscription returns the updated Status and LastExecuted  
    $subscriptions = $rs2010.ListSubscriptions($site);   
    $subscriptions | select Status, Path, report, Description, Owner, SubscriptionID, EventType, lastexecuted | where {$_.SubscriptionID -eq $subscriptionid} 
}
