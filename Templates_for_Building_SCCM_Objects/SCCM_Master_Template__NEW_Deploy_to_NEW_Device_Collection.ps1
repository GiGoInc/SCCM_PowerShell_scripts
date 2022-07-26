<#
.Synopsis
This script is intended to build the AD-Groups,  by another script with a list of machine names, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,BPApplID String

.Example
PS C:\> .\Read_Bankpro--bsub.ps1 -computer 'Computer1'
	Computer1,Yes,	BPApplID="XAMS1"


    It's assumed that the tech:
        ....is using a PowerShell install file named "install.ps1"
        ...created a folder named the same as "$SourceFolder" in \\sccmserver\PACKAGES
        ...populated that folder with the install contents

To Be Done
    Create piece to move Device Collection to correct subfolder in SCCM
#>
        $Appname = Read-Host -Prompt 'Application Name'
   $SourceFolder = Read-Host -Prompt 'Source folder name, like "Image Center 2016".'
 $SourceLocation = "\\sccmserver\Packages\$SourceFolder"
      $DTRunTime = Read-Host -Prompt 'Approximate runtime for application install (minutes)'
   $DTMaxRunTime = Read-Host -Prompt 'Maximum runtime for application install (minutes)'

    ######################################################################################
    #SUPER AWESOME GRAPHICAL DATE PICKER - GO!
    ######################################################################################
    ### AVAILABLE DATE
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $form = New-Object Windows.Forms.Form 
        $form.Text = "Select Date"
        $Font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Bold)
        # Font styles are: Regular, Bold, Italic, Underline, Strikeout
        $Form.Font = $Font
        $form.Size = New-Object Drawing.Size @(280,280) 
        $form.StartPosition = "CenterScreen"
        $titleText = New-Object Windows.Forms.Label
        $titleText.Height = 280
        $titleText.Width = 10
        $titleText.AutoSize = $true
        $titleText.Text = "Choose AVAILABLE date:"
        $form.Controls.Add($titleText)
        $Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
        $Form.Icon = $Icon
        $calendar = New-Object System.Windows.Forms.MonthCalendar
        $calendar.Location = New-Object System.Drawing.Point(16,23)
        $calendar.ShowTodayCircle = $False
        $calendar.MaxSelectionCount = 1
        $form.Controls.Add($calendar)
        $OKButton = New-Object System.Windows.Forms.Button
        $OKButton.Location = New-Object System.Drawing.Point(38,188)
        $OKButton.Size = New-Object System.Drawing.Size(75,23)
        $OKButton.Text = "OK"
        $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $OKButton
        $form.Controls.Add($OKButton)
        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Point(113,188)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $CancelButton
        $form.Controls.Add($CancelButton)
        # $form.Topmost = $True
        $result = $form.ShowDialog() 
        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $date = $calendar.SelectionStart
            [DateTime]$Time = "7:00:00 PM"
            $ADate = $Date.ToString("yyyy/MM/dd")
            $ATime = $Time.ToString("HH:mm")
        }
    ######################################################################################
    ### DEADLINE DATE
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            $form = New-Object Windows.Forms.Form 
            $form.Text = "Select Date"
            $Font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Bold)
            # Font styles are: Regular, Bold, Italic, Underline, Strikeout
            $Form.Font = $Font
            $form.Size = New-Object Drawing.Size @(280,280) 
            $form.StartPosition = "CenterScreen"
            $titleText = New-Object Windows.Forms.Label
            $titleText.Height = 280
            $titleText.Width = 10
            $titleText.AutoSize = $true
            $titleText.Text = "Choose date for enforcement:"
            $form.Controls.Add($titleText)
            $Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
            $Form.Icon = $Icon
            $calendar = New-Object System.Windows.Forms.MonthCalendar
            $calendar.Location = New-Object System.Drawing.Point(16,23)
            $calendar.ShowTodayCircle = $False
            $calendar.MaxSelectionCount = 1
            $form.Controls.Add($calendar)
            $OKButton = New-Object System.Windows.Forms.Button
            $OKButton.Location = New-Object System.Drawing.Point(38,188)
            $OKButton.Size = New-Object System.Drawing.Size(75,23)
            $OKButton.Text = "OK"
            $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.AcceptButton = $OKButton
            $form.Controls.Add($OKButton)
            $CancelButton = New-Object System.Windows.Forms.Button
            $CancelButton.Location = New-Object System.Drawing.Point(113,188)
            $CancelButton.Size = New-Object System.Drawing.Size(75,23)
            $CancelButton.Text = "Cancel"
            $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton = $CancelButton
            $form.Controls.Add($CancelButton)           
            $result = $form.ShowDialog() 
            
            if ($result -eq [System.Windows.Forms.DialogResult]::OK)
            {
                $date = $calendar.SelectionStart
                [DateTime]$Time = "7:00:00 PM"
                $DDate = $Date.ToString("yyyy/MM/dd") + " " + $Time.ToString("HH:mm")
            }
    # DEPLOYMENT for DEVICE Collection
    Write-Host ""
    Write-Host "Available Date and Time is: $ADate $ATime"
    Write-Host "Deadline DateTime is: $DDate"
        $DAction = "Install"
    	$DComm = "Deployment from POWERSHELL of $AppName to $DCollName"


