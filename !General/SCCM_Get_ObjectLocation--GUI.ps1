<#
GenerateForm
Hide-PowerShell
<#
Object 						Class 								Property
Application 				SMS_ApplicationLatest 				ModelName
Package 					SMS_Package 						PackageID
Query 						SMS_Query 							QueryID
Software Metering Rule 		SMS_MeteredProductRule 				SecurityKey
Configuration Item 			SMS_ConfigurationItemLatest 		ModelName
Configuration Baseline 		SMS_ConfigurationBaselineInfo 		ModelName
Operating System Image 		SMS_OperatingSystemInstallPackage 	PackageID
Operating System Package 	SMS_ImagePackage 					PackageID
User State Migration 		SMS_StateMigration 					MigrationID
Boot Image 					SMS_BootImagePackage 				PackageID
Task Sequence 				SMS_TaskSequencePackage 			PackageID
Driver Package 				SMS_DriverPackage 					PackageID
Driver 						SMS_Driver 							ModelName
Software Update 			SMS_SoftwareUpdate 					ModelName
Collection 					SMS_Collection 						CollectionID
#>

Function Get-ObjectLocation
{
    param (
    [string]$InstanceKey
    )
    
    $ContainerNode = Get-WmiObject -Namespace 'root/SMS/site_XX1' -ComputerName 'SERVER' -Query "SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='$InstanceKey'"
    if ($ContainerNode -ne $null) {
        $ObjectFolder = $ContainerNode.Name
        if ($ContainerNode.ParentContainerNodeID -eq 0) {
            $ParentFolder = $false
        }
        else {
            $ParentFolder = $true
            $ParentContainerNodeID = $ContainerNode.ParentContainerNodeID
        }
        while ($ParentFolder -eq $true) {
            $ParentContainerNode = Get-WmiObject -Namespace 'root/SMS/site_XX1' -ComputerName 'SERVER' -Query "SELECT * FROM SMS_ObjectContainerNode WHERE ContainerNodeID = '$ParentContainerNodeID'"
            $ObjectFolder =  $ParentContainerNode.Name + "\" + $ObjectFolder
            if ($ParentContainerNode.ParentContainerNodeID -eq 0) {
                $ParentFolder = $false
            }
            else {
                $ParentContainerNodeID = $ParentContainerNode.ParentContainerNodeID
            }
        }
        $ObjectFolder = "Root\" + $ObjectFolder
        Write-Host "Checking Object: $ObjectFolder"
        $Label_Location.Text = $ObjectFolder
    }
    else {
        $ObjectFolder = "Root"
        Write-Host "Checking Object: $ObjectFolder"
        $Label_Location.Text = $ObjectFolder
    }
}



#Generated Form Function
Function GenerateForm
{
	#Load Assemblies
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

	# here's the base64 string of the image
		$base64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwgAADsIBFShKgAAAABl0RVh0U29mdHdhcmUAcG
		FpbnQubmV0IDQuMC4xMK0KCsAAAAMbSURBVDhPARAD7/wABAsjBhQ0BR5UCCZfDC5nGTdvMEx7WG+UYXSYgZGqkp60kZyylKCzj5yvhZOscoSiAAIDDAQFEQ4dQChDcl1
		wkJumuLrAycjM0tbV3N3h5uPn7OLk6tvd5c7S2szQ2MnN1wAHCRYHDRYvPU6NoLSSobTS297l6e3u6+7rzNHnoae8iYu1l5vi3eDu8PXb3uPe4eYAChEcEhonOEdYfpGp
		coOWz9vi4MXN6W1v7UZE8ERCtlBTpKivsLW64Ofu19zi5ejsABMYJBchLz9SZVNmfae4ydLE0vFYWvZGRPNFRPNIR5A5OMTI0Obq8OPm6ubb3dHKyAA0PU0uPVF+j6abq
		7vH1eLUr7v5U1P7UFHvUE+CLi0QBAQvIyKrTk+YJSecLSypb3AAkaGvhYuU5uLn7tnarnR2n2Fhnjo6dy0uKBITHRYWUEtLYltbvJeZuKalxL6/S0JCAN3Y2+6RkuaJiu
		iSktSSkJ2AhF5bWkg9Oz8/QUhGR7S0tKenp+rq6rGxsZWTlCsmJgDbyczatbTBvsDBv8K7u7ywsK/Oz82fnp+srKyenJ3V1tbDw8Knp6WHhoV6dnY7JCQA0by/2c/Ou7u
		7oZ+gvry8mZeWcXBuZGFgdGprQjc2MSUkKhITMyAhVkpMZFNWWyYoANO2t4RVVDsxMUo0NVZKTF9KS2Q4OWFhY39ERpRRVGVqd4pxdHd2gF9lb3d7f29oagC2pquhZWiH
		j5tziJ1LZHiBkJ2AipQ0VW15hJB5hpJXb4NqgpRedYZ7ipeosLJrbXAAh5OekpeaYoSeiqa4VHqUbI2mdZCih5ehobK9hpeidXl9ipGZgIaNfICHa3J5cHyIAImZo4uZn
		o2epHuHi2p0fWpxdGFpcVFbY2VvdlxlbzxIVmRyf3Z9i3qEkXiFlXmImQBRZXt0h5Nwf4ZldYBseod7h5F4g5J6iZVwgpNmd5AwQV0/UXJabYZJXHsoPWAgNVoAJTxcGT
		JSNk5rMUlpJj1dN0tqHzFUQ1dyJTtdFChMCRg3GS9VMEZnJDteJTtcNElpaO+AgIeMJI4AAAAASUVORK5CYII="

	# Create a streaming image by streaming the base64 string to a bitmap streamsource
		$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
		$bitmap.BeginInit()
		$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
		$bitmap.EndInit()
		$bitmap.Freeze()

	# Display the Main Screen
	Function Display-MainScreen
	{
		# Always Displayed Controls
		    $Form.Controls.Add($Label_Title)
		    $Form.Controls.Add($Label_Item)
		    $Form.Controls.Add($TextBox_Item)
		    $Form.Controls.Add($Button_GetInfo)
		    $Form.Controls.Add($Label_Location)		
	}

	# Define Return Button Click Function
	Function Return-MainScreen
	{
        $Form.Controls.Remove($Label_Title)
        $Form.Controls.Remove($Label_Item)
        $Form.Controls.Remove($TextBox_Item)
        $Form.Controls.Remove($Button_GetInfo)
        $Form.Controls.Remove($Label_Location)		
        $Form.Refresh()
        Display-MainScreen
	}

	# Info based on Object info
	Function GetInfo
	{

        $Info = $TextBox_Item.Text
        Write-Host "Running GetInfo: $Info" -ForegroundColor Cyan
        Get-ObjectLocation -InstanceKey $Info
    }


#------ Define All GUI Objects-------
        # Font styles are: Regular, Bold, Italic, Underline, Strikeout
          $Label_Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
         $TextBox_Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Italic)
        $ComboBox_Font = New-Object System.Drawing.Font("Segoe UI",13,[System.Drawing.FontStyle]::Regular)		
          $Button_Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Regular)	



