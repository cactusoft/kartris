'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports kartrisPagesDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports CkartrisFormatErrors

Public Class PagesBLL

    Private Shared _Adptr As PagesTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As PagesTblAdptr
        Get
            _Adptr = New PagesTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function _GetPages(ByVal pLanguageID As Byte) As DataTable
        Return Adptr._GetData(pLanguageID)
    End Function

    Public Shared Function _GetPageByID(ByVal pLanguageID As Byte, ByVal pPageID As Integer) As DataTable
        Return Adptr._GetByID(pLanguageID, pPageID)
    End Function

    Public Shared Function _GetAllNames() As DataTable
        Return Adptr._GetNames()
    End Function

    Public Shared Function GetPageByName(ByVal numLanguageID As Short, ByVal strPageName As String) As DataTable
        Return Adptr.GetByName(numLanguageID, strPageName)
    End Function

    Public Shared Function _AddPage(ByVal tblElements As DataTable, ByVal strPageName As String, ByVal numParentID As Short, _
                             ByVal blnPageLive As Boolean, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddPage As SqlCommand = sqlConn.CreateCommand
            cmdAddPage.CommandText = "_spKartrisPages_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddPage.CommandType = CommandType.StoredProcedure
            Try
                cmdAddPage.Parameters.AddWithValue("@Page_Name", strPageName)
                cmdAddPage.Parameters.AddWithValue("@Page_ParentID", numParentID)
                cmdAddPage.Parameters.AddWithValue("@Page_Live", blnPageLive)
                cmdAddPage.Parameters.AddWithValue("@NowOffset", CkartrisDisplayFunctions.NowOffset)
                cmdAddPage.Parameters.AddWithValue("@Page_NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddPage.Transaction = savePoint

                cmdAddPage.ExecuteNonQuery()

                If cmdAddPage.Parameters("@Page_NewID").Value Is Nothing OrElse _
                cmdAddPage.Parameters("@Page_NewID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewPageID As Integer = cmdAddPage.Parameters("@Page_NewID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.Pages, intNewPageID, sqlConn, savePoint) Then
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

    Public Shared Function _UpdatePage(ByVal tblElements As DataTable, ByVal numPageID As Integer, _
                                ByVal strPageName As String, ByVal numParentID As Short, _
                                ByVal blnPageLive As Boolean, ByVal strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdatePage As SqlCommand = sqlConn.CreateCommand
            cmdUpdatePage.CommandText = "_spKartrisPages_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdatePage.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdatePage.Parameters.AddWithValue("@Page_ID", numPageID)
                cmdUpdatePage.Parameters.AddWithValue("@Page_Name", strPageName)
                cmdUpdatePage.Parameters.AddWithValue("@Page_ParentID", numParentID)
                cmdUpdatePage.Parameters.AddWithValue("@Page_Live", blnPageLive)
                cmdUpdatePage.Parameters.AddWithValue("@NowOffset", CkartrisDisplayFunctions.NowOffset)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdatePage.Transaction = savePoint

                cmdUpdatePage.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                        tblElements, LANG_ELEM_TABLE_TYPE.Pages, numPageID, sqlConn, savePoint) Then
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

    Public Shared Function _DeletePage(ByVal numPageID As Integer, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeletePage As SqlCommand = sqlConn.CreateCommand
            cmdDeletePage.CommandText = "_spKartrisPages_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeletePage.CommandType = CommandType.StoredProcedure
            Try
                cmdDeletePage.Parameters.AddWithValue("@Page_ID", numPageID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeletePage.Transaction = savePoint

                cmdDeletePage.ExecuteNonQuery()

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
