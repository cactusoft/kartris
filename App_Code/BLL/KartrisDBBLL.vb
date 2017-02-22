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
Imports kartrisDBDataTableAdapters
Imports CkartrisFormatErrors
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports System.Web.HttpContext
Imports KartSettingsManager
Public Class KartrisDBBLL

    Public Shared Function GetProductsAttributesToCompare(ByVal pProductList As String, ByVal pLanguageID As Short, ByVal pCustomerGroupID As Short) As DataTable

        Dim adptr As New CustomProductsToCompareTblAdptr
        Return adptr.GetAttributesToCompare(pProductList, pLanguageID, pCustomerGroupID)

    End Function

    Public Shared Function GetSearchResult(ByVal pSearchText As String, ByVal pKeyList As String, ByVal pLanguageID As Short, ByVal pPageIndx As Short, _
                                    ByVal pRowsPerPage As Short, ByRef pTotalSearchResult As Integer, ByVal pMinPrice As Single, ByVal pMaxPrice As Single, _
                                    ByVal pSearchMethod As String, ByVal pCustomerGroupID As Short) As DataTable
        pSearchText = Current.Server.UrlDecode(pSearchText)
        Dim adptr As New SearchTblAdptr
        If GetKartConfig("general.fts.enabled") = "y" Then
            Try
                Return GetSearchResult(True, pSearchText, pKeyList, pLanguageID, pPageIndx, pRowsPerPage, pTotalSearchResult, pMinPrice, pMaxPrice, pSearchMethod, pCustomerGroupID)
            Catch ex As SqlException
                If ex.Number = 2812 OrElse ex.Number = 208 Then
                    If Not IsFTSEnabled() Then '' That means "general.fts.enabled" has been set manually to y
                        ConfigBLL._UpdateConfigValue("general.fts.enabled", "n")
                        Return GetSearchResult(False, pSearchText, pKeyList, pLanguageID, pPageIndx, pRowsPerPage, pTotalSearchResult, pMinPrice, pMaxPrice, pSearchMethod, pCustomerGroupID)
                    End If
                End If
            End Try
        End If
        Return GetSearchResult(False, pSearchText, pKeyList, pLanguageID, pPageIndx, pRowsPerPage, pTotalSearchResult, pMinPrice, pMaxPrice, pSearchMethod, pCustomerGroupID)
    End Function

    Shared Function GetSearchResult(ByVal blnIsFTS As Boolean, ByVal pSearchText As String, ByVal pKeyList As String, ByVal pLanguageID As Short, ByVal pPageIndx As Short, _
                                    ByVal pRowsPerPage As Short, ByRef pTotalSearchResult As Integer, ByVal pMinPrice As Single, ByVal pMaxPrice As Single, _
                                    ByVal pSearchMethod As String, ByVal pCustomerGroupID As Short) As DataTable
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdSearchFTS As SqlCommand = sqlConn.CreateCommand
            cmdSearchFTS.Connection = sqlConn
            cmdSearchFTS.CommandText = "spKartrisDB_Search"
            If blnIsFTS Then cmdSearchFTS.CommandText += "FTS"
            cmdSearchFTS.CommandTimeout = 2700
            cmdSearchFTS.CommandType = CommandType.StoredProcedure
            Try
                cmdSearchFTS.Parameters.AddWithValue("@SearchText", FixNullToDB(pSearchText))
                cmdSearchFTS.Parameters.AddWithValue("@keyWordsList", FixNullToDB(pKeyList))
                cmdSearchFTS.Parameters.AddWithValue("@LANG_ID", FixNullToDB(pLanguageID, "i"))
                cmdSearchFTS.Parameters.AddWithValue("@PageIndex", pPageIndx)
                cmdSearchFTS.Parameters.AddWithValue("@RowsPerPage", FixNullToDB(pRowsPerPage, "i"))
                cmdSearchFTS.Parameters.AddWithValue("@TotalResultProducts", pTotalSearchResult).Direction = ParameterDirection.Output
                cmdSearchFTS.Parameters.AddWithValue("@MinPrice", FixNullToDB(pMinPrice, "g"))
                cmdSearchFTS.Parameters.AddWithValue("@MaxPrice", FixNullToDB(pMaxPrice, "g"))
                cmdSearchFTS.Parameters.AddWithValue("@Method", FixNullToDB(pSearchMethod))
                cmdSearchFTS.Parameters.AddWithValue("@CustomerGroupID", FixNullToDB(pCustomerGroupID, "i"))

                Dim da As New SqlDataAdapter(cmdSearchFTS)
                Dim ds As New DataSet()
                da.Fill(ds, "tblSearch")
                pTotalSearchResult = cmdSearchFTS.Parameters("@TotalResultProducts").Value
                Return ds.Tables("tblSearch")
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
        Return Nothing
    End Function
    Public Shared Function _SearchBackEnd(ByVal pSearchLocation As String, ByVal pKeyList As String, ByVal pLanguageID As Short, ByVal pPageIndx As Short, _
                                      ByVal pRowsPerPage As Short, ByRef pTotalSearchResult As Integer) As DataTable
        Dim adptr As New SearchTblAdptr
        If GetKartConfig("general.fts.enabled") = "y" Then
            Try
                Return adptr._GetBackEndSearchFTS(pSearchLocation, pKeyList, pLanguageID, pPageIndx, pRowsPerPage, pTotalSearchResult)
            Catch ex As SqlException
                If ex.Number = 2812 OrElse ex.Number = 208 Then
                    If Not IsFTSEnabled() Then '' That means "general.fts.enabled" has been set manually to y
                        ConfigBLL._UpdateConfigValue("general.fts.enabled", "n")
                        Return adptr._GetBackEndSearch(pSearchLocation, pKeyList, pLanguageID, pPageIndx, pRowsPerPage, pTotalSearchResult)
                    End If
                End If
            End Try
        End If
        Return adptr._GetBackEndSearch(pSearchLocation, pKeyList, pLanguageID, pPageIndx, pRowsPerPage, pTotalSearchResult)
    End Function

    Public Shared Sub _LoadTaskList(ByRef numOrdersToInvoice As Integer, ByRef numOrdersNeedPayment As Integer, ByRef numOrdersToDispatch As Integer, _
              ByRef numStockWarning As Integer, ByRef numOutOfStock As Integer, ByRef numWaitingReviews As Integer, _
               ByRef numWaitingAffiliates As Integer, ByRef numCustomersWaitingRefunds As Integer, _
               ByRef numCustomersInArrears As Integer, ByRef strMsg As String)

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdTaskListValues As SqlCommand = sqlConn.CreateCommand
            cmdTaskListValues.CommandText = "_spKartrisDB_GetTaskList"
            cmdTaskListValues.CommandType = CommandType.StoredProcedure
            Try
                cmdTaskListValues.Parameters.AddWithValue("@NoOrdersToInvoice", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoOrdersNeedPayment", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoOrdersToDispatch", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoStockWarnings", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoOutOfStock", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoReviewsWaiting", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoAffiliatesWaiting", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoCustomersWaitingRefunds", 0).Direction = ParameterDirection.Output
                cmdTaskListValues.Parameters.AddWithValue("@NoCustomersInArrears", 0).Direction = ParameterDirection.Output
                sqlConn.Open()

                cmdTaskListValues.ExecuteNonQuery()

                numOrdersToInvoice = cmdTaskListValues.Parameters("@NoOrdersToInvoice").Value
                numOrdersNeedPayment = cmdTaskListValues.Parameters("@NoOrdersNeedPayment").Value
                numOrdersToDispatch = cmdTaskListValues.Parameters("@NoOrdersToDispatch").Value
                numStockWarning = cmdTaskListValues.Parameters("@NoStockWarnings").Value
                numOutOfStock = cmdTaskListValues.Parameters("@NoOutOfStock").Value
                numWaitingReviews = cmdTaskListValues.Parameters("@NoReviewsWaiting").Value
                numWaitingAffiliates = cmdTaskListValues.Parameters("@NoAffiliatesWaiting").Value
                numCustomersWaitingRefunds = cmdTaskListValues.Parameters("@NoCustomersWaitingRefunds").Value
                numCustomersInArrears = cmdTaskListValues.Parameters("@NoCustomersInArrears").Value

            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
    End Sub

    Public Shared Function _CreateDBBackup(ByVal strBackupPath As String, ByVal strBackupDescription As String, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdBackup As SqlCommand = sqlConn.CreateCommand
            cmdBackup.CommandText = "_spKartrisDB_CreateBackup"
            cmdBackup.CommandType = CommandType.StoredProcedure
            Try
                cmdBackup.Parameters.AddWithValue("@BackupPath", strBackupPath)
                sqlConn.Open()
                cmdBackup.ExecuteNonQuery()
                If Not String.IsNullOrEmpty(strBackupDescription) Then
                    Dim strDescPath As String = strBackupPath.Replace(".bak", ".txt")
                    Dim sw As StreamWriter
                    sw = File.CreateText(strDescPath)
                    sw.Write(strBackupDescription)
                    sw.Flush()
                    sw.Close()
                End If
                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
        Return False
    End Function

    Public Shared Sub _GetDBInformation(ByRef tblDBInformation As DataTable, ByRef strMsg As String)
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdInfo As SqlCommand = sqlConn.CreateCommand
            cmdInfo.CommandText = "_spKartrisDB_GetInformation"
            cmdInfo.CommandType = CommandType.StoredProcedure
            Try
                Using adptr As New SqlDataAdapter(cmdInfo)
                    adptr.Fill(tblDBInformation)
                End Using
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
    End Sub

    Public Shared Sub _GetFTSInformation(ByRef blnKartrisCatalogExist As Boolean, ByRef blnKartrisFTSEnabled As Boolean, _
                                         ByRef strKartrisFTSLanguages As String, ByRef blnFTSSupported As Boolean, ByRef strMsg As String)

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdInfo As SqlCommand = sqlConn.CreateCommand
            cmdInfo.CommandText = "_spKartrisDB_GetFTSInfo"
            cmdInfo.CommandType = CommandType.StoredProcedure
            cmdInfo.Parameters.AddWithValue("@kartrisCatalogExist", False).Direction = ParameterDirection.Output
            cmdInfo.Parameters.AddWithValue("@kartrisFTSEnabled", False).Direction = ParameterDirection.Output
            cmdInfo.Parameters.Add("@kartrisFTSLanguages", SqlDbType.NVarChar, 4000).Direction = ParameterDirection.Output
            cmdInfo.Parameters("@kartrisFTSLanguages").Value = ""
            cmdInfo.Parameters.AddWithValue("@FTSSupported", False).Direction = ParameterDirection.Output

            Try
                sqlConn.Open()
                cmdInfo.ExecuteNonQuery()
                blnKartrisCatalogExist = cmdInfo.Parameters("@kartrisCatalogExist").Value
                blnKartrisFTSEnabled = cmdInfo.Parameters("@kartrisFTSEnabled").Value
                strKartrisFTSLanguages = cmdInfo.Parameters("@kartrisFTSLanguages").Value
                blnFTSSupported = cmdInfo.Parameters("@FTSSupported").Value
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
    End Sub
    Public Shared Function IsFTSEnabled() As Boolean
        Dim blnCatalogExist As Boolean = False, blnFTSEnabled As Boolean = False

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdInfo As SqlCommand = sqlConn.CreateCommand
            cmdInfo.CommandText = "_spKartrisDB_GetFTSInfo"
            cmdInfo.CommandType = CommandType.StoredProcedure
            cmdInfo.Parameters.AddWithValue("@kartrisCatalogExist", False).Direction = ParameterDirection.Output
            cmdInfo.Parameters.AddWithValue("@kartrisFTSEnabled", False).Direction = ParameterDirection.Output
            cmdInfo.Parameters.AddWithValue("@kartrisFTSLanguages", "").Direction = ParameterDirection.Output
            cmdInfo.Parameters.AddWithValue("@FTSSupported", False).Direction = ParameterDirection.Output

            Try
                sqlConn.Open()
                cmdInfo.ExecuteNonQuery()
                blnCatalogExist = cmdInfo.Parameters("@kartrisCatalogExist").Value
                blnFTSEnabled = cmdInfo.Parameters("@kartrisFTSEnabled").Value
            Catch ex As Exception
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using

        If blnCatalogExist AndAlso blnFTSEnabled Then Return True

        Return False
    End Function



    Public Shared Sub SetupFTS()
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdInfo As SqlCommand = sqlConn.CreateCommand
            cmdInfo.CommandText = "_spKartrisDB_SetupFTS"
            cmdInfo.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                cmdInfo.ExecuteNonQuery()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
    End Sub
    Public Shared Sub StopFTS()
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdInfo As SqlCommand = sqlConn.CreateCommand
            cmdInfo.CommandText = "_spKartrisDB_StopFTS"
            cmdInfo.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                cmdInfo.ExecuteNonQuery()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
        End Using
    End Sub


#Region " Admin Triggers        "
    Public Shared Function _GetKartrisTriggers() As DataTable
        Dim triggerAdptr As New TriggersTblAdptr
        Return triggerAdptr._GetDBTriggers()
    End Function
    Public Shared Sub _EnableTrigger(ByVal pTableName As String, ByVal pTriggerName As String)
        Dim triggerAdptr As New TriggersTblAdptr, numStatus As Short = 0
        triggerAdptr._EnableDBTrigger(pTriggerName, pTableName, numStatus)
        _AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Triggers, _
                IIf(numStatus = 1, "Succeeded.", "Failed"), "_spKartrisDB_EnableTrigger##", pTriggerName)
    End Sub
    Public Shared Sub _DisableTrigger(ByVal pTableName As String, ByVal pTriggerName As String)
        Dim triggerAdptr As New TriggersTblAdptr, numStatus As Short = 0
        triggerAdptr._DisableDBTrigger(pTriggerName, pTableName, numStatus)
        _AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Triggers, _
                IIf(numStatus = 0, "Succeeded.", "Failed"), "_spKartrisDB_DisableTrigger##", pTriggerName)
    End Sub
    Public Shared Sub _EnableAllTriggers()
        Dim triggerAdptr As New TriggersTblAdptr, numStatus As Short = 0
        triggerAdptr._EnableAllDBTriggers()
        _AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Triggers, Nothing, "_spKartrisDB_EnableAllTrigers", Nothing)
    End Sub
    Public Shared Sub _DisableAllTriggers()
        Dim triggerAdptr As New TriggersTblAdptr, numStatus As Short = 0
        triggerAdptr._DisableAllDBTriggers()
        _AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Triggers, Nothing, "_spKartrisDB_DisableAllTrigers", Nothing)
    End Sub
