. C:\Scripts\!Modules\ListAll_SSRS_Subscriptions_for_specific_User.ps1
}
     "$Report,$Description,$SubscriptionID" | Add-Content ".\SCCM_Report_Subscriptions_for_$user.csv"
. C:\Scripts\!Modules\ListAll_SSRS_Subscriptions_for_specific_User.ps1

$user = 'SUPERUSER'

"Report,Description,SubscriptionID" | Set-Content ".\SCCM_Report_Subscriptions_for_$user.csv"


$A = CheckReportSubscriptions -currentOwner "DOMAIN\$user" -server "SERVER/reportserver" -site "/"
ForEach ($item in $A)
{
              $Path = $item.Path 
            $Report = $item.Report 
       $Description = $item.Description 
             $Owner = $item.Owner 
    $SubscriptionID = $item.SubscriptionID 
      $LastExecuted = $item.LastExecuted 
            $Status = $item.Status  
    
    # Write-Host "Report:         $Report"
    # Write-Host "Description:    $Description"
    # Write-Host "SubscriptionID: $SubscriptionID"
    
     "$Report,$Description,$SubscriptionID" | Add-Content ".\SCCM_Report_Subscriptions_for_$user.csv"
}
