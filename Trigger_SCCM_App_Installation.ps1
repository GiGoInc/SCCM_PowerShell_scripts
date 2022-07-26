Function Trigger-AppInstallation
{
    Param
    (
     [String][Parameter(Mandatory=$True, Position=1)] $Computername,
     [String][Parameter(Mandatory=$True, Position=2)] $AppName,
     [ValidateSet("Install","Uninstall")]
     [String][Parameter(Mandatory=$True, Position=3)] $Method
    )
     
    Begin {
    $Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $Computername | Where-Object {$_.Name -like $AppName})
     
    $Args = @{EnforcePreference = [UINT32] 0
    Id = "$($Application.id)"
    IsMachineTarget = $Application.IsMachineTarget
    IsRebootIfNeeded = $False
    Priority = 'High'
    Revision = "$($Application.Revision)" }
    }
     
    Process
    {
        Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -ComputerName $Computername -MethodName $Method -Arguments $Args
    }
    End {}
}


Function Trigger-PackageInstallation
{
    Param
    (
     [String][Parameter(Mandatory=$True, Position=1)] $Computername,
     [String][Parameter(Mandatory=$True, Position=2)] $AppName,
     [ValidateSet("Install","Uninstall")]
     [String][Parameter(Mandatory=$True, Position=3)] $Method
    )
     
    Begin {
    $Package = (Get-CimInstance -ClassName CCM_SoftwareDistribution -Namespace "ROOT\ccm\policy\machine\actualconfig" -ComputerName $Computername | Where-Object {$_.PKG_MIFName -like $AppName})
     
    $Args = @{EnforcePreference = [UINT32] 0
    Id = "$($Package.ADV_AdvertisementID)"
    IsMachineTarget = $Package.IsMachineTarget
    IsRebootIfNeeded = $False
    Priority = 'High'
    Revision = "$($Package.Revision)" }
    }
     
    Process
    {
        Invoke-CimMethod -Namespace "ROOT\ccm\policy\machine\actualconfig" -ClassName CCM_SoftwareDistribution -ComputerName $Computername -PRG_ProgramName $PRG_ProgramName -Arguments $Args
    }
    End {}
}


Trigger-PackageInstallation -Computername '42snm12' -AppName "Windows Update Agent - x86 Patches" -Method 'Install'


$Package =(Get-CimInstance -ClassName CCM_SoftwareDistribution -Namespace "ROOT\ccm\policy\machine\actualconfig" -ComputerName '42snm12' | Where-Object {$_.PKG_MIFName -like "Windows Update Agent - x86 Patches"})

ROOT\ccm\Policy\Machine\ActualConfig:CCM_SoftwareDistribution.ADV_AdvertisementID="SS1201AC",PKG_PackageID="SS10054E",PRG_ProgramID="Install"


\\42SNM12\ROOT\ccm\ClientSDK:CCM_Application.Id="ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_d6580735-e460-41e3-8d1a-fa43737f7b88",IsMachineTarget=true,Revision="6"

\\42SNM12\ROOT\ccm\policy\machine\actualconfig:CCM_SoftwareDistribution.ADV_AdvertisementID="SS1201AC",PKG_PackageID="SS10054E",PRG_ProgramID="Install"


\\42SNM12\ROOT\ccm\Policy\Machine\RequestedConfig:CCM_SoftwareDistribution.PolicyID="SS1201AC-SS10054E-60F8A6B9",PolicyInstanceID="{FED49C53-5C0B-4BC8-84F9-D53B5287EB83}",PolicyRuleID="{bf5d2f29-5acb-4cd9-ae16-361e86c0854a}",PolicySource="SMS:SS1",PolicyVersion="3.00"


$Computername = '42snm12'
$PRG_ProgramName = 'Install'

$Package | Out-file 'D:\PKGINFO.txt'



