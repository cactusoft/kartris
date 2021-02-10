﻿'========================================================================
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

    ''' <summary>
    ''' Set object config value - Back end (uses object config ID)
    ''' </summary>
    ''' <param name="numConfigID">OC_ID</param>
    ''' <param name="numParentID">ID of the parent item, e.g. product ID</param>
    ''' <param name="strValue">The value you want to set it to</param>
    ''' <param name="strMsg">Tax extra info, we now set this to EU if using UK/VAT tax regime for EU countries</param>
    ''' <returns>boolean</returns>
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

    ''' <summary>
    ''' Set object config value - Front end (uses object config name)
    ''' </summary>
    ''' <param name="strConfigName">Name of the object config setting, e.g. K:user.eori</param>
    ''' <param name="numParentID">ID of the parent item, e.g. user ID</param>
    ''' <param name="strValue">The value you want to set it to</param>
    ''' <param name="strMsg">Tax extra info, we now set this to EU if using UK/VAT tax regime for EU countries</param>
    ''' <returns>boolean</returns>
    Public Shared Function SetConfigValue(ByVal strConfigName As String, ByVal numParentID As Long, ByVal strValue As String, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "spKartrisObjectConfig_SetValue"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure

            Try
                cmd.Parameters.AddWithValue("@ParentID", FixNullToDB(numParentID, "l"))
                cmd.Parameters.AddWithValue("@ConfigName", strConfigName)
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
        Try
            Return Adptr.GetValue(strConfigName, numParentID)
        Catch ex As Exception
            CkartrisFormatErrors.LogError("ObjectConfigBLL.GetValue - " & ex.Message & vbCrLf & "strConfigName: " & strConfigName & vbCrLf & "numParentID: " & numParentID)
        End Try
        Return Nothing
    End Function
End Class
