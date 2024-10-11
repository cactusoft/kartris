'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisFormatErrors
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports kartrisConfigData
Imports kartrisConfigDataTableAdapters


Public Class ConfigBLL
    Private Shared _Adptr As ConfigTblAdptr = Nothing
    Private Shared _CacheAdptr As ConfigCacheTblAdptr = Nothing

    Protected Shared ReadOnly Property Adptr() As ConfigTblAdptr
        Get
            _Adptr = New ConfigTblAdptr
            Return _Adptr
        End Get
    End Property
    Protected Shared ReadOnly Property CacheAdptr() As ConfigCacheTblAdptr
        Get
            _CacheAdptr = New ConfigCacheTblAdptr
            Return _CacheAdptr
        End Get
    End Property

    Public Shared Function GetConfigCacheData() As DataTable
        Return CacheAdptr._GetConfigCacheData()
    End Function

    Public Shared Function _GetConfigDesc(ByVal ConfigName As String) As String
        Return CStr(Adptr._GetConfigDesc(ConfigName).Rows(0)("CFG_Description"))
    End Function
    Public Shared Function _SearchConfig(ByVal _ConfigKey As String, ByVal _ImportantConfig As Boolean) As DataTable
        Return Adptr._SearchConfig(_ConfigKey, _ImportantConfig)
    End Function
    Public Shared Function _GetConfigByName(ByVal _CFG_Name As String) As DataTable
        Return Adptr._GetConfigByName(_CFG_Name)
    End Function
    Public Shared Function _GetImportantConfig() As DataTable
        Return Adptr._GetImportantConfig()
    End Function

    Public Shared Function _UpdateConfigValue(ByVal ConfigName As String, ByVal ConfigValue As String, Optional ByVal blnAddAdminLog As Boolean = True, _
                                              Optional ByVal blnRefreshCache As Boolean = True) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateConfigValue As SqlCommand = sqlConn.CreateCommand
            cmdUpdateConfigValue.CommandText = "_spKartrisConfig_UpdateConfigValue"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateConfigValue.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateConfigValue.Parameters.AddWithValue("@CFG_Name", FixNullToDB(ConfigName))
                cmdUpdateConfigValue.Parameters.AddWithValue("@CFG_Value", FixNullToDB(ConfigValue))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateConfigValue.Transaction = savePoint

                cmdUpdateConfigValue.ExecuteNonQuery()

                If blnAddAdminLog Then
                    KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Config, _
                     GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), _
                     CreateQuery(cmdUpdateConfigValue), ConfigName, sqlConn, savePoint)
                End If

                savePoint.Commit()
                sqlConn.Close()
                If blnRefreshCache Then KartSettingsManager.RefreshCache()
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using

        Return False
    End Function

    Public Shared Function _AddConfig(ByVal pName As String, ByVal pValue As String, ByVal pDataType As String, _
       ByVal pDisplayType As String, ByVal pDisplayInfo As String, ByVal pDesc As String, _
       ByVal pDefaultValue As String, ByVal pVersionAdded As Single, ByVal pImportant As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString)

            Dim cmdAddConfig As SqlCommand = sqlConn.CreateCommand
            cmdAddConfig.CommandText = "_spKartrisConfig_Add"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdAddConfig.CommandType = CommandType.StoredProcedure

            Try
                cmdAddConfig.Parameters.AddWithValue("@CFG_Name", FixNullToDB(pName))
                cmdAddConfig.Parameters.AddWithValue("@CFG_Value", FixNullToDB(pValue))
                cmdAddConfig.Parameters.AddWithValue("@CFG_DataType", FixNullToDB(pDataType))
                cmdAddConfig.Parameters.AddWithValue("@CFG_DisplayType", FixNullToDB(pDisplayType))
                cmdAddConfig.Parameters.AddWithValue("@CFG_DisplayInfo", FixNullToDB(pDisplayInfo))
                cmdAddConfig.Parameters.AddWithValue("@CFG_Description", FixNullToDB(pDesc))
                cmdAddConfig.Parameters.AddWithValue("@CFG_VersionAdded", FixNullToDB(pVersionAdded, "g"))
                cmdAddConfig.Parameters.AddWithValue("@CFG_DefaultValue", FixNullToDB(pDefaultValue))
                cmdAddConfig.Parameters.AddWithValue("@CFG_Important", FixNullToDB(pImportant, "b"))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddConfig.Transaction = savePoint
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                cmdAddConfig.ExecuteNonQuery()
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Config, _
                   strMsg, CreateQuery(cmdAddConfig), pName, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()

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

    Public Shared Function _UpdateConfig(ByVal pName As String, ByVal pValue As String, ByVal pDataType As String, _
       ByVal pDisplayType As String, ByVal pDisplayInfo As String, ByVal pDesc As String, _
       ByVal pDefaultValue As String, ByVal pVersionAdded As Single, ByVal pImportant As Boolean, ByRef strMsg As String) As Integer

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlClient.SqlConnection(strConnString)

            Dim cmdUpdateConfig As SqlCommand = sqlConn.CreateCommand
            cmdUpdateConfig.CommandText = "_spKartrisConfig_Update"

            Dim savePoint As SqlClient.SqlTransaction = Nothing
            cmdUpdateConfig.CommandType = CommandType.StoredProcedure

            Try
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_Value", FixNullToDB(pValue))
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_DataType", FixNullToDB(pDataType))
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_DisplayType", FixNullToDB(pDisplayType))
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_DisplayInfo", FixNullToDB(pDisplayInfo))
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_Description", FixNullToDB(pDesc))
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_VersionAdded", FixNullToDB(pVersionAdded, "g"))
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_DefaultValue", FixNullToDB(pDefaultValue))
                cmdUpdateConfig.Parameters.AddWithValue("@CFG_Important", FixNullToDB(pImportant, "b"))
                cmdUpdateConfig.Parameters.AddWithValue("@Original_CFG_Name", FixNullToDB(pName))

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateConfig.Transaction = savePoint

                cmdUpdateConfig.ExecuteNonQuery()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Config, _
                 strMsg, CreateQuery(cmdUpdateConfig), pName, sqlConn, savePoint)

                savePoint.Commit()
                sqlConn.Close()

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
