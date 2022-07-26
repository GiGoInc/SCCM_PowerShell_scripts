$Computers = 'SCCMSERVER1', `
			'SCCMSERVER2', `
			'SCCMSERVER3'

ForEach ($Computer in $Computers)
{
    If(Test-Connection $computer -count 1 -quiet -BufferSize 16)
    {
        $A = Test-Path "\\$computer\SCCMContentLib$"
        If ($A -eq $true)
        {
            Write-Host "$Computer - $A" -ForegroundColor Cyan
        }
        Else
        {
            Write-Host "$Computer - $A" -ForegroundColor Red
        }
    }
    Else
    {
            Write-Host "$Computer`t`tCould not ping..." -ForegroundColor Red
    }

}
