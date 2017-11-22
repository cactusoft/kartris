'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports SessionsData
Imports SessionsDataTableAdapters
Imports System.Web.HttpContext
Imports KartSettingsManager
Imports System.Collections

Public Class SessionsBLL

	Enum Using_Cookies
		YES = 1
		NO = 2
		BACKUP = 3
	End Enum

	Private strUsingCookies As String

	Private Const USING_COOKIES_YES As String = "yes"
	Private Const USING_COOKIES_NO As String = "no"
	Private Const USING_COOKIES_BACKUP As String = "backup"
	Private Const VARIABLE_NAME As String = "s"
	Private Const CODE_LENGTH As Integer = 6
	Private DEFAULT_SESSION_EXPIRY As Integer

	Private _AdptrSessions As SessionsTblAdptr = Nothing
	Private _AdptrSessionValues As SessionValuesTblAdptr = Nothing

	Private _SessionCode As String
	Private _SessionID As Long


	Private Class KartSessionValues

		Private strOriginalValue As String
		Private numOriginalExpiry As Integer

		'ID and name are not accessible, but required internally
		Private SESSV_ID As Integer
		Private SESSV_SessionID As Integer
		Private SESSV_Name As String

		'This can be altered outside the class
		Public Value As String				 'The value held
		Public Expiry As Integer			  'Minutes until the value expires
		Public Deleted As Boolean			  'Whether to flag the name/value for deletion

		Private _AdptrSessionValues As SessionValuesTblAdptr = Nothing

		Protected ReadOnly Property AdptrSessionValues() As SessionValuesTblAdptr
			Get
                _AdptrSessionValues = New SessionValuesTblAdptr
                Return _AdptrSessionValues
            End Get
        End Property

    End Class

    ''//
    Public ReadOnly Property SessionCode() As String
        Get
            If _SessionCode = "" Then NewSession()
            Return _SessionCode
        End Get
    End Property

    Public ReadOnly Property SessionIP() As String
        Get
            Return CkartrisEnvironment.GetClientIPAddress()
        End Get
    End Property

    Public ReadOnly Property SessionID() As Long
        Get
            If SessionID = 0 Then NewSession()
            Return _SessionID
        End Get
    End Property
    ''//

    Protected ReadOnly Property AdptrSessions() As SessionsTblAdptr
        Get
            _AdptrSessions = New SessionsTblAdptr
            Return _AdptrSessions
        End Get
    End Property

    Protected ReadOnly Property AdptrSessionValues() As SessionValuesTblAdptr
        Get
            _AdptrSessionValues = New SessionValuesTblAdptr
            Return _AdptrSessionValues
        End Get
    End Property

    Public ReadOnly Property IsBrowser() As Boolean
        Get
            Try
                Dim strHTTPUserAgent As String
                strHTTPUserAgent = LCase(Current.Request.ServerVariables("HTTP_USER_AGENT"))
                If strHTTPUserAgent.Contains("msie") OrElse strHTTPUserAgent.Contains("gecko") OrElse strHTTPUserAgent.Contains("opera") OrElse strHTTPUserAgent.Contains("netscape") OrElse strHTTPUserAgent.Contains("safari") OrElse strHTTPUserAgent.Contains("webkit") Then
                    Return True
                Else
                    Return False
                End If
            Catch ex As Exception
                Return False
            End Try
        End Get
    End Property

    Private Shared Function GetRandomString(ByVal numLength As Integer) As String
        Dim strRandomString As String = ""
        Dim numRandomNumber As Integer

        'Generate a new seed based on the server timer
        Randomize()

        'Loop for as many letters as we need
        Do While Len(strRandomString) < numLength
            'Generate random number	
            numRandomNumber = Int(Rnd(1) * 36) + 1
            If numRandomNumber < 11 Then
                'If it's less than 11 then we'll do a number
                strRandomString = strRandomString & Chr(numRandomNumber + 47)
            Else
                'Otherwise we'll do a letter; + 86 because 96 (min being 97, 'a') - 10 (the first 10 was for the number)
                strRandomString = strRandomString & Chr(numRandomNumber + 86)
            End If
        Loop

        'Zero and 'o' and '1' and 'I' are easily confused...
        'So we replace any of these with alternatives
        'To ensure best randomness, replace the numbers
        'with alternative letters and letters
        'with alternative numbers

        strRandomString = Replace(strRandomString, "0", "X")
        strRandomString = Replace(strRandomString, "1", "Y")
        strRandomString = Replace(strRandomString, "O", "4")
        strRandomString = Replace(strRandomString, "I", "9")

        Return strRandomString
    End Function
    ''//

    Public Sub NewSession()
        Dim COOKIE_NAME, strValue As String
        ''Dim SESS_Values As String = ""
        Dim SESS_DateCreated, SESS_DateLastUpdated As Date
        Dim SESS_Expiry As Integer
        Dim oDT As New Data.DataTable

        If IsBrowser Then

            'Set related config settings
            COOKIE_NAME = HttpSecureCookie.GetCookieName("Basket")
            DEFAULT_SESSION_EXPIRY = CInt(GetKartConfig("general.sessions.expiry"))

            strUsingCookies = LCase(Trim(GetKartConfig("general.sessions.usecookies")))

            'Try and find a session id somewhere. The cookie takes preference (so
            'if a user goes to a page in the history with an old ID, they won't
            'switch sessions and see an old basket, someone elses login etc)
            strValue = ""
            If strUsingCookies <> Trim(LCase(USING_COOKIES_NO)) Then
                If Not (Current.Request.Cookies(COOKIE_NAME) Is Nothing) Then
                    strValue = Current.Request.Cookies(COOKIE_NAME).Item(VARIABLE_NAME)
                End If
                If strValue = "" Then
                    strValue = Current.Request.QueryString(VARIABLE_NAME)
                    If strValue = "" Then strValue = Current.Request.Form(VARIABLE_NAME)
                End If
            End If

            'Check it's the right length
            If Len(strValue & "") < CODE_LENGTH + 1 Then
				_SessionID = 0
				_SessionCode = ""
			Else
				'Get the random code prefix, followed by the ID
				_SessionID = strValue.Substring(CODE_LENGTH)
				_SessionCode = strValue
			End If

			'We set up the session. If we've got a session code then try and pull it
			'out of the database. Keep open the recordset for laters
			If _SessionID > 0 Then

				oDT = AdptrSessions.GetSessionValues(_SessionID, _SessionCode, CkartrisDisplayFunctions.NowOffset)
				If oDT.Rows.Count > 0 Then
					_SessionCode = oDT.Rows(0).Item("SESS_Code") & ""
					SESS_DateLastUpdated = oDT.Rows(0).Item("SESS_DateLastUpdated")
					AdptrSessions.UpdateSessionsDateLastUpdated(CkartrisDisplayFunctions.NowOffset, _SessionID)
				Else
					_SessionCode = ""
					_SessionID = 0
				End If
				oDT.Dispose()
			End If

			'If we haven't got a session, need to create a new one. Need to do an
			'insert now so that we get the database ID
			If _SessionID = 0 Then
				_SessionCode = GetRandomString(CODE_LENGTH)
				SESS_DateCreated = CkartrisDisplayFunctions.NowOffset
				SESS_DateLastUpdated = SESS_DateCreated
				SESS_Expiry = DEFAULT_SESSION_EXPIRY

				_SessionID = AdptrSessions.AddSessions(_SessionCode, SessionIP, SESS_DateCreated, SESS_DateLastUpdated, SESS_Expiry)
				_SessionCode = _SessionCode & _SessionID
			End If

			'Store the session code in a session-length cookie.
			If strUsingCookies <> Trim(LCase(USING_COOKIES_NO)) Then
				If Current.Request.Cookies(COOKIE_NAME) Is Nothing Then
					Current.Response.Cookies(COOKIE_NAME)(VARIABLE_NAME) = _SessionCode
					Current.Response.Cookies(COOKIE_NAME).Expires = CkartrisDisplayFunctions.NowOffset.AddMinutes(DEFAULT_SESSION_EXPIRY)
				End If
			End If

		End If

	End Sub

	'Adds a new name/value pair
	Public Sub Add(ByVal strName As String, ByVal strValue As String)
		If IsBrowser Then
			DEFAULT_SESSION_EXPIRY = CInt(GetKartConfig("general.sessions.expiry"))
			If SessionValueExists(strName) Then
				AdptrSessionValues.UpdateSessionValues(SessionID, strName, strValue, DEFAULT_SESSION_EXPIRY)
			Else
				AdptrSessionValues.InsertSessionValues(SessionID, strName, strValue, DEFAULT_SESSION_EXPIRY)
			End If
		End If
	End Sub

	'Edits a new name/value pair
	Public Sub Edit(ByVal strName As String, ByVal strValue As String)
		If IsBrowser Then
			DEFAULT_SESSION_EXPIRY = CInt(GetKartConfig("general.sessions.expiry"))
			If Not (SessionValueExists(strName)) Then
				AdptrSessionValues.InsertSessionValues(SessionID, strName, strValue, DEFAULT_SESSION_EXPIRY)
			Else
				AdptrSessionValues.UpdateSessionValues(SessionID, strName, strValue, DEFAULT_SESSION_EXPIRY)
			End If

		End If
	End Sub

	'Deletes an item
	Public Sub Delete(ByVal strName As String)
		If IsBrowser Then
			AdptrSessionValues.DeleteSessionValues(SessionID, strName)
		End If
	End Sub

	Private Function SessionValueExists(ByVal strName As String) As Boolean
		Dim blnExists As Boolean = False
		If IsBrowser Then
			blnExists = AdptrSessionValues.GetCount(SessionID, strName) > 0
		End If
		Return blnExists
	End Function

	Public Function Value(ByVal strName As String) As String
		Dim strValue As String = ""
		If IsBrowser Then
			strValue = AdptrSessionValues.GetValue(SessionID, strName) & ""
		End If
		Return strValue
	End Function

	Public Function Expiry(ByVal strName As String) As Integer
		Dim numExpiry As Integer
		''If _IsBrowser Then
		''	If Not objItems.ContainsKey(LCase(strName)) Then Call AddItem(strName, "")
		''	numExpiry = objItems(LCase(strName)).Expiry
		''End If
		Return numExpiry
	End Function

	Public Function GetSessions() As SessionsDataTable
		Return AdptrSessions.GetData()
	End Function

	Private Function AddSessions(ByVal _SESS_Code As String, ByVal _SESS__IP As String, ByVal _SESS_DateCreated As String, ByVal _SESS_DateLastUpdated As String, ByVal _SESS_Expiry As Integer) As Boolean
		AdptrSessions.AddSessions(_SESS_Code, _SESS__IP, _SESS_DateCreated, _SESS_DateLastUpdated, _SESS_Expiry)
		Return True
	End Function

	Private Function AddSessionValues(ByVal _SESSV_SessionID As Integer, ByVal _SESSV_Name As String, ByVal _SESSV_Value As String, ByVal _SESSV_Expiry As Integer) As Boolean
		AdptrSessionValues.InsertSessionValues(_SESSV_SessionID, _SESSV_Name, _SESSV_Value, _SESSV_Expiry)
		Return True
	End Function

	Public Function GetSessionID(ByVal strSessionCode As String) As Long
		Return AdptrSessions.GetSessionID(strSessionCode)
	End Function

	Public Sub CleanExpiredSessionsData()
		AdptrSessions.DeleteExpired(CkartrisDisplayFunctions.NowOffset)
	End Sub

End Class

