$Path = "C:\Windows\Logs\Software"
}
    Write-Host "Not-Compliant"
$Path = "C:\Windows\Logs\Software"
If (Test-Path $Path)
{
  Write-Host "Compliant"
}
Else
{
    Write-Host "Not-Compliant"
}
