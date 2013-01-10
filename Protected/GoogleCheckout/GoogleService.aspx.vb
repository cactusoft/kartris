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
Imports System.IO
Imports GCheckout.MerchantCalculation
Imports GCheckout.Util
Imports CkartrisBLL
Imports KartrisClasses

Partial Class GoogleService

    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        Try
            ' Extract the XML from the request.
            Dim objRequestStream As Stream = Request.InputStream
            Dim objRequestStreamReader As StreamReader = New StreamReader(objRequestStream)
            Dim strRequestXml As String = objRequestStreamReader.ReadToEnd
            objRequestStream.Close()
            Log.Debug(("Request XML: " + strRequestXml))

            ' Process the incoming XML.
            Dim objCallbackProcessor As CallbackProcessor = New CallbackProcessor(New KartrisCallbackRules, GetGCheckoutConfig("ProcessCurrency"))

            Dim bytResponseXML() As Byte = objCallbackProcessor.Process(strRequestXml)
            Log.Debug(("Response XML: " + EncodeHelper.Utf8BytesToString(bytResponseXML)))
            HttpContext.Current.Session.Abandon()
            Response.BinaryWrite(bytResponseXML)

        Catch ex As Exception
            Log.Debug(ex.ToString)

        End Try
    End Sub


    ''' <summary>
    ''' Kartris Rules to handle merchant calculation callbacks
    ''' </summary>
    Private Class KartrisCallbackRules
        Inherits CallbackRules

        ''' <summary>
        ''' Check the entered coupon code in Google Checkout and returns the value if its valid
        ''' </summary>
        ''' <param name="ThisOrder">The Order to perform the calculation</param>
        ''' <param name="Address">contains a possible shipping address for an order.
        ''' This address should be used to calculate taxes and shipping costs 
        ''' for the order.</param>
        ''' <param name="MerchantCode">Contains a coupon or gift certificate code
        ''' that the customer entered for an order.</param>
        ''' <returns></returns>
        Public Overloads Overrides Function GetMerchantCodeResult(ByVal ThisOrder As Order, ByVal Address As AnonymousAddress, ByVal MerchantCode As String) As MerchantCodeResult
            Dim objRetVal As New MerchantCodeResult()
            Dim tblCoupons As DataTable = CouponsBLL._SearchByCouponCode(MerchantCode)

            If tblCoupons.Rows.Count = 1 Then
                If tblCoupons.Rows(0)("CP_Enabled") Then
                    Dim blnValidCoupon As Boolean = True
                    If Not tblCoupons.Rows(0)("CP_Reusable") Then
                        If Not tblCoupons.Rows(0)("CP_Used") Then blnValidCoupon = False
                    End If

                    'WE CANT COMPUTE FOR COUPONS YET AS WE NEED TO FIND A WAY TO GET THE BASKET TOTALDISCOUNTPRICE FROM HERE
                    'RetVal.Amount = 10
                    'RetVal.Valid = True
                    'RetVal.Message = "You saved $10!"
                Else
                    objRetVal.Message = "Sorry, we didn't recognize code '" & MerchantCode & "'."
                End If
            End If
            objRetVal.Type = MerchantCodeType.Coupon
            objRetVal.Valid = False

            Return objRetVal
        End Function

        ''' <summary>
        ''' Calculate Total Tax amount for the order based on the shipping rates and address
        ''' </summary>
        ''' <param name="ThisOrder">The Order to perform the calculation</param>
        ''' <param name="Address">contains a possible shipping address for an order.
        ''' This address should be used to calculate taxes and shipping costs 
        ''' for the order.</param>
        ''' <param name="ShippingRate">The cost of shipping the order.</param>
        ''' <returns></returns>
        Public Overloads Overrides Function GetTaxResult(ByVal ThisOrder As Order, ByVal Address As AnonymousAddress, ByVal ShippingRate As Decimal) As Decimal
            Dim numRetVal As Decimal = 0
            'Check if the country in the address is taxable
            Dim adrCountry As Country = Country.GetByIsoCode(Address.CountryCode, 1)

            'If country is taxable then get the various tax amounts (passed as private data) in the original
            'Google Checkout order request and add them up to get the total tax amount for the order.
            If adrCountry.D_Tax Then
                Dim numOrderHandlingPriceTaxAmount As Decimal = 0
                Dim numBasketTotalTaxAmount As Decimal = 0
                Dim numShippingPriceTaxAmount As Decimal = 0
                Dim numPromotionDiscountTaxAmount As Decimal = 0
                Dim numCouponDiscountTaxAmount As Decimal = 0
                Dim numCustomerDiscountTaxAmount As Decimal = 0

                For Each nodMerchantXMLNode As System.Xml.XmlNode In ThisOrder.MerchantPrivateDataNodes

                    If nodMerchantXMLNode.Name = "basket-totaltaxamount" Then
                        numBasketTotalTaxAmount = CDec(nodMerchantXMLNode.InnerText.ToString)
                    ElseIf nodMerchantXMLNode.Name = "orderhandlingcharge-totaltaxamount" Then
                        numOrderHandlingPriceTaxAmount = CDec(nodMerchantXMLNode.InnerText.ToString)
                    ElseIf nodMerchantXMLNode.Name = "coupon-discount" Then
                        numCouponDiscountTaxAmount = CDec(nodMerchantXMLNode.InnerText.ToString)
                    ElseIf nodMerchantXMLNode.Name = "promotion-discount" Then
                        numPromotionDiscountTaxAmount = CDec(nodMerchantXMLNode.InnerText.ToString)
                    ElseIf nodMerchantXMLNode.Name = "customer-discount" Then
                        numCustomerDiscountTaxAmount = CDec(nodMerchantXMLNode.InnerText.ToString)

                    End If
                Next

                Dim T_ID As Byte = CInt(KartSettingsManager.GetKartConfig("frontend.checkout.shipping.taxband"))
                Dim numShippingTaxRate As Double = TaxBLL.GetTaxRate(T_ID)

                If numShippingTaxRate > 0 Then numShippingTaxRate = numShippingTaxRate / 100

                Dim numShippingIncTax As Decimal = CDec(HttpContext.Current.Session("SessionIncTax" & ThisOrder.ItemSubTotal))
                numShippingPriceTaxAmount = numShippingIncTax - ShippingRate

                numRetVal = Decimal.Round(numBasketTotalTaxAmount + numShippingPriceTaxAmount + numOrderHandlingPriceTaxAmount + _
                                       numCustomerDiscountTaxAmount + numPromotionDiscountTaxAmount + numCouponDiscountTaxAmount, 2)
            End If
            Return numRetVal
        End Function

        ''' <summary>
        ''' Calculate the shipping costs
        ''' </summary>
        ''' <param name="ShipMethodName">Identifies a shipping method for which
        ''' costs need to be calculated.</param>
        ''' <param name="ThisOrder">The Order to perform the calculation</param>
        ''' <param name="Address">contains a possible shipping address for an order.
        ''' This address should be used to calculate taxes and shipping costs 
        ''' for the order.</param>
        ''' <returns></returns>
        Public Overloads Overrides Function GetShippingResult(ByVal ShipMethodName As String, ByVal ThisOrder As Order, ByVal Address As AnonymousAddress) As ShippingResult
            Dim objRetVal As New ShippingResult()

            Dim numShippingPriceExTax As Decimal
            Dim numOrderLanguageID As Int16
            For Each nodMerchantXMLNode As System.Xml.XmlNode In ThisOrder.MerchantPrivateDataNodes
                If nodMerchantXMLNode.Name = "shipping-totalextax" Then
                    numShippingPriceExTax = nodMerchantXMLNode.InnerText.ToString
                ElseIf nodMerchantXMLNode.Name = "order-languageid" Then
                    numOrderLanguageID = nodMerchantXMLNode.InnerText.ToString
                End If
            Next

            Dim objGoogleShippingMethod As ShippingMethod = Nothing

            Dim adrShippingCountry As Country = Country.GetByIsoCode(Address.CountryCode, 1)

            Dim strGCCurrencyCode As String = GetGCheckoutConfig("ProcessCurrency")
            Dim numGCCurrencyID As Integer = CurrenciesBLL.CurrencyID(strGCCurrencyCode)

            If adrShippingCountry IsNot Nothing Then
                If numGCCurrencyID <> CurrenciesBLL.GetDefaultCurrency() Then numShippingPriceExTax = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency(), numShippingPriceExTax, numGCCurrencyID)
                objGoogleShippingMethod = ShippingMethod.GetByName(ShipMethodName, adrShippingCountry.CountryId, numShippingPriceExTax, numOrderLanguageID)
            End If

            If objGoogleShippingMethod IsNot Nothing Then
                objRetVal.Shippable = True
                Dim numShippingMethodExTax As Double
                Dim numShippingMethodIncTax As Double
                If numGCCurrencyID = CurrenciesBLL.GetDefaultCurrency() Then
                    numShippingMethodExTax = objGoogleShippingMethod.ExTax
                    numShippingMethodExTax = objGoogleShippingMethod.IncTax
                Else
                    numShippingMethodIncTax = CurrenciesBLL.ConvertCurrency(numGCCurrencyID, objGoogleShippingMethod.IncTax)
                    numShippingMethodExTax = CurrenciesBLL.ConvertCurrency(numGCCurrencyID, objGoogleShippingMethod.ExTax)
                End If

                HttpContext.Current.Session("SessionIncTax" & ThisOrder.ItemSubTotal) = numShippingMethodIncTax
                objRetVal.ShippingRate = numShippingMethodExTax
            Else
                objRetVal = Nothing
            End If

            Return objRetVal

        End Function
    End Class
End Class




