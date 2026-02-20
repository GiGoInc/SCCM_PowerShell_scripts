<#
# $SiteServer = 'SERVER'
# $SiteCode = 'XX1'
<#
Object 						Class 								Property
Application 				SMS_ApplicationLatest 				ModelName
Package 					SMS_Package 						PackageID
Query 						SMS_Query 							QueryID
Software Metering Rule 		SMS_MeteredProductRule 				SecurityKey
Configuration Item 			SMS_ConfigurationItemLatest 		ModelName
Configuration Baseline 		SMS_ConfigurationBaselineInfo 		ModelName
Operating System Image 		SMS_OperatingSystemInstallPackage 	PackageID
Operating System Package 	SMS_ImagePackage 					PackageID
User State Migration 		SMS_StateMigration 					MigrationID
Boot Image 					SMS_BootImagePackage 				PackageID
Task Sequence 				SMS_TaskSequencePackage 			PackageID
Driver Package 				SMS_DriverPackage 					PackageID
Driver 						SMS_Driver 							ModelName
Software Update 			SMS_SoftwareUpdate 					ModelName
Collection 					SMS_Collection 						CollectionID
#>

Function Get-ObjectLocation
{
    param (
    [string]$InstanceKey
    )
    
    $ContainerNode = Get-WmiObject -Namespace 'root/SMS/site_XX1' -ComputerName 'SERVER' -Query "SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='$InstanceKey'"
    if ($ContainerNode -ne $null)
    {
        $ObjectFolder = $ContainerNode.Name
        if ($ContainerNode.ParentContainerNodeID -eq 0)
        {
            $ParentFolder = $false
        }
        else
        {
            $ParentFolder = $true
            $ParentContainerNodeID = $ContainerNode.ParentContainerNodeID
        }
        while ($ParentFolder -eq $true)
        {
            $ParentContainerNode = Get-WmiObject -Namespace 'root/SMS/site_XX1' -ComputerName 'SERVER' -Query "SELECT * FROM SMS_ObjectContainerNode WHERE ContainerNodeID = '$ParentContainerNodeID'"
            $ObjectFolder =  $ParentContainerNode.Name + "\" + $ObjectFolder
            if ($ParentContainerNode.ParentContainerNodeID -eq 0)
            {
                $ParentFolder = $false
            }
            else
            {
                $ParentContainerNodeID = $ParentContainerNode.ParentContainerNodeID
            }
        }
        $ObjectFolder = "Root\" + $ObjectFolder
        Write-Output $ObjectFolder
    }
    else
    {
        $ObjectFolder = "Root"
        Write-Output $ObjectFolder
    }
}

# $SiteCode = 'XX1'
# $SiteServer = 'SERVER'
