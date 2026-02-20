Option Explicit
WScript.Echo CheckRange("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\maximumpasswordage", "30")
Function CheckRange(RegKey, ExpectedValue)
    On Error Resume Next
 Err.Clear

 ' if "30" = "No Key", CInt() will failed, set ExpectedValue = -1 in that case.
 ExpectedValue = CInt(ExpectedValue)
 If (Err.Number <> 0) Then
  ExpectedValue = -1
  Err.Clear
 End If
 'WScript.Echo "ExpectedValue: " & ExpectedValue
 
 Dim Compliant, NonCompliant, CurrentValue

 ' Read Current value in this client
 CurrentValue = GetCurrentValue(RegKey)
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

Function GetCurrentValue(RegKey)
 On Error Resume Next
    Err.Clear

    Dim RegObject 
    Set RegObject = WScript.CreateObject("WScript.Shell")
    GetCurrentValue = RegObject.RegRead(RegKey)
 ' Case: No Key
 If (Err.Number <> 0) Then
  Err.Clear
  GetCurrentValue = ""
  Exit Function
 End If
End Function