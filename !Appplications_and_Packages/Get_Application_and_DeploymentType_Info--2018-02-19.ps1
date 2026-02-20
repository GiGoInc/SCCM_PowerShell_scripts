cls
} else {Write-Host " oScope object Creation failed"; exit}
# Finish
cls
<#
2018-02-19 3pm -- Partially works. Testing script to find alternate (faster) output to Get-CMApplication



    #####################################################
    
     
    [string]$sSCCMServerName           = "SERVER"
    [string]$SMSSiteCode               = "XX1"
    [string]$sSCCMUsername             = "DOMAIN\SUPERUSER"
    [string]$sSCCMPassword             = "(PASSWORD)"
     
      
     
    #####################################################
    # Functions
     
    # WQLConnect
    # Purpose: To create a WQL query connection to an SCCM Server
    #          This will utilise credentials if script isn't being run on the server itself
    #
    function WQLConnect($Server, $User, $Password) {
     
      $namedValues              = New-Object Microsoft.ConfigurationManagement.ManagementProvider.SmsNamedValuesDictionary
      if ($namedValues -ne $null) { Write-Host " namedValues object Created"} else {Write-Host " namedValues object Creation failed"; exit}
     
      $connection               = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
      if ($connection  -ne $null) { Write-Host " connection  object Created"} else {Write-Host " connection  object Creation failed"; exit}
     
     
      # Connect with credentials if not running on the server itself
      if ($env:computername.ToUpper() -eq $Server.ToUpper()){
         Write-Host  "Local WQL Connection Made"
         [void]$connection.Connect($Server)
      }
      else
      {
         Write-Host  "Remote WQL Connection Made: " + $sSCCMServerName
         [void]$connection.Connect($Server, $User, $Password)
     
      }
      return $connection
     
    }
     
      
     
    #####################################################
    # Main
     
    #create connection to SCCMServer 
    $oServerConnection                       = WQLConnect $sSCCMServerName $sSCCMUsername $sSCCMPassword
#>


[string]$sSCCMServerName           = "SERVER"
[string]$SMSSiteCode               = "XX1"

