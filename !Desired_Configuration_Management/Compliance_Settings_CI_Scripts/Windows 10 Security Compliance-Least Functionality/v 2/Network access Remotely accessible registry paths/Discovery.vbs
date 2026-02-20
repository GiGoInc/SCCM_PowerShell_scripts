Option Explicit
WScript.Echo CheckMultiString("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths\Machine", "System\CurrentControlSet\Control\ProductOptions" & vbCrLf & "System\CurrentControlSet\Control\Server Applications" & vbCrLf & "Software\Microsoft\Windows NT\CurrentVersion")

Function CheckMultiString(RegKey, ExpectedValue)
	On Error Resume Next
	Err.Clear

	Dim currentValueArray, expectedValueArray, temparyExpectedValueArray, isNoKey
	Dim expectedValueCount, currentValueCount, index, compareResult

	' Read Current value in this client
	' The return value of GetCurrentValue() is alread a array.
	currentValueArray = GetCurrentValue(RegKey) 

	'WScript.Echo "currentValueArray:" &  UBound(currentValueArray)

	'split the ExpectedValue to Array
	temparyExpectedValueArray = Split(ExpectedValue, vbCrLf)

	'In the expected value array may contains blank item, we need remove the blank item. 
	'Blank item is invalidate for Registry mutistring value.
	index = 0
	Dim eachExpectedValue 
	ReDim expectedValueArray(UBound(temparyExpectedValueArray))
	For Each eachExpectedValue in temparyExpectedValueArray
		If Trim(eachExpectedValue) <> "" Then
			expectedValueArray(index) = eachExpectedValue
			index = index + 1
		End If
	Next
    
 'Array subscript start from 0, so redim the array with index-1.
 ReDim Preserve expectedValueArray(index - 1)
 'WScript.Echo "expectedValueArray:" &  UBound(expectedValueArray)

 'Exactly compare the expected value with the actual value.
 compareResult = CompareTwoListString(expectedValueArray, currentValueArray)
 
 If compareResult Then
	'WScript.Echo "Reuslt:Compliance"
	CheckMultiString = RebuildReturnValue(expectedValueArray, True)
 Else
    'WScript.Echo "Reuslt:NOT Compliance"
	CheckMultiString = RebuildReturnValue(currentValueArray, False)
 End If
  
End Function

'Get the registry value, return a array.
Function GetCurrentValue(RegKey)
 On Error Resume Next
    Err.Clear

    Dim RegObject
    Set RegObject = WScript.CreateObject("WScript.Shell")
    
    GetCurrentValue = RegObject.RegRead(RegKey)
    
    ' Case: No Key
    If (Err.Number <> 0) Then
        Err.Clear

        'if no this registry key, return a array contains only "NO KEY".
        GetCurrentValue = Array("NO KEY")
    End If 
    
End Function    

'compare two list, two list need exactly macth.
Function CompareTwoListString(ExpectedValueList, ActualValueList)
    on error resume next
    
     ' verify that the actual list is exectly equal to the expected list.
    Dim ActualValue, ExpectedValue, Result 

    If UBound(ExpectedValueList) <> UBound(ActualValueList) Then
        CompareTwoListString = false        
        Exit Function
    End If
        
    ' Verify all the actual values are in the list of expected values
    For Each ActualValue in ActualValueList
        ' Find if actual value is in list of expected values
        Result = false

        For Each ExpectedValue in ExpectedValueList
            If UCase(Trim(ActualValue)) = UCase(Trim(ExpectedValue)) Then
                Result = true
                Exit For
            End If
        Next

        If Result = false Then
            CompareTwoListString = false
            Exit Function
        End If
    Next
    
    ' If we want exactly mathc, so verify all the expected value are in the list of actual value
    For Each ExpectedValue in ExpectedValueList
        ' Find if expected value is in list of actual values
        Result = false
        For Each ActualValue in ActualValueList
            If UCase(Trim(ActualValue)) = UCase(Trim(ExpectedValue)) Then
                Result = true
                Exit For
            End If
        Next

        If Result = false Then
            CompareTwoListString = false
            Exit Function
        End If
    Next

    ' Passsed all tests
    CompareTwoListString = true
End Function

' Rebuild the return value since the DCM connot compare values in multiple string, so 
' we need to make the multiple string to a single string and our expected value is in same 
' format, so DCM is able to handle now.
' For actual value, should be a single string with space char splitted.
' For expected value, use the "%XTransCarriageReturn%" to splitted.
Function RebuildReturnValue(ValueArray, IsExpectedValue)
	On Error Resume Next

	'WScript.Echo UBound(ValueArray)

	Dim returnString
	returnString = ""
	
	Dim splitter
	
	If IsExpectedValue Then
		splitter = "%XTransCarriageReturn%"
	Else
		splitter = " "
	End If
	
	Dim i
	For i=0 to UBound(ValueArray)
		'WScript.Echo ValueArray(i)
		returnString = returnString & ValueArray(i) & splitter
	Next
 
	Dim l
	l = Len(returnString)
	' Remove last splitter
	If l > 0 Then
		'WScript.Echo l-Len(splitter)
		returnString = Left(returnString, l-Len(splitter))
	End If
	
	RebuildReturnValue = returnString
End Function