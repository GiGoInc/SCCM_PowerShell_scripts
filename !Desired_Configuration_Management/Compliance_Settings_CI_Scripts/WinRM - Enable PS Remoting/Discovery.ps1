$check = Test-WSMan
{Write-Host 'Compliant'}
else
$check = Test-WSMan
if($check -eq $null)
{Write-Host 'Non-Compliant'}
else
{Write-Host 'Compliant'}
