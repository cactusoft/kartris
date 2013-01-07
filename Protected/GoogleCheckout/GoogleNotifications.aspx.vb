'[[[NEW COPYRIGHT NOTICE]]]
Imports System.IO
Imports GCheckout
Imports GCheckout.Util
Imports GCheckout.AutoGen
Imports KartSettingsManager
Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports KartrisClasses


Partial Class GoogleNotifications
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        Dim strError As String = ""

        ' Extract the XML from the request.
        Dim objRequestStream As Stream = Request.InputStream
        Dim objRequestStreamReader As StreamReader = New StreamReader(objRequestStream)
        Dim objRequestXml As String = objRequestStreamReader.ReadToEnd
        objRequestStream.Close()
        If Not String.IsNullOrEmpty(objRequestXml) Then
            ' Act on the XML.
            Select Case (EncodeHelper.GetTopElement(objRequestXml))
                Case "new-order-notification"
                    Dim N1 As NewOrderNotification = CType(EncodeHelper.Deserialize(objRequestXml, GetType(NewOrderNotification)), NewOrderNotification)
                    Dim dateOrderTimeStamp As Date = N1.timestamp
                    Dim strCustomerEmail As String = N1.buyerbillingaddress.email


                    Dim OrderShippingMethod As ShippingMethod = Nothing
                    Dim numShippingWeight, numShippingTotalExTax, numShippingTotalTaxAmount, numBasketTotalTaxAmount As Double
                    Dim numCouponDiscountTaxAmount, numPromotionDiscountTaxAmount, numCustomerDiscountTaxAmount As Double
                    Dim strCouponCode As String = ""
                    Dim strCustomerIPAddress As String = ""
                    Dim intCurrencyID, intLanguageID As Int16
                    Dim intSessionID As Integer
                    Dim intCustomerID As Integer

                    Dim APP_PricesIncTax As Boolean
                    Dim APP_ShowTaxDisplay As Boolean

                    If ConfigurationManager.AppSettings("TaxRegime").tolower = "us" Then
                        APP_PricesIncTax = False
                        APP_ShowTaxDisplay = False
                    Else
                        APP_PricesIncTax = GetKartConfig("general.tax.pricesinctax") = "y"
                        APP_ShowTaxDisplay = GetKartConfig("frontend.display.showtax") = "y"
                    End If

                    For Each node As System.Xml.XmlNode In N1.shoppingcart.merchantprivatedata.Any
                        With node
                            If .Name = "shipping-weight" Then
                                numShippingWeight = .InnerText
                            ElseIf .Name = "shipping-totalextax" Then
                                numShippingTotalExTax = .InnerText
                            ElseIf .Name = "shipping-totaltaxamount" Then
                                numShippingTotalTaxAmount = .InnerText
                            ElseIf .Name = "basket-totaltaxamount" Then
                                numBasketTotalTaxAmount = CDbl(.InnerText)
                            ElseIf .Name = "coupon-code" Then
                                strCouponCode = .InnerText
                            ElseIf .Name = "order-currencyid" Then
                                intCurrencyID = CInt(.InnerText)
                            ElseIf .Name = "order-languageid" Then
                                intLanguageID = CInt(.InnerText)
                            ElseIf .Name = "buyer-ipaddress" Then
                                strCustomerIPAddress = .InnerText
                            ElseIf .Name = "session-id" Then
                                intSessionID = .InnerText
                            ElseIf .Name = "customer-id" Then
                                intCustomerID = .InnerText
                            ElseIf .Name = "customer-discount" Then
                                numCustomerDiscountTaxAmount = CDbl(.InnerText)
                            ElseIf .Name = "coupon-discount" Then
                                numCouponDiscountTaxAmount = CDbl(.InnerText)
                            ElseIf .Name = "promotion-discount" Then
                                numPromotionDiscountTaxAmount = CDbl(.InnerText)
                            End If
                        End With
                    Next


                    If intLanguageID > 0 Then HttpContext.Current.Session("LANG") = intLanguageID
                    If intSessionID > 0 Then HttpContext.Current.Session("SessionID") = intSessionID

                    Dim GCBasketBLL As New BasketBLL
                    Dim OrderBasketBLL As New BasketBLL

                    Dim strRandomPassword As String = Membership.GeneratePassword(12, 0)

                    Dim intBillingCountryID As Integer
                    Dim intShippingCountryID As Integer

                    Dim BillingAddress As KartrisClasses.Address = Nothing
                    Dim ShippingAddress As KartrisClasses.Address = Nothing

                    'Get billing address from XML
                    With N1.buyerbillingaddress
                        intBillingCountryID = Country.GetByIsoCode(.countrycode).CountryId
                        Try
                            BillingAddress = New KartrisClasses.Address(.contactname, .companyname, .address1, .city, .region, .postalcode, _
                                                                                    intBillingCountryID, .phone, , , "b")
                        Catch ex As Exception
                            strError = "Cannot retrieve billing address - " & ex.Message
                        End Try

                    End With

                    'Get shipping address from XML
                    With N1.buyershippingaddress
                        intShippingCountryID = Country.GetByIsoCode(.countrycode).CountryId
                        Try
                            ShippingAddress = New KartrisClasses.Address(.contactname, .companyname, .address1, .city, .region, .postalcode, _
                                                                                    intShippingCountryID, .phone, , , "s")
                        Catch ex As Exception
                            strError = "Cannot retrieve shipping address - " & ex.Message
                        End Try

                    End With

                    Dim strReferenceCode As String = N1.googleordernumber

                    Dim strGCCurrencyCode As String = GetGCheckoutConfig("ProcessCurrency")
                    Dim GCCurrencyID As Integer = CurrenciesBLL.CurrencyID(strGCCurrencyCode)
                    Dim intDefaultCurrencyID = CurrenciesBLL.GetDefaultCurrency
                    Dim aryPromotions As New ArrayList
                    Dim aryPromotionsDiscount As New ArrayList

                    'DO VARIOUS DATA VALIDITY CHECKS
                    If String.IsNullOrEmpty(strError) Then
                        With GCBasketBLL
                            'Retrieve Basket Items from Session

                            If GCCurrencyID <> intDefaultCurrencyID Then .CurrencyID = GCCurrencyID
                            .LoadBasketItems()
                            .Validate(False)

                            .CalculateTotals()

                            Try
                                Dim strCouponError As String = ""
                                .CalculateCoupon(strCouponCode & "", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

                                .CalculatePromotions(aryPromotions, aryPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

                                Dim BSKT_CustomerDiscount As Double = .GetCustomerDiscount(intCustomerID)
                                .CalculateCustomerDiscount(BSKT_CustomerDiscount)
                                .CalculateOrderHandlingCharge(intShippingCountryID)

                            Catch ex As Exception
                                strError = "(Google Checkout BasketBLL) Cannot compute discounts and order handling charges - " & ex.Message
                            End Try


                            Dim intSubtract As Int16 = 0

                            If .OrderHandlingPrice.ExTax > 0 Then intSubtract += 1
                            If .CouponDiscount.ExTax < 0 Then intSubtract += 1
                            If .CustomerDiscount.ExTax < 0 Then intSubtract += 1
                            If .PromotionDiscount.ExTax < 0 Then intSubtract += 1



                            If .BasketItems.Count = N1.shoppingcart.items.Count - intSubtract Then
                                'Compare the computed totals from the values in the XML
                                If Math.Round(numBasketTotalTaxAmount, 2) = Math.Round(.TotalTaxAmount, 2) And _
                                        Math.Round(numShippingTotalExTax, 2) = Math.Round(.ShippingTotalExTax, 2) And _
                                        Math.Round(numShippingWeight, 2) = Math.Round(.ShippingTotalWeight, 2) And _
                                        Math.Round(numShippingTotalTaxAmount, 2) = Math.Round(.ShippingTotalTaxAmount, 2) And _
                                        Math.Round(numCustomerDiscountTaxAmount, 2) = Math.Round(.CustomerDiscount.TaxAmount, 2) And _
                                        Math.Round(numPromotionDiscountTaxAmount, 2) = Math.Round(.PromotionDiscount.TaxAmount, 2) And _
                                        Math.Round(numCouponDiscountTaxAmount, 2) = Math.Round(.CouponDiscount.TaxAmount, 2) Then

                                    Try
                                        Dim objShippingDetails As New Interfaces.objShippingDetails
                                        Dim GCShippingTotalExtax As Double

                                        If GCCurrencyID <> intDefaultCurrencyID Then
                                            GCShippingTotalExtax = CurrenciesBLL.ConvertCurrency(intDefaultCurrencyID, numShippingTotalExTax, GCCurrencyID)
                                        Else
                                            GCShippingTotalExtax = numShippingTotalExTax
                                        End If


                                        OrderShippingMethod = ShippingMethod.GetByName(N1.ShippingMethod, intShippingCountryID, _
                                                                                       GCShippingTotalExtax, intLanguageID)

                                        Dim OrderShippingMethodRate As Double
                                        If OrderShippingMethod IsNot Nothing Then
                                            If intDefaultCurrencyID <> GCCurrencyID Then
                                                OrderShippingMethodRate = CurrenciesBLL.ConvertCurrency(GCCurrencyID, OrderShippingMethod.Rate, intDefaultCurrencyID)
                                            Else
                                                OrderShippingMethodRate = OrderShippingMethod.Rate
                                            End If
                                            .CalculateShipping(intLanguageID, OrderShippingMethod.ID, OrderShippingMethodRate, intShippingCountryID, objShippingDetails)
                                        Else
                                            .CalculateShipping(intLanguageID, 0, 0, intShippingCountryID, objShippingDetails)
                                        End If
                                    Catch ex As Exception
                                        strError = "Cannot compute order shipping charges - " & ex.Message
                                    End Try

                                    If .OrderHandlingPrice.ExTax > 0 And String.IsNullOrEmpty(strError) Then
                                        Dim numOrderHandlingPriceExTax As Double

                                        For Each ThisItem As Item In N1.shoppingcart.items
                                            If ThisItem.itemname = GetGlobalResourceObject("Kartris", "ContentText_OrderHandlingCharge") Then
                                                numOrderHandlingPriceExTax = CDbl(ThisItem.unitprice.Value)
                                            End If
                                        Next
                                        If numOrderHandlingPriceExTax <> .OrderHandlingPrice.ExTax Then strError = "Totals doesn't match"
                                    End If
                                Else
                                    strError = "Basket Totals doesn't match"
                                    If numBasketTotalTaxAmount <> .TotalTaxAmount Then strError += vbCrLf & "Basket Total Tax Amount: " & numBasketTotalTaxAmount & " <> " & .TotalTaxAmount
                                    If numShippingTotalExTax <> .ShippingTotalExTax Then strError += vbCrLf & "Shipping Total ExTax: " & numShippingTotalExTax & " <> " & .ShippingTotalExTax
                                    If numShippingWeight <> .ShippingTotalWeight Then strError += vbCrLf & "Shipping Total Weight: " & numShippingWeight & " <> " & .ShippingTotalWeight
                                    If numShippingTotalTaxAmount <> .ShippingTotalTaxAmount Then strError += vbCrLf & "Shipping Total Tax Amount: " & numShippingTotalTaxAmount & " <> " & .ShippingTotalTaxAmount
                                    If numCustomerDiscountTaxAmount <> .CustomerDiscount.TaxAmount Then strError += vbCrLf & "Customer Discount Tax Amount: " & numCustomerDiscountTaxAmount & " <> " & .CustomerDiscount.TaxAmount
                                    If numPromotionDiscountTaxAmount <> .PromotionDiscount.TaxAmount Then strError += vbCrLf & "Promotion Discount Tax Amount: " & numPromotionDiscountTaxAmount & " <> " & .PromotionDiscount.TaxAmount
                                    If numCouponDiscountTaxAmount <> .CouponDiscount.TaxAmount Then strError += vbCrLf & "Coupon Discount Tax Amount: " & numCouponDiscountTaxAmount & " <> " & .CouponDiscount.TaxAmount
                                End If
                            Else
                                strError = "Basket Item count doesn't match"
                            End If
                        End With
                    End If


                    'DO VARIOUS DATA VALIDITY CHECKS
                    If String.IsNullOrEmpty(strError) Then
                        'If Order Currency is different to Google Checkout currency then do Order BasketBLL
                        If GCCurrencyID <> intCurrencyID Then
                            With OrderBasketBLL
                                'Retrieve Basket Items from Session

                                .CurrencyID = intCurrencyID
                                .LoadBasketItems()
                                .Validate(False)

                                .CalculateTotals()

                                Try
                                    Dim objShippingDetails As New Interfaces.objShippingDetails

                                    Dim strCouponError As String = ""
                                    .CalculateCoupon(strCouponCode & "", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

                                    .CalculatePromotions(aryPromotions, aryPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

                                    Dim BSKT_CustomerDiscount As Double = .GetCustomerDiscount(intCustomerID)
                                    .CalculateCustomerDiscount(BSKT_CustomerDiscount)
                                    .CalculateOrderHandlingCharge(intShippingCountryID)

                                    Dim OrderShippingTotalExtax As Double
                                    If intCurrencyID <> intDefaultCurrencyID Then
                                        OrderShippingTotalExtax = CurrenciesBLL.ConvertCurrency(intDefaultCurrencyID, numShippingTotalExTax, intCurrencyID)
                                    Else
                                        OrderShippingTotalExtax = numShippingTotalExTax
                                    End If

                                    OrderShippingMethod = ShippingMethod.GetByName(N1.ShippingMethod, intShippingCountryID, _
                                                                                   OrderShippingTotalExtax, intLanguageID)
                                    Dim OrderShippingMethodRate As Double

                                    If OrderShippingMethod IsNot Nothing Then
                                        If intCurrencyID <> intDefaultCurrencyID Then
                                            OrderShippingMethodRate = CurrenciesBLL.ConvertCurrency(intCurrencyID, OrderShippingMethod.Rate, intDefaultCurrencyID)
                                        Else
                                            OrderShippingMethodRate = OrderShippingMethod.Rate
                                        End If
                                        .CalculateShipping(intLanguageID, OrderShippingMethod.ID, OrderShippingMethodRate, intShippingCountryID, objShippingDetails)
                                    Else
                                        .CalculateShipping(intLanguageID, 0, 0, intShippingCountryID, objShippingDetails)
                                    End If

                                Catch ex As Exception
                                    strError = "(Order BasketBLL) Cannot compute discounts and order handling charges - " & ex.Message
                                End Try
                            End With

                        Else
                            OrderBasketBLL = GCBasketBLL
                        End If
                    End If

                    'If there are no errors then create Kartris order
                    If String.IsNullOrEmpty(strError) Then
                        Dim O_ID As Integer
                        Dim C_ID As Integer = 0

                        Dim strBillingAddressText As String, strShippingAddressText As String
                        Dim strSubject As String
                        Dim blnSameShippingAsBilling As Boolean = False

                        Dim sbdEmailText As StringBuilder = New StringBuilder
                        Dim sbdBodyText As StringBuilder = New StringBuilder
                        Dim sbdBasketItems As StringBuilder = New StringBuilder

                        Dim arrBasketItems As ArrayList

                        Dim objOrder As Kartris.Interfaces.objOrder = Nothing

                        Dim blnNewUser As Boolean = True

                        Dim blnAppPricesIncTax As Boolean
                        Dim blnAppShowTaxDisplay As Boolean

                        If ConfigurationManager.AppSettings("TaxRegime").tolower Then
                            blnAppPricesIncTax = False
                            blnAppShowTaxDisplay = False
                        Else
                            blnAppPricesIncTax = GetKartConfig("general.tax.pricesinctax") = "y"
                            blnAppShowTaxDisplay = GetKartConfig("frontend.display.showtax") = "y"
                        End If

                        Dim blnDifferentGatewayCurrency As Boolean = CurrenciesBLL.CurrencyCode(intCurrencyID) <> GetGCheckoutConfig("ProcessCurrency")

                        Dim objGoogleKartrisUser As KartrisMemberShipUser = Nothing
                        Try
                            objGoogleKartrisUser = Membership.GetUser(strCustomerEmail)

                        Catch ex As Exception

                        End Try

                        If objGoogleKartrisUser IsNot Nothing Then
                            C_ID = objGoogleKartrisUser.ID
                            blnNewUser = False

                            Dim lstUsrAddresses As Collections.Generic.List(Of KartrisClasses.Address) = Nothing

                            lstUsrAddresses = KartrisClasses.Address.GetAll(C_ID)

                            'Check if the addresses in the XML already exists in the database so we can skip on adding them
                            For Each usrAddress As KartrisClasses.Address In lstUsrAddresses
                                If KartrisClasses.Address.CompareAddress(usrAddress, BillingAddress) Then BillingAddress = usrAddress
                                If KartrisClasses.Address.CompareAddress(usrAddress, ShippingAddress) Then ShippingAddress = usrAddress
                            Next

                        End If

                        With BillingAddress
                            strBillingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                                          .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                                          .County & vbCrLf & .Postcode & vbCrLf & _
                                          .Country.Name
                        End With

                        With ShippingAddress
                            strShippingAddressText = .FullName & vbCrLf & .Company & vbCrLf & _
                                          .StreetAddress & vbCrLf & .TownCity & vbCrLf & _
                                          .County & vbCrLf & .Postcode & vbCrLf & _
                                          .Country.Name
                        End With


                        If strShippingAddressText = strBillingAddressText Then blnSameShippingAsBilling = True


                        Dim strPromotionDescription As String = ""
                        'Promotion discount
                        If OrderBasketBLL.PromotionDiscount.IncTax < 0 Then
                            For Each objPromotion As PromotionBasketModifier In aryPromotionsDiscount
                                With objPromotion
                                    sbdBodyText.Append(GetItemEmailText(GetGlobalResourceObject("Kartris", "ContentText_PromotionDiscount"), .Name, .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate))
                                    If strPromotionDescription <> "" Then strPromotionDescription += vbCrLf & .Name Else strPromotionDescription += .Name
                                End With
                            Next
                        End If

                        'Coupon discount
                        If OrderBasketBLL.CouponDiscount.IncTax < 0 Then
                            sbdBodyText.Append(GetBasketModifierEmailText(OrderBasketBLL.CouponDiscount, GetGlobalResourceObject("Kartris", "ContentText_CouponDiscount"), "strCouponName", intCurrencyID))
                        End If

                        'Customer discount
                        If OrderBasketBLL.CustomerDiscount.IncTax < 0 Then
                            sbdBodyText.Append(GetBasketModifierEmailText(OrderBasketBLL.CustomerDiscount, GetGlobalResourceObject("Basket", "ContentText_Discount"), "", intCurrencyID))
                        End If

                        sbdBodyText.Append(GetBasketModifierEmailText(OrderBasketBLL.ShippingPrice, GetGlobalResourceObject("Address", "ContentText_Shipping"), OrderBasketBLL.ShippingDescription, intCurrencyID))

                        'Order handling charge
                        If OrderBasketBLL.OrderHandlingPrice.ExTax > 0 Then
                            sbdBodyText.Append(GetBasketModifierEmailText(OrderBasketBLL.OrderHandlingPrice, GetGlobalResourceObject("Kartris", "ContentText_OrderHandlingCharge"), "", intCurrencyID))
                        End If
                        sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))

                        'Order totals
                        If blnAppPricesIncTax = False Or blnAppShowTaxDisplay Then
                            sbdBodyText.Append(" " & GetGlobalResourceObject("Checkout", "ContentText_OrderValue") & " = " & CurrenciesBLL.FormatCurrencyPrice(intCurrencyID, OrderBasketBLL.FinalPriceExTax) & vbCrLf)
                            sbdBodyText.Append(" " & GetGlobalResourceObject("Kartris", "ContentText_Tax") & " = " & CurrenciesBLL.FormatCurrencyPrice(intCurrencyID, OrderBasketBLL.FinalPriceTaxAmount) & vbCrLf)
                        End If
                        sbdBodyText.Append(" " & GetGlobalResourceObject("Basket", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(intCurrencyID, OrderBasketBLL.FinalPriceIncTax) & vbCrLf)
                        sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))

                        If blnDifferentGatewayCurrency Then
                            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_ProcessCurrencyExp1") & vbCrLf)
                            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "ContentText_TotalInclusive") & " = " & CurrenciesBLL.FormatCurrencyPrice(GCCurrencyID, N1.ordertotal.Value) & vbCrLf)
                            sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)
                        End If

                        'Total Saved
                        If OrderBasketBLL.TotalAmountSaved > 0 And KartSettingsManager.GetKartConfig("frontend.checkout.confirmation.showtotalsaved") = "y" Then
                            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_TotalSaved1") & _
                                              CurrenciesBLL.FormatCurrencyPrice(intCurrencyID, OrderBasketBLL.TotalAmountSaved) & _
                                              GetGlobalResourceObject("Email", "EmailText_TotalSaved2") & vbCrLf)
                            sbdBodyText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker"))
                        End If

                        'Customer billing information
                        sbdBodyText.Append(vbCrLf)
                        With BillingAddress
                            sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_PurchaseContactDetails") & vbCrLf & _
                                 " " & GetGlobalResourceObject("Address", "FormLabel_CardHolderName") & ": " & .FullName & vbCrLf & _
                                 " " & GetGlobalResourceObject("Email", "EmailText_Company") & ": " & .Company & vbCrLf & _
                                 " " & GetGlobalResourceObject("Kartris", "FormLabel_EmailAddress") & ": " & strCustomerEmail & vbCrLf & _
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

                        If blnSameShippingAsBilling Then
                            With BillingAddress
                                strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf & _
                                              " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf & _
                                              " " & .County & vbCrLf & " " & .Postcode & vbCrLf & _
                                              " " & .Country.Name & vbCrLf & vbCrLf
                            End With
                        Else
                            With ShippingAddress
                                strShippingAddressEmailText = " " & .FullName & vbCrLf & " " & .Company & vbCrLf & _
                                              " " & .StreetAddress & vbCrLf & " " & .TownCity & vbCrLf & _
                                              " " & .County & vbCrLf & " " & .Postcode & vbCrLf & _
                                              " " & .Country.Name & vbCrLf & vbCrLf
                            End With
                        End If

                        sbdBodyText.Append(strShippingAddressEmailText & GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf)

                        sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_OrderTime2") & ": " & dateOrderTimeStamp & vbCrLf)
                        sbdBodyText.Append(" " & GetGlobalResourceObject("Email", "EmailText_IPAddress") & ": " & strCustomerIPAddress)

                        If KartSettingsManager.GetKartConfig("frontend.users.emailnewaccountdetails") = "y" And blnNewUser Then
                            'Build up email text
                            strSubject = GetGlobalResourceObject("Email", "Config_Subjectline5")

                            sbdEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpHeader") & vbCrLf & vbCrLf)
                            sbdEmailText.Append(GetGlobalResourceObject("Email", "EmailText_EmailAddress") & strCustomerEmail & vbCrLf)
                            sbdEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerCode") & strRandomPassword & vbCrLf & vbCrLf)
                            sbdEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter1") & CkartrisBLL.WebShopURL & "customer.aspx" & _
                                               GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter2"))
                            sbdEmailText.Replace("<br>", vbCrLf).Replace("<br />", vbCrLf)
                        End If

                        arrBasketItems = OrderBasketBLL.BasketItems
                        If Not (arrBasketItems Is Nothing) Then
                            Dim objBasketItem As New BasketItem
                            For i As Integer = 0 To arrBasketItems.Count - 1
                                objBasketItem = arrBasketItems(i)
                                With objBasketItem
                                    sbdBasketItems.Append(GetItemEmailText(.Quantity & " x " & .ProductName, .VersionName & " (" & .CodeNumber & ")" & IIf(.HasOptions, vbCrLf & " " & .OptionText(), ""), .ExTax, .IncTax, .TaxAmount, .ComputedTaxRate, intCurrencyID))
                                End With
                            Next
                        End If

                        sbdBodyText.Insert(0, sbdBasketItems.ToString)
                        Dim blnOrderEmails As Boolean = True
                        If GetKartConfig("frontend.orders.emailcustomer") = "y" Then blnOrderEmails = False

                        Dim intShippingMethodID As Integer = 0
                        Dim numShippingMethodRate As Double = 0
                        If OrderShippingMethod IsNot Nothing Then
                            intShippingMethodID = OrderShippingMethod.ID
                            numShippingMethodRate = OrderShippingMethod.Rate
                        End If
                        'Create the order record
                        O_ID = OrdersBLL.Add(C_ID, strCustomerEmail, strRandomPassword, BillingAddress, _
                                             ShippingAddress, blnSameShippingAsBilling, OrderBasketBLL, arrBasketItems, sbdBodyText.ToString, _
                                            "googlecheckout", intLanguageID, intCurrencyID, _
                                             GCCurrencyID, blnOrderEmails, intShippingMethodID, N1.ordertotal.Value, "", strPromotionDescription, "", "")

                        If O_ID > 0 And N1.financialorderstate <> FinancialOrderState.PAYMENT_DECLINED Then
                            Dim tblOrder As DataTable = OrdersBLL.GetOrderByID(O_ID)
                            Dim O_CouponCode As String = ""
                            Dim O_TotalPriceGateway As Double = 0
                            Dim O_WLID As Integer = 0
                            Dim strCallBodyText As String = ""
                            Dim strBasketBLL As String = ""
                            If tblOrder.Rows.Count > 0 Then
                                If tblOrder.Rows(0)("O_Sent") = 0 Then
                                    'Store order details
                                    O_CouponCode = CStr(FixNullFromDB(tblOrder.Rows(0)("O_CouponCode")))
                                    O_TotalPriceGateway = CDbl(tblOrder.Rows(0)("O_TotalPriceGateway"))
                                    O_WLID = CInt(tblOrder.Rows(0)("O_WishListID"))
                                    strBasketBLL = CStr(tblOrder.Rows(0)("O_Status"))
                                    strCallBodyText = CStr(tblOrder.Rows(0)("O_Details"))

                                    Dim blnCheckInvoicedOnPayment As Boolean = KartSettingsManager.GetKartConfig("frontend.orders.checkinvoicedonpayment") = "y"
                                    Dim blnCheckReceivedOnPayment As Boolean = KartSettingsManager.GetKartConfig("frontend.orders.checkreceivedonpayment") = "y"

                                    Dim intUpdateResult As Integer = OrdersBLL.CallbackUpdate(O_ID, strReferenceCode, Now, True, _
                                                                                              blnCheckInvoicedOnPayment, _
                                                                                              blnCheckReceivedOnPayment, _
                                                                                              GetGlobalResourceObject("Email", "EmailText_OrderTime") & " " & Now, _
                                                                                              O_CouponCode, O_WLID, C_ID, GCCurrencyID, "googlecheckout", O_TotalPriceGateway)
                                    Dim strCustomerEmailText As String = ""
                                    Dim strStoreEmailText As String = ""



                                    'EMAIL TO CUSTOMER
                                    If KartSettingsManager.GetKartConfig("frontend.checkout.ordertracking") = "y" Then
                                        'Add order tracking information at the top
                                        strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderLookup") & vbCrLf & vbCrLf & WebShopURL() & "customer.aspx" & vbCrLf & vbCrLf & strCallBodyText
                                    Else
                                        strCustomerEmailText = strCallBodyText
                                    End If

                                    'Add in email header above that
                                    strCustomerEmailText = GetGlobalResourceObject("Email", "EmailText_OrderReceived") & vbCrLf & vbCrLf & _
                                        GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & _
                                        strCustomerEmailText

                                    'Header for store email
                                    strStoreEmailText = GetGlobalResourceObject("Email", "EmailText_StoreEmailHeader") & vbCrLf & vbCrLf & _
                                        GetGlobalResourceObject("Kartris", "ContentText_OrderNumber") & ": " & O_ID & vbCrLf & strCallBodyText

                                    If KartSettingsManager.GetKartConfig("general.email.method") = "write" Then
                                        Session("strEmailText") = strCustomerEmailText & "xxxEmailSeparatorxxx" & strStoreEmailText
                                    End If
                                    'Order updated. 
                                    OrderBasketBLL.DeleteBasket()
                                End If
                            End If
                        End If
                    End If
                Case "risk-information-notification"
                    Dim N2 As RiskInformationNotification = CType(EncodeHelper.Deserialize(objRequestXml, GetType(RiskInformationNotification)), RiskInformationNotification)
                    ' This notification tells us that Google has authorized the order and it has passed the fraud check.
                    Dim OrderNumber2 As String = N2.googleordernumber
                    Dim AVS As String = N2.riskinformation.avsresponse
                    Dim CVN As String = N2.riskinformation.cvnresponse
                    Dim SellerProtection As Boolean = N2.riskinformation.eligibleforprotection
                Case "order-state-change-notification"
                    Dim N3 As OrderStateChangeNotification = CType(EncodeHelper.Deserialize(objRequestXml, GetType(OrderStateChangeNotification)), OrderStateChangeNotification)
                    ' The order has changed either financial or fulfillment state in Google's system.
                    Dim strOrderNumber3 As String = N3.googleordernumber
                    Dim strNewFinanceState As String = N3.newfinancialorderstate.ToString
                    Dim strNewFulfillmentState As String = N3.newfulfillmentorderstate.ToString
                    Dim strPrevFinanceState As String = N3.previousfinancialorderstate.ToString
                    Dim strPrevFulfillmentState As String = N3.previousfulfillmentorderstate.ToString


                    If UCase(strNewFinanceState) = "CHARGEABLE" Then
                        Dim blnCheckInvoicedOnPayment As Boolean = KartSettingsManager.GetKartConfig("frontend.orders.checkinvoicedonpayment") = "y"
                        Dim blnCheckReceivedOnPayment As Boolean = KartSettingsManager.GetKartConfig("frontend.orders.checkreceivedonpayment") = "y"

                        Dim intUpdateResult As Integer = OrdersBLL.UpdateByReferenceCode(strOrderNumber3, Now, True, _
                                                                                  blnCheckInvoicedOnPayment, _
                                                                                  blnCheckReceivedOnPayment, _
                                                                                  GetGlobalResourceObject("Email", "EmailText_OrderTime") & " " & Now)
                    End If
                Case "charge-amount-notification"
                    Dim N4 As ChargeAmountNotification = CType(EncodeHelper.Deserialize(objRequestXml, GetType(ChargeAmountNotification)), ChargeAmountNotification)
                    ' Google has successfully charged the customer's credit card.
                    Dim strOrderNumber4 As String = N4.googleordernumber
                    Dim numChargedAmount As Decimal = N4.latestchargeamount.Value
                Case "refund-amount-notification"
                    Dim N5 As RefundAmountNotification = CType(EncodeHelper.Deserialize(objRequestXml, GetType(RefundAmountNotification)), RefundAmountNotification)
                    ' Google has successfully refunded the customer's credit card.
                    Dim strOrderNumber5 As String = N5.googleordernumber
                    Dim numRefundedAmount As Decimal = N5.latestrefundamount.Value
                Case "chargeback-amount-notification"
                    Dim N6 As ChargebackAmountNotification = CType(EncodeHelper.Deserialize(objRequestXml, GetType(ChargebackAmountNotification)), ChargebackAmountNotification)
                    ' A customer initiated a chargeback with his credit card company to get her money back.
                    Dim strOrderNumber6 As String = N6.googleordernumber
                    Dim strChargebackAmount As Decimal = N6.latestchargebackamount.Value
            End Select
        Else
            Throw New Exception("No XML!")
        End If
        Session.Abandon()
        If Not String.IsNullOrEmpty(strError) Then Throw New Exception(strError)
    End Sub
End Class




