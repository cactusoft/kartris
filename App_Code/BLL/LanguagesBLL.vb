'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports kartrisLanguageData
Imports kartrisLanguageDataTableAdapters
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports CkartrisFormatErrors
Imports CkartrisEnumerations
Imports KartSettingsManager

Public Class LanguagesBLL

    '' LanguageElementTypeField
    Private Shared _TypeFieldAdptr As LanguageElementTypeFieldsTblAdptr = Nothing

    Protected Shared ReadOnly Property TypeFieldAdptr() As LanguageElementTypeFieldsTblAdptr
        Get
            _TypeFieldAdptr = New LanguageElementTypeFieldsTblAdptr()
            Return _TypeFieldAdptr
        End Get
    End Property

    Public Shared Function _GetTypeFieldDetails() As DataTable
        Return TypeFieldAdptr._GetData()
    End Function

    '' Languages
    Private Shared _Adptr As LanguagesTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As LanguagesTblAdptr
        Get
            _Adptr = New LanguagesTblAdptr
            Return _Adptr
        End Get
    End Property

    ''' <summary>
    ''' 'Get Languages' function that handles its own caching methods...just pass true to force-refresh the cache
    ''' </summary>
    ''' <param name="refreshCache"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetLanguages(Optional ByVal refreshCache As Boolean = False) As DataTable
        If refreshCache Then
            If Not HttpRuntime.Cache("KartrisFrontLanguagesCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisFrontLanguagesCache")
            Dim tblLanguages As DataTable = Adptr.GetData
            HttpRuntime.Cache.Add("KartrisFrontLanguagesCache", tblLanguages, Nothing, Date.MaxValue, TimeSpan.Zero, _
                                  Caching.CacheItemPriority.Low, Nothing)
            'were only trying to refresh the cache so return nothing
            Return Nothing
        Else
            If HttpRuntime.Cache("KartrisFrontLanguagesCache") Is Nothing Then GetLanguages(True)
            Return DirectCast(HttpRuntime.Cache("KartrisFrontLanguagesCache"), DataTable)
        End If
    End Function

    Public Shared Function GetLanguagesCount() As Integer
        If HttpRuntime.Cache("KartrisFrontLanguagesCache") IsNot Nothing Then
            Return DirectCast(HttpRuntime.Cache("KartrisFrontLanguagesCache"), DataTable).Rows.Count
        Else
            Return 0
        End If
    End Function

    Public Shared Function _GetLanguages() As DataTable
        Return Adptr._GetData()
    End Function

    Public Shared Function _GetBackendLanguages() As DataRow()
        Return GetLanguagesFromCache().Select("LANG_LiveBack = 1")
    End Function

    Public Shared Function _GetByLanguageID(ByVal _LanguageID As Byte) As DataRow()
        Return GetLanguagesFromCache().Select("LANG_ID=" & _LanguageID)
    End Function

    Public Shared Function GetLanguageFrontName_s(ByVal _LanguageID As Short) As String
        For Each row As DataRow In GetLanguagesFromCache().Rows
            If FixNullFromDB(row("LANG_ID")) = _LanguageID Then
                Return FixNullFromDB(row("LANG_FrontName"))
            End If
        Next
        Return ""
    End Function

    Public Shared Function GetSkinURLByCulture(ByVal _Language_Culture As String) As String
        For Each row As DataRow In GetLanguagesFromCache().Rows
            If FixNullFromDB(row("LANG_Culture")) = _Language_Culture Then
                Return FixNullFromDB(row("LANG_SkinLocation"))
            End If
        Next
        Return ""
    End Function

    Public Shared Function GetLanguageIDByCulture_s(ByVal _Language_Culture As String) As Byte
        For Each row As DataRow In GetLanguages().Rows
            If UCase(FixNullFromDB(row("LANG_Culture"))) = UCase(_Language_Culture) Then
                Return CByte(row("LANG_ID"))
            End If
        Next
        Return 0
    End Function

    Public Shared Function GetLanguageIDByCultureUI_s(ByVal _Language_Culture As String) As Byte
        For Each row As DataRow In GetLanguages().Rows
            If UCase(Left(FixNullFromDB(row("LANG_Culture")), 2)) = UCase(Left(_Language_Culture, 2)) Then
                Return CByte(row("LANG_ID"))
            End If
        Next
        Return 0
    End Function

    Public Shared Function GetCultureByLanguageID_s(ByVal _Language_ID As Short) As String
        For Each row As DataRow In GetLanguagesFromCache().Rows
            If FixNullFromDB(row("LANG_ID")) = _Language_ID Then
                Return FixNullFromDB(row("LANG_Culture"))
            End If
        Next
        Return ""
    End Function

    Public Shared Function GetUICultureByLanguageID_s(ByVal _Language_ID As Short) As String
        For Each row As DataRow In GetLanguagesFromCache().Rows
            If FixNullFromDB(row("LANG_ID")) = _Language_ID Then
                Return FixNullFromDB(row("LANG_UICulture"))
            End If
        Next
        Return ""
    End Function

    Public Shared Function GetDefaultLanguageID() As Byte
        Return CByte(GetKartConfig("frontend.languages.default"))
    End Function

    Public Shared Function GetDateFormat(ByVal numLangID As Byte, ByVal chrType As Char) As String
        For Each row As DataRow In GetLanguagesFromCache().Rows
            If FixNullFromDB(row("LANG_ID")) = numLangID Then
                If chrType = "d" Then Return FixNullFromDB(row("LANG_DateFormat"))
                Return FixNullFromDB(row("LANG_DateAndTimeFormat"))
            End If
        Next
        Return ""
    End Function

    Public Shared Function GetEmailToContact(ByVal numLangID As Byte) As String
        Dim dr() As DataRow = GetLanguagesFromCache.Select("LANG_ID=" & numLangID)
        If dr.Length = 1 Then Return FixNullFromDB(dr(0)("LANG_EmailToContact"))
        Return ""
    End Function

    Public Shared Function GetEmailTo(ByVal numLangID As Byte) As String
        Dim dr() As DataRow = GetLanguagesFromCache.Select("LANG_ID=" & numLangID)
        If dr.Length = 1 Then Return FixNullFromDB(dr(0)("LANG_EmailTo"))
        Return ""
    End Function

    Public Shared Function GetEmailFrom(ByVal numLangID As Byte) As String
        Dim dr() As DataRow = GetLanguagesFromCache.Select("LANG_ID=" & numLangID)
        If dr.Length = 1 Then Return FixNullFromDB(dr(0)("LANG_EmailFrom"))
        Return ""
    End Function

    'We say 'theme' but we're really returned the 
    'skin folder
    Public Shared Function GetTheme(ByVal numLangID As Byte) As String
        Dim dr() As DataRow = GetLanguagesFromCache.Select("LANG_ID=" & numLangID)
        If dr.Length = 1 Then Return FixNullFromDB(dr(0)("LANG_Theme"))
        Return ""
    End Function

    Public Shared Function GetMasterPage(ByVal numLangID As Byte) As String
        Dim dr() As DataRow = GetLanguagesFromCache.Select("LANG_ID=" & numLangID)
        If dr.Length = 1 Then Return FixNullFromDB(dr(0)("LANG_Master"))
        Return ""
    End Function

    Public Shared Function _UpdateLanguage(ByVal _LanguageID As Byte, ByVal _BackName As String, ByVal _FrontName As String, _
               ByVal _SkinLocation As String, ByVal _LiveFront As Boolean, ByVal _LiveBack As Boolean, _
               ByVal _EmailFrom As String, ByVal _EmailTo As String, ByVal _EmailContact As String, _
               ByVal _DateFormat As String, ByVal _DateAndTimeFormat As String, ByVal _Culture As String, _
               ByVal _UICulture As String, ByVal _Master As String, ByVal _Theme As String, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString)

            Dim cmdUpdateLanguage As SqlCommand = sqlConn.CreateCommand
            cmdUpdateLanguage.CommandText = "_spKartrisLanguages_Update"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdUpdateLanguage.CommandType = CommandType.StoredProcedure

            Try
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_BackName", FixNullToDB(_BackName))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_FrontName", FixNullToDB(_FrontName))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_SkinLocation", FixNullToDB(_SkinLocation))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_LiveFront", _LiveFront)
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_LiveBack", _LiveBack)
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_EmailFrom", FixNullToDB(_EmailFrom))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_EmailTo", FixNullToDB(_EmailTo))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_EmailToContact", FixNullToDB(_EmailContact))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_DateFormat", FixNullToDB(_DateFormat))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_DateAndTimeFormat", FixNullToDB(_DateAndTimeFormat))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_Culture", FixNullToDB(_Culture))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_UICulture", FixNullToDB(_UICulture))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_Master", FixNullToDB(_Master))
                cmdUpdateLanguage.Parameters.AddWithValue("@LANG_Theme", FixNullToDB(_Theme))
                cmdUpdateLanguage.Parameters.AddWithValue("@Original_LANG_ID", _LanguageID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateLanguage.Transaction = savePoint

                cmdUpdateLanguage.ExecuteNonQuery()

                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Languages, _
                   strMsg, CreateQuery(cmdUpdateLanguage), _BackName, sqlConn, savePoint)

                savePoint.Commit()
                RefreshLanguagesCache()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False

    End Function

    Public Shared Function _AddLanguage(ByVal _BackName As String, ByVal _FrontName As String, _
       ByVal _SkinLocation As String, ByVal _LiveFront As Boolean, ByVal _LiveBack As Boolean, _
       ByVal _EmailFrom As String, ByVal _EmailTo As String, ByVal _EmailContact As String, _
       ByVal _DateFormat As String, ByVal _DateAndTimeFormat As String, ByVal _Culture As String, _
       ByVal _UICulture As String, ByVal _Master As String, ByVal _Theme As String, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString)

            Dim cmdAddLanguage As SqlCommand = sqlConn.CreateCommand
            cmdAddLanguage.CommandText = "_spKartrisLanguages_Add"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdAddLanguage.CommandType = CommandType.StoredProcedure

            Try
                cmdAddLanguage.Parameters.AddWithValue("@LANG_BackName", FixNullToDB(_BackName))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_FrontName", FixNullToDB(_FrontName))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_SkinLocation", FixNullToDB(_SkinLocation))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_LiveFront", _LiveFront)
                cmdAddLanguage.Parameters.AddWithValue("@LANG_LiveBack", _LiveBack)
                cmdAddLanguage.Parameters.AddWithValue("@LANG_EmailFrom", FixNullToDB(_EmailFrom))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_EmailTo", FixNullToDB(_EmailTo))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_EmailToContact", FixNullToDB(_EmailContact))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_DateFormat", FixNullToDB(_DateFormat))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_DateAndTimeFormat", FixNullToDB(_DateAndTimeFormat))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_Culture", FixNullToDB(_Culture))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_UICulture", FixNullToDB(_UICulture))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_Master", FixNullToDB(_Master))
                cmdAddLanguage.Parameters.AddWithValue("@LANG_Theme", FixNullToDB(_Theme))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddLanguage.Transaction = savePoint

                cmdAddLanguage.ExecuteNonQuery()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Languages, _
                 strMsg, CreateQuery(cmdAddLanguage), _BackName, sqlConn, savePoint)

                savePoint.Commit()
                RefreshLanguagesCache()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False

    End Function

End Class
