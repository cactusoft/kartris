'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports kartrisKBDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports CkartrisFormatErrors

Public Class KBBLL

    Private Shared _Adptr As KnowledgeBaseTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As KnowledgeBaseTblAdptr
        Get
            _Adptr = New KnowledgeBaseTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function _GetKB(ByVal pLanguageID As Byte) As DataTable
        Return Adptr._GetData(pLanguageID)
    End Function

    Public Shared Function _GetKBByID(ByVal pLanguageID As Byte, ByVal pKBID As Integer) As DataTable
        Return Adptr._GetByID(pLanguageID, pKBID)
    End Function

    Public Shared Function GetKBByID(ByVal numLanguageID As Short, ByVal numKBID As Integer) As DataTable
        Return Adptr.GetByID(numLanguageID, numKBID)
    End Function

    Public Shared Function GetKBTitleByID(ByVal numLanguageID As Short, ByVal numKBID As Integer) As String
        Return Adptr.GetTitleByID(numLanguageID, numKBID)
    End Function

    Public Shared Function GetKB(ByVal numLanguageID As Short) As DataTable
        Return Adptr.GetData(numLanguageID)
    End Function

    Public Shared Function Search(ByVal strKeywordList As String, ByVal numLanguageID As Short) As DataTable
        Return Adptr.Search(strKeywordList, numLanguageID)
    End Function

    Public Shared Function _AddKB(ByVal tblElements As DataTable, ByVal datCreated As Date, ByVal datUpdated As Date, _
                             ByVal blnKBLive As Boolean, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddKB As SqlCommand = sqlConn.CreateCommand
            cmdAddKB.CommandText = "_spKartrisKnowledgeBase_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddKB.CommandType = CommandType.StoredProcedure
            Try
                cmdAddKB.Parameters.AddWithValue("@NowOffset_Created", datCreated)
                cmdAddKB.Parameters.AddWithValue("@NowOffset_Updated", datUpdated)
                cmdAddKB.Parameters.AddWithValue("@KB_Live", blnKBLive)
                cmdAddKB.Parameters.AddWithValue("@KB_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddKB.Transaction = savePoint

                cmdAddKB.ExecuteNonQuery()

                If cmdAddKB.Parameters("@KB_NewID").Value Is Nothing OrElse _
                cmdAddKB.Parameters("@KB_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewKBID As Integer = cmdAddKB.Parameters("@KB_NewID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.KnowledgeBase, intNewKBID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
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

    Public Shared Function _UpdateKB(ByVal tblElements As DataTable, ByVal numKBID As Integer, _
                                ByVal datCreated As Date, ByVal datUpdated As Date, _
                             ByVal blnKBLive As Boolean, ByVal strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateKB As SqlCommand = sqlConn.CreateCommand
            cmdUpdateKB.CommandText = "_spKartrisKnowledgeBase_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateKB.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateKB.Parameters.AddWithValue("@KB_ID", numKBID)
                cmdUpdateKB.Parameters.AddWithValue("@KB_Live", blnKBLive)
                cmdUpdateKB.Parameters.AddWithValue("@NowOffset_Created", datCreated)
                cmdUpdateKB.Parameters.AddWithValue("@NowOffset_Updated", datUpdated)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateKB.Transaction = savePoint

                cmdUpdateKB.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.KnowledgeBase, numKBID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
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

    Public Shared Function _DeleteKB(ByVal numKBID As Integer, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteKB As SqlCommand = sqlConn.CreateCommand
            cmdDeleteKB.CommandText = "_spKartrisKnowledgeBase_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteKB.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteKB.Parameters.AddWithValue("@KB_ID", numKBID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteKB.Transaction = savePoint

                cmdDeleteKB.ExecuteNonQuery()

                savePoint.Commit()
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

End Class
