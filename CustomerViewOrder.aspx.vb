'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports KartSettingsManager

Partial Class Customer_ViewOrder
	Inherits PageBaseClass

	Protected APP_PricesIncTax, APP_ShowTaxDisplay As Boolean
	Private objCurrency As New CurrenciesBLL
	Private objBasket As New BasketBLL
	Private numTaxDue, numTotalPriceExTax, numTotalPriceIncTax, numCouponDiscount, numCustomerDiscount, numShipping, numOrderHandlingCharge, numTotal As Double
	Private numDiscountPercentage, numPromotionDiscountTotal, numCouponDiscountTotal, CP_DiscountValue As Double
	Private strCouponCode, CP_DiscountType, CP_CouponCode As String
	Private numShippingPriceIncTax, numShippingPriceExTax, numOrderHandlingPriceIncTax, numOrderHandlingPriceExTax, numFinalTotalPriceInTaxGateway As Double
	Private numCurrencyIDGateway, numCurrencyID As Double

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Dim numCustomerID, numOrderID As Integer
        Dim tblOrder As Data.DataTable


        If Not (User.Identity.IsAuthenticated) Then
            Response.Redirect("~/CustomerAccount.aspx")
        Else
            numCustomerID = CurrentLoggedUser.ID
        End If

        If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Or ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple" Then
            APP_PricesIncTax = False
            APP_ShowTaxDisplay = False
        Else
            APP_PricesIncTax = GetKartConfig("general.tax.pricesinctax") = "y"
            APP_ShowTaxDisplay = GetKartConfig("frontend.display.showtax") = "y"
        End If


        numOrderID = Val(Request.QueryString("O_ID"))

        UC_CustomerOrder.ShowOrderSummary = True
        UC_CustomerOrder.OrderID = numOrderID

        tblOrder = objBasket.GetCustomerOrderDetails(numOrderID)

        If tblOrder.Rows.Count > 0 Then
            If tblOrder.Rows(0).Item("O_CustomerID") <> numCustomerID Then
                phdOrderStatus.Visible = False
            End If
        Else
            phdOrderStatus.Visible = False
        End If


    End Sub

    Sub Popup_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Response.Redirect("~/Customer.aspx")
    End Sub


End Class
