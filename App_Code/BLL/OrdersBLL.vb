'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

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
Imports kartrisOrdersData
Imports kartrisOrdersDataTableAdapters
Imports System.Web.HttpContext
Imports CkartrisEnumerations

Public Class OrdersBLL
    Public Enum ORDERS_LIST_CALLMODE
        RECENT
        UNFINISHED
        INVOICE
        DISPATCH
        COMPLETE
        PAYMENT
        GATEWAY
        AFFILIATE
        BYDATE
        BYBATCH
        CUSTOMER
        SEARCH
        CANCELLED
    End Enum

    Private Shared _Adptr As OrderstblAdptr = Nothing
    Private Shared _InvoiceRowsAdptr As InvoiceRowsTblAdptr = Nothing
    Private Shared _PaymentsAdptr As PaymentsTblAdptr = Nothing

#Region "Properties - Adapters"
    Protected Shared ReadOnly Property InvoiceRowsAdptr() As InvoiceRowsTblAdptr
        Get
            _InvoiceRowsAdptr = New InvoiceRowsTblAdptr
            Return _InvoiceRowsAdptr
        End Get
    End Property

    Protected Shared ReadOnly Property Adptr() As OrderstblAdptr
        Get
            _Adptr = New OrderstblAdptr
            Return _Adptr
        End Get
    End Property

    Protected Shared ReadOnly Property PaymentsAdptr() As PaymentsTblAdptr
        Get
            _PaymentsAdptr = New PaymentsTblAdptr
            Return _PaymentsAdptr
        End Get
    End Property
#End Region