#########################################################################################################################################
#########################################################################################################################################
	### STATIC INFORMATION - ROW 1
	# App Header/Title Label
		$Label_Title = New-Object System.Windows.Forms.Label
		$Label_Title.Location = new-object System.Drawing.Size(5,3)
		$Label_Title.Size = New-Object System.Drawing.Size(1600,25)
		$Label_Title.ForeColor = "Black"
		$Label_Title.Text = "Input the object info, (like Collection ID) and press the GetInfo button."
		$Label_Title.Font = $Label_Font
		$Label_Title.TextAlign = "MiddleLeft"

	##################################################################################################
	### STATIC INFORMATION - ROW 2
	# Item Label
		$Label_Item = New-Object System.Windows.Forms.Label
		$Label_Item.AutoSize = $False
		$Label_Item.Location = new-object System.Drawing.Size(5,50)
		$Label_Item.Size = New-Object System.Drawing.Size(90,30)
		$Label_Item.ForeColor = "Black"
		$Label_Item.Text = "Object: "
		$Label_Item.Font = $Label_Font
		$Label_Item.TextAlign = "MiddleRight"
	# Item TextBox
	    $TextBox_Item = New-Object System.Windows.Forms.TextBox
	    $TextBox_Item.AutoSize = $False
	    $TextBox_Item.Location = new-object System.Drawing.Size(120,50)
	    $TextBox_Item.Size = New-Object System.Drawing.Size(290,30)
	    $TextBox_Item.Font = $TextBox_Font
	    $TextBox_Item.ForeColor = "Black"

	# GetInfo Button
		$Button_GetInfo = New-Object System.Windows.Forms.Button
		$Button_GetInfo.Location = New-Object System.Drawing.Size(420,50)
		$Button_GetInfo.Size = New-Object System.Drawing.Size(100,30)
		$Button_GetInfo.BackColor ="Green"
		$Button_GetInfo.ForeColor = "Snow"
		$Button_GetInfo.Text = "Get Info"
		$Button_GetInfo.Add_Click({GetInfo})
		$Button_GetInfo.FlatAppearance.BorderColor = "#FF03000C"
		$Button_GetInfo.Font = $Button_Font

	##################################################################################################
	### STATIC INFORMATION - ROW 3
	# Label Label
	    $Label_Location = New-Object System.Windows.Forms.Label
	    $Label_Location.AutoSize = $True
	    $Label_Location.Location = new-object System.Drawing.Size(5,100)
	    $Label_Location.Size = New-Object System.Drawing.Size(950,30)
	    $Label_Location.TextAlign = "MiddleLeft"
	    $Label_Location.Font = $Label_Font
	    $Label_Location.ForeColor = "White"

# -------- This is the start of the ROW info section -------------
# -------- This is the end of the object definition section ------

# -----Draw the empty form----
		$Form = New-Object System.Windows.Forms.Form
		$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
		$Form.width = 1000
		$Form.height = 400
		$Form.BackColor = "SlateGray"
		$Form.Text = "Find Object Location in SCCM"
        $Form.Font = $Font
		#$Form.maximumsize = New-Object System.Drawing.Size(800,1600)
		$Form.startposition = "centerscreen"
		$Form.KeyPreview = $True
		$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter") {}})
		$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Form.Close()}})

	#----Populate the form----
		Display-MainScreen
		$Form.Add_Shown({$Form.Activate()})
		$Form.ShowDialog()

} #End Function

Add-Type -AssemblyName PresentationCore
# Add a helper
$showWindowAsync = Add-Type –memberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name “Win32ShowWindowAsync” -namespace Win32Functions –passThru

function Show-PowerShell()
{
     [void]$showWindowAsync::ShowWindowAsync((Get-Process –id $pid).MainWindowHandle, 10)
}

function Hide-PowerShell()
{
    [void]$showWindowAsync::ShowWindowAsync((Get-Process –id $pid).MainWindowHandle, 2)
}


# Show-Window
Hide-PowerShell
GenerateForm
