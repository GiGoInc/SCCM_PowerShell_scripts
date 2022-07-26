<#
    It's assumed that the tech:
        ....is using a PowerShell install file named "install.ps1"
        ...created a folder named the same as "$SourceFolder" in \\sccmserver\PACKAGES
        ...populated that folder with the install contents

To Be Done
    Create piece to move Device Collection to correct subfolder in SCCM
#>


# User Input Variables
        $Appname = "Isaac Test App"
             $GN = "SDG-$Appname Users"
   $SourceFolder = "Isaac_Test_App"
$DetectionMethod = '(INSERT DETECTION METHOD SCRIPT HERE)'
      $DTRunTime = '5'
   $DTMaxRunTime = '20'
   $LimitingColl = "All Windows Workstation or Professional Systems (DC0)"
      $QDAppName = "%Isaac%Test%App%"
     $QDAVersion = "20"


####################################################################################################
# Load AD Module
    Import-Module ActiveDirectory


# New-CMApplication Static Variables
    $ADGPath = "OU=SCCM Deployment Groups,OU=Domain Groups,DC=Domain,DC=DOMAIN"

# Create User Group in AD
    New-ADGroup `
        -GroupScope Universal `
        -Name $GN `
        -Description $Appname `
        -Path $ADGPath
    Write-Host "Created AD Group: " -NoNewline
    Write-Host "$GN" -ForegroundColor Green

####################################################################################################
# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location SS1:
    CD SS1:

# Static Variables
    # DEVICE Collection - New-CMDeviceCollection Static Variables
        $DCollName = "SCOrch - $Appname"
        $DSchedule = New-CMSchedule -Start "$(get-date -format MM/dd/yyy) 12:00 AM" -RecurCount 1 -RecurInterval Days
        $Comments = "Created automagically by PowerShell on $(get-date -format MM/dd/yyy)"
        $SCOrchFolder = '[SCOrch Installs]'

     # DEVICE Collection Query-based Membership - Add-CMDeviceCollectionQueryMembershipRule Static Variables
        $DQuery = 'select SMS_R_SYSTEM.ResourceID,
                SMS_R_SYSTEM.ResourceType,
                SMS_R_SYSTEM.Name,
                SMS_R_SYSTEM.SMSUniqueIdentifier,
                SMS_R_SYSTEM.ResourceDomainORWorkgroup,
                SMS_R_SYSTEM.Client
                from SMS_R_System
                inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId
                where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like "'+ "$QDAppName"+ '" and SMS_G_System_ADD_REMOVE_PROGRAMS.Version <= "'+"$QDAVersion"+'"'


    # USER Collection - New-CMUserCollection Static Variables
        $UserLimitingColl = "All Users and User Groups"
        $USchedule = New-CMSchedule -Start "$(get-date -format MM/dd/yyy) 12:00 AM" -RecurCount 1 -RecurInterval Hours
        $Comments = "Created automagically by PowerShell on $(get-date -format MM/dd/yyy)"

    # USER Collection Query-based Membership - Add-CMUserCollectionQueryMembershipRule Static Variables
        $UQuery = 'select SMS_R_USER.ResourceID,
                SMS_R_USER.ResourceType,
                SMS_R_USER.Name,
                SMS_R_USER.UniqueUserName,
                SMS_R_USER.WindowsNTDomain
                from SMS_R_User
                where SMS_R_User.SecurityGroupName = "Domain\\'+$GN+'"'


    # APPLICATION - New-CMApplication Static Variables
        $AutoInstallApp = $True
        $DisplaySupersedenceInApplicationCatalog = $False
        $RightNow = $(get-date)
        $AppDesc = "Automated Install from PowerShell"
        $DPGroup = "All DP's"


    # APPLICATION DeploymentType - Add-CMScriptDeploymentType Static Variables
        $SourceLocation = "\\sccmserver\Packages\$SourceFolder"
        $DeploymentTypeName = 'Install'
        $DTInstall = "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File .\install.ps1"
        $UninstallDT = "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File .\install.ps1"


    # DEPLOYMENT for DEVICE Collection
        $ADate = $(Get-Date -Format yyyy/MM/dd)
        $ATime = $(Get-Date -Format HH:mm)
        $DDate = $(Get-Date -Format yyyy/MM/dd) + " " + $(Get-Date -Format HH:mm)
        $DAction = "Install"
    	$DComm = "Deployment from POWERSHELL of $AppName to $DCollName"


    # DEPLOYMENT for USER Collection
    	$UComm = "Deployment from POWERSHELL of $AppName to $UCollName"


