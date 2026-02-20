$File = "E:\!Scripts\Powershell\delete_list.txt"
Write-Output -BackgroundColor Red -ForegroundColor Yellow -Object Done

$File = "E:\!Scripts\Powershell\delete_list.txt"


Function Check-List ($File)
# ForEach ($PCName in $File)
 {
    # Select the computer(s)
	$SCCMServer = "SERVER"
	$sitename = "XX1"
    $computername = $File
 #Write-Output $computername
    # Get the resourceID from SCCM
    $resID = Get-WmiObject -computername $SCCMServer -query "select resourceID from sms_r_system where name like `'$computername`'" -Namespace "root\sms\site_$sitename"
    $computerID = $resID.ResourceID

    if ($resID.ResourceId -eq $null) {
        $msgboxValue = "No SCCM record for that computer"
        }
    else
        {
            $comp = [wmi]"\\$SCCMServer\root\sms\site_$($sitename):sms_r_system.resourceID=$($resID.ResourceId)"

            # Output to screen
        Write-Output "$computername with resourceID $computerID will be deleted"

        # Delete the computer account
            $comp.psbase.delete()
    }
}
Get-Content $File | foreach-Object {invoke-command -ScriptBlock ${function:Check-List} -ArgumentList $_}

Write-Output -BackgroundColor Red -ForegroundColor Yellow -Object Done