$sPath  = [string]::Format("\\{0}\ROOT\sms\site_{1}", $sSCCMServerName, $SMSSiteCode)
$oScope = new-object System.Management.ManagementScope -ArgumentList $sPath
If ($oScope -ne $null)
{
    Write-Host " oScope object Created"
 
    $oQuery                      = new-object System.Management.ObjectQuery -ArgumentList ([string]"select * from sms_application where IsEnabled=1 and IsLatest=1")
    Write-Host "OQuery = $oQuery "
    $oManagementObjectSearcher   = new-object System.Management.ManagementObjectSearcher -ArgumentList $oScope,$oQuery
    $ResultsCollection           = $oManagementObjectSearcher.Get()    
    $ResultsCollectionEnumerator = $ResultsCollection.GetEnumerator()

    ForEach ($Result in $ResultsCollection)
    {
        $Result.Get()        
        
        [xml]$sdmPackageXml  = New-Object system.Xml.XmlDocument
             $sdmPackageXml.LoadXml($Result.Properties["SDMPackageXML"].Value)
        
        If (($Result.LocalizedDisplayName).Length -eq 0){$AppLocalizedDisplayName = 'N/A'} Else{ $AppLocalizedDisplayName = $Result.LocalizedDisplayName}
        If (($Result.CreatedBy).Length -eq 0){$AppCreatedBy = 'N/A'} Else{ $AppCreatedBy = $Result.CreatedBy}
        If (($Result.DateCreated).Length -eq 0){$AppDateCreated = 'N/A'} Else{ $AppDateCreated = $Result.DateCreated}
        If (($Result.DateLastModified).Length -eq 0){$AppDateLastModified = 'N/A'} Else{ $AppDateLastModified = $Result.DateLastModified}
        If (($Result.LastModifiedBy).Length -eq 0){$AppLastModifiedBy = 'N/A'} Else{ $AppLastModifiedBy = $Result.LastModifiedBy}
        If (($Result.LocalizedCategoryInstanceNames).Length -eq 0){$AppLocalizedCategoryInstanceNames = 'N/A'}Else{ $AppLocalizedCategoryInstanceNames = $Result.LocalizedCategoryInstanceNames}
        If (($Result.LocalizedDescription).Length -eq 0){$AppLocalizedDescription = 'N/A'} Else{ $AppLocalizedDescription = $Result.LocalizedDescription}
        If (($Result.Manufacturer).Length -eq 0){$AppManufacturer = 'N/A'} Else{ $AppManufacturer = $Result.Manufacturer}
        If (($Result.SDMPackageVersion).Length -eq 0){$AppSDMPackageVersion = 'N/A'} Else{ $AppSDMPackageVersion = $Result.SDMPackageVersion}
        If (($Result.SoftwareVersion).Length -eq 0){$AppSoftwareVersion = 'N/A'} Else{ $AppSoftwareVersion = $Result.SoftwareVersion}
        If ($sdmPackageXml.DisplayInfo.Icon.Data){$AppSoftwareIcon = 'Icon set'}Else{$AppSoftwareIcon = 'Icon not set'}



        # Write-Host "########"
        # Write-Host "LocalizedDisplayName       = " $Result.LocalizedDisplayName -ForegroundColor Green
        # Write-Host "PackageID                  = " $Result.PackageID -ForegroundColor Yellow
        # Write-Host "CI_ID                      = " $Result.CI_ID -ForegroundColor Cyan
        # Write-Host "SoftwareVersion            = " $Result.SoftwareVersion -ForegroundColor Magenta
        # Write-Host "Number of Deployment Types = " $Result.NumberOfDeploymentTypes -ForegroundColor Red

	    Write-Host ""
	    Write-Host "** Application Information ***`t" $AppLocalizedDisplayName -ForegroundColor Green
	    Write-Host "`tCreated By                 :`t" $AppCreatedBy -ForegroundColor Yellow
	    Write-Host "`tCreated Date               :`t" $AppDateCreated -ForegroundColor Cyan
	    Write-Host "`tModified Date              :`t" $AppDateLastModified -ForegroundColor Magenta
	    Write-Host "`tModified By                :`t" $AppLastModifiedBy -ForegroundColor Red
	    Write-Host "`tAdministrative Categories  :`t `"" $AppLocalizedCategoryInstanceNames "`"" -ForegroundColor Green
	    Write-Host "`tAdministrator Comments     :`t" $AppLocalizedDescription -ForegroundColor Yellow
	    Write-Host "`tPublisher                  :`t" $AppManufacturer -ForegroundColor Cyan
	    Write-Host "`tRevision                   :`t" $AppSDMPackageVersion -ForegroundColor Magenta
	    Write-Host "`tSoftware Version           :`t" $AppSoftwareVersion -ForegroundColor Red
	    Write-Host "`tSoftware Icon              :`t" $AppSoftwareIcon -ForegroundColor Yellow


        ForEach ($Node in $sdmPackageXml.AppMgmtDigest.DeploymentType)
        {
            Write-Host "   DT Name                 = " $node.LogicalName
        
		    If (($Node.Title).Length -eq 0){$DTTitle = 'N/A'}Else{$DTTitle = $Node.Title}
		    If ((($sdmPackageXml.Contacts).ID).Length -eq 0){$DTContacts = 'N/A'}Else{$DTContacts = ($sdmPackageXml.Contacts).ID}
		    If ((($sdmPackageXml.Owners).ID).Length -eq 0){$DTOwners = 'N/A'}Else{$DTOwners = ($sdmPackageXml.Owners).ID}
		    If (($sdmPackageXml.ReleaseDate).Length -eq 0){$DTReleaseDate = 'N/A'}Else{$DTReleaseDate = $sdmPackageXml.ReleaseDate}
		    If (($Node.Description).Length -eq 0){$DTDescription  =  'N/A'}Else{$DTDescription = $Node.Description}
		    If (($Node.Installer.InstallCommandLine).Length -eq 0){$DTInstallCommandLine  =  'N/A'}Else{$DTInstallCommandLine = $Node.Installer.InstallCommandLine}
		    If (($Node.Installer.UninstallCommandLine).Length -eq 0){$DTUninstallCommandLine  =  'N/A'}Else{$DTUninstallCommandLine = $Node.Installer.UninstallCommandLine}
	
            Write-Host "** DeploymentType Information ***`t"  $DTTitle -ForegroundColor Green
            Write-Host "`tDeploymentType Contacts                :`t" $DTContacts
            Write-Host "`tDeploymentType Owners                  :`t" $DTOwners
            Write-Host "`tDeploymentType ReleaseDate             :`t" $DTReleaseDate
            Write-Host "`tDeploymentType Description             :`t" $DTDescription
            Write-Host "`tDeploymentType Install Command Line    :`t" $DTInstallCommandLine
            Write-Host "`tDeploymentType Uninstall Command Line  :`t" $DTUninstallCommandLine


            ForEach ($requirement in $node.Requirements)
            {
                ForEach ($rule in $requirement.Rule)
                {
                    Write-Host "`tDeploymentType Rule  :`t" $requirement.Rule.Annotation.DisplayName.Text -ForegroundColor Gray
                }                  
            }
        }
        Write-Host ""
    }

 
############################################
# Finish
} else {Write-Host " oScope object Creation failed"; exit}
