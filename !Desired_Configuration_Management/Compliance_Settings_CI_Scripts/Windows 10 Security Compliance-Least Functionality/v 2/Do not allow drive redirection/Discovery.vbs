Option explicit
WScript.Echo CheckFooSetting()

Public Const ResultSeparator = ";"
Public Const SubscriptOutOfRangeError = 9

' A class that represents a check against a single registry
Class RegCheck
	
	'HKEY_LOCAL_MACHINE
	'HKEY_CURRENT_USER
	Private m_Hive
	
	Private m_KeyPath
	Private m_ValueName
	Private m_ExpectedValue
	Private m_ActualValue
	
	'Equals
	'GreaterThen
	'LessThen
	'GreaterThanEquals
	'LessThenEquals
	Private m_Operation
	
	Private m_IsPassed
	
	' Properties and methods go here.
	
	Public Property Let Hive(regHive)
		m_Hive = regHive
	End Property

	Public Property Let KeyPath(regKeyPath)
		m_KeyPath = regKeyPath
	End Property

	Public Property Let ValueName(regValueName)
		m_ValueName = regValueName
	End Property

	Public Property Let ExpectedValue(regExpectedValue)
		m_ExpectedValue = regExpectedValue
	End Property

	Public Property Let Operation(regOperation)
		m_Operation = regOperation
	End Property

	Public Property Get IsPassed
		IsPassed = m_IsPassed
	End Property
	
	' Return a full path that is from the combination of Hive, RegPath and ValueName
	Private Property Get RegFullPath

        RegFullPath = m_Hive
        
		If UCase(m_Hive) = "HKEY_LOCAL_MACHINE" Then
			RegFullPath = "HKLM"
		Else 
			If UCase(m_Hive) = "HKEY_CURRENT_USER" Then
				RegFullPath = "HKCU"
			End If
		End If
		
		RegFullPath = RegFullPath & "\" & m_KeyPath & "\" & m_ValueName
	
	End Property
	
	' Return a string about the detailed check failure or empty string that means the check was passed
	Public Function GetCheckResult
		If m_IsPassed Then
			GetCheckResult = ""
		Else
			GetCheckResult = "  Registry Validation Failure: " & RegFullPath & ", Expected Value: " & m_ExpectedValue & ", Actual Value: " & m_ActualValue
		End If
	End Function

	Public Sub Check()

		On Error Resume Next

		'WScript.Echo Hive & vbCrLf
		'WScript.Echo KeyPath & vbCrLf
		'WScript.Echo ValueName & vbCrLf
		'WScript.Echo ExpectedValue & vbCrLf
		'WScript.Echo Operatino & vbCrLf

		m_IsPassed = False
		
		Dim ReaderObject
		Dim RegKey
		
		RegKey = RegFullPath
		
		Set ReaderObject = WScript.CreateObject("WScript.Shell")

		Err.Clear
		m_ActualValue = ReaderObject.RegRead(RegKey)
		If Err.Number <> 0 Then

			'WScript.Echo Err.Number
			'WScript.Echo Err.Description
			
			' "NO KEY" is a special case
			If UCase(m_ExpectedValue) = "NO KEY" Then
				m_IsPassed = True
				Exit Sub
			End If
		
			m_ActualValue = "NO KEY"
			m_IsPassed = False
			Exit Sub
		End If
		
		Select Case m_Operation
			Case "Equals"
				If m_ExpectedValue = CStr(m_ActualValue) Then
					'WScript.Echo m_ActualValue & vbCrLf
					m_IsPassed = True
					Exit Sub
				End If
			' Only support Equals
			'GreaterThen
			'LessThen
			'GreaterThanEquals
			'LessThenEquals
		End Select
		
	End Sub
	
End Class