#Region "Backend Methods"
    Public Shared Function _GetTileAppData(ByVal OrderSent As String, ByVal OrderInvoiced As String, ByVal OrderPaid As String,
                                      ByVal OrderShipped As String, ByVal OrderCancelled As String, ByVal DateRangeStart As Date,
                                      ByVal DateRangeEnd As Date, ByVal intRangeInMinutes As Integer) As DataTable
        Try

            ' Perform the update on the DataTable
            Return Adptr._GetTileAppData(OrderSent, OrderInvoiced, OrderPaid, OrderShipped, OrderCancelled,
                                  DateRangeStart, DateRangeEnd, intRangeInMinutes)
            ' If we reach here, no errors, so commit the transaction

        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            ' If we reach here, there was an error, so rollback the transaction
            Return Nothing
        End Try
    End Function

    Public Shared Sub _Delete(ByVal O_ID As Integer, ByVal blnReturnStock As Boolean)
        Try

            ' Perform the update on the DataTable
            Adptr._Delete(O_ID, blnReturnStock)
            ' If we reach here, no errors, so commit the transaction

        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            ' If we reach here, there was an error, so rollback the transaction
        End Try
    End Sub

    Public Shared Sub _PurgeOrders(ByVal O_PurgeDate As Date)
        Try

            ' Perform the update on the DataTable
            Dim tblToPurgeOrders As DataTable = Adptr._ToPurgeOrdersList(O_PurgeDate)
            For Each dr As DataRow In tblToPurgeOrders.Rows
                Adptr._Delete(dr.Item(0).ToString(), False)
            Next
            ' If we reach here, no errors, so commit the transaction
        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            ' If we reach here, there was an error, so rollback the transaction
        End Try
    End Sub
    ''' <summary>
    ''' 
    ''' </summary>
    ''' <returns>Returns the newly created order ID</returns>
    Public Shared Function _CloneAndCancel(ByVal O_ID As Integer, ByVal strOrderDetails As String, _
                                           ByVal BillingAddress As KartrisClasses.Address, ByVal ShippingAddress As KartrisClasses.Address, _
                                           ByVal blnSameShippingAsBilling As Boolean, _
                                            ByVal O_Sent As Boolean, ByVal O_Invoiced As Boolean, ByVal O_Paid As Boolean, ByVal O_Shipped As Boolean, _
                                          ByVal BasketObject As BasketBLL, ByVal BasketArray As ArrayList, _
                                           ByVal strShippingMethod As String, ByVal strNotes As String, _
                                          ByVal numGatewayTotalPrice As Double, ByVal O_PurchaseOrderNo As String, _
                                          ByVal strPromotionDescription As String, ByVal intCurrencyID As Integer, _
                                          ByVal blnOrderEmails As Boolean) As Integer
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisOrders_CloneAndCancel"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Log("Before Try")
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint


                Dim intNewOrderID As Integer = 0
                Dim objBasket As BasketBLL = BasketObject
                Dim arrBasketItems As ArrayList = BasketArray
                Dim strBillingAddressText As String, strShippingAddressText As String

                'Build the billing address string to be used in the order record
                With BillingAddress
                    strBillingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                          .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                          .County & vbCrLf & .Postcode & vbCrLf & _
                          .Country.Name & vbCrLf & .Phone
                End With

                'Build the shipping address string to be used in the order record
                If blnSameShippingAsBilling Then
                    strShippingAddressText = strBillingAddressText
                Else
                    With ShippingAddress
                        strShippingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                              .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                              .County & vbCrLf & .Postcode & vbCrLf & _
                              .Country.Name & vbCrLf & .Phone
                    End With
                End If

                Dim numTaxDue As Single
                If objBasket.ApplyTax Then numTaxDue = 1 Else numTaxDue = 0

                Dim numCurrencyRate As Double = CDbl(CurrenciesBLL.CurrencyRate(intCurrencyID))

                'Create the actual order record
                With cmd.Parameters
                    .AddWithValue("@O_ID", O_ID)
                    .AddWithValue("@O_Details", strOrderDetails)
                    .AddWithValue("@O_BillingAddress", strBillingAddressText)
                    .AddWithValue("@O_ShippingAddress", strShippingAddressText)
                    .AddWithValue("O_Sent", O_Sent)
                    .AddWithValue("O_Invoiced", O_Invoiced)
                    .AddWithValue("O_Paid", O_Paid)
                    .AddWithValue("O_Shipped", O_Shipped)
                    .AddWithValue("@O_ShippingPrice", objBasket.ShippingPrice.ExTax)
                    .AddWithValue("@O_ShippingTax", objBasket.ShippingPrice.TaxAmount)
                    .AddWithValue("@O_TotalPrice", objBasket.FinalPriceIncTax)
                    .AddWithValue("@O_LastModified", CkartrisDisplayFunctions.NowOffset)
                    .AddWithValue("@O_CouponCode", objBasket.CouponCode)
                    .AddWithValue("@O_CouponDiscountTotal", objBasket.CouponDiscount.IncTax)
                    .AddWithValue("@O_TaxDue", numTaxDue)
                    .AddWithValue("@O_TotalPriceGateway", numGatewayTotalPrice)
                    .AddWithValue("@O_OrderHandlingCharge", objBasket.OrderHandlingPrice.ExTax)
                    .AddWithValue("@O_OrderHandlingChargeTax", objBasket.OrderHandlingPrice.TaxAmount)
                    .AddWithValue("@O_ShippingMethod", strShippingMethod)
                    .AddWithValue("@O_Notes", strNotes)
                    .AddWithValue("@BackendUserID", HttpContext.Current.Session("_UserID"))
                    .AddWithValue("@O_PurchaseOrderNo", O_PurchaseOrderNo)
                    .AddWithValue("@O_PromotionDiscountTotal", objBasket.PromotionDiscount.IncTax)
                    .AddWithValue("@O_PromotionDescription", strPromotionDescription)
                    .AddWithValue("@O_AffiliateTotalPrice", objBasket.TotalValueToAffiliate)
                    .AddWithValue("@O_PricesIncTax", IIf(objBasket.PricesIncTax, 1, 0))
                    .AddWithValue("@O_SendOrderUpdateEmail", IIf(blnOrderEmails, 1, 0))
                    .AddWithValue("@O_CurrencyRate", numCurrencyRate)
                End With


                intNewOrderID = cmd.ExecuteScalar

                'Cycle through the basket items and add each as order invoice rows
                If Not (arrBasketItems Is Nothing) Then
                    Dim BasketItem As New BasketItem
                    For i As Integer = 0 To arrBasketItems.Count - 1
                        BasketItem = arrBasketItems(i)
                        With BasketItem
                            Dim cmdAddInvoiceRows As New SqlCommand("spKartrisOrders_InvoiceRowsAdd", sqlConn, savePoint)
                            cmdAddInvoiceRows.CommandType = CommandType.StoredProcedure


                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_OrderNumberID", intNewOrderID)
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_VersionCode", .VersionCode)
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_VersionName", IIf(.VersionName <> .ProductName Or _
                                                                                             InStr(.VersionName, .ProductName) = 0, _
                                                                                             .ProductName & " - " & .VersionName, .VersionName))
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_Quantity", .Quantity)
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_PricePerItem", .IR_PricePerItem)
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_TaxPerItem", .IR_TaxPerItem)

                            Dim sbdExtraText As New StringBuilder(.OptionText)
                            If Not String.IsNullOrEmpty(.CustomText) Then
                                If Not String.IsNullOrEmpty(.OptionText) Then sbdExtraText.Append("<br/>")
                                sbdExtraText.Append("[" & .CustomText & "]")
                            End If
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_OptionsText", sbdExtraText.ToString)

                            Dim strOutputValue As Integer = cmdAddInvoiceRows.ExecuteScalar
                            If strOutputValue = 0 Then Throw New Exception("Failed adding invoice row")
                        End With
                    Next
                End If


                If objBasket.PromotionDiscount.IncTax < 0 Then
                    Dim objPromotions As New ArrayList
                    Dim objPromotionsDiscount As New ArrayList
                    objBasket.CalculatePromotions(objPromotions, objPromotionsDiscount, False)
                    For Each objPromotion As PromotionBasketModifier In objPromotionsDiscount
                        Dim cmdAddPromotionLinks As New SqlCommand("spKartrisOrdersPromotions_Add", sqlConn, savePoint)
                        cmdAddPromotionLinks.CommandType = CommandType.StoredProcedure
                        cmdAddPromotionLinks.Parameters.AddWithValue("@OrderID", intNewOrderID)
                        cmdAddPromotionLinks.Parameters.AddWithValue("@PromotionID", objPromotion.PromotionID)
                        cmdAddPromotionLinks.ExecuteNonQuery()
                    Next
                End If

                ' If we reach here, no errors, so commit the transaction
                savePoint.Commit()
                sqlConn.Close()

                Return intNewOrderID
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                'Something went wrong, so rollback the order
                If Not savePoint Is Nothing Then savePoint.Rollback()
                Return 0
                Throw                'Bubble up the exception
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return 0
    End Function

    Public Shared Function GetOrderByID(ByVal O_ID As Long) As DataTable
        Return Adptr.GetData(O_ID)
    End Function

    Public Shared Function _GetParentOrderID(ByVal O_ID As Long) As Long
        Return Adptr._GetParentOrderID(O_ID)
    End Function
    Public Shared Function _GetChildOrderID(ByVal O_ID As Long) As Long
        Return Adptr._GetChildOrderID(O_ID)
    End Function
    Public Shared Function _GetByStatus(ByVal CallMode As ORDERS_LIST_CALLMODE, ByVal intPageNo As Integer, Optional ByVal AffiliateID As Integer = 0, Optional ByVal O_DateRangeStart As Date = Nothing, Optional ByVal O_DateRangeEnd As Date = Nothing, Optional ByVal strGateway As String = "", Optional ByVal strGatewayID As String = "", Optional ByVal Limit As Integer = 50) As DataTable
        'If date range start parameter is empty then use a valid date
        If O_DateRangeStart = Date.MinValue Then
            O_DateRangeStart = CkartrisDisplayFunctions.NowOffset.Date
        Else
            'Make sure that the date is passed with time so we're adding 1 second to the range start value
            O_DateRangeStart = O_DateRangeStart.Date.AddMilliseconds(-1)
        End If

        'Pass 12:59:59.59 PM of range end value
        If O_DateRangeEnd = Date.MinValue Then
            O_DateRangeEnd = O_DateRangeStart.AddDays(1).AddMinutes(-1)
        Else
            O_DateRangeEnd = O_DateRangeEnd.Date.AddDays(1).AddMinutes(-1)
        End If
        If CallMode = ORDERS_LIST_CALLMODE.CUSTOMER Then
            Try
                strGatewayID = CInt(strGatewayID)
            Catch ex As Exception
                strGatewayID = 0
            End Try
        End If

        Return Adptr._GetDataByStatus(System.Enum.GetName(GetType(ORDERS_LIST_CALLMODE), CallMode), AffiliateID, O_DateRangeStart, O_DateRangeEnd, strGateway, strGatewayID, intPageNo, Limit)
    End Function

    Public Shared Function _GetByStatusCount(ByVal CallMode As ORDERS_LIST_CALLMODE, Optional ByVal AffiliateID As Integer = 0, Optional ByVal O_DateRangeStart As Date = Nothing, Optional ByVal O_DateRangeEnd As Date = Nothing, Optional ByVal strGateway As String = "", Optional ByVal strGatewayID As String = "") As Integer
        'If date range start parameter is empty then use a valid date
        If O_DateRangeStart = Date.MinValue Then
            O_DateRangeStart = CkartrisDisplayFunctions.NowOffset.Date
        Else
            'Make sure that the date is passed with time so we're adding 1 second to the range start value
            O_DateRangeStart = O_DateRangeStart.Date.AddMilliseconds(-1)
        End If

        'Pass 12:59:59.59 PM of range end value
        If O_DateRangeEnd = Date.MinValue Then
            O_DateRangeEnd = O_DateRangeStart.AddDays(1).AddMinutes(-1)
        Else
            O_DateRangeEnd = O_DateRangeEnd.Date.AddDays(1).AddMinutes(-1)
        End If
        If CallMode = ORDERS_LIST_CALLMODE.CUSTOMER Then
            Try
                strGatewayID = CInt(strGatewayID)
            Catch ex As Exception
                strGatewayID = 0
            End Try
        End If

        Return Adptr._GetByStatusCount(System.Enum.GetName(GetType(ORDERS_LIST_CALLMODE), CallMode), AffiliateID, O_DateRangeStart, O_DateRangeEnd, strGateway, strGatewayID)
    End Function

    Public Shared Function _UpdateStatus(ByVal O_ID As Integer, ByVal O_Sent As Boolean, ByVal O_Paid As Boolean, ByVal O_Shipped As Boolean,
                                         ByVal O_Invoiced As Boolean, ByVal O_Status As String, ByVal O_Notes As String, ByVal O_Cancelled As Boolean) As Integer

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisOrders_UpdateStatus"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                ' Perform the update on the DataTable
                With cmd.Parameters
                    .AddWithValue("@O_ID", O_ID)
                    .AddWithValue("@O_LastModified", CkartrisDisplayFunctions.NowOffset)
                    .AddWithValue("@O_Sent", IIf(O_Sent, 1, 0))
                    .AddWithValue("@O_Invoiced", IIf(O_Invoiced, 1, 0))
                    .AddWithValue("@O_Shipped", IIf(O_Shipped, 1, 0))
                    .AddWithValue("@O_Paid", IIf(O_Paid, 1, 0))
                    .AddWithValue("@O_Cancelled", IIf(O_Cancelled, 1, 0))
                    .AddWithValue("@O_Status", O_Status)
                    .AddWithValue("@O_Notes", O_Notes)
                End With

                Dim returnValue As Integer = cmd.ExecuteScalar
                If returnValue <> O_ID Then
                    Throw New Exception("ID is 0? Something's not right")
                End If

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Orders, _
                 GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), _
                 CreateQuery(cmd), O_ID, sqlConn, savePoint)

                ' If we reach here, no errors, so commit the transaction
                savePoint.Commit()
                sqlConn.Close()

                Return returnValue
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                ' If we reach here, there was an error, so rollback the transaction
                savePoint.Rollback()
                Return 0
            End Try
        End Using
    End Function

    Public Shared Function _GetInvoiceRows(ByVal O_ID As Integer) As DataTable
        Return InvoiceRowsAdptr.GetInvoiceRows(O_ID)
    End Function
    Public Shared Function _GetOrderTotalByCustomerID(ByVal CustomerID As Integer) As Double
        Return Adptr._GetCustomerTotal(CustomerID)
    End Function
