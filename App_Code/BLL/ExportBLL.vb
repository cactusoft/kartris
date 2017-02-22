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
Imports kartrisExportData
Imports kartrisExportDataTableAdapters
Imports CkartrisDisplayFunctions
Imports CkartrisFormatErrors
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Public Class ExportBLL
    Private Shared _Adptr As SavedExportsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr() As SavedExportsTblAdptr
        Get
            _Adptr = New SavedExportsTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function _GetSavedExports() As DataTable
        Return Adptr._GetData()
    End Function

    Public Shared Function _GetSavedExport(ByVal numExportID As Long) As DataTable
        Return Adptr._GetByID(numExportID)
    End Function

    Public Shared Function _AddSavedExport(ByVal strName As String, ByVal strDetails As String, ByVal numFieldDelimiter As Integer, _
                                           ByVal numStringDelimiter As Integer, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddExport As SqlCommand = sqlConn.CreateCommand
            cmdAddExport.CommandText = "_spKartrisSavedExports_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddExport.CommandType = CommandType.StoredProcedure
            Try
                cmdAddExport.Parameters.AddWithValue("@Name", strName)
                cmdAddExport.Parameters.AddWithValue("@DateCreated", NowOffset)
                cmdAddExport.Parameters.AddWithValue("@Details", strDetails)
                cmdAddExport.Parameters.AddWithValue("@FieldDelimiter", numFieldDelimiter)
                cmdAddExport.Parameters.AddWithValue("@StringDelimiter", numStringDelimiter)
                cmdAddExport.Parameters.AddWithValue("@New_ID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddExport.Transaction = savePoint

                cmdAddExport.ExecuteNonQuery()

                If cmdAddExport.Parameters("@New_ID").Value Is Nothing OrElse _
                cmdAddExport.Parameters("@New_ID").Value Is DBNull.Value Then
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
    Public Shared Function _UpdateSavedExport(ByVal numExportID As Long, ByVal strName As String, ByVal strDetails As String, _
                                              ByVal numFieldDelimiter As Integer, ByVal numStringDelimiter As Integer, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateExport As SqlCommand = sqlConn.CreateCommand
            cmdUpdateExport.CommandText = "_spKartrisSavedExports_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateExport.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateExport.Parameters.AddWithValue("@Name", strName)
                cmdUpdateExport.Parameters.AddWithValue("@DateModified", NowOffset)
                cmdUpdateExport.Parameters.AddWithValue("@Details", strDetails)
                cmdUpdateExport.Parameters.AddWithValue("@FieldDelimiter", numFieldDelimiter)
                cmdUpdateExport.Parameters.AddWithValue("@StringDelimiter", numStringDelimiter)
                cmdUpdateExport.Parameters.AddWithValue("@ExportID", numExportID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateExport.Transaction = savePoint

                cmdUpdateExport.ExecuteNonQuery()

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

    Public Shared Function _DeleteSavedExport(ByVal numExportID As Long, ByVal strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdDeleteExport As SqlCommand = sqlConn.CreateCommand
            cmdDeleteExport.CommandText = "_spKartrisSavedExports_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdDeleteExport.CommandType = CommandType.StoredProcedure
            Try
                cmdDeleteExport.Parameters.AddWithValue("@ExportID", numExportID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdDeleteExport.Transaction = savePoint

                cmdDeleteExport.ExecuteNonQuery()

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

    Public Shared Function _ExportOrders(ByVal strDateFrom As String, ByVal strDateTo As String, ByVal blnIncludeDetails As Boolean, ByVal blnIncompleteOrders As Boolean) As DataTable
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdExecuteQuery As SqlCommand = sqlConn.CreateCommand
            cmdExecuteQuery.CommandText = "_spKartrisDB_ExportOrders"

            cmdExecuteQuery.CommandType = CommandType.StoredProcedure
            cmdExecuteQuery.Parameters.AddWithValue("@StartDate", FixNullToDB(strDateFrom))
            cmdExecuteQuery.Parameters.AddWithValue("@EndDate", FixNullToDB(strDateTo))
            cmdExecuteQuery.Parameters.AddWithValue("@IncludeDetails", blnIncludeDetails)
            cmdExecuteQuery.Parameters.AddWithValue("@IncludeIncomplete", blnIncompleteOrders)
            cmdExecuteQuery.CommandTimeout = 3600

            Try
                Dim tblExport As New DataTable()
                Using adptr As New SqlDataAdapter(cmdExecuteQuery)
                    adptr.Fill(tblExport)
                    Return tblExport
                End Using
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Finally
            End Try
        End Using
        Return Nothing
    End Function
    Public Shared Function _CustomExecute(ByVal strQuery As String) As DataTable

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdExecuteQuery As SqlCommand = sqlConn.CreateCommand
            cmdExecuteQuery.CommandText = "_spKartrisDB_ExecuteQuery"

            cmdExecuteQuery.CommandType = CommandType.StoredProcedure
            cmdExecuteQuery.Parameters.AddWithValue("@QueryText", FixNullToDB(strQuery, "s"))
            cmdExecuteQuery.CommandTimeout = 3600

            Try
                Dim tblExport As New DataTable()
                Using adptr As New SqlDataAdapter(cmdExecuteQuery)
                    adptr.Fill(tblExport)
                    Return tblExport
                End Using
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            End Try
        End Using

        Return Nothing
    End Function
End Class
