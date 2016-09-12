'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.HttpContext
Imports kartrisOptionsDataTableAdapters
Imports CkartrisEnumerations
Imports CkartrisFormatErrors

Public Class OptionsBLL

    Private Shared _OptionGroupAdptr As OptionGroupsTblAdptr = Nothing
    Private Shared _OptionAdptr As OptionsTblAdptr = Nothing
    Private Shared _ProductOptionGroupAdptr As ProductOptionGroupLinkTblAdptr = Nothing
    Private Shared _ProductOptionsAdptr As ProductOptionLinkTblAdptr = Nothing


    Protected Shared ReadOnly Property OptionGroupAdptr() As OptionGroupsTblAdptr
        Get
            _OptionGroupAdptr = New OptionGroupsTblAdptr
            Return _OptionGroupAdptr
        End Get
    End Property

    Protected Shared ReadOnly Property OptionAdptr() As OptionsTblAdptr
        Get
            _OptionAdptr = New OptionsTblAdptr
            Return _OptionAdptr
        End Get
    End Property

    Protected Shared ReadOnly Property ProductOptionGroupAdptr() As ProductOptionGroupLinkTblAdptr
        Get
            _ProductOptionGroupAdptr = New ProductOptionGroupLinkTblAdptr
            Return _ProductOptionGroupAdptr
        End Get
    End Property

    Protected Shared ReadOnly Property ProductOptionAdptr() As ProductOptionLinkTblAdptr
        Get
            _ProductOptionsAdptr = New ProductOptionLinkTblAdptr
            Return _ProductOptionsAdptr
        End Get
    End Property

    Public Shared Function _GetOptionSchema() As DataTable
        Dim tblTemp As DataTable = OptionAdptr._GetData()
        tblTemp.Clear()
        Return tblTemp
    End Function

    Public Shared Function _GetOptionGroupSchema() As DataTable
        Dim tblTemp As DataTable = OptionGroupAdptr._GetData()
        tblTemp.Clear()
        Return tblTemp
    End Function

    Public Shared Function _GetProductOptionSchema() As DataTable
        Dim tblTemp As DataTable = ProductOptionAdptr.GetData()
        tblTemp.Clear()
        Return tblTemp
    End Function

    Public Shared Function _GetProductGroupSchema() As DataTable
        Dim tblTemp As DataTable = ProductOptionGroupAdptr.GetData()
        tblTemp.Clear()
        Return tblTemp
    End Function

    Public Shared Function _GetOptionGroups() As DataTable
        Return OptionGroupAdptr._GetData()
    End Function

    Public Shared Function _GetOptionGroupPage(ByVal pPageIndx As Byte, ByVal pRowsPerPage As Integer, ByRef pTotalGroups As Integer) As DataTable
        Return OptionGroupAdptr._GetGroupsPage(pPageIndx, pRowsPerPage, pTotalGroups)
    End Function

    Public Shared Function _GetOptionsByGroupID(ByVal pGrpID As Integer, ByVal pLanguageID As Byte) As DataTable
        Return OptionAdptr._GetByGroupID(pLanguageID, pGrpID)
    End Function

    Public Shared Function _GetOptionGroupsByProductID(ByVal pProductID As Integer) As DataTable
        Return ProductOptionGroupAdptr._GetByProductID(pProductID)
    End Function

    Public Shared Function _GetOptionsByProductID(ByVal pProductID As Integer) As DataTable
        Return ProductOptionAdptr._GetByProductID(pProductID)
    End Function

    Public Shared Function _GetOptionsByProductAndGroup(ByVal pProductID As Integer, ByVal pGroupID As Integer, ByVal pLanguageID As Byte) As DataTable
        Return ProductOptionAdptr._GetOptionsByProductAndGroup(pProductID, pGroupID, pLanguageID)
    End Function

    Public Shared Function _AddOptionGrp(ByVal pBackendName As String, ByVal pDisplayType As Char, _
                                    ByVal pOrderByValue As Integer, ByVal ptblElements As DataTable, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdOptionGrp As SqlCommand = sqlConn.CreateCommand
            cmdOptionGrp.CommandText = "_spKartrisOptionGroups_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmdOptionGrp.CommandType = CommandType.StoredProcedure
            Try
                cmdOptionGrp.Parameters.AddWithValue("@OPTG_BackendName", pBackendName)
                cmdOptionGrp.Parameters.AddWithValue("@OPTG_OptionDisplayType", pDisplayType)
                cmdOptionGrp.Parameters.AddWithValue("@OPTG_DefOrderByValue", pOrderByValue)
                cmdOptionGrp.Parameters.AddWithValue("@NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdOptionGrp.Transaction = savePoint

                cmdOptionGrp.ExecuteNonQuery()

                If cmdOptionGrp.Parameters("@NewID").Value Is DBNull.Value OrElse _
                    cmdOptionGrp.Parameters("@NewID").Value Is Nothing Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim numNewGrpID As Integer = CInt(cmdOptionGrp.Parameters("@NewID").Value)

                numNewGrpID = CInt(cmdOptionGrp.Parameters("@NewID").Value)
                If Not LanguageElementsBLL._AddLanguageElements( _
                        ptblElements, LANG_ELEM_TABLE_TYPE.OptionGroups, _
                        numNewGrpID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                strMsg = ex.Message
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

        Return False

    End Function
    Public Shared Function _UpdateOptionGrp(ByVal pOptionGrpID As Integer, ByVal pBackendName As String, ByVal pDisplayType As Char, _
                                    ByVal pOrderByValue As Integer, ByVal ptblElements As DataTable, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdOptionGrp As SqlCommand = sqlConn.CreateCommand
            cmdOptionGrp.CommandText = "_spKartrisOptionGroups_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdOptionGrp.CommandType = CommandType.StoredProcedure
            Try
                cmdOptionGrp.Parameters.AddWithValue("@OPTG_BackendName", pBackendName)
                cmdOptionGrp.Parameters.AddWithValue("@OPTG_OptionDisplayType", pDisplayType)
                cmdOptionGrp.Parameters.AddWithValue("@OPTG_DefOrderByValue", pOrderByValue)
                cmdOptionGrp.Parameters.AddWithValue("@Original_OPTG_ID", pOptionGrpID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdOptionGrp.Transaction = savePoint

                cmdOptionGrp.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                                    ptblElements, LANG_ELEM_TABLE_TYPE.OptionGroups, pOptionGrpID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                strMsg = ex.Message
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

        Return False

    End Function
    Public Shared Function _DeleteOptionGrp(ByVal pOptionGrpID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdOptionGrp As SqlCommand = sqlConn.CreateCommand
            cmdOptionGrp.CommandText = "_spKartrisOptionGroups_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdOptionGrp.CommandType = CommandType.StoredProcedure
            Try
                cmdOptionGrp.Parameters.AddWithValue("@OPTG_ID", pOptionGrpID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdOptionGrp.Transaction = savePoint

                cmdOptionGrp.ExecuteNonQuery()

                savePoint.Commit()
                sqlConn.Close()
                strMsg = GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully")
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                strMsg = ex.Message
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

        Return False

    End Function

    Public Shared Function _AddOption(ByVal pOptionGrpID As Integer, ByVal pSelected As Boolean, ByVal pPriceChange As Single, _
                            ByVal pWeightChange As Single, ByVal pOrderByValue As Integer, ByVal ptblElements As DataTable, _
                            ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdOptionGrp As SqlCommand = sqlConn.CreateCommand
            cmdOptionGrp.CommandText = "_spKartrisOptions_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdOptionGrp.CommandType = CommandType.StoredProcedure
            Try
                cmdOptionGrp.Parameters.AddWithValue("@OPT_OptionGroupID", pOptionGrpID)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_CheckBoxValue", pSelected)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_DefPriceChange", pPriceChange)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_DefWeightChange", pWeightChange)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_DefOrderByValue", pOrderByValue)
                cmdOptionGrp.Parameters.AddWithValue("@NewID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdOptionGrp.Transaction = savePoint

                cmdOptionGrp.ExecuteNonQuery()

                If cmdOptionGrp.Parameters("@NewID").Value Is DBNull.Value OrElse _
                    cmdOptionGrp.Parameters("@NewID").Value Is Nothing Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim numNewOptionID As Integer = CInt(cmdOptionGrp.Parameters("@NewID").Value)

                If Not LanguageElementsBLL._AddLanguageElements( _
                        ptblElements, LANG_ELEM_TABLE_TYPE.Options, _
                        numNewOptionID, sqlConn, savePoint) Then
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
    Public Shared Function _UpdateOption(ByVal pOriginalOptionID As Integer, ByVal pOptionGrpID As Integer, ByVal pSelected As Boolean, ByVal pPriceChange As Single, _
                                ByVal pWeightChange As Single, ByVal pOrderByValue As Integer, ByVal ptblElements As DataTable, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdOptionGrp As SqlCommand = sqlConn.CreateCommand
            cmdOptionGrp.CommandText = "_spKartrisOptions_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdOptionGrp.CommandType = CommandType.StoredProcedure
            Try
                cmdOptionGrp.Parameters.AddWithValue("@OPT_OptionGroupID", pOptionGrpID)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_CheckBoxValue", pSelected)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_DefPriceChange", pPriceChange)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_DefWeightChange", pWeightChange)
                cmdOptionGrp.Parameters.AddWithValue("@OPT_DefOrderByValue", pOrderByValue)
                cmdOptionGrp.Parameters.AddWithValue("@Original_OPT_ID", pOriginalOptionID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdOptionGrp.Transaction = savePoint

                cmdOptionGrp.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                                    ptblElements, LANG_ELEM_TABLE_TYPE.Options, _
                                    pOriginalOptionID, sqlConn, savePoint) Then
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
    Public Shared Function _DeleteOption(ByVal pOptionID As Integer, ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdOptionGrp As SqlCommand = sqlConn.CreateCommand
            cmdOptionGrp.CommandText = "_spKartrisOptions_Delete"
            Dim savePoint As SqlTransaction = Nothing
            cmdOptionGrp.CommandType = CommandType.StoredProcedure
            Try
                cmdOptionGrp.Parameters.AddWithValue("@OPT_ID", pOptionID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdOptionGrp.Transaction = savePoint

                cmdOptionGrp.ExecuteNonQuery()

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

    Public Shared Function _CreateProductOptions(ByVal pProductID As Integer, ByVal ptblOptionGroupList As DataTable, _
                                                 ByVal ptblOptionsList As DataTable, ByRef strMsg As String) As Boolean
        '' To Create/Re-Create Options for the Product
        ''  --> 1. Delete the existing product's Options from ProductOptionLink.
        ''      2. Delete the existing product's OptionGroups from ProductOptionGroupLink.
        ''      3. Suspend the product's versions in the Versions Table
        ''      4. Create/Re-Create new records for the Product's Options & OptionGroups.
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim savePoint As SqlTransaction = Nothing
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()

                If Not _DeleteProductOptionsByProductID(pProductID, sqlConn, savePoint) Then Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                If Not _DeleteProductOptionGroupByProductID(pProductID, sqlConn, savePoint) Then Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                If Not _SuspendProductVersions(pProductID, sqlConn, savePoint) Then Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                If Not _AddProductOptionGroupLink(ptblOptionGroupList, sqlConn, savePoint) Then Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                If Not _AddProductOptionLink(ptblOptionsList, sqlConn, savePoint) Then Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
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

    Private Shared Function _AddProductOptionGroupLink(ByVal tblProductOptionGroup As DataTable, ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisProductOptionGroupLink_Add", sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            For Each row As DataRow In tblProductOptionGroup.Rows
                cmd.Parameters.AddWithValue("@ProductID", CInt(row("P_OPTG_ProductID")))
                cmd.Parameters.AddWithValue("@GroupID", CShort(row("P_OPTG_OptionGroupID")))
                cmd.Parameters.AddWithValue("@OrderBy", CInt(row("P_OPTG_OrderByValue")))
                cmd.Parameters.AddWithValue("@MustSelect", CBool(row("P_OPTG_MustSelected")))
                cmd.ExecuteNonQuery()
                cmd.Parameters.Clear()
            Next
            Return True
            'End Using
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try

        Return False
    End Function
    Private Shared Function _AddProductOptionLink(ByVal tblProductOptionLink As DataTable, ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisProductOptionLink_Add", sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            For Each row As DataRow In tblProductOptionLink.Rows
                cmd.Parameters.AddWithValue("@OptionID", CInt(row("P_OPT_OptionID")))
                cmd.Parameters.AddWithValue("@ProductID", CInt(row("P_OPT_ProductID")))
                cmd.Parameters.AddWithValue("@OrderBy", CInt(row("P_OPT_OrderByValue")))
                cmd.Parameters.AddWithValue("@PriceChange", CDec(row("P_OPT_PriceChange")))
                cmd.Parameters.AddWithValue("@WeightChange", CDbl(row("P_OPT_WeightChange")))
                cmd.Parameters.AddWithValue("@Selected", CBool(row("P_OPT_Selected")))
                cmd.ExecuteNonQuery()
                cmd.Parameters.Clear()
            Next
            Return True
            'End Using
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try

        Return False
    End Function
    Public Shared Function _DeleteProductOptionsByProductID(ByVal pProductID As Integer, ByVal pConn As SqlConnection, _
                                                      ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisProductOptionLink_DeleteByProductID", pConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            cmd.Parameters.AddWithValue("@ProductID", pProductID)
            cmd.ExecuteNonQuery()
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try

        Return False
    End Function
    Public Shared Function _DeleteProductOptionGroupByProductID(ByVal pProductID As Integer, ByVal pConn As SqlConnection, _
                                                      ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisProductOptionGroupLink_DeleteByProductID", pConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            cmd.Parameters.AddWithValue("@ProductID", pProductID)
            cmd.ExecuteNonQuery()
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try

        Return False
    End Function
    Private Shared Function _SuspendProductVersions(ByVal pProductID As Integer, ByVal pConn As SqlConnection, _
                                                      ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmd As New SqlCommand("_spKartrisVersions_SuspendProductVersions", pConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Transaction = savePoint
            cmd.Parameters.AddWithValue("@P_ID", pProductID)
            cmd.ExecuteNonQuery()
            Return True
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try

        Return False
    End Function

    'In v2.9006 we add a new feature, that means when updating an option,
    'you can choose to have all products that have option values for this
    'option to have their price and weight change values reset from the
    'change you make here.
    Public Shared Function _UpdateOptionValues(ByVal pOptionID As Integer, ByVal decPriceChange As Decimal, ByVal decWeightChange As Decimal) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdOption As SqlCommand = sqlConn.CreateCommand
            cmdOption.CommandText = "_spKartrisProductOptionLink_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdOption.CommandType = CommandType.StoredProcedure
            Try
                cmdOption.Parameters.AddWithValue("@P_OPT_OptionID", pOptionID)
                cmdOption.Parameters.AddWithValue("@P_OPT_PriceChange", decPriceChange)
                cmdOption.Parameters.AddWithValue("@P_OPT_WeightChange", decWeightChange)
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdOption.Transaction = savePoint

                cmdOption.ExecuteNonQuery()


                savePoint.Commit()
                sqlConn.Close()
                Return True

            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), "Error updating option values in bulk for existing products")
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using

        Return False
    End Function
End Class
