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
Imports kartrisObjectConfigTableAdapters
Imports System.Web.HttpContext
Imports CkartrisFormatErrors
Imports CkartrisDisplayFunctions
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Public Class ObjectConfigBLL

    Private Shared _Adptr As ObjectConfigTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr() As ObjectConfigTblAdptr
        Get
            _Adptr = New ObjectConfigTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function _GetData() As DataTable
        Return Adptr._GetData()
    End Function
    Public Shared Function _GetValue(ByVal strConfigName As String, ByVal numParentID As Long) As Object
        'Dim strValue As String = CStr(Adptr._GetValue(strConfigName, numParentID))
        Return FixNullFromDB(Adptr._GetValue(strConfigName, numParentID))
    End Function

    Public Shared Function _SetConfigValue(ByVal numConfigID As Integer, ByVal numParentID As Long, ByVal strValue As String, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisObjectConfig_SetValue"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure

            Try
                cmd.Parameters.AddWithValue("@ParentID", FixNullToDB(numParentID, "l"))
                cmd.Parameters.AddWithValue("@ConfigID", FixNullToDB(numConfigID, "i"))
                cmd.Parameters.AddWithValue("@ConfigValue", FixNullToDB(strValue))
                
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                cmd.ExecuteNonQuery()

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

    Public Shared Function GetValue(ByVal strConfigName As String, ByVal numParentID As Long) As Object
        Return Adptr.GetValue(strConfigName, numParentID)
    End Function
End Class
