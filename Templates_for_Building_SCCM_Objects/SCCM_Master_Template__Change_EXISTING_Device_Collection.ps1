$CollNames = "Workstations - Non-Branch - Group 01 of 10", `
             "Workstations - Non-Branch - Group 02 of 10", `
             "Workstations - Non-Branch - Group 03 of 10", `
             "Workstations - Non-Branch - Group 04 of 10", `
             "Workstations - Non-Branch - Group 05 of 10", `
             "Workstations - Non-Branch - Group 06 of 10", `
             "Workstations - Non-Branch - Group 07 of 10", `
             "Workstations - Non-Branch - Group 08 of 10", `
             "Workstations - Non-Branch - Group 09 of 10", `
             "Workstations - Non-Branch - Group 10 of 10"


$Comments = 'Divided Non-Branch machines into 10 random groups, 100 (approx) each'

# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location SS1:
    CD SS1:

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