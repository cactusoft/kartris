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
Imports System.Threading
Imports System.Globalization
Imports CkartrisDisplayFunctions
Imports KartSettingsManager

Partial Class UserControls_General_Invoice
    Inherits System.Web.UI.UserControl

    Protected APP_ShowTaxDisplay, blnHasCustomerDiscountExemption As Boolean
    Protected numColumns As Single
    Private numTotalExTax, numTotalTaxAmount, numTotal As Decimal
    Private numTotalPriceExTax, numTotalPriceIncTax, numRowTaxAmount As Decimal
    Private numPromoDiscountTotal, numCouponDiscountTotal As Decimal
    Private blnTaxDue As Boolean
    Private CP_DiscountValue As Decimal
    Private strPromoDesc, strCouponCode, CP_CouponCode, CP_DiscountType As String
    Private numDiscountPercentage As Double
    Private strShippingMethod As String
    Private numShippingPriceExTax, numShippingPriceIncTax, numShippingTaxTotal As Decimal
    Private numOrderHandlingPriceExTax, numOrderHandlingPriceIncTax, numOrderHandlingTaxTotal As Decimal
    Private numFinalTotalPriceInTaxGateway As Decimal
    Private numOrderCurrency, numGatewayCurrency As Short
    Private numCurrencyRoundNumber As Short

    'v2.9010 added way to exclude items from customer discount
    'Often we have mods which require calculating a subtotal of 
    'cart items. We'll create variables here for this, but these
    'could be used for other custom mods in future requiring
    'similar.
    Private _SubTotalExTax, _SubTotalIncTax As Decimal

    Private _OrderLanguageID As Integer
    Private _CustomerID As Integer
    Private _OrderID As Integer
    Private _FrontOrBack As String


    Public WriteOnly Property CustomerID() As Integer
        Set(ByVal value As Integer)
            _CustomerID = value
        End Set
    End Property

    Public WriteOnly Property OrderID() As Integer
        Set(ByVal value As Integer)
            _OrderID = value
        End Set
    End Property

    Public WriteOnly Property FrontOrBack() As String
        Set(ByVal value As String)
            _FrontOrBack = value
        End Set
    End Property

    Public Function DashForBlankValue(ByVal strInput As String) As String
        If Len(strInput) > 0 Then
            Return strInput
        Else
            Return ("-")
        End If
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim tblInvoice As Data.DataTable
        Dim strPONumber As String = "", strVatNumber As String = ""
        Dim datInvoiceDate As DateTime
        Dim strDefaultAddress, strBillingAddress, strShippingAddress As String
        Dim strOrderComments As String = ""

        numCurrencyRoundNumber = BasketBLL.CurrencyRoundNumber

        strDefaultAddress = "" : strBillingAddress = "" : strShippingAddress = ""
        Dim objBasketBLL As New BasketBLL
        tblInvoice = objBasketBLL.GetCustomerInvoice(_OrderID, _CustomerID, 0)

        If tblInvoice.Rows.Count > 0 Then
            strBillingAddress = tblInvoice.Rows(0).Item("O_BillingAddress")
            strShippingAddress = tblInvoice.Rows(0).Item("O_ShippingAddress")
            strPONumber = DashForBlankValue(tblInvoice.Rows(0).Item("O_PurchaseOrderNo"))

            strVatNumber = DashForBlankValue(tblInvoice.Rows(0).Item("U_CardholderEUVATNum") & "")
            datInvoiceDate = tblInvoice.Rows(0).Item("O_Date")

            strBillingAddress = tblInvoice.Rows(0).Item("O_BillingAddress")
            strShippingAddress = tblInvoice.Rows(0).Item("O_ShippingAddress")

            'Let's see if can set comments
            Try
                strOrderComments = tblInvoice.Rows(0).Item("O_Comments")
            Catch ex As Exception
                'Generally errors on older orders before comments were stored in db.
                'In this case, we just retain strOrderComments as zero
                'length string
            End Try

            _OrderLanguageID = tblInvoice.Rows(0).Item("O_LanguageID")

            Try
                Dim strOrderCulture As String = Server.HtmlEncode(LanguagesBLL.GetCultureByLanguageID_s(_OrderLanguageID))
                Thread.CurrentThread.CurrentUICulture = New CultureInfo(strOrderCulture)
                Thread.CurrentThread.CurrentCulture = New CultureInfo(strOrderCulture)
            Catch ex As Exception
            End Try
        End If

        If tblInvoice.Rows.Count < 1 Then
            'this error should only happen if a customer tries to
            'edit the querystring to view an invoice that does
            'not belong to them.
            Response.Write("Unable to display this invoice to you")
            Response.End()
        End If
        For i As Integer = 0 To tblInvoice.Rows.Count - 1

            numOrderCurrency = tblInvoice.Rows(i).Item("O_CurrencyID")
            numGatewayCurrency = tblInvoice.Rows(i).Item("O_CurrencyIDGateway")

            Dim blnBitcoinGateway As Boolean = (CurrenciesBLL.CurrencyCode(numGatewayCurrency).ToLower = "btc")
            If blnBitcoinGateway Then
                numFinalTotalPriceInTaxGateway = Math.Round(tblInvoice.Rows(0).Item("O_TotalPriceGateway"), 8)
            Else
                numFinalTotalPriceInTaxGateway = Math.Round(tblInvoice.Rows(0).Item("O_TotalPriceGateway"), numCurrencyRoundNumber)
            End If

        Next

        'Clean up addresses, put in line breaks
        strBillingAddress = Replace(strBillingAddress, vbCrLf & vbCrLf, vbCrLf)
        strBillingAddress = Replace(strBillingAddress & "", vbCrLf, "<br />" & vbCrLf)
        strShippingAddress = Replace(strShippingAddress, vbCrLf & vbCrLf, vbCrLf)
        strShippingAddress = Replace(strShippingAddress & "", vbCrLf, "<br />" & vbCrLf)

        'Remove phone number, last line of address
        Dim aryShippingAddress As Array = Split(strShippingAddress, "<br />")
        strShippingAddress = ""
        For numCounter = 0 To UBound(aryShippingAddress) - 1
            strShippingAddress &= aryShippingAddress(numCounter) & "<br />"
        Next

        strOrderComments = Replace(strOrderComments, vbCrLf & vbCrLf, vbCrLf)
        strOrderComments = Replace(strOrderComments & "", vbCrLf, "<br />" & vbCrLf)

        'Set shipping address to billing address if blank
        If strShippingAddress = "" Then strShippingAddress = strBillingAddress

        'Set values for controls on the page
        litBilling.Text = strBillingAddress
        litShipping.Text = strShippingAddress
        litOrderID.Text = _OrderID
        litPONumber.Text = strPONumber
        litCustomerID.Text = _CustomerID
        litInvoiceDate.Text = FormatDate(datInvoiceDate, "d", _OrderLanguageID)
        litVatNumber.Text = strVatNumber
        litEORINumber.Text = ObjectConfigBLL.GetValue("K:user.eori", _CustomerID)

        'MOD v3.0001
        'Add email to invoice
        Dim objUsersBLL As New UsersBLL
        litEmail.Text = objUsersBLL.GetEmailByID(_CustomerID)

        If Not String.IsNullOrWhiteSpace(strOrderComments) AndAlso KartSettingsManager.GetKartConfig("frontend.orders.showcommentsoninvoice") = "y" Then
            CType(FindControl("phdOrderComments"), PlaceHolder).Visible = True
            CType(FindControl("litOrderComments"), Literal).Text = strOrderComments
        End If

        'get sales receipt details
        tblInvoice.Dispose()

        tblInvoice = objBasketBLL.GetCustomerInvoice(_OrderID, _CustomerID, 1)

        rptInvoice.DataSource = tblInvoice
        rptInvoice.DataBind()

    End Sub

    Protected Sub rptInvoice_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptInvoice.ItemDataBound
        Dim strVersionCode, strItemPriceTax As String
        Dim strCustomizationOptionText As String
        Dim numItemPriceIncTax, numItemPriceExTax, numItemPriceTax, numRowPriceExTax, numRowPriceIncTax As Double
        Dim blnExcludeFromCustomerDiscount As Boolean 'v2.9010 addition, allows items to be excluded from the % customer discount available to customer
        Dim strMark As String = ""

        'show tax if config says so
        APP_ShowTaxDisplay = (LCase(GetKartConfig("frontend.display.showtax")) = "y") Or (LCase(GetKartConfig("frontend.display.showtax")) = "c")
        If APP_ShowTaxDisplay = True Then numColumns = 7 Else numColumns = 4

        If e.Item.ItemType = ListItemType.Header Then
            numPromoDiscountTotal = 0

        ElseIf e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim objProductsBLL As New ProductsBLL
            Dim objVersionsBLL As New VersionsBLL
            strVersionCode = e.Item.DataItem("IR_VersionCode")
            strCustomizationOptionText = e.Item.DataItem("IR_OptionsText")
            numTotal = e.Item.DataItem("O_TotalPrice")
            blnTaxDue = e.Item.DataItem("O_TaxDue")

            'get data for promotion discount
            numPromoDiscountTotal = e.Item.DataItem("O_PromotionDiscountTotal")
            strPromoDesc = e.Item.DataItem("O_PromotionDescription")

            'get data for coupon discount
            strCouponCode = e.Item.DataItem("O_CouponCode") & ""
            CP_DiscountValue = -IIf(IsDBNull(e.Item.DataItem("CP_DiscountValue")), 0, e.Item.DataItem("CP_DiscountValue"))
            CP_DiscountType = e.Item.DataItem("CP_DiscountType") & ""
            If CP_DiscountType = "f" Then CP_DiscountValue = IIf(IsDBNull(e.Item.DataItem("O_CouponDiscountTotal")), 0, e.Item.DataItem("O_CouponDiscountTotal"))
            CP_CouponCode = e.Item.DataItem("CP_CouponCode") & ""
            numCouponDiscountTotal = e.Item.DataItem("O_CouponDiscountTotal")

            'get data for customer discount
            numDiscountPercentage = e.Item.DataItem("O_DiscountPercentage")

            'get data for shipping cost
            strShippingMethod = e.Item.DataItem("O_ShippingMethod") & ""
            numShippingPriceExTax = e.Item.DataItem("O_ShippingPrice")
            numShippingPriceIncTax = e.Item.DataItem("O_ShippingPrice") + e.Item.DataItem("O_ShippingTax")
            numShippingTaxTotal = e.Item.DataItem("O_ShippingTax")

            'get data for order handling
            numOrderHandlingPriceExTax = e.Item.DataItem("O_OrderHandlingCharge")
            numOrderHandlingPriceIncTax = e.Item.DataItem("O_OrderHandlingCharge") + e.Item.DataItem("O_OrderHandlingChargeTax")
            numOrderHandlingTaxTotal = e.Item.DataItem("O_OrderHandlingChargeTax")

            'set product/version name and customization text
            CType(e.Item.FindControl("litVersionCode"), Literal).Text = strVersionCode
            If strCustomizationOptionText <> "" Then
                CType(e.Item.FindControl("litCustomizationOptionText"), Literal).Text = "<div>" & strCustomizationOptionText & "</div>"
            End If

            'Handle items that are exempt from customer discount
            blnExcludeFromCustomerDiscount = e.Item.DataItem("IR_ExcludeFromCustomerDiscount")

            'Totals
            If e.Item.DataItem("O_PricesIncTax") Then
                'PRICES INCLUDING TAX
                numItemPriceExTax = Math.Round(e.Item.DataItem("IR_PricePerItem") - e.Item.DataItem("IR_TaxPerItem"), numCurrencyRoundNumber)
                numItemPriceIncTax = Math.Round(e.Item.DataItem("IR_PricePerItem"), numCurrencyRoundNumber)
                numItemPriceTax = e.Item.DataItem("IR_TaxPerItem")
                strItemPriceTax = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numItemPriceTax) ' & " (" & (e.Item.DataItem("IR_TaxPerItem") / (e.Item.DataItem("IR_PricePerItem") - e.Item.DataItem("IR_TaxPerItem"))) & ")"
                numRowPriceExTax = e.Item.DataItem("IR_Quantity") * numItemPriceExTax
                numRowPriceIncTax = Math.Round(e.Item.DataItem("IR_PricePerItem"), numCurrencyRoundNumber) * e.Item.DataItem("IR_Quantity")
            Else
                'PRICES EXCLUDING TAX
                numItemPriceExTax = e.Item.DataItem("IR_PricePerItem")
                numItemPriceTax = e.Item.DataItem("IR_TaxPerItem")
                strItemPriceTax = (Math.Round(numItemPriceTax * 100, 4)) & "%"
                numRowPriceExTax = Math.Round(e.Item.DataItem("IR_PricePerItem") * e.Item.DataItem("IR_Quantity"), numCurrencyRoundNumber)
                'In following line, the 0.0000000001 is there to ensure tax is rounded up rather than down, if is 0.5
                numRowPriceIncTax = Math.Round(e.Item.DataItem("IR_PricePerItem") * e.Item.DataItem("IR_Quantity") * ((1 + e.Item.DataItem("IR_TaxPerItem")) + 0.0000000001), numCurrencyRoundNumber)
            End If

            'Set marker for items that are excluded from customer discount
            If blnExcludeFromCustomerDiscount Then
                blnHasCustomerDiscountExemption = True
                strMark = " **"
                _SubTotalExTax = _SubTotalExTax + numRowPriceExTax
                _SubTotalIncTax = _SubTotalIncTax + numRowPriceIncTax
            Else
                strMark = ""
            End If

            numTotalPriceExTax = numTotalPriceExTax + numRowPriceExTax
            numTotalPriceIncTax = numTotalPriceIncTax + numRowPriceIncTax
            numRowTaxAmount = Math.Round(numRowPriceIncTax - numRowPriceExTax, numCurrencyRoundNumber)
            numTotalTaxAmount = numTotalTaxAmount + numRowTaxAmount

            'Set the various controls to appropriate value
            CType(e.Item.FindControl("litVersionName"), Literal).Text = e.Item.DataItem("IR_VersionName") & strMark
            CType(e.Item.FindControl("litItemPriceExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numItemPriceExTax)
            CType(e.Item.FindControl("litTaxPerItem"), Literal).Text = strItemPriceTax
            If e.Item.DataItem("O_PricesIncTax") Then 'Price is either inc or ex tax
                CType(e.Item.FindControl("litItemPrice"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numItemPriceIncTax)
            Else
                CType(e.Item.FindControl("litItemPrice"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numItemPriceExTax)
            End If
            CType(e.Item.FindControl("litQuantity"), Literal).Text = CSng(e.Item.DataItem("IR_Quantity"))
            CType(e.Item.FindControl("litRowPriceExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numRowPriceExTax)
            CType(e.Item.FindControl("litTaxAmount"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numRowTaxAmount)
            CType(e.Item.FindControl("litRowPriceIncTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numRowPriceIncTax)

            '-------------------------------------------------
            'MOD v3.0001
            'Extra rows for more info - Brexit related for UK clients
            CType(e.Item.FindControl("phdNonUKRows"), PlaceHolder).Visible = KartSettingsManager.GetKartConfig("general.orders.extendedinvoiceinfo") = "y"
            CType(e.Item.FindControl("litDiscountedValue"), Literal).Text = ""
            CType(e.Item.FindControl("litWeight"), Literal).Text = objVersionsBLL._GetWeightByVersionCode(strVersionCode)
            CType(e.Item.FindControl("litDiscountedValue"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, ((100 - numDiscountPercentage) / 100) * numRowPriceExTax)

            'Commodity code, first we lookup product ID from the SKU, then use that
            'to see if any commodity code. 
            Dim numProductID As Integer = objProductsBLL.GetProductIDByVersionCode(strVersionCode)
            Dim strCommodityCode As String = ObjectConfigBLL.GetValue("K:product.commoditycode", numProductID)
            If strCommodityCode <> "" Then
                CType(e.Item.FindControl("phdCommodityCode"), PlaceHolder).Visible = True
                CType(e.Item.FindControl("phdNoCommodityCode"), PlaceHolder).Visible = False
                CType(e.Item.FindControl("litCommodityCode"), Literal).Text = strCommodityCode
            End If
            '-------------------------------------------------

        ElseIf e.Item.ItemType = ListItemType.Footer Then
            Dim numTotalTaxFraction As Double
            Dim numPromotionDiscountIncTax, numPromotionDiscountExTax, numPromotionDiscountTaxAmount As Double
            Dim numCouponDiscountIncTax, numCouponDiscountExTax, numCouponDiscountTaxAmount, numCouponDiscountValue As Double
            Dim numCustomerDiscountIncTax, numCustomerDiscountExTax, numCustomerDiscountTaxAmount, numCustomerDiscountValue As Double
            Dim numShippingPrice, numOrderHandlingPrice As Double

            numTotalPriceIncTax = Math.Round(numTotalPriceIncTax, numCurrencyRoundNumber)
            numTotalPriceExTax = Math.Round(numTotalPriceExTax, numCurrencyRoundNumber)

            'promotion 
            If numPromoDiscountTotal <> 0 Then
                numTotalTaxFraction = IIf(numTotalPriceExTax = 0, 0, numTotalTaxAmount / numTotalPriceExTax)
                numPromotionDiscountIncTax = (numPromoDiscountTotal)
                numPromotionDiscountExTax = numPromotionDiscountIncTax * (1 - (numTotalTaxFraction / (1 + numTotalTaxFraction)))
                numPromotionDiscountTaxAmount = numPromotionDiscountIncTax - numPromotionDiscountExTax

                CType(e.Item.FindControl("phdPromotionDiscount"), PlaceHolder).Visible = True
                CType(e.Item.FindControl("litPromoDesc"), Literal).Text = Replace(strPromoDesc, vbCrLf, "<br/>")
                CType(e.Item.FindControl("litPromoDiscountExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numPromotionDiscountExTax)
                CType(e.Item.FindControl("litPromoTaxPerItem"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numPromotionDiscountTaxAmount)
                CType(e.Item.FindControl("litPromoItemPrice"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numPromotionDiscountIncTax)
                CType(e.Item.FindControl("litPromoDiscountTotal1"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numPromotionDiscountExTax)
                CType(e.Item.FindControl("litPromoDiscountTaxAmount"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numPromotionDiscountTaxAmount)
                CType(e.Item.FindControl("litPromoDiscountTotal2"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numPromoDiscountTotal)
            End If

            'coupon discount
            If strCouponCode <> "" Then
                numTotalTaxFraction = Math.Round(IIf(numTotalPriceExTax = 0, 0, numTotalTaxAmount / numTotalPriceExTax), 4)
                If CP_DiscountType = "p" Then        'PERCENTAGE
                    numCouponDiscountIncTax = Math.Round(CP_DiscountValue * (numTotalPriceIncTax + numPromotionDiscountIncTax) / 100, numCurrencyRoundNumber)
                    ''numCouponDiscountIncTax = Math.Round(numCouponDiscountTotal, 2)
                    numCouponDiscountExTax = Math.Round(CP_DiscountValue * (numTotalPriceExTax + numPromotionDiscountExTax) / 100, numCurrencyRoundNumber)
                    ''numCouponDiscountExTax = numCouponDiscountIncTax * (1 - (numTotalTaxFraction / (1 + numTotalTaxFraction)))
                    numCouponDiscountTaxAmount = numCouponDiscountIncTax - numCouponDiscountExTax
                ElseIf CP_DiscountType = "f" Then
                    numCouponDiscountIncTax = Math.Round(CP_DiscountValue, numCurrencyRoundNumber)
                    numCouponDiscountExTax = Math.Round(numCouponDiscountIncTax * (1 - (numTotalTaxFraction / (1 + numTotalTaxFraction))), numCurrencyRoundNumber)
                    numCouponDiscountTaxAmount = numCouponDiscountIncTax - numCouponDiscountExTax
                Else
                    numCouponDiscountIncTax = 0
                    numCouponDiscountExTax = 0
                    numCouponDiscountTaxAmount = 0
                End If
            End If

            numCouponDiscountValue = IIf(blnTaxDue, numCouponDiscountIncTax, numCouponDiscountExTax)
            If numCouponDiscountValue <> 0 Then
                CType(e.Item.FindControl("phdCouponDiscount"), PlaceHolder).Visible = True
                CType(e.Item.FindControl("litCouponCode"), Literal).Text = CP_CouponCode
                CType(e.Item.FindControl("litCouponDiscountExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCouponDiscountExTax)
                CType(e.Item.FindControl("litCouponDiscountTaxPerItem"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCouponDiscountTaxAmount)
                CType(e.Item.FindControl("litCouponDiscountPrice"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCouponDiscountIncTax)
                CType(e.Item.FindControl("litCouponDiscountTotal1"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCouponDiscountExTax)
                CType(e.Item.FindControl("litCouponDiscountTaxAmount"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCouponDiscountTaxAmount)
                CType(e.Item.FindControl("litCouponDiscountTotal2"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCouponDiscountValue)
            End If

            'customer discount
            If numDiscountPercentage <> 0 Then
                numCustomerDiscountExTax = -Math.Round(((((numTotalPriceExTax - _SubTotalExTax) + numPromotionDiscountExTax + numCouponDiscountExTax) * (numDiscountPercentage / 100))), numCurrencyRoundNumber)
                numCustomerDiscountIncTax = -Math.Round((((numTotalPriceIncTax - _SubTotalIncTax) + numPromotionDiscountIncTax + numCouponDiscountIncTax) * (numDiscountPercentage / 100)), numCurrencyRoundNumber)
                numCustomerDiscountTaxAmount = numCustomerDiscountIncTax - numCustomerDiscountExTax
            End If

            numCustomerDiscountValue = IIf(blnTaxDue, numCustomerDiscountIncTax, numCustomerDiscountExTax)
            If numCustomerDiscountValue <> 0 Or blnHasCustomerDiscountExemption = True Then
                CType(e.Item.FindControl("phdCustomerDiscount"), PlaceHolder).Visible = True
                CType(e.Item.FindControl("litContentTextExcludedItems"), Literal).Text = " (" & GetGlobalResourceObject("Basket", "ContentText_SomeItemsExcludedFromDiscount") & ")"
                CType(e.Item.FindControl("litDiscountPercentage"), Literal).Text = GetGlobalResourceObject("Basket", "ContentText_Discount") & " = " & numDiscountPercentage & "%<br />"
                CType(e.Item.FindControl("litCustomerDiscountExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCustomerDiscountExTax)
                CType(e.Item.FindControl("litCustomerDiscountTaxPerItem"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCustomerDiscountTaxAmount)
                CType(e.Item.FindControl("litCustomerDiscountPrice"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCustomerDiscountIncTax)
                CType(e.Item.FindControl("litCustomerDiscountTotal1"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCustomerDiscountExTax)
                CType(e.Item.FindControl("litCustomerDiscountTaxAmount"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCustomerDiscountTaxAmount)
                CType(e.Item.FindControl("litCustomerDiscountTotal2"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numCustomerDiscountValue)
            End If

            'shipping cost
            numShippingPrice = IIf(blnTaxDue, numShippingPriceIncTax, numShippingPriceExTax)
            If numShippingPrice <> 0 Then
                CType(e.Item.FindControl("phdShippingCost"), PlaceHolder).Visible = True
                CType(e.Item.FindControl("litShippingMethod"), Literal).Text = strShippingMethod
                CType(e.Item.FindControl("litShippingPriceExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numShippingPriceExTax)
                CType(e.Item.FindControl("litShippingTaxPerItem"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numShippingTaxTotal)
                CType(e.Item.FindControl("litShippingPrice"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numShippingPriceIncTax)
                CType(e.Item.FindControl("litShippingPriceTotal1"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numShippingPriceExTax)
                CType(e.Item.FindControl("litShippingTaxAmount"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numShippingTaxTotal)
                CType(e.Item.FindControl("litShippingPriceTotal2"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numShippingPrice)
            End If

            'order handling charge
            numOrderHandlingPrice = IIf(blnTaxDue, numOrderHandlingPriceIncTax, numOrderHandlingPriceExTax)
            If numOrderHandlingPrice <> 0 Then
                CType(e.Item.FindControl("phdOrderHandlingCharge"), PlaceHolder).Visible = True
                CType(e.Item.FindControl("litOrderHandlingPriceExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numOrderHandlingPriceExTax)
                CType(e.Item.FindControl("litOrderHandlingTaxPerItem"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numOrderHandlingTaxTotal)
                CType(e.Item.FindControl("litOrderHandlingPrice"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numOrderHandlingPriceIncTax)
                CType(e.Item.FindControl("litOrderHandlingPriceTotal1"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numOrderHandlingPriceExTax)
                CType(e.Item.FindControl("litOrderHandlingPriceTaxTotal"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numOrderHandlingTaxTotal)
                CType(e.Item.FindControl("litOrderHandlingPriceTotal2"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numOrderHandlingPrice)
            End If

            'total
            numTotalExTax = numTotalPriceExTax + numPromotionDiscountExTax + numCouponDiscountExTax + numCustomerDiscountExTax + numShippingPriceExTax + numOrderHandlingPriceExTax
            numTotalTaxAmount = numTotalTaxAmount + numPromotionDiscountTaxAmount + numCouponDiscountTaxAmount + numCustomerDiscountTaxAmount + numShippingTaxTotal + numOrderHandlingTaxTotal
            numTotal = numTotalPriceIncTax + numPromotionDiscountIncTax + numCouponDiscountIncTax + numCustomerDiscountIncTax + numShippingPriceIncTax + numOrderHandlingPriceIncTax
            CType(e.Item.FindControl("litTotalExTax"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numTotalExTax)
            CType(e.Item.FindControl("litTotalTaxAmount"), Literal).Text = CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numTotalTaxAmount)

            'Add currency description row, separate from total so can keep final column
            'width reasonable
            Dim objLanguageElementsBLL As New LanguageElementsBLL()
            CType(e.Item.FindControl("litCurrencyDescription"), Literal).Text = "(" & CurrenciesBLL.CurrencyCode(numOrderCurrency) & " - " &
                                            objLanguageElementsBLL.GetElementValue(_OrderLanguageID,
                                              CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Currencies,
                                            CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, numOrderCurrency) & ")"

            CType(e.Item.FindControl("litTotal"), Literal).Text += CurrenciesBLL.FormatCurrencyPrice(numOrderCurrency, numTotal)

            If numGatewayCurrency <> numOrderCurrency Then
                CType(e.Item.FindControl("phdTotalGateway"), PlaceHolder).Visible = True
                CType(e.Item.FindControl("litTotalGateway"), Literal).Text = "(" & CurrenciesBLL.CurrencyCode(numGatewayCurrency) & " - " &
                            objLanguageElementsBLL.GetElementValue(_OrderLanguageID,
                              CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Currencies,
                            CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, numGatewayCurrency) & ") "
                CType(e.Item.FindControl("litTotalGateway"), Literal).Text += CurrenciesBLL.FormatCurrencyPrice(numGatewayCurrency, numFinalTotalPriceInTaxGateway)

            End If

        End If

    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Error
        CkartrisFormatErrors.LogError()
    End Sub

End Class
