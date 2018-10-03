'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation
Imports CkartrisFormatErrors
Imports System.Data
Imports System.Data.SqlClient
Imports kartrisSubSitesData
Imports kartrisSubSitesDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations

Public Class SubSitesBLL


    Private Shared _Adptr As SubSitesTblAdptr = Nothing
    'Private Shared _InvoiceRowsAdptr As InvoiceRowsTblAdptr = Nothing
    'Private Shared _PaymentsAdptr As PaymentsTblAdptr = Nothing

#Region "Properties - Adapters"
    'Protected Shared ReadOnly Property InvoiceRowsAdptr() As InvoiceRowsTblAdptr
    '    Get
    '        _InvoiceRowsAdptr = New InvoiceRowsTblAdptr
    '        Return _InvoiceRowsAdptr
    '    End Get
    'End Property

    Protected Shared ReadOnly Property Adptr() As SubSitesTblAdptr
        Get
            _Adptr = New SubSitesTblAdptr
            Return _Adptr
        End Get
    End Property

    'Protected Shared ReadOnly Property PaymentsAdptr() As PaymentsTblAdptr
    '    Get
    '        _PaymentsAdptr = New PaymentsTblAdptr
    '        Return _PaymentsAdptr
    '    End Get
    'End Property
#End Region

    'Public Shared Function _GetTileAppData(ByVal OrderSent As String, ByVal OrderInvoiced As String, ByVal OrderPaid As String,
    '                                  ByVal OrderShipped As String, ByVal OrderCancelled As String, ByVal DateRangeStart As Date,
    '                                  ByVal DateRangeEnd As Date, ByVal intRangeInMinutes As Integer) As DataTable
    '    Try

    '        ' Perform the update on the DataTable
    '        Return Adptr._GetTileAppData(OrderSent, OrderInvoiced, OrderPaid, OrderShipped, OrderCancelled,
    '                              DateRangeStart, DateRangeEnd, intRangeInMinutes)
    '        ' If we reach here, no errors, so commit the transaction

    '    Catch ex As Exception
    '        ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
    '        ' If we reach here, there was an error, so rollback the transaction
    '        Return Nothing
    '    End Try
    'End Function

    'Public Shared Sub _Delete(ByVal O_ID As Integer, ByVal blnReturnStock As Boolean)
    '    Try

    '        ' Perform the update on the DataTable
    '        Adptr._Delete(O_ID, blnReturnStock)
    '        ' If we reach here, no errors, so commit the transaction

    '    Catch ex As Exception
    '        ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
    '        ' If we reach here, there was an error, so rollback the transaction
    '    End Try
    'End Sub

    'Public Shared Sub _PurgeOrders(ByVal O_PurgeDate As Date)
    '    Try

    '        ' Perform the update on the DataTable
    '        Dim tblToPurgeOrders As DataTable = Adptr._ToPurgeOrdersList(O_PurgeDate)
    '        For Each dr As DataRow In tblToPurgeOrders.Rows
    '            Adptr._Delete(dr.Item(0).ToString(), False)
    '        Next
    '        ' If we reach here, no errors, so commit the transaction
    '    Catch ex As Exception
    '        ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
    '        ' If we reach here, there was an error, so rollback the transaction
    '    End Try
    'End Sub
    ''' <summary>
    ''' 
    ''' </summary>
    ''' <returns>Returns the newly created order ID</returns>


    Public Shared Function GetSubSites() As DataTable
        Return Adptr.GetData()
    End Function

    Public Shared Function GetSubSiteByID(ByVal SUB_ID As Long) As DataTable
        Return Adptr._GetSubSiteByID(SUB_ID)
    End Function

    'Public Shared Function _UpdateStatus(ByVal O_ID As Integer, ByVal O_Sent As Boolean, ByVal O_Paid As Boolean, ByVal O_Shipped As Boolean,
    '                                     ByVal O_Invoiced As Boolean, ByVal O_Status As String, ByVal O_Notes As String, ByVal O_Cancelled As Boolean) As Integer

    '    Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
    '    Using sqlConn As New SqlConnection(strConnString)
    '        Dim cmd As SqlCommand = sqlConn.CreateCommand
    '        cmd.CommandText = "_spKartrisOrders_UpdateStatus"
    '        Dim savePoint As SqlTransaction = Nothing
    '        cmd.CommandType = CommandType.StoredProcedure
    '        Try
    '            sqlConn.Open()
    '            savePoint = sqlConn.BeginTransaction()
    '            cmd.Transaction = savePoint
    '            ' Perform the update on the DataTable
    '            With cmd.Parameters
    '                .AddWithValue("@O_ID", O_ID)
    '                .AddWithValue("@O_LastModified", CkartrisDisplayFunctions.NowOffset)
    '                .AddWithValue("@O_Sent", IIf(O_Sent, 1, 0))
    '                .AddWithValue("@O_Invoiced", IIf(O_Invoiced, 1, 0))
    '                .AddWithValue("@O_Shipped", IIf(O_Shipped, 1, 0))
    '                .AddWithValue("@O_Paid", IIf(O_Paid, 1, 0))
    '                .AddWithValue("@O_Cancelled", IIf(O_Cancelled, 1, 0))
    '                .AddWithValue("@O_Status", O_Status)
    '                .AddWithValue("@O_Notes", O_Notes)
    '            End With

    '            Dim returnValue As Integer = cmd.ExecuteScalar
    '            If returnValue <> O_ID Then
    '                Throw New Exception("ID is 0? Something's not right")
    '            End If

    '            KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Orders,
    '             GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"),
    '             CreateQuery(cmd), O_ID, sqlConn, savePoint)

    '            ' If we reach here, no errors, so commit the transaction
    '            savePoint.Commit()
    '            sqlConn.Close()

    '            Return returnValue
    '        Catch ex As Exception
    '            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
    '            ' If we reach here, there was an error, so rollback the transaction
    '            savePoint.Rollback()
    '            Return 0
    '        End Try
    '    End Using
    'End Function


    Public Shared Function _Update(ByVal SUB_ID As Integer, ByVal SUB_Name As String, ByVal SUB_Domain As String, ByVal SUB_BaseCategoryID As Integer, ByVal SUB_SkinID As Integer, ByVal SUB_Notes As String, ByVal SUB_Live As Boolean) As Integer
        Try
            Dim dtNull As Nullable(Of DateTime) = Nothing
            Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return Adptr._Update(SUB_ID, SUB_Name, SUB_Domain, SUB_BaseCategoryID, SUB_SkinID, SUB_Notes, SUB_Live)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Return Nothing
        End Try

    End Function

    Public Shared Function _Add(ByVal SUB_Name As String, ByVal SUB_Domain As String, ByVal SUB_BaseCategoryID As Integer, ByVal SUB_SkinID As Integer, ByVal SUB_Notes As String, ByVal SUB_Live As Boolean) As Integer
        Try
            Dim dtNull As Nullable(Of DateTime) = Nothing
            Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
            Return Adptr._Add(SUB_Name, SUB_Domain, SUB_BaseCategoryID, SUB_SkinID, SUB_Notes, SUB_Live)
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Return Nothing
        End Try

    End Function

End Class