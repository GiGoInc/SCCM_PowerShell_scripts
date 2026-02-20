On Error Resume Next

'***  Define string variables - default value for this is 100 (retries)

Class_Name = 		"SMS_SCI_Component"
Class_ItemName =	"SMS_DISTRIBUTION_MANAGER|msdcsccm1.lighthouse.hhc"
Class_ItemType =	"Component"
Property_Name = 	"PullDP Number Of Queries"
Property_SiteCode = 	"DC1"
DesiredValue =		100
CreateIfNotPresent =	"False"

'***  Check parameters - we need the provider server name and the site code

set args=wscript.arguments

If args.Count = 2 then
	SMSProviderServer = UCASE(Wscript.Arguments(0))
	SiteCode = UCASE(Wscript.Arguments(1))
Else
	wscript.Echo "Incorrect command line arguments." & vbCrLf & "Usage: cscript /nologo ModifySCFProperty.vbs <smsproviderserver> <sitecode>" & vbCrLf & "Example: cscript /nologo ModifySCFProperty.vbs SERVER1 S01" & vbCrLf
	WScript.Quit(1)
End If


'***  Connect to the provider - report the error and terminate on failure

SMSProviderServer = "\\" + SMSProviderServer + "\"
Set ObjSvc = GetObject("winmgmts:" & "{impersonationLevel=Impersonate,authenticationLevel=Pkt}!" & SMSProviderServer & "root\sms\site_" & SiteCode)

If Err.Number <> 0 Then
	wscript.Echo "Failed to connect to provider server with code: " & Err.Number & ".  Aborting!"
	WScript.Quit(2)
End If

'***  Get the desired instance of the class

Set objInst = ObjSvc.Get(Class_Name & ".ItemName='" & Class_ItemName & "',ItemType='" & Class_ItemType & "',SiteCode='" & Property_SiteCode &"'")

If Err.Number <> 0 Then
	WScript.Echo "Failed to open desired object with error code " & Err.Number & " (" & Err.Description & ").  Aborting!"
	WScript.Quit(3)
End If

'***  Loop through the Properties until we find a match or run out

bFoundProperty = False

If not IsNull (objInst.Props) Then
	For Each objProp in objInst.Props
		If objProp.PropertyName = Property_Name Then
			bFoundProperty = True
			Exit For
		End If
	Next
End If

If bFoundProperty = False Then
	If CreateIfNotPresent <> "True" Then
		WScript.Echo "Desired object was found but property was not found.  Exiting without making any changes."
		WScript.Quit(4)
	End If

	Dim NewProp
	Set NewProp = objSvc.Get("SMS_EmbeddedProperty").Spawninstance_()

	NewProp.PropertyName = Property_Name
	NewProp.Value = DesiredValue

	If IsNull (objInst.Props) Then
		objInst.Props = array(NewProp)
	Else
		Dim tempProps
		tempProps = objInst.Props
		Redim Preserve tempProps(UBound(tempProps)+1)
		set tempProps(UBound(tempProps)) = NewProp
		objInst.Props = tempProps
	End If

	objInst.Put_

	If Err.Number <> 0 Then
		wscript.Echo "Failed to add the desired property with code: " & Err.Number & ".  Aborting!"
		WScript.Quit(5)
	End If

	wscript.Echo "Property '" & Property_Name & "' successfully added with value '" & DesiredValue & "'."
Else
	If objProp.Value = DesiredValue Then
		WScript.Echo "Property '" & Property_Name & "' found with desired value '" & DesiredValue & "'.  Not making any changes."
		WScript.Quit(0)
	Else
		OriginalValue = objProp.Value
		objProp.Value = DesiredValue
		objProp.Put_
		objInst.Put_

		If Err.Number <> 0 Then
			wscript.Echo "Failed to save the desired change with code: " & Err.Number & ".  Aborting!"
			WScript.Quit(6)
		Else
			WScript.Echo "Property '" & Property_Name & "' successfully changed from '" & OriginalValue & "' to '" & DesiredValue & "'."
		End If
	End If
End If