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
Imports kartrisAttributesData
Imports kartrisAttributesDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports CkartrisFormatErrors

Public Class AttributesBLL

    Private Shared _Adptr As AttributesTblAdpt = Nothing
    Private Shared _AdptrValues As AttributeValuesTblAdptr = Nothing
    Private Shared _AdptrOptions As AttributeOptionsTblAdpt = Nothing
    Private Shared _AdptrProductOption As AttributeProductOptionsTblAdpt = Nothing

    Protected Shared ReadOnly Property Adptr() As AttributesTblAdpt
        Get
            _Adptr = New AttributesTblAdpt
            Return _Adptr
        End Get
    End Property
    Protected Shared ReadOnly Property AdptrValues() As AttributeValuesTblAdptr
        Get
            _AdptrValues = New AttributeValuesTblAdptr
            Return _AdptrValues
        End Get
    End Property

    Protected Shared ReadOnly Property AdptrOptions() As AttributeOptionsTblAdpt
        Get
            _AdptrOptions = New AttributeOptionsTblAdpt
            Return _AdptrOptions
        End Get
    End Property

    Protected Shared ReadOnly Property AdptrProductOptions() As AttributeProductOptionsTblAdpt
        Get
            _AdptrProductOption = New AttributeProductOptionsTblAdpt
            Return _AdptrProductOption
        End Get
    End Property

    Public Shared Function GetAttributesByCategoryId(ByVal numCategoryId As Integer) As DataTable
        Return Adptr._GetByCategoryId(numCategoryId)
    End Function

    Public Shared Function GetSummaryAttributesByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As DataTable
        Return Adptr.GetSummaryByProductID(_ProductID, _LanguageID)
    End Function

    Public Shared Function GetSpecialAttributesByProductID(ByVal _ProductID As Integer, ByVal _LanguageID As Short) As DataTable
        Return Adptr._GetSpecialByProductID(_ProductID, _LanguageID)
    End Function

    Public Shared Function _GetAttributesByLanguage(ByVal languageID As Byte) As DataTable
        Return Adptr._GetByLanguage(languageID)
    End Function

    Public Shared Function _GetAttributeValuesByProduct(ByVal intProductID As Integer) As DataTable
        Return AdptrValues._GetByProductID(intProductID)
    End Function

    Public Shared Function _GetByAttributeID(ByVal numAttributeID As Integer) As DataTable
        Return Adptr._GetByAttributeID(numAttributeID)
    End Function

    Public Shared Function GetOptionsByAttributeID(ByVal numAttributeID As Integer) As DataTable
        Return AdptrOptions.GetDataBy(numAttributeID)
    End Function

    ''' <summary>
    ''' Get the Attribute Options that have been assigned to a given product
    ''' </summary>
    ''' <param name="ProductId">The product to check</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetAttributeOptionsByProductID(ByVal ProductId As Integer) As DataTable
        Return AdptrProductOptions._GetByProductID(ProductId)
    End Function

    ''' <summary>
    ''' Add new attribute option to the product so that we have an option for the product
    ''' </summary>
    ''' <param name="AttributeOptionID"></param>
    ''' <param name="ProductId"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _AddAttributeProductOption(ByVal AttributeOptionID As Integer, ByVal ProductId As Integer,
                                                      ByRef strMsg As String) As Integer
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdAddAttribute As SqlCommand = sqlConn.CreateCommand
            cmdAddAttribute.CommandText = "_spKartrisAttributeProductOption_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmdAddAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdAddAttribute.Parameters.AddWithValue("@AttributeOptionId", AttributeOptionID)
                cmdAddAttribute.Parameters.AddWithValue("@ProductId", ProductId)
                cmdAddAttribute.Parameters.AddWithValue("@AttributeProductId", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddAttribute.Transaction = savePoint

                cmdAddAttribute.ExecuteNonQuery()

                If cmdAddAttribute.Parameters("@AttributeProductId").Value Is Nothing OrElse _
                  cmdAddAttribute.Parameters("@AttributeProductId").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewAttributeProductOptionID As Integer = cmdAddAttribute.Parameters("@AttributeProductId").Value


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
    ''' Update an existing attribute option
    ''' </summary>
    ''' <param name="tblElements"></param>
    ''' <param name="numAttributeID"></param>
    ''' <param name="OrderBy"></param>
    ''' <param name="strMsg"></param>
    ''' <returns></returns>
    ''' <remarks>Attribute options are the selectable check box items under an attribute (e.g. the colours under the attribute 'color')</remarks>
    Public Shared Function _UpdateAttributeOption(ByVal tblElements As DataTable,
                                                  ByVal numAttributeID As Integer,
                                                  ByVal OrderBy As Integer,
                                                  ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdAddAttribute As SqlCommand = sqlConn.CreateCommand
            cmdAddAttribute.CommandText = "_spKartrisAttributeOption_Update"

            Dim savePoint As SqlTransaction = Nothing
            cmdAddAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdAddAttribute.Parameters.AddWithValue("@AttributeOptionId", numAttributeID)
                cmdAddAttribute.Parameters.AddWithValue("@OrderByValue", OrderBy)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddAttribute.Transaction = savePoint

                cmdAddAttribute.ExecuteNonQuery()

                Dim intAttributeOptionID As Integer = cmdAddAttribute.Parameters("@AttributeOptionId").Value
                If Not LanguageElementsBLL._UpdateLanguageElements( _
                    tblElements, LANG_ELEM_TABLE_TYPE.AttributeOption, intAttributeOptionID, sqlConn, savePoint) Then
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

    ''' <summary>
    ''' Add a new attribute option to the database
    ''' </summary>
    ''' <param name="tblElements"></param>
    ''' <param name="numAttributeID"></param>
    ''' <param name="OrderBy"></param>
    ''' <param name="strMsg"></param>
    ''' <returns></returns>
    ''' <remarks>Attribute options are the selectable check box items under an attribute (e.g. the colours under the attribute 'color')</remarks>
    Public Shared Function _AddNewAttributeOption(ByVal tblElements As DataTable,
                                                  ByVal numAttributeID As Integer,
                                                  ByVal OrderBy As Integer,
                                                  ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdAddAttribute As SqlCommand = sqlConn.CreateCommand
            cmdAddAttribute.CommandText = "_spKartrisAttributeOption_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmdAddAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdAddAttribute.Parameters.AddWithValue("@AttributeId", numAttributeID)
                cmdAddAttribute.Parameters.AddWithValue("@OrderByValue", OrderBy)
                cmdAddAttribute.Parameters.AddWithValue("@NewAttributeOption_ID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddAttribute.Transaction = savePoint

                cmdAddAttribute.ExecuteNonQuery()

                If cmdAddAttribute.Parameters("@NewAttributeOption_ID").Value Is Nothing OrElse _
                  cmdAddAttribute.Parameters("@NewAttributeOption_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewAttributeOptionID As Integer = cmdAddAttribute.Parameters("@NewAttributeOption_ID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                  tblElements, LANG_ELEM_TABLE_TYPE.AttributeOption, intNewAttributeOptionID, sqlConn, savePoint) Then
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

    ''' <summary>
    ''' Delete an option within an attribute
    ''' </summary>
    ''' <param name="AttributeOptionID"></param>
    ''' <param name="strMsg">Pointer to error message</param>
    ''' <returns>True if operation successful</returns>
    ''' <remarks></remarks>
    Public Shared Function _DeleteAttributeOption(ByVal AttributeOptionID As Integer,
                                                  ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateAttribute As SqlCommand = sqlConn.CreateCommand
            cmdUpdateAttribute.CommandText = "_spKartrisAttributeOption_Delete"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateAttribute.Parameters.AddWithValue("@AttributeOptionId", AttributeOptionID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateAttribute.Transaction = savePoint

                cmdUpdateAttribute.ExecuteNonQuery()

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
    ''' Delete all product options for a given attribute and product
    ''' </summary>
    ''' <param name="AttributeId"></param>
    ''' <param name="strMsg"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function _DeleteAttributeProductOptions(ByVal AttributeId As Integer,
                                                          ByVal ProductId As Integer,
                                                          ByRef strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateAttribute As SqlCommand = sqlConn.CreateCommand
            cmdUpdateAttribute.CommandText = "_spKartrisAttributeProductOptions_DeleteByAttributeIdAndProductId"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateAttribute.Parameters.AddWithValue("@AttributeId", AttributeId)
                cmdUpdateAttribute.Parameters.AddWithValue("@ProductId", ProductId)
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateAttribute.Transaction = savePoint

                cmdUpdateAttribute.ExecuteNonQuery()

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

    Public Shared Function _AddNewAttribute(ByVal tblElements As DataTable, ByVal chrType As Char, _
              ByVal blnLive As Boolean, ByVal blnFastEntry As Boolean, ByVal blnShowFront As Boolean, _
              ByVal blnShowSearch As Boolean, ByVal numOrderNo As Byte, _
              ByVal chrCompare As Char, ByVal blnSpecial As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdAddAttribute As SqlCommand = sqlConn.CreateCommand
            cmdAddAttribute.CommandText = "_spKartrisAttributes_Add"

            Dim savePoint As SqlTransaction = Nothing
            cmdAddAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdAddAttribute.Parameters.AddWithValue("@Type", chrType)
                cmdAddAttribute.Parameters.AddWithValue("@Live", blnLive)
                cmdAddAttribute.Parameters.AddWithValue("@FastEntry", blnFastEntry)
                cmdAddAttribute.Parameters.AddWithValue("@ShowFrontend", blnShowFront)
                cmdAddAttribute.Parameters.AddWithValue("@ShowSearch", blnShowSearch)
                cmdAddAttribute.Parameters.AddWithValue("@OrderByValue", numOrderNo)
                cmdAddAttribute.Parameters.AddWithValue("@Compare", chrCompare)
                cmdAddAttribute.Parameters.AddWithValue("@Special", blnSpecial)
                cmdAddAttribute.Parameters.AddWithValue("@NewAttribute_ID", 0).Direction = ParameterDirection.Output

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddAttribute.Transaction = savePoint

                cmdAddAttribute.ExecuteNonQuery()

                If cmdAddAttribute.Parameters("@NewAttribute_ID").Value Is Nothing OrElse _
                  cmdAddAttribute.Parameters("@NewAttribute_ID").Value Is DBNull.Value Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                Dim intNewAttributeID As Integer = cmdAddAttribute.Parameters("@NewAttribute_ID").Value
                If Not LanguageElementsBLL._AddLanguageElements( _
                  tblElements, LANG_ELEM_TABLE_TYPE.Attributes, intNewAttributeID, sqlConn, savePoint) Then
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

    Public Shared Function _UpdateAttribute(ByVal tblElements As DataTable, ByVal numAttributeID As Integer, ByVal chrType As Char, _
              ByVal blnLive As Boolean, ByVal blnFastEntry As Boolean, ByVal blnShowFront As Boolean, _
              ByVal blnShowSearch As Boolean, ByVal numOrderNo As Byte, _
              ByVal chrCompare As Char, ByVal blnSpecial As Boolean, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateAttribute As SqlCommand = sqlConn.CreateCommand
            cmdUpdateAttribute.CommandText = "_spKartrisAttributes_Update"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateAttribute.Parameters.AddWithValue("@Original_AttributeID", numAttributeID)
                cmdUpdateAttribute.Parameters.AddWithValue("@Type", chrType)
                cmdUpdateAttribute.Parameters.AddWithValue("@Live", blnLive)
                cmdUpdateAttribute.Parameters.AddWithValue("@FastEntry", blnFastEntry)
                cmdUpdateAttribute.Parameters.AddWithValue("@ShowFrontend", blnShowFront)
                cmdUpdateAttribute.Parameters.AddWithValue("@ShowSearch", blnShowSearch)
                cmdUpdateAttribute.Parameters.AddWithValue("@OrderByValue", numOrderNo)
                cmdUpdateAttribute.Parameters.AddWithValue("@Compare", chrCompare)
                cmdUpdateAttribute.Parameters.AddWithValue("@Special", blnSpecial)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateAttribute.Transaction = savePoint

                cmdUpdateAttribute.ExecuteNonQuery()

                If Not LanguageElementsBLL._UpdateLanguageElements( _
                  tblElements, LANG_ELEM_TABLE_TYPE.Attributes, numAttributeID, sqlConn, savePoint) Then
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

    Public Shared Function _DeleteAttribute(ByVal numAttributeID As Integer, ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdUpdateAttribute As SqlCommand = sqlConn.CreateCommand
            cmdUpdateAttribute.CommandText = "_spKartrisAttributes_Delete"

            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateAttribute.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateAttribute.Parameters.AddWithValue("@AttributeID", numAttributeID)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateAttribute.Transaction = savePoint

                cmdUpdateAttribute.ExecuteNonQuery()

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

    Public Shared Function _UpdateAttributeValues(ByVal intProductID As Integer, ByVal tblProductAttributes As DataTable,
                                                    ByVal tblLanguageElements As DataTable,
                                                    ByVal tblAttributeOptions As DataTable,
                                                    ByRef strMsg As String) As Boolean

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim savePoint As SqlTransaction = Nothing
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()

                '' 1. DELETE From The Product's Attribute Values
                If Not _DeleteAttributeValuesByProductID(intProductID, sqlConn, savePoint) Then
                    Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                End If

                '' 2. CREATE New Attribute Values
                For Each row As DataRow In tblProductAttributes.Rows
                    Dim ProductID As Integer = CInt(row("ProductID"))
                    Dim AttributeID As Integer = CInt(row("AttributeID"))
                    Dim AttributeType As String = row("AttributeType")
                    Dim AttributeValueID As Integer = _AddAttributeValue(ProductID, AttributeID, sqlConn, savePoint)

                    If AttributeValueID <> 0 Then
                        If AttributeType = "t" Then
                            ' Text type attribute
                            Dim tblValuesLanguageElements As New DataTable
                            tblValuesLanguageElements = tblLanguageElements.Select("ProductID=" & ProductID & " AND AttributeID=" & AttributeID).CopyToDataTable()
                            tblValuesLanguageElements.Columns.Remove("ProductID")
                            tblValuesLanguageElements.Columns.Remove("AttributeID")

                            If Not LanguageElementsBLL._AddLanguageElements(tblValuesLanguageElements, _
                                    LANG_ELEM_TABLE_TYPE.AttributeValues, AttributeValueID, sqlConn, savePoint) Then
                                '' 3. CREATE The Language Element for each one.
                                Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                            End If
                        ElseIf AttributeType = "c" Then
                            ' checkbox or Yes/No datatype
                            ' First delete all existing entries, then reinsert them (no 'update' function)
                            If _DeleteAttributeProductOptions(AttributeID, ProductID, strMsg) Then
                                For Each dr As DataRow In tblAttributeOptions.Select("AttributeID = " & AttributeID)
                                    ' Loop through all rows for this attribute.
                                    _AddAttributeProductOption(dr("AttributeOptionId"), ProductID, strMsg)
                                Next
                            Else
                                Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                            End If
                        End If
                    Else
                        Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
                    End If
                Next
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

    Private Shared Function _DeleteAttributeValuesByProductID(ByVal intProductID As Integer, ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Boolean
        Try
            Dim cmdDelete As New SqlCommand("_spKartrisAttributeValues_DeleteByProductID", sqlConn, savePoint)
            cmdDelete.CommandType = CommandType.StoredProcedure
            cmdDelete.Parameters.AddWithValue("@ProductID", intProductID)
            cmdDelete.ExecuteNonQuery()
            Return True
            'End Using
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
        End Try
        Return False
    End Function

    Private Shared Function _AddAttributeValue(ByVal intProductID As Integer, ByVal numAttributeID As Integer, ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Integer
        Try
            Dim cmdAdd As New SqlCommand("_spKartrisAttributeValues_Add", sqlConn, savePoint)
            cmdAdd.CommandType = CommandType.StoredProcedure
            cmdAdd.Parameters.AddWithValue("@ProductID", intProductID)
            cmdAdd.Parameters.AddWithValue("@AttributeID", numAttributeID)
            cmdAdd.Parameters.AddWithValue("@NewAttributeValue_ID", 0).Direction = ParameterDirection.Output
            cmdAdd.ExecuteNonQuery()

            If cmdAdd.Parameters("@NewAttributeValue_ID").Value Is Nothing OrElse _
                cmdAdd.Parameters("@NewAttributeValue_ID").Value Is DBNull.Value Then
                Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
            End If

            Return CInt(cmdAdd.Parameters("@NewAttributeValue_ID").Value)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            If Not savePoint Is Nothing Then savePoint.Rollback()
        End Try
        Return 0
    End Function

    Public Shared Function _GetPotentialAttributeOptionsByProduct(ByVal ProductId As Integer, ByVal AttributeId As Integer) As DataTable
        _GetPotentialAttributeOptionsByProduct = Nothing
        Dim strMsg As String = ""

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdStr As String = "_spDeadlineAttributeOptionsByOptionId"
            Dim cmd As New SqlCommand(cmdStr, sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@P_ID", ProductId)
            cmd.Parameters.AddWithValue("@Attribute_ID", AttributeId)
            Try
                sqlConn.Open()
                Using sda As New SqlDataAdapter(cmd)
                    Dim dt As New DataTable()
                    sda.Fill(dt)
                    Return dt
                End Using
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                sqlConn.Close()
                cmd.Dispose()
            End Try
        End Using
    End Function
End Class
