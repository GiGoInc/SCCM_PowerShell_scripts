$AppName = "WMF 5.0"

$CollNames = "$AppName - Group 01", `
             "$AppName - Group 02", `
             "$AppName - Group 03", `
             "$AppName - Group 04", `
             "$AppName - Group 05", `
             "$AppName - Group 06", `
             "$AppName - Group 07", `
             "$AppName - Group 08", `
             "$AppName - Group 09", `
             "$AppName - Group 10"


$Comments = "Created automagically by PowerShell on $(get-date -format MM/dd/yyy)"

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
    
        # DEVICE Collection - New-CMDeviceCollection Static Variables
    
            $DSchedule = New-CMSchedule -Start "$(get-date -format MM/dd/yyy) 12:00 AM" -RecurCount 1 -RecurInterval Days
            # $Comments = "Created automagically by PowerShell on $(get-date -format MM/dd/yyy)"
    
    # DEVICE Collection
        New-CMDeviceCollection `
            -Name $DCollName `
            -LimitingCollectionName $LimitingColl `
            -RefreshSchedule $DSchedule `
            -RefreshType Both `
            -Comment $Comments
        Write-Host ""
        Write-Host "Created SCCM DEVICE Collection named: " -NoNewline
        Write-Host "$DCollName" -ForegroundColor Green
    
    $DCollID = (Get-CMCollection -Name $DCollName).CollectionID
}