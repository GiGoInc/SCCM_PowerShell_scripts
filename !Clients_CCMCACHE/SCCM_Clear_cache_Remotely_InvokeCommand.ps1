
$computers = 'Server1'

Foreach ($computer in $computers)
{
    Write-Host "Checking $computer"
        $ScriptBlockContent = { 
            param ($computer)
            $A = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx  -Impersonation 3
            ForEach ($item in $A)
            {
                $CID = $item.cacheid
                $loc = $item.location
                $RP = $loc.ToString().split('C:')[2]
                $folder = "C:"+"$RP"
                'ROOT\ccm\SoftMgmtAgent:CacheInfoEx.CacheId='+"""$CID""" | remove-wmiobject
                Remove-Item $folder -Recurse -Force
                #Write-host "Removing $folder"
            }
        }


    Invoke-Command -ComputerName $computer -ScriptBlock $ScriptBlockContent -ArgumentList $computer
}