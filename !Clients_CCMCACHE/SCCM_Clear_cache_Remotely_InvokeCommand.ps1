<#
}
    Invoke-Command -ComputerName $computer -ScriptBlock $ScriptBlockContent -ArgumentList $computer
<#
}
    Invoke-Command -ComputerName $computer -ScriptBlock $ScriptBlockContent -ArgumentList $computer
<#
$computers = "3WPPL32", `
             "H4T7VD2", `
             "2JVVJC2", `
             "FLWBLT03", `
             "BHM2B42", `
             "70YNX12", `
             "ALWRDR22", `
             "ALWRDR30", `
             "ALWRDR50", `
             "COMPUTER83", `
             "84HTP12", `
             "CBQPK32", `
             "WNBULTIPRO1", `
             "ALWRDR17", `
             "ALWRDR34", `
             "ALWRDR11", `
             "ALWRDR35", `
             "ALWRDR40", `
             "ALWRDR75", `
             "ALWRDR80", `
             "ALWRDR90", `
             "GRR5N22", `
             "2Y41LC2", `
             "CM0FLC2", `
             "5TF2LC2", `
             "FRL0LC2", `
             "4Q1QJC2", `
             "CQNQJC2", `
             "JYRDHC2", `
             "28T7VD2", `
             "1XF2LC2", `
             "1FTPK32", `
             "COMPUTER57", `
             "2RG0942", `
             "LAE0SP36", `
             "5YNDLC2", `
             "60R9K12", `
             "COMPUTER170", `
             "NETWORKGNS3", `
             "NETWORKTRN6", `
             "FFD3N12", `
             "PC04342", `
             "XXXXVENDOR1", `
             "LAG0SP03", `
             "LAH5ET08", `
             "FLO5SP07", `
             "MSPASP02", `
             "XXXXPATSTW71", `
             "9NFTP12", `
             "LAI6ET04", `
             "BDBSR22", `
             "FLO5SP05", `
             "PC1357", `
             "XXXXVENDOR4"
#>

$computers = 'mscusp07'

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
