Function SCCMModule
$Results | Add-Content "$CurrentDirectory\Get_Collection_Paths--Results.csv"
'Collection ID,Folder Path' | Set-Content "$CurrentDirectory\Get_Collection_Paths--Results.csv"
Function SCCMModule
$Results | Add-Content "$CurrentDirectory\Get_Collection_Paths--Results.csv"
'Collection ID,Folder Path' | Set-Content "$CurrentDirectory\Get_Collection_Paths--Results.csv"
Function SCCMModule
{
    # Load SCCM Module
    $ErrorActionPreference = 'Stop'
    # Find SCCM Module
    $SCCMPath = 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    If (!(Test-path $SCCMPath))
    {
        Write-Host "Cannot find path: '" -NoNewline -ForegroundColor Magenta
        Write-Host $SCCMpath -NoNewline -ForegroundColor Red
        Write-Host "', can not load SCCM module!!!" -ForegroundColor Magenta
    }
    Else
    {
        C:
        CD $SCCMPath
    }


    # Connect to SCCM
    Try
    {
        Import-Module ".\ConfigurationManager.psd1"
        Set-Location XX1:
        CD XX1:
    }
    Catch [System.Exception]
    {
        $Oops = $error[0]
        If ($Oops -like "Cannot find drive. A drive with the name 'XX1' does not exist.")
        {
            Write-Host "Error connecting to SCCM!!! " -NoNewline -ForegroundColor Red
            Write-Host "Verify the account you are using has permissions!!!" -ForegroundColor Cyan
        }
    }
    Finally
    {
        $ErrorActionPreference = 'Continue'    
    }
}

Function Get-ObjectLocation
{
    param (
        [string]$InstanceKey
    )
    $SiteServer = 'SERVER'
    $SiteCode = 'XX1'
    $Object = @()
    $ContainerNode = Get-WmiObject -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer -Query "SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='$InstanceKey'"
    If ($ContainerNode -ne $null)
    {
        ForEach ($Node in $ContainerNode)
        {
        $ObjectFolder = $Node.Name
        If ($Node.ParentContainerNodeID -eq 0)
        {
            $ParentFolder = $false
        }
        Else
        {
            $ParentFolder = $true
            $ParentContainerNodeID = $Node.ParentContainerNodeID
        }
        while ($ParentFolder -eq $true)
        {
            $ParentContainerNode = Get-WmiObject -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer -Query "SELECT * FROM SMS_ObjectContainerNode WHERE ContainerNodeID = '$ParentContainerNodeID'"
            $ObjectFolder = $ParentContainerNode.Name + "\" + $ObjectFolder
            If ($ParentContainerNode.ParentContainerNodeID -eq 0)
            {
                $ParentFolder = $false
            }
            Else
            {
                $ParentContainerNodeID = $ParentContainerNode.ParentContainerNodeID
            }
        }
        $ObjectFolder = "Root\" + $ObjectFolder
        $object += $ObjectFolder + ','
        }
        [string]$object #.replace(',',"`n")
    }
    Else
    {
		$CollCheck = Get-WmiObject -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer -Query "SELECT SMS_Collection.CollectionID FROM SMS_Collection WHERE SMS_Collection.Name like '$InstanceKey'"
        $CollID = $CollCheck.Collectionid
		$ContainerNode = Get-WmiObject -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer -Query "SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='$CollID'"
		If ($ContainerNode -ne $null)
		{
			ForEach ($Node in $ContainerNode)
			{
			$ObjectFolder = $Node.Name
			If ($Node.ParentContainerNodeID -eq 0)
			{
				$ParentFolder = $false
			}
			Else
			{
				$ParentFolder = $true
				$ParentContainerNodeID = $Node.ParentContainerNodeID
			}
			while ($ParentFolder -eq $true)
			{
				$ParentContainerNode = Get-WmiObject -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer -Query "SELECT * FROM SMS_ObjectContainerNode WHERE ContainerNodeID = '$ParentContainerNodeID'"
				$ObjectFolder = $ParentContainerNode.Name + "\" + $ObjectFolder
				If ($ParentContainerNode.ParentContainerNodeID -eq 0)
				{
					$ParentFolder = $false
				}
				Else
				{
					$ParentContainerNodeID = $ParentContainerNode.ParentContainerNodeID
				}
			}
			$ObjectFolder = "Root\" + $ObjectFolder
			$object += $ObjectFolder + ','
			}
            #Write-Host $ObjectFolder
		}
		Else
		{
        $ObjectFolder = "Root\" + $ObjectFolder
        $object += $ObjectFolder + ','
        #Write-Host $ObjectFolder
		}			
	}
}


