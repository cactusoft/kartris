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
Imports kartrisAttributesData
Imports kartrisAttributesDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports CkartrisFormatErrors

Public Class AttributesBLL

    Private Shared _Adptr As AttributesTblAdpt = Nothing
    Private Shared _AdptrValues As AttributeValuesTblAdptr = Nothing

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

    Public Shared Function _GetByAttributeID(ByVal numAttributeID As Byte) As DataTable
        Return Adptr._GetByAttributeID(numAttributeID)
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

                Dim intNewAttributeID As Byte = cmdAddAttribute.Parameters("@NewAttribute_ID").Value
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
    Public Shared Function _UpdateAttribute(ByVal tblElements As DataTable, ByVal numAttributeID As Byte, ByVal chrType As Char, _
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
    Public Shared Function _DeleteAttribute(ByVal numAttributeID As Byte, ByRef strMsg As String) As Boolean

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

    Public Shared Function _UpdateAttributeValues(ByVal intProductID As Integer, ByVal tblProductAttributes As DataTable, _
                                           ByVal tblLanguageElements As DataTable, ByRef strMsg As String) As Boolean

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
                    Dim AttributeID As Byte = CByte(row("AttributeID"))
                    Dim AttributeValueID As Integer = _AddAttributeValue(ProductID, AttributeID, sqlConn, savePoint)

                    If AttributeValueID <> 0 Then
                        Dim tblValuesLanguageElements As New DataTable
                        tblValuesLanguageElements = tblLanguageElements.Select("ProductID=" & ProductID & " AND AttributeID=" & AttributeID).CopyToDataTable()
                        tblValuesLanguageElements.Columns.Remove("ProductID")
                        tblValuesLanguageElements.Columns.Remove("AttributeID")

                        If Not LanguageElementsBLL._AddLanguageElements(tblValuesLanguageElements, _
                                LANG_ELEM_TABLE_TYPE.AttributeValues, AttributeValueID, sqlConn, savePoint) Then
                            '' 3. CREATE The Language Element for each one.
                            Throw New ApplicationException(GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBCustom"))
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
    Private Shared Function _AddAttributeValue(ByVal intProductID As Integer, ByVal numAttributeID As Byte, ByVal sqlConn As SqlConnection, ByVal savePoint As SqlTransaction) As Integer
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
End Class
