# Load SCCM Module
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:


<#
    Pieces to this script

    1) Set the dates the deployment will run
    2) Set the Collection Name
    3) Create Collections
    4) Set the Include Collections
    5) Create deployments and assign them to the right Collections

#>

###########################################################################################################
### Change this for each new set of deployments
    <#
        Deployment span for all the Collections is normally about a month assuming you start on a Tuesday evening
             First week's deployments - 4 (1 on Tuesday, 1 on Wednesday, 2 on Thursday)
        Additional week's deployments - 8 (2 on Monday - Thursday)
        28 Collections (approx 100 machine per Collection)
        28 / 4+8+8+8 = 4 weeks, with 15 deployment evenings
    #> 
     $DeploymentStartDate = '08/22/2017'
       $DeploymentEndDate = '09/14/2017'

    $CollNameStart = 'WMF 5.1'




###########################################################################################################
### Create Collections using text file with static names list

# Variables
    $AvailableTime = Get-Date -Format "MM/dd/yyyy hh:mm tt"      
    $Schedule1 = New-CMSchedule -Start "$AvailableTime" -RecurCount 14 -RecurInterval Days
     $Comments = "Created by Automated PowerShell script - $AvailableTime - Isaac"

# Get Deploy dates
    $DeployDates = @()
    $Start = $DeploymentStartDate | Get-Date
    $End = $DeploymentEndDate | Get-Date
    
    #define a counter
        $i=0
    
    # Test every date between start and end to see if it is a Sunday, Friday, or Saturday
        For ($d=$start;$d -le $end;$d=$d.AddDays(1))
        {
            If ($d.DayOfWeek -notmatch "Sunday|Friday|Saturday")
            {
                #if the day of the week is not a Saturday or Sunday
                #increment the counter
                $Date = $d.Date
                $DeployDates += $Date | Get-Date -Format "MM/dd/yyyy"
                $i++
            }
        }


# Counter
    $CollArray = @()
    $Num=1
    Do
    {
        $CollName = "$CollNameStart" + '  deployment - Group ' + "{0:D2}" -f $Num
        $CollArray += $CollName
    }While (($Num = $Num + 1) -le 28)


# Check each Collection/Deployment
    ForEach ($CollName in $CollArray)
    {	
        # Make Device Collections
            #New-CMDeviceCollection -Name $CollName -LimitingCollectionName "All Windows Workstation or Professional Systems (DC0)" -RefreshSchedule $Schedule1 -RefreshType Both -Comment $Comments

        $CollName

        # Make Deployment
            $A = Get-CMCollection -Name $CollName | Select-Object CollectionID
            $CollID = $A.CollectionID

 

    }


###########################################################################################################
### Get Collection IDs from those new Collections and match them to a "Workstation Install Groups" Collection

<#
$A = Get-CMCollection -Name " | Select-Object Name,CollectionID
$CollID = $A.CollectionID
$CollName = $A.Name
"$CollName,$CollID" -join ',' | Add-Content "$CurrentDirectory \SCCM_Collections_$ADate.txt"





$Collections = 'SS10080C;Workstations - Branch;03/28/2017 18:00', `
               'SS1007C2;Workstations - Non-Branch - Group 01;03/28/2017 18:00', `
               'SS1007C3;Workstations - Non-Branch - Group 02;03/28/2017 18:00', `
               'SS1007C4;Workstations - Non-Branch - Group 03;03/28/2017 18:00', `
               'SS1007C5;Workstations - Non-Branch - Group 04;03/29/2017 18:00', `
               'SS1007C6;Workstations - Non-Branch - Group 05;03/29/2017 18:00', `
               'SS1007C7;Workstations - Non-Branch - Group 06;03/29/2017 18:00', `
               'SS1007C8;Workstations - Non-Branch - Group 07;03/30/2017 18:00', `
               'SS1007C9;Workstations - Non-Branch - Group 08;03/30/2017 18:00', `
               'SS1007CA;Workstations - Non-Branch - Group 09;03/30/2017 18:00', `
               'SS1007CB;Workstations - Non-Branch - Group 10;04/03/2017 18:00', `
               'SS1007CC;Workstations - Non-Branch - Group 11;04/03/2017 18:00', `
               'SS1007CD;Workstations - Non-Branch - Group 12;04/03/2017 18:00', `
               'SS1007CE;Workstations - Non-Branch - Group 13;04/04/2017 18:00', `
               'SS1007CF;Workstations - Non-Branch - Group 14;04/04/2017 18:00', `
               'SS1007D0;Workstations - Non-Branch - Group 15;04/04/2017 18:00', `
               'SS1007D1;Workstations - Non-Branch - Group 16;04/05/2017 18:00', `
               'SS1007D2;Workstations - Non-Branch - Group 17;04/05/2017 18:00', `
               'SS1007D3;Workstations - Non-Branch - Group 18;04/05/2017 18:00', `
               'SS1007D4;Workstations - Non-Branch - Group 19;04/06/2017 18:00', `
               'SS1007D5;Workstations - Non-Branch - Group 20;04/06/2017 18:00', `
               'SS1007D6;Workstations - Non-Branch - Group 21;04/06/2017 18:00', `
               'SS1007D7;Workstations - Non-Branch - Group 22;04/10/2017 18:00', `
               'SS1007D8;Workstations - Non-Branch - Group 23;04/10/2017 18:00', `
               'SS1007D9;Workstations - Non-Branch - Group 24;04/10/2017 18:00', `
               'SS1007DA;Workstations - Non-Branch - Group 25;04/11/2017 18:00', `
               'SS1007DB;Workstations - Non-Branch - Group 26;04/11/2017 18:00', `
               'SS1007DC;Workstations - Non-Branch - Group 27;04/11/2017 18:00', `
               'SS1007DF;Workstations - Non-Branch - Not in a Group;04/11/2017 18:00'

