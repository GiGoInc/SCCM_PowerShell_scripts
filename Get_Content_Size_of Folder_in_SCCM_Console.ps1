<#
GetFolderInfo -FolderName $FolderName -Server $server -SiteCode $SiteCode

<#
 
This script gets the total size of all the content files for each deployment type for each application in the console folder you specify.
 
#>
 
$Server = "SERVER"
$SiteCode = "XX1"

 
# import assemblies
[System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.ApplicationManagement.dll") | Out-Null
 
# Creating Type Accelerators
$accelerators = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$accelerators::Add('SccmSerializer',[type]'Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer')


Function GetFolderInfo ($FolderName,$Server,$SiteCode)
{ 
    # Get FolderID
    Write-Host "Getting FolderID of Console Folder '$FolderName'" -ForegroundColor Yellow
    $FolderID = Get-WmiObject -ComputerName $server -Namespace "ROOT\SMS\Site_$SiteCode" `
    -Query "select * from SMS_ObjectContainerNode where Name='$FolderName'" | Select ContainerNodeID
    $FolderID = $FolderID.ContainerNodeID
    Write-host "  $FolderID"
 
    # Get InstanceKey of Folder Members
    Write-Host "Getting Members of Folder" -ForegroundColor Yellow
    $FolderMembers =  Get-WmiObject -ComputerName $server -Namespace "ROOT\SMS\Site_$SiteCode" `
    -Query "select * from SMS_ObjectContainerItem where ContainerNodeID='$FolderID'" | Select * | Select InstanceKey
    $FolderMembers = $FolderMembers.InstanceKey
    write-host "  Found $($FolderMembers.Count) applications"
     
    # Get Application name of each Folder member
    write-host "Getting Application Names" -ForegroundColor Yellow
    $NameList = @()
    foreach ($foldermember in $foldermembers)
        {
            $Name =  Get-WmiObject -ComputerName $server -Namespace "ROOT\SMS\Site_$SiteCode" -Query "select Name from SMS_ObjectName where ObjectKey='$foldermember'" | Select -ExpandProperty Name
            $NameList += $Name
        }
    $namelist = $NameList | sort
     
    # Deserialize each SDMPackageXML property, and get the file size of each file in the contents for each deployment type
    $totalsize = 0
    foreach ($name in $namelist)
        {
            Write-Host "  Deserializing $name"
            $app = [wmi](gwmi -ComputerName $server -Namespace root\sms\Site_$SiteCode -class sms_application | ?{$_.LocalizedDisplayName -eq $Name -and $_.IsLatest -eq $true}).__Path
            $appXML = [SccmSerializer]::DeserializeFromString($app.SDMPackageXML,$true)
            $DTs = $appxml.DeploymentTypes
            foreach ($DT in $DTs)
                {
                    $sizes = $dt.Installer.Contents.Files.Size
                    foreach ($size in $sizes)
                        {$totalsize = $totalsize + $size}
                }
        }
     
    Write-Host "`nTotal Size of all content files for every application in the '$FolderName' folder is:" -NoNewline -ForegroundColor Red
    Write-Host "$(($totalsize / 1GB).ToString(".00")) GB`n" -ForegroundColor Green
}



$FolderName = "Drivers" # Applications\Default Apps


GetFolderInfo -FolderName $FolderName -Server $server -SiteCode $SiteCode
