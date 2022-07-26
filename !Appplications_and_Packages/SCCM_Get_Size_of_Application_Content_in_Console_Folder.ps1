<#
 
This script gets the total size of all the content files for each deployment type for each application in the console folder you specify.
 
#>
 
$server = "sccmsrv-01"
$SiteCode = "ABC"
$FolderName = "Non-Default Apps" # Applications\Default Apps
 
# import assemblies
[System.Reflection.Assembly]::LoadFrom(“C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.ApplicationManagement.dll”) | Out-Null
 
# Creating Type Accelerators
$accelerators = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$accelerators::Add('SccmSerializer', [type]'Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer')
 
# Get FolderID
Write-Host "Getting FolderID of Console Folder '$FolderName'"
$FolderID = Get-WmiObject -Namespace "ROOT\SMS\Site_$SiteCode" `
    -Query "select * from SMS_ObjectContainerNode where Name='$FolderName'" | Select ContainerNodeID
$FolderID = $FolderID.ContainerNodeID
Write-host "  $FolderID"
 
# Get InstanceKey of Folder Members
Write-Host "Getting Members of Folder"
$FolderMembers = Get-WmiObject -Namespace "ROOT\SMS\Site_$SiteCode" `
    -Query "select * from SMS_ObjectContainerItem where ContainerNodeID='$FolderID'" | Select * | Select InstanceKey
$FolderMembers = $FolderMembers.InstanceKey
write-host "  Found $($FolderMembers.Count) applications"
 
# Get Application name of each Folder member
write-host "Getting Application Names"
$NameList = @()
foreach ($foldermember in $foldermembers)
{
    $Name = Get-wmiobject -Namespace "ROOT\SMS\Site_$SiteCode" -Query "select Name from SMS_ObjectName where ObjectKey='$foldermember'" | Select -ExpandProperty Name
    $NameList += $Name
}
$namelist = $NameList | sort
 
# Deserialize each SDMPackageXML property, and get the file size of each file in the contents for each deployment type
$totalsize = 0
foreach ($name in $namelist)
{
    write-host "  Deserializing $name"
    $app = [wmi](gwmi -ComputerName $server -Namespace root\sms\site_$code -class sms_application | ? {$_.LocalizedDisplayName -eq $Name -and $_.IsLatest -eq $true}).__Path
    $appXML = [SccmSerializer]::DeserializeFromString($app.SDMPackageXML, $true)
    $DTs = $appxml.DeploymentTypes
    foreach ($DT in $DTs)
    {
        $sizes = $dt.Installer.Contents.Files.Size
        foreach ($size in $sizes)
        {$totalsize = $totalsize + $size}
    }
}
 
write-host "Total Size of all content files for every application in the '$FolderName' folder is:" -ForegroundColor Green
write-host "$(($totalsize / 1GB).ToString(".00")) GB" -ForegroundColor Green