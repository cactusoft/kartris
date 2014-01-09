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
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation
Imports KartSettingsManager
Imports KartrisClasses

Partial Class UserControls_Back_EditOrder
    Inherits System.Web.UI.UserControl

    Private _SelectedPaymentMethod As String = ""

    ''' <summary>
    ''' this runs when an update to data is made to trigger the animation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event ShowMasterUpdate()

    ''' <summary>
    ''' this runs each time the page is called
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            ViewState("Referer") = Request.ServerVariables("HTTP_REFERER")

            Try

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


                'Get the Order ID QueryString - if it won't convert to integer then force return to Orders List page
                ViewState("numOrderID") = CType(Request.QueryString("OrderID"), Integer)
                If ViewState("numOrderID") = 0 Then

                Else
                    Dim dtOrderRecord As DataTable = OrdersBLL.GetOrderByID(ViewState("numOrderID"))
                    If dtOrderRecord IsNot Nothing Then
                        If dtOrderRecord.Rows.Count = 1 Then
                            Dim strOrderData As String = ""
                            litOrderID.Text = dtOrderRecord.Rows(0)("O_ID")
                            strOrderData = CkartrisDataManipulation.FixNullFromDB(dtOrderRecord.Rows(0)("O_Data"))
                            Dim intOrderLanguageID As Int16 = CShort(dtOrderRecord.Rows(0)("O_LanguageID"))
                            Dim intOrderCurrencyID As Int16 = CShort(dtOrderRecord.Rows(0)("O_CurrencyID"))
                            Dim strOrderPaymentGateway As String = dtOrderRecord.Rows(0)("O_PaymentGateway")
                            litOrderCustomerID.Text = CInt(dtOrderRecord.Rows(0)("O_CustomerID"))
                            txtOrderCustomerEmail.Text = UsersBLL.GetEmailByID(litOrderCustomerID.Text)
                            txtOrderPONumber.Text = CkartrisDataManipulation.FixNullFromDB(dtOrderRecord.Rows(0)("O_PurchaseOrderNo"))
                            chkOrderSent.Checked = CBool(dtOrderRecord.Rows(0)("O_Sent"))
                            chkOrderInvoiced.Checked = CBool(dtOrderRecord.Rows(0)("O_Invoiced"))
                            chkSendOrderUpdateEmail.Checked = CBool(dtOrderRecord.Rows(0)("O_SendOrderUpdateEmail"))
                            Session("LANG") = intOrderLanguageID
                            Session("CUR_ID") = intOrderCurrencyID

                            'Build up the language dropdown
                            ddlOrderLanguage.Items.Clear()
                            For Each objLang As Language In Language.LoadLanguages
                                Dim lstItem As New ListItem(objLang.Name, objLang.ID)
                                ddlOrderLanguage.Items.Add(lstItem)
                            Next

                            ddlOrderLanguage.SelectedValue = intOrderLanguageID

                            ViewState("arrOrderData") = Split(strOrderData, "|||")
                            Dim objOrder As New Kartris.Interfaces.objOrder
                            objOrder = Payment.Deserialize(ViewState("arrOrderData")(0), objOrder.GetType)
                            Dim addBilling As Address = Nothing
                            Dim addShipping As Address = Nothing

                            With objOrder
                                With .Billing
                                    addBilling = New Address(.Name, .Company, .StreetAddress, .TownCity, .CountyState, .Postcode, _
                                                                          Country.GetByIsoCode(.CountryIsoCode).CountryId, .Phone, , , _
                                                                          IIf(objOrder.SameShippingAsBilling, "u", "b"))
                                End With
                                If .SameShippingAsBilling Then
                                    addShipping = addBilling
                                    ViewState("intShippingDestinationID") = Country.GetByIsoCode(.Billing.CountryIsoCode).CountryId
                                Else
                                    With .Shipping
                                        addShipping = New Address(.Name, .Company, .StreetAddress, .TownCity, .CountyState, .Postcode, _
                                                                          Country.GetByIsoCode(.CountryIsoCode).CountryId, .Phone, , , _
                                                                          IIf(objOrder.SameShippingAsBilling, "u", "s"))
                                        ViewState("intShippingDestinationID") = Country.GetByIsoCode(.CountryIsoCode).CountryId
                                    End With
                                End If
                            End With
                            Dim lstBilling As New Generic.List(Of Address)
                            lstBilling.Add(addBilling)
                            UC_BillingAddress.Addresses = lstBilling

                            Dim lstShipping As New Generic.List(Of Address)
                            lstShipping.Add(addShipping)
                            UC_ShippingAddress.Addresses = lstShipping

                            If ddlPaymentGateways.Items.Count = 2 And strOrderPaymentGateway = "" Then
                                _SelectedPaymentMethod = ddlPaymentGateways.Items(1).Value
                                ddlPaymentGateways.SelectedValue = ddlPaymentGateways.Items(1).Value
                                valPaymentGateways.Enabled = False 'disable validation just to be sure
                            End If

                            If _SelectedPaymentMethod = "" Then
                                _SelectedPaymentMethod = strOrderPaymentGateway
                                ddlPaymentGateways.SelectedValue = strOrderPaymentGateway
                            End If

                            LoadBasket()

                        Else
                            Exit Sub
                        End If
                    Else
                        Exit Sub
                    End If
                End If



            Catch ex As Exception
                CkartrisFormatErrors.LogError(ex.Message)
                Response.Redirect("_OrdersList.aspx")
            End Try
        End If
    End Sub
    Protected Sub LoadBasket(Optional ByVal blnCopyOrderItems As Boolean = False)
        Dim objBasket As BasketBLL = UC_BasketMain.GetBasket
        Dim sessionID As Long = Session("SessionID")

        objBasket = Payment.Deserialize(ViewState("arrOrderData")(1), objBasket.GetType)

        If blnCopyOrderItems Then
            UC_BasketMain.EmptyBasket_Click(Nothing, Nothing)
            If objBasket.BasketItems IsNot Nothing Then
                Dim BasketItem As New BasketItem
                'final check if basket items are still there

                For Each item As BasketItem In objBasket.BasketItems
                    With item
                        objBasket.AddNewBasketValue(BasketBLL.BASKET_PARENTS.BASKET, sessionID, .VersionID, .Quantity, .CustomText, .OptionText)
                    End With
                Next
            End If

        End If

        'get the shipping destination id from the viewstate and assign it to the basket controls destination id property
        UC_BasketMain.ShippingDestinationID = ViewState("intShippingDestinationID")


        'reload the basketitems from the database - this confirms if the items were correctly added from the invoicerows data
        objBasket.LoadBasketItems()

        Session("Basket") = objBasket
        Session("BasketItems") = objBasket.BasketItems

        'recalculate and refresh display
        UC_BasketMain.LoadBasket()
        UC_BasketMain.RefreshShippingMethods()
        'If UC_BasketMain.GetBasketItems.Count > 0 Then btnCreateNewOrder.Visible = True Else btnCreateNewOrder.Visible = False

    End Sub
    'Format back link
    Public Function FormatBackLink(ByVal strDate As String, ByVal strFromDate As String, ByVal strPage As String) As String
        Dim strURL As String = ""
        If strFromDate = "false" And (strPage = "" Or strPage = "1") Then
            'No page or date passed, format js back link
            strURL = "javascript:history.back()"
        Else
            'We have either a date, or page number, or both
            If strFromDate = "true" Then
                strURL &= "_OrdersList.aspx?strDate=" & strDate
            Else
                strURL &= "_OrdersList.aspx?strDate="
            End If
            If CInt(strPage) > 1 Then
                strURL &= "&Page=" & strPage
            End If
        End If

        Return strURL
    End Function

    Protected Sub chkSameShippingAsBilling_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkSameShippingAsBilling.CheckedChanged
        If chkSameShippingAsBilling.Checked Then
            pnlShippingAddress.Visible = False
            RefreshShippingMethods("billing")
        Else
            pnlShippingAddress.Visible = True
            RefreshShippingMethods("shipping")
        End If

    End Sub

    Private Sub RefreshShippingMethods(Optional ByVal strControl As String = "shipping")
        Dim numShippingDestinationID As Integer
        If strControl = "billing" Then
            If UC_BillingAddress.SelectedAddress IsNot Nothing Then
                numShippingDestinationID = UC_BillingAddress.SelectedAddress.CountryID
            Else
                numShippingDestinationID = 0
            End If
        Else
            If UC_ShippingAddress.SelectedAddress IsNot Nothing Then
                numShippingDestinationID = UC_ShippingAddress.SelectedAddress.CountryID
            Else
                numShippingDestinationID = 0
            End If
        End If

        'Check whether to show the EUVat Field or not
        If Not String.IsNullOrEmpty(GetKartConfig("general.tax.euvatcountry")) Then
            Dim adrShipping As Address = Nothing
            If chkSameShippingAsBilling.Checked Then
                If UC_BillingAddress.SelectedID > 0 Then
                    adrShipping = UC_BillingAddress.Addresses.Find(Function(Add) Add.ID = UC_BillingAddress.SelectedID)
                ElseIf numShippingDestinationID > 0 Then
                    adrShipping = UC_BillingAddress.SelectedAddress
                End If
            Else
                If UC_ShippingAddress.SelectedID > 0 Then
                    adrShipping = UC_ShippingAddress.Addresses.Find(Function(Add) Add.ID = UC_ShippingAddress.SelectedID)
                ElseIf numShippingDestinationID > 0 Then
                    adrShipping = UC_ShippingAddress.SelectedAddress
                End If
            End If
            If adrShipping IsNot Nothing Then
                If UCase(adrShipping.Country.IsoCode) <> UCase(GetKartConfig("general.tax.euvatcountry")) And adrShipping.Country.D_Tax Then
                    phdEUVAT.Visible = True
                    litMSCode.Text = adrShipping.Country.IsoCode
                    If litMSCode.Text = "GR" Then litMSCode.Text = "EL"
                Else
                    phdEUVAT.Visible = False
                End If
            Else
                phdEUVAT.Visible = False
            End If
        Else
            phdEUVAT.Visible = False
        End If

        txtEUVAT.Text = ""
        Session("blnEUVATValidated") = False

        Dim objShippingDetails As New Interfaces.objShippingDetails

        UC_BasketMain.ShippingDetails = objShippingDetails
        UC_BasketMain.ShippingDestinationID = numShippingDestinationID
        UC_BasketMain.RefreshShippingMethods()

    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect(ViewState("Referer"))
    End Sub

    '''' <summary>
    '''' handles the reset and copy linkbutton being clicked
    '''' </summary>
    '''' <remarks></remarks>
    Protected Sub lnkBtnResetAndCopy_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        LoadBasket(True)
    End Sub
    Protected Sub lnkBtnAddToBasket_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim intVersionID As Long = CheckAutoCompleteData()
        If intVersionID > 0 Then
            Dim dr As DataRow = VersionsBLL._GetVersionByID(intVersionID).Rows(0)
            Select Case CChar(FixNullFromDB(dr("V_Type")))
                Case "o", "b", "c"  '' Options Product
                    litOptionsVersion.Text = intVersionID
                    _UC_AutoComplete_Item.SetText("")
                    _UC_OptionsPopup.ShowPopup(intVersionID, FixNullFromDB(dr("V_ProductID")), FixNullFromDB(dr("V_CodeNumber"))) '' Show options for selected product
                Case Else           '' Normal Product
                    litOptionsVersion.Text = ""
                    Dim objBasket As BasketBLL = UC_BasketMain.GetBasket
                    Dim sessionID As Long = Session("SessionID")
                    objBasket.AddNewBasketValue(BasketBLL.BASKET_PARENTS.BASKET, sessionID, intVersionID, 1, "", "")
                    _UC_AutoComplete_Item.SetText("")
                    LoadBasket()
            End Select
        End If
    End Sub
    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetLocalResourceObject("ContentText_ConfirmEditOrder"))
    End Sub
    ''' <summary>
    ''' if the save is confirmed, "Yes" is chosen
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed

        Dim CUR_ID As Integer = CInt(Session("CUR_ID"))

        Dim strBillingAddressText As String, strShippingAddressText As String

        Dim sbdBodyText As StringBuilder = New StringBuilder
        Dim sbdBasketItems As StringBuilder = New StringBuilder

        Dim arrBasketItems As ArrayList
        Dim objBasket As BasketBLL = Session("Basket")
        Dim objOrder As Kartris.Interfaces.objOrder = Nothing
        Dim strOrderDetails As String = ""

        Dim blnAppPricesIncTax As Boolean
        Dim blnAppShowTaxDisplay As Boolean
        Dim blnAppUSmultistatetax As Boolean
        If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Then
            blnAppPricesIncTax = False
            blnAppShowTaxDisplay = False
            blnAppUSmultistatetax = True
        Else
            blnAppPricesIncTax = GetKartConfig("general.tax.pricesinctax") = "y"
            blnAppShowTaxDisplay = GetKartConfig("frontend.display.showtax") = "y"
            blnAppUSmultistatetax = False
        End If

        Dim intGatewayCurrency As Int16 = 0

        'try to get the gateway currency and details from the old order
        Dim intO_ID As Integer = ViewState("numOrderID")
        Dim dtOrderRecord As DataTable = OrdersBLL.GetOrderByID(intO_ID)
        If dtOrderRecord IsNot Nothing Then
            If dtOrderRecord.Rows.Count = 1 Then
                intGatewayCurrency = dtOrderRecord.Rows(0)("O_CurrencyIDGateway")
                strOrderDetails = dtOrderRecord.Rows(0)("O_Details")
            Else
                Exit Sub
            End If
        Else
            Exit Sub
        End If

        'THIS CODE IS MAINLY FROM THE CHECKOUT || GENERATES THE BASKET DETAILS, SHIPPING AND ORDER TOTAL LINES
        With UC_BillingAddress.SelectedAddress
            strBillingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                          .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                          .County & vbCrLf & .Postcode & vbCrLf & _
                          .Country.Name
        End With
        If chkSameShippingAsBilling.Checked Then
            strShippingAddressText = strBillingAddressText
        Else
            With UC_ShippingAddress.SelectedAddress
                strShippingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                              .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                              .County & vbCrLf & .Postcode & vbCrLf & _
                              .Country.Name
            End With
        End If

        Dim blnDifferentGatewayCurrency As Boolean = CUR_ID <> intGatewayCurrency
        Dim blnDifferentOrderCurrency As Boolean = CurrenciesBLL.GetDefaultCurrency <> CUR_ID


        'Promotion discount
        Dim strPromotionDescription As String = ""
        If objBasket.PromotionDiscount.IncTax < 0 Then
            For Each objPromotion As PromotionBasketModifier In UC_BasketMain.GetPromotionsDiscount
                With objPromotion
                    sbdBodyText.Append(GetItemEmailText(GetGlobalResourceObject("Kartris", "ContentText_PromotionDiscount"), .Name, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
                    If strPromotionDescription <> "" Then strPromotionDescription += vbCrLf & .Name Else strPromotionDescription += .Name
                End With
            Next
        End If

        'Coupon discount
        If objBasket.CouponDiscount.IncTax < 0 Then

            sbdBodyText.Append(GetBasketModifierEmailText(objBasket.CouponDiscount, GetGlobalResourceObject("Kartris", "ContentText_CouponDiscount"), "strCouponName"))
        End If

        'Customer discount
        If objBasket.CustomerDiscount.IncTax < 0 Then
            sbdBodyText.Append(GetBasketModifierEmailText(objBasket.CustomerDiscount, GetGlobalResourceObject("Basket", "ContentText_Discount"), ""))
        End If

        sbdBodyText.Append(GetBasketModifierEmailText(objBasket.ShippingPrice, GetGlobalResourceObject("Address", "ContentText_Shipping"), IIf(String.IsNullOrEmpty(objBasket.ShippingDescription), objBasket.ShippingName, objBasket.ShippingDescription)))


        'Order handling charge
        If objBasket.OrderHandlingPrice.ExTax > 0 Then
            sbdBodyText.Append(GetBasketModifierEmailText(objBasket.OrderHandlingPrice, GetGlobalResourceObject("Kartris", "ContentText_OrderHandlingCharge"), ""))
        End If
        sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))

        'Order totals
        If blnAppPricesIncTax = False Or blnAppShowTaxDisplay Then
            sbdBodyText.Append(" " & GetGlobalResourceObject("Checkout", "ContentText_OrderValue") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceExTax, , False) & vbCrLf)
            sbdBodyText.Append(" " & GetGlobalResourceObject("Kartris", "ContentText_Tax") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceTaxAmount, , False) & _
                 IIf(blnAppUSmultistatetax, " (" & (objBasket.D_Tax * 100) & "%)", "") & vbCrLf)
        End If
        sbdBodyText.Append(" " & GetGlobalResourceObject("Basket", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceIncTax, , False) & vbCrLf)
        sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))


        Dim numGatewayTotalPrice As Double
        If blnDifferentGatewayCurrency Then
            numGatewayTotalPrice = CurrenciesBLL.ConvertCurrency(intGatewayCurrency, objBasket.FinalPriceIncTax, CUR_ID)

            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_ProcessCurrencyExp1") & vbCrLf)
            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(intGatewayCurrency, numGatewayTotalPrice, , False) & vbCrLf)
            sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)
        Else
            numGatewayTotalPrice = objBasket.FinalPriceIncTax
        End If

        'Total Saved
        If objBasket.TotalAmountSaved > 0 And KartSettingsManager.GetKartConfig("frontend.checkout.confirmation.showtotalsaved") = "y" Then
            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_TotalSaved1") & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.TotalAmountSaved, , False) & GetGlobalResourceObject("Email", "EmailText_TotalSaved2") & vbCrLf)
            sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
        End If

        'Customer billing information
        sbdBodyText.Append(vbCrLf)
        With UC_BillingAddress.SelectedAddress
            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_PurchaseContactDetails") & vbCrLf & _
                 " " & GetGlobalResourceObject("Address", "FormLabel_CardHolderName") & ": " & .FullName & vbCrLf & _
                 " " & GetGlobalResourceObject("Email", "EmailText_Company") & ": " & .Company & vbCrLf & _
                 IIf(Not String.IsNullOrEmpty(txtEUVAT.Text), " " & GetGlobalResourceObject("Invoice", "FormLabel_CardholderEUVatNum") & ": " & txtEUVAT.Text & vbCrLf, "") & _
                 " " & GetGlobalResourceObject("Kartris", "FormLabel_EmailAddress") & ": " & txtOrderCustomerEmail.Text & vbCrLf & _
                 " " & GetGlobalResourceObject("Address", "FormLabel_Telephone") & ": " & .Phone & vbCrLf & vbCrLf & _
                 " " & GetGlobalResourceObject("Email", "EmailText_Address") & ":" & vbCrLf & _
                 " " & .StreetAddress & vbCrLf & _
                 " " & .TownCity & vbCrLf & _
                 " " & .County & vbCrLf & _
                 " " & .Postcode & vbCrLf & _
                 " " & .Country.Name & vbCrLf & vbCrLf)
            sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)
        End With

        'Shipping info
        sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_ShippingDetails") & vbCrLf)
        Dim strShippingAddressEmailText As String = ""

        If chkSameShippingAsBilling.Checked Then
            With UC_BillingAddress.SelectedAddress
                strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf & _
                              " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf & _
                              " " & .County & vbCrLf & " " & .Postcode & vbCrLf & _
                              " " & .Country.Name & vbCrLf & vbCrLf
            End With
        Else
            With UC_ShippingAddress.SelectedAddress
                strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf & _
                              " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf & _
                              " " & .County & vbCrLf & " " & .Postcode & vbCrLf & _
                              " " & .Country.Name & vbCrLf & vbCrLf
            End With
        End If

        sbdBodyText.Append(strShippingAddressEmailText & GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)


        sbdBodyText.Insert(0, sbdBasketItems.ToString)

        arrBasketItems = UC_BasketMain.GetBasketItems
        If Not (arrBasketItems Is Nothing) Then
            Dim BasketItem As New BasketItem
            For i As Integer = 0 To arrBasketItems.Count - 1
                BasketItem = arrBasketItems(i)
                With BasketItem
                    Dim sbdOptionText As New StringBuilder("")
                    If Not String.IsNullOrEmpty(.OptionText) Then sbdOptionText.Append(vbCrLf & " " & .OptionText().Replace("<br>", vbCrLf & " ").Replace("<br />", vbCrLf & " "))
                    sbdBasketItems.Append( _
                                GetItemEmailText(.Quantity & " x " & .ProductName, .VersionName & " (" & .CodeNumber & ")" & _
                                                 sbdOptionText.ToString, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
                    If .CustomText <> "" Then
                        'Add custom text to mail
                        sbdBasketItems.Append(" [ " & .CustomText & " ]" & vbCrLf)
                    End If
                End With
            Next
        End If

        sbdBodyText.Insert(0, sbdBasketItems.ToString)

        'Extract IP/User Agent info from the original order
        strOrderDetails = Mid(strOrderDetails, InStr(strOrderDetails, " " & GetGlobalResourceObject("Email", "EmailText_OrderTime2")))

        'then try to append the updated basket and order total lines from the new basket
        strOrderDetails = sbdBodyText.ToString & strOrderDetails


        Dim intNewOrderID As Integer = OrdersBLL._CloneAndCancel(intO_ID, strOrderDetails, UC_BillingAddress.SelectedAddress, UC_ShippingAddress.SelectedAddress, _
                                                                 chkSameShippingAsBilling.Checked, chkOrderSent.Checked, chkOrderInvoiced.Checked, chkOrderPaid.Checked, _
                                                                 chkOrderShipped.Checked, objBasket, arrBasketItems, _
                                                                UC_BasketMain.SelectedShippingMethod, txtOrderNotes.Text, numGatewayTotalPrice, txtOrderPONumber.Text, _
                                                                strPromotionDescription, CUR_ID, chkSendOrderUpdateEmail.Checked)
        'if we got a new order id then that means the order was successfully cloned and cancelled - lets now redirect the user to the new order details page
        If intNewOrderID > 0 Then
            objOrder = New Kartris.Interfaces.objOrder
            'Create the Order object and fill in the property values.
            objOrder.ID = intNewOrderID
            objOrder.Description = GetGlobalResourceObject("Kartris", "Config_OrderDescription")
            objOrder.Amount = CurrenciesBLL.FormatCurrencyPrice(CUR_ID, numGatewayTotalPrice, False)
            objOrder.ShippingPrice = CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.ShippingPrice.IncTax, False)
            objOrder.OrderHandlingPrice = CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.OrderHandlingPrice.IncTax, False)

            With UC_BillingAddress.SelectedAddress
                objOrder.Billing.Name = .FullName
                objOrder.Billing.StreetAddress = .StreetAddress
                objOrder.Billing.TownCity = .TownCity
                objOrder.Billing.CountyState = .County
                objOrder.Billing.CountryName = .Country.Name
                objOrder.Billing.Postcode = .Postcode
                objOrder.Billing.Phone = .Phone
                objOrder.Billing.CountryIsoCode = .Country.IsoCode
            End With

            If chkSameShippingAsBilling.Checked Then
                objOrder.SameShippingAsBilling = True
            Else
                With UC_ShippingAddress.SelectedAddress
                    objOrder.Shipping.Name = .FullName
                    objOrder.Shipping.StreetAddress = .StreetAddress
                    objOrder.Shipping.TownCity = .TownCity
                    objOrder.Shipping.CountyState = .County
                    objOrder.Shipping.CountryName = .Country.Name
                    objOrder.Shipping.Postcode = .Postcode
                    objOrder.Shipping.Phone = .Phone
                    objOrder.Shipping.CountryIsoCode = .Country.IsoCode
                End With
            End If
            objOrder.CustomerIPAddress = Request.ServerVariables("REMOTE_HOST")
            objOrder.CustomerEmail = txtOrderCustomerEmail.Text

            'update data field with serialized order and basket objects and selected shipping method id - this allows us to edit this order later if needed
            OrdersBLL.DataUpdate(intNewOrderID, Payment.Serialize(objOrder) & "|||" & Payment.Serialize(objBasket) & "|||" & UC_BasketMain.SelectedShippingID)

            Response.Redirect("_ModifyOrderStatus.aspx?OrderID=" & intNewOrderID & "&cloned=y")
        End If
    End Sub

    Function CheckAutoCompleteData() As Long
        Dim strAutoCompleteText As String = ""
        strAutoCompleteText = _UC_AutoComplete_Item.GetText
        If strAutoCompleteText <> "" AndAlso strAutoCompleteText.Contains("(") _
                AndAlso strAutoCompleteText.Contains(")") Then
            Try
                Dim numItemID As Long = CLng(Mid(strAutoCompleteText, strAutoCompleteText.LastIndexOf("(") + 2, strAutoCompleteText.LastIndexOf(")") - strAutoCompleteText.LastIndexOf("(") - 1))
                Dim strItemName As String = ""
                strItemName = VersionsBLL._GetNameByVersionID(numItemID, Session("_LANG"))

                If strItemName Is Nothing Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
                    Return 0
                End If
                Return numItemID
            Catch ex As Exception
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
                Return 0
            End Try
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue"))
            Return 0
        End If
    End Function

    ''' <summary>
    ''' This even fired when the selection from the options popup has been saved
    ''' </summary>
    Protected Sub _UC_OptionsPopup_OptionsSelected(ByVal strOptions As String, ByVal numVersionID As Integer) Handles _UC_OptionsPopup.OptionsSelected
        If Not String.IsNullOrEmpty(litOptionsVersion.Text) AndAlso litOptionsVersion.Text = numVersionID Then
            _UC_OptionsPopup.ClearIDs() '' reset product id and version id for the options popup
            litOptionsVersion.Text = Nothing
            Dim objBasket As BasketBLL = UC_BasketMain.GetBasket
            Dim sessionID As Long = Session("SessionID")
            objBasket.AddNewBasketValue(BasketBLL.BASKET_PARENTS.BASKET, sessionID, numVersionID, 1, "", strOptions)
            LoadBasket()
        End If
    End Sub
End Class