#Region "Payment"
    Public Shared Function _AddNewPayment(ByVal Payment_Date As Date, ByVal Payment_CustomerID As Integer, ByVal Payment_Amount As Double, ByVal Payment_CurrencyID As Integer,
                                                    ByVal Payment_Gateway As String, ByVal Payment_ReferenceCode As String, ByVal Payment_ExchangeRate As Double,
                                                    ByVal lcLinkedOrders As ListItemCollection) As Integer
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim intNewPaymentID As Integer
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisPayments_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                With cmd
                    .Transaction = savePoint
                    .Parameters.AddWithValue("@Payment_CustomerID", Payment_CustomerID)
                    .Parameters.AddWithValue("@Payment_Date", Payment_Date)
                    .Parameters.AddWithValue("@Payment_Amount", Payment_Amount)
                    .Parameters.AddWithValue("@Payment_CurrencyID", Payment_CurrencyID)
                    .Parameters.AddWithValue("@Payment_ReferenceNo", Payment_ReferenceCode)
                    .Parameters.AddWithValue("@Payment_Gateway", Payment_Gateway)
                    .Parameters.AddWithValue("@Payment_CurrencyRate", Payment_ExchangeRate)
                    intNewPaymentID = .ExecuteScalar
                End With


                If lcLinkedOrders.Count > 0 Then
                    For Each item As ListItem In lcLinkedOrders
                        Dim intOrderID As Integer = CInt(item.Value)
                        Dim cmdLinkedOrders As New SqlCommand("_spKartrisPayments_AddLinkedOrder", sqlConn, savePoint)
                        With cmdLinkedOrders
                            .CommandType = CommandType.StoredProcedure
                            .Transaction = savePoint
                            .Parameters.AddWithValue("@OP_PaymentID", intNewPaymentID)
                            .Parameters.AddWithValue("@OP_OrderID", intOrderID)
                            .Parameters.AddWithValue("@OP_OrderCanceled", 0)
                            .ExecuteNonQuery()
                        End With
                    Next
                End If

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Orders, _
               GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), _
               CreateQuery(cmd), intNewPaymentID, sqlConn, savePoint)

                ' If we reach here, no errors, so commit the transaction
                savePoint.Commit()
                sqlConn.Close()
                Return intNewPaymentID
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                'Something went wrong, so rollback the order
                If Not savePoint Is Nothing Then savePoint.Rollback()
                Return 0
                Throw                'Bubble up the exception
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Function
    Public Shared Function _UpdatePayment(ByVal Payment_ID As Integer, ByVal Payment_Date As Date, ByVal Payment_CustomerID As Integer, ByVal Payment_Amount As Double,
                                          ByVal Payment_CurrencyID As Integer, ByVal Payment_Gateway As String, ByVal Payment_ReferenceCode As String,
                                          ByVal Payment_ExchangeRate As Double, ByVal lcLinkedOrders As ListItemCollection) As Integer
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "_spKartrisPayments_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                With cmd
                    .Transaction = savePoint
                    .Parameters.AddWithValue("@Payment_ID", Payment_ID)
                    .Parameters.AddWithValue("@Payment_CustomerID", Payment_CustomerID)
                    .Parameters.AddWithValue("@Payment_Date", Payment_Date)
                    .Parameters.AddWithValue("@Payment_Amount", Payment_Amount)
                    .Parameters.AddWithValue("@Payment_CurrencyID", Payment_CurrencyID)
                    .Parameters.AddWithValue("@Payment_ReferenceNo", Payment_ReferenceCode)
                    .Parameters.AddWithValue("@Payment_Gateway", Payment_Gateway)
                    .Parameters.AddWithValue("@Payment_CurrencyRate", Payment_ExchangeRate)
                    .ExecuteNonQuery()
                End With

                Dim cmdDeleteExistingLinkedOrders As New SqlCommand("_spKartrisPayments_DeleteLinkedOrders", sqlConn, savePoint)
                With cmdDeleteExistingLinkedOrders
                    .CommandType = CommandType.StoredProcedure
                    .Transaction = savePoint
                    .Parameters.AddWithValue("@OP_PaymentID", Payment_ID)
                    .ExecuteNonQuery()
                End With

                If lcLinkedOrders.Count > 0 Then
                    For Each item As ListItem In lcLinkedOrders
                        Dim intOrderID As Integer = CInt(item.Value)
                        Dim cmdLinkedOrders As New SqlCommand("_spKartrisPayments_AddLinkedOrder", sqlConn, savePoint)
                        With cmdLinkedOrders
                            .CommandType = CommandType.StoredProcedure
                            .Transaction = savePoint
                            .Parameters.AddWithValue("@OP_PaymentID", Payment_ID)
                            .Parameters.AddWithValue("@OP_OrderID", intOrderID)
                            .Parameters.AddWithValue("@OP_OrderCanceled", 0)
                            .ExecuteNonQuery()
                        End With
                    Next
                End If

                KartrisDBBLL._AddAdminLog(HttpContext.Current.Session("_User"), ADMIN_LOG_TABLE.Orders, _
               GetGlobalResourceObject("_Kartris", "ContentText_OperationCompletedSuccessfully"), _
               CreateQuery(cmd), Payment_ID, sqlConn, savePoint)

                ' If we reach here, no errors, so commit the transaction
                savePoint.Commit()
                sqlConn.Close()
                Return Payment_ID
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                'Something went wrong, so rollback the order
                If Not savePoint Is Nothing Then savePoint.Rollback()
                Return 0
                Throw                'Bubble up the exception
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Function
    Public Shared Function _GetPaymentByCustomerID(ByVal CustomerID As Integer) As DataTable
        Return PaymentsAdptr._GetByCustomerID(CustomerID)
    End Function
    Public Shared Function _GetPaymentByID(ByVal PaymentID As Long) As DataTable
        Return PaymentsAdptr._Get(PaymentID)
    End Function
    Public Shared Function _DeletePayment(ByVal PaymentID As Long) As Integer
        Return PaymentsAdptr._Delete(PaymentID)
    End Function
    Public Shared Function _GetPaymentLinkedOrders(ByVal PaymentID As Long) As DataTable
        Return PaymentsAdptr._GetLinkedOrders(PaymentID)
    End Function
    Public Shared Function _GetPaymentsFilteredList(ByVal Payment_FilterType As String, ByVal Payment_Gateway As String, ByVal Payment_Date As Date,
                                                    ByVal intPageNo As Integer, ByVal Limit As Integer) As DataTable
        If Payment_Date = Date.MinValue Then Payment_Date = Date.Today
        Return PaymentsAdptr._GetFilteredList(Payment_FilterType, Payment_Gateway, Payment_Date, intPageNo, Limit)
    End Function
    Public Shared Function _GetPaymentsFilteredListCount(ByVal Payment_FilterType As String, ByVal Payment_Gateway As String, ByVal Payment_Date As Date) As Integer
        If Payment_Date = Date.MinValue Then Payment_Date = Date.Today
        Return PaymentsAdptr._GetFilteredListCount(Payment_FilterType, Payment_Gateway, Payment_Date)
    End Function
    Public Shared Function _GetPaymentTotalByCustomerID(ByVal CustomerID As Integer) As Double
        Return PaymentsAdptr._GetCustomerTotal(CustomerID)
    End Function