# Sanity Check
cls
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "Based on the information you put in...."
Write-Host ""
Write-Host "You want to create an application named `"" -NoNewline
Write-Host "$Appname" -ForegroundColor Green -NoNewline
Write-Host "`"..."
Write-Host ""
Write-Host "You want it be available on " -NoNewline
Write-Host "$ADate $ATime " -ForegroundColor Green -NoNewline
Write-Host "and you want the be enforced on " -NoNewline
Write-Host "$DDate" -ForegroundColor Green -NoNewline
Write-Host "..."
Write-Host ""
Write-Host "You estimate the install will take " -NoNewline
Write-Host "$DTRunTime " -ForegroundColor Green -NoNewline
Write-Host "minutes to install and should only be allowed to run for " -NoNewline
Write-Host "$DTMaxRunTime " -ForegroundColor Green -NoNewline
Write-Host "minutes..."
Write-Host ""
Write-Host "And you have already copied the installation files to " -NoNewline
Write-Host "$SourceLocation" -ForegroundColor Green -NoNewline
Write-Host "`"?"
Write-Host ""
$DoIt = Read-Host "Is all that information correct and do you want to proceed? [Y/N]"
If($DoIt -ne "Y")
{
	break
}


If (!(Test-Path $SourceLocation))
{
    Write-Host ""
    Write-Host "############################################################" -ForegroundColor Red
    Write-Host ""
    Write-Host "STOP! " -ForegroundColor Red
    Write-Host ""
    Write-Host "I pity the fool who doesn't realize: " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Sourcefolder doesn't exist: $SourceLocation"
    Write-Host ""
    break
}


# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location SS1:
    CD SS1:



####################################################################################################
# Static Variables
    $LimitingColl = "All Windows Workstation or Professional Systems (DC0)"
       # $QDAppName = '%'+$Appname.Replace(' ','%')+'%'

    # DEVICE Collection - New-CMDeviceCollection Static Variables
        $DCollName = "SCOrch - $Appname"
        $DSchedule = New-CMSchedule -Start "$(get-date -format MM/dd/yyy) 12:00 AM" -RecurCount 1 -RecurInterval Days
        $Comments = "Created automagically by PowerShell on $(get-date -format MM/dd/yyy)"
        # $SCOrchFolder = '[SCOrch Installs]'

    # APPLICATION - New-CMApplication Static Variables
        $AutoInstallApp = $True
        $DisplaySupersedenceInApplicationCatalog = $False
        $RightNow = $(get-date)
        $AppDesc = "Automated Install from PowerShell"
        $DPGroup = "All DP's"

    # APPLICATION DeploymentType - Add-CMScriptDeploymentType Static Variables
        $DeploymentTypeName = 'Install'
        $DTInstall = "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File .\install.ps1"
        $UninstallDT = "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File .\Uninstall.ps1"


####################################################################################################
# Check for Existing Objects
$z = Get-CMApplication -Name $appname
$y = Get-CMCollection -Name $DCollName

If ($z -ne $null)
{
    Write-Host ""
    Write-Host "############################################################" -ForegroundColor Red
    Write-Host ""
    Write-Host "Congratulations! You messed up!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Application already exists: `"" -NoNewline
    Write-Host "$appname" -ForegroundColor Red -NoNewline
    Write-Host "`"."
    Write-Host ""
    break
}

If ($y -ne $null)
{
    Write-Host ""
    Write-Host "############################################################" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ummmmmm....you got a problem!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Collection already exists: $DCollName"
    Write-Host ""
    break
}



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

# # 16777220  DeviceCollection\[SCOrch Installs]
# # 16777532  DeviceCollection\TEST_Isaac
# [Array]$DeviceCollectionID = $DCollID
# $TargetFolderID = 16777220 # [SCOrch Installs]
# $CurrentFolderID = 0
# $ObjectTypeID = 5000
# Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList $CurrentFolderID,$DeviceCollectionID,$ObjectTypeID,$TargetFolderID -ComputerName sccmserver -Namespace ROOT\SMS\site_SS1
#     Write-Host ""
#     Write-Host "Moved " -NoNewline
#     Write-Host "$DCollName " -NoNewline -ForegroundColor Green
#     Write-Host "to folder " -NoNewline
#     Write-Host "[SCOrch Installs]" -ForegroundColor Red

<#
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
#>


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
# Recap
    Write-Host ""
    Write-Host ""
    Write-Host "############################################################" -ForegroundColor Green
    Write-Host ""
    Write-Host "So this just happened, in case you missed it...."
    Write-Host ""
    Write-Host ""
    Write-Host "Created SCCM DEVICE Collection named `"" -NoNewline
    Write-Host "$DCollName" -ForegroundColor Green -NoNewline
    Write-Host "`""
    Write-Host ""
    Write-Host "Created and modified SCCM Application named: `"" -NoNewline
    Write-Host "$Appname" -ForegroundColor Green -NoNewline
    Write-Host "`"."
    Write-Host ""
    Write-Host "Created a DeploymentType named `"" -NoNewline
    Write-Host "$DeploymentTypeName" -ForegroundColor Green -NoNewline
    Write-Host "`" and Distributed content to `"" -NoNewline
    Write-Host "$DPGroup" -ForegroundColor Green -NoNewline
    Write-Host "`"."
    Write-Host ""
    Write-Host "Created Application Deployment for the Application to the Collection." -NoNewline
    Write-Host ""
    Write-Host ""
    Write-Host "############################################################" -ForegroundColor Green
    Write-Host ""
    Write-Host "Script completed!"
    Write-Host ""
    Write-Host "*** You will need to manually add members to the new Collection! ***" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "*** You will need to manually set the Application DeploymentType DetectionMethod! ***" -ForegroundColor Cyan
    Write-Host ""
    Start-Sleep -Seconds 6
    Write-Host "...feel free to automate the last two pieces."
    Start-Sleep -Seconds 3
    Write-Host ""
    Write-Host ""
    Write-Host "       POWERSHELL!!!" -ForegroundColor Red
    Write-Host ""



Write-Host ""
Read-Host -Prompt 'Press Enter to exit...'
