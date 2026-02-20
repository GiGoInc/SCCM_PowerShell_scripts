WScript.Echo ValidateSetting("root\rsop\computer", "RSOP_UserPrivilegeRight", "UserRight='SeTakeOwnershipPrivilege' and precedence=1", "AccountList", "Administrators")
Function ValidateSetting(wmiNamespace, wmiClass, wmiWhere, wmiProperty, baselineValue)
 
 on error resume next

 ' Get expected values and actual valuse we are testing against
 Dim ExpectedValues, ActualValues
    ExpectedValues = baselineValue

    ' Poll WMI
    Dim objWMIService, strWQL, objSettings
    Set objWMIService = GetObject("winmgmts:\\.\" + wmiNamespace)
    strWQL = "Select * from " + wmiClass + " where " + wmiWhere
    Set objSettings = objWMIService.ExecQuery(strWQL)

    ' Set ActualValues for case where no settings are found.
    If objSettings.Count = 0 Then
        Select Case wmiClass
            Case "RSOP_AuditPolicy"
                ActualValues = "NO AUDITING"
            Case "RSOP_UserPrivilegeRight"
                ActualValues = "NO ONE"
            Case Else
                ActualValues = "Invalid wmiClass parameter: " + wmiClass
        End Select
    Else
        ' Set ActualValues with actual settings.
        ActualValues = PollWMIForSettings (objSettings, UCase(wmiProperty))
    End If
    
    ' do our validation
    ValidateSetting = ValidateResults(wmiClass, ExpectedValues, ActualValues)
 
 ' do error checking, make sure our function return something.
 If ValidateSetting = "" Then
  ValidateSetting = "ValidateSetting return Nothing or Empty"
  If Err.Number <> 0 Then
      ValidateSetting = ValidateSetting & ", Error: " & Err.Number
      ValidateSetting = ValidateSetting & ", Error (Hex): " & Hex(Err.Number)
      ValidateSetting = ValidateSetting & ", Source: " &  Err.Source
      ValidateSetting = ValidateSetting & ", Description: " &  Err.Description
      Err.Clear
  End If
 End If
  
End Function

'compare two list, isExactMatch=true means two list need exactly macth.
Function CompareTwoListString(expectedListString, actualListString, isExactMatch)
    on error resume next
    
     ' verify that the actual list is exectly equal to the expected list.
    Dim ActualValueList, ExpectedValueList, ActualValue, ExpectedValue, Result 
    ActualValueList = Split(UCase(actualListString), ",")
    ExpectedValueList = Split(UCase(expectedListString), ",")

    If isExactMatch = true AND UBound(ExpectedValueList) <> UBound(ActualValueList) Then
        CompareTwoListString = false
        Exit Function
    End If
        
    ' Verify all the actual values are in the list of expected values
    For Each ActualValue in ActualValueList
        ' Find if actual value is in list of expected values
        Result = false
        For Each ExpectedValue in ExpectedValueList
            If Trim(ActualValue) = Trim(ExpectedValue) Then
                Result = true
                Exit For
            End If
        Next

        If Result = false Then
            CompareTwoListString = false
            Exit Function
        End If
    Next

    'if no need exectly match, when actual value is sub-set of expect value, will return true.
    If isExactMatch <> true Then
        CompareTwoListString = true
        Exit Function
    End If
    
    ' If we want exactly mathc, so verify all the expected value are in the list of actual value
    For Each ExpectedValue in ExpectedValueList
        ' Find if expected value is in list of actual values
        Result = false
        For Each ActualValue in ActualValueList
            If Trim(ActualValue) = Trim(ExpectedValue) Then
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

' Validate results
Function ValidateResults(wmiClass, ExpectedValues, ActualValues)

 on error resume next

    Select Case wmiClass
        Case "RSOP_AuditPolicy"
            If ActualValues = "" Then
                If UCase(ExpectedValues) = "NO AUDITING" Then
                    ValidateResults = ExpectedValues
                Else
                    ValidateResults = "No Auditing"
                End If
                Exit Function
            End If
            
            If CompareTwoListString(ExpectedValues, ActualValues, true) = true Then
                ValidateResults = ExpectedValues
            Else
                ValidateResults = ActualValues
            End If

        Case "RSOP_UserPrivilegeRight"
            ' We are always in compliant if no one has the privilege
            If Trim(ActualValues) = "" Or UCase(Trim(ActualValues)) = "NO ONE" Then
                ValidateResults = ExpectedValues
                Exit Function
            End If
            
            If CompareTwoListString(ExpectedValues, ActualValues, true) = true Then
                ValidateResults = ExpectedValues
            Else
                ValidateResults = ActualValues
            End If

        Case Else
            ' Just return the actual value
            ValidateResults = ActualValues
    End Select
End Function

' Set ActualValues to a comma deliminated list of values defined by what settings we are polling.
Function PollWMIForSettings(objSettings, wmiProperty)

 on error resume next

    Dim ActualValues, objSetting, value
    ActualValues = ""
            
    ' Go through all properties
    For Each objSetting in objSettings
        For Each value in Split(wmiProperty, ",")
            Select Case UCase(Trim(value))
                Case "SUCCESS"
                    If objSetting.Success = True Then
                        If ActualValues <> "" Then
                            ActualValues = ActualValues + ","
                        End If
                        ActualValues = ActualValues + "SUCCESS"
                    End If

                Case "FAILURE"
                    If objSetting.Failure = True Then
                        If ActualValues <> "" Then
                            ActualValues = ActualValues + ","
                        End If
                        ActualValues = ActualValues + "FAILURE"
                    End If

                Case "SETTING"
                    If ActualValues <> "" Then
                        ActualValues = ActualValues + ","
                    End If
                    ActualValues = ActualValues + objSetting.Setting

                Case "ACCOUNTLIST"
                    If NOT (IsNull(objSetting) Or IsNull(objSetting.AccountList)) Then
                      For Each strAccount in objSetting.AccountList
                         If ActualValues <> "" Then
                             ActualValues = ActualValues + ","
                         End If
                         ActualValues = ActualValues +  UCase(Right(strAccount, Len(strAccount) - InStrRev(strAccount, "\") ))
                      Next
                    End If
                case Else
                    ActualValues = ActualValues + "--Unknown property: " + value + " :--"
            End Select
        Next
    Next    
    PollWMIForSettings = ActualValues
End Function