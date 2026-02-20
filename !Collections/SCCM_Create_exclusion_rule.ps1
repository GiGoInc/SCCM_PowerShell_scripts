#Example 1
Add-CollectionExcludeRule -SiteServer Server100 -SiteCode PRI -CollectionName "OSD Bare Metal" -ExCollectionName "New Dev Col"
}
#Example 1
$CollectionName = "OSD Bare Metal"
$ExclusionCollectionName = "New Dev Col"
$ParentCollection = Get-WmiObject -Namespace "root\sms\Site_PRI" -Class SMS_Collection -Filter "Name='$CollectionName'"
$SubCollection = Get-WmiObject -Namespace "root\sms\Site_PRI" -Class SMS_Collection -Filter "Name='$ExclusionCollectionName'"

$VerifyDependency = Invoke-WmiMethod -Namespace "root\sms\Site_PRI" -Class SMS_Collection -Name VerifyNoCircularDependencies -ArgumentList @($ParentCollection.__PATH,$SubCollection.__PATH,$null)

If($VerifyDependency){
    #Read Lazy properties
    $ParentCollection.Get()
    
    #Create new rule
    $NewRule = ([WMIClass]"\\Localhost\root\SMS\Site_PRI:SMS_CollectionRuleExcludeCollection").CreateInstance()
    $NewRule.ExcludeCollectionID = $SubCollection.CollectionID
    $NewRule.RuleName = $SubCollection.Name
    
    #Commit changes and initiate the collection evaluator                    
    $ParentCollection.CollectionRules += $NewRule.psobject.baseobject
    $ParentCollection.Put()
    $ParentCollection.RequestRefresh()
}

#Example 2
$CollectionName = "OSD Bare Metal"
$ExclusionCollectionName = "New Dev Col"
$ParentCollection = Get-WmiObject -Namespace "root\sms\Site_PRI" -Class SMS_Collection -Filter "Name='$CollectionName'"
$SubCollection = Get-WmiObject -Namespace "root\sms\Site_PRI" -Class SMS_Collection -Filter "Name='$ExclusionCollectionName'"

$VerifyDependency = Invoke-WmiMethod -Namespace "root\sms\Site_PRI" -Class SMS_Collection -Name VerifyNoCircularDependencies -ArgumentList @($ParentCollection.__PATH,$SubCollection.__PATH,$null)

If($VerifyDependency){
    #Create new rule
    $NewRule = ([WMIClass]"\\Localhost\root\SMS\Site_PRI:SMS_CollectionRuleExcludeCollection").CreateInstance()
    $NewRule.ExcludeCollectionID = $SubCollection.CollectionID
    $NewRule.RuleName = $SubCollection.Name
    
    #Commit changes and initiate the collection evaluator                   
    $ParentCollection.AddMemberShipRule($NewRule)
    $ParentCollection.RequestRefresh()
}

#Example 3
Function Add-CollectionExcludeRule
{
    [CmdletBinding()]
    Param(
         [Parameter(Mandatory=$True,HelpMessage="Please Enter Primary Server Site Server")]
                $SiteServer,
         [Parameter(Mandatory=$True,HelpMessage="Please Enter Primary Server Site code")]
                $SiteCode,
         [Parameter(Mandatory=$True,HelpMessage="Please Enter collection name where do you want to set new rule")]
                $CollectionName,
         [Parameter(Mandatory=$True,HelpMessage="Please Enter collection name that you want to exclude")]
                $ExCollectionName 
         )

    $ParentCollection = Get-WmiObject -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer -Filter "Name='$CollectionName'"
    $SubCollection = Get-WmiObject -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer -Filter "Name='$ExCollectionName'"

    $VerifyDependency = Invoke-WmiMethod -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -Name VerifyNoCircularDependencies -ArgumentList @($ParentCollection.__PATH,$SubCollection.__PATH,$null) -ComputerName $SiteServer 

    If($VerifyDependency){
        #Read Lazy properties
        $ParentCollection.Get()
        
        #Create new rule
        $NewRule = ([WMIClass]"\\$SiteServer\root\SMS\Site_$($SiteCode):SMS_CollectionRuleExcludeCollection").CreateInstance()
        $NewRule.ExcludeCollectionID = $SubCollection.CollectionID
        $NewRule.RuleName = $SubCollection.Name
        
        #Commit changes and initiate the collection evaluator                      
        $ParentCollection.CollectionRules += $NewRule.psobject.baseobject
        $ParentCollection.Put()
        $ParentCollection.RequestRefresh()
    }         
         
}
Add-CollectionExcludeRule -SiteServer Server100 -SiteCode PRI -CollectionName "OSD Bare Metal" -ExCollectionName "New Dev Col"
