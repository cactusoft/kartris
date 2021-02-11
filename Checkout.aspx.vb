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
Imports System.Data
Imports System.Data.Common
Imports System.Data.SqlClient
Imports System.Web.Configuration
Imports KartSettingsManager
Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports MailChimp.Net.Models
Imports System.Threading.Tasks
Imports Braintree
Imports PaymentsBLL

''' <summary>
''' Checkout - this page handles users checking out,
''' the subsequent confirmation page, and then
''' formats the form which is posted to payment
''' gateways to initiate a payment.
''' </summary>
Partial Class _Checkout
    Inherits PageBaseClass
    Private _SelectedPaymentMethod As String = ""
    Private _blnAnonymousCheckout As Boolean = False

    ''' <summary>
    ''' Page Load
    ''' </summary>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack Then

            '---------------------------------------
            'SET PAGE TITLE
            '---------------------------------------
            Page.Title = GetLocalResourceObject("PageTitle_CheckOut") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

            '---------------------------------------
            'GET LIST OF PAYMENT GATEWAYS
            'This comes from a config setting that
            'is populated dynamically from the
            'available payment gateways that are
            'turned on in the 'plugins' folder.
            '---------------------------------------
            Dim strPaymentMethods As String = GetKartConfig("frontend.payment.gatewayslist")

            '---------------------------------------
            'CHECK IF USER IS LOGGED IN
            '---------------------------------------
            Dim blnAuthorized As Boolean = False
            If CurrentLoggedUser IsNot Nothing Then
                blnAuthorized = CurrentLoggedUser.isAuthorized
            End If

            '---------------------------------------
            'SHOW CUSTOMER COMMENTS BOX?
            '---------------------------------------
            If GetKartConfig("frontend.checkout.comments.enabled") = "n" Then
                phdCustomerComments.Visible = False
            End If

            '=======================================
            'PAYMENT GATEWAYS
            'Paypal, SagePay, etc.
            '=======================================
            Dim arrPaymentsMethods As String() = Split(strPaymentMethods, ",")

            'If the order value inclusive of everything is zero, we don't want
            'to bill the customer. Instead we activate the PO method, even if
            'this user is not authorized to use it. We hide the other payment
            'methods.
            Dim objBasket As Kartris.Basket = Session("Basket")
            Dim blnOrderIsFree As Boolean = False 'Disable, suspect this might misfire (objBasket.FinalPriceIncTax = 0)

            'This line below looks a bit more complicated than it should. We have seen
            'some cases where orders slip by without payment, when they should not. It doesn't seem
            'to be possible, but apparently has happened in some cases. The code below is an idea to try
            'to stop this, the assumption that if the finalprice shows as zero because of some glitch,
            'maybe the first item in the basket would have a zero name too. Or that maybe it will trigger
            'an error. Only time will tell. If this causes problems, comment it out and just stop accepting
            'free orders (most sites don't do this, but some use it to give promotions away).
            Try
                blnOrderIsFree = (objBasket.FinalPriceIncTax = 0 And objBasket.BasketItems.Item(0).Name <> "")
            Catch ex As Exception
                'order stays as not free
            End Try

            If blnOrderIsFree Then
                'Add the PO option with name 'FREE' and hide payment selection
                'The 'False' flag indicates this is not for authorized users
                'only. PO normally is, but here we are using this for all users
                'if total price is zero.
                ddlPaymentGateways.Items.Add(New ListItem("FREE", "po_offlinepayment" & "::False"))
                updPaymentMethods.Visible = False
                valPaymentGateways.Enabled = False
            Else
                'Order isn't free. Load up the payment gateways.
                Try
                    'Add the default 'Please select' line at top of menu
                    ddlPaymentGateways.Items.Add(New ListItem(GetGlobalResourceObject("Kartris", "ContentText_DropdownSelectDefault"), "::False"))

                    '---------------------------------------
                    'LOOP THROUGH PAYMENT METHODS
                    '---------------------------------------
                    For Each strGatewayEntry As String In arrPaymentsMethods

                        'The config setting stores info for each gateway,
                        'separated by double colons (::)
                        Dim arrGateway As String() = Split(strGatewayEntry, "::")

                        '---------------------------------------
                        'CHECK PAYMENT GATEWAY DATA VALID
                        'We shoud have 5 bits of data (in a zero
                        'based array).
                        '---------------------------------------
                        If UBound(arrGateway) = 4 Then
                            Dim blnOkToAdd As Boolean = True

                            'Is this a payment gateway? (value='p')
                            If arrGateway(4) = "p" Then

                                'Is this only available for 'authorized'
                                'customers? For offline (PO) orders in
                                'particular, you probably only want 
                                'trusted customers to be able to use it.
                                'To do this, set the gateway's settings
                                'to 'Authorized Only' and then edit any
                                'customer you want to be able to use this
                                'payment system to 'Authorize' them.
                                If LCase(arrGateway(2)) = "true" Then
                                    blnOkToAdd = blnAuthorized
                                End If

                                '---------------------------------------
                                'CHECK STATUS OF GATEWAY
                                'There are four possibilities
                                'On, Off, Test, Fake
                                'The last two are for use when testing
                                'a payment system. 'Test' will pass an
                                'order through using the gateways test
                                'mode, if available. 'Fake' bypasses 
                                'the payment gateway completely, and
                                'just simulates the callback the gateway
                                'should make to your callback page.
                                'For more info, see the PDF User Guide.

                                'Test/Fake are only available if you are
                                'logged in as a back end admin. This
                                'means you can setup and test a new
                                'payment system on a live site without
                                'it being visible to customers.
                                '---------------------------------------
                                If LCase(arrGateway(1)) = "test" Or LCase(arrGateway(1)) = "fake" Then
                                    blnOkToAdd = HttpSecureCookie.IsBackendAuthenticated

                                    'Gateway is turned off, don't add it
                                    'to the list.
                                ElseIf LCase(arrGateway(1)) = "off" Then
                                    blnOkToAdd = False
                                End If
                            Else

                                'Not a payment system... shipping plugins for 
                                'USPS, UPS, etc. are stored in the same
                                'plugins folder, but we don't want them
                                'available as a choice of payment system!
                                blnOkToAdd = False
                            End If

                            'This is a payment system and is available to 
                            'this customer
                            If blnOkToAdd Then
                                Dim strGatewayName As String = arrGateway(0)

                                'Get the 'friendly' name of the payment system from 
                                'the gateway's config. Note you can have friendly
                                'names for multiple languages in the config file:

                                '<setting name="FriendlyName(en-GB)" serializeAs="String">
                                '<value>Offline payment</value>
                                '</setting>
                                Dim strFriendlyName As String = Payment.GetPluginFriendlyName(strGatewayName)

                                'If no friendly name, use the Gateway's default name
                                '(Paypal, SagePay, etc.)
                                'Friendly name is better, because 'SagePay' probably means
                                'less to a customer than 'Pay with Credit Card'
                                If Interfaces.Utils.TrimWhiteSpace(strFriendlyName) <> "" Then
                                    ddlPaymentGateways.Items.Add(New ListItem(strFriendlyName, arrGateway(0).ToString & "::" & arrGateway(3).ToString))
                                Else
                                    ddlPaymentGateways.Items.Add(New ListItem(strGatewayName, arrGateway(0).ToString & "::" & arrGateway(3).ToString))
                                End If

                                If strGatewayName.ToLower = "po_offlinepayment" Then

                                    'Default name for PO (offline payment)
                                    strGatewayName = GetGlobalResourceObject("Checkout", "ContentText_Po")
                                End If

                            End If
                        Else
                            'Didn't have the four values needed for payment
                            'gateway config
                            Throw New Exception("Invalid gatewaylist config setting!")
                        End If

                    Next

                    '---------------------------------------
                    'SHOW PAYMENT METHODS DROPDOWN
                    'Note that the count of gateways we get
                    'from the dropdown menu, but that has
                    'an extra line 'Please select', so the
                    'count will be 1 higher than the actual
                    'number of gateways. Hence '1' means no
                    'payment systems, '2' means there is one
                    'and so on.
                    '---------------------------------------

                    'If there are no valid payment systems (Count = 1),
                    'we log an exception.
                    If ddlPaymentGateways.Items.Count = 1 Then
                        Throw New Exception("No valid payment gateways")

                        'If there is one (Count = 2) then we don't need to
                        'show the user a choice, since there is
                        'only one to choose from. So we default to
                        'that and hide the validators and dropdown.
                    ElseIf ddlPaymentGateways.Items.Count = 2 Then
                        Dim arrSelectedGateway() As String = Split(ddlPaymentGateways.Items(1).Value, "::")
                        _SelectedPaymentMethod = arrSelectedGateway(0)
                        _blnAnonymousCheckout = CBool(arrSelectedGateway(1))
                        ddlPaymentGateways.SelectedValue = ddlPaymentGateways.Items(1).Value
                        phdPaymentMethods.Visible = False
                        valPaymentGateways.Enabled = False 'disable validation just to be sure
                        If _SelectedPaymentMethod = "PO_OfflinePayment" Then phdPONumber.Visible = True Else phdPONumber.Visible = False

                        'Store value in hidden field. We hope this will be more
                        'robust if page times out
                        litPaymentGatewayHidden.Text = _SelectedPaymentMethod
                    Else
                        'More than one payment method available,
                        'show dropdown and give user the choice.
                        'Hide the PO number field.
                        phdPaymentMethods.Visible = True
                        'txtPurchaseOrderNo.Style.Item("display") = "none"
                        'phdPONumber.Style.Item("display") = "none"
                        phdPONumber.Visible = False
                    End If

                    '---------------------------------------
                    'ERROR LOADING PAYMENT GATEWAYS LIST
                    '---------------------------------------
                Catch ex As Exception
                    Throw New Exception("Error loading payment gateway list")
                End Try
            End If


            '---------------------------------------
            'CLEAR ADDRESS CONTROLS
            '---------------------------------------
            UC_BillingAddress.Clear()
            UC_ShippingAddress.Clear()

            '---------------------------------------
            'CUSTOMER OPTION TO SELECT
            'EMAIL UPDATES OF ORDER STATUS?
            '---------------------------------------
            If GetKartConfig("frontend.checkout.ordertracking") <> "n" And GetKartConfig("backend.orders.emailupdates") <> "n" Then
                phdOrderEmails.Visible = True
            Else
                phdOrderEmails.Visible = False
                chkOrderEmails.Checked = False
            End If

            '---------------------------------------
            'SHOW MAILING LIST OPT-IN BOX?
            '---------------------------------------
            If GetKartConfig("frontend.users.mailinglist.enabled") <> "n" Then
                phdMailingList.Visible = True
                chkMailingList.Checked = False
            Else
                phdMailingList.Visible = False
                chkMailingList.Checked = False
            End If

            '---------------------------------------
            'SHOW SAVE-BASKET OPTION?
            'Customers can save the basket if they
            'want to make the same order again in
            'future
            '---------------------------------------
            If GetKartConfig("frontend.checkout.savebasket") <> "n" Then phdSaveBasket.Visible = True Else phdSaveBasket.Visible = False

            '---------------------------------------
            'SHOW Ts & Cs CHECKBOX CONFIRMATION?
            '---------------------------------------
            If GetKartConfig("frontend.checkout.termsandconditions") <> "n" Then phdTermsAndConditions.Visible = True Else phdTermsAndConditions.Visible = False
            ConfigureAddressFields()
        Else



        End If

        '=======================================
        'SHOW LOGIN BOX
        'If the user is not logged in, or has
        'not proceeded through first steps of
        'creating new user, then we show the
        'login / new user options.
        'The 'proceed' button is hidden.
        '=======================================
        If Not (UC_KartrisLogin.Cleared Or User.Identity.IsAuthenticated) Then

            'Show login box
            mvwCheckout.ActiveViewIndex = 0
            btnProceed.Visible = False
        Else

            'Show checkout form if not already set to
            'go to confirmation page
            If mvwCheckout.ActiveViewIndex <> 2 Then mvwCheckout.ActiveViewIndex = 1 Else valSummary.Enabled = False
            btnProceed.Visible = True
        End If

        '=======================================
        'SETUP CHECKOUT FORM
        'Runs if user is logged in already
        '=======================================
        If Not IsNothing(CurrentLoggedUser) Then

            'Show checkout form if not already set to
            'go to confirmation page
            If mvwCheckout.ActiveViewIndex <> 2 Then mvwCheckout.ActiveViewIndex = 1 Else valSummary.Enabled = False

            'Fresh form arrival
            If Not Page.IsPostBack Then

                'Set up first user address (billing)
                Dim lstUsrAddresses As Collections.Generic.List(Of KartrisClasses.Address) = Nothing

                '---------------------------------------
                'BILLING ADDRESS
                '---------------------------------------
                If UC_BillingAddress.Addresses Is Nothing Then

                    'Find all addresses in this user's account
                    lstUsrAddresses = KartrisClasses.Address.GetAll(CurrentLoggedUser.ID)

                    'Populate dropdown by filtering billing/universal addresses
                    UC_BillingAddress.Addresses = lstUsrAddresses.FindAll(Function(p) p.Type = "b" Or p.Type = "u")
                End If

                '---------------------------------------
                'SHIPPING ADDRESS
                '---------------------------------------
                If UC_ShippingAddress.Addresses Is Nothing Then

                    'Find all addresses in this user's account
                    If lstUsrAddresses Is Nothing Then lstUsrAddresses = KartrisClasses.Address.GetAll(CurrentLoggedUser.ID)

                    'Populate dropdown by filtering shipping/universal addresses
                    UC_ShippingAddress.Addresses = lstUsrAddresses.FindAll(Function(ShippingAdd) ShippingAdd.Type = "s" Or ShippingAdd.Type = "u")
                End If

                '---------------------------------------
                'SHIPPING/BILLING ADDRESS NOT SAME
                '---------------------------------------

                If (Not CurrentLoggedUser.DefaultBillingAddressID = CurrentLoggedUser.DefaultShippingAddressID) Then
                    If Not _blnAnonymousCheckout Then
                        chkSameShippingAsBilling.Checked = False
                    Else
                        chkSameShippingAsBilling.Checked = True
                    End If
                Else
                    chkSameShippingAsBilling.Checked = False
                End If

                If UC_BasketSummary.GetBasket.AllDigital Then
                    pnlShippingAddress.Visible = False
                    UC_ShippingAddress.Visible = False
                Else
                    If Not chkSameShippingAsBilling.Checked Then
                        'Show shipping address block
                        pnlShippingAddress.Visible = True
                        UC_ShippingAddress.Visible = True
                    Else
                        pnlShippingAddress.Visible = False
                        UC_ShippingAddress.Visible = False
                    End If
                End If

                '---------------------------------------
                'SELECT DEFAULT ADDRESSES
                '---------------------------------------
                If UC_BillingAddress.SelectedID = 0 Then
                    UC_BillingAddress.SelectedID = CurrentLoggedUser.DefaultBillingAddressID
                End If
                If UC_ShippingAddress.SelectedID = 0 Then
                    UC_ShippingAddress.SelectedID = CurrentLoggedUser.DefaultShippingAddressID
                End If
            End If
        End If

    End Sub

    ''' <summary>
    ''' Page Load Complete
    ''' </summary>
    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        'Fails for new users
        If Not Me.IsPostBack Then
            Try
                If txtEUVAT.Text = "" And phdEUVAT.Visible = True Then
                    txtEUVAT.Text = UsersBLL.GetCustomerEUVATNumber(CurrentLoggedUser.ID)
                End If
            Catch ex As Exception
                'probably a new user or don't need vate
            End Try
        End If

        '---------------------------------------
        'ZERO ITEMS IN BASKET!
        '---------------------------------------
        If UC_BasketView.GetBasketItems.Count = 0 Then Response.Redirect("~/Basket.aspx")

        '---------------------------------------
        'CHECK MINIMUM ORDER VALUE MET
        '---------------------------------------
        Dim numMinOrderValue As Double = CDbl(GetKartConfig("frontend.orders.minordervalue"))

        If numMinOrderValue > 0 Then

            If GetKartConfig("general.tax.pricesinctax") = "y" Then

                'Prices include tax
                If UC_BasketView.GetBasket.TotalIncTax < CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), numMinOrderValue) Then
                    Response.Redirect("~/Basket.aspx?error=minimum")
                End If
            Else
                If UC_BasketView.GetBasket.TotalExTax < CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), numMinOrderValue) Then
                    Response.Redirect("~/Basket.aspx?error=minimum")
                End If
            End If
        End If

        'Just to be sure we get shipping price, have
        'had issues where sometimes a single shipping method
        'doesn't trigger lookup for shipping price
        'UC_BasketView.RefreshShippingMethods()
        'If Not Me.IsPostBack() Then
        '    txtEUVAT_AutoPostback()
        'End If

    End Sub

    ''' <summary>
    ''' Payment Method Changed, refresh
    ''' </summary>
    Protected Sub ddlPaymentGateways_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlPaymentGateways.SelectedIndexChanged
        Dim arrSelectedGateway() As String = Split(ddlPaymentGateways.SelectedItem.Value, "::")
        _SelectedPaymentMethod = arrSelectedGateway(0)
        _blnAnonymousCheckout = CBool(arrSelectedGateway(1))
        ConfigureAddressFields(True)

        'Store value in hidden field. We hope this will be more
        'robust if page times out
        litPaymentGatewayHidden.Text = _SelectedPaymentMethod

        'Decide whether to show PO field
        If _SelectedPaymentMethod = "PO_OfflinePayment" Then
            phdPONumber.Visible = True
        Else
            phdPONumber.Visible = False
            txtPurchaseOrderNo.Text = ""
            litPONumberText.Text = ""
        End If

    End Sub

    ''' <summary>
    ''' Show or Hide Address Fields depending on the selected payment gateway and basket contents
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub ConfigureAddressFields(Optional ByVal blnUpdateAddressPanel As Boolean = False)
        If _blnAnonymousCheckout Then
            chkSameShippingAsBilling.Visible = False
            chkSameShippingAsBilling.Checked = False
            lblchkSameShipping.Visible = False
            UC_BillingAddress.Visible = False
        Else
            chkSameShippingAsBilling.Visible = True
            'chkSameShippingAsBilling.Checked = True
            lblchkSameShipping.Visible = True
            UC_BillingAddress.Visible = True
        End If

        If UC_BasketSummary.GetBasket.AllDigital Then
            pnlShippingAddress.Visible = False
            UC_ShippingAddress.Visible = False
            chkSameShippingAsBilling.Visible = False
            lblchkSameShipping.Visible = False
        Else
            If Not _blnAnonymousCheckout Then
                chkSameShippingAsBilling.Visible = True
                lblchkSameShipping.Visible = True
                If chkSameShippingAsBilling.Checked Then
                    pnlShippingAddress.Visible = False
                    UC_ShippingAddress.Visible = False
                Else
                    pnlShippingAddress.Visible = True
                    UC_ShippingAddress.Visible = True
                End If
            Else
                pnlShippingAddress.Visible = True
                UC_ShippingAddress.Visible = True
            End If

        End If
        If blnUpdateAddressPanel Then updAddresses.Update()
    End Sub

    ''' <summary>
    ''' Billing country changed, refresh
    ''' shipping methods
    ''' </summary>
    Protected Sub BillingCountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs) Handles UC_BillingAddress.CountryUpdated
        RefreshShippingMethods("billing")
    End Sub

    ''' <summary>
    ''' Shipping country updated, refresh
    ''' shipping methods
    ''' </summary>
    Protected Sub ShippingCountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs) Handles UC_ShippingAddress.CountryUpdated
        'If Not chkSameShippingAsBilling.Checked And UC_ShippingAddress.SelectedAddress IsNot Nothing Then RefreshShippingMethods()
        RefreshShippingMethods()
    End Sub

    ''' <summary>
    ''' The checkbox for 'same shipping
    ''' as billing address' has been 
    ''' changed (checked/unchecked))
    ''' </summary>
    Protected Sub chkSameShippingAsBilling_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkSameShippingAsBilling.CheckedChanged
        If chkSameShippingAsBilling.Checked Then
            pnlShippingAddress.Visible = False
            UC_ShippingAddress.Visible = False
            RefreshShippingMethods("billing")
        Else
            pnlShippingAddress.Visible = True
            UC_ShippingAddress.Visible = True
            RefreshShippingMethods("shipping")
        End If
        updAddresses.Update()
    End Sub

    ''' <summary>
    ''' Refresh shipping methods
    ''' </summary>
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

        '=======================================
        'EU VAT and EORI fields
        'New brexit-related changes

        '=======================================
        Dim adrShipping As KartrisClasses.Address = Nothing
        If chkSameShippingAsBilling.Checked Then
            'Shipping address same as billing
            'so use billing address (as shipping
            'address)
            If UC_BillingAddress.SelectedID > 0 Then
                adrShipping = UC_BillingAddress.Addresses.Find(Function(Add) Add.ID = UC_BillingAddress.SelectedID)
            ElseIf numShippingDestinationID > 0 Then
                adrShipping = UC_BillingAddress.SelectedAddress
            End If
        Else
            'Must use shipping address
            If UC_ShippingAddress.SelectedID > 0 Then
                adrShipping = UC_ShippingAddress.Addresses.Find(Function(Add) Add.ID = UC_ShippingAddress.SelectedID)
            ElseIf numShippingDestinationID > 0 Then
                adrShipping = UC_ShippingAddress.SelectedAddress
            End If
        End If

        'Two new functions determine whether to show EU VAT and EORI fields at checkout
        Try
            phdEUVAT.Visible = CkartrisRegionalSettings.ShowEUVATField(UCase(GetKartConfig("general.tax.euvatcountry")), adrShipping.Country.IsoCode, adrShipping.Country.D_Tax, adrShipping.Country.TaxExtra, GetKartConfig("general.tax.domesticshowfield") = "y")
        Catch ex As Exception
            phdEUVAT.Visible = False
        End Try
        Try
            phdEORI.Visible = CkartrisRegionalSettings.ShowEORIField(adrShipping.Country.D_Tax, adrShipping.Country.TaxExtra)
        Catch ex As Exception
            phdEORI.Visible = False
        End Try


        If phdEUVAT.Visible Then
            'Show VAT country ISO code in front of field
            litMSCode.Text = adrShipping.Country.IsoCode

            'EU uses 'EL' for Greece, and not the 
            'ISO code 'GR', so we need to adjust for this
            If litMSCode.Text = "GR" Then litMSCode.Text = "EL"

            'Try to fill EU number
            Try
                txtEUVAT.Text = UsersBLL.GetCustomerEUVATNumber(CurrentLoggedUser.ID)
            Catch ex As Exception

            End Try
        Else
            'Country of user is same as store
            'Hide VAT box
            txtEUVAT.Text = ""
            Call txtEUVAT_AutoPostback()
        End If

        If phdEORI.Visible Then
            'Try to fill EU number
            Try
                txtEORI.Text = ObjectConfigBLL.GetValue("K:user.eori", CurrentLoggedUser.ID)
            Catch ex As Exception

            End Try
        End If

        '=======================================================
        'SET SHIPPING DETAILS FROM ADDRESS CONTROL
        '=======================================================
        Dim objShippingDetails As New Interfaces.objShippingDetails
        Try
            With objShippingDetails.RecipientsAddress
                If chkSameShippingAsBilling.Checked Then
                    .Postcode = UC_BillingAddress.SelectedAddress.Postcode
                    .CountryID = UC_BillingAddress.SelectedAddress.Country.CountryId
                    .CountryIsoCode = UC_BillingAddress.SelectedAddress.Country.IsoCode
                    .CountryName = UC_BillingAddress.SelectedAddress.Country.Name
                Else
                    .Postcode = UC_ShippingAddress.SelectedAddress.Postcode
                    .CountryID = UC_ShippingAddress.SelectedAddress.Country.CountryId
                    .CountryIsoCode = UC_ShippingAddress.SelectedAddress.Country.IsoCode
                    .CountryName = UC_ShippingAddress.SelectedAddress.Country.Name
                End If
            End With
        Catch ex As Exception

        End Try

        '=======================================
        'UPDATE BASKET WITH SHIPPING DETAILS
        '=======================================
        UC_BasketView.ShippingDetails = objShippingDetails
        UC_BasketSummary.ShippingDetails = objShippingDetails

        UC_BasketView.ShippingDestinationID = numShippingDestinationID
        UC_BasketSummary.ShippingDestinationID = numShippingDestinationID

        UC_BasketView.RefreshShippingMethods()

    End Sub

    ''' <summary>
    ''' Proceed button clicked, moves us
    ''' to next stage
    ''' </summary>
    Protected Sub btnProceed_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnProceed.Click
        If String.IsNullOrEmpty(_SelectedPaymentMethod) Then
            Dim arrSelectedGateway() As String = Split(ddlPaymentGateways.SelectedItem.Value, "::")
            _SelectedPaymentMethod = arrSelectedGateway(0)
            _blnAnonymousCheckout = CBool(arrSelectedGateway(1))
        End If

        Dim clsPlugin As Kartris.Interfaces.PaymentGateway = Nothing
        Dim strGatewayName As String = _SelectedPaymentMethod

        If mvwCheckout.ActiveViewIndex > "0" Then
            clsPlugin = Payment.PPLoader(strGatewayName)
            If LCase(clsPlugin.Status) = "test" Or LCase(clsPlugin.Status) = "fake" Then litFakeOrTest.Visible = True Else litFakeOrTest.Visible = False
        End If

        Dim blnBasketAllDigital As Boolean = UC_BasketSummary.GetBasket.AllDigital

        If mvwCheckout.ActiveViewIndex = "1" Then
            '=======================================
            'ADDRESS DETAILS ENTERED,
            'SHIPPING METHODS SELECTED
            'COMMENTS ADDED
            '=======================================
            litOtherErrors.Text = ""

            'Handle EU VAT number validation
            Dim blnValidEUVAT As Boolean
            If txtEUVAT.Visible And Not String.IsNullOrEmpty(txtEUVAT.Text) Then
                txtEUVAT_AutoPostback()
                blnValidEUVAT = Session("blnEUVATValidated")
                If Not blnValidEUVAT Then litOtherErrors.Text = GetGlobalResourceObject("Kartris", "ContentText_VATNumberInvalid")
            Else
                blnValidEUVAT = True
            End If

            'Validation - no shipping selected
            If Not UC_BasketView.GetBasket.AllFreeShipping And UC_BasketView.SelectedShippingID = 0 Then
                litOtherErrors.Text += GetGlobalResourceObject("Checkout", "ContentText_NoShippingSelected") & "<br />"
            End If

            If Not _blnAnonymousCheckout Then
                'Validation - no billing address
                If UC_BillingAddress.SelectedAddress Is Nothing Then
                    litOtherErrors.Text += GetGlobalResourceObject("Checkout", "ContentText_NoBillingAddress") & "<br />"
                    blnValidEUVAT = False
                End If
            End If

            If Not blnBasketAllDigital Then
                'Validation - no shipping address
                If Not chkSameShippingAsBilling.Checked Then
                    If UC_ShippingAddress.SelectedAddress Is Nothing Then
                        litOtherErrors.Text += GetGlobalResourceObject("Checkout", "ContentText_NoShippingAddress") & "<br />"
                        blnValidEUVAT = False
                    End If
                End If
            End If

            'Validation - Ts and Cs agreement not checked
            If GetKartConfig("frontend.checkout.termsandconditions") <> "n" Then
                If Not chkTermsAndConditions.Checked Then
                    litOtherErrors.Text += GetGlobalResourceObject("Checkout", "ContentText_ErrorTermsNotChecked") & "<br />"
                    blnValidEUVAT = False
                End If
            End If

            '=======================================
            'PAGE IS VALID
            'Set up confirmation page
            '=======================================
            If Page.IsValid And (UC_BasketView.SelectedShippingID <> 0 Or UC_BasketView.GetBasket.AllFreeShipping) And blnValidEUVAT Then

                Dim isOk As Boolean = True

                'Set billing address to one selected by user
                'Set shipping address to this, or to selected shipping one, depending on same-shipping checkbox
                If Not blnBasketAllDigital Then
                    If Not _blnAnonymousCheckout AndAlso UC_BillingAddress.SelectedAddress IsNot Nothing Then
                        If chkSameShippingAsBilling.Checked Then
                            UC_Shipping.Address = UC_BillingAddress.SelectedAddress
                        Else
                            UC_Shipping.Address = UC_ShippingAddress.SelectedAddress
                        End If
                    Else
                        UC_Shipping.Address = UC_ShippingAddress.SelectedAddress
                    End If
                Else
                    If Not _blnAnonymousCheckout Then
                        'For downloable orders, we don't really need shipping, but
                        'payment systems require it. Therefore, we set it to same
                        'as billing and also check the box (which is hidden) to say
                        'we're using same shipping address as for billing
                        UC_Shipping.Address = UC_BillingAddress.SelectedAddress
                        chkSameShippingAsBilling.Checked = True
                    End If
                End If

                If _blnAnonymousCheckout Then
                    UC_Billing.Visible = False
                    litBillingDetails.Visible = False
                Else
                    UC_Billing.Address = UC_BillingAddress.SelectedAddress
                    UC_Billing.Visible = True
                    litBillingDetails.Visible = True
                End If

                'Hide shipping address from being visible if all items in order
                'are downloadable
                If blnBasketAllDigital Then
                    UC_Shipping.Visible = False
                    litShippingDetails.Visible = False
                Else
                    UC_Shipping.Visible = True
                    litShippingDetails.Visible = True
                End If


                'Show payment method on confirmation page
                If _SelectedPaymentMethod.ToLower = "po_offlinepayment" Then
                    'Change 'po_offlinepayment' to language string for this payment type
                    litPaymentMethod.Text = Server.HtmlEncode(GetGlobalResourceObject("Checkout", "ContentText_Po"))
                    litPONumberText.Text = GetGlobalResourceObject("Invoice", "ContentText_PONumber") & ": <strong>" & txtPurchaseOrderNo.Text & "</strong><br/>"
                Else
                    'try to get the friendly name - use the payment gateway name if its blank
                    Dim strFriendlyName As String = Payment.GetPluginFriendlyName(strGatewayName)
                    If Interfaces.Utils.TrimWhiteSpace(strFriendlyName) <> "" Then
                        litPaymentMethod.Text = strFriendlyName
                    Else
                        litPaymentMethod.Text = _SelectedPaymentMethod
                    End If
                End If

                'Show VAT number
                If txtEUVAT.Text <> "" Then
                    litVATNumberText.Text = GetGlobalResourceObject("Invoice", "FormLabel_CardholderEUVatNum") & ": <strong>" & txtEUVAT.Text & "</strong><br/>"
                End If

                'Show VAT number
                If txtEORI.Text <> "" Then
                    litEORINumberText.Text = "EORI: <strong>" & txtEORI.Text & "</strong><br/>"
                End If

                'Show whether mailing list opted into
                If Not chkMailingList.Checked Then litMailingListYes.Visible = False Else litMailingListYes.Visible = True

                'Show whether 'receive order updates' was checked
                If Not chkOrderEmails.Checked Then litOrderEmailsYes2.Visible = False Else litOrderEmailsYes2.Visible = True

                'Show whether 'save basket' was checked
                If Not chkSaveBasket.Checked Then litSaveBasketYes.Visible = False Else litSaveBasketYes.Visible = True

                'Show comments (HTMLencoded for XSS protection)
                If Trim(txtComments.Text) <> "" Then
                    lblComments.Text = Server.HtmlEncode(CkartrisDisplayFunctions.StripHTML(txtComments.Text))
                    pnlComments.Visible = True
                Else
                    pnlComments.Visible = False
                End If

                'Set various variables for use later
                Dim CUR_ID As Integer = CInt(Session("CUR_ID"))
                Dim objBasket As Kartris.Basket = Session("Basket")

                'Some items might be excluded from customer discount
                If objBasket.HasCustomerDiscountExemption Then

                End If
                Dim intGatewayCurrency As Int16

                'Set payment gateway
                If Interfaces.Utils.TrimWhiteSpace(clsPlugin.Currency) <> "" Then
                    intGatewayCurrency = CurrenciesBLL.CurrencyID(clsPlugin.Currency)
                Else
                    intGatewayCurrency = CUR_ID
                End If

                'If payment system can only process a particular currency
                'we show a message that the order was converted from user
                'selected currency to this for processing
                If intGatewayCurrency <> CUR_ID Then
                    pnlProcessCurrency.Visible = True
                    lblProcessCurrency.Text = CurrenciesBLL.FormatCurrencyPrice(intGatewayCurrency, CurrenciesBLL.ConvertCurrency(intGatewayCurrency, objBasket.FinalPriceIncTax, CUR_ID), , False)
                Else
                    pnlProcessCurrency.Visible = False
                End If

                'Back button, in case customers need to change anything
                btnBack.Visible = True

                'Show Credit Card Input Usercontrol if payment gateway type is local
                If LCase(clsPlugin.GatewayType) = "local" And
                    Not (clsPlugin.GatewayName.ToLower = "po_offlinepayment" Or
                    clsPlugin.GatewayName.ToLower = "bitcoin" Or
                    clsPlugin.GatewayName.ToLower = "easypaymultibanco" Or
                    clsPlugin.GatewayName.ToLower = "braintreepayment") Then
                    UC_CreditCardInput.AcceptsPaypal = clsPlugin.AcceptsPaypal
                    phdCreditCardInput.Visible = True
                ElseIf clsPlugin.GatewayName.ToLower = "braintreepayment" Then  ' show BrainTree input form
                    Dim clientToken As String = ""
                    Try
                        clientToken = PaymentsBLL.GenerateClientToken()
                    Catch ex As Exception
                        Try
                            clientToken = ""
                            Throw New BrainTreeException("Something went wrong, please contact an Administrator.", "")
                        Catch bEx As BrainTreeException
                            UC_PopUpErrors.SetTextMessage = If(bEx.CustomMessage IsNot Nothing, bEx.CustomMessage, bEx.Message)
                            UC_PopUpErrors.SetTitle = GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors")
                            UC_PopUpErrors.ShowPopup()
                            mvwCheckout.ActiveViewIndex = 1
                            isOk = False
                        End Try
                    End Try

                    'Mailchimp library
                    Dim mailChimpLib As MailChimpBLL = New MailChimpBLL(CurrentLoggedUser, objBasket, CurrenciesBLL.CurrencyCode(Session("CUR_ID")))

                    'Mailchimp
                    Dim blnMailChimp As Boolean = KartSettingsManager.GetKartConfig("general.mailchimp.enabled") = "y"

                    If Not clientToken.Equals("") Then
                        'MAILCHIMP Adding Cart to BrainTree Payments
                        'If the User is Logged
                        If blnMailChimp Then
                            If CurrentLoggedUser IsNot Nothing Then
                                Session("BraintreeCartId") = mailChimpLib.AddCartToCustomerToStore().Result
                            End If
                        End If

                        phdBrainTree.Visible = True
                        phdCreditCardInput.Visible = False
                        phdPONumber.Visible = False
                        txtPurchaseOrderNo.Text = ""
                        litPONumberText.Text = ""
                        tbClientToken.Value = clientToken
                        tbAmount.Value = objBasket.FinalPriceIncTax
                        ScriptManager.RegisterStartupScript(
                        Me,
                        GetType(Page),
                        "BrainTreeSelected",
                        "var clientToken = $(""input[name*='tbClientToken']"")[0]; $(clientToken).on('input', function () {clientTokenChanged();});$(clientToken).trigger(""input"");",
                        True)
                    End If
                Else
                    phdCreditCardInput.Visible = False
                End If

                If isOk Then
                    'Move to next step
                    mvwCheckout.ActiveViewIndex = "2"
                    btnProceed.OnClientClick = ""
                End If
            Else
                'Show any errors not handled by
                'client side validation
                popExtender.Show()
            End If

        ElseIf mvwCheckout.ActiveViewIndex = "2" Then

            '=======================================
            'PROCEED CLICKED ON ORDER REVIEW PAGE
            '=======================================
            Dim blnValid As Boolean = False
            Dim numSelectedShippingID As Integer = 0
            Try
                numSelectedShippingID = UC_BasketView.SelectedShippingID
            Catch ex As Exception

            End Try

            'If numSelectedShippingID = 0 Then Response.Redirect("Checkout.aspx?shippingzero")

            'This causes issues with shipping selection, drop it for now
            'Load the basket again to verify contents. Check if quantities are still valid
            'UC_BasketSummary.LoadBasket()
            'Dim objValidateBasket As Kartris.Basket = UC_BasketSummary.GetBasket
            'If objValidateBasket.AdjustedQuantities Then
            '    UC_BasketView.LoadBasket()
            '    mvwCheckout.ActiveViewIndex = "1"
            '    Exit Sub
            'End If
            'objValidateBasket = Nothing

            'For local payment gateway types, credit
            'card details were entered. Validate these.
            If phdCreditCardInput.Visible Then
                'Validate Credit Card Input here
                Page.Validate("CreditCard")
                If IsValid Then blnValid = True
            End If

            'Handle local payment scenarios
            'This could be a local type payment gateway
            'where card data is entered directly into
            'Kartris. Or it could be the PO (purchase
            'order) / offline payment method, where a
            'user can checkout without giving card
            'details and will pay offline.
            If LCase(clsPlugin.GatewayType) <> "local" Or
            blnValid Or clsPlugin.GatewayName.ToLower = "po_offlinepayment" Or
            clsPlugin.GatewayName.ToLower = "bitcoin" Or
            clsPlugin.GatewayName.ToLower = "easypaymultibanco" Or
            clsPlugin.GatewayName.ToLower = "braintreepayment" Then

                'Setup variables to use later
                Dim C_ID As Integer = 0
                Dim O_ID As Integer
                Dim CUR_ID As Integer = CInt(Session("CUR_ID"))

                Dim blnUseHTMLOrderEmail As Boolean = (GetKartConfig("general.email.enableHTML") = "y")
                Dim sbdHTMLOrderEmail As StringBuilder = New StringBuilder
                Dim sbdHTMLOrderContents As StringBuilder = New StringBuilder
                Dim sbdHTMLOrderBasket As StringBuilder = New StringBuilder

                'Dim strBillingAddressText As String, strShippingAddressText As String
                Dim strSubject As String = ""
                Dim strTempEmailTextHolder As String = ""

                Dim sbdNewCustomerEmailText As StringBuilder = New StringBuilder
                Dim sbdBodyText As StringBuilder = New StringBuilder
                Dim sbdBasketItems As StringBuilder = New StringBuilder
                Dim arrBasketItems As List(Of Kartris.BasketItem)

                Dim objBasket As Kartris.Basket = Session("Basket")

                Dim objOrder As Kartris.Interfaces.objOrder = Nothing

                Dim blnNewUser As Boolean = True
                Dim blnAppPricesIncTax As Boolean
                Dim blnAppShowTaxDisplay As Boolean
                Dim blnAppUSmultistatetax As Boolean
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

                'Determine whether order will use the currency
                'specified in the payment gateway settings, or
                'the one the user has chosen on the store.
                Dim intGatewayCurrency As Int16
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
                If User.Identity.IsAuthenticated Then
                    C_ID = CurrentLoggedUser.ID
                    blnNewUser = False
                End If

                'Handle Promotion Coupons
                If Not String.IsNullOrEmpty(objBasket.CouponName) And objBasket.CouponDiscount.IncTax = 0 Then
                    strTempEmailTextHolder = GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf & " " & GetGlobalResourceObject("Basket", "ContentText_ApplyCouponCode") & vbCrLf & " " & objBasket.CouponName & vbCrLf
                    sbdBodyText.AppendLine(strTempEmailTextHolder)
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderContents.Append(GetBasketModifierHTMLEmailText(objBasket.CouponDiscount, GetGlobalResourceObject("Kartris", "ContentText_CouponDiscount"), objBasket.CouponName))
                    End If
                End If

                'Promotion discount
                Dim strPromotionDescription As String = ""
                If objBasket.PromotionDiscount.IncTax < 0 Then
                    For Each objPromotion As PromotionBasketModifier In UC_BasketSummary.GetPromotionsDiscount
                        With objPromotion
                            sbdBodyText.AppendLine(GetItemEmailText(.Quantity & " x " & GetGlobalResourceObject("Kartris", "ContentText_PromotionDiscount"), .Name, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
                            If blnUseHTMLOrderEmail Then
                                sbdHTMLOrderContents.Append(GetHTMLEmailRowText(.Quantity & " x " & GetGlobalResourceObject("Kartris", "ContentText_PromotionDiscount"), .Name, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
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
                'We need to show this line if the discount exists (i.e. not zero) but
                'also if zero but there are items that are exempt from the discount, so
                'it's clear why the discount is zero.
                If objBasket.CustomerDiscount.IncTax < 0 Or objBasket.HasCustomerDiscountExemption Then
                    sbdBodyText.AppendLine(GetBasketModifierEmailText(objBasket.CustomerDiscount, GetGlobalResourceObject("Basket", "ContentText_Discount"), "[customerdiscountexempttext]"))
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderContents.Append(GetBasketModifierHTMLEmailText(objBasket.CustomerDiscount, GetGlobalResourceObject("Basket", "ContentText_Discount"), "[customerdiscountexempttext]"))
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
                    sbdBodyText.Append(" " & GetGlobalResourceObject("Kartris", "ContentText_Tax") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceTaxAmount, , False) &
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
                        sbdHTMLOrderContents.Append(" " & GetGlobalResourceObject("Kartris", "ContentText_Tax") & " = " & CurrenciesBLL.FormatCurrencyPrice(CUR_ID, objBasket.FinalPriceTaxAmount, , False) &
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
                    numGatewayTotalPrice = CurrenciesBLL.FormatCurrencyPrice(intGatewayCurrency, CurrenciesBLL.ConvertCurrency(intGatewayCurrency, objBasket.FinalPriceIncTax, CUR_ID), False, False)
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
                With UC_BillingAddress.SelectedAddress
                    sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_PurchaseContactDetails") & vbCrLf)

                    If Not _blnAnonymousCheckout Then
                        sbdBodyText.Append(" " & GetGlobalResourceObject("Address", "FormLabel_CardHolderName") & ": " & .FullName & vbCrLf &
                                         " " & GetGlobalResourceObject("Email", "EmailText_Company") & ": " & .Company & vbCrLf &
                                         IIf(Not String.IsNullOrEmpty(txtEUVAT.Text), " " & GetGlobalResourceObject("Invoice", "FormLabel_CardholderEUVatNum") & ": " & txtEUVAT.Text & vbCrLf, ""))
                    End If

                    sbdBodyText.Append(" " & GetGlobalResourceObject("Kartris", "FormLabel_EmailAddress") & ": " & UC_KartrisLogin.UserEmailAddress & vbCrLf)

                    If Not _blnAnonymousCheckout Then
                        sbdBodyText.Append(" " & GetGlobalResourceObject("Address", "FormLabel_Telephone") & ": " & .Phone & vbCrLf & vbCrLf)
                    End If

                    sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_Address") & ":" & vbCrLf)

                    If Not _blnAnonymousCheckout Then
                        sbdBodyText.Append(" " & .StreetAddress & vbCrLf &
                        " " & .TownCity & vbCrLf &
                        " " & .County & vbCrLf &
                        " " & .Postcode & vbCrLf &
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
                            'do the same for EORI number
                            If Not String.IsNullOrEmpty(txtEORI.Text) Then
                                sbdHTMLOrderEmail.Replace("[eorinumberlabel]", "EORI: ")
                                sbdHTMLOrderEmail.Replace("[eorinumbervalue]", Server.HtmlEncode(txtEORI.Text))
                            Else
                                sbdHTMLOrderEmail.Replace("[eorinumberlabel]", "")
                                sbdHTMLOrderEmail.Replace("[eorinumbervalue]<br />", "")
                                sbdHTMLOrderEmail.Replace("[eorinumbervalue]", "")
                            End If
                            sbdHTMLOrderEmail.Replace("[billingemail]", Server.HtmlEncode(UC_KartrisLogin.UserEmailAddress))
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

                            sbdHTMLOrderEmail.Replace("[billingemail]", Server.HtmlEncode(UC_KartrisLogin.UserEmailAddress))

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
                        With UC_BillingAddress.SelectedAddress
                            strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf &
                                      " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf &
                                      " " & .County & vbCrLf & " " & .Postcode & vbCrLf &
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
                        With UC_ShippingAddress.SelectedAddress
                            strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf &
                                      " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf &
                                      " " & .County & vbCrLf & " " & .Postcode & vbCrLf &
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
                    'Now we could blank out the shipping address details, not
                    'really relevant for alldownloadable orders, although payment
                    'systems still require them

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

                'Comments and additional info
                If Trim(txtComments.Text) <> "" Then
                    strTempEmailTextHolder = " " & GetGlobalResourceObject("Email", "EmailText_Comments") & ": " & vbCrLf & vbCrLf &
                                         " " & txtComments.Text & vbCrLf & vbCrLf
                    sbdBodyText.Append(strTempEmailTextHolder)
                    If blnUseHTMLOrderEmail Then
                        sbdHTMLOrderEmail.Replace("[ordercomments]", Server.HtmlEncode(strTempEmailTextHolder).Replace(vbCrLf, "<br/>"))
                    End If
                Else
                    sbdHTMLOrderEmail.Replace("[ordercomments]", "")
                End If

                sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_OrderTime2") & ": " & CkartrisDisplayFunctions.NowOffset & vbCrLf)
                sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_IPAddress") & ": " & CkartrisEnvironment.GetClientIPAddress() & vbCrLf)
                sbdBodyText.Append(" " & Request.ServerVariables("HTTP_USER_AGENT") & vbCrLf)
                If blnUseHTMLOrderEmail Then
                    sbdHTMLOrderEmail.Replace("[nowoffset]", CkartrisDisplayFunctions.NowOffset)
                    sbdHTMLOrderEmail.Replace("[customerip]", CkartrisEnvironment.GetClientIPAddress())
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
                    sbdNewCustomerEmailText.Append(GetGlobalResourceObject("Email", "EmailText_EmailAddress") & UC_KartrisLogin.UserEmailAddress & vbCrLf)
                    sbdNewCustomerEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerCode") & UC_KartrisLogin.UserPassword & vbCrLf & vbCrLf)
                    sbdNewCustomerEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter1") & CkartrisBLL.WebShopURL & "Customer.aspx" & GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter2"))
                    sbdNewCustomerEmailText.Replace("<br>", vbCrLf).Replace("<br />", vbCrLf)
                End If

                sbdBodyText.Insert(0, sbdBasketItems.ToString)

                arrBasketItems = UC_BasketView.GetBasketItems
                If Not (arrBasketItems Is Nothing) Then
                    Dim BasketItem As New BasketItem
                    'final check if basket items are still there
                    If arrBasketItems.Count = 0 Then
                        CkartrisFormatErrors.LogError("Basket items were lost in the middle of Checkout! Customer redirected to main Basket page." & vbCrLf &
                                                  "Details: " & vbCrLf & "C_ID:" & IIf(User.Identity.IsAuthenticated, CurrentLoggedUser.ID, " New User") & vbCrLf &
                                                    "Payment Gateway: " & clsPlugin.GatewayName & vbCrLf &
                                                    "Generated Body Text: " & sbdBodyText.ToString)
                        Response.Redirect("~/Basket.aspx")
                    End If

                    'Get customer discount, we need this to decide whether to mark items
                    'exempt from it
                    Dim BSKT_CustomerDiscount As Double = 0
                    Try
                        BSKT_CustomerDiscount = BasketBLL.GetCustomerDiscount(CurrentLoggedUser.ID)
                    Catch ex As Exception
                        'New user, just defaults to zero as no customer discount in this case
                    End Try


                    'We need to mark items that are exempt from customer discounts
                    Dim strMark As String = ""
                    Dim blnHasExemptCustomerDiscountItems As Boolean = False

                    'Loop through basket items
                    For Each Item As Kartris.BasketItem In arrBasketItems
                        With Item
                            Dim strCustomControlName As String = ObjectConfigBLL.GetValue("K:product.customcontrolname", Item.ProductID)
                            Dim strCustomText As String = ""

                            Dim sbdOptionText As New StringBuilder("")
                            If Not String.IsNullOrEmpty(.OptionText) Then sbdOptionText.Append(vbCrLf & " " & .OptionText().Replace("<br>", vbCrLf & " ").Replace("<br />", vbCrLf & " "))

                            'Set string to blank or **, to mark items exempt from customer discount
                            If .ExcludeFromCustomerDiscount And BSKT_CustomerDiscount > 0 Then
                                strMark = " **"
                                blnHasExemptCustomerDiscountItems = True
                            Else
                                strMark = ""
                            End If

                            'Append line for this item
                            sbdBasketItems.AppendLine(
                                    GetItemEmailText(.Quantity & " x " & .ProductName & strMark, .VersionName & " (" & .CodeNumber & ")" &
                                                     sbdOptionText.ToString, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))

                            If .CustomText <> "" AndAlso String.IsNullOrEmpty(strCustomControlName) Then
                                'Add custom text to mail
                                strCustomText = " [ " & .CustomText & " ]" & vbCrLf
                                sbdBasketItems.Append(strCustomText)
                            End If
                            If blnUseHTMLOrderEmail Then
                                'this line builds up the individual rows of the order contents table in the HTML email
                                sbdHTMLOrderBasket.AppendLine(GetHTMLEmailRowText(.Quantity & " x " & .ProductName & strMark, .VersionName & " (" & .CodeNumber & ") " &
                                                     sbdOptionText.ToString & strCustomText, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate, 0, .VersionID, .ProductID))
                            End If
                        End With
                    Next

                    'Now we know if there are customer discount exempt items, can replace
                    '[customerdiscountexempttext] which was inserted with the customer discount
                    'line further above.
                    If blnHasExemptCustomerDiscountItems Then
                        sbdBodyText.Replace("[customerdiscountexempttext]", GetGlobalResourceObject("Basket", "ContentText_SomeItemsExcludedFromDiscount"))
                        sbdHTMLOrderContents.Replace("[customerdiscountexempttext]", GetGlobalResourceObject("Basket", "ContentText_SomeItemsExcludedFromDiscount"))
                    Else
                        sbdBodyText.Replace("[customerdiscountexempttext]", "")
                        sbdHTMLOrderContents.Replace("[customerdiscountexempttext]", "")
                    End If
                End If

                sbdBodyText.Insert(0, sbdBasketItems.ToString)

                If blnUseHTMLOrderEmail Then
                    'build up the table and the header tags, insert basket contents
                    sbdHTMLOrderContents.Insert(0, "<table id=""orderitems""><thead><tr>" & vbCrLf &
                                            "<th class=""col1"">" & GetGlobalResourceObject("Kartris", "ContentText_Item") & "</th>" & vbCrLf &
                                            "<th class=""col2"">" & GetGlobalResourceObject("Kartris", "ContentText_Price") & "</th></thead><tbody>" & vbCrLf &
                                            sbdHTMLOrderBasket.ToString)
                    'finally close the order contents HTML table
                    sbdHTMLOrderContents.Append("</tbody></table>")
                    'and append the order contents to the main HTML email
                    sbdHTMLOrderEmail.Replace("[ordercontents]", sbdHTMLOrderContents.ToString)
                End If

                'check if shippingdestinationid is initialized, if not then reload checkout page
                If Not blnBasketAllDigital Then
                    If UC_BasketSummary.ShippingDestinationID = 0 Or UC_BasketView.ShippingDestinationID = 0 Then
                        CkartrisFormatErrors.LogError("Basket was reset. Shipping info lost." & vbCrLf & "BasketView Shipping Destination ID: " &
                                                  UC_BasketView.ShippingDestinationID & vbCrLf & "BasketSummary Shipping Destination ID: " &
                                                  UC_BasketSummary.ShippingDestinationID)
                        Response.Redirect("~/Checkout.aspx")
                    End If
                End If

                'If this is guest checkout, let's set a boolean value
                'we can pass to the ordersBLL below, this way, the new
                'account created is tagged as guest
                Dim blnIsGuest As Boolean = (Session("_IsGuest") = "YES")

                'Create the order record
                O_ID = OrdersBLL.Add(C_ID, UC_KartrisLogin.UserEmailAddress, UC_KartrisLogin.UserPassword, UC_BillingAddress.SelectedAddress,
                                         UC_ShippingAddress.SelectedAddress, chkSameShippingAsBilling.Checked, objBasket,
                                          arrBasketItems, IIf(blnUseHTMLOrderEmail, sbdHTMLOrderEmail.ToString, sbdBodyText.ToString), clsPlugin.GatewayName, CInt(Session("LANG")), CUR_ID,
                                         intGatewayCurrency, chkOrderEmails.Checked, UC_BasketView.SelectedShippingMethod, numGatewayTotalPrice,
                                         IIf(String.IsNullOrEmpty(txtEUVAT.Text), "", txtEUVAT.Text), strPromotionDescription, txtPurchaseOrderNo.Text, Trim(txtComments.Text),
                                        blnIsGuest)

                'Store EORI number for client
                Try
                    Dim blnUpdatedEORI As Boolean = ObjectConfigBLL.SetConfigValue("K:user.eori", C_ID, txtEORI.Text, "")
                Catch ex As Exception
                    CkartrisFormatErrors.LogError("Error updating K:user.eori")
                End Try


                Session("_IsGuest") = Nothing

                'Mailchimp
                Dim blnMailChimp As Boolean = KartSettingsManager.GetKartConfig("general.mailchimp.enabled") = "y"

                If blnMailChimp Then
                    'MAILCHIMP Adding Cart
                    Dim mailChimpLib As MailChimpBLL = New MailChimpBLL(CurrentLoggedUser, objBasket, CurrenciesBLL.CurrencyCode(Session("CUR_ID")))
                    'If the User is Logged
                    If CurrentLoggedUser IsNot Nothing And String.IsNullOrEmpty(Session("BraintreeCartId")) Then
                        Dim addCartResult As String = mailChimpLib.AddCartToCustomerToStore(O_ID).Result
                    End If
                End If

                'Order Creation successful
                If O_ID > 0 Then
                    Session("OrderID") = O_ID 'Google analytics needs this later

                    objOrder = New Kartris.Interfaces.objOrder
                    'Create the Order object and fill in the property values.
                    objOrder.ID = O_ID
                    objOrder.Description = GetGlobalResourceObject("Kartris", "Config_OrderDescription")
                    objOrder.Amount = numGatewayTotalPrice
                    objOrder.ShippingPrice = objBasket.ShippingPrice.IncTax
                    objOrder.OrderHandlingPrice = objBasket.OrderHandlingPrice.IncTax
                    objOrder.ShippingExTaxPrice = objBasket.ShippingPrice.ExTax
                    objOrder.Currency = CurrenciesBLL.CurrencyCode(CUR_ID)

                    'Set billing address for order
                    If Not _blnAnonymousCheckout Then
                        With UC_BillingAddress.SelectedAddress
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

                    'Set shipping address for order
                    If Not blnBasketAllDigital Then
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
                                objOrder.Shipping.Company = .Company
                            End With
                        End If
                    Else
                        'For digital orders, we always set shipping same as 
                        'billing on the order. We generally hide it from view
                        'but most payment systems require shipping address
                        'so this keeps them happy
                        objOrder.SameShippingAsBilling = True
                    End If

                    objOrder.CustomerIPAddress = Request.ServerVariables("REMOTE_HOST")
                    objOrder.CustomerEmail = UC_KartrisLogin.UserEmailAddress

                    If Not User.Identity.IsAuthenticated Then
                        If Membership.ValidateUser(UC_KartrisLogin.UserEmailAddress, UC_KartrisLogin.UserPassword) Then
                            FormsAuthentication.SetAuthCookie(UC_KartrisLogin.UserEmailAddress, True)
                        End If
                    End If
                    Try
                        Dim KartrisUser As KartrisMemberShipUser = Membership.GetUser(UC_KartrisLogin.UserEmailAddress)
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
                                strHTMLEmailText = strHTMLEmailText.Replace("[customeremail]", UC_KartrisLogin.UserEmailAddress)
                                strHTMLEmailText = strHTMLEmailText.Replace("[customerpassword]", UC_KartrisLogin.UserPassword)
                                sbdNewCustomerEmailText.Clear()
                                sbdNewCustomerEmailText.Append(strHTMLEmailText)
                            Else
                                blnHTMLEmail = False
                            End If
                        End If
                        SendEmail(strFromEmail, UC_KartrisLogin.UserEmailAddress, strSubject, sbdNewCustomerEmailText.ToString, , , , , blnHTMLEmail)
                    End If

                    'Mailing List
                    If chkMailingList.Checked Then
                        Dim ML_SignupDateTime, ML_ConfirmationDateTime As DateTime
                        Dim blnSignupCustomer As Boolean = False
                        If objOrder.CustomerID > 0 Then
                            Dim tblCustomerData As DataTable = BasketBLL.GetCustomerData(objOrder.CustomerID)
                            If tblCustomerData.Rows.Count > 0 Then
                                ''// mailing list
                                ML_ConfirmationDateTime = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_ConfirmationDateTime"))
                                ML_SignupDateTime = FixNullFromDB(tblCustomerData.Rows(0).Item("U_ML_SignupDateTime"))
                                If Not (ML_SignupDateTime > New Date(1900, 1, 1) Or ML_ConfirmationDateTime > New Date(1900, 1, 1)) Then blnSignupCustomer = True
                            End If
                        Else
                            blnSignupCustomer = False
                        End If


                        If blnSignupCustomer Then
                            Dim strRandomString As String = ""

                            BasketBLL.UpdateCustomerMailingList(UC_KartrisLogin.UserEmailAddress, strRandomString, "h", objOrder.CustomerIPAddress)


                            'If mailchimp is active, we want to add the user to the mailing list
                            If KartSettingsManager.GetKartConfig("general.mailchimp.enabled") = "y" Then
                                'Add user direct to MailChimp
                                BasketBLL.AddListSubscriber(UC_KartrisLogin.UserEmailAddress)
                            Else
                                'Use the built in mailing list
                                Dim sbdMLBodyText As StringBuilder = New StringBuilder()
                                Dim strBodyText As String
                                Dim strMailingListSignUpLink As String = WebShopURL() & "Default.aspx?id=" & objOrder.CustomerID & "&r=" & strRandomString

                                sbdMLBodyText.Append(GetGlobalResourceObject("Kartris", "EmailText_NewsletterSignup") & vbCrLf & vbCrLf)
                                sbdMLBodyText.Append(strMailingListSignUpLink & vbCrLf & vbCrLf)
                                sbdMLBodyText.Append(GetGlobalResourceObject("Kartris", "EmailText_NewsletterAuthorizeFooter"))

                                strBodyText = sbdMLBodyText.ToString
                                strBodyText = Replace(strBodyText, "[IPADDRESS]", objOrder.CustomerIPAddress)
                                strBodyText = Replace(strBodyText, "[WEBSHOPNAME]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                                strBodyText = Replace(strBodyText, "[WEBSHOPURL]", WebShopURL)
                                strBodyText = strBodyText & GetGlobalResourceObject("Kartris", "ContentText_NewsletterSignup")

                                Dim blnHTMLEmail As Boolean = KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y"
                                If blnHTMLEmail Then
                                    Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("MailingListSignUp")
                                    'build up the HTML email if template is found
                                    If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                                        strHTMLEmailText = strHTMLEmailText.Replace("[mailinglistconfirmationlink]", strMailingListSignUpLink)
                                        strHTMLEmailText = strHTMLEmailText.Replace("[websitename]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                                        strHTMLEmailText = strHTMLEmailText.Replace("[customerip]", objOrder.CustomerIPAddress)
                                        strBodyText = strHTMLEmailText
                                    Else
                                        blnHTMLEmail = False
                                    End If
                                End If

                                'GDPR Mod - v2.9013 
                                'We want to be able to have a log of all opt-in
                                'requests sent, so we can prove the user was sent
                                'the GDPR notice, and also prove what text they
                                'received. We do this by BCCing the confirmation
                                'opt-in mail to an email address. A free account
                                'like gmail would be good for this.
                                Dim objBCCsCollection As New System.Net.Mail.MailAddressCollection
                                Dim strGDPROptinArchiveEmail As String = KartSettingsManager.GetKartConfig("general.gdpr.mailinglistbcc")
                                If strGDPROptinArchiveEmail.Length > 2 Then
                                    objBCCsCollection.Add(strGDPROptinArchiveEmail)
                                End If

                                SendEmail(strFromEmail, UC_KartrisLogin.UserEmailAddress, GetGlobalResourceObject("Kartris", "PageTitle_MailingList"), strBodyText, , , , , blnHTMLEmail,, objBCCsCollection)
                            End If

                        End If
                    End If

                    'Save Basket
                    If chkSaveBasket.Checked Then
                        Call BasketBLL.SaveBasket(objOrder.CustomerID, "Order #" & O_ID & ", " & CkartrisDisplayFunctions.NowOffset, Session("SessionID"))
                    End If

                    'v2.9010 Autosave basket
                    'This is in addition to the normal saving process, which lets a 
                    'customer save a named basket
                    Try
                        BasketBLL.AutosaveBasket(objOrder.CustomerID)
                    Catch ex As Exception
                        'User not logged in
                    End Try

                    'objOrder.WebShopURL = Page.Request.Url.ToString.Replace("?new=y", "")
                    objOrder.WebShopURL = WebShopURL() & "Checkout.aspx"

                    'serialize order object and store it as a session value
                    Session("objOrder") = Payment.Serialize(objOrder)

                    'update data field with serialized order and basket objects and selected shipping method id - this allows us to edit this order later if needed
                    OrdersBLL.DataUpdate(O_ID, Session("objOrder") & "|||" & Payment.Serialize(objBasket) & "|||" & UC_BasketView.SelectedShippingID)

                    Dim transactionId As String = ""
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

                        Dim strEasypayPayment As String = ""
                        Dim strBraintreePayment As String = ""

                        If clsPlugin.GatewayName.ToLower = "po_offlinepayment" OrElse
                    clsPlugin.GatewayName.ToLower = "bitcoin" OrElse
                    clsPlugin.GatewayName.ToLower = "easypaymultibanco" OrElse
                    clsPlugin.GatewayName.ToLower = "braintreepayment" Then
                            'PO orders don't need authorizing, they are
                            'effectively successful if placed as payment
                            'will come later
                            If clsPlugin.GatewayName.ToLower = "bitcoin" Then
                                strBitcoinPaymentAddress = clsPlugin.ProcessOrder(Payment.Serialize(objOrder))
                                blnResult = True
                            ElseIf clsPlugin.GatewayName.ToLower = "easypaymultibanco" Then
                                strEasypayPayment = clsPlugin.ProcessOrder(Payment.Serialize(objOrder))
                                blnResult = True
                                BasketBLL.DeleteBasket()
                                Session("Basket") = Nothing
                            ElseIf clsPlugin.GatewayName.ToLower = "braintreepayment" Then      ' if the user selected BrainTree as a paying method, retrieves some data from the form and calls PaymentsBLL to perform the transaction
                                Dim paymentMethodNonce, output As String
                                Dim amount As Decimal
                                Dim CurrencyID As Short
                                CurrencyID = Session("CUR_ID")
                                Try
                                    paymentMethodNonce = Request.Form("ctl00$cntMain$tbPaymentMethodNonce")
                                    amount = Request.Form("ctl00$cntMain$tbAmount")
                                    Try
                                        transactionId = PaymentsBLL.BrainTreePayment(paymentMethodNonce, amount, CurrencyID)
                                    Catch bEx As BrainTreeException
                                        transactionId = ""
                                        UC_PopUpErrors.SetTextMessage = If(bEx.CustomMessage IsNot Nothing, bEx.CustomMessage, bEx.Message)
                                        UC_PopUpErrors.SetTitle = GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors")
                                        UC_PopUpErrors.ShowPopup()
                                        mvwCheckout.ActiveViewIndex = 1
                                        blnResult = False
                                    End Try


                                    If transactionId <> "" Then
                                        blnResult = True
                                        Try
                                            'Mailchimp, try to remove cart
                                            If blnMailChimp Then
                                                'Mailchimp library
                                                Dim mailChimpLib As MailChimpBLL = New MailChimpBLL(CurrentLoggedUser, objBasket, CurrenciesBLL.CurrencyCode(Session("CUR_ID")))

                                                Dim cartId As String = Session("BraintreeCartId")
                                                If cartId IsNot Nothing Then
                                                    ' Removing Cart and adding Order to successful payment made with Braintree
                                                    Dim mcCustomer As MailChimp.Net.Models.Customer = mailChimpLib.GetCustomer(CurrentLoggedUser.ID).Result
                                                    Dim mcOrder As Order = mailChimpLib.AddOrder(mcCustomer, cartId).Result
                                                    Dim mcDeleteCart As Boolean = mailChimpLib.DeleteCart(cartId).Result
                                                    Session("BraintreeCartId") = Nothing

                                                End If
                                            End If
                                        Catch ex As Exception
                                            Debug.Print(ex.Message)
                                        End Try
                                        BasketBLL.DeleteBasket()
                                        Session("Basket") = Nothing

                                    End If
                                Catch ex As Exception
                                    output = "Error: 81503: Amount is an invalid format."
                                End Try
                            End If

                            blnResult = True
                        Else
                            '---------------------------------------
                            'COLLECT CARD DETAILS
                            '---------------------------------------
                            objOrder.CreditCardInfo.CardNumber = UC_CreditCardInput.CardNumber
                            objOrder.CreditCardInfo.CardType = UC_CreditCardInput.CardType
                            objOrder.CreditCardInfo.BeginMonth = Left(UC_CreditCardInput.StartDate, 2)
                            objOrder.CreditCardInfo.BeginYear = Right(UC_CreditCardInput.StartDate, 2)
                            objOrder.CreditCardInfo.IssueNumber = UC_CreditCardInput.CardIssueNumber
                            objOrder.CreditCardInfo.CV2 = UC_CreditCardInput.CardSecurityNumber
                            objOrder.CreditCardInfo.ExpiryMonth = Left(UC_CreditCardInput.ExpiryDate, 2)
                            objOrder.CreditCardInfo.ExpiryYear = Right(UC_CreditCardInput.ExpiryDate, 2)

                            '---------------------------------------
                            'VALIDATE CREDIT CARD DETAILS
                            'Did the gateway return a 'sucess' result on validation?
                            '---------------------------------------
                            blnResult = clsPlugin.ValidateCardOrder(Payment.Serialize(objOrder), Payment.Serialize(objBasket))
                        End If

                        '---------------------------------------
                        'SUCCESSFULLY PLACED ORDER
                        '---------------------------------------
                        If blnResult Then
                            'The transaction was authorized so update the order
                            If clsPlugin.CallbackSuccessful Or
                        clsPlugin.GatewayName.ToLower = "po_offlinepayment" Or
                        clsPlugin.GatewayName.ToLower = "easypaymultibanco" Or
                        clsPlugin.GatewayName.ToLower = "braintreepayment" Then
                                If clsPlugin.GatewayName.ToLower = "po_offlinepayment" Or
                            clsPlugin.GatewayName.ToLower = "easypaymultibanco" Or
                            clsPlugin.GatewayName.ToLower = "braintreepayment" Then
                                    O_ID = objOrder.ID
                                Else
                                    'Get order ID that was passed back with callback
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

                                            Try
                                                'Mailchimp, try to remove cart
                                                If blnMailChimp Then
                                                    'Mailchimp library
                                                    Dim mailChimpLib As MailChimpBLL = New MailChimpBLL(CurrentLoggedUser, objBasket, CurrenciesBLL.CurrencyCode(Session("CUR_ID")))

                                                    Dim cartId As String = "cart_" + O_ID.ToString()
                                                    If cartId IsNot Nothing Then
                                                        ' Removing Cart and adding Order to successful payment made with Braintree
                                                        Dim mcCustomer As MailChimp.Net.Models.Customer = mailChimpLib.GetCustomer(CurrentLoggedUser.ID).Result
                                                        Dim mcOrder As Order = mailChimpLib.AddOrder(mcCustomer, cartId).Result
                                                        Dim mcDeleteCart As Boolean = mailChimpLib.DeleteCart(cartId).Result

                                                    End If
                                                End If
                                            Catch ex As Exception
                                                Debug.Print(ex.Message)
                                            End Try

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
                                        Dim blnCheckSent As Boolean = True

                                        '---------------------------------------
                                        'SET ORDER TIME
                                        'It uses the offset config setting in
                                        'case the server your site runs on is
                                        'not in your time zone
                                        '---------------------------------------
                                        Dim strOrderTimeText As String = GetGlobalResourceObject("Email", "EmailText_OrderTime") & " " & CkartrisDisplayFunctions.NowOffset
                                        If clsPlugin.GatewayName.ToLower = "po_offlinepayment" Or clsPlugin.GatewayName.ToLower = "bitcoin" Or clsPlugin.GatewayName.ToLower = "easypaymultibanco" Then
                                            blnCheckReceivedOnPayment = False
                                            blnCheckInvoicedOnPayment = False
                                        End If

                                        If clsPlugin.GatewayName.ToLower = "easypaymultibanco" Then
                                            blnCheckSent = False
                                        End If

                                        '---------------------------------------
                                        'UPDATE THE ORDER RECORD
                                        '---------------------------------------
                                        Dim referenceCode As String = ""
                                        If clsPlugin.GatewayName.ToLower = "braintreepayment" Then
                                            referenceCode = transactionId
                                        Else
                                            referenceCode = clsPlugin.CallbackReferenceCode
                                        End If

                                        Dim intUpdateResult As Integer = OrdersBLL.CallbackUpdate(O_ID, referenceCode, CkartrisDisplayFunctions.NowOffset, blnCheckSent,
                                                                                              blnCheckInvoicedOnPayment,
                                                                                              blnCheckReceivedOnPayment,
                                                                                              strOrderTimeText,
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
                                            strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderReceived") & vbCrLf & vbCrLf &
                                                        GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & vbCrLf &
                                                        strCustomerEmailText
                                        Else
                                            strCustomerEmailText = strCustomerEmailText.Replace("[storeowneremailheader]", "")
                                        End If


                                        '---------------------------------------
                                        'SEND CUSTOMER EMAIL
                                        '---------------------------------------
                                        If KartSettingsManager.GetKartConfig("frontend.orders.emailcustomer") <> "n" Then
                                            SendEmail(strFromEmail, UC_KartrisLogin.UserEmailAddress, GetGlobalResourceObject("Email", "Config_Subjectline") & " (#" & O_ID & ")", strCustomerEmailText, , , , , blnUseHTMLOrderEmail)
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

                                If clsPlugin.GatewayName.ToLower <> "easypaymultibanco" Then

                                    '---------------------------------------

                                    'ORDER UPDATED
                                    'Clear object, transfer to the 
                                    'CheckoutComplete.aspx page
                                    '---------------------------------------
                                    'Dim BasketObject As Kartris.Basket = New Kartris.Basket


                                    BasketBLL.DeleteBasket()
                                    Session("Basket") = Nothing
                                    Session("OrderDetails") = strCallBodyText
                                    Session("OrderID") = O_ID
                                    Session("_NewPassword") = Nothing
                                    Session("objOrder") = Nothing
                                    Server.Transfer("CheckoutComplete.aspx")
                                Else
                                    Session("GateWayName") = clsPlugin.GatewayName
                                    Session("_PostBackURL") = ""
                                    Session("EasypayPayment") = strEasypayPayment
                                    Server.Transfer("VisaDetail.aspx?g=easypay&a=mbrefer")

                                End If
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
                                    Server.Transfer("CheckoutProcess.aspx", True)
                                End If

                            End If

                        Else
                            '---------------------------------------
                            'ERROR BACK FROM CREDIT CARD GATEWAY
                            'Show error in popup
                            '---------------------------------------
                            If clsPlugin.GatewayName.ToLower <> "braintreepayment" Then
                                UC_PopUpErrors.SetTextMessage = clsPlugin.CallbackMessage
                            End If
                            UC_PopUpErrors.SetTitle = GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors")
                            UC_PopUpErrors.ShowPopup()
                            mvwCheckout.ActiveViewIndex = 1
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
                        'FORMAT FORM TO POST TO REMOTE GATEWAY
                        '---------------------------------------
                        Server.Transfer("CheckoutProcess.aspx", True)
                    End If
                End If
            End If


        End If

    End Sub

    ''' <summary>
    ''' Back button click
    ''' </summary>
    Protected Sub btnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnBack.Click
        btnBack.Visible = False
        mvwCheckout.ActiveViewIndex = 1
    End Sub


    ''' <summary>
    ''' Post back automatically and refresh
    ''' when EU VAT number is entered
    ''' </summary>
    Protected Sub txtEUVAT_AutoPostback() Handles txtEUVAT.TextChanged, chkSameShippingAsBilling.CheckedChanged

        '---------------------------------------
        'VAT NUMBER WAS SUBMITTED
        '---------------------------------------
        Dim strEUVatNumber As String = txtEUVAT.Text
        Dim strThisUsersCountryCode = litMSCode.Text
        If Not String.IsNullOrEmpty(txtEUVAT.Text) Then

            'Even though we show the country code part outside
            'the text field, some users enter it into the text
            'field too. Rather than cause an error, we want to
            'just check if they do this and then remove it.
            If Left(strEUVatNumber, 2).ToUpper = strThisUsersCountryCode.ToUpper Then
                txtEUVAT.Text = Replace(strEUVatNumber, strThisUsersCountryCode, "")
            End If

            '---------------------------------------
            'We use the official EU web service
            'to validate EU VAT numbers, but can
            'fall back on simpler function if the
            'web service is unreachable or has
            'some other issue
            '---------------------------------------
            Dim blnValid As Boolean = True
            Dim datCurrent As Date
            Dim strName As String = String.Empty, strAddress As String = String.Empty
            If GetKartConfig("general.tax.euvatnumbercheck") = "y" Then
                Try
                    'Try to use web service
                    Dim svcEUVAT As New eu.europa.ec.checkVatService
                    datCurrent = svcEUVAT.checkVat(litMSCode.Text, txtEUVAT.Text, blnValid, strName, strAddress)
                    Session("blnEUVATValidated") = blnValid
                Catch ex As Exception
                    'If web service is unavailable, we fall back
                    'to our CheckVATNumber function, which just
                    'checks the format of the submitted number
                    'against the formats each EU member country
                    'uses for its VAT numbers
                    Session("blnEUVATValidated") = CheckVATNumber(litMSCode.Text, litMSCode.Text & txtEUVAT.Text)
                End Try
            Else
                Session("blnEUVATValidated") = True
            End If
        Else

            'No VAT number submitted, so
            'not validated
            'Reset everything
            txtEUVAT.Text = ""
            Session("blnEUVATValidated") = False
        End If

        If Session("blnEUVATValidated") = True Then
            'Show VAT number as valid
            'is blank, hide validation info
            litValidationOfVATNumber.Text = "&#x2705;"
            litValidationOfVATNumber.Visible = True
        Else
            If strEUVatNumber = "" Then
                'is blank, hide validation info
                litValidationOfVATNumber.Text = ""
                litValidationOfVATNumber.Visible = False
            Else
                'really is invalid
                litValidationOfVATNumber.Text = "&#x274C;"
                litValidationOfVATNumber.Visible = True
            End If
            'Show VAT number as invalid
        End If

        'UC_BasketView.RefreshShippingMethods()

    End Sub

    ''' <summary>
    ''' This function was updated 21 Oct 2010
    ''' by Paul, reflects latest specs obtained
    ''' from HMRC web site.
    ''' </summary>
    Private Function CheckVATNumber(ByVal strISOCode As String, ByVal strVatNumber As String) As Boolean
        strVatNumber = Replace(Replace(strVatNumber, " ", ""), "-", "")
        strVatNumber = Replace(Replace(strVatNumber, ".", ""), ",", "")
        Dim strCountryCodeFromVatNumber As String = Left(strVatNumber, 2)
        Dim numVatNumberLength As Integer = Len(strVatNumber) - 2
        Dim blnPassed As Boolean = False
        Select Case strISOCode
            Case "AT" 'Austria
                blnPassed = numVatNumberLength = 9 And
                      UCase(Mid(strVatNumber, 3, 1)) = "U" And
                   IsNumeric(Right(strVatNumber, 8)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "BE", "BG" 'Belgium, Bulgaria
                blnPassed = (numVatNumberLength = 9 Or numVatNumberLength = 10) And
                   IsNumeric(Right(strVatNumber, 9)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "PT", "DE", "EE" 'Portugal, Germany, Estonia
                blnPassed = numVatNumberLength = 9 And
                   IsNumeric(Right(strVatNumber, 9)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "DK", "FI", "LU", "MT", "HU", "SI" 'Denmark, Finland, Luxembourg, Malta, Hungary, Slovenia
                blnPassed = numVatNumberLength = 8 And
                   IsNumeric(Right(strVatNumber, 8)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "FR" 'France
                blnPassed = numVatNumberLength = 11 And
                   IsNumeric(Right(strVatNumber, 9)) And
                   InStr(strVatNumber, "O") = 0 And
                   InStr(strVatNumber, "I") = 0 And
                   strCountryCodeFromVatNumber = strISOCode

            Case "GR" 'Greece
                blnPassed = numVatNumberLength = 9 And
                   IsNumeric(Right(strVatNumber, 9)) And
                   strCountryCodeFromVatNumber = "EL"

            Case "IE" 'Ireland
                blnPassed = numVatNumberLength = 8 And
                   IsNumeric(Mid(strVatNumber, 5, 4)) And
                   Not IsNumeric(Right(strVatNumber, 1)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "IT", "LV", "HR" 'Italy, Latvia, Croatia
                blnPassed = numVatNumberLength = 11 And
                   IsNumeric(Right(strVatNumber, 11)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "NL" 'Netherlands
                blnPassed = numVatNumberLength = 12 And
                   IsNumeric(Right(strVatNumber, 2)) And
                   IsNumeric(Mid(strVatNumber, 3, 8)) And
                   Mid(strVatNumber, 12, 1) = "B" And
                   strCountryCodeFromVatNumber = strISOCode

            Case "ES" 'Spain
                blnPassed = numVatNumberLength = 9 And
                   IsNumeric(Mid(strVatNumber, 4, 7)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "SE" 'Sweden
                blnPassed = numVatNumberLength = 12 And
                   IsNumeric(Right(strVatNumber, 12)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "GB", "UK", "LT" 'United Kingdom, Lithuania
                blnPassed = (numVatNumberLength = 12 Or numVatNumberLength = 9) And
                   IsNumeric(Right(strVatNumber, 9)) And
                   (strCountryCodeFromVatNumber = "GB" Or strCountryCodeFromVatNumber = "LT")

            Case "CY" 'Cyprus
                blnPassed = numVatNumberLength = 9 And
                   Not IsNumeric(Right(strVatNumber, 1)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case "CZ" 'Czech Republic
                If numVatNumberLength >= 11 And numVatNumberLength <= 13 Then
                    strVatNumber = Mid(strVatNumber, 4)
                    numVatNumberLength = Len(strVatNumber)
                End If
                blnPassed = numVatNumberLength >= 8 And
                   numVatNumberLength <= 10 And
                   IsNumeric(Right(strVatNumber, 8)) And
                   (strCountryCodeFromVatNumber = "CS" Or strCountryCodeFromVatNumber = "CZ")

            Case "PL", "SK" 'Poland, Slovak Republic
                blnPassed = numVatNumberLength = 10 And
                   IsNumeric(Right(strVatNumber, 10)) And
                   strCountryCodeFromVatNumber = strISOCode

            Case Else       'ISO not recognised as in the EU - fail
                blnPassed = False

        End Select

        Return blnPassed
    End Function
End Class