' A rule class that represents a SettingRule or Option Rule
' In the rule, we have one or multiple registry check
' So far, If all the registry checks passed, the rule passed, otherwise not passed.
Class RuleCheck

	Private m_Name
	Private m_ExpectedValue
	private m_IsPassed
	
	Private m_RegCheckArray()

	Public Property Let Name(ruleName)
		m_Name = ruleName
	End Property

	Public Property Let ExpectedValue(ruleExpectedValue)
		m_ExpectedValue = ruleExpectedValue
	End Property

	Public Property Get IsPassed
		IsPassed = m_IsPassed
	End Property
	
	' Add an registry check to the registry check list
	Public Sub AddRegistryCheck(regCheckObj)
		
		On Error Resume Next
		Err.Clear
		
		If regCheckObj Is Nothing Then
			Exit Sub
		End If
		
		Dim n
		n = ubound(m_RegCheckArray)
		If Err.Number = SubscriptOutOfRangeError Then
			ReDim m_RegCheckArray(1)
			Set m_RegCheckArray(0) = regCheckObj
		Else
			ReDim Preserve m_RegCheckArray(n + 1)
			Set m_RegCheckArray(n) = regCheckObj
		End If
		
	End Sub
	
	' Return a string about the detailed failures (include sub check in registry) 
	' or empty string that means comliance against the rule
	Public Function GetCheckResult(showRegistryResult)
	
		On Error Resume Next
		
		Dim isPassed
		isPassed = True
		
		Dim result
		result = ""
		
		Dim n
		n = ubound(m_RegCheckArray)
		If Err.Number = SubscriptOutOfRangeError Then
			GetCheckResult = ""
			Exit Function
		End If

		' Get each failed registry check result
		If n > 0 Then
			Dim i
			Dim regCheckObj
			
			For i = 0 to n - 1
				Set regCheckObj = m_RegCheckArray(i)
				If Not regCheckObj.IsPassed Then
					isPassed = False

                    if (showRegistryResult) Then
					    If result <> "" Then
						    result = result & ResultSeparator
					    End If
					    result = result & regCheckObj.GetCheckResult()
					End If
					
				End If
			Next
		End If
		
		' show rule validation failure
		If Not isPassed Then
		
			GetCheckResult = "Rule Validation Failure: " & """" & m_Name & """" & ResultSeparator & _
			                 "  Expected Value: " & """" & m_ExpectedValue & """"
			                 
			if (showRegistryResult) Then
			    GetCheckResult = GetCheckResult & ResultSeparator & result
			End If
			                 
		End If
		
	End Function
	
	' Check this rule (check all registries in the rules)
	Public Sub Check()

		On Error Resume Next
		Err.Clear
		
		m_IsPassed = True
		
		Dim n
		n = ubound(m_RegCheckArray)
		If Err.Number = SubscriptOutOfRangeError Then
			Exit Sub
		End If
		
		Dim i
		For i = 0 to n - 1
			m_RegCheckArray(i).Check()

			If (Not m_RegCheckArray(i).IsPassed) Then
			    m_IsPassed = False    
			End If
		Next

	End Sub
	
End Class

' Main entry
Function CheckFooSetting()

	On Error Resume Next

	Dim ruleCheck
	Dim regCheckObj
	Dim isPassed

    isPassed = True
	CheckFooSetting = ""
	
	' The following code will be generated according Setting ADMX defination

	' Code Generation Begin

Set ruleCheck = new RuleCheck
ruleCheck.Name = "Do not allow drive redirection"
ruleCheck.ExpectedValue = "Disabled"
Set regCheckObj = new RegCheck
regCheckObj.Hive = "HKEY_LOCAL_MACHINE"
regCheckObj.KeyPath = "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
regCheckObj.ValueName = "fDisableCdm"
regCheckObj.ExpectedValue = "0"
regCheckObj.Operation = "Equals"
ruleCheck.AddRegistryCheck(regCheckObj)
Set regCheckObj = Nothing
ruleCheck.Check()
If (Not ruleCheck.IsPassed) Then
    isPassed = False
End If
CheckFooSetting = CheckFooSetting & ruleCheck.GetCheckResult(False) & ";  "


		
	' Code Generation End
	
	If isPassed Then
		CheckFooSetting = "Disabled"
	End If

End Function