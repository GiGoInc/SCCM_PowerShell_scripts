$Output = @()
$Output += "SmsProviderObjectPath," + `
           "BoundaryFlags," + `
           "BoundaryID," + `
           "BoundaryType," + ` 
           "CreatedBy," + `
           "CreatedOn," + `
           "DefaultSiteCode," + ` 
           "DisplayName," + `
           "GroupCount," + `
           "ModifiedBy," + `
           "ModifiedOn," + `
           "SiteSystems," + `
           "Value"

$Boundaries = Get-CMBoundary
ForEach ($Boundary in $Boundaries)
{
$Output += $Boundary.SmsProviderObjectPath + "," + `
           $Boundary.BoundaryFlags + "," + ` 
           $Boundary.BoundaryID + "," + ` 
           $Boundary.BoundaryType + "," + ` 
           $Boundary.CreatedBy + "," + ` 
           $Boundary.CreatedOn + "," + ` 
           $Boundary.DefaultSiteCode + "," + ` 
           $Boundary.DisplayName + "," + ` 
           $Boundary.GroupCount + "," + ` 
           $Boundary.ModifiedBy + "," + ` 
           $Boundary.ModifiedOn + "," + ` 
           $Boundary.SiteSystems + "," + ` 
           $Boundary.Value    
}
$output | Set-Content "D:\Powershell\!SCCM_PS_scripts\!Boundary_Groups\Get_Boundaries_Info--Results.csv"

           
