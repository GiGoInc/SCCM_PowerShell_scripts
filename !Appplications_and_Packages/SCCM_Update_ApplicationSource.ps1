[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
 
$SiteServer = "<name_of_your_Primary_Site_server>"
$SiteCode = "<your_site_code>"
$CurrentContentPath = "\\\\<name_of_server_where_the_content_was_stored_previously\\<folder>\\<folder>"
$UpdatedContentPath = "\\<name_of_the_server_where_the_content_is_stored_now\<folder>\<folder>"
 
$Applications = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -class SMS_Application | Where-Object {$_.IsLatest -eq $True}
$ApplicationCount = $Applications.Count
 
Write-Output ""
Write-Output "INFO: A total of $($ApplicationCount) applications will be modified`n"
Write-Output "INFO: Value of current content path: $($CurrentContentPath)"
Write-Output "INFO: Value of updated content path: $($UpdatedContentPath)`n"
Write-Output "# What would you like to do?"
Write-Output "# ---------------------------------------------------------------------"
Write-Output "# 1. Verify first - Verify the applications new path before updating"
Write-Output "# 2. Update now - Update the path on all applications"
Write-Output "# ---------------------------------------------------------------------`n"
$EnumAnswer = Read-Host "Please enter your selection [1,2] and press Enter"
 
switch ($EnumAnswer) {
    1 {$SetEnumAnswer = "Verify"}
    2 {$SetEnumAnswer = "Update"}
    Default {$SetEnumAnswer = "Verify"}
}
 
if ($SetEnumAnswer -like "Verify") {
    Write-Output ""
    $Applications | ForEach-Object {
        $CheckApplication = [wmi]$_.__PATH
        $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($CheckApplication.SDMPackageXML,$True)
        foreach ($CheckDeploymentType in $CheckApplicationXML.DeploymentTypes) {
            $CheckInstaller = $CheckDeploymentType.Installer
            $CheckContents = $CheckInstaller.Contents[0]
            $CheckUpdatedPath = $CheckContents.Location -replace "$($CurrentContentPath)","$($UpdatedContentPath)"
            Write-Output "INFO: Current content path for $($_.LocalizedDisplayName):"
            Write-Output -ForegroundColor Green "$($CheckContents.Location)"
            Write-Output "UPDATE: Updated content path will be:"
            Write-Output -ForegroundColor Red "$($CheckUpdatedPath)`n"
        }
    }
}
 
if ($SetEnumAnswer -like "Update") {
    Write-Output ""
    $Applications | ForEach-Object {
        $Application = [wmi]$_.__PATH
        $ApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($Application.SDMPackageXML,$True)
        foreach ($DeploymentType in $ApplicationXML.DeploymentTypes) {
            $Installer = $DeploymentType.Installer
            $Contents = $Installer.Contents[0]
            $UpdatePath = $Contents.Location -replace "$($CurrentContentPath)","$($UpdatedContentPath)"
            if ($UpdatePath -ne $Contents.Location) {
                $UpdateContent = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentImporter]::CreateContentFromFolder($UpdatePath)
                $UpdateContent.FallbackToUnprotectedDP = $True
                $UpdateContent.OnFastNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
                $UpdateContent.OnSlowNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::DoNothing
                $UpdateContent.PeerCache = $False
                $UpdateContent.PinOnClient = $False
                $Installer.Contents[0].ID = $UpdateContent.ID
                $Installer.Contents[0] = $UpdateContent
            }
        }
        $UpdatedXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToString($ApplicationXML, $True)
        $Application.SDMPackageXML = $UpdatedXML
        $Application.Put() | Out-Null
        Write-Output "INFO: Updated content path for $($_.LocalizedDisplayName)"
    }
}




<Installer Technology="MSI"><ExecutionContext>System</ExecutionContext>
	<Contents>
		<Content ContentId="Content_ac2238bd-aa93-4309-87b2-7b90f0d82983" Version="1">
		<File Name="CitrixReceiver.exe" Size="28735896"/>
		<File Name="Install.bat" Size="466"/>
		<Location>\\SCCMSERVER\Packages\Citrix\CitrixReceiver\</Location>
		<PeerCache>true</PeerCache>
		<OnFastNetwork>Download</OnFastNetwork>
		<OnSlowNetwork>Download</OnSlowNetwork>
		</Content>
	</Contents>
	
<Requirements>
	<Rule xmlns="http://schemas.microsoft.com/SystemsCenterConfigurationManager/2009/06/14/Rules" id="Rule_8b1d97cd-091a-4a55-aece-7b240fdc3bfe" Severity="None" NonCompliantWhenSettingIsNotFound="false">
	<Annotation>
		<DisplayName Text="Operating system One of {Windows XP SP3 (32-bit), All Windows 7 (64-bit), All Windows 7 (32-bit), Windows 7 (64-bit), Windows 7 SP1 (64-bit), Windows 7 (32-bit), Windows 7 SP1 (32-bit), All Windows 8 (64-bit), All Windows 8 (32-bit), All Windows 8.1 (64-bit), All Windows 8.1 (32-bit)}"/>
	<Description Text=""/>
	</Annotation>
	<OperatingSystemExpression>
	<Operator>OneOf</Operator>
	<Operands>
		<RuleExpression RuleId="Windows/x86_Windows_XP_Professional_Service_Pack_3"/>
		<RuleExpression RuleId="Windows/All_x64_Windows_7_Client"/>
		<RuleExpression RuleId="Windows/All_x86_Windows_7_Client"/>
		<RuleExpression RuleId="Windows/x64_Windows_7_Client"/>
		<RuleExpression RuleId="Windows/x64_Windows_7_SP1"/>
		<RuleExpression RuleId="Windows/x86_Windows_7_Client"/>
		<RuleExpression RuleId="Windows/x86_Windows_7_SP1"/>
		<RuleExpression RuleId="Windows/All_x64_Windows_8_Client"/>
		<RuleExpression RuleId="Windows/All_x86_Windows_8_Client"/>
		<RuleExpression RuleId="Windows/All_x64_Windows_8.1_Client"/>
		<RuleExpression RuleId="Windows/All_x86_Windows_8.1_Client"/>
	</Operands>
	</OperatingSystemExpression>
	</Rule>
</Requirements>