Function Retire-CMApplication
{
    [CmdletBinding()]
    param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $RetiringApps = @()
    )

    # for each provided app name, remove deployments, rename, and retire
    foreach ($app in $RetiringApps)
    {
        if ($RetiringApp = Get-CMApplication -Name $app)
        {
            Write-Host "So long, $app!`n"

    # checking retired status, setting to active so that we can make changes
            if ($RetiringApp.IsExpired)
            {
                $appWMI = gwmi -ComputerName 'sccm1' -Namespace Root\SMS\Site_SS1 -class SMS_ApplicationLatest -Filter "LocalizedDisplayName = '$app'"
                $appWMI.SetIsExpired($false) | Out-Null
                Write-Host "Setting Status of $app to Active so that changes can be made.`n"
            }
    
            $oldDeploys = Get-CMDeployment -SoftwareName $RetiringApp.LocalizedDisplayName
    
    # remove all deployments for the app
            if ($oldDeploys)
            {
                $oldDeploys | ForEach-Object {Remove-CMDeployment -ApplicationName $app -DeploymentId $_.DeploymentID -Force}
                Write-Host "Removed $($oldDeploys.Count) deployments of $app.`n"
            }
    
    # remove content from all dp's and dpg's
            Write-Host "Removing content from all distribution points"
            $DPs = Get-CMDistributionPoint
            foreach ($DP in $DPs)
            {
                Write-Host "."
                try
                {
                    Remove-CMContentDistribution -Application $RetiringApp -DistributionPointName ($DP).NetworkOSPath -Force -EA SilentlyContinue
                }
                catch
                { }
            }
            Write-Host "`n"
            Write-Host "Removing content from all distribution point groups"
            $DPGs = Get-CMDistributionPointGroup
            foreach ($DPG in $DPGs)
            {
                Write-Host "."
                try
                {
                    Remove-CMContentDistribution -Application $RetiringApp -DistributionPointGroupName ($DPG).Name -Force -EA SilentlyContinue
                }
                catch
                { }
            }
            Write-Host "`n"
    
    # rename the app
            #$app = $app.Replace('Retired-', '')
            #try
            #{
            #    Set-CMApplication -Name $app -NewName "Retired-$app"
            #}
            #catch
            #{ }
            #Write-Host "Renamed to Retired-$app.`n"
    
    # move the app according to category
            #if ($RetiringApp.LocalizedCategoryInstanceNames -eq "Mac")
            #{
            #    Move-CMObject -FolderPath "Applications\Retired" -InputObject $RetiringApp
            #    Write-Host "Moved to Mac\Retired Applications.`n"
            #}
            #else
            #{
            #    Move-CMObject -FolderPath "Application\Retired" -InputObject $RetiringApp
            #    Write-Host "Moved to Retired.`n"
            #}
    
            # # retire the app
            #if (!$RetiringApp.IsExpired)
            #{
            #    #$appWMI = gwmi -ComputerName 'sccm1' -Namespace Root\SMS\Site_SS1 -class SMS_ApplicationLatest -Filter "LocalizedDisplayName = 'Retired-$app'"
            #    $appWMI = gwmi -ComputerName 'sccm1' -Namespace Root\SMS\Site_SS1 -class SMS_ApplicationLatest -Filter "LocalizedDisplayName = '$app'"
            #    $appWMI.SetIsExpired($true) | Out-Null
            #    Write-Host "Set status to Retired.`n"
            #}
            #else
            #{
            #    Write-Host "Status was already set to Retired.`n"
            #}
            #>

    # rename the app
        try
        {
            Set-CMApplication -Name $app -NewName "Retired-$app"
            $app = 'Retired-' + $app
            Write-Host "Renamed to Retired-$app." -ForegroundColor Green
        }
        catch
        { }

    # retire the app
        $appWMI = gwmi -ComputerName 'sccm1' -Namespace Root\SMS\Site_SS1 -class SMS_ApplicationLatest -Filter "LocalizedDisplayName = '$app'"
        $appWMI.SetIsExpired($true) | Out-Null
        Write-Host "Set status to Retired.`n" -ForegroundColor Green

    # return source files location
            $xml = [xml]$RetiringApp.SDMPackageXML
            $loc = $xml.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location
			foreach ($location in $Loc)
			{
				Write-Host "Don't forget to delete the source files from '$location'.`n"
			}	
        }
        else
        {
            Write-Host "$app was not found. No actions performed.`n"
        }
    }
}

Function Get_AppSources
{
    [CmdletBinding()]
    param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $RetiringApps = @()
    )

    # for each provided app name, remove deployments, rename, and retire
    foreach ($app in $RetiringApps)
    {
        if ($RetiringApp = Get-CMApplication -Name $app)
        {
            # return source files location
            $xml = [xml]$RetiringApp.SDMPackageXML
            $loc = $xml.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location
			foreach ($location in $Loc)
			{
				Write-Host "$App`t$location"
			}	
        }
        else
        {
            Write-Host "$app was not found. No actions performed"
        }
    }
}

########################################################################################################################################################
try
{
# make sure we have access to CM commands before we continue
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" -ErrorAction Stop
Create-UtilityForm
}
catch
{
[System.Windows.Forms.MessageBox]::Show("Failed to set CM site drive. Are you sure you are running this from SCCM01 and the console is up to date?" , "Fail!")
}
########################################################################################################################################################

# Retire-CMApplication -RetiringApps 'Attachmate EXTRA X-treme 9.1 - Host Sessions','Firefox x64','Internet Explorer 11','Internet Explorer 8 for Windows Server 2003','MS Streets and Trips 2013','Mitel Contact Center Solutions Client Component Pack','Morning Check Tools','NTABL - Stucky client','Online Banking Solution Encrypted Keyboard Driver','Oracle Crystal Ball','PERFORM.360','Pervasive PSQL v11 Client','Retired-AMS 360 Client Rev 4','Retired-CRA Interactive Geocoder Hotfix','Retired-McAfee FramePackage Agent','Retired-zoom','SharePoint Designer','Sharepoint printer fix','TestNow'

###################################################

$AppNames = Get-CMApplication | select LocalizedDisplayName
Get_AppSources -RetiringApps $AppNames.LocalizedDisplayName

###################################################