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
        Set-Location SS1:
        CD SS1:
    }
    Catch [System.Exception]
    {
        $Oops = $error[0]
        If ($Oops -like "Cannot find drive. A drive with the name 'SS1' does not exist.")
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
    $SiteServer = 'SCCMSERVER'
    $SiteCode = 'SS1'
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


$CollIDs = 'SS10044B','SS10044C','SS10008A','SS100A39','SS10091B','SS10094E','SS10094D','SS1009BB','SS100261','SS100A9C','SS10068E','SS10068D','SS10068B','SS10068A','SS100689','SS100688','SS100AE2','SS100B61','SS1009AE','SS1009AF','SS100AE5','SS100AE6','SS10022E','SS10024A','SS10022D','SS100719','SS1005C4','SS1004C9','SS1000F2','SS1009B2','SS1001B9','SS1001BD','SS1001BB','SS1001BC','SS100067','SS100145','SS100694','SS1008B9','SS1008B8','SS1008BB','SS100443','SS10089D','SS1004F6','SS1005ED','SS10092B','SS1000BC','SS1005D3','SS10006D','SS1004E1','SS100065','SS10065B','SS1001D3','SS10067B','SS1000DD','SS10088A','SS100194','SS100195','SS1004D5','SS1003F4','SS1003F2','SS1001D5','SS10011A','SS1007EB','SS1005DA','SS100A40','SS10006E','SS1008BD','SS1007F0','SS1007EE','SS1007EF','SS1007ED','SS1007EC','SS100A3C','SS100A88','SS1009F9','SS1009F8','SS1009FA','SS1009FB','SS100063','SS100790','SS10006C','SS1009FC','SS10012A','SS100148','SS100066','SS1004FA','SS100425','SS10006A','SS100423','SS100069','SS10019E','SS1004F9','SS1004D1','SS100ADC','SS100ADD','SS100ADE','SS100ADF','SS100B73','SS100068','SS1009F6','SS1009F5','SS1009F7','SS100B6E','SS1001BA','SS1009B5','SS1008DF','SS100192','SS100193','SS10036D','SS10085F','SS10068F','SS100831','SS100830','SS100690','SS10022F','SS10028A','SS10064A','SS1000B6','SS1002A6','SS1002A4','SS10020A','SS100289','SS100250','SS100255','SS1008BC','SS1008BE','SS1008BF','SS1008C0','SS1008C1','SS1008C2','SS1008C3','SS1008C4','SS1008C5','SS1008C6','SS1002A5','SS1002FA','SS1000B3','SS100A9D','SS100230','SS100B30','SS10026A','SS10094B','SS10094C','SS100532','SS100215','SS100AE7','SS1009EE','SS10093D','SS1009E9','SS10043D','SS100440','SS10043C','SS100444','SS10043E','SS100441','SS10007A','SS100AE8','SS10024B','SS100266','SS100231','SS10099E','SS100496','SS100497','SS100239','SS100A6A','SS100A6B','SS100A05','SS1002BC','SS1001FE','SS1000B5','SS10012E','SS100277','SS10097B','SS10090F','SS10047B','SS100264','SS10024C','SS1009F0','SS1009F1','SS1009F3','SS1009F2','SS1005AA','SS100118','SS100AA2','SS1009F4','SS100233','SS100240','SS10071B','SS100812','SS100659','SS10021E','SS1001EA','SS10027C','SS10021B','SS100234','SS1002A7','SS100235','SS100373','SS100517','SS1000B7','SS100200','SS1002CB','SS1002AA','SS1001EF','SS1000E7','SS100B62','SS100528','SS1001EE','SS1007E9','SS100826','SS1007EA','SS100924','SS1002AB','SS100A42','SS100AFB','SS1008E9','SS100B11','SS1006FD','SS1006FE','SS1006FF','SS1006FA','SS1006FB','SS100784','SS100700','SS100701','SS100702','SS100AFC','SS100AFD','SS100703','SS1007A1','SS1007E2','SS100236','SS10052F','SS100519','SS1000BA','SS10034C','SS100B12','SS100201','SS1002A9','SS100275','SS100B32','SS10025B','SS1001EB','SS100210','SS100270','SS1001F5','SS100287','SS1002AC','SS100332','SS100249','SS100869','SS100B0A','SS100B5E','SS100933','SS100B5D','SS1004A9','SS100923','SS100922','SS1009D9','SS100025','SS10011F','SS100150','SS100151','SS1002AD','SS100A22','SS1004CE','SS100938','SS10065E','SS100937','SS1004DA','SS100562','SS100563','SS100A71','SS100AA7','SS1008A1','SS100AA6','SS10041C','SS100B01','SS100290','SS100247','SS100276','SS1001F0','SS10027E','SS10085C','SS1002AF','SS100244','SS100267','SS10026E','SS100A41','SS100A45','SS1004EF','SS1004F1','SS1004F4','SS1004F7','SS1000E6','SS100204','SS1001ED','SS1002E5','SS1002EF','SS1002DC','SS100523','SS1002B5','SS1003EB','SS1000BB','SS1000B8','SS1000B9','SS10026C','SS1000BD','SS1002A8','SS100242','SS100265','SS1000BE','SS100258','SS100259','SS1004C8','SS10023A','SS100232','SS100521','SS1000BF','SS1000C0','SS1009D6','SS1009CA','SS100206','SS1002B0','SS100B2D','SS100813','SS100B27','SS100B26','SS10068C','SS10087E','SS100B36','SS100269','SS10084D','SS10084C','SS1004EE','SS100810','SS10091F','SS100A36','SS100ADA','SS100AAD','SS100987','SS100B75','SS100B42','SS100216','SS10072E','SS10072F','SS1000C1','SS1001A2','SS1005EF','SS100AAC','SS10025D','SS100948','SS100945','SS100949','SS100953','SS100B28','SS10026D','SS1002B1','SS100243','SS10051B','SS1000C2','SS1000C3','SS1007A4','SS100245','SS1007F2','SS100B02','SS100B03','SS10070A','SS10070B','SS10070C','SS100705','SS100704','SS100852','SS100709','SS1002B3','SS1004D8','SS1002B2','SS100271','SS1002B4','SS1006A8','SS100205','SS100286','SS100214','SS10025A','SS100272','SS1001A9','SS10020B','SS100256','SS1002CC','SS100881','SS100882','SS10088D','SS100B44','SS100B45','SS100B46','SS100B47','SS100B48','SS100B49','SS100B4A','SS100B4B','SS100B4C','SS100B4D','SS100B4E','SS100B50','SS100B51','SS100B52','SS100B53','SS100B43','SS100367','SS1009A0','SS100248','SS1009AC','SS100B77','SS100238','SS100B3D','SS1005C3','SS1000C5','SS100530','SS10023C','SS1002B6','SS10089E','SS100B16','SS100B72','SS100B74','SS100B5F','SS100237','SS1004D9','SS100B60','SS10020C','SS10020F','SS100B18','SS100378','SS100387','SS10038B','SS100855','SS100385','SS100455','SS10090D','SS100381','SS100456','SS100453','SS100454','SS100457','SS100458','SS100459','SS1000C6','SS1000C7','SS1000C8','SS1000C9','SS100445','SS100212','SS1002D1','SS1002B7','SS1004F8','SS1004E0','SS1002B8','SS10027A','SS1002B9','SS1006E2','SS1006E3','SS100B1A','SS10025E','SS10024F','SS100B25','SS100283','SS100862','SS1001F3','SS1000CB','SS100115','SS100111','SS100110','SS100282','SS1002C8','SS1002BA','SS1002BB','SS1009D8','SS10085D','SS1000CC','SS100268','SS1002C1','SS1008EA','SS100870','SS100996','SS1002BF','SS1002C2','SS1002C3','SS10027F','SS100284','SS100279','SS10085B','SS100209','SS1002C0','SS1002BD','SS100278','SS10035F','SS10031A','SS10036A','SS10016C','SS100360','SS1000CD','SS1001E4','SS10031B','SS1002C4','SS100A46','SS100A47','SS100A53','SS100A59','SS100A5B','SS100A5C','SS100A5D','SS100A5E','SS100A5F','SS100A60','SS100A61','SS100A62','SS100A63','SS1002BE','SS100B63','SS1009CD','SS100274','SS100246','SS100AAB','SS1008E0','SS1000E9','SS100825','SS100262','SS10027B','SS10021C','SS1001EC','SS10035A','SS10006F','SS1005BA','SS1001F4','SS100B7A','SS10086B','SS100573','SS100574','SS100666','SS1009B0','SS100599','SS1006D2','SS100608','SS100609','SS10060C','SS10060D','SS100693','SS1005A4','SS100888','SS100A74','SS100A75','SS100A76','SS1009EA','SS100889','SS100B3C','SS1005BE','SS1005BD','SS1005BF','SS1005DD','SS1005E1','SS1005E8','SS1005E9','SS100679','SS10082B','SS1009B4','SS100807','SS100927','SS100662','SS1006DB','SS10079E','SS100891','SS100AB5','SS100AB7','SS10067C','SS10067D','SS10067E','SS10067F','SS100931','SS100932','SS100AE0','SS1007A2','SS100575','SS1009BE','SS1009B8','SS1009B7','SS10010A','SS100101','SS10008B','SS100104','SS100105','SS10023F','SS1005C6','SS1008E4','SS10028D','SS100B70','SS100B67','SS100B66','SS100B6B','SS100B6F','SS100B6C','SS100B6D','SS10028E','SS10021D','SS10088B','SS10028C','SS10085A','SS10028F','SS10052E','SS100217','SS1002C6','SS100280','SS10085E','SS1002C7','SS100724','SS1000CE','SS1000CF','SS100291','SS10021A','SS100254','SS100652','SS100653','SS10044F','SS100155','SS1000B4','SS100B39','SS100B38','SS100293','SS10023E','SS1000F1','SS1000EE','SS1000F0','SS1000EF','SS10026B','SS100A21','SS100253','SS1008AF','SS100515','SS100A11','SS100B17','SS10095C','SS1002C9','SS1004AC','SS1004D7','SS1007E5','SS100A1B','SS100860','SS100294','SS100710','SS1005FC','SS100296','SS100297','SS1002CA','SS100A50','SS100A4C','SS10087C','SS10087D','SS10087B','SS100A4F','SS100A4E','SS10020D','SS100295','SS100281','SS10020E','SS100531','SS100859','SS100AFF','SS100B1F','SS100716','SS100B0F','SS1009DE','SS100B1E','SS100B1C','SS100B1D','SS100AAA','SS100026','SS100935','SS10099A','SS10099B','SS10074D','SS1007C2','SS1007C4','SS1007C5','SS1007CF','SS1007D2','SS1007D3','SS1007D4','SS1007D8','SS1007DA','SS1007DB','SS1007DF','SS100A3E','SS100AC7','SS10093E','SS1000EC','SS10044D','SS100260','SS100298','SS10093C'
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