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
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation
Imports KartSettingsManager
Imports KartrisClasses

Partial Class UserControls_Back_CreateOrder
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

            Session("OrderID") = 0

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
                ElseIf ddlPaymentGateways.Items.Count > 1 Then
                    ddlPaymentGateways.SelectedIndex = 1
                End If

                ddlOrderLanguage.Items.Clear()
                For Each objLang As Language In Language.LoadLanguages
                    Dim lstItem As New ListItem(objLang.Name, objLang.ID)
                    ddlOrderLanguage.Items.Add(lstItem)
                Next

                ddlOrderLanguage.SelectedIndex = 0

                Dim tblCurrencies As DataTable = KartSettingsManager.GetCurrenciesFromCache() 'CurrenciesBLL.GetCurrencies()
                Dim drwLiveCurrencies As DataRow() = tblCurrencies.Select("CUR_Live = 1")
                If drwLiveCurrencies.Length > 0 Then
                    ddlOrderCurrency.Items.Clear()
                    For i As Byte = 0 To drwLiveCurrencies.Length - 1
                        ddlOrderCurrency.Items.Add(New ListItem(drwLiveCurrencies(i)("CUR_Symbol") & " " & drwLiveCurrencies(i)("CUR_ISOCode"), drwLiveCurrencies(i)("CUR_ID")))
                    Next
                End If

                ddlOrderCurrency.SelectedValue = Session("CUR_ID")

                LoadBasket()
            Catch ex As Exception
                CkartrisFormatErrors.LogError(ex.Message)
                Response.Redirect("_OrdersList.aspx")
            End Try
        Else
            txtNewPassword.Attributes.Add("value", txtNewPassword.Text)
            txtConfirmPassword.Attributes.Add("value", txtConfirmPassword.Text)
        End If
    End Sub

    ''' <summary>
    ''' Currency changed
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ddlOrderCurrency_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlOrderCurrency.SelectedIndexChanged
        Session("CUR_ID") = ddlOrderCurrency.SelectedValue
        _UC_BasketMain.LoadBasket()
    End Sub

    ''' <summary>
    ''' Load the basket
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub LoadBasket()
        Dim objBasket As kartris.Basket = _UC_BasketMain.GetBasket
        Dim sessionID As Long = Session("SessionID")

        objBasket = Session("Basket")

        'get the shipping destination id from the viewstate and assign it to the basket controls destination id property
        _UC_BasketMain.ShippingDestinationID = ViewState("intShippingDestinationID")

        'reload the basketitems from the database - this confirms if the items were correctly added from the invoicerows data
        objBasket.LoadBasketItems()

        Session("Basket") = objBasket
        Session("BasketItems") = objBasket.BasketItems

        'recalculate and refresh display
        _UC_BasketMain.LoadBasket()
        If chkSameShippingAsBilling.Checked Then RefreshShippingInfo("billing") Else RefreshShippingInfo()
    End Sub

    ''' <summary>
    ''' Format a back link
    ''' </summary>
    ''' <remarks></remarks>
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

    ''' <summary>
    ''' Shipping address same as billing one box checked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub chkSameShippingAsBilling_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkSameShippingAsBilling.CheckedChanged
        If chkSameShippingAsBilling.Checked Then
            pnlShippingAddress.Visible = False
            _UC_ShippingAddress.Visible = False
            RefreshShippingInfo("billing")
        Else
            pnlShippingAddress.Visible = True
            _UC_ShippingAddress.Visible = True
            RefreshShippingInfo("shipping")
        End If

    End Sub

    ''' <summary>
    ''' Added added into email box (auto postback)
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub txtOrderCustomerEmail_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles txtOrderCustomerEmail.TextChanged
        Dim lngCustomerID As Long = CheckEmailExist(txtOrderCustomerEmail.Text)
        If lngCustomerID > 0 Then
            phdExistingCustomer.Visible = True
            litOrderCustomerID.Text = lngCustomerID
            phdNewPassword.Visible = False
            _UC_BillingAddress.CustomerID = lngCustomerID
            _UC_ShippingAddress.CustomerID = lngCustomerID
            'Set up first user address (billing)
            Dim lstUsrAddresses As Collections.Generic.List(Of KartrisClasses.Address) = Nothing

            '---------------------------------------
            'BILLING ADDRESS
            '---------------------------------------
            If _UC_BillingAddress.Addresses Is Nothing Then

                'Find all addresses in this user's account
                lstUsrAddresses = KartrisClasses.Address.GetAll(lngCustomerID)

                'Populate dropdown by filtering billing/universal addresses
                _UC_BillingAddress.Addresses = lstUsrAddresses.FindAll(Function(p) p.Type = "b" Or p.Type = "u")
            End If

            '---------------------------------------
            'SHIPPING ADDRESS
            '---------------------------------------
            If _UC_ShippingAddress.Addresses Is Nothing Then

                'Find all addresses in this user's account
                If lstUsrAddresses Is Nothing Then lstUsrAddresses = KartrisClasses.Address.GetAll(lngCustomerID)

                'Populate dropdown by filtering shipping/universal addresses
                _UC_ShippingAddress.Addresses = lstUsrAddresses.FindAll(Function(ShippingAdd) ShippingAdd.Type = "s" Or ShippingAdd.Type = "u")
            End If

            '---------------------------------------
            'SHIPPING/BILLING ADDRESS NOT SAME
            '---------------------------------------
            If (Not Session("DefaultBillingAddressID") = Session("DefaultShippingAddressID")) Then
                chkSameShippingAsBilling.Checked = False
            Else
                chkSameShippingAsBilling.Checked = True
            End If

            If Not chkSameShippingAsBilling.Checked Then
                'Show shipping address block
                pnlShippingAddress.Visible = True
                _UC_ShippingAddress.Visible = True
            Else
                pnlShippingAddress.Visible = False
                _UC_ShippingAddress.Visible = False
            End If

            '---------------------------------------
            'SELECT DEFAULT ADDRESSES
            '---------------------------------------
            If _UC_BillingAddress.SelectedID = 0 Then
                _UC_BillingAddress.SelectedID = Session("DefaultBillingAddressID")
            End If
            If _UC_ShippingAddress.SelectedID = 0 Then
                _UC_ShippingAddress.SelectedID = Session("DefaultShippingAddressID")
            End If

            If chkSameShippingAsBilling.Checked Then RefreshShippingInfo("billing") Else RefreshShippingInfo()
            _UC_AutoComplete_Item.SetFoucs()
        Else
            _UC_BillingAddress.Clear()
            _UC_ShippingAddress.Clear()

            chkSameShippingAsBilling.Checked = True
            pnlShippingAddress.Visible = False
            _UC_ShippingAddress.Visible = False

            phdExistingCustomer.Visible = False
            phdNewPassword.Visible = True
            txtNewPassword.Focus()
        End If
    End Sub

    ''' <summary>
    ''' Check that email address exists
    ''' </summary>
    ''' <remarks></remarks>
    Public Function CheckEmailExist(ByVal strEmailAddress As String) As Long
        Dim tblUserDetails As System.Data.DataTable = UsersBLL.GetDetails(strEmailAddress)
        If tblUserDetails.Rows.Count > 0 Then
            Session("DefaultBillingAddressID") = tblUserDetails(0)("U_DefBillingAddressID")
            Session("DefaultShippingAddressID") = tblUserDetails(0)("U_DefShippingAddressID")
            Return tblUserDetails(0)("U_ID")
        Else
            Session("DefaultBillingAddressID") = 0
            Session("DefaultShippingAddressID") = 0
            Return 0
        End If
    End Function

    ''' <summary>
    ''' Refresh shipping
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub RefreshShippingInfo(Optional ByVal strControl As String = "shipping")
        Dim numShippingDestinationID As Integer
        If strControl = "billing" Then
            If _UC_BillingAddress.SelectedAddress IsNot Nothing Then
                numShippingDestinationID = _UC_BillingAddress.SelectedAddress.CountryID
            Else
                numShippingDestinationID = 0
            End If
        Else
            If _UC_ShippingAddress.SelectedAddress IsNot Nothing Then
                numShippingDestinationID = _UC_ShippingAddress.SelectedAddress.CountryID
            Else
                numShippingDestinationID = 0
            End If
        End If

        'Check whether to show the EUVat Field or not
        If Not String.IsNullOrEmpty(GetKartConfig("general.tax.euvatcountry")) Then
            Dim adrShipping As Address = Nothing
            If chkSameShippingAsBilling.Checked Then
                If _UC_BillingAddress.SelectedID > 0 Then
                    adrShipping = _UC_BillingAddress.Addresses.Find(Function(Add) Add.ID = _UC_BillingAddress.SelectedID)
                ElseIf numShippingDestinationID > 0 Then
                    adrShipping = _UC_BillingAddress.SelectedAddress
                End If
            Else
                If _UC_ShippingAddress.SelectedID > 0 Then
                    adrShipping = _UC_ShippingAddress.Addresses.Find(Function(Add) Add.ID = _UC_ShippingAddress.SelectedID)
                ElseIf numShippingDestinationID > 0 Then
                    adrShipping = _UC_ShippingAddress.SelectedAddress
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


        '=======================================================
        'SET SHIPPING DETAILS FROM ADDRESS CONTROL
        '=======================================================
        Dim objShippingDetails As New Interfaces.objShippingDetails
        Try
            With objShippingDetails.RecipientsAddress
                If chkSameShippingAsBilling.Checked Then
                    .Postcode = _UC_BillingAddress.SelectedAddress.Postcode
                    .CountryID = _UC_BillingAddress.SelectedAddress.Country.CountryId
                    .CountryIsoCode = _UC_BillingAddress.SelectedAddress.Country.IsoCode
                    .CountryName = _UC_BillingAddress.SelectedAddress.Country.Name
                Else
                    .Postcode = _UC_ShippingAddress.SelectedAddress.Postcode
                    .CountryID = _UC_ShippingAddress.SelectedAddress.Country.CountryId
                    .CountryIsoCode = _UC_ShippingAddress.SelectedAddress.Country.IsoCode
                    .CountryName = _UC_ShippingAddress.SelectedAddress.Country.Name
                End If
            End With
        Catch ex As Exception

        End Try

        _UC_BasketMain.ShippingDetails = objShippingDetails
        _UC_BasketMain.ShippingDestinationID = numShippingDestinationID
        _UC_BasketMain.RefreshShippingMethods()

    End Sub

    ''' <summary>
    ''' Cancel
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect(ViewState("Referer"))
    End Sub

    ''' <summary>
    ''' Add item to basket using AJAX lookup
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnAddToBasket_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim intVersionID As Long = CheckAutoCompleteData()
        If intVersionID > 0 Then
            Session("LANG") = ddlOrderLanguage.SelectedValue

            'Set the default currency - can no longer
            'assume is ID=1
            Dim tblCurrencies As DataTable = KartSettingsManager.GetCurrenciesFromCache() 'CurrenciesBLL.GetCurrencies()
            Dim drwLiveCurrencies As DataRow() = tblCurrencies.Select("CUR_Live = 1")
            If drwLiveCurrencies.Length > 0 Then
                Session("CUR_ID") = CInt(drwLiveCurrencies(0)("CUR_ID"))
            Else
                Session("CUR_ID") = 1
            End If

            Dim dr As DataRow = VersionsBLL._GetVersionByID(intVersionID).Rows(0)
            Select Case CChar(FixNullFromDB(dr("V_Type")))
                Case "o", "b", "c"  '' Options Product
                    litOptionsVersion.Text = intVersionID
                    _UC_AutoComplete_Item.SetText("")
                    _UC_OptionsPopup.ShowPopup(intVersionID, FixNullFromDB(dr("V_ProductID")), FixNullFromDB(dr("V_CodeNumber"))) '' Show options for selected product
                Case Else           '' Normal Product
                    litOptionsVersion.Text = ""
                    Dim objBasket As kartris.Basket = _UC_BasketMain.GetBasket
                    Dim sessionID As Long = Session("SessionID")
                    BasketBLL.AddNewBasketValue(objBasket.BasketItems, BasketBLL.BASKET_PARENTS.BASKET, sessionID, intVersionID, 1, "", "")
                    _UC_AutoComplete_Item.SetText("")
                    Session("Basket") = objBasket
                    LoadBasket()
            End Select
        End If
    End Sub

    ''' <summary>
    ''' Save the order - will trigger confirmation first
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        Dim strErrorMessage As String = ""

        'Validate fields
        If Not _UC_BasketMain.GetBasket.AllFreeShipping And _UC_BasketMain.SelectedShippingID = 0 Then strErrorMessage += GetGlobalResourceObject("Checkout", "ContentText_NoShippingSelected") & "<br/>"
        If txtConfirmPassword.Text <> txtNewPassword.Text Then strErrorMessage += GetGlobalResourceObject("_Orders", "ErrorText_PasswordsMustMatch") & "<br/>"
        If _UC_BasketMain.GetBasketItems.Count = 0 Then strErrorMessage += GetGlobalResourceObject("Basket", "ContentText_BasketEmpty") & "<br/>"

        If strErrorMessage <> "" Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strErrorMessage)
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Orders", "ContentText_NewOrderConfirmation"))
        End If

    End Sub
    ''' <summary>
    ''' if the save is confirmed, "Yes" is chosen
    ''' This Sub does the actual order creation.
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed

        If Session("OrderID") = 0 Then

            'MOST OF THE CODE HERE CAME FROM CHECKOUT
            Dim CUR_ID As Integer = CInt(Session("CUR_ID"))

            Dim sbdBodyText As StringBuilder = New StringBuilder
            Dim sbdBasketItems As StringBuilder = New StringBuilder

            Dim _blnAnonymousCheckout As Boolean = False
            Dim blnBasketAllDigital As Boolean = False

            'Dim arrBasketItems As ArrayList
            Dim BasketItems As List(Of Kartris.BasketItem)
            Dim objBasket As kartris.Basket = Session("Basket")
            Dim objOrder As Kartris.Interfaces.objOrder = Nothing
            Dim strOrderDetails As String = ""

            Dim blnAppPricesIncTax As Boolean
            Dim blnAppShowTaxDisplay As Boolean
            Dim blnAppUSmultistatetax As Boolean

            Dim intGatewayCurrency As Int16 = 0

            Dim clsPlugin As Kartris.Interfaces.PaymentGateway = Nothing
            Dim strGatewayName As String = ddlPaymentGateways.SelectedValue

            clsPlugin = Payment.PPLoader(strGatewayName)

            If LCase(clsPlugin.GatewayType) <> "local" Or clsPlugin.GatewayName.ToLower = "po_offlinepayment" Or
                clsPlugin.GatewayName.ToLower = "bitcoin" Then

                'Setup variables to use later
                Dim C_ID As Integer = 0
                Dim O_ID As Integer

                Dim blnUseHTMLOrderEmail As Boolean = (GetKartConfig("general.email.enableHTML") = "y")
                Dim sbdHTMLOrderEmail As StringBuilder = New StringBuilder
                Dim sbdHTMLOrderContents As StringBuilder = New StringBuilder
                Dim sbdHTMLOrderBasket As StringBuilder = New StringBuilder

                'Dim strBillingAddressText As String, strShippingAddressText As String
                Dim strSubject As String = ""
                Dim strTempEmailTextHolder As String = ""

                Dim sbdNewCustomerEmailText As StringBuilder = New StringBuilder

                Dim blnNewUser As Boolean = True
                If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Or ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple" Then
                    blnAppPricesIncTax = False
                    blnAppShowTaxDisplay = False
                    blnAppUSmultistatetax = True
                Else
                    blnAppPricesIncTax = GetKartConfig("general.tax.pricesinctax") = "y"
                    blnAppShowTaxDisplay = GetKartConfig("frontend.display.showtax") = "y"
                    blnAppUSmultistatetax = False
                End If

                'Get the order confirmation template if HTML email is enabled
                If blnUseHTMLOrderEmail Then
                    sbdHTMLOrderEmail.Append(RetrieveHTMLEmailTemplate("OrderConfirmation"))
                    'switch back to normal text email if the template can't be retrieved
                    If sbdHTMLOrderEmail.Length < 1 Then blnUseHTMLOrderEmail = False
                End If

                If Interfaces.Utils.TrimWhiteSpace(clsPlugin.Currency) <> "" Then
                    intGatewayCurrency = CurrenciesBLL.CurrencyID(clsPlugin.Currency)
                Else
                    intGatewayCurrency = CUR_ID
                End If

                'Set a boolean value if currency of order
                'set in payment system is different to 
                'that the user was using. This way we know
                'if we need to convert the total to a
                'different currency for payment.
                Dim blnDifferentGatewayCurrency As Boolean = CUR_ID <> intGatewayCurrency

                'Determine if is existing user, if
                'so set Customer ID to the logged in
                'user
                If Not String.IsNullOrEmpty(Trim(litOrderCustomerID.Text)) Then
                    C_ID = CLng(litOrderCustomerID.Text)
                    blnNewUser = False
                End If

                'Handle Promotion Coupons
                If Not String.IsNullOrEmpty(objBasket.CouponName) And objBasket.CouponDiscount.IncTax = 0 Then
                    strTempEmailTextHolder = GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf & " " & GetGlobalResourceObject("Basket", "ContentText_ApplyCouponCode") & vbCrLf & " " & objBasket.CouponName & vbCrLf
                    sbdBodyText.AppendLine(strTempEmailTextHolder)
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderContents.Append("<tr class=""row_promotioncoupons""><td colspan=""2"">" & strTempEmailTextHolder.Replace(vbCrLf, "<br/>") &
                                                    "</td></tr>")
                    End If
                End If

                'Promotion discount
                Dim strPromotionDescription As String = ""
                If objBasket.PromotionDiscount.IncTax < 0 Then
                    For Each objPromotion As PromotionBasketModifier In _UC_BasketMain.GetPromotionsDiscount
                        With objPromotion
                            sbdBodyText.AppendLine(GetItemEmailText(GetGlobalResourceObject("Kartris", "ContentText_PromotionDiscount"), .Name, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
                            If blnUseHTMLOrderEmail Then
                                sbdHTMLOrderContents.Append(GetHTMLEmailRowText(GetGlobalResourceObject("Kartris", "ContentText_PromotionDiscount"), .Name, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
                            End If
                            If strPromotionDescription <> "" Then strPromotionDescription += vbCrLf & .Name Else strPromotionDescription += .Name
                        End With
                    Next
                End If

                'Coupon discount
                If objBasket.CouponDiscount.IncTax < 0 Then
                    sbdBodyText.AppendLine(GetBasketModifierEmailText(objBasket.CouponDiscount, GetGlobalResourceObject("Kartris", "ContentText_CouponDiscount"), objBasket.CouponName))
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderContents.Append(GetBasketModifierHTMLEmailText(objBasket.CouponDiscount, GetGlobalResourceObject("Kartris", "ContentText_CouponDiscount"), objBasket.CouponName))
                    End If
                End If

                'Customer discount
                If objBasket.CustomerDiscount.IncTax < 0 Then
                    sbdBodyText.AppendLine(GetBasketModifierEmailText(objBasket.CustomerDiscount, GetGlobalResourceObject("Basket", "ContentText_Discount"), ""))
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderContents.Append(GetBasketModifierHTMLEmailText(objBasket.CustomerDiscount, GetGlobalResourceObject("Basket", "ContentText_Discount"), ""))
                    End If
                End If

                'Shipping
                sbdBodyText.AppendLine(GetBasketModifierEmailText(objBasket.ShippingPrice, GetGlobalResourceObject("Address", "ContentText_Shipping"), IIf(String.IsNullOrEmpty(objBasket.ShippingDescription), objBasket.ShippingName, objBasket.ShippingDescription)))
                If blnUseHTMLOrderEmail Then
                    sbdHTMLOrderContents.Append(GetBasketModifierHTMLEmailText(objBasket.ShippingPrice, GetGlobalResourceObject("Address", "ContentText_Shipping"), IIf(String.IsNullOrEmpty(objBasket.ShippingDescription), objBasket.ShippingName, objBasket.ShippingDescription)))
                End If

                'Order handling charge
                If objBasket.OrderHandlingPrice.ExTax > 0 Then
                    sbdBodyText.AppendLine(GetBasketModifierEmailText(objBasket.OrderHandlingPrice, GetGlobalResourceObject("Kartris", "ContentText_OrderHandlingCharge"), ""))
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderContents.Append(GetBasketModifierHTMLEmailText(objBasket.OrderHandlingPrice, GetGlobalResourceObject("Kartris", "ContentText_OrderHandlingCharge"), ""))
                    End If
                End If

                sbdBodyText.AppendLine(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))

                'Order totals
                If blnAppPricesIncTax = False Or blnAppShowTaxDisplay Then
                    sbdBodyText.AppendLine(" " & GetGlobalResourceObject("Checkout", "ContentText_OrderValue") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceExTax, , False) & vbCrLf)
                    sbdBodyText.Append(" " & GetGlobalResourceObject("Kartris", "ContentText_Tax") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceTaxAmount, , False) & _
                         IIf(blnAppUSmultistatetax, " (" & Math.Round((objBasket.D_Tax * 100), 5) & "%)", "") & vbCrLf)
                End If
                sbdBodyText.Append(" " & GetGlobalResourceObject("Basket", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceIncTax, , False) &
                                   " (" & CurrenciesBLL.CurrencyCode(CUR_ID) & " - " &
                                        LanguageElementsBLL.GetElementValue(GetLanguageIDfromSession,
                                        CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Currencies,
                                        CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, CUR_ID) &
                                    ")" & vbCrLf)
                sbdBodyText.AppendLine(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
                If blnUseHTMLOrderEmail Then
                    sbdHTMLOrderContents.Append("<tr class=""row_totals""><td colspan=""2"">")
                    If blnAppPricesIncTax = False Or blnAppShowTaxDisplay Then
                        sbdHTMLOrderContents.AppendLine(" " & GetGlobalResourceObject("Checkout", "ContentText_OrderValue") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceExTax, , False) & "<br/>")
                        sbdHTMLOrderContents.Append(" " & GetGlobalResourceObject("Kartris", "ContentText_Tax") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceTaxAmount, , False) & _
                             IIf(blnAppUSmultistatetax, " (" & Math.Round((objBasket.D_Tax * 100), 5) & "%)", "") & "<br/>")
                    End If
                    sbdHTMLOrderContents.Append("(" & CurrenciesBLL.CurrencyCode(CUR_ID) & " - " &
                                                    LanguageElementsBLL.GetElementValue(GetLanguageIDfromSession,
                                                    CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Currencies,
                                                    CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, CUR_ID) &
                                                ") <strong>" & GetGlobalResourceObject("Basket", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceIncTax, , False) &
                                                "</strong></td></tr>")
                End If

                'Handle order total conversion to different currency.
                'Some payment systems only accept one currency, e.g.
                'USD. In this case, if you have multiple currencies
                'on your site, the amount needs to be converted to
                'this one currency in order to process the payment on
                'the payment gateway.
                Dim numGatewayTotalPrice As Double
                If blnDifferentGatewayCurrency Then
                    numGatewayTotalPrice = CurrenciesBLL.ConvertCurrency(intGatewayCurrency, objBasket.FinalPriceIncTax, CUR_ID)
                    If clsPlugin.GatewayName.ToLower = "bitcoin" Then numGatewayTotalPrice = Math.Round(numGatewayTotalPrice, 8)

                    sbdBodyText.AppendLine(" " & GetGlobalResourceObject("Email", "EmailText_ProcessCurrencyExp1") & vbCrLf)
                    sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(intGatewayCurrency, numGatewayTotalPrice, , False) &
                                       " (" & CurrenciesBLL.CurrencyCode(intGatewayCurrency) & " - " &
                                           LanguageElementsBLL.GetElementValue(GetLanguageIDfromSession,
                                           CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Currencies,
                                           CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, intGatewayCurrency) &
                                         ")" & vbCrLf)
                    sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)

                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderContents.Append("<tr class=""row_processcurrency""><td colspan=""2"">")
                        sbdHTMLOrderContents.AppendLine(" " & GetGlobalResourceObject("Email", "EmailText_ProcessCurrencyExp1") & "<br/>")
                        sbdHTMLOrderContents.Append(" " & GetGlobalResourceObject("Email", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(intGatewayCurrency, numGatewayTotalPrice, , False) &
                                                    " (" & CurrenciesBLL.CurrencyCode(intGatewayCurrency) & " - " &
                                                       LanguageElementsBLL.GetElementValue(GetLanguageIDfromSession,
                                                       CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Currencies,
                                                       CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, intGatewayCurrency) &
                                                     ")" & "<br/>")
                        sbdHTMLOrderContents.Append("</td></tr>")
                    End If
                Else
                    'User was using same currency as the gateway requires, or
                    'the gateway supports multiple currencies... no conversion
                    'needed.
                    numGatewayTotalPrice = objBasket.FinalPriceIncTax
                End If

                'Total Saved
                If objBasket.TotalAmountSaved > 0 And KartSettingsManager.GetKartConfig("frontend.checkout.confirmation.showtotalsaved") = "y" Then
                    strTempEmailTextHolder = " " & GetGlobalResourceObject("Email", "EmailText_TotalSaved1") & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.TotalAmountSaved, , False) & GetGlobalResourceObject("Email", "EmailText_TotalSaved2") & vbCrLf
                    sbdBodyText.AppendLine(strTempEmailTextHolder)
                    sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderEmail.Replace("[totalsavedline]", strTempEmailTextHolder.Replace(vbCrLf, "<br/>"))
                    End If
                Else
                    sbdHTMLOrderEmail.Replace("[totalsavedline]", "")
                End If

                'Customer billing information
                sbdBodyText.Append(vbCrLf)
                With _UC_BillingAddress.SelectedAddress
                    sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_PurchaseContactDetails") & vbCrLf)

                    If Not _blnAnonymousCheckout Then
                        sbdBodyText.Append(" " & GetGlobalResourceObject("Address", "FormLabel_CardHolderName") & ": " & .FullName & vbCrLf & _
                                             " " & GetGlobalResourceObject("Email", "EmailText_Company") & ": " & .Company & vbCrLf & _
                                             IIf(Not String.IsNullOrEmpty(txtEUVAT.Text), " " & GetGlobalResourceObject("Invoice", "FormLabel_CardholderEUVatNum") & ": " & txtEUVAT.Text & vbCrLf, ""))
                    End If

                    sbdBodyText.Append(" " & GetGlobalResourceObject("Kartris", "FormLabel_EmailAddress") & ": " & txtOrderCustomerEmail.Text & vbCrLf)

                    If Not _blnAnonymousCheckout Then
                        sbdBodyText.Append(" " & GetGlobalResourceObject("Address", "FormLabel_Telephone") & ": " & .Phone & vbCrLf & vbCrLf)
                    End If

                    sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_Address") & ":" & vbCrLf)

                    If Not _blnAnonymousCheckout Then
                        sbdBodyText.Append(" " & .StreetAddress & vbCrLf & _
                            " " & .TownCity & vbCrLf & _
                            " " & .County & vbCrLf & _
                            " " & .Postcode & vbCrLf & _
                            " " & .Country.Name)
                    Else
                        sbdBodyText.Append(GetGlobalResourceObject("Kartris", "ContentText_NotApplicable"))
                    End If

                    sbdBodyText.Append(vbCrLf & vbCrLf & GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)

                    If blnUseHTMLOrderEmail Then
                        If Not _blnAnonymousCheckout Then
                            sbdHTMLOrderEmail.Replace("[billingname]", Server.HtmlEncode(.FullName))
                            'retrieve the company label text and value if present, otherwise hide both placeholders from the template
                            If Not String.IsNullOrEmpty(.Company) Then
                                sbdHTMLOrderEmail.Replace("[companylabel]", GetGlobalResourceObject("Email", "EmailText_Company") & ": ")
                                sbdHTMLOrderEmail.Replace("[billingcompany]", Server.HtmlEncode(.Company))
                            Else
                                sbdHTMLOrderEmail.Replace("[companylabel]", "")
                                sbdHTMLOrderEmail.Replace("[billingcompany]<br />", "")
                                sbdHTMLOrderEmail.Replace("[billingcompany]", "")
                            End If
                            'do the same for EUVAT number
                            If Not String.IsNullOrEmpty(txtEUVAT.Text) Then
                                sbdHTMLOrderEmail.Replace("[euvatnumberlabel]", GetGlobalResourceObject("Invoice", "FormLabel_CardholderEUVatNum") & ": ")
                                sbdHTMLOrderEmail.Replace("[euvatnumbervalue]", Server.HtmlEncode(txtEUVAT.Text))
                            Else
                                sbdHTMLOrderEmail.Replace("[euvatnumberlabel]", "")
                                sbdHTMLOrderEmail.Replace("[euvatnumbervalue]<br />", "")
                                sbdHTMLOrderEmail.Replace("[euvatnumbervalue]", "")
                            End If
                            sbdHTMLOrderEmail.Replace("[billingemail]", Server.HtmlEncode(txtOrderCustomerEmail.Text))
                            sbdHTMLOrderEmail.Replace("[billingphone]", Server.HtmlEncode(.Phone))
                            sbdHTMLOrderEmail.Replace("[billingstreetaddress]", Server.HtmlEncode(.StreetAddress))
                            sbdHTMLOrderEmail.Replace("[billingtowncity]", Server.HtmlEncode(.TownCity))
                            sbdHTMLOrderEmail.Replace("[billingcounty]", Server.HtmlEncode(.County))
                            sbdHTMLOrderEmail.Replace("[billingpostcode]", Server.HtmlEncode(.Postcode))
                            sbdHTMLOrderEmail.Replace("[billingcountry]", Server.HtmlEncode(.Country.Name))
                        Else
                            sbdHTMLOrderEmail.Replace("[billingname]", GetGlobalResourceObject("Kartris", "ContentText_NotApplicable"))

                            sbdHTMLOrderEmail.Replace("[companylabel]", "")
                            sbdHTMLOrderEmail.Replace("[billingcompany]<br />", "")
                            sbdHTMLOrderEmail.Replace("[billingcompany]", "")

                            sbdHTMLOrderEmail.Replace("[euvatnumberlabel]", "")
                            sbdHTMLOrderEmail.Replace("[euvatnumbervalue]<br />", "")
                            sbdHTMLOrderEmail.Replace("[euvatnumbervalue]", "")

                            sbdHTMLOrderEmail.Replace("[billingemail]", Server.HtmlEncode(txtOrderCustomerEmail.Text))

                            sbdHTMLOrderEmail.Replace("[billingphone]", GetGlobalResourceObject("Kartris", "ContentText_NotApplicable"))
                            sbdHTMLOrderEmail.Replace("[billingstreetaddress]", "")
                            sbdHTMLOrderEmail.Replace("[billingtowncity]", "")
                            sbdHTMLOrderEmail.Replace("[billingcounty]", "")
                            sbdHTMLOrderEmail.Replace("[billingpostcode]", "")
                            sbdHTMLOrderEmail.Replace("[billingcountry]", "")
                        End If

                    End If
                End With

                'Shipping info
                sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_ShippingDetails") & vbCrLf)
                Dim strShippingAddressEmailText As String = ""

                If Not blnBasketAllDigital Then
                    If chkSameShippingAsBilling.Checked Then
                        With _UC_BillingAddress.SelectedAddress
                            strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf & _
                                          " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf & _
                                          " " & .County & vbCrLf & " " & .Postcode & vbCrLf & _
                                          " " & .Country.Name & vbCrLf & vbCrLf
                            sbdHTMLOrderEmail.Replace("[shippingname]", Server.HtmlEncode(.FullName))
                            sbdHTMLOrderEmail.Replace("[shippingstreetaddress]", Server.HtmlEncode(.StreetAddress))
                            sbdHTMLOrderEmail.Replace("[shippingtowncity]", Server.HtmlEncode(.TownCity))
                            sbdHTMLOrderEmail.Replace("[shippingcounty]", Server.HtmlEncode(.County))
                            sbdHTMLOrderEmail.Replace("[shippingpostcode]", Server.HtmlEncode(.Postcode))
                            sbdHTMLOrderEmail.Replace("[shippingcountry]", Server.HtmlEncode(.Country.Name))
                            sbdHTMLOrderEmail.Replace("[shippingphone]", Server.HtmlEncode(.Phone))
                            If Not String.IsNullOrEmpty(.Company) Then
                                sbdHTMLOrderEmail.Replace("[shippingcompany]", Server.HtmlEncode(.Company))
                            Else
                                sbdHTMLOrderEmail.Replace("[shippingcompany]<br />", "")
                                sbdHTMLOrderEmail.Replace("[shippingcompany]", "")
                            End If
                        End With
                    Else
                        With _UC_ShippingAddress.SelectedAddress
                            strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf & _
                                          " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf & _
                                          " " & .County & vbCrLf & " " & .Postcode & vbCrLf & _
                                          " " & .Country.Name & vbCrLf & vbCrLf
                            sbdHTMLOrderEmail.Replace("[shippingname]", Server.HtmlEncode(.FullName))
                            sbdHTMLOrderEmail.Replace("[shippingstreetaddress]", Server.HtmlEncode(.StreetAddress))
                            sbdHTMLOrderEmail.Replace("[shippingtowncity]", Server.HtmlEncode(.TownCity))
                            sbdHTMLOrderEmail.Replace("[shippingcounty]", Server.HtmlEncode(.County))
                            sbdHTMLOrderEmail.Replace("[shippingpostcode]", Server.HtmlEncode(.Postcode))
                            sbdHTMLOrderEmail.Replace("[shippingcountry]", Server.HtmlEncode(.Country.Name))
                            sbdHTMLOrderEmail.Replace("[shippingphone]", Server.HtmlEncode(.Phone))
                            If Not String.IsNullOrEmpty(.Company) Then
                                sbdHTMLOrderEmail.Replace("[shippingcompany]", Server.HtmlEncode(.Company))
                            Else
                                sbdHTMLOrderEmail.Replace("[shippingcompany]", "")
                            End If
                        End With
                    End If
                Else
                    'Basket is all digital so blank out shipping address fields
                    strShippingAddressEmailText = GetGlobalResourceObject("Kartris", "ContentText_NotApplicable") & vbCrLf & vbCrLf
                    sbdHTMLOrderEmail.Replace("[shippingname]", GetGlobalResourceObject("Kartris", "ContentText_NotApplicable"))
                    sbdHTMLOrderEmail.Replace("[shippingstreetaddress]", "")
                    sbdHTMLOrderEmail.Replace("[shippingtowncity]", "")
                    sbdHTMLOrderEmail.Replace("[shippingcounty]", "")
                    sbdHTMLOrderEmail.Replace("[shippingpostcode]", "")
                    sbdHTMLOrderEmail.Replace("[shippingcountry]", "")
                    sbdHTMLOrderEmail.Replace("[shippingphone]", "")

                    sbdHTMLOrderEmail.Replace("[shippingcompany]<br />", "")
                    sbdHTMLOrderEmail.Replace("[shippingcompany]", "")
                End If


                sbdBodyText.Append(strShippingAddressEmailText & GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)

                'WE'RE OVERRIDING THE CUSTOMER COMMENTS CODE HERE AS THE ORDER IS BEING DONE THROUGH THE BACKEND BY THE ADMIN
                'Comments and additional info
                'If Trim(txtComments.Text) <> "" Then
                Dim arrAuth As String() = HttpSecureCookie.DecryptValue(Session("Back_Auth"), "Create New Order")
                strTempEmailTextHolder = " " & GetGlobalResourceObject("Email", "EmailText_Comments") & ": " & vbCrLf & vbCrLf &
                                         " " & GetGlobalResourceObject("_Orders", "ContentText_OrderCreatedByAdmin") & arrAuth(0) & vbCrLf & vbCrLf
                sbdBodyText.Append(strTempEmailTextHolder)
                If blnUseHTMLOrderEmail Then
                    sbdHTMLOrderEmail.Replace("[ordercomments]", Server.HtmlEncode(strTempEmailTextHolder).Replace(vbCrLf, "<br/>"))
                End If
                'Else
                'sbdHTMLOrderEmail.Replace("[ordercomments]", "")
                'End If

                sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_OrderTime2") & ": " & CkartrisDisplayFunctions.NowOffset & vbCrLf)
                sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_IPAddress") & ": " & Request.ServerVariables("REMOTE_ADDR") & vbCrLf)
                sbdBodyText.Append(" " & Request.ServerVariables("HTTP_USER_AGENT") & vbCrLf)
                If blnUseHTMLOrderEmail Then
                    sbdHTMLOrderEmail.Replace("[nowoffset]", CkartrisDisplayFunctions.NowOffset)
                    sbdHTMLOrderEmail.Replace("[customerip]", Request.ServerVariables("REMOTE_ADDR"))
                    sbdHTMLOrderEmail.Replace("[customeruseragent]", Request.ServerVariables("HTTP_USER_AGENT"))
                    sbdHTMLOrderEmail.Replace("[webshopurl]", CkartrisBLL.WebShopURL)
                    sbdHTMLOrderEmail.Replace("[websitename]", Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname")))
                End If

                '======================================
                'SEND NEW ACCOUNT DETAILS
                'This is probably not required and
                'it also sends the user password that
                'they chose too. For this reason, we
                'now turn off at default in the config
                'setting. But it can be turned on if
                'required.
                '======================================
                If KartSettingsManager.GetKartConfig("frontend.users.emailnewaccountdetails") = "y" And blnNewUser Then
                    'Build up email text
                    strSubject = GetGlobalResourceObject("Email", "Config_Subjectline5")

                    sbdNewCustomerEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpHeader") & vbCrLf & vbCrLf)
                    sbdNewCustomerEmailText.Append(GetGlobalResourceObject("Email", "EmailText_EmailAddress") & txtOrderCustomerEmail.Text & vbCrLf)
                    sbdNewCustomerEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerCode") & txtNewPassword.Text & vbCrLf & vbCrLf)
                    sbdNewCustomerEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter1") & CkartrisBLL.WebShopURL & "Customer.aspx" & GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter2"))
                    sbdNewCustomerEmailText.Replace("<br>", vbCrLf).Replace("<br />", vbCrLf)
                End If

                sbdBodyText.Insert(0, sbdBasketItems.ToString)

                BasketItems = _UC_BasketMain.GetBasketItems
                If Not (BasketItems Is Nothing) Then
                    Dim BasketItem As New BasketItem
                    'final check if basket items are still there
                    If BasketItems.Count = 0 Then
                        CkartrisFormatErrors.LogError("Basket items were lost in the middle of Checkout! Customer redirected to main Basket page." & vbCrLf & _
                                                      "Details: " & vbCrLf & "C_ID:" & IIf(Not String.IsNullOrEmpty(Trim(litOrderCustomerID.Text)), litOrderCustomerID.Text, " New User") & vbCrLf & _
                                                        "Payment Gateway: " & clsPlugin.GatewayName & vbCrLf & _
                                                        "Generated Body Text: " & sbdBodyText.ToString)
                        'Response.Redirect("~/Basket.aspx")
                    End If
                    For Each Item As Kartris.BasketItem In BasketItems
                        With Item
                            Dim strCustomControlName As String = ObjectConfigBLL.GetValue("K:product.customcontrolname", BasketItem.ProductID)
                            Dim strCustomText As String = ""

                            Dim sbdOptionText As New StringBuilder("")
                            If Not String.IsNullOrEmpty(.OptionText) Then sbdOptionText.Append(vbCrLf & " " & .OptionText().Replace("<br>", vbCrLf & " ").Replace("<br />", vbCrLf & " "))

                            sbdBasketItems.AppendLine( _
                                        GetItemEmailText(.Quantity & " x " & .ProductName, .VersionName & " (" & .CodeNumber & ")" & _
                                                         sbdOptionText.ToString, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))


                            If .CustomText <> "" AndAlso String.IsNullOrEmpty(strCustomControlName) Then
                                'Add custom text to mail
                                strCustomText = " [ " & .CustomText & " ]" & vbCrLf
                                sbdBasketItems.Append(strCustomText)
                            End If
                            If blnUseHTMLOrderEmail Then
                                'this line builds up the individual rows of the order contents table in the HTML email
                                sbdHTMLOrderBasket.AppendLine(GetHTMLEmailRowText(.Quantity & " x " & .ProductName, .VersionName & " (" & .CodeNumber & ") " & _
                                                         sbdOptionText.ToString & strCustomText, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
                            End If
                        End With
                    Next
                End If

                sbdBodyText.Insert(0, sbdBasketItems.ToString)
                If blnUseHTMLOrderEmail Then
                    'build up the table and the header tags, insert basket contents
                    sbdHTMLOrderContents.Insert(0, "<table id=""orderitems""><thead><tr>" & vbCrLf & _
                                                "<th class=""col1"">" & GetGlobalResourceObject("Kartris", "ContentText_Item") & "</th>" & vbCrLf & _
                                                "<th class=""col2"">" & GetGlobalResourceObject("Kartris", "ContentText_Price") & "</th></thead><tbody>" & vbCrLf &
                                                sbdHTMLOrderBasket.ToString)
                    'finally close the order contents HTML table
                    sbdHTMLOrderContents.Append("</tbody></table>")
                    'and append the order contents to the main HTML email
                    sbdHTMLOrderEmail.Replace("[ordercontents]", sbdHTMLOrderContents.ToString)
                End If

                'check if shippingdestinationid is initialized, if not then reload checkout page
                If Not blnBasketAllDigital Then
                    If _UC_BasketMain.ShippingDestinationID = 0 Or _UC_BasketMain.ShippingDestinationID = 0 Then
                        CkartrisFormatErrors.LogError("Basket was reset. Shipping info lost." & vbCrLf & "BasketView Shipping Destination ID: " & _
                                                      _UC_BasketMain.ShippingDestinationID & vbCrLf & "BasketSummary Shipping Destination ID: " & _
                                                      _UC_BasketMain.ShippingDestinationID)
                        Response.Redirect("~/Checkout.aspx")
                    End If
                End If


                'Create the order record
                O_ID = OrdersBLL.Add(C_ID, txtOrderCustomerEmail.Text, txtNewPassword.Text, _UC_BillingAddress.SelectedAddress, _
                                     _UC_ShippingAddress.SelectedAddress, chkSameShippingAsBilling.Checked, objBasket, _
                                      BasketItems, IIf(blnUseHTMLOrderEmail, sbdHTMLOrderEmail.ToString, sbdBodyText.ToString), clsPlugin.GatewayName, CInt(Session("LANG")), CUR_ID, _
                                     intGatewayCurrency, chkSendOrderUpdateEmail.Checked, _UC_BasketMain.SelectedShippingMethod, numGatewayTotalPrice, _
                                     IIf(String.IsNullOrEmpty(txtEUVAT.Text), "", txtEUVAT.Text), strPromotionDescription, txtOrderPONumber.Text, "")

                'Order Creation successful
                If O_ID > 0 Then
                    objOrder = New Kartris.Interfaces.objOrder
                    'Create the Order object and fill in the property values.
                    objOrder.ID = O_ID
                    objOrder.Description = GetGlobalResourceObject("Kartris", "Config_OrderDescription")
                    objOrder.Amount = numGatewayTotalPrice
                    objOrder.ShippingPrice = objBasket.ShippingPrice.IncTax
                    objOrder.OrderHandlingPrice = objBasket.OrderHandlingPrice.IncTax
                    objOrder.ShippingExTaxPrice = objBasket.ShippingPrice.ExTax
                    objOrder.Currency = CurrenciesBLL.CurrencyCode(CUR_ID)


                    If Not _blnAnonymousCheckout Then
                        With _UC_BillingAddress.SelectedAddress
                            objOrder.Billing.Name = .FullName
                            objOrder.Billing.StreetAddress = .StreetAddress
                            objOrder.Billing.TownCity = .TownCity
                            objOrder.Billing.CountyState = .County
                            objOrder.Billing.CountryName = .Country.Name
                            objOrder.Billing.Postcode = .Postcode
                            objOrder.Billing.Phone = .Phone
                            objOrder.Billing.CountryIsoCode = .Country.IsoCode
                            objOrder.Billing.Company = .Company
                        End With
                    End If

                    If Not blnBasketAllDigital Then
                        If chkSameShippingAsBilling.Checked Then
                            objOrder.SameShippingAsBilling = True
                        Else
                            With _UC_ShippingAddress.SelectedAddress
                                objOrder.Shipping.Name = .FullName
                                objOrder.Shipping.StreetAddress = .StreetAddress
                                objOrder.Shipping.TownCity = .TownCity
                                objOrder.Shipping.CountyState = .County
                                objOrder.Shipping.CountryName = .Country.Name
                                objOrder.Shipping.Postcode = .Postcode
                                objOrder.Shipping.Phone = .Phone
                                objOrder.Shipping.CountryIsoCode = .Country.IsoCode
                                objOrder.Shipping.Company = .Company
                            End With
                        End If
                    End If

                    objOrder.CustomerIPAddress = Request.ServerVariables("REMOTE_HOST")
                    objOrder.CustomerEmail = txtOrderCustomerEmail.Text

                    If Not Page.User.Identity.IsAuthenticated Then
                        If Membership.ValidateUser(txtOrderCustomerEmail.Text, txtNewPassword.Text) Then
                            FormsAuthentication.SetAuthCookie(txtOrderCustomerEmail.Text, True)
                        End If
                    End If
                    Try
                        Dim KartrisUser As KartrisMemberShipUser = Membership.GetUser(txtOrderCustomerEmail.Text)
                        If KartrisUser IsNot Nothing Then
                            objOrder.CustomerID = KartrisUser.ID
                        End If
                    Catch ex As Exception
                        objOrder.CustomerID = 0
                    End Try

                    objOrder.CustomerLanguage = LanguagesBLL.GetUICultureByLanguageID_s(CInt(Session("LANG")))


                    Dim strFromEmail As String = LanguagesBLL.GetEmailFrom(CInt(Session("LANG")))

                    'Send new account email to new customer
                    If KartSettingsManager.GetKartConfig("frontend.users.emailnewaccountdetails") = "y" And blnNewUser Then

                        Dim blnHTMLEmail As Boolean = KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y"
                        If blnHTMLEmail Then
                            Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("NewCustomerSignUp")
                            'build up the HTML email if template is found
                            If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                                strHTMLEmailText = strHTMLEmailText.Replace("[webshopurl]", WebShopURL)
                                strHTMLEmailText = strHTMLEmailText.Replace("[websitename]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                                strHTMLEmailText = strHTMLEmailText.Replace("[customeremail]", txtOrderCustomerEmail.Text)
                                strHTMLEmailText = strHTMLEmailText.Replace("[customerpassword]", txtNewPassword.Text)
                                sbdNewCustomerEmailText.Clear()
                                sbdNewCustomerEmailText.Append(strHTMLEmailText)
                            Else
                                blnHTMLEmail = False
                            End If
                        End If
                        SendEmail(strFromEmail, txtOrderCustomerEmail.Text, strSubject, sbdNewCustomerEmailText.ToString, , , , , blnHTMLEmail)
                    End If

                    objOrder.WebShopURL = WebShopURL() & "checkout.aspx"

                    'serialize order object and store it as a session value
                    Session("objOrder") = Payment.Serialize(objOrder)

                    'We have a serialization issue with the promotions
                    'it seems. We don't really need these in the saved
                    'basket XML, since when restoring an order in the
                    'back end for editing, we just pull the products and
                    'then apply promotions logic on those to determine
                    'what promotion to apply. But this is a bit of a hack;
                    'ideally we'll figure out what the serialization issue
                    'is with promotions.
                    objBasket.objPromotions.Clear()
                    objBasket.objPromotionsDiscount.Clear()

                    'update data field with serialized order and basket objects and selected shipping method id - this allows us to edit this order later if needed
                    OrdersBLL.DataUpdate(O_ID, Session("objOrder") & "|||" & Payment.Serialize(objBasket) & "|||" & _UC_BasketMain.SelectedShippingID)

                    If LCase(clsPlugin.GatewayType) = "local" Then
                        '---------------------------------------
                        'LOCAL PROCESS
                        'This includes gateways where card
                        'details are taken through the checkout
                        'page and relayed to the gateway, and
                        'also the 'PO offline' method where
                        'orders are made without payment, to be
                        'paid later offline.
                        '---------------------------------------
                        Dim blnResult As Boolean
                        Dim strBitcoinPaymentAddress As String = ""


                        If clsPlugin.GatewayName.ToLower = "po_offlinepayment" OrElse clsPlugin.GatewayName.ToLower = "bitcoin" Then
                            'PO orders don't need authorizing, they are
                            'effectively successful if placed as payment
                            'will come later
                            If clsPlugin.GatewayName.ToLower = "bitcoin" Then
                                strBitcoinPaymentAddress = clsPlugin.ProcessOrder(Payment.Serialize(objOrder))
                            End If

                            blnResult = True

                            'DISABLE CREDIT CARD BITS AS ITS NOT SUPPORTED WHEN CREATING ORDERS IN THE BACKEND YET
                            'Else
                            '---------------------------------------
                            'COLLECT CARD DETAILS
                            '---------------------------------------
                            'objOrder.CreditCardInfo.CardNumber = UC_CreditCardInput.CardNumber
                            'objOrder.CreditCardInfo.CardType = UC_CreditCardInput.CardType
                            'objOrder.CreditCardInfo.BeginMonth = Left(UC_CreditCardInput.StartDate, 2)
                            'objOrder.CreditCardInfo.BeginYear = Right(UC_CreditCardInput.StartDate, 2)
                            'objOrder.CreditCardInfo.IssueNumber = UC_CreditCardInput.CardIssueNumber
                            'objOrder.CreditCardInfo.CV2 = UC_CreditCardInput.CardSecurityNumber
                            'objOrder.CreditCardInfo.ExpiryMonth = Left(UC_CreditCardInput.ExpiryDate, 2)
                            'objOrder.CreditCardInfo.ExpiryYear = Right(UC_CreditCardInput.ExpiryDate, 2)

                            '---------------------------------------
                            'VALIDATE CREDIT CARD DETAILS
                            'Did the gateway return a 'sucess' result on validation?
                            '---------------------------------------
                            'blnResult = clsPlugin.ValidateCardOrder(Payment.Serialize(objOrder), Payment.Serialize(objBasket))
                        End If

                        '---------------------------------------
                        'SUCCESSFULLY PLACED ORDER
                        '---------------------------------------
                        If blnResult Then
                            'The transaction was authorized so update the order
                            If clsPlugin.CallbackSuccessful Or clsPlugin.GatewayName.ToLower = "po_offlinepayment" Then
                                If clsPlugin.GatewayName.ToLower = "po_offlinepayment" Then
                                    O_ID = objOrder.ID
                                Else
                                    'Get order ID that was passed back
                                    'with callback
                                    O_ID = clsPlugin.CallbackOrderID
                                End If

                                '---------------------------------------
                                'CREATE DATATABLE OF ORDER
                                '---------------------------------------
                                Dim tblOrder As DataTable = OrdersBLL.GetOrderByID(O_ID)

                                Dim O_CouponCode As String = ""
                                Dim O_TotalPriceGateway As Double = 0
                                Dim O_PurchaseOrderNo As String = ""
                                Dim O_WishListID As Integer = 0
                                Dim strCallBodyText As String = ""
                                Dim strBasketBLL As String = ""

                                '---------------------------------------
                                'DATA EXISTS FOR THIS ORDER ID
                                '---------------------------------------
                                If tblOrder.Rows.Count > 0 Then
                                    If tblOrder.Rows(0)("O_Sent") = 0 Then

                                        'Store order details
                                        O_CouponCode = CStr(FixNullFromDB(tblOrder.Rows(0)("O_CouponCode")))
                                        O_TotalPriceGateway = CDbl(tblOrder.Rows(0)("O_TotalPriceGateway"))
                                        O_PurchaseOrderNo = CStr(tblOrder.Rows(0)("O_PurchaseOrderNo"))
                                        O_WishListID = CInt(tblOrder.Rows(0)("O_WishListID"))
                                        strBasketBLL = CStr(tblOrder.Rows(0)("O_Status"))

                                        '---------------------------------------
                                        'FORMAT EMAIL TEXT
                                        'Mark offline orders clearly so they
                                        'are not mistaken for finished orders
                                        'where payment is already received and
                                        'goods need to be dispatched
                                        '---------------------------------------
                                        If clsPlugin.GatewayName.ToLower = "po_offlinepayment" Then
                                            Dim strPOline As String = ""

                                            strPOline += GetGlobalResourceObject("Invoice", "ContentText_PONumber") & ": " & O_PurchaseOrderNo & vbCrLf
                                            strPOline += vbCrLf

                                            If blnUseHTMLOrderEmail Then
                                                strCallBodyText = CStr(tblOrder.Rows(0)("O_Details"))
                                                strCallBodyText = strCallBodyText.Replace("[poofflinepaymentdetails]", strPOline.Replace(vbCrLf, "<br />"))
                                            Else
                                                strCallBodyText = strPOline & CStr(tblOrder.Rows(0)("O_Details"))
                                            End If
                                        Else
                                            strCallBodyText = CStr(tblOrder.Rows(0)("O_Details"))
                                            strCallBodyText = strCallBodyText.Replace("[poofflinepaymentdetails]", "")
                                        End If

                                        If clsPlugin.GatewayName.ToLower = "bitcoin" Then
                                            Dim strBitcoinline As String = ""

                                            strBitcoinline += GetGlobalResourceObject("Kartris", "ContentText_BitcoinPaymentDetails").ToString.Replace("[bitcoinpaymentaddress]", strBitcoinPaymentAddress)
                                            strBitcoinline += vbCrLf

                                            If blnUseHTMLOrderEmail Then
                                                strCallBodyText = strCallBodyText.Replace("[bitcoinpaymentdetails]", strBitcoinline)
                                            Else
                                                strCallBodyText += strBitcoinline.Replace("<br/>", vbCrLf) & strCallBodyText
                                            End If

                                        Else
                                            strCallBodyText = strCallBodyText.Replace("[bitcoinpaymentdetails]", "")
                                        End If
                                        '---------------------------------------
                                        'DETERMINE BEHAVIOUR OF STATUS BOXES
                                        'There are config settings to determine
                                        'whether the 'invoiced' and 'payment
                                        'received' status checkboxes on each
                                        'order are checked when a successful
                                        'payment is received
                                        '---------------------------------------
                                        Dim blnCheckInvoicedOnPayment As Boolean = KartSettingsManager.GetKartConfig("frontend.orders.checkinvoicedonpayment") = "y"
                                        Dim blnCheckReceivedOnPayment As Boolean = KartSettingsManager.GetKartConfig("frontend.orders.checkreceivedonpayment") = "y"

                                        '---------------------------------------
                                        'SET ORDER TIME
                                        'It uses the offset config setting in
                                        'case the server your site runs on is
                                        'not in your time zone
                                        '---------------------------------------
                                        Dim strOrderTimeText As String = GetGlobalResourceObject("Email", "EmailText_OrderTime") & " " & CkartrisDisplayFunctions.NowOffset
                                        If clsPlugin.GatewayName.ToLower = "po_offlinepayment" Or clsPlugin.GatewayName.ToLower = "bitcoin" Then
                                            blnCheckReceivedOnPayment = False
                                            blnCheckInvoicedOnPayment = False
                                        End If

                                        '---------------------------------------
                                        'UPDATE THE ORDER RECORD
                                        '---------------------------------------
                                        Dim intUpdateResult As Integer = OrdersBLL.CallbackUpdate(O_ID, clsPlugin.CallbackReferenceCode, CkartrisDisplayFunctions.NowOffset, True, _
                                                                                                  blnCheckInvoicedOnPayment, _
                                                                                                  blnCheckReceivedOnPayment, _
                                                                                                  strOrderTimeText, _
                                                                                                  O_CouponCode, O_WishListID, 0, 0, "", 0)
                                        'If intUpdateResult = O_ID Then
                                        Dim strCustomerEmailText As String = ""
                                        Dim strStoreEmailText As String = ""

                                        strCallBodyText = strCallBodyText.Replace("[orderid]", O_ID)

                                        '---------------------------------------
                                        'FORMAT CUSTOMER EMAIL TEXT
                                        '---------------------------------------
                                        If KartSettingsManager.GetKartConfig("frontend.checkout.ordertracking") <> "n" Then
                                            'Add order tracking information at the top
                                            If Not blnUseHTMLOrderEmail Then
                                                strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderLookup") & vbCrLf & vbCrLf & WebShopURL() & "Customer.aspx" & vbCrLf & vbCrLf
                                            End If
                                        End If
                                        'Don't need order tracking info
                                        strCustomerEmailText += strCallBodyText

                                        'Add in email header above that
                                        If Not blnUseHTMLOrderEmail Then
                                            strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderReceived") & vbCrLf & vbCrLf & _
                                                            GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & vbCrLf & _
                                                            strCustomerEmailText
                                        Else
                                            strCustomerEmailText = strCustomerEmailText.Replace("[storeowneremailheader]", "")
                                        End If


                                        '---------------------------------------
                                        'SEND CUSTOMER EMAIL
                                        '---------------------------------------
                                        If KartSettingsManager.GetKartConfig("frontend.orders.emailcustomer") <> "n" Then
                                            SendEmail(strFromEmail, txtOrderCustomerEmail.Text, GetGlobalResourceObject("Email", "Config_Subjectline") & " (#" & O_ID & ")", strCustomerEmailText, , , , , blnUseHTMLOrderEmail)
                                        End If

                                        '---------------------------------------
                                        'SEND STORE OWNER EMAIL
                                        '---------------------------------------
                                        If KartSettingsManager.GetKartConfig("frontend.orders.emailmerchant") <> "n" Then
                                            strStoreEmailText = GetGlobalResourceObject("Email", "EmailText_StoreEmailHeader") & vbCrLf & vbCrLf
                                            If Not blnUseHTMLOrderEmail Then
                                                strStoreEmailText += GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & strCallBodyText
                                            Else
                                                strStoreEmailText = strCallBodyText.Replace("[storeowneremailheader]", strStoreEmailText)
                                            End If
                                            SendEmail(strFromEmail, LanguagesBLL.GetEmailTo(1), GetGlobalResourceObject("Email", "Config_Subjectline2") & " (#" & O_ID & ")", strStoreEmailText, , , , , blnUseHTMLOrderEmail)
                                        End If

                                        'Send an order notification to Windows Store App if enabled
                                        PushKartrisNotification("o")
                                    End If
                                End If

                                '---------------------------------------
                                'ORDER UPDATED
                                'Clear object, transfer to the 
                                'CheckoutComplete.aspx page
                                '---------------------------------------
                                'Dim BasketObject As Kartris.Basket = New Kartris.Basket
                                BasketBLL.DeleteBasket()
                                Session("Basket") = Nothing
                                'Session("OrderDetails") = strCallBodyText
                                'Session("OrderID") = O_ID
                                Session("_NewPassword") = Nothing
                                Session("objOrder") = Nothing

                                'Server.Transfer("CheckoutComplete.aspx")
                                Response.Redirect("_ModifyOrderStatus.aspx?OrderID=" & O_ID & "&cloned=y")

                            Else
                                '---------------------------------------
                                'REDIRECT TO PAYPAL OR 3D-SECURE
                                '---------------------------------------
                                Dim strPostBackURL As String = clsPlugin.PostbackURL
                                Dim strCallbackMessage As String = clsPlugin.CallbackMessage
                                clsPlugin = Nothing
                                Session("_NewPassword") = Nothing
                                If String.IsNullOrEmpty(strCallbackMessage) Then
                                    Response.Redirect(strPostBackURL)
                                Else
                                    Session("_CallbackMessage") = strCallbackMessage
                                    Session("_PostBackURL") = strPostBackURL
                                    Session("OrderID") = O_ID
                                    lnkBtnSave.Text = "Saved! Order ID: " & O_ID
                                    lnkBtnSave.Enabled = False
                                    updEditOrder.Update()
                                End If

                            End If

                            'Else
                            '---------------------------------------
                            'ERROR BACK FROM CREDIT CARD GATEWAY
                            'Show error in popup
                            '---------------------------------------
                            '    UC_PopUpErrors.SetTextMessage = clsPlugin.CallbackMessage
                            '    UC_PopUpErrors.SetTitle = GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors")
                            '    UC_PopUpErrors.ShowPopup()
                            '    mvwCheckout.ActiveViewIndex = 1
                        End If

                        clsPlugin = Nothing
                    Else
                        '---------------------------------------
                        'REMOTE PAYMENT PROCESS
                        '---------------------------------------
                        Session("BasketObject") = objBasket
                        Session("GatewayName") = strGatewayName
                        Session("_NewPassword") = Nothing
                        clsPlugin = Nothing


                        '---------------------------------------
                        'UPDATE THE ORDER RECORD
                        '---------------------------------------
                        Dim intUpdateResult As Integer = OrdersBLL.CallbackUpdate(O_ID, "", CkartrisDisplayFunctions.NowOffset, True, _
                                                                                  True, _
                                                                                  False, _
                                                                                  Payment.Serialize(objBasket), _
                                                                                  objBasket.CouponCode, 0, 0, 0, "", 0)

                        '---------------------------------------
                        'FORMAT FORM TO POST TO REMOTE GATEWAY
                        '---------------------------------------
                        Session("OrderID") = O_ID
                        Session("Basket") = Nothing
                        Session("BasketObject") = Nothing
                        BasketBLL.DeleteBasket()
                        Response.Redirect("_OrdersList.aspx?callmode=payment")
                    End If
                End If
            End If
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
            Dim objBasket As kartris.Basket = _UC_BasketMain.GetBasket
            Dim sessionID As Long = Session("SessionID")
            BasketBLL.AddNewBasketValue(objBasket.BasketItems, BasketBLL.BASKET_PARENTS.BASKET, sessionID, numVersionID, 1, "", strOptions)
            LoadBasket()
        End If
    End Sub

    ''' <summary>
    ''' Billing country changed, refresh
    ''' shipping methods
    ''' </summary>
    Protected Sub BillingCountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs) Handles _UC_BillingAddress.CountryUpdated
        If chkSameShippingAsBilling.Checked Then RefreshShippingInfo("billing")
    End Sub
    ''' <summary>
    ''' Shipping country updated, refresh
    ''' shipping methods
    ''' </summary>
    Protected Sub ShippingCountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs) Handles _UC_ShippingAddress.CountryUpdated
        If Not chkSameShippingAsBilling.Checked And _UC_ShippingAddress.SelectedAddress IsNot Nothing Then RefreshShippingInfo("shipping")
        RefreshShippingInfo("shipping")
    End Sub
End Class
