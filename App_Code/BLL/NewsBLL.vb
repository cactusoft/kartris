'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports CkartrisDisplayFunctions
Imports CkartrisEnumerations
Imports kartrisNewsDataTableAdapters
Imports CkartrisFormatErrors
Imports KartSettingsManager

Public Class NewsBLL

    Private Shared _Adptr As NewsTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As NewsTblAdptr
        Get
            _Adptr = New NewsTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function _GetNewsForCache() As DataTable
        Return Adptr._GetDataForCache()
    End Function

    Public Shared Function _GetSummaryNews(ByVal numLanguageID As Byte) As DataView
        Dim drwNews() As DataRow = GetSiteNewsFromCache.Select("LANG_ID =" & numLanguageID)
        Using tblNews As New DataTable
            tblNews.Columns.Add(New DataColumn("N_ID", Type.GetType("System.Int32")))
            tblNews.Columns.Add(New DataColumn("N_Name", Type.GetType("System.String")))
            tblNews.Columns.Add(New DataColumn("N_DateCreated", Type.GetType("System.DateTime")))
            tblNews.Columns.Add(New DataColumn("N_LastUpdated", Type.GetType("System.DateTime")))

            For i As Integer = 0 To drwNews.Length - 1
                tblNews.Rows.Add(drwNews(i)("N_ID"), drwNews(i)("N_Name"), FixNullFromDB(drwNews(i)("N_DateCreated")), FixNullFromDB(drwNews(i)("N_LastUpdated")))
            Next

            Dim dvwNews As DataView
            dvwNews = tblNews.DefaultView
            dvwNews.Sort = "N_LastUpdated DESC, N_ID ASC"

            Return dvwNews
        End Using
    End Function

    Public Shared Function GetLatestNews(ByVal numLanguageID As Byte, Optional ByVal numNoOfRecords As Short = -1) As DataTable
        Dim drwNews() As DataRow = GetSiteNewsFromCache.Select("LANG_ID =" & numLanguageID)
        Using tblLatestNews As New DataTable
            tblLatestNews.Columns.Add(New DataColumn("N_ID", Type.GetType("System.Int32")))
            tblLatestNews.Columns.Add(New DataColumn("N_Name", Type.GetType("System.String")))
            tblLatestNews.Columns.Add(New DataColumn("N_Strapline", Type.GetType("System.String")))
            tblLatestNews.Columns.Add(New DataColumn("N_Text", Type.GetType("System.String")))
            tblLatestNews.Columns.Add(New DataColumn("N_DateCreated", Type.GetType("System.DateTime")))

            For i As Integer = 0 To drwNews.Length - 1
                'Note we pull out 500 chars for summary, will likely be truncated later
                'but we need to have enough to ensure still have some text after HTML
                'is stripped out
                tblLatestNews.Rows.Add(drwNews(i)("N_ID"), drwNews(i)("N_Name"), Left(FixNullFromDB(drwNews(i)("N_Strapline")), 500), Left(FixNullFromDB(drwNews(i)("N_Text")), 500), FixNullFromDB(drwNews(i)("N_DateCreated")))
                If tblLatestNews.Rows.Count = numNoOfRecords Then Exit For
            Next
            Return tblLatestNews
        End Using
    End Function

    Public Shared Function GetNewsTitleByID(ByVal numID As Integer, ByVal numLanguageID As Byte) As String
        Dim drwNews() As DataRow = GetSiteNewsFromCache.Select("LANG_ID =" & numLanguageID & " AND N_ID=" & numID)
        If drwNews.Length <> 1 Then Return Nothing
        Return CStr(drwNews(0)("N_Name"))
    End Function

    Public Shared Function GetByID(ByVal numLanguageID As Byte, ByVal numID As Integer) As DataTable
        Dim drwNews() As DataRow = GetSiteNewsFromCache.Select("LANG_ID =" & numLanguageID & " AND N_ID=" & numID)
        If drwNews.Length <> 1 Then Return Nothing
        Using tblNews As New DataTable
            tblNews.Columns.Add(New DataColumn("N_ID", Type.GetType("System.Int32")))
            tblNews.Columns.Add(New DataColumn("N_Name", Type.GetType("System.String")))
            tblNews.Columns.Add(New DataColumn("N_Text", Type.GetType("System.String")))
            tblNews.Columns.Add(New DataColumn("N_StrapLine", Type.GetType("System.String")))
            tblNews.Columns.Add(New DataColumn("N_DateCreated", Type.GetType("System.DateTime")))

            tblNews.Rows.Add(drwNews(0)("N_ID"), drwNews(0)("N_Name"), FixNullFromDB(drwNews(0)("N_Text")), FixNullFromDB(drwNews(0)("N_StrapLine")), FixNullFromDB(drwNews(0)("N_DateCreated")))

            Return tblNews
        End Using
    End Function

    Public Shared Function _AddNews(ByVal tblElements As DataTable, ByVal datCreation As Date, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddNews As SqlCommand = sqlConn.CreateCommand
            cmdAddNews.CommandText = "_spKartrisNews_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddNews.CommandType = CommandType.StoredProcedure
            Try
                cmdAddNews.Parameters.AddWithValue("@NowOffset", datCreation)
                cmdAddNews.Parameters.AddWithValue("@N_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddNews.Transaction = savePoint

                cmdAddNews.ExecuteNonQuery()

                If cmdAddNews.Parameters("@N_NewID").Value Is Nothing OrElse _
                    cmdAddNews.Parameters("@N_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewNewsID As Integer = cmdAddNews.Parameters("@N_NewID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.News, intNewNewsID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")

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

    Public Shared Function _UpdateNews(ByVal tblElements As DataTable, ByVal datCreation As Date, ByVal numNewsID As Integer, ByVal strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateNews As SqlCommand = sqlConn.CreateCommand
            cmdUpdateNews.CommandText = "_spKartrisNews_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateNews.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateNews.Parameters.AddWithValue("@N_ID", numNewsID)
                cmdUpdateNews.Parameters.AddWithValue("@N_DateCreated", datCreation)
                cmdUpdateNews.Parameters.AddWithValue("@NowOffset", CkartrisDisplayFunctions.NowOffset)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateNews.Transaction = savePoint

                cmdUpdateNews.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.News, numNewsID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")

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

    Public Shared Function _DeleteNews(ByVal numNewsID As Integer, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteNews As SqlCommand = sqlConn.CreateCommand
            cmdDeleteNews.CommandText = "_spKartrisNews_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteNews.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteNews.Parameters.AddWithValue("@N_ID", numNewsID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteNews.Transaction = savePoint

                cmdDeleteNews.ExecuteNonQuery()

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using

        Return False
    End Function

End Class
