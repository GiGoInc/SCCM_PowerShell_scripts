$ErrorActionPreference = 'silentlycontinue'

}
$ErrorActionPreference = 'silentlycontinue'
$i = 0
# Get each user profile SID and Path to the profile
$UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where {$_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } | Select-Object @{Name="SID"; Expression={$_.PSChildName}}, @{Name="UserHive";Expression={"$($_.ProfileImagePath)\NTuser.dat"}}

# Add in the .DEFAULT User Profile
$DefaultProfile = "" | Select-Object SID, UserHive
$DefaultProfile.SID = ".DEFAULT"
$DefaultProfile.Userhive = "C:\Users\Public\NTuser.dat"
$UserProfiles += $DefaultProfile

# Loop through each profile on the machine
Foreach ($UserProfile in $UserProfiles)
{
    If ($Property = Get-ItemProperty -Path Registry::HKEY_USERS\$($UserProfile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name 'Lync')
    {
       $i++
    }
}

If ($i -eq 0)
{
    Write-Host 'Compliant'
}
Else
{
    Write-Host 'Non-Compliant'
}

######################################################################################################################################################################################################
######################################################################################################################################################################################################

$ErrorActionPreference = 'silentlycontinue'
# Get each user profile SID and Path to the profile
$UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where {$_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } | Select-Object @{Name="SID"; Expression={$_.PSChildName}}, @{Name="UserHive";Expression={"$($_.ProfileImagePath)\NTuser.dat"}}

# Add in the .DEFAULT User Profile
$DefaultProfile = "" | Select-Object SID, UserHive
$DefaultProfile.SID = ".DEFAULT"
$DefaultProfile.Userhive = "C:\Users\Public\NTuser.dat"
$UserProfiles += $DefaultProfile

# Loop through each profile on the machine
Foreach ($UserProfile in $UserProfiles)
{
    If ($ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Run)
    {
        Remove-ItemProperty -Path Registry::HKEY_USERS\$($UserProfile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name "Lync" -Force
    }
}

