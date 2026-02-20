WScript.Echo GetAuditData("{0CCE9219-69AE-11D9-BED3-505054503030}")
Function GetAuditData(subcategory)
	Set objWshell = WScript.CreateObject("WScript.Shell")
	Set oExec = objWshell.Exec("auditPol.exe /get /subcategory:""" & subcategory & """ /r")

	' Wait for program to finish
	timeout = 200
	Do While oExec.Status = 0 And timeout > 0
		WScript.Sleep 10
		timeout = timeout - 1
	Loop

	If oExec.Status = 0 Then
		GetAuditData = "ERROR: Timed Out"
	Else
		Result = oExec.StdOut.ReadAll
		If Result = "" Then
			GetAuditData =  "ERROR: Get Data Failed"
		Else
			Values = Split(Result, ",")
			ActualValue = Values(ubound(values)-1)      
			GetAuditData = ActualValue  
		End If
	End If  
End Function