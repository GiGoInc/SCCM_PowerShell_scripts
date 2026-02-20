function Invoke-SCCM-DCM_Evaluation
}
    }
function Invoke-SCCM-DCM_Evaluation
}
    }
function Invoke-SCCM-DCM_Evaluation
{
    param (
        [Parameter(Mandatory=$true, HelpMessage="Computer Name",ValueFromPipeline=$true)] $Computer
           )
    $Baselines = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
    $Baselines | % { ([wmiclass]"\\$Computer\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) }
}

$log = '.\Intitiate_All_DCM_Baselines.csv'

#$Computers = 'HWGNM12','85JTP12','4BLQL32','LAIFLT01','CDPJG12','CL0SL32','8T9NM12','CVRNM12','LAISLT02','9MNNM12','9TPNM12','BJ6Z942','7QJTJ02','G5T7VD2','G3TXK32','2S40942','93RNM12','JBRQL32','2VCY842','ALOCLS53','547JM32','3YC9L12','5RGTP12','C61VR22','94VPL32','BJ90B42','CWSN262','9G8PL32','6JCNM12','C9HPJC2','5G9NJC2','LANOCL30','F4VPL32','DJH7K12','G8NGL32','BGR3B42','BHZZ942','C9KYN32','47SNM12','24KZ842','BCRVQ22','JB15Q12','3CRYH02','8LPNM12','6XGTP12','BK02B42','GQ83N22','BGPX942','GWTPK32','CQZWY12','9BVPL32','GK9NM12','FPZ5R22','1FDNH12','GRY5N22','2VSY842','COMPUTER28','5QPNM12','BCJQLN1','8BXZP12','BHL3B42','2V70942','LASPTN23','JPCNH12','DQKYN32','FL1MT52','GH4PL32','5TPPK32','8WLML12','MSMGLT11','BHNZ942','COMPUTER09','9XHRLN1','XXXXEMP10','2V10942','70WPK32','8PXFHC2','6KGTP12','F8YNL32','ALOCLS54','LARMLT01','LALSDT03','COMPUTER166','MSIVLP78','DTFP942','D5VPL32','26MY842','GSTPK32','F7LQL32','2DDNH12','4VWPK32','9WM9G12','BGT4B42','BYTQL32','H4GSH12','J6XZP12','LANOCL23'

$Computers = 'PC1'

ForEach ($Computer in $Computers)
{
    If(Test-Connection $computer -count 1 -quiet -BufferSize 16)
    {
        Try
        {
            Write-Host "Initiating $computer..."
            Invoke-SCCM-DCM_Evaluation -Computer $Computer
            "$computer,Initiated" | add-content $Log
        }
        Catch
        {
            Write-Host "Couldn't Initiate $computer"
            "$computer,Failed to Intitiate" | add-content $Log
        }
    }
    Else
    {
        Write-Host "Offline: $computer..."
        "$computer,Offline" | add-content $Log
    }
}
