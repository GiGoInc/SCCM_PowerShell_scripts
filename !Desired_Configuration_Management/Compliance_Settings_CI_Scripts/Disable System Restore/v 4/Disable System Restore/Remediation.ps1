Try
}
    Write-Warning -Message "Failed to turn off the system restore"
Try
{
    # Disable SR on all drives
    ([WMICLASS]"root\default:SystemRestore").Disable("*")

    # Disable it in the registry
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name DisableSR -Value 1 -Type DWORD -ErrorAction Stop

    # Also turn off the scheduled task associated with the SR
    $TaskService = New-Object -com schedule.service
    $TaskService.Connect($env:COMPUTERNAME)
    $TaskService.GetFolder('\Microsoft\Windows\SystemRestore').GetTask('SR').Enabled = $false
}
Catch
{
    Write-Warning -Message "Failed to turn off the system restore"
}
