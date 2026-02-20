Option Explicit
WScript.Echo CheckRange("root\rsop\computer", "RSOP_SecuritySettingNumeric", "Setting", "KeyName='LockoutBadCount' And precedence=1", "3")
Function CheckRange(wmiNamespace, wmiClass, wmiProperty, wmiWhere, ExpectedValue)
 On Error Resume Next
 Err.Clear

 ' if "3" = "No Key", CInt() will failed, set ExpectedValue = -1 in that case.
 ExpectedValue = CInt(ExpectedValue)
 If (Err.Number <> 0) Then
  ExpectedValue = -1
  Err.Clear
 End If
 'WScript.Echo "ExpectedValue: " & ExpectedValue
 
 Dim Compliant, NonCompliant, CurrentValue

 ' Read Current value in this client
 CurrentValue = GetCurrentValue(wmiNamespace, wmiClass, wmiProperty, wmiWhere)
 'WScript.Echo "CurrentValue: " & CurrentValue
 ' Case: Current Value = No Key
 If (CurrentValue = "") Then
  'WScript.Echo "CurrentValue: No Key"
  CheckRange = ""
  Exit Function
 End If
 
 CurrentValue = CInt(CurrentValue)
 
 ' set Compliant and NonCompliant return value
 Compliant = ExpectedValue
 NonCompliant = CurrentValue

 ' Case: If ExpectedValue = 0, Means Unlimited, any value (CurrentValue) is Compliant
    If (ExpectedValue = 0) Then
  CheckRange = Compliant
  Exit Function
 End If

 ' Case: If ExpectedValue <> 0, The CurrentValue should LessEqules Expected Value, that is Compliant
 If (CurrentValue <= ExpectedValue) Then
  CheckRange = Compliant
  Exit Function
    End If
 
 ' Other Case: NonCompliant
 CheckRange = NonCompliant
 
End Function

Function GetCurrentValue(wmiNamespace, wmiClass, wmiProperty, wmiWhere)
 On Error Resume Next
    Err.Clear

    ' Get WMI data
    Dim objWMIService, strWQL, objSettings, objInstance
    Set objWMIService = GetObject("winmgmts:\\.\" + wmiNamespace)
    strWQL = "Select " + wmiProperty +" from " + wmiClass + " where " + wmiWhere
    Set objSettings = objWMIService.ExecQuery(strWQL)
    
    For Each objInstance in objSettings 
  GetCurrentValue = objInstance.Setting
  Exit For
    Next

 ' Case: No Key
 If (Err.Number <> 0) Then
  Err.Clear
  GetCurrentValue = ""
  Exit Function
 End If
End Function