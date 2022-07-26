Function Get-SCCMUserCollectionDeployment
{
<#
    .SYNOPSIS
        Function to retrieve a User's collection deployment

    .DESCRIPTION
        Function to retrieve a User's collection deployment
        The function will first retrieve all the collection where the user is member of and
        find deployments advertised on those.

        The final output will include user, collection and deployment information.

    .PARAMETER Username
        Specifies the SamAccountName of the user.
        The user must be present in the SCCM CMDB

    .PARAMETER SiteCode
        Specifies the SCCM SiteCode

    .PARAMETER ComputerName
        Specifies the SCCM Server to query

    .PARAMETER Credential
        Specifies the credential to use to query the SCCM Server.
        Default will take the current user credentials

    .PARAMETER Purpose
        Specifies a specific deployment intent.
        Possible value: Available or Required.
        Default is Null (get all)

    .EXAMPLE
        Get-SCCMUserCollectionDeployment -UserName TestUser -Credential $cred -Purpose Required

    .NOTES
        Francois-Xavier cat
        lazywinadmin.com
        @lazywinadmin

        SMS_R_User: https://msdn.microsoft.com/en-us/library/hh949577.aspx
        SMS_Collection: https://msdn.microsoft.com/en-us/library/hh948939.aspx
        SMS_DeploymentInfo: https://msdn.microsoft.com/en-us/library/hh948268.aspx
#>

    [CmdletBinding()]
    PARAM
    (
        [Parameter(Mandatory)]
        [Alias('SamAccountName')]
        $UserName,

        [Parameter(Mandatory)]
        $SiteCode,

        [Parameter(Mandatory)]
        $ComputerName,

        [Alias('RunAs')]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [ValidateSet('Required', 'Available')]
        $Purpose
    )

    BEGIN
    {
        # Verify if the username contains the domain name
        #  If it does... remove the domain name
        # Example: "FX\TestUser" will become "TestUser"
        if ($UserName -like '*\*') { $UserName = ($UserName -split '\\')[1] }

        # Define default properties
        $Splatting = @{
            ComputerName = $ComputerName
            NameSpace = "root\SMS\Site_$SiteCode"
        }

        IF ($PSBoundParameters['Credential'])
        {
            $Splatting.Credential = $Credential
        }

        Switch ($Purpose)
        {
            "Required" { $DeploymentIntent = 0 }
            "Available" { $DeploymentIntent = 2 }
            default { $DeploymentIntent = "NA" }
        }

        Function Get-DeploymentIntentName
        {
                PARAM(
                [Parameter(Mandatory)]
                $DeploymentIntent
                )
                    PROCESS
                    {
                if ($DeploymentIntent = 0) { Write-Output "Required" }
                if ($DeploymentIntent = 2) { Write-Output "Available" }
                if ($DeploymentIntent -ne 0 -and $DeploymentIntent -ne 2) { Write-Output "NA" }
            }
        }#Function Get-DeploymentIntentName


    }
    PROCESS
    {
        # Find the User in SCCM CMDB
        $User = Get-WMIObject @Splatting -Query "Select * From SMS_R_User WHERE UserName='$UserName'"

        # Find the collections where the user is member of
        Get-WmiObject -Class sms_fullcollectionmembership @splatting -Filter "ResourceID = '$($user.resourceid)'" |
        ForEach-Object {

            # Retrieve the collection of the user
            $Collections = Get-WmiObject @splatting -Query "Select * From SMS_Collection WHERE CollectionID='$($_.Collectionid)'"


            # Retrieve the deployments (advertisement) of each collections
            Foreach ($Collection in $collections)
            {
                IF ($DeploymentIntent -eq 'NA')
                {
                    # Find the Deployment on one collection
                    $Deployments = (Get-WmiObject @splatting -Query "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)'")
                }
                ELSE
                {
                    $Deployments = (Get-WmiObject @splatting -Query "Select * From SMS_DeploymentInfo WHERE CollectionID='$($Collection.CollectionID)' AND DeploymentIntent='$DeploymentIntent'")
                }

                Foreach ($Deploy in $Deployments)
                {

                    # Prepare Output
                    $Properties = @{
                        UserName = $UserName
                        ComputerName = $ComputerName
                        CollectionName = $Deploy.CollectionName
                        CollectionID = $Deploy.CollectionID
                        DeploymentID = $Deploy.DeploymentID
                        DeploymentName = $Deploy.DeploymentName
                        DeploymentIntent = $deploy.DeploymentIntent
                        DeploymentIntentName = (Get-DeploymentIntentName -DeploymentIntent $deploy.DeploymentIntent)
                        TargetName = $Deploy.TargetName
                        TargetSubName = $Deploy.TargetSubname

                    }

                    # Output the current Object
                    New-Object -TypeName PSObject -prop $Properties
                }
            }
        }
    }
}
CLS

$UserID = 'LPHILLI'
########################################
# SCCM Module - Check
Write-Host "Checking via SCCM Module..." -ForegroundColor Magenta
    $Output1 = @()
    $AN = (Get-SCCMUserCollectionDeployment -UserName "$UserID" -SiteCode 'SS1' -ComputerName 'sccmserver' | sort TargetName) 
    ForEach ($App in $AN)
    {
        If ($App.CollectionName -match 'SDG*')
        {
            $Output1 += $($App.CollectionName) + ' -- ' + $($App.targetname)
        }
    }
    $Output1 | Select -Unique
########################################
# SQL Query - Check
    Write-Host "`nChecking via SQL Query..." -ForegroundColor Yellow
    $Output2 = @()
    $SQL_Query = "SELECT ds.SoftwareName AS SoftwareName, 
                  ds.CollectionID,
                  ds.CollectionName,
                  ad.MachineName,
                  ad.UserName,
                  dbo.fn_GetAppState(ad.ComplianceState, ad.EnforcementState, cia.OfferTypeID, 1, ad.DesiredState, ad.IsApplicable) AS EnforcementState
                  FROM v_CollectionExpandedUserMembers  cm
                  INNER JOIN v_R_User  ud ON ud.ResourceID= cm.UserItemKey
                  INNER JOIN v_DeploymentSummary ds ON ds.CollectionID = cm.SiteID
                  LEFT JOIN v_AppIntentAssetData  ad ON ad.UserName = 'Domain\$UserID' AND ad.AssignmentID = ds.AssignmentID
                  INNER JOIN v_CIAssignment  cia ON cia.AssignmentID = ds.AssignmentID
                  WHERE ud.Unique_User_Name0 = 'Domain\$UserID' AND ds.FeatureType = 1
                  order by SoftwareName"

          $DB = 'CM_SS1'
      $Server = 'sccmserverdb'
       $Query = $SQL_Query
    $Instance = 'sccmserverdb'
    # Run SQl
    $QueryInvoke = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $DB  `
        -HostName $Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $Instance
ForEach ($Item in $QueryInvoke)
{
    If ($Item.CollectionName -match 'SDG*')
    {
        $Output2 += $Item.CollectionName + ' -- ' + $Item.SoftwareName
    }
}
$Output2 | Select -Unique
########################################