#End Region

#End Region

#Region "Frontend Methods"

    Private Shared Sub Log(ByVal strText As String)
    End Sub

    ''' <summary>
    ''' ADD ORDER - Used by the checkout page to process an order before redirecting to the payment gateway.
    ''' Steps involve creating a user account if we have a first time customer, adding of new billing and shipping addresses 
    ''' and the creation of the actual order record. All are done in a single transaction so if any of these steps fail, everything 
    ''' can be rolled back.
    ''' </summary>
    ''' <returns>Returns the newly created order ID</returns>
    Public Shared Function Add(ByVal C_ID As Integer, ByVal strUserEmailAddress As String, ByVal strUserPassword As String, _
              ByVal BillingAddress As KartrisClasses.Address, ByVal ShippingAddress As KartrisClasses.Address, _
              ByVal blnSameShippingAsBilling As Boolean, ByVal BasketObject As BasketBLL, ByVal BasketArray As ArrayList, _
              ByVal strOrderDetails As String, ByVal strGatewayName As String, _
              ByVal intLanguageID As Integer, ByVal intCurrencyID As Integer, ByVal intGatewayCurrencyID As Integer, _
              ByVal blnOrderEmails As Boolean, ByVal strShippingMethod As String, ByVal numGatewayTotalPrice As Double, _
              ByVal strEUVATNumber As String, ByVal strPromotionDescription As String, ByVal strPurchaseOrderNo As String, ByVal strComments As String) As Integer
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "spKartrisOrders_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Log("Before Try")
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint

                Dim O_ID As Integer = 0
                Dim blnNewUser As Boolean
                Dim strBillingAddressText As String = "", strShippingAddressText As String = ""

                Dim objBasket As BasketBLL = BasketObject
                Dim arrBasketItems As ArrayList = BasketArray

                'if C_ID has a value then we have a legitimate user - proceed with the order transaction
                If C_ID = 0 Then
                    'Add a new User record
                    Dim strRandomSalt As String = Membership.GeneratePassword(20, 0)
                    Dim cmdAddOrderUser As New SqlCommand("spKartrisUsers_Add", sqlConn, savePoint)
                    cmdAddOrderUser.CommandType = CommandType.StoredProcedure
                    cmdAddOrderUser.Parameters.AddWithValue("@U_EmailAddress", strUserEmailAddress)
                    cmdAddOrderUser.Parameters.AddWithValue("@U_Password", UsersBLL.EncryptSHA256Managed(strUserPassword, strRandomSalt))
                    cmdAddOrderUser.Parameters.AddWithValue("@U_SaltValue", strRandomSalt)

                    C_ID = cmdAddOrderUser.ExecuteScalar
                    blnNewUser = True
                End If

                If C_ID > 0 Then
                    Dim strFullName As String = ""
                    If BillingAddress IsNot Nothing Then strFullName = BillingAddress.FullName
                    If Not (String.IsNullOrEmpty(strEUVATNumber) AndAlso String.IsNullOrEmpty(strFullName)) Then
                        Dim cmdUpdateUserNameandEUVAT As New SqlCommand("spKartrisUsers_UpdateNameAndEUVAT", sqlConn, savePoint)
                        cmdUpdateUserNameandEUVAT.CommandType = CommandType.StoredProcedure
                        cmdUpdateUserNameandEUVAT.Parameters.AddWithValue("@U_ID", C_ID)
                        cmdUpdateUserNameandEUVAT.Parameters.AddWithValue("@U_AccountHolderName", strFullName)
                        cmdUpdateUserNameandEUVAT.Parameters.AddWithValue("@U_CardholderEUVATNum", strEUVATNumber)
                        cmdUpdateUserNameandEUVAT.ExecuteNonQuery()
                    End If
                End If

                'Add a new billing address - if a new one is entered
                If BillingAddress IsNot Nothing Then
                    If BillingAddress.ID = 0 Then
                        With BillingAddress
                            Dim cmdAddUpdateOrderAddress As New SqlCommand("spKartrisUsers_AddUpdateAddress", sqlConn, savePoint)
                            cmdAddUpdateOrderAddress.CommandType = CommandType.StoredProcedure
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_UserID", C_ID)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Label", .Label)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Name", .FullName)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Company", .Company)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_StreetAddress", .StreetAddress)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_TownCity", .TownCity)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_County", .County)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_PostCode", .Postcode)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Country", .CountryID)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Telephone", .Phone)
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Type", IIf(blnSameShippingAsBilling, "u", "b"))
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_MakeDefault", IIf(blnNewUser, 1, 0))
                            cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_ID", 0)

                            cmdAddUpdateOrderAddress.ExecuteNonQuery()
                        End With
                    End If
                End If

                'Add a new shipping address - if a new one is entered
                If Not blnSameShippingAsBilling Then
                    If ShippingAddress IsNot Nothing Then
                        If ShippingAddress.ID = 0 Then
                            With ShippingAddress
                                Dim cmdAddUpdateOrderAddress As New SqlCommand("spKartrisUsers_AddUpdateAddress", sqlConn, savePoint)
                                cmdAddUpdateOrderAddress.CommandType = CommandType.StoredProcedure
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_UserID", C_ID)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Label", .Label)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Name", .FullName)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Company", .Company)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_StreetAddress", .StreetAddress)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_TownCity", .TownCity)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_County", .County)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_PostCode", .Postcode)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Country", .CountryID)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Telephone", .Phone)
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_Type", "s")
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_MakeDefault", IIf(blnNewUser, 1, 0))
                                cmdAddUpdateOrderAddress.Parameters.AddWithValue("@ADR_ID", 0)

                                cmdAddUpdateOrderAddress.ExecuteNonQuery()
                            End With
                        End If
                    End If
                End If

                'Build the billing address string to be used in the order record
                If BillingAddress IsNot Nothing Then
                    With BillingAddress
                        strBillingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                              .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                              .County & vbCrLf & .Postcode & vbCrLf & _
                              .Country.Name & vbCrLf & .Phone
                    End With
                End If

                'Build the shipping address string to be used in the order record
                If blnSameShippingAsBilling Then
                    strShippingAddressText = strBillingAddressText
                Else
                    If ShippingAddress IsNot Nothing Then
                        With ShippingAddress
                            strShippingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                                  .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                                  .County & vbCrLf & .Postcode & vbCrLf & _
                                  .Country.Name & vbCrLf & .Phone
                        End With
                    End If
                End If

                ''// get affiliate id from session variable and compare it to user current affiliate id
                '' update user affiliate id only if differ
                Dim intAffiliateID As Integer = 0
                Dim numAffiliatePercentage As Double = 0
                If HttpContext.Current.Session("C_AffiliateID") IsNot Nothing Then
                    intAffiliateID = CInt(HttpContext.Current.Session("C_AffiliateID"))
                    If intAffiliateID > 0 Then
                        If objBasket.IsCustomerAffiliate(intAffiliateID) Then
                            Dim cmdUpdateAffiliate As New SqlCommand("spKartrisCustomer_UpdateAffiliate", sqlConn, savePoint)
                            cmdUpdateAffiliate.CommandType = CommandType.StoredProcedure
                            With cmdUpdateAffiliate.Parameters
                                .AddWithValue("@Type", 3)
                                .AddWithValue("@UserID", C_ID)
                                .AddWithValue("@AffiliateCommission", 0)
                                .AddWithValue("@AffiliateID", intAffiliateID)
                            End With
                            cmdUpdateAffiliate.ExecuteNonQuery()
                            numAffiliatePercentage = CDbl(Adptr.GetAffiliateCommission(intAffiliateID))
                        End If
                    End If
                End If

                Dim numCurrencyRate As Double = CDbl(CurrenciesBLL.CurrencyRate(intCurrencyID))

                Dim intWishlistID As Integer = 0
                If HttpContext.Current.Session("WL_ID") IsNot Nothing Then intWishlistID = HttpContext.Current.Session("WL_ID")

                Dim numTaxDue As Single
                If objBasket.ApplyTax Then numTaxDue = 1 Else numTaxDue = 0
                'Create the actual order record
                With cmd.Parameters
                    .AddWithValue("@O_CustomerID", C_ID)
                    .AddWithValue("@O_Details", strOrderDetails)
                    .AddWithValue("@O_ShippingPrice", objBasket.ShippingPrice.ExTax)
                    .AddWithValue("@O_ShippingTax", objBasket.ShippingPrice.TaxAmount)
                    .AddWithValue("@O_DiscountPercentage", objBasket.CustomerDiscountPercentage)
                    .AddWithValue("@O_AffiliatePercentage", numAffiliatePercentage)
                    .AddWithValue("@O_TotalPrice", objBasket.FinalPriceIncTax)
                    .AddWithValue("@O_Date", CkartrisDisplayFunctions.NowOffset)
                    .AddWithValue("@O_PurchaseOrderNo", IIf(Trim(strPurchaseOrderNo) <> "", strPurchaseOrderNo, ""))
                    .AddWithValue("@O_SecurityID", 0)
                    .AddWithValue("@O_Sent", 0)
                    .AddWithValue("@O_Invoiced", 0)
                    .AddWithValue("@O_Shipped", 0)
                    .AddWithValue("@O_Paid", 0)
                    .AddWithValue("@O_Status", Payment.Serialize(objBasket))
                    .AddWithValue("@O_LastModified", CkartrisDisplayFunctions.NowOffset)
                    .AddWithValue("@O_WishListID", intWishlistID)
                    .AddWithValue("@O_CouponCode", objBasket.CouponCode)
                    .AddWithValue("@O_CouponDiscountTotal", objBasket.CouponDiscount.IncTax)
                    .AddWithValue("@O_PricesIncTax", IIf(objBasket.PricesIncTax, 1, 0))
                    .AddWithValue("@O_TaxDue", numTaxDue)
                    .AddWithValue("@O_PaymentGateWay", strGatewayName)
                    .AddWithValue("@O_ReferenceCode", "")
                    .AddWithValue("@O_LanguageID", intLanguageID)
                    .AddWithValue("@O_CurrencyID", intCurrencyID)
                    .AddWithValue("@O_TotalPriceGateway", numGatewayTotalPrice)
                    .AddWithValue("@O_CurrencyIDGateway", intGatewayCurrencyID)
                    .AddWithValue("@O_AffiliatePaymentID", 0)
                    .AddWithValue("@O_AffiliateTotalPrice", objBasket.TotalValueToAffiliate)
                    .AddWithValue("@O_SendOrderUpdateEmail", IIf(blnOrderEmails, 1, 0))
                    .AddWithValue("@O_OrderHandlingCharge", objBasket.OrderHandlingPrice.ExTax)
                    .AddWithValue("@O_OrderHandlingChargeTax", objBasket.OrderHandlingPrice.TaxAmount)
                    .AddWithValue("@O_CurrencyRate", numCurrencyRate)
                    .AddWithValue("@O_ShippingMethod", strShippingMethod)
                    .AddWithValue("@O_BillingAddress", strBillingAddressText)
                    .AddWithValue("@O_ShippingAddress", strShippingAddressText)
                    .AddWithValue("@O_PromotionDiscountTotal", objBasket.PromotionDiscount.IncTax)
                    .AddWithValue("@O_PromotionDescription", strPromotionDescription)
                    .AddWithValue("@O_Comments", IIf(Trim(strComments) <> "", strComments, ""))
                End With
                O_ID = cmd.ExecuteScalar

                'Cycle through the basket items and add each as order invoice rows
                If Not (arrBasketItems Is Nothing) Then
                    Dim BasketItem As New BasketItem
                    For i As Integer = 0 To arrBasketItems.Count - 1
                        BasketItem = arrBasketItems(i)
                        With BasketItem
                            Dim cmdAddInvoiceRows As New SqlCommand("spKartrisOrders_InvoiceRowsAdd", sqlConn, savePoint)
                            cmdAddInvoiceRows.CommandType = CommandType.StoredProcedure


                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_OrderNumberID", O_ID)
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_VersionCode", .VersionCode)
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_VersionName", IIf(.VersionName <> .ProductName Or _
                                                                                             InStr(.VersionName, .ProductName) = 0, _
                                                                                             .ProductName & " - " & .VersionName, .VersionName))
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_Quantity", CSng(.Quantity))
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_PricePerItem", .IR_PricePerItem)
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_TaxPerItem", .IR_TaxPerItem)

                            Dim sbdExtraText As New StringBuilder(.OptionText)
                            If Not String.IsNullOrEmpty(.CustomText) Then
                                If Not String.IsNullOrEmpty(.OptionText) Then sbdExtraText.Append("<br/>")
                                sbdExtraText.Append("[" & .CustomText & "]")
                            End If
                            cmdAddInvoiceRows.Parameters.AddWithValue("@IR_OptionsText", sbdExtraText.ToString)

                            Dim strOutputValue As Integer = cmdAddInvoiceRows.ExecuteScalar
                            If strOutputValue = 0 Then Throw New Exception("Failed adding invoice row")
                        End With
                    Next
                End If


                If objBasket.PromotionDiscount.IncTax < 0 Then
                    Dim objPromotions As New ArrayList
                    Dim objPromotionsDiscount As New ArrayList
                    objBasket.CalculatePromotions(objPromotions, objPromotionsDiscount, False)
                    For Each objPromotion As PromotionBasketModifier In objPromotionsDiscount
                        Dim cmdAddPromotionLinks As New SqlCommand("spKartrisOrdersPromotions_Add", sqlConn, savePoint)
                        With cmdAddPromotionLinks
                            .CommandType = CommandType.StoredProcedure
                            .Parameters.AddWithValue("@OrderID", O_ID)
                            .Parameters.AddWithValue("@PromotionID", objPromotion.PromotionID)
                            .ExecuteNonQuery()
                        End With
                    Next
                End If

                ' If we reach here, no errors, so commit the transaction
                savePoint.Commit()
                sqlConn.Close()
                If blnNewUser Then
                    If Membership.ValidateUser(strUserEmailAddress, strUserPassword) Then
                        FormsAuthentication.SetAuthCookie(strUserEmailAddress, True)
                    End If
                End If


                Return O_ID
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                'Something went wrong, so rollback the order
                If Not savePoint Is Nothing Then savePoint.Rollback()
                Return 0
                Throw                'Bubble up the exception
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return 0
    End Function

    ''' <summary>
    ''' This is the method used by the callback (callback.aspx) page to update a successful order.
    ''' </summary>
    Public Shared Function CallbackUpdate(ByVal O_ID As Long, ByVal O_ReferenceCode As String, ByVal O_LastModified As Date, _
                                          ByVal O_Sent As Boolean, ByVal O_Invoiced As Boolean, ByVal O_Paid As Boolean, _
                                          ByVal O_Status As String, ByVal O_CouponCode As String, ByVal O_WLID As Integer, _
                                          ByVal O_CustomerID As Integer, ByVal GatewayCurrencyID As Short, _
                                          ByVal O_GatewayName As String, ByVal O_Amount As Double) As Integer

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "spKartrisOrders_CallbackUpdate"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                ' Perform the update on the DataTable
                With cmd.Parameters
                    .AddWithValue("@O_ID", O_ID)
                    .AddWithValue("@O_ReferenceCode", O_ReferenceCode)
                    .AddWithValue("@O_LastModified", O_LastModified)
                    .AddWithValue("@O_Sent", IIf(O_Sent, 1, 0))
                    .AddWithValue("@O_Invoiced", IIf(O_Invoiced, 1, 0))
                    .AddWithValue("@O_Paid", IIf(O_Paid, 1, 0))
                    .AddWithValue("@O_Status", O_Status)
                    .AddWithValue("@O_WLID", O_WLID)
                End With


                Dim returnValue As Integer = cmd.ExecuteScalar
                If returnValue <> O_ID Then
                    Throw New Exception("ID is 0? Something's not right")
                End If
                If Not String.IsNullOrEmpty(O_CouponCode) Then
                    Dim cmdRecordOrderCoupon As New SqlCommand("spKartrisOrders_CouponUsed", sqlConn, savePoint)
                    cmdRecordOrderCoupon.CommandType = CommandType.StoredProcedure
                    cmdRecordOrderCoupon.Parameters.AddWithValue("@CouponCode", O_CouponCode)
                    cmdRecordOrderCoupon.ExecuteNonQuery()
                End If

                'If CustomerID is supplied then that means that the call is coming from the callback page and we need to add a new payment record
                If O_CustomerID > 0 Then
                    Dim cmdAddPayment As New SqlCommand("spKartrisPayments_Add", sqlConn, savePoint)
                    cmdAddPayment.CommandType = CommandType.StoredProcedure
                    With cmdAddPayment.Parameters
                        .AddWithValue("@Payment_CustomerID", O_CustomerID)
                        .AddWithValue("@Payment_CurrencyID", GatewayCurrencyID)
                        .AddWithValue("@Payment_ReferenceNo", O_ReferenceCode)
                        .AddWithValue("@Payment_Date", O_LastModified)
                        .AddWithValue("@Payment_Amount", O_Amount)
                        .AddWithValue("@Payment_Gateway", O_GatewayName)
                        .AddWithValue("@Payment_CurrencyRate", CurrenciesBLL.CurrencyRate(GatewayCurrencyID))
                    End With
                    returnValue = cmdAddPayment.ExecuteScalar
                    If returnValue = 0 Then
                        Throw New Exception("PaymentID is 0? Something's not right")
                    End If

                    Dim cmdOrderPaymentsLink As New SqlCommand("spKartrisOrderPaymentsLink_Add", sqlConn, savePoint)
                    cmdOrderPaymentsLink.CommandType = CommandType.StoredProcedure
                    cmdOrderPaymentsLink.Parameters.AddWithValue("@OP_PaymentID", returnValue)
                    cmdOrderPaymentsLink.Parameters.AddWithValue("@OP_OrderID", O_ID)
                    cmdOrderPaymentsLink.ExecuteNonQuery()
                End If

                ' If we reach here, no errors, so commit the transaction
                savePoint.Commit()
                sqlConn.Close()

                'Try to update customer balance before returning value
                Try
                    UsersBLL.UpdateCustomerBalance(O_CustomerID, _
                                CDec(_GetPaymentTotalByCustomerID(O_CustomerID) - _GetOrderTotalByCustomerID(O_CustomerID)))
                Catch ex As Exception

                End Try

                Return returnValue
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                ' If we reach here, there was an error, so rollback the transaction
                savePoint.Rollback()
                Return 0
            End Try
        End Using

    End Function
    ''' <summary>
    ''' This method is used to update an order's data field before passing the customer to the payment gateway
    ''' </summary>
    Public Shared Function DataUpdate(ByVal O_ID As Long, ByVal O_Data As String) As Integer
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmd As SqlCommand = sqlConn.CreateCommand
            cmd.CommandText = "spKartrisOrders_DataUpdate"
            Dim savePoint As SqlTransaction = Nothing
            cmd.CommandType = CommandType.StoredProcedure
            Try
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmd.Transaction = savePoint
                ' Perform the update on the DataTable
                cmd.Parameters.AddWithValue("@O_ID", O_ID)
                cmd.Parameters.AddWithValue("@O_Data", O_Data)

                Dim returnValue As Integer = cmd.ExecuteScalar
                If returnValue <> O_ID Then
                    Throw New Exception("ID is 0? Something's not right")
                End If

                ' If we reach here, no errors, so commit the transaction
                savePoint.Commit()
                sqlConn.Close()

                Return returnValue
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                ' If we reach here, there was an error, so rollback the transaction
                savePoint.Rollback()
                Return 0
            End Try
        End Using
    End Function



    ''' <summary>
    ''' This is the method used by other payment gateways to update an order through its reference code.
    ''' </summary>
    Public Shared Function UpdateByReferenceCode(ByVal O_ReferenceCode As String, ByVal O_LastModified As Date, _
                                          ByVal O_Sent As Boolean, ByVal O_Invoiced As Boolean, ByVal O_Paid As Boolean, _
                                          ByVal O_Status As String) As Integer
        Try

            ' Perform the update on the DataTable
            Dim returnValue As Integer = Adptr.UpdateByReferenceCode(O_ReferenceCode, O_LastModified, O_Sent, O_Invoiced, O_Paid, O_Status)
            If returnValue <> O_ReferenceCode Then
                Throw New Exception("The returned reference code doesn't match? Something's not right")
            End If
            ' If we reach here, no errors, so commit the transaction
            Return returnValue


        Catch ex As Exception
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            ' If we reach here, there was an error, so rollback the transaction
            Return 0
        End Try

    End Function

    Public Shared Function GetQBQueue() As DataTable
        Return Adptr.GetQBQueue
    End Function

    Public Shared Function UpdateQBSent(ByVal intOrderID As Integer) As Integer
        Return Adptr.UpdateQBSent(intOrderID)
    End Function

    Public Shared Function GetCardTypeList() As DataTable
        Dim CardTypesAdptr As CardTypesTblAdptr = New CardTypesTblAdptr
        Dim dtCardType As DataTable = CardTypesAdptr.GetCardTypeList
        CardTypesAdptr = Nothing
        Return dtCardType
    End Function
#End Region

End Class