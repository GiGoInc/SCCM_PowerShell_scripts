$VBPath = 'D:\NS2k8'
$Log = 'D:\NS2k8\Security_Compliance_Info.txt'
$null | Set-Content $Log


$Files = Get-ChildItem -Path $VBPath -Filter '*.vbs' | select FullName, Name
ForEach ($File in $Files)
{
  $F = $File.Name
  $C = Get-Content -Path $File.FullName
  Foreach ($line in $C)
  {
    If ($line -match "WScript.Echo GetAuditData")
    {
        $line = $line.replace('WScript.Echo GetAuditData("','').replace('")','')
        "$F;$line" -join ';' | Add-Content $Log
    }
  }
  
}


# Get New list of VB Scripts
# Run the audit policy against the subcategories and verify results
  $Items = Get-Content $Log
  ForEach ($Item in $Items)
  {
    $FileName    = $Item.split(';')[0]
    $Subcategory = $Item.split(';')[1]
  
    $ScriptBlock =
    {
      auditPol.exe /get /subcategory:"$Subcategory" /r
    }
    $Result = Invoke-Command -ScriptBlock $ScriptBlock
    If ($Result -ne $null)
    {
      $Result = $Result.split(',')[-3]
      Write-Host "$Result" -ForegroundColor Green -NoNewline
    }
    If ($Result -eq $null)
    {
      $Result = "ERROR: Get Data Failed"
      Write-Host "$Result" -ForegroundColor Red -NoNewline
    }
    Write-Host " -- " -NoNewline
    Write-Host $Subcategory -ForegroundColor Cyan
  }

