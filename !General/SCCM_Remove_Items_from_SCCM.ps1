#######################################################################
}

#######################################################################
#Name: Remove multiple packages ,applications,drivers,Images etc from Configmgr 2012
#Author: Eswar Koneti
#Date Created:22-July-2014
#Avilable At:www.eskonr.com

#######################################################################

#Import Module
$CMModulepath = $Env:SMS_ADMIN_UI_PATH.ToString().Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + "\ConfigurationManager.psd1"
import-module $CMModulepath -force
#Change the site Code
CD XX1:
#Change output File Location to store the results
$Outputpath = 'D:\Powershell\!SCCM_PS_scripts\!General\SCCM_Remove_Items_from_SCCM--Results.txt'
#Change the input filename ,make sure you supply the information in correct format

Import-Csv 'D:\Powershell\!SCCM_PS_scripts\!General\SCCM_Remove_Items_from_SCCM--Package_List.csv' | `
    ForEach-Object {
    $PackageType = $_.PackageType
    $PackageName = $_.PackageName

    Write-Host "Checking: $PackageName" -ForegroundColor Cyan

    # For Packages
    If ($PackageType -eq "Package")
    {
        #Check If the supplied package exist in CM12
        If ( Get-CMPackage -Name "$PackageName")
        {
            Remove-CMPackage -Name  "$PackageName" -Force
            #Check If the supplied package deleted or not from CM12
            If (!( Get-CMPackage -Name "$PackageName"))
            {
                "Package " + $PackageName + " " + "Deleted " | Out-File -FilePath $Outputpath -Append
            }
            Else
            {
                "Package " + $PackageName + " " + "Not Deleted ,Fix the problem and delete manually " | Out-File -FilePath $Outputpath -Append
            }
        }
    }

    #For Applications

    If ($PackageType -eq "Application")
    {
        #Check If the supplied Application exist in CM12
        If ( Get-CMApplication -Name "$PackageName")
        {
            Remove-CMApplication -Name  "$PackageName" -Force
            #Check If the supplied Application deleted or not from CM12
            If (!( Get-CMApplication -Name "$PackageName"))
            {
                "Application " + $PackageName + " " + "Deleted " | Out-File -FilePath $Outputpath -Append
            }
            Else
            {
                "Application " + $PackageName + " " + "not Deleted ,Fix the problem and delete Manually " | Out-File -FilePath $Outputpath -Append
            }
        }


    }

    # For Driver Packages
    If ($PackageType -eq "Driver")
    {
        #Check If the supplied Driver Package exist in CM12
        If ( Get-CMDriverPackage -Name "$PackageName")
        {
            Remove-CMDriverPackage -Name  "$PackageName" -Force
            #Check If the supplied Driver Package deleted or not from CM12
            If (!( Get-CMDriverPackage -Name "$PackageName"))
            {
                "Driver " + $PackageName + " " + "Deleted " | Out-File -FilePath $Outputpath -Append
            }
            Else
            {
                "Driver " + $PackageName + " " + "not Deleted ,Fix the problem and delete Manually " | Out-File -FilePath $Outputpath -Append
            }

        }
    }

    #For BootImages

    If ($PackageType -eq "BootImage")
    {
        #Check If the supplied Boot Image exist in CM12
        If ( Get-CMBootImage -Name "$PackageName")
        {
            Remove-CMBootImage -Name  "$packagename" -Force
            #Check If the supplied Boot Image deleted or not from CM12
            If (!( Get-CMDriverPackage -Name "$PackageName"))
            {
                "BootImage " + $PackageName + " " + "Deleted " | Out-File -FilePath $Outputpath -Append
            }
            Else
            {
                "BootImage " + $PackageName + " " + "not Deleted ,Fix the problem and delete Manually " | Out-File -FilePath $Outputpath -Append
            }
        }
    }


    #For OSImage

    If ($PackageType -eq "OSImage")
    {
        #Check If the supplied OS Image exist in CM12
        If ( Get-CMOperatingSystemImage -Name "$PackageName")
        {
            Remove-CMOperatingSystemImage -Name "$packagename" -Force
            #Check If the supplied OS Image deleted or not from CM12
            If (!( Get-CMOperatingSystemImage -Name "$PackageName"))
            {
                "OSImage " + $PackageName + " " + "Deleted " | Out-File -FilePath $Outputpath -Append
            }
            Else
            {
                "OSImage " + $PackageName + " " + "not Deleted ,Fix the problem and delete Manually " | Out-File -FilePath $Outputpath -Append
            }

        }
    }


    #For SUPPackages

    If ($PackageType -eq "SUP")
    {
        #Check If the supplied SUP Package exist in CM12
        If ( Get-CMSoftwareUpdateDeploymentPackage -Name "$PackageName")
        {
            Remove-CMSoftwareUpdateDeploymentPackage -Name  "$packagename" -Force
            #Check If the supplied SUP Package exist in CM12
            If (!( Get-CMSoftwareUpdateDeploymentPackage -Name "$PackageName"))
            {
                "SUP " + $PackageName + " " + "Deleted " | Out-File -FilePath $Outputpath -Append
            }
            Else
            {
                "SUP  " + $PackageName + " " + "not Deleted ,Fix the problem and delete Manually " | Out-File -FilePath $Outputpath -Append
            }
        }
    }


}