####################################################################################################
# DEVICE Collection
    New-CMDeviceCollection `
        -Name $DCollName `
        -LimitingCollectionName $LimitingColl `
        -RefreshSchedule $DSchedule `
        -RefreshType Both `
        -Comment $Comments
    Write-Host ""
    Write-Host "Created SCCM DEVICE Collection named: " -NoNewline
    Write-Host "$DCollName" -ForegroundColor Green

$DCollID = (Get-CMCollection -CollectionType Device -Name $DCollName).CollectionID

# 16777220  DeviceCollection\[SCOrch Installs]
# 16777532  DeviceCollection\TEST_Isaac
[Array]$DeviceCollectionID = $DCollID
$TargetFolderID = 16777220 # [SCOrch Installs]
$CurrentFolderID = 0
$ObjectTypeID = 5000
Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList $CurrentFolderID,$DeviceCollectionID,$ObjectTypeID,$TargetFolderID -ComputerName sccmserver -Namespace ROOT\SMS\site_SS1
    Write-Host ""
    Write-Host "Moved " -NoNewline
    Write-Host "$DCollName " -NoNewline -ForegroundColor Green
    Write-Host "to folder " -NoNewline
    Write-Host "[SCOrch Installs]" -ForegroundColor Red

# DEVICE Collection Query-based Membership
Add-CMDeviceCollectionQueryMembershipRule `
        -CollectionId $DCollID `
        -QueryExpression $DQuery `
        -RuleName "$Appname Users"
    Write-Host ""
    Write-Host "Created SCCM query named: " -NoNewline
    Write-Host "$Appname Users " -ForegroundColor Green -NoNewline
    Write-Host "for " -NoNewline
    Write-Host "DEVICE COLLECTION " -ForegroundColor Red -NoNewline
    Write-Host "named " -NoNewline
    Write-Host "$DCollName" -ForegroundColor Green

####################################################################################################
# USER Collection
New-CMUserCollection `
        -LimitingCollectionName $UserLimitingColl `
        -Name $GN `
        -Comment $Comments `
        -RefreshSchedule $USchedule `
        -RefreshType Both
    Write-Host ""
    Write-Host "Created SCCM USER Collection named: " -NoNewline
    Write-Host "$GN" -ForegroundColor Green

$UCollID = (Get-CMCollection -CollectionType User -Name $GN).CollectionID


# 16777477  UserCollection\[Software Distribution]
# 16777458  UserCollection\[Software Distribution]\Active Directory Software Groups
# 16777533  UserCollection\TEST_Isaac
[Array]$UserCollectionID = $UCollID
$TargetFolderID = 16777458 # [Software Distribution]
$CurrentFolderID = 0
$ObjectTypeID = 5001
Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList $CurrentFolderID,$UserCollectionID,$ObjectTypeID,$TargetFolderID -ComputerName sccmserver -Namespace ROOT\SMS\site_SS1
    Write-Host ""
    Write-Host "Moved " -NoNewline
    Write-Host "$GN " -NoNewline -ForegroundColor Green
    Write-Host "to folder " -NoNewline
    Write-Host "Active Directory Software Groups" -ForegroundColor Red


# USER Collection Query-based Membership
Add-CMUserCollectionQueryMembershipRule `
        -CollectionId $UCollID `
        -QueryExpression $UQuery `
        -RuleName "$Appname Users"
    Write-Host ""
    Write-Host "Created SCCM query named: " -NoNewline
    Write-Host "$Appname Users " -ForegroundColor Green -NoNewline
    Write-Host "for " -NoNewline
    Write-Host "USER COLLECTION " -ForegroundColor Red -NoNewline
    Write-Host "named " -NoNewline
    Write-Host "$GN" -ForegroundColor Green

####################################################################################################
# APPLICATION
New-CMApplication `
        -Name $Appname `
        -AutoInstall $True `
        -Description $AppDesc `
        -DisplaySupersedenceInApplicationCatalog $False `
        -ReleaseDate $RightNow
    Write-Host ""
    Write-Host "Created SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green

# APPLICATION
Set-CMApplication `
        -Name $Appname `
        -DistributionPointSetting AutoDownload `
        -SendToProtectedDistributionPoint $True
    Write-Host ""
    Write-Host "Modified SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green

