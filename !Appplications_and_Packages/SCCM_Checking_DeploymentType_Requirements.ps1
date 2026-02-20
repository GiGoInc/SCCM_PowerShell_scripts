cls
# Finish
############################################
cls

#	#####################################################
#	
#	 
	[string]$sSCCMServerName           = "SERVER"
	[string]$SMSSiteCode               = "XX1"
#	[string]$sSCCMUsername             = "DOMAIN\SUPERUSER"
#	[string]$sSCCMPassword             = "(PASSWORD)"
#	 
#	  
#	 
#	#####################################################
#	# Functions
#	 
#	# WQLConnect
#	# Purpose: To create a WQL query connection to an SCCM Server
#	#          This will utilise credentials if script isn't being run on the server itself
#	#
#	function WQLConnect($Server, $User, $Password) {
#	 
#	  $namedValues              = New-Object Microsoft.ConfigurationManagement.ManagementProvider.SmsNamedValuesDictionary
#	  if ($namedValues -ne $null) { Write-Host " namedValues object Created"} else {Write-Host " namedValues object Creation failed"; exit}
#	 
#	  $connection               = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
#	  if ($connection  -ne $null) { Write-Host " connection  object Created"} else {Write-Host " connection  object Creation failed"; exit}
#	 
#	 
#	  # Connect with credentials if not running on the server itself
#	  if ($env:computername.ToUpper() -eq $Server.ToUpper()){
#	     Write-Host  "Local WQL Connection Made"
#	     [void]$connection.Connect($Server)
#	  }
#	  else
#	  {
#	     Write-Host  "Remote WQL Connection Made: " + $sSCCMServerName
#	     [void]$connection.Connect($Server, $User, $Password)
#	 
#	  }
#	  return $connection
#	 
#	}
#	 
#	  
#	 
#	#####################################################
#	# Main
#	 
#	#create connection to SCCMServer 
#	$oServerConnection                       = WQLConnect $sSCCMServerName $sSCCMUsername $sSCCMPassword

$sPath  = [string]::Format("\\{0}\ROOT\sms\site_{1}", $sSCCMServerName, $SMSSiteCode)
$oScope = new-object System.Management.ManagementScope -ArgumentList $sPath
if ($oScope -ne $null) { Write-Host " oScope object Created"} else {Write-Host " oScope object Creation failed"; exit}
 
$oQuery                      = new-object System.Management.ObjectQuery -ArgumentList ([string]"select * from sms_application where IsEnabled=1 and IsLatest=1")
Write-Host "OQuery = $oQuery "
$oManagementObjectSearcher   = new-object System.Management.ManagementObjectSearcher -ArgumentList $oScope,$oQuery
$ResultsCollection           = $oManagementObjectSearcher.Get()    
$ResultsCollectionEnumerator = $ResultsCollection.GetEnumerator()


 foreach ($Result in $ResultsCollection)
  {
        $Result.Get()        
 
        [xml]$sdmPackageXml  = New-Object system.Xml.XmlDocument
             $sdmPackageXml.LoadXml($Result.Properties["SDMPackageXML"].Value)

            Write-Host "########"
            Write-Host "LocalizedDisplayName       = " $Result.LocalizedDisplayName -ForegroundColor Green
            Write-Host "PackageID                  = " $Result.PackageID -ForegroundColor Yellow
            Write-Host "CI_ID                      = " $Result.CI_ID -ForegroundColor Cyan
            Write-Host "SoftwareVersion            = " $Result.SoftwareVersion -ForegroundColor Magenta
            Write-Host "Number of Deployment Types = " $Result.NumberOfDeploymentTypes -ForegroundColor Red

            foreach ($node in $sdmPackageXml.AppMgmtDigest.DeploymentType)
            {
               Write-Host "   DT Name                 = " $node.LogicalName

               foreach ($requirement in $node.Requirements)
               {
                 foreach ($rule in $requirement.Rule)
                 {
                     Write-Host "   Rule                    = " $requirement.Rule.Annotation.DisplayName.Text -ForegroundColor Gray
                  }                  
               }
            }
            Write-Host ""
    }

 
############################################
# Finish