$CollIDs = 'XX10044B','XX10044C','XX10008A','XX100A39','XX10091B','XX10094E','XX10094D','XX1009BB','XX100261','XX100A9C','XX10068E','XX10068D','XX10068B','XX10068A','XX100689','XX100688','XX100AE2','XX100B61','XX1009AE','XX1009AF','XX100AE5','XX100AE6','XX10022E','XX10024A','XX10022D','XX100719','XX1005C4','XX1004C9','XX1000F2','XX1009B2','XX1001B9','XX1001BD','XX1001BB','XX1001BC','XX100067','XX100145','XX100694','XX1008B9','XX1008B8','XX1008BB','XX100443','XX10089D','XX1004F6','XX1005ED','XX10092B','XX1000BC','XX1005D3','XX10006D','XX123456','XX100065','XX10065B','XX1001D3','XX10067B','XX1000DD','XX10088A','XX100194','XX100195','XX1004D5','XX123456','XX1003F2','XX1001D5','XX10011A','XX1007EB','XX1005DA','XX100A40','XX10006E','XX1008BD','XX1007F0','XX1007EE','XX1007EF','XX1007ED','XX1007EC','XX100A3C','XX100A88','XX1009F9','XX1009F8','XX1009FA','XX1009FB','XX100063','XX100790','XX10006C','XX1009FC','XX10012A','XX100148','XX100066','XX1004FA','XX100425','XX10006A','XX100423','XX100069','XX10019E','XX1004F9','XX1004D1','XX100ADC','XX100ADD','XX100ADE','XX100ADF','XX100B73','XX100068','XX1009F6','XX1009F5','XX1009F7','XX100B6E','XX1001BA','XX1009B5','XX1008DF','XX100192','XX100193','XX10036D','XX10085F','XX10068F','XX100831','XX100830','XX100690','XX10022F','XX10028A','XX10064A','XX1000B6','XX1002A6','XX1002A4','XX10020A','XX123456','XX100250','XX100255','XX1008BC','XX1008BE','XX1008BF','XX1008C0','XX1008C1','XX1008C2','XX1008C3','XX1008C4','XX1008C5','XX1008C6','XX1002A5','XX1002FA','XX1000B3','XX100A9D','XX100230','XX100B30','XX123456','XX10094B','XX10094C','XX123456','XX100215','XX100AE7','XX1009EE','XX10093D','XX1009E9','XX10043D','XX100440','XX10043C','XX100444','XX10043E','XX100441','XX10007A','XX100AE8','XX10024B','XX100266','XX100231','XX10099E','XX100496','XX100497','XX100239','XX100A6A','XX100A6B','XX100A05','XX1002BC','XX1001FE','XX1000B5','XX10012E','XX100277','XX10097B','XX10090F','XX10047B','XX100264','XX10024C','XX1009F0','XX1009F1','XX1009F3','XX1009F2','XX1005AA','XX100118','XX100AA2','XX1009F4','XX100233','XX100240','XX10071B','XX100812','XX100659','XX10021E','XX1001EA','XX10027C','XX10021B','XX100234','XX123456','XX100235','XX100373','XX100517','XX1000B7','XX100200','XX1002CB','XX1002AA','XX1001EF','XX1000E7','XX100B62','XX100528','XX1001EE','XX1007E9','XX100826','XX1007EA','XX100924','XX1002AB','XX100A42','XX100AFB','XX1008E9','XX100B11','XX1006FD','XX1006FE','XX1006FF','XX1006FA','XX1006FB','XX100784','XX100700','XX100701','XX100702','XX100AFC','XX100AFD','XX100703','XX1007A1','XX1007E2','XX100236','XX10052F','XX100519','XX1000BA','XX10034C','XX100B12','XX100201','XX1002A9','XX100275','XX100B32','XX10025B','XX1001EB','XX100210','XX100270','XX1001F5','XX100287','XX1002AC','XX100332','XX100249','XX100869','XX100B0A','XX100B5E','XX100933','XX100B5D','XX123456','XX100923','XX100922','XX1009D9','XX100025','XX10011F','XX100150','XX100151','XX123456','XX100A22','XX1004CE','XX100938','XX10065E','XX100937','XX1004DA','XX100562','XX100563','XX100A71','XX100AA7','XX1008A1','XX100AA6','XX10041C','XX100B01','XX123456','XX100247','XX100276','XX1001F0','XX10027E','XX10085C','XX1002AF','XX100244','XX100267','XX10026E','XX100A41','XX100A45','XX1004EF','XX1004F1','XX1004F4','XX1004F7','XX1000E6','XX100204','XX1001ED','XX1002E5','XX1002EF','XX1002DC','XX100523','XX1002B5','XX1003EB','XX1000BB','XX1000B8','XX1000B9','XX10026C','XX1000BD','XX1002A8','XX100242','XX100265','XX1000BE','XX100258','XX100259','XX1004C8','XX10023A','XX100232','XX100521','XX1000BF','XX1000C0','XX1009D6','XX1009CA','XX100206','XX1002B0','XX100B2D','XX100813','XX100B27','XX100B26','XX10068C','XX10087E','XX100B36','XX100269','XX10084D','XX10084C','XX1004EE','XX100810','XX10091F','XX100A36','XX100ADA','XX100AAD','XX100987','XX100B75','XX100B42','XX100216','XX10072E','XX10072F','XX1000C1','XX1001A2','XX1005EF','XX100AAC','XX10025D','XX100948','XX100945','XX100949','XX100953','XX100B28','XX10026D','XX1002B1','XX100243','XX10051B','XX1000C2','XX1000C3','XX1007A4','XX100245','XX1007F2','XX100B02','XX100B03','XX10070A','XX10070B','XX10070C','XX100705','XX100704','XX100852','XX100709','XX1002B3','XX1004D8','XX1002B2','XX100271','XX1002B4','XX1006A8','XX100205','XX100286','XX100214','XX10025A','XX100272','XX1001A9','XX10020B','XX100256','XX1002CC','XX100881','XX100882','XX10088D','XX100B44','XX100B45','XX100B46','XX100B47','XX100B48','XX100B49','XX100B4A','XX100B4B','XX100B4C','XX100B4D','XX100B4E','XX100B50','XX100B51','XX100B52','XX100B53','XX100B43','XX100367','XX1009A0','XX100248','XX1009AC','XX100B77','XX100238','XX100B3D','XX1005C3','XX1000C5','XX100530','XX10023C','XX1002B6','XX10089E','XX100B16','XX100B72','XX100B74','XX100B5F','XX100237','XX1004D9','XX100B60','XX10020C','XX10020F','XX100B18','XX100378','XX100387','XX10038B','XX100855','XX100385','XX100455','XX10090D','XX100381','XX100456','XX100453','XX100454','XX100457','XX100458','XX100459','XX1000C6','XX1000C7','XX1000C8','XX1000C9','XX100445','XX100212','XX1002D1','XX1002B7','XX1004F8','XX123456','XX1002B8','XX10027A','XX1002B9','XX1006E2','XX1006E3','XX100B1A','XX10025E','XX10024F','XX100B25','XX100283','XX100862','XX1001F3','XX1000CB','XX100115','XX100111','XX100110','XX100282','XX1002C8','XX1002BA','XX1002BB','XX1009D8','XX10085D','XX1000CC','XX100268','XX1002C1','XX1008EA','XX100870','XX100996','XX1002BF','XX1002C2','XX1002C3','XX10027F','XX100284','XX100279','XX10085B','XX100209','XX1002C0','XX1002BD','XX100278','XX10035F','XX10031A','XX10036A','XX10016C','XX100360','XX1000CD','XX1001E4','XX10031B','XX1002C4','XX100A46','XX100A47','XX100A53','XX100A59','XX100A5B','XX100A5C','XX100A5D','XX100A5E','XX100A5F','XX100A60','XX100A61','XX100A62','XX100A63','XX1002BE','XX100B63','XX1009CD','XX123456','XX100246','XX100AAB','XX1008E0','XX1000E9','XX100825','XX100262','XX10027B','XX10021C','XX1001EC','XX10035A','XX10006F','XX1005BA','XX1001F4','XX100B7A','XX10086B','XX100573','XX100574','XX100666','XX1009B0','XX100599','XX1006D2','XX100608','XX100609','XX10060C','XX10060D','XX100693','XX1005A4','XX100888','XX100A74','XX100A75','XX100A76','XX1009EA','XX100889','XX100B3C','XX1005BE','XX1005BD','XX1005BF','XX1005DD','XX1005E1','XX123456','XX1005E9','XX100679','XX10082B','XX1009B4','XX100807','XX100927','XX100662','XX1006DB','XX10079E','XX100891','XX100AB5','XX100AB7','XX10067C','XX10067D','XX10067E','XX10067F','XX100931','XX100932','XX100AE0','XX1007A2','XX100575','XX1009BE','XX1009B8','XX1009B7','XX10010A','XX100101','XX10008B','XX100104','XX100105','XX10023F','XX1005C6','XX1008E4','XX10028D','XX100B70','XX100B67','XX100B66','XX100B6B','XX100B6F','XX100B6C','XX100B6D','XX10028E','XX10021D','XX10088B','XX10028C','XX10085A','XX123456','XX10052E','XX100217','XX1002C6','XX100280','XX10085E','XX1002C7','XX100724','XX1000CE','XX1000CF','XX123456','XX10021A','XX100254','XX100652','XX100653','XX10044F','XX100155','XX1000B4','XX100B39','XX100B38','XX100293','XX10023E','XX1000F1','XX1000EE','XX1000F0','XX1000EF','XX10026B','XX100A21','XX100253','XX1008AF','XX123456','XX100A11','XX100B17','XX10095C','XX1002C9','XX1004AC','XX1004D7','XX1007E5','XX100A1B','XX100860','XX100294','XX100710','XX1005FC','XX100296','XX100297','XX1002CA','XX100A50','XX100A4C','XX10087C','XX10087D','XX10087B','XX100A4F','XX100A4E','XX10020D','XX100295','XX100281','XX10020E','XX123456','XX100859','XX100AFF','XX100B1F','XX100716','XX100B0F','XX1009DE','XX100B1E','XX100B1C','XX100B1D','XX100AAA','XX100026','XX100935','XX10099A','XX10099B','XX10074D','XX1007C2','XX1007C4','XX1007C5','XX1007CF','XX1007D2','XX1007D3','XX1007D4','XX1007D8','XX1007DA','XX1007DB','XX1007DF','XX100A3E','XX100AC7','XX10093E','XX1000EC','XX10044D','XX100260','XX100298','XX10093C'
$Output = @()
$i = 1
$total = $CollIDs.Length
ForEach ($CollID in $CollIDs)
{
    $CPaths = $null
    $SPaths = $null
    $CPath = $null
    $SPath = $null
    Write-Host "Checking $i of $total - $CollID"
    $CPaths = Get-ObjectLocation -InstanceKey $CollID
    If ($CPaths -ne $null)
    {
        $SPaths = $CPaths.Split(',').trim()
        ForEach ($SPath in $SPaths)
        {
            If ($SPath -ne ''){$output += "$CollID,$SPath"}
        }
    }
    Else
    {
        $output += "$CollID,Root"
    }
    $i++
}
$output | sort
$Results = $output | sort
$CurrentDirectory = 'D:\Powershell\!SCCM_PS_scripts\!Collections'
'Collection ID,Folder Path' | Set-Content "$CurrentDirectory\Get_Collection_Paths--Results.csv"
$Results | Add-Content "$CurrentDirectory\Get_Collection_Paths--Results.csv"
