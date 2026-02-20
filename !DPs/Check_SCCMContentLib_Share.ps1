$Computers = 'ALCASM01', `
}

$Computers = 'ALCASM01', `
'ALK5SM01', `
'ALK6SM01', `
'ALK7SM01', `
'ALK9SM01', `
'ALLESM01', `
'ALOCSCCM01', `
'ALP2SM01', `
'ALP7SM01', `
'ALQ0SM01', `
'ALT5SM01', `
'ALTFSM01', `
'FLA3SM01', `
'FLA4SM01', `
'FLA6SM01', `
'FLA7SM01', `
'FLA8SM01', `
'FLA9SM01', `
'FLB1SM01', `
'FLB8SM01', `
'FLB9SM01', `
'FLC4SM01', `
'FLC7SM01', `
'FLC8SM01', `
'FLD0SM01', `
'FLD3SM01', `
'FLD4SM01', `
'FLDTSM01', `
'SERVER', `
'SERVER', `
'FLMDSM01', `
'FLO2SM01', `
'FLO5SM01', `
'FLO7SM01', `
'FLP3SM01', `
'FLP4SM01', `
'FLP5SM01', `
'FLP6SM01', `
'FLQ2SM01', `
'FLQ4SM01', `
'FLQ8SM01', `
'FLQ9SM01', `
'FLR3SM01', `
'FLRASM01', `
'FLT0SM01', `
'FLT2SM01', `
'FLU0SM01', `
'ILSGSCCM1', `
'LAABSM01', `
'SERVER', `
'LAATSM01', `
'LABBSM01', `
'LABSSM01', `
'LACESM01', `
'LACGSM01', `
'LACOSM01', `
'LACVSM01', `
'LADMSM01', `
'LAE0SM01', `
'LAE2SM01', `
'LAE3SM01', `
'LAE4SM01', `
'LAE6SM01', `
'LAE7SM01', `
'LAE9SM01', `
'LAF3SM01', `
'LAF4SM01', `
'LAF8SM01', `
'LAF9SM01', `
'LAFASM01', `
'LAFBSM01', `
'LAFCSM01', `
'LAFMSM01', `
'LAG0SM01', `
'LAG1SM01', `
'LAG2SM01', `
'LAG4SM01', `
'LAG5SM01', `
'LAG7SM01', `
'LAG8SM01', `
'LAG9SM01', `
'LAH1SM01', `
'LAH2SM01', `
'LAH3SM01', `
'LAH4SM01', `
'LAH5SM01', `
'LAH6SM01', `
'LAHRSM01', `
'LAI0SM01', `
'LAI1SM01', `
'LAI5SM01', `
'LAI6SM01', `
'LAI7SM01', `
'LAI8SM01', `
'LAJ0SM01', `
'LAJ1SM01', `
'COMPUTER306', `
'LAJ4SM01', `
'LAJ5SM01', `
'LAJ6SM01', `
'LAJ7SM01', `
'LAJ8SM01', `
'LAK0SM01', `
'LAK1SM01', `
'LAK2SM01', `
'LAL6SM01', `
'LAL7SM01', `
'LAL9SM01', `
'LALFSM01', `
'SERVER', `
'LAMESM01', `
'LAN0SM01', `
'LAN1SM01', `
'LAN3SM01', `
'LAN4SM01', `
'LAN5SM01', `
'LAN6SM01', `
'LAN7SM01', `
'SERVER', `
'LAN9SM01', `
'LAO0SM01', `
'LAO1SM01', `
'LAO3SM01', `
'LAO4SM01', `
'LAO9SM01', `
'SERVER', `
'LAOWSM01', `
'LAPLSM01', `
'SERVER', `
'LAQ6SM01', `
'LAR1SM01', `
'LARWSM01', `
'LAS1SM01', `
'LASGSM01', `
'LASLSM01', `
'LASOSM01', `
'LASVSM01', `
'LAT3SM01', `
'LATASM01', `
'LAU2SM01', `
'LAVPSM01', `
'LAWESM01', `
'SERVER', `
'SERVER', `
'LAZYSM01', `
'MSBASM01', `
'SERVER', `
'MSBYSM01', `
'SERVER', `
'MSCWSM01', `
'SERVER', `
'MSDHSM01', `
'MSDISM01', `
'MSDRSM01', `
'MSEOSM01', `
'MSESSM01', `
'MSGTSM01', `
'SERVER', `
'SERVER', `
'MSLBSM01', `
'MSLRSM01', `
'MSLYSM01', `
'MSMOSM01', `
'MSMPSM01', `
'MSNVSM01', `
'SERVER', `
'MSOSSM01', `
'MSPASM01', `
'SERVER', `
'MSPDSM01', `
'MSPFSM01', `
'MSPMSM01', `
'MSPNSM01', `
'MSPPSM01', `
'SERVER', `
'MSPVSM01', `
'MSPXSM01', `
'MSSTSM01', `
'MSSUSM01', `
'MSVASM01', `
'MSWASM01', `
'MSXRSM01', `
'TXS9SM01', `
'TXT7SM01'

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
