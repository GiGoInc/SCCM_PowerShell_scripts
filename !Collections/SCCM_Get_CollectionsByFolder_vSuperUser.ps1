cls

}
cls
 ##############################
 # Add Required Type Libraries
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
##############################
C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
##############################
$ADGroups = Get-ADGroup -Filter *
$ADGroups.name | sort | Set-Content 'D:\Projects\ActiveDirectory\AD_Group_Names.txt'
##############################
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:
##############################
$ADate = Get-Date -Format "yyyy_MM-dd"
$Log = "D:\Powershell\!SCCM_PS_scripts\!Collections\$ADate--Collections.csv"
'Collections' | Set-Content $Log

cls
$SiteCode = 'XX1'
$FolderName = 'Active Directory Software Groups'
$FolderObjs = $(Get-WmiObject -Class SMS_ObjectContainerNode -Namespace Root\SMS\Site_$SiteCode -filter "Name='$FolderName'" -ComputerName 'SERVER').ContainerNodeID

foreach ($FolderObjID in $FolderObjs)
{
    #Write-Host $FolderObjID -f green
    $Items = Get-WmiObject -Class SMS_ObjectContainerItem -Namespace Root\SMS\Site_$SiteCode -filter "ContainerNodeID=$FolderObjID" -ComputerName 'SERVER'
    ForEach ($item in $items)
    {
            $InstanceKeys = $item.InstanceKey
            ForEach ($InstanceKey in $InstanceKeys)
            {
                #Write-Host "`t$InstanceKey" -f Yellow
                $Coll = Get-CMUserCollection -CollectionID $InstanceKey
                $CollName = $Coll.Name
                    # Write-Host "`t`t$CollName " -f Red
                    $CollName | Add-Content $Log
            }
     }
}

