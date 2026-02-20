$CollNames = "Workstations - Non-RemoteLocale - Group 01 of 10", `
}
    # $DCollID = (Get-CMCollection -Name $DCollName).CollectionID
$CollNames = "Workstations - Non-RemoteLocale - Group 01 of 10", `
             "Workstations - Non-RemoteLocale - Group 02 of 10", `
             "Workstations - Non-RemoteLocale - Group 03 of 10", `
             "Workstations - Non-RemoteLocale - Group 04 of 10", `
             "Workstations - Non-RemoteLocale - Group 05 of 10", `
             "Workstations - Non-RemoteLocale - Group 06 of 10", `
             "Workstations - Non-RemoteLocale - Group 07 of 10", `
             "Workstations - Non-RemoteLocale - Group 08 of 10", `
             "Workstations - Non-RemoteLocale - Group 09 of 10", `
             "Workstations - Non-RemoteLocale - Group 10 of 10"


$Comments = 'Divided Non-RemoteLocale machines into 10 random groups, 100 (approx) each'

# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location XX1:
    CD XX1:

ForEach ($DCollName in $CollNames)
{
    # Static Variables
        $LimitingColl = "All Windows Workstation or Professional Systems (DC0)"
    
    Set-CMCollection -Name $DCollName `
                     -Comment $Comments
        
        Write-Host ""
        Write-Host "Set SCCM DEVICE Collection named: " -NoNewline
        Write-Host "$DCollName" -ForegroundColor Green
    
    # $DCollID = (Get-CMCollection -Name $DCollName).CollectionID
}
