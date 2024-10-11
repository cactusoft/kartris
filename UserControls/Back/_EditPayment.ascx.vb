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
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports CkartrisEnumerations
Imports KartSettingsManager
Imports KartrisClasses

Partial Class UserControls_Back_EditPayment

    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            Dim objOrdersBLL As New OrdersBLL
            Dim objUsersBLL As New UsersBLL

            ViewState("Referer") = Request.ServerVariables("HTTP_REFERER")


            'Payment gateways
            Dim strPaymentMethods As String = GetKartConfig("frontend.payment.gatewayslist")
            Dim arrPaymentsMethods As String() = Split(strPaymentMethods, ",")
            Try
                ddlPaymentGateways.Items.Add(New ListItem(GetGlobalResourceObject("Kartris", "ContentText_DropdownSelectDefault"), ""))
                For Each strGatewayEntry As String In arrPaymentsMethods
                    Dim arrGateway As String() = Split(strGatewayEntry, "::")
                    If UBound(arrGateway) = 4 Then
                        Dim blnOkToAdd As Boolean = True
                        If arrGateway(4) = "p" Then
                            If LCase(arrGateway(1)) = "test" Then
                                blnOkToAdd = HttpSecureCookie.IsBackendAuthenticated
                            ElseIf LCase(arrGateway(1)) = "off" Then
                                blnOkToAdd = False
                            End If
                        Else
                            blnOkToAdd = False
                        End If
                        If blnOkToAdd Then
                            Dim strGatewayName As String = arrGateway(0)
                            If strGatewayName.ToLower = "po_offlinepayment" Then
                                strGatewayName = GetGlobalResourceObject("Checkout", "ContentText_Po")
                            End If
                            ddlPaymentGateways.Items.Add(New ListItem(strGatewayName, arrGateway(0).ToString))
                        End If
                    Else
                        Throw New Exception("Invalid gatewaylist config setting!")
                    End If

                Next

            Catch ex As Exception
                Throw New Exception("Error loading payment gateway list")
            End Try

            If ddlPaymentGateways.Items.Count = 1 Then
                Throw New Exception("No valid payment gateways")
            End If

            Try
                Dim tblCurrenceis As DataTable = KartSettingsManager.GetCurrenciesFromCache() 'CurrenciesBLL.GetCurrencies()
                Dim drwLiveCurrencies As DataRow() = tblCurrenceis.Select("CUR_Live = 1")
                If drwLiveCurrencies.Length > 0 Then
                    ddlPaymentCurrency.Items.Clear()
                    For i As Byte = 0 To drwLiveCurrencies.Length - 1
                        ddlPaymentCurrency.Items.Add(New ListItem(drwLiveCurrencies(i)("CUR_Symbol") & " " & drwLiveCurrencies(i)("CUR_ISOCode"), drwLiveCurrencies(i)("CUR_ID")))
                    Next
                End If
                ddlPaymentCurrency.SelectedIndex = ddlPaymentCurrency.Items.IndexOf(ddlPaymentCurrency.Items.FindByValue(Session("CUR_ID")))
            Catch ex As Exception
                Throw New Exception("Error loading currency list")
            End Try
            If String.IsNullOrEmpty(Request.QueryString("PaymentID")) Then
                calDate.SelectedDate = CkartrisDisplayFunctions.NowOffset
                lnkBtnDelete.Visible = False
                SetPaymentCurrency(ddlPaymentCurrency.SelectedValue)
                litPaymentID.Visible = False
                lblPaymentID.Visible = False
                SetPaymentCustomer(0)
                If Not IsPostBack Then
                    Try
                        Dim intOrderID As Long = CType(Request.QueryString("OrderID"), Integer)
                        Dim intCustomerID As Long = CType(Request.QueryString("CustomerID"), Integer)
                        'automatically add the order in the linked orders list if OrderID QS is passed
                        If intOrderID > 0 Then
                            lbxOrders.Items.Add(intOrderID)
                        End If
                        'add fill up the customer email if the CustomerID QS passed is valid
                        If intCustomerID > 0 Then
                            Dim strCustomerEmail As String = objUsersBLL.GetEmailByID(intCustomerID)
                            If Not String.IsNullOrEmpty(strCustomerEmail) Then SetPaymentCustomer(strCustomerEmail)
                        End If
                    Catch ex As Exception

                    End Try
                End If
            Else
                Dim lngPaymentID As Long = CLng(Request.QueryString("PaymentID"))
                Dim tblPayment As New DataTable
                tblPayment = objOrdersBLL._GetPaymentByID(lngPaymentID)
                If tblPayment.Rows.Count > 0 Then
                    Dim intCurrencyID As Integer = CInt(FixNullFromDB(tblPayment.Rows(0)("Payment_CurrencyID")))
                    Dim lngCustomerID As Long = CLng(FixNullFromDB(tblPayment.Rows(0)("Payment_CustomerID")))

                    litPaymentID.Visible = True
                    lblPaymentID.Visible = True
                    litPaymentID.Text = lngPaymentID

                    txtPaymentDate.Text = FormatDate(FixNullFromDB(tblPayment.Rows(0)("Payment_Date")), "d", Session("_LANG"))

                    SetPaymentCustomer(objUsersBLL.GetEmailByID(lngCustomerID))
                    SetPaymentCurrency(intCurrencyID)
                    txtPaymentAmount.Text = FixNullFromDB(tblPayment.Rows(0)("Payment_Amount"))
                    txtPaymentReferenceCode.Text = FixNullFromDB(tblPayment.Rows(0)("Payment_ReferenceNo"))
                    SetPaymentGateway(FixNullFromDB(tblPayment.Rows(0)("Payment_Gateway")))

                    Dim tblLinkedOrders As New DataTable
                    tblLinkedOrders = objOrdersBLL._GetPaymentLinkedOrders(lngPaymentID)
                    If tblLinkedOrders.Rows.Count > 0 Then
                        lbxOrders.Items.Clear()
                        For Each drwOrder As DataRow In tblLinkedOrders.Rows
                            Dim lngOrderID As Long = CLng(FixNullFromDB(drwOrder("OP_OrderID")))
                            Dim blnOrderCancelled As Boolean = CBool(FixNullFromDB(drwOrder("OP_OrderCanceled")))
                            Dim dblOrderTotalPrice As Double = CDbl(FixNullFromDB(drwOrder("O_TotalPrice")))
                            Dim intOrderCurrencyID As Integer = CInt(FixNullFromDB(drwOrder("O_CurrencyID")))

                            Dim strOrderText As String = lngOrderID & vbTab & " (" & CurrenciesBLL.FormatCurrencyPrice(intOrderCurrencyID, dblOrderTotalPrice) & ")"

                            If lbxOrders.Items.FindByValue(CStr(lngOrderID)) Is Nothing Then
                                lbxOrders.Items.Add(New ListItem(strOrderText, CStr(lngOrderID)))
                                lbxOrders.SelectedIndex = lbxOrders.Items.Count - 1
                            End If
                        Next
                        txtOrderID.Text = ""
                    End If
                    tblLinkedOrders = Nothing
                Else
                    Response.Redirect("_PaymentsList.aspx")
                End If
            End If

        End If
    End Sub

    ''' <summary>
    ''' Handles change of currency
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub ddlCurrency_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlPaymentCurrency.SelectedIndexChanged
        SetPaymentCurrency(ddlPaymentCurrency.SelectedValue)
    End Sub

    ''' <summary>
    ''' adds the order id to the orders' list
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub lnkBtnAddOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnAddOrder.Click
        Try
            Dim strOrderID As String = txtOrderID.Text
            If IsNumeric(strOrderID) Then

                Dim numOrderID As Long = CLng(strOrderID)
                Dim tblOrder As New DataTable
                Dim objOrdersBLL As New OrdersBLL
                Dim objUsersBLL As New UsersBLL

                tblOrder = objOrdersBLL.GetOrderByID(numOrderID)

                If tblOrder.Rows.Count > 0 Then

                    Dim lngCustomerID As Long = FixNullFromDB(tblOrder.Rows(0)("O_CustomerID"))
                    Dim intCurrencyID As Integer = FixNullFromDB(tblOrder.Rows(0)("O_CurrencyID"))


                    If SetPaymentCustomer(objUsersBLL.GetEmailByID(lngCustomerID)) = 0 Then
                        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
                    End If

                    SetPaymentCurrency(intCurrencyID)

                    SetPaymentGateway(FixNullFromDB(tblOrder.Rows(0)("O_PaymentGateway")))

                    txtPaymentAmount.Text = FixNullFromDB(tblOrder.Rows(0)("O_TotalPrice"))

                    Dim strOrderText As String = numOrderID & vbTab & " (" & CurrenciesBLL.FormatCurrencyPrice(intCurrencyID, txtPaymentAmount.Text) & ")"

                    If lbxOrders.Items.FindByValue(CStr(numOrderID)) Is Nothing Then
                        lbxOrders.Items.Add(New ListItem(strOrderText, CStr(numOrderID)))
                        lbxOrders.SelectedIndex = lbxOrders.Items.Count - 1
                    End If
                    tblOrder = Nothing
                    txtOrderID.Text = ""
                    txtOrderID.Focus()
                    updPaymentDetails.Update()
                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
                End If
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
            End If
        Catch ex As Exception
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
        End Try

    End Sub

    ''' <summary>
    ''' removes the selected order from the orders' list
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub lnkBtnRemoveOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnRemoveOrder.Click
        Dim selectedIndx As Integer = lbxOrders.SelectedIndex
        If selectedIndx >= 0 Then
            lbxOrders.Items.RemoveAt(selectedIndx)
            If lbxOrders.Items.Count >= selectedIndx Then
                lbxOrders.SelectedIndex = selectedIndx - 1
            Else
                If lbxOrders.Items.Count <> 0 Then
                    lbxOrders.SelectedIndex = lbxOrders.Items.Count - 1
                End If
            End If
        End If
    End Sub

    Function SetPaymentCustomer(ByVal strCustomerEmail As String) As Long
        Dim objUsersBLL As New UsersBLL
        Dim tblCustomer As New DataTable
        tblCustomer = objUsersBLL.GetDetails(strCustomerEmail)
        If tblCustomer.Rows.Count > 0 Then
            Dim lngCustomerID As Long = CLng(FixNullFromDB(tblCustomer.Rows(0)("U_ID")))
            txtPaymentCustomerEmail.Text = strCustomerEmail
            litPaymentCustomerID.Text = lngCustomerID
            litPaymentCustomerName.Text = FixNullFromDB(tblCustomer.Rows(0)("U_AccountHolderName"))
            litPaymentCustomerID.Visible = True
            litPaymentCustomerName.Visible = True
            lblPaymentCustomerID.Visible = True
            lblPaymentCustomerName.Visible = True
            tblCustomer = Nothing
            Return lngCustomerID
        Else
            litPaymentCustomerID.Visible = False
            litPaymentCustomerName.Visible = False
            lblPaymentCustomerID.Visible = False
            lblPaymentCustomerName.Visible = False
            txtPaymentCustomerEmail.Text = ""
            tblCustomer = Nothing
            Return 0
        End If
    End Function

    Function SetPaymentCurrency(ByVal intCurrencyID As Integer) As Integer
        Dim tblCurrency As New DataTable
        Dim rowCurrencies As DataRow()

        rowCurrencies = CurrenciesBLL._GetByCurrencyID(intCurrencyID)

        If rowCurrencies IsNot Nothing Then
            ddlPaymentCurrency.SelectedValue = CByte(rowCurrencies(0)("CUR_ID"))
            txtPaymentCurrencyRate.Text = _HandleDecimalValues(CStr(FixNullFromDB(rowCurrencies(0)("CUR_ExchangeRate"))))
            rowCurrencies = Nothing
            Return intCurrencyID
        Else
            ddlPaymentCurrency.SelectedValue = ""
            txtPaymentCurrencyRate.Text = ""
            rowCurrencies = Nothing
            Return 0
        End If
    End Function

    Function SetPaymentGateway(ByVal strPaymentGateway As String) As Boolean
        Try
            Dim blnGatewayFound As Boolean = False
            For Each item As ListItem In ddlPaymentGateways.Items
                If item.Value.ToLower = strPaymentGateway.ToLower Then
                    ddlPaymentGateways.SelectedValue = strPaymentGateway
                    blnGatewayFound = True
                    Exit For
                End If
            Next
            If blnGatewayFound Then
                litInactivePaymentGateway.Text = ""
                valPaymentGateways.Enabled = True
            Else
                litInactivePaymentGateway.Text = strPaymentGateway
                ddlPaymentGateways.Visible = False
                valPaymentGateways.Enabled = False
            End If
            Return True
        Catch ex As Exception
            Return False
        End Try
    End Function

    Protected Sub txtPaymentCustomerEmail_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles txtPaymentCustomerEmail.TextChanged
        If SetPaymentCustomer(txtPaymentCustomerEmail.Text) Then ddlPaymentGateways.Focus() Else txtPaymentCustomerEmail.Focus()
    End Sub

    ''' <summary>
    ''' handles the delete linkbutton being clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    ''' <summary>
    ''' if the delete is confirmed, "Yes" is chosen
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        'OrdersBLL._Delete(ViewState("numOrderID"), blnReturnStock)
        If Not String.IsNullOrEmpty(Request.QueryString("PaymentID")) Then
            Dim lngPaymentID As Long = CLng(Request.QueryString("PaymentID"))
            Dim objOrdersBLL As New OrdersBLL
            objOrdersBLL._DeletePayment(lngPaymentID)
            Response.Redirect(ViewState("Referer"))
        End If
    End Sub

    ''' <summary>
    ''' Click to save order
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click

        Dim objOrdersBLL As New OrdersBLL
        If Not String.IsNullOrEmpty(Request.QueryString("PaymentID")) Then

            Dim lngPaymentID As Long = CLng(Request.QueryString("PaymentID"))

            If objOrdersBLL._UpdatePayment(lngPaymentID, txtPaymentDate.Text, litPaymentCustomerID.Text, txtPaymentAmount.Text, ddlPaymentCurrency.SelectedValue,
                                            ddlPaymentGateways.SelectedValue, txtPaymentReferenceCode.Text, txtPaymentCurrencyRate.Text, lbxOrders.Items) > 0 Then
                RaiseEvent ShowMasterUpdate()
            End If

        Else
            Dim intNewPaymentID As Integer
            'v3.2001
            'I found during testing (but would not really happen in real use cases) that
            'when adding payments, I make up a reference code. Problem is, these must be unique
            'in the db, and often the made up ones aren't. Need to trap insertion error, and
            'pretty sure in these cases, errors would be down to that.

            intNewPaymentID = objOrdersBLL._AddNewPayment(txtPaymentDate.Text, litPaymentCustomerID.Text, txtPaymentAmount.Text, ddlPaymentCurrency.SelectedValue, ddlPaymentGateways.SelectedValue,
                                         txtPaymentReferenceCode.Text, txtPaymentCurrencyRate.Text, lbxOrders.Items)
            If intNewPaymentID > 0 Then
                'Mark order as paid
                'Rather than redirect to the payment, if it was successful and linked to a specific order, we should
                'redirect to edit that order, so the payment box and any comments can be made
                If lbxOrders.Items.Count > 0 Then
                    'we have an order linked to this payment
                    Dim numOrderID As Integer = lbxOrders.Items(0).Value
                    Response.Redirect("_ModifyOrderStatus.aspx?OrderID=" & numOrderID & "&FromDate=false&Page=1")
                Else
                    Response.Redirect("_ModifyPayment.aspx?PaymentID=" & intNewPaymentID & "&s=update")
                End If

            Else
                'Will return zero in case of error
                'Error, show "already in use" validator for reference box
                litPaymentReferenceUsed.Visible = True
                litPaymentReferenceUsed.Text = "<br /><span class=""error"" style=""display: inline;"">" & GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists") & "</span>"
                updPaymentDetails.Update()
            End If

        End If

    End Sub
End Class