$StartDate = (GET-DATE)
    ForEach ($Collection in $Collections)
    {
         $COllID = $Collection.split(';')[0]
           $Name = $Collection.split(';')[1]
           $Time = $Collection.split(';')[2]
        $EndDate = [datetime]$Time
             $TS = NEW-TIMESPAN –Start $StartDate –End $EndDate
        If (($TS.Date -le '0') -and ($TS.Hours -le '0')){Add-CMDeviceCollectionIncludeMembershipRule -CollectionId SS100870 -IncludeCollectionId $CollID}
    }

###########################################################################################################
### Add Include Collection Rule

Function Add-CollectionIncludeRule ($CollectionName,$InCollectionName)
{
    $ParentCollection = Get-WmiObject -Namespace "root\sms\Site_SS1" -Class SMS_Collection -ComputerName 'SCCMSERVER' -Filter "Name='$CollectionName'"
    $SubCollection = Get-WmiObject -Namespace "root\sms\Site_SS1" -Class SMS_Collection -ComputerName 'SCCMSERVER' -Filter "Name='$InCollectionName'"

    $VerifyDependency = Invoke-WmiMethod -Namespace "root\sms\Site_SS1" -Class SMS_Collection -Name VerifyNoCircularDependencies -ArgumentList @($ParentCollection.__PATH,$SubCollection.__PATH,$null) -ComputerName 'SCCMSERVER'

    If($VerifyDependency){
        #Read Lazy properties
        $ParentCollection.Get()
        
        #Create new rule
        $NewRule = ([WMIClass]"\\SCCMSERVER\root\SMS\Site_SS1:SMS_CollectionRuleIncludeCollection").CreateInstance()
        $NewRule.IncludeCollectionID = $SubCollection.CollectionID
        $NewRule.RuleName = $SubCollection.Name
        
        #Commit changes and initiate the collection evaluator                      
        $ParentCollection.CollectionRules += $NewRule.psobject.baseobject
        $ParentCollection.Put()
        $ParentCollection.RequestRefresh()
    }         
}


Add-CollectionIncludeRule -CollectionName "WMF 5.1 deployment - Group 01" -InCollectionName "Workstations - Non-Branch - Group 01"


###########################################################################################################
### Setup deployments
$List = "D:\Powershell\!SCCM_PS_scripts\!Deployments\SCCM_Set_Deployments_on_Device_Collection--PCList.txt"

$CollectionInfo = Get-Content $List

ForEach ($Item in $CollectionInfo)
{
    $CollName = $Item.split(';')[0]
     $AppName = $Item.split(';')[1]
       $ADate = $Item.split(';')[2]
       $DDate = $Item.split(';')[3]
        $Comm = "Deployment from POWERSHELL to $CollName of $AppName"
	 $DAction = "Install"

New-CMApplicationDeployment -Name $AppName `
                            -AvailableDateTime $ADate `
                            -CollectionName $CollName `
                            -Comment $Comm `
                            -DeadlineDateTime $DDate `
                            -DeployPurpose Required `
                            -EnableMomAlert $False `
                            -FailParameterValue 15 `
                            -OverrideServiceWindow $True `
                            -PreDeploy $False `
                            -RebootOutsideServiceWindow $False `
                            -SendWakeupPacket $True `
                            -TimeBaseOn LocalTime `
                            -UserNotification HideAll
}
CD D:

#>