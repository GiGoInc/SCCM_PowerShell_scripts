<#
    Add machine to correct Collection in SCCM for Mainteenance / Patch Window

    Collection Name                                                 Collection ID
    Server Default Maint. Window	                                SS10008B
    Server Maintenance Window - 2nd Sunday 12AM - 6AM	            SS1001A6
    Server Maintenance Window - 3rd Sat 6PM - 12AM	                SS10010F
    Server Maintenance Window - 3rd Sat 6PM - 12AM[1]	            SS1001A5
    Server Maintenance Window - 3rd Sunday 12AM - 6AM	            SS100089
    Server Maintenance Window - 3rd Sunday 12PM - 6PM	            SS10010E
    Server Maintenance Window - 3rd Sunday 6AM - 12 PM	            SS10008C
    Server Maintenance Window - 4th Saturday 6PM - 12 AM	        SS100092
    Server Maintenance Window - 4th Sunday 12AM - 6AM	            SS10018C
    Server Maintenance Window - 4th Sunday 12AM - 6AM - Automated	SS100466
    Server Maintenance Window - 4th Sunday 12PM - 6PM	            SS100093
    Server Maintenance Window - 4th Sunday 6AM - 12 PM	            SS100090
    Server Maintenance Window - MANUAL INSTALL	                    SS1003F7
#>

# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location SS1:
    CD SS1:

$log = '\\scorchserver1\D$\!Isaac\Add_Machine_to_Maintenance_Window.log'
$Computer = "\`d.T.~Ed/{11EF698E-EC71-4AD8-82DC-AB8933BDB096}.hostname\`d.T.~Ed/"            # select 'hostname' from row in VM_REQUESTS
$Pw = "\`d.T.~Ed/{11EF698E-EC71-4AD8-82DC-AB8933BDB096}.patch_window\`d.T.~Ed/"     # select 'patch_window' from row in VM_REQUESTS

$CollName = "Server Maintenance Window - $Pw"


If(Get-CMCollection -Name $CollName)
{
    If(Get-CMDevice -Name $computer)
    {
        # Write-Host "Adding " -NoNewline
        # Write-Host "$Computer " -NoNewline -ForegroundColor Cyan
        # Write-Host "to collection named " -NoNewline
        # Write-Host "$CollName " -NoNewline -ForegroundColor Cyan
        # Write-Host "for Maintenance Window"
        "$(get-date -format MM/dd/yyy) * $(get-date -format HH:mm:ss) *  Adding $Computer to collection named $CollName for Maintenance Window" | Add-Content $log
    
        Add-CMDeviceCollectionDirectMembershipRule -CollectionName "$CollName" -ResourceID $(get-cmdevice -name "$Computer").ResourceID
    }
    Else
    {
        Write-host $output = "Found $collname, can't find $computer record."
        "$(get-date -format MM/dd/yyy) * $(get-date -format HH:mm:ss) *  Found $collname, can't find $computer record." | Add-Content $log
    }
}
Else
{
    Write-host $output = "Can't find $collname in SCCM"
    "$(get-date -format MM/dd/yyy) * $(get-date -format HH:mm:ss) *  Can't find $collname in SCCM" | Add-Content $log
 
}