#End Region
#Region " Admin Log                 "
    Public Shared Sub _AddAdminLog(ByVal numLoginName As String, ByVal strType As ADMIN_LOG_TABLE, ByVal strDesc As String, _
                        ByVal strQuery As String, ByVal strRelatedID As String, _
                        Optional ByVal sqlConn As SqlConnection = Nothing, Optional ByVal savePoint As SqlTransaction = Nothing)
        Try

            If sqlConn Is Nothing Then
                Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
                sqlConn = New SqlConnection(strConnString)
                sqlConn.Open()
            End If

            Dim cmdAddAdminLog As New SqlCommand("_spKartrisAdminLog_AddNewAdminLog", sqlConn)
            cmdAddAdminLog.CommandType = CommandType.StoredProcedure

            If savePoint IsNot Nothing Then cmdAddAdminLog.Transaction = savePoint

            cmdAddAdminLog.Parameters.AddWithValue("@LoginName", FixNullToDB(numLoginName))
            cmdAddAdminLog.Parameters.AddWithValue("@Type", FixNullToDB(strType.ToString()))
            cmdAddAdminLog.Parameters.AddWithValue("@Desc", FixNullToDB(strDesc))
            cmdAddAdminLog.Parameters.AddWithValue("@Query", FixNullToDB(strQuery))
            cmdAddAdminLog.Parameters.AddWithValue("@RelatedID", FixNullToDB(strRelatedID))
            cmdAddAdminLog.Parameters.AddWithValue("@IP", FixNullToDB(HttpContext.Current.Request.ServerVariables("REMOTE_ADDR")))
            cmdAddAdminLog.Parameters.AddWithValue("@NowOffset", CkartrisDisplayFunctions.NowOffset)

            cmdAddAdminLog.ExecuteNonQuery()

            If savePoint Is Nothing Then sqlConn.Close()
        Catch ex As Exception
            Dim strMsg As String = ""
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            If savePoint IsNot Nothing Then Throw New ApplicationException(strMsg)
        Finally
            If savePoint Is Nothing Then
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End If
        End Try

    End Sub

    Public Shared Function _PurgeOldLogs(ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisAdminLog_PurgeOldData"
            cmd.CommandType = CommandType.StoredProcedure

            Try
                sqlConn.Open()
                cmd.Parameters.AddWithValue("@PurgeDate", Now.AddDays(0 - CInt(GetKartConfig("backend.adminlog.purgedays"))))
                cmd.ExecuteNonQuery()
                sqlConn.Close()

                Return True
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close()
            End Try
            Return False
        End Using
    End Function
    Public Shared Function _SearchAdminLog(ByVal strKeyword As String, ByVal strType As String, ByVal datFrom As Date, ByVal datTo As Date) As DataTable
        Dim adptrAdminLog As New AdminLogTblAdptr
        Return adptrAdminLog._Search(strKeyword, strType, datFrom, datTo)
    End Function
    Public Shared Function _GetLogByID(ByVal numLogID As Integer) As DataRow
        Dim adptrAdminLog As New AdminLogTblAdptr
        Try
            Return adptrAdminLog._GetByID(numLogID).Rows(0)
        Catch ex As Exception
        End Try
        Return Nothing
    End Function
#End Region
#Region " Admin Related Tables      "
    Public Shared Sub _AdminClearRelatedData(ByVal chrDataType As Char, ByVal strUser As String, ByVal strPassword As String, _
            ByRef blnSucceeded As Boolean, ByRef strMsg As String)

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdClearProductsData As SqlCommand = sqlConn.CreateCommand
            cmdClearProductsData.CommandText = "_spKartrisAdminRelatedTables_Clear"

            Dim savePoint As SqlTransaction = Nothing
            cmdClearProductsData.CommandType = CommandType.StoredProcedure
            Try
                cmdClearProductsData.Parameters.AddWithValue("@DataType", FixNullToDB(chrDataType, "c"))
                cmdClearProductsData.Parameters.AddWithValue("@UserName", FixNullToDB(strUser, "s"))
                cmdClearProductsData.Parameters.AddWithValue("@Password", UsersBLL.EncryptSHA256Managed(FixNullToDB(strPassword), LoginsBLL._GetSaltByUserName(strUser), True))
                cmdClearProductsData.Parameters.AddWithValue("@IPAddress", FixNullToDB(HttpContext.Current.Request.ServerVariables("REMOTE_ADDR")))
                cmdClearProductsData.Parameters.AddWithValue("@Succeeded", False).Direction = ParameterDirection.Output
                cmdClearProductsData.Parameters.Add("@Output", SqlDbType.NVarChar, 4000).Direction = ParameterDirection.Output
                cmdClearProductsData.Parameters("@Output").Value = ""

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdClearProductsData.Transaction = savePoint

                cmdClearProductsData.ExecuteNonQuery()
                strMsg = cmdClearProductsData.Parameters("@Output").Value
                Dim strRelatedRecords As String = ""
                If chrDataType = "P" Then strRelatedRecords = "Products Related Tables"
                If chrDataType = "O" Then strRelatedRecords = "Orders Related Tables"
                If chrDataType = "S" Then strRelatedRecords = "Sessions Related Tables"
                If chrDataType = "C" Then strRelatedRecords = "Content Related Tables"
                blnSucceeded = CBool(cmdClearProductsData.Parameters("@Succeeded").Value)
                cmdClearProductsData.Parameters("@Password").Value = "[HIDDEN]"
                _AddAdminLog(strUser, ADMIN_LOG_TABLE.DataRecords, IIf(blnSucceeded, "Succeeded", "Failed"), _
                CreateQuery(cmdClearProductsData), strRelatedRecords, sqlConn, savePoint)
                savePoint.Commit()
                CkartrisBLL.RefreshKartrisCache()
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Sub
    Public Shared Function _GetAdminRelatedTables(ByVal chrDataType As Char) As DataTable
        Dim adptr As New AdminRelatedTablesTblAdptr
        Return adptr._GetByTpe(chrDataType)
    End Function
#End Region
#Region " Admin Execute Query    "
    Public Shared Function _ExecuteQuery(ByVal strQuery As String, ByRef numAffectedRecords As Integer, _
               ByRef tblReturnedRecords As DataTable, ByVal strUser As String, ByRef strMessage As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdExecuteQuery As SqlCommand = sqlConn.CreateCommand
            cmdExecuteQuery.CommandText = "_spKartrisDB_ExecuteQuery"

            Dim savePoint As SqlTransaction = Nothing
            cmdExecuteQuery.CommandType = CommandType.StoredProcedure
            cmdExecuteQuery.Parameters.AddWithValue("@QueryText", FixNullToDB(strQuery, "s"))

            Dim strExecutionSucceeded As String = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
            Dim strExecutionFailed As String = GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom")
            Dim strExecutionNotAllowed As String = HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgCommandNotAllowed")
            Dim blnCommandAllowed As Boolean = True

            Select Case Left(strQuery, 6).ToUpper
                Case "SELECT"
                    Try
                        Using adptr As New SqlDataAdapter(cmdExecuteQuery)
                            adptr.Fill(tblReturnedRecords)
                            sqlConn.Open()
                            savePoint = sqlConn.BeginTransaction()
                            cmdExecuteQuery.Transaction = savePoint
                            _AddAdminLog(strUser, ADMIN_LOG_TABLE.ExecuteQuery, strExecutionSucceeded, _
                              cmdExecuteQuery.CommandText & "##@QueryText=" & strQuery, Nothing, sqlConn, savePoint)
                            savePoint.Commit()
                            Return True
                        End Using
                    Catch ex As Exception
                        ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
                        If Not savePoint Is Nothing Then savePoint.Rollback()
                    Finally
                        If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
                    End Try
                Case Else
                    If Left(strQuery, 6).ToUpper = "INSERT" OrElse _
                        Left(strQuery, 6).ToUpper = "UPDATE" OrElse _
                        Left(strQuery, 6).ToUpper = "DELETE" OrElse _
                        Left(strQuery, 15).ToUpper = "ALTER PROCEDURE" OrElse _
                        Left(strQuery, 16).ToUpper = "CREATE PROCEDURE" Then
                        Try
                            sqlConn.Open()
                            savePoint = sqlConn.BeginTransaction()
                            cmdExecuteQuery.Transaction = savePoint
                            numAffectedRecords = cmdExecuteQuery.ExecuteNonQuery()
                            _AddAdminLog(strUser, ADMIN_LOG_TABLE.ExecuteQuery, strExecutionSucceeded, _
                              cmdExecuteQuery.CommandText & "##@QueryText=" & strQuery, Nothing, sqlConn, savePoint)
                            savePoint.Commit()
                            Return True
                        Catch ex As Exception
                            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
                            If Not savePoint Is Nothing Then savePoint.Rollback()
                        Finally
                            If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
                        End Try
                    Else
                        blnCommandAllowed = False
                        strMessage = strExecutionNotAllowed
                    End If
            End Select

            Try
                _AddAdminLog(strUser, ADMIN_LOG_TABLE.ExecuteQuery, IIf(blnCommandAllowed, strExecutionFailed, strExecutionNotAllowed), _
                  cmdExecuteQuery.CommandText & "##@QueryText=" & strQuery, Nothing)
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
            End Try

        End Using
        Return False
    End Function
#End Region
#Region " Deleted Items             "
    Public Shared Sub DeleteNotNeededFiles()
        Dim tblDeleted As DataTable = _GetDeletedItems()
        For Each row As DataRow In tblDeleted.Rows
            Dim numID As Long = FixNullFromDB(row("Deleted_ID"))
            Dim chrType As Char = FixNullFromDB(row("Deleted_Type"))
            If numID <> Nothing AndAlso chrType <> Nothing Then
                Try
                    Select Case chrType
                        Case "c" '' Category
                            Dim tblRecord As DataTable = CategoriesBLL._GetByID(numID)
                            If tblRecord.Rows.Count = 0 Then
                                CkartrisImages.RemoveImages(CkartrisImages.IMAGE_TYPE.enum_CategoryImage, numID)
                            End If
                            _DeleteRecord(numID, chrType)
                        Case "p" '' Product
                            Dim tblRecord As DataTable = ProductsBLL._GetProductInfoByID(numID)
                            If tblRecord.Rows.Count = 0 Then
                                CkartrisImages.RemoveImages(CkartrisImages.IMAGE_TYPE.enum_ProductImage, numID)
                            End If
                            _DeleteRecord(numID, chrType)
                        Case "v" '' Version
                            If CInt(FixNullFromDB(row("Deleted_VersionProduct"))) <> Nothing Then
                                Dim tblRecord As DataTable = VersionsBLL._GetVersionByID(numID)
                                If tblRecord.Rows.Count = 0 Then
                                    CkartrisImages.RemoveImages(CkartrisImages.IMAGE_TYPE.enum_VersionImage, numID, row("Deleted_VersionProduct"))
                                End If
                            End If
                            _DeleteRecord(numID, chrType)
                        Case "m" '' Media
                            Dim tblRecord As DataTable = MediaBLL._GetMediaLinkByID(numID)
                            If tblRecord.Rows.Count = 0 Then
                                CkartrisMedia.RemoveMedia(numID)
                            End If
                            _DeleteRecord(numID, chrType)
                        Case "r" '' Promotion
                            Dim tblRecord As DataTable = PromotionsBLL._GetPromotionByID(numID)
                            If tblRecord.Rows.Count = 0 Then
                                CkartrisImages.RemoveImages(CkartrisImages.IMAGE_TYPE.enum_PromotionImage, numID)
                            End If
                            _DeleteRecord(numID, chrType)
                    End Select
                Catch ex As Exception
                End Try
            End If

        Next
    End Sub
    Public Shared Function _GetDeletedItems() As DataTable
        Dim adptr As New DeletedItemsTblAdptr
        Return adptr._GetData()
    End Function
    Shared Sub _DeleteRecord(ByVal numID As Long, ByVal strType As String)
        Try
            Dim adptr As New DeletedItemsTblAdptr
            adptr._Delete(numID, strType)
        Catch ex As Exception
        End Try
    End Sub
#End Region
End Class