# APPLICATION DeploymentType
Add-CMScriptDeploymentType `
        -ApplicationName $Appname `
        -DeploymentTypeName $DeploymentTypeName `
        -InstallCommand $DTInstall `
        -ScriptLanguage PowerShell `
        -ScriptText $DetectionMethod `
        -ContentFallback `
        -ContentLocation $SourceLocation `
        -EstimatedRuntimeMins $DTRunTime `
        -LogonRequirementType WhereOrNotUserLoggedOn `
        -MaximumRuntimeMins $DTMaxRunTime `
        -SlowNetworkDeploymentMode Download `
        -UninstallCommand $UninstallDT `
        -UserInteractionMode Hidden
    Write-Host ""
    Write-Host "Created Application DeploymentType named: " -NoNewline
    Write-Host "$DeploymentTypeName " -ForegroundColor Green -NoNewline
    Write-Host "for Application named " -NoNewline
    Write-Host "$Appname " -ForegroundColor Red

# APPLICATION Content Distribution
    Start-CMContentDistribution -ApplicationName $Appname -DistributionPointGroupName $DPGroup
    Write-Host ""
    Write-Host "Created Application Content Distribution for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green -NoNewline
    Write-Host "to Distribution Point: " -NoNewline
    Write-Host "$DPGroup " -ForegroundColor Red


####################################################################################################
# DEPLOYMENT DEVICE Collection
    $DDeploymentHash = @{
		                CollectionName = $DCollName
		                Name = $AppName
		                AvailableDateTime = $DDate
		                Comment = $DComm
		                DeadlineDate = [DateTime]$DDate
		                DeployAction = "Install"
		                DeployPurpose = "Required"
		                EnableMomAlert = $False
		                OverrideServiceWindow = $False
		                PreDeploy = $True
		                RebootOutsideServiceWindow = $False
		                SendWakeupPacket = $True
		                TimeBaseOn = "LocalTime"
		                UseMeteredNetwork = $True
		                UserNotification = "HideAll"
                        }
    Start-CMApplicationDeployment @DDeploymentHash
    Write-Host ""
    Write-Host "Created Application Deployment for: " -NoNewline
    Write-Host "$AppName " -ForegroundColor Green -NoNewline
    Write-Host "for DEVICE Collection named " -NoNewline
    Write-Host "$DCollName " -ForegroundColor Red

####################################################################################################
# DEPLOYMENT USER Collection
    $UDeploymentHash = @{
                        CollectionName = $GN
                        Name = $Appname
                        ApprovalRequired = $False
		                AvailableDateTime = $DDate
                        Comment = $Comm
                        DeployAction = "Install"
                        DeployPurpose = "Available"
                        TimeBaseOn = "LocalTime"
                        UserNotification = "DisplayAll"
                        }
    Start-CMApplicationDeployment @UDeploymentHash
    Write-Host ""
    Write-Host "Created Application Deployment for: " -NoNewline
    Write-Host "$AppName " -ForegroundColor Green -NoNewline
    Write-Host "for USER Collection named " -NoNewline
    Write-Host "$GN " -ForegroundColor Red


####################################################################################################
# Recap
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "So this just happened, in case you missed it...."
    Write-Host ""
    Write-Host "Created AD Group: " -NoNewline
    Write-Host "$GN" -ForegroundColor Green
    Write-Host ""
    Write-Host "Created SCCM DEVICE Collection named: " -NoNewline
    Write-Host "$DCollName" -ForegroundColor Green
    Write-Host "Moved " -NoNewline
    Write-Host "$DCollName " -NoNewline -ForegroundColor Green
    Write-Host "to folder " -NoNewline
    Write-Host "[SCOrch Installs]" -ForegroundColor Red
    Write-Host "Created SCCM query named: " -NoNewline
    Write-Host "$Appname Users " -ForegroundColor Green -NoNewline
    Write-Host "for " -NoNewline
    Write-Host "DEVICE COLLECTION " -ForegroundColor Red -NoNewline
    Write-Host "named " -NoNewline
    Write-Host "$DCollName" -ForegroundColor Green
    Write-Host ""
    Write-Host ""
    Write-Host "Created SCCM USER Collection named: " -NoNewline
    Write-Host "$GN" -ForegroundColor Green
    Write-Host "Moved " -NoNewline
    Write-Host "$GN " -NoNewline -ForegroundColor Green
    Write-Host "to folder " -NoNewline
    Write-Host "Active Directory Software Groups" -ForegroundColor Red
    Write-Host "Created SCCM query named: " -NoNewline
    Write-Host "$Appname Users " -ForegroundColor Green -NoNewline
    Write-Host "for " -NoNewline
    Write-Host "USER COLLECTION " -ForegroundColor Red -NoNewline
    Write-Host "named " -NoNewline
    Write-Host "$GN" -ForegroundColor Green
    Write-Host ""
    Write-Host "Created SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
    Write-Host "Modified SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
    Write-Host ""
    Write-Host "Created Application DeploymentType named: " -NoNewline
    Write-Host "$DeploymentTypeName " -ForegroundColor Green -NoNewline
    Write-Host "for Application named " -NoNewline
    Write-Host "$Appname " -ForegroundColor Red
    Write-Host "Created Application Content Distribution for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green -NoNewline
    Write-Host "to Distribution Point: " -NoNewline
    Write-Host "$DPGroup " -ForegroundColor Red
    Write-Host ""
    Write-Host "Created Application Deployment for: " -NoNewline
    Write-Host "$AppName " -ForegroundColor Green -NoNewline
    Write-Host "for DEVICE Collection named " -NoNewline
    Write-Host "$DCollName " -ForegroundColor Red
    Write-Host "Created Application Deployment for: " -NoNewline
    Write-Host "$AppName " -ForegroundColor Green -NoNewline
    Write-Host "for USER Collection named " -NoNewline
    Write-Host "$GN " -ForegroundColor Red