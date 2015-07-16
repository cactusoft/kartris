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
Imports System.Collections.Generic
Imports System.Threading
Imports System.Globalization
Imports CkartrisBLL
Imports KartSettingsManager
Imports KartrisClasses

''' <summary>
''' This control runs the baskets on the site, including the basket
''' page itself, the minibasket and the basket summary on the
''' checkout
''' </summary>
Partial Class Templates_BasketView
    Inherits System.Web.UI.UserControl

    Protected Shared BSKT_CustomerDiscount As Double
    Private Shared arrPromotionsDiscount As New ArrayList
    Protected objCurrency As New CurrenciesBLL
    Protected objItem As New BasketItem
    Protected blnAdjusted As Boolean
    Protected SESS_CurrencyID As Integer
    Protected APP_PricesIncTax, APP_ShowTaxDisplay, APP_USMultiStateTax As Boolean

    Private arrPromotions As New List(Of Kartris.Promotion)
    Private numCustomerID As Integer
    Private _objShippingDetails As Interfaces.objShippingDetails

    Private _ViewType As BasketBLL.VIEW_TYPE = BasketBLL.VIEW_TYPE.MAIN_BASKET
    Private _ViewOnly As Boolean

    Private blnShowPromotion As Boolean = True

    Public Shared ReadOnly Property Basket() As kartris.Basket
        Get
            If HttpContext.Current.Session("Basket") Is Nothing Then HttpContext.Current.Session("Basket") = New Kartris.Basket
            Return HttpContext.Current.Session("Basket")
        End Get
    End Property

    Public Shared Property BasketItems() As List(Of Kartris.BasketItem)
        Get
            If HttpContext.Current.Session("_BasketItems") Is Nothing Then HttpContext.Current.Session("_BasketItems") = New List(Of Kartris.BasketItem)
            Return HttpContext.Current.Session("_BasketItems")
        End Get
        Set(ByVal value As List(Of Kartris.BasketItem))
            HttpContext.Current.Session("_BasketItems") = value
        End Set
    End Property

    Public ReadOnly Property GetBasket() As kartris.Basket
        Get
            Return Basket
        End Get
    End Property

    Public ReadOnly Property GetBasketItems() As List(Of Kartris.BasketItem)
        Get
            Return BasketItems
        End Get
    End Property

    Public ReadOnly Property GetPromotionsDiscount() As ArrayList
        Get
            Return arrPromotionsDiscount
        End Get
    End Property

    Public Property ViewType() As BasketBLL.VIEW_TYPE
        Get
            Return _ViewType
        End Get
        Set(ByVal value As BasketBLL.VIEW_TYPE)
            _ViewType = value
        End Set
    End Property

    Public Property ViewOnly() As Boolean
        Get
            Return _ViewOnly
        End Get
        Set(ByVal value As Boolean)
            _ViewOnly = value
        End Set
    End Property

    Public Property ShippingDetails() As Interfaces.objShippingDetails
        Get
            _objShippingDetails = Session("_ShippingDetails")
            If _objShippingDetails IsNot Nothing Then
                _objShippingDetails.ShippableItemsTotalWeight = Basket.ShippingTotalWeight
                _objShippingDetails.ShippableItemsTotalPrice = Basket.ShippingTotalExTax
                _objShippingDetails.ShippableItemsWeightUnit = GetKartConfig("general.weightunit")
            End If
            Return _objShippingDetails
        End Get
        Set(ByVal value As Interfaces.objShippingDetails)
            _objShippingDetails = value
            _objShippingDetails.ShippableItemsTotalWeight = Basket.ShippingTotalWeight
            _objShippingDetails.ShippableItemsTotalPrice = Basket.ShippingTotalExTax
            _objShippingDetails.ShippableItemsWeightUnit = GetKartConfig("general.weightunit")
            Session("_ShippingDetails") = _objShippingDetails
        End Set
    End Property

    Public Property ShippingDestinationID() As Integer
        Get
            If Session("_ShippingDestinationID") Is Nothing Then
                Return 0
            Else
                Return Session("_ShippingDestinationID")
            End If
        End Get
        Set(ByVal value As Integer)
            Session("_ShippingDestinationID") = value
            Session("numShippingCountryID") = value
        End Set
    End Property

    Public ReadOnly Property ShippingBoundary() As Double
        Get
            If GetKartConfig("frontend.checkout.shipping.calcbyweight") = "y" Then
                Return Basket.ShippingTotalWeight
            Else
                If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") <> "y" Or Not Basket.ApplyTax Then
                    Return Basket.ShippingTotalExTax
                Else
                    Return Basket.ShippingTotalIncTax
                End If
            End If
        End Get
    End Property

    Public ReadOnly Property SelectedShippingID() As Integer
        Get
            Return UC_ShippingMethodsDropdown.SelectedShippingID
        End Get
    End Property

    Public ReadOnly Property SelectedShippingAmount() As Double
        Get
            Return UC_ShippingMethodsDropdown.SelectedShippingAmount
        End Get
    End Property

    Public ReadOnly Property SelectedShippingMethod() As String
        Get
            Return Basket.ShippingName
        End Get
    End Property

    Private Property CouponCode() As String
        Get
            Return Session("CouponCode") & ""
        End Get
        Set(ByVal value As String)
            Session("CouponCode") = value
        End Set
    End Property

    Public Event ItemQuantityChanged()

    ''' <summary>
    ''' Loads the basket
    ''' </summary>
    ''' <remarks></remarks>
    Sub LoadBasket()
        'We hide or disable some things during checkout, so
        'need to check if this is being called on the checkout
        'page
        Dim blnIsInCheckout As Boolean
        blnIsInCheckout = InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "checkout.aspx") > 0

        'If user logged in, grab their customer ID, otherwise
        'we set to zero
        If Context.User.Identity.IsAuthenticated Then
            Try
                numCustomerID = DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID
            Catch ex As Exception
                FormsAuthentication.SignOut()
                numCustomerID = 0
            End Try
        Else
            numCustomerID = 0
        End If

        'Set customer ID for the basket object
        Basket.DB_C_CustomerID = numCustomerID

        If ViewType = BasketBLL.VIEW_TYPE.MINI_BASKET And (Not blnIsInCheckout) Then
            Session("numShippingCountryID") = 0
            Session("_ShippingDestinationID") = 0

            If APP_USMultiStateTax Then
                Basket.D_Tax = 0
            Else
                Basket.D_Tax = 1
            End If

        End If

        Basket.LoadBasketItems()
        BasketItems = Basket.BasketItems

        If BasketItems.Count = 0 Then
            litBasketEmpty.Text = GetGlobalResourceObject("Basket", "ContentText_BasketEmpty")
        Else
            phdBasket.Visible = True
        End If

        If blnIsInCheckout And Not ViewType = BasketBLL.VIEW_TYPE.MINI_BASKET Then
            RefreshShippingMethods()
            SetShipping(UC_ShippingMethodsDropdown.SelectedShippingID, UC_ShippingMethodsDropdown.SelectedShippingAmount, ShippingDestinationID)
        Else
            Call Basket.Validate(False)

            rptBasket.DataSource = BasketItems
            rptBasket.DataBind()

            Call Basket.CalculateTotals()

            Call BasketBLL.CalculatePromotions(Basket, arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

            Dim strCouponError As String = ""
            Call BasketBLL.CalculateCoupon(Basket, CouponCode & "", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

            BSKT_CustomerDiscount = BasketBLL.GetCustomerDiscount(numCustomerID)
            Call BasketBLL.CalculateCustomerDiscount(Basket, BSKT_CustomerDiscount)


            Call BasketBLL.CalculateOrderHandlingCharge(Basket, Session("numShippingCountryID"))
        End If

        If Basket.ShippingName = "" Or ViewType <> BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then
            phdShipping.Visible = False
        Else
            phdShipping.Visible = True
            If Basket.AllFreeShipping Then UC_ShippingMethodsDropdown.Visible = False
        End If

        If Basket.OrderHandlingPrice.IncTax = 0 Or ViewType <> BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then phdOrderHandling.Visible = False Else phdOrderHandling.Visible = True

        Try
            phdOutOfStockElectronic.Visible = Basket.AdjustedForElectronic
            phdOutOfStock.Visible = Basket.AdjustedQuantities
        Catch ex As Exception
        End Try

        Session("Basket") = Basket
    End Sub

    ''' <summary>
    ''' On page load
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        SESS_CurrencyID = Session("CUR_ID")

        If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Or ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple" Then
            APP_PricesIncTax = False
            APP_ShowTaxDisplay = False
            APP_USMultiStateTax = True
        Else
            APP_PricesIncTax = LCase(GetKartConfig("general.tax.pricesinctax")) = "y"
            'For checkout, we show tax if showtax is set to 'y' or 'c'.
            'For other pages, only if it is set to 'y'.
            If ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then
                APP_ShowTaxDisplay = (LCase(GetKartConfig("frontend.display.showtax")) = "y") Or (LCase(GetKartConfig("frontend.display.showtax")) = "c")
            Else
                APP_ShowTaxDisplay = LCase(GetKartConfig("frontend.display.showtax")) = "y"
            End If
            APP_USMultiStateTax = False
        End If

        If HttpContext.Current.User.Identity.IsAuthenticated Then
            Try
                numCustomerID = DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID
            Catch ex As Exception
                FormsAuthentication.SignOut()
                numCustomerID = 0
            End Try
        Else
            numCustomerID = 0
        End If

        litError.Text = ""

        If Not (IsPostBack) Then
            Call LoadBasket()
        Else
            If Basket.OrderHandlingPrice.IncTax = 0 Or ViewType <> BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then phdOrderHandling.Visible = False Else phdOrderHandling.Visible = True
        End If

        tmrAddToBasket.Enabled = False

    End Sub

    ''' <summary>
    ''' Pre-render
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender

        If ViewType = BasketBLL.VIEW_TYPE.MAIN_BASKET Then
            If KartSettingsManager.GetKartConfig("frontend.basket.shippingestimate") = "y" AndAlso BasketItems.Count > 0 Then
                UC_ShippingMethodsEstimate.Visible = True
                UC_ShippingMethodsEstimate.Boundary = ShippingBoundary
                UC_ShippingMethodsEstimate.Refresh()
            Else
                UC_ShippingMethodsEstimate.Visible = False
            End If

            'Hide shipping estimates if all items in basket are digital
            If Basket.AllDigital = True Then
                UC_ShippingMethodsEstimate.Visible = False
            End If
            
            phdMainBasket.Visible = True
            phdControls.Visible = True
            blnShowPromotion = True
            phdPromotions.Visible = True
            phdBasketButtons.Visible = True
        ElseIf ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then
            UC_ShippingMethodsEstimate.Visible = False
            phdControls.Visible = False
            blnShowPromotion = False
            phdPromotions.Visible = False
            If Not _ViewOnly Then phdShippingSelection.Visible = True
        ElseIf ViewType = BasketBLL.VIEW_TYPE.MINI_BASKET Then
            UC_ShippingMethodsEstimate.Visible = False
            phdMiniBasket.Visible = True
        End If

        If ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And ViewOnly Then
            rptBasket.DataSource = BasketItems
            rptBasket.DataBind()
        End If

        rptPromotions.DataSource = arrPromotions
        rptPromotions.DataBind()
        phdPromotions.Visible = IIf(arrPromotions.Count > 0 And blnShowPromotion, True, False)

        rptPromotionDiscount.DataSource = arrPromotionsDiscount
        rptPromotionDiscount.DataBind()
        phdPromotionDiscountHeader.Visible = IIf(arrPromotionsDiscount.Count > 0, True, False)

        If BasketItems Is Nothing OrElse BasketItems.Count = 0 Then
            phdBasket.Visible = False
        End If

        phdMainBasket.Visible = (ViewType <> BasketBLL.VIEW_TYPE.MINI_BASKET)
        phdShipping.Visible = (ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET)

        If UC_ShippingMethodsDropdown.SelectedShippingID > 0 Then
            phdShippingTax.Visible = True
            phdShippingTaxHide.Visible = False
        Else
            phdShippingTax.Visible = False
            phdShippingTaxHide.Visible = True
        End If

        If InStr(LCase(HttpContext.Current.Request.ServerVariables("SCRIPT_NAME")), "checkout.aspx") = 0 And ViewType = BasketBLL.VIEW_TYPE.MINI_BASKET Then
            If Not Page.IsPostBack Then
                If Not Page.User.Identity.IsAuthenticated Then
                    Session("blnLoginCleared") = False
                End If
            End If
        End If

        If InStr(LCase(HttpContext.Current.Request.ServerVariables("SCRIPT_NAME")), "checkout.aspx") > 0 And ViewType = BasketBLL.VIEW_TYPE.MINI_BASKET Then
            phdOrderInProgress.Visible = True
            phdMiniBasketContent.Visible = False
            UC_ShippingMethodsDropdown.EnableViewState = False
        Else
            phdMiniBasketContent.Visible = True
        End If

        If ViewType = BasketBLL.VIEW_TYPE.MINI_BASKET Then
            Call DisplayMiniBasket()
        End If

        ''// update basket item adjusted quantity
        If ViewType = BasketBLL.VIEW_TYPE.MINI_BASKET Then
            For Each objItem As BasketItem In BasketItems
                If objItem.AdjustedQty Then
                    BasketBLL.UpdateQuantity(objItem.ID, objItem.StockQty)
                End If
            Next
        End If

        Session("Basket") = Basket
    End Sub

    ''' <summary>
    ''' Load the minibasket
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub LoadMiniBasket()
        Call LoadBasket()
        Call DisplayMiniBasket()
    End Sub

    ''' <summary>
    ''' Display the minibasket
    ''' </summary>
    ''' <remarks></remarks>
    Sub DisplayMiniBasket()
        Dim vFinalPriceExTax, vFinalPriceIncTax, vFinalPriceTaxAmount As Double

        rptMiniBasket.DataSource = BasketItems
        rptMiniBasket.DataBind()

        Dim numTotalItems As Int32 = 0

        If BasketItems Is Nothing OrElse BasketItems.Count = 0 Then
            phdMiniBasketContent.Visible = False
            phdMiniBasketEmpty.Visible = True
            numTotalItems = 0
        Else
            If GetKartConfig("frontend.minibasket.countversions") = "y" Then
                'Absolute total of items in basket (rows x qty)
                numTotalItems = Basket.TotalItems
            Else
                'No. of rows in basket (i.e. different items)
                numTotalItems = BasketItems.Count
            End If

            phdMiniBasketEmpty.Visible = False
        End If

        phdMiniBasketPromotions.Visible = IIf(Basket.PromotionDiscount.IncTax = 0, False, True)
        phdMiniBasketCouponDiscount.Visible = IIf(Basket.CouponDiscount.IncTax = 0, False, True)        
        phdMiniBasketCustomerDiscount.Visible = IIf(BSKT_CustomerDiscount <> 0, True, False)

        lnkMiniBasketPromotions.NavigateUrl = "/" & WebShopFolder() & "Basket.aspx"
        lnkMiniBasketCouponDiscount.NavigateUrl = "/" & WebShopFolder() & "Basket.aspx"
        lnkMiniBasketCustomerDiscount.NavigateUrl = "/" & WebShopFolder() & "Basket.aspx"

        If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Or ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple" Then
            APP_ShowTaxDisplay = False
            APP_USMultiStateTax = True
        Else
            'For checkout, we show tax if showtax is set to 'y' or 'c'.
            'For other pages, only if it is set to 'y'.
            If ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then
                APP_ShowTaxDisplay = (LCase(GetKartConfig("frontend.display.showtax")) = "y") Or (LCase(GetKartConfig("frontend.display.showtax")) = "c")
            Else
                APP_ShowTaxDisplay = LCase(GetKartConfig("frontend.display.showtax")) = "y"
            End If
            APP_USMultiStateTax = False
        End If

        vFinalPriceExTax = (Basket.FinalPriceExTax - Basket.ShippingPrice.ExTax - Basket.OrderHandlingPrice.ExTax)
        vFinalPriceIncTax = (Basket.FinalPriceIncTax - Basket.ShippingPrice.IncTax - Basket.OrderHandlingPrice.IncTax)
        vFinalPriceTaxAmount = (Basket.FinalPriceTaxAmount - Basket.ShippingPrice.TaxAmount - Basket.OrderHandlingPrice.TaxAmount)

        If Basket.PricesIncTax Then
            If APP_ShowTaxDisplay Then
                phdMiniBasketTotal.Visible = False
                litMiniBasketTax1.Text = GetGlobalResourceObject("Kartris", "ContentText_MinibasketExTax") & "&nbsp;<span class=""price"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceExTax) & "</span>"
                litMiniBasketTax2.Text = GetGlobalResourceObject("Kartris", "ContentText_MinibasketIncludingTax") & "&nbsp;<span class=""total"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceIncTax) & "</span>"
            Else
                phdMiniBasketTax.Visible = False
                litMiniBasketTotal.Text = GetGlobalResourceObject("Kartris", "ContentText_MinibasketTotal") & "&nbsp;<span class=""total"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceIncTax) & "</span>"
            End If
        Else
            If APP_ShowTaxDisplay Then
                phdMiniBasketTotal.Visible = False
                litMiniBasketTax1.Text = GetGlobalResourceObject("Kartris", "ContentText_MinibasketTotal") & "&nbsp;<span class=""total"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceExTax) & "</span>"
                litMiniBasketTax2.Text = GetGlobalResourceObject("Kartris", "ContentText_Tax") & "&nbsp;<span class=""price"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceTaxAmount) & "</span>"
            Else
                phdMiniBasketTax.Visible = False
                litMiniBasketTotal.Text = GetGlobalResourceObject("Kartris", "ContentText_MinibasketTotal") & "&nbsp;<span class=""total"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceExTax) & "</span>"
            End If
        End If

        'Build up string for compact basket, if enabled
        litCompactShoppingBasket.Text = "<a href=""" & CkartrisBLL.WebShopURL & "Basket.aspx" & """><span id=""compactbasket_title"">" & GetGlobalResourceObject("Basket", "PageTitle_ShoppingBasket") & "</span>" & vbCrLf
        litCompactShoppingBasket.Text &= "<span id=""compactbasket_noofitems"">(" & numTotalItems.ToString & ")</span>" & vbCrLf

        If Basket.PricesIncTax Then
            litCompactShoppingBasket.Text &= "<span id=""compactbasket_totalprice"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceIncTax) & "</span>" & vbCrLf
        Else
            litCompactShoppingBasket.Text &= "<span id=""compactbasket_totalprice"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceExTax) & "</span>" & vbCrLf
        End If
        litCompactShoppingBasket.Text &= "</a>" & vbCrLf

        'We have a second compact display which is turned on client side
        'by the foundation 'hide-for-large' rule
        litCompactShoppingBasket2.Text = litCompactShoppingBasket.Text

        'Set basket link for normal size screens
        litShoppingBasketTitle.Text = litCompactShoppingBasket.Text
        updPnlMiniBasket.Update()

    End Sub

    ''' <summary>
    ''' Prices update when quantities changed but need this to 
    ''' reload basket to pull up promotions
    ''' </summary>
    ''' <remarks></remarks>
    Sub btnRecalculate_Click() Handles btnRecalculate.Click
        LoadBasket()
    End Sub

    ''' <summary>
    ''' Change a quantity of an item in basket
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Sub QuantityChanged(ByVal sender As Object, ByVal e As EventArgs)
        Dim objQuantity As TextBox = sender.Parent.FindControl("txtQuantity")
        Dim objBasketID As HiddenField = sender.Parent.FindControl("hdfBasketID")

        If Not IsNumeric(objQuantity.Text) Then
            objQuantity.Text = "0"
            objQuantity.Focus()
        Else
            'Get the unit size for the product (integer and decimal ones)
            Dim strUnitSize As String = ObjectConfigBLL.GetValue("K:product.unitsize", CLng(CType(sender.Parent.FindControl("litProductID_H"), Literal).Text))
            Dim numQuantity As Single = CSng(objQuantity.Text)

            'We need to check if the quantity the user has changed to
            'confirms to the unitsize setting
            strUnitSize = Replace(strUnitSize, ",", ".") '' Will use the "." instead of "," (just in case wrongly typed)
            Dim numMod As Decimal = CkartrisDataManipulation.SafeModulus(numQuantity, strUnitSize)
            If numMod <> 0D Then
                'wrong quantity - quantity should be a multiplies of unit size
                ShowPopup(GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors"), _
                        Replace(GetGlobalResourceObject("ObjectConfig", "ContentText_OrderMultiplesOfUnitsize"), "[unitsize]", strUnitSize))
                numQuantity = (numQuantity - CkartrisDataManipulation.SafeModulus(numQuantity, strUnitSize))
            End If

            'Update basket with new quantity
            Try
                BasketBLL.UpdateQuantity(CInt(objBasketID.Value), numQuantity)
            Catch ex As Exception
            End Try

            'Show warning if quantities were updated or fixed
            'due to stock level issue
            Try
                phdOutOfStockElectronic.Visible = Basket.AdjustedForElectronic
                phdOutOfStock.Visible = Basket.AdjustedQuantities
            Catch ex As Exception
            End Try

            'order weight or value changed, so need to refresh
            'the shipping options available and force reselection
            RefreshShippingMethods()

            Call LoadBasket()

            'refresh updatepanel
            updPnlMainBasket.Update()
        End If
    End Sub

    ''' <summary>
    ''' Remove an item from basket (click trash can
    ''' icon on row)
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Sub RemoveItem_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim numItemID As Long
        Dim strArgument As String
        Dim numRemoveVersionID As Integer = 0

        strArgument = E.CommandArgument

        Dim arrArguments() As String = strArgument.Split(";")
        numItemID = CLng(arrArguments(0))
        numRemoveVersionID = CLng(arrArguments(1))

        BasketBLL.DeleteBasketItems(CLng(numItemID))

        Call LoadBasket()

        updPnlMainBasket.Update()
    End Sub

    ''' <summary>
    ''' Remove coupon link click
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Sub RemoveCoupon_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim strCouponError As String = ""

        Call Basket.CalculateTotals()

        Call BasketBLL.CalculatePromotions(Basket, arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        Session("CouponCode") = ""
        Call BasketBLL.CalculateCoupon(Basket, "", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        BSKT_CustomerDiscount = BasketBLL.GetCustomerDiscount(numCustomerID)
        Call BasketBLL.CalculateCustomerDiscount(Basket, BSKT_CustomerDiscount)


        Call BasketBLL.CalculateOrderHandlingCharge(Basket, Session("numShippingCountryID"))

        updPnlMainBasket.Update()

    End Sub

    ''' <summary>
    ''' Click custom text link on customizable items
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Sub CustomText_Click(ByVal sender As Object, ByVal e As CommandEventArgs)
        Dim numItemID As Long
        Dim numCustomCost As Double
        Dim strCustomType As String = ""

        numItemID = e.CommandArgument
        hidBasketID.Value = numItemID

        For Each objItem As BasketItem In BasketItems
            If objItem.ID = numItemID Then
                numCustomCost = objItem.CustomCost
                litCustomCost.Text = CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), objItem.CustomCost)
                lblCustomDesc.Text = objItem.CustomDesc
                hidCustomVersionID.Value = objItem.VersionID
                txtCustomText.Text = objItem.CustomText
                strCustomType = objItem.CustomType
            End If
        Next

        'Hide cost line if zero
        If numCustomCost = 0 Then
            phdCustomizationPrice.Visible = False
        Else
            phdCustomizationPrice.Visible = True
        End If

        'Text Customization (Required)
        'Hide certain fields
        If strCustomType = "r" Then
            valCustomText.Visible = True
            phdCustomizationCancel.Visible = False
        Else
            valCustomText.Visible = False
            phdCustomizationCancel.Visible = True
        End If

        popCustomText.Show()
        updPnlCustomText.Update()
    End Sub

    ''' <summary>
    ''' Click the 'apply coupon' button
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Sub ApplyCoupon_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim strCouponError As String = ""

        Call Basket.CalculateTotals()

        Call BasketBLL.CalculatePromotions(Basket, arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        Call BasketBLL.CalculateCoupon(Basket, Trim(txtCouponCode.Text), strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))
        If strCouponError <> "" Then
            With popMessage
                .SetTitle = GetGlobalResourceObject("Basket", "PageTitle_ShoppingBasket")
                .SetTextMessage = strCouponError
                .SetWidthHeight(400, 140)
                .ShowPopup()
            End With
        Else
            Session("CouponCode") = Trim(txtCouponCode.Text)
        End If

        BSKT_CustomerDiscount = BasketBLL.GetCustomerDiscount(numCustomerID)
        Call BasketBLL.CalculateCustomerDiscount(Basket, BSKT_CustomerDiscount)


        Call BasketBLL.CalculateOrderHandlingCharge(Basket, Session("numShippingCountryID"))

        updPnlMainBasket.Update()

        Call RefreshMiniBasket()
    End Sub

    ''' <summary>
    ''' Empty basket button click
    ''' </summary>
    Sub EmptyBasket_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        BasketBLL.DeleteBasket()
        Call LoadBasket()
        updPnlMainBasket.Update()
    End Sub

    ''' <summary>
    ''' Refresh mini basket by loading basket up
    ''' and displaying minibasket
    ''' </summary>
    Sub RefreshMiniBasket()
        Call LoadBasket()
        Call DisplayMiniBasket()
    End Sub

    ''' <summary>
    ''' Get semi-colon separated list of product IDs of
    ''' items in basket
    ''' </summary>
    Private Function GetProductIDs() As String
        Dim strProductIDs As String = ""

        If Not (BasketItems Is Nothing) Then
            For Each objItem As BasketItem In BasketItems
                strProductIDs = strProductIDs & objItem.ProductID & ";"
            Next
        End If

        Return strProductIDs
    End Function

    ''' <summary>
    ''' Get an item from basket using product ID
    ''' </summary>
    ''' <param name="numProductID"></param>
    Private Function GetBasketItemByProductID(ByVal numProductID As Integer) As BasketItem
        For Each Item As BasketItem In BasketItems
            If Item.ProductID = numProductID Then Return Item
        Next
        Return Nothing
    End Function

    ''' <summary>
    ''' Return shipping total including tax
    ''' </summary>
    Public Function ShippingTotalIncTax() As Double
        Return Basket.ShippingTotalIncTax
    End Function

    ''' <summary>
    ''' Find and set shipping country's ID
    ''' </summary>
    ''' <param name="numShippingID"></param>
    ''' <param name="numShippingAmount"></param>
    ''' <param name="numDestinationID"></param>
    ''' <remarks></remarks>
    Public Sub SetShipping(ByVal numShippingID As Integer, ByVal numShippingAmount As Double, ByVal numDestinationID As Integer)
        If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Or ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple" Then
            APP_PricesIncTax = False
            APP_ShowTaxDisplay = False
            APP_USMultiStateTax = True
        Else
            APP_PricesIncTax = LCase(GetKartConfig("general.tax.pricesinctax")) = "y"
            'For checkout, we show tax if showtax is set to 'y' or 'c'.
            'For other pages, only if it is set to 'y'.
            If ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then
                APP_ShowTaxDisplay = (LCase(GetKartConfig("frontend.display.showtax")) = "y") Or (LCase(GetKartConfig("frontend.display.showtax")) = "c")
            Else
                APP_ShowTaxDisplay = LCase(GetKartConfig("frontend.display.showtax")) = "y"
            End If
            APP_USMultiStateTax = False
        End If

        SESS_CurrencyID = Session("CUR_ID")

        Session("numShippingCountryID") = numDestinationID
        Basket.CalculateShipping(Val(HttpContext.Current.Session("LANG")), numShippingID, numShippingAmount, Session("numShippingCountryID"), ShippingDetails)

        BasketBLL.CalculateOrderHandlingCharge(Basket, Session("numShippingCountryID"))
        If Basket.OrderHandlingPrice.IncTax = 0 Then phdOrderHandling.Visible = False Else phdOrderHandling.Visible = True

        UpdatePromotionDiscount()

        Basket.Validate(False)

        Call Basket.CalculateTotals()

        Call BasketBLL.CalculatePromotions(Basket, arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        Dim strCouponError As String = ""
        Call BasketBLL.CalculateCoupon(Basket, Session("CouponCode") & "", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        BSKT_CustomerDiscount = BasketBLL.GetCustomerDiscount(numCustomerID)
        Call BasketBLL.CalculateCustomerDiscount(Basket, BSKT_CustomerDiscount)


        BasketItems = Basket.BasketItems

        rptBasket.DataSource = BasketItems
        rptBasket.DataBind()
        Session("Basket") = Basket
    End Sub

    ''' <summary>
    ''' Update promotion discount
    ''' country's ID
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub UpdatePromotionDiscount()
        For Each objItem As PromotionBasketModifier In arrPromotionsDiscount
            objItem.ApplyTax = Basket.ApplyTax
        Next

        rptPromotionDiscount.DataSource = arrPromotionsDiscount
        rptPromotionDiscount.DataBind()
    End Sub

    ''' <summary>
    ''' Set order handling charge based on shipping
    ''' country's ID
    ''' </summary>
    ''' <param name="numShippingCountryID"></param>
    ''' <remarks></remarks>
    Public Sub SetOrderHandlingCharge(ByVal numShippingCountryID As Integer)
        BasketBLL.CalculateOrderHandlingCharge(Basket, numShippingCountryID)
    End Sub

    ''' <summary>
    ''' Runs for each item in minibasket as bound
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub rptMiniBasket_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptMiniBasket.ItemDataBound
        For Each ctlMiniBasket As Control In e.Item.Controls

            Dim objItem As New BasketItem
            objItem = e.Item.DataItem

            Dim strURL, strOptions As String
            strURL = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, objItem.ProductID)
            strOptions = objItem.OptionLink

            'Only add options to URL if there are some
            If strOptions <> "0" And strOptions <> "" Then
                If strURL.Contains("?") Then
                    strURL = strURL & "&strOptions=" & strOptions
                Else
                    strURL = strURL & "?strOptions=" & strOptions
                End If
            End If

            'Set navigate URL of link control
            CType(e.Item.FindControl("lnkMiniBasketProduct"), HyperLink).NavigateUrl = strURL
        Next
    End Sub

    ''' <summary>
    ''' Runs for each item in basket as bound
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub rptBasket_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptBasket.ItemDataBound
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then

            objItem = e.Item.DataItem

            If LCase(objItem.ProductType) = "s" AndAlso String.IsNullOrEmpty(ObjectConfigBLL.GetValue("K:product.customcontrolname", objItem.ProductID)) Then
                CType(e.Item.FindControl("phdProductType1"), PlaceHolder).Visible = True
            Else
                CType(e.Item.FindControl("phdProductType2"), PlaceHolder).Visible = True
                If objItem.HasCombinations Then
                    CType(e.Item.FindControl("phdItemHasCombinations"), PlaceHolder).Visible = True
                Else
                    CType(e.Item.FindControl("phdItemHasNoCombinations"), PlaceHolder).Visible = True
                End If
            End If

            Dim strURL, strOptions As String
            strURL = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, objItem.ProductID)
            strOptions = objItem.OptionLink

            'Only add options to URL if there are some
            If strOptions <> "0" And strOptions <> "" Then
                If strURL.Contains("?") Then
                    strURL = strURL & "&strOptions=" & strOptions
                Else
                    strURL = strURL & "?strOptions=" & strOptions
                End If
            End If

            'Set navigate URL of link control
            CType(e.Item.FindControl("lnkProduct"), HyperLink).NavigateUrl = strURL

            If LCase(objItem.CustomType) <> "n" Then
                CType(e.Item.FindControl("lnkCustomize"), LinkButton).ToolTip = "(" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), objItem.CustomCost) & ")" & vbCrLf & objItem.CustomText
                CType(e.Item.FindControl("lnkCustomize"), LinkButton).Visible = True
            Else
                CType(e.Item.FindControl("lnkCustomize"), LinkButton).ToolTip = ""
                CType(e.Item.FindControl("lnkCustomize"), LinkButton).Visible = False
            End If

            If objItem.AdjustedQty Then
                CType(e.Item.FindControl("txtQuantity"), TextBox).CssClass = "quantity_changed"
            End If
        End If
    End Sub

    ''' <summary>
    ''' Click button to save custom text for items
    ''' that support this
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnSaveCustomText_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveCustomText.Click
        Dim numSessionID, numBasketID, numVersionID As Long
        Dim numQuantity As Double
        Dim strCustomText, strOptions As String

        If IsNumeric(hidBasketID.Value) Then numBasketID = CLng(hidBasketID.Value) Else numBasketID = 0
        If numBasketID > 0 Then ''// comes from basket
            numVersionID = CLng(hidCustomVersionID.Value)
            strCustomText = Trim(txtCustomText.Text)
            strCustomText = CkartrisDisplayFunctions.StripHTML(strCustomText)

            BasketBLL.SaveCustomText(numBasketID, strCustomText)

            For Each objItem As BasketItem In BasketItems
                If numBasketID = objItem.ID Then
                    objItem.CustomText = strCustomText
                End If
            Next

            rptBasket.DataSource = BasketItems
            rptBasket.DataBind()

            Call LoadBasket()

            updPnlMainBasket.Update()

        Else ''// comes from product page
            numSessionID = Session("SessionID")
            numVersionID = CLng(hidCustomVersionID.Value)
            numQuantity = CDbl(hidCustomQuantity.Value)
            strCustomText = Trim(txtCustomText.Text)
            strCustomText = CkartrisDisplayFunctions.StripHTML(strCustomText)
            strOptions = hidOptions.Value
            numBasketID = hidOptionBasketID.Value
            BasketBLL.AddNewBasketValue(Basket.BasketItems, BasketBLL.BASKET_PARENTS.BASKET, numSessionID, numVersionID, numQuantity, strCustomText, strOptions, numBasketID)

            ShowAddItemToBasket(numVersionID, numQuantity, True)
        End If
    End Sub

    ''' <summary>
    ''' Saves custom text for items that support it
    ''' </summary>
    ''' <param name="strCustomText"></param>
    ''' <param name="numItemID"></param>
    ''' <remarks></remarks>
    Private Sub SaveCustomText(ByVal strCustomText As String, Optional ByVal numItemID As Integer = 0)
        If numItemID = 0 Then
            numItemID = btnSaveCustomText.CommandArgument
        End If

        BasketBLL.SaveCustomText(numItemID, strCustomText)

        For Each objItem As BasketItem In BasketItems
            If numItemID = objItem.ID Then
                objItem.CustomText = strCustomText
            End If
        Next

        rptBasket.DataSource = BasketItems
        rptBasket.DataBind()

        updPnlMainBasket.Update()
    End Sub

    ''' <summary>
    ''' Shows popup for errors or events on minibasket. This can
    ''' be useful for pages where errors need to be flagged with
    ''' a popup as items are added to basket but break some rule
    ''' such as unitsize.
    ''' </summary>
    ''' <param name="strTitle"></param>
    ''' <param name="strMessage"></param>
    ''' <remarks></remarks>
    Public Sub ShowPopupMini(ByVal strTitle As String, strMessage As String)
        popMessage2.SetTitle = strTitle
        popMessage2.SetTextMessage = strMessage
        popMessage2.SetWidthHeight(330, 100)
        popMessage2.ShowPopup()
    End Sub

    ''' <summary>
    ''' Shows popup detailing errors or problems when on the main
    ''' basket page, such as changing qty to an amount which breaks
    ''' a rule such as unitsize.
    ''' </summary>
    ''' <param name="strTitle"></param>
    ''' <param name="strMessage"></param>
    ''' <remarks></remarks>
    Public Sub ShowPopup(strTitle As String, strMessage As String)
        litSubHeadingInformation.Text = strTitle
        litContentTextItemsAdded.Text = strMessage
        tmrAddToBasket.Enabled = False
        popAddToBasket.Show()
        updPnlAddToBasket.Update()
    End Sub

    ''' <summary>
    ''' Handles adding custom product items to basket, we don't
    ''' need to show popup here because productversions.ascx
    ''' already does this
    ''' </summary>
    ''' <param name="numVersionID"></param>
    ''' <param name="numQuantity"></param>
    ''' <param name="strParameterValues"></param>
    ''' <remarks></remarks>
    Public Sub AddCustomItemToBasket(ByVal numVersionID As Long, ByVal numQuantity As Double, ByVal strParameterValues As String)
        Dim sessionID As Long
        sessionID = Session("SessionID")
        BasketBLL.AddNewBasketValue(Basket.BasketItems, BasketBLL.BASKET_PARENTS.BASKET, sessionID, numVersionID, numQuantity, strParameterValues, "", 0)
        ShowAddItemToBasket(numVersionID, numQuantity, True)
    End Sub

    ''' <summary>
    ''' Shows custom text for an item in basket
    ''' </summary>
    ''' <param name="numVersionID"></param>
    ''' <param name="numQuantity"></param>
    ''' <param name="strOptions"></param>
    ''' <param name="numBasketValueID"></param>
    ''' <remarks></remarks>
    Public Sub ShowCustomText(ByVal numVersionID As Long, ByVal numQuantity As Double, Optional ByVal strOptions As String = "", Optional ByVal numBasketValueID As Integer = 0)
        Dim strCustomType As String
        Dim tblCustomization As DataTable = BasketBLL.GetCustomization(numVersionID)
        Dim sessionID As Long

        If tblCustomization.Rows.Count > 0 Then
            strCustomType = LCase(tblCustomization.Rows(0).Item("V_CustomizationType"))
            If strCustomType <> "n" Then
                If strCustomType = "t" Or strCustomType = "r" Then
                    'Text Customization
                    '(Optional or Required)
                    hidBasketID.Value = "0"
                    hidOptionBasketID.Value = numBasketValueID
                    hidCustomType.Value = strCustomType
                    hidCustomVersionID.Value = numVersionID
                    hidCustomQuantity.Value = numQuantity
                    hidOptions.Value = strOptions
                    litCustomCost.Text = CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), tblCustomization.Rows(0).Item("V_CustomizationCost")))
                    lblCustomDesc.Text = tblCustomization.Rows(0).Item("V_CustomizationDesc") & ""

                    Dim strCustomText As String = ""
                    For Each objBasketItem As BasketItem In Basket.BasketItems
                        If objBasketItem.ID = numBasketValueID Then
                            strCustomText = objBasketItem.CustomText
                            Exit For
                        End If
                    Next
                    txtCustomText.Text = strCustomText

                    'Hide cost line if zero
                    If tblCustomization.Rows(0).Item("V_CustomizationCost") = 0 Then
                        phdCustomizationPrice.Visible = False
                    Else
                        phdCustomizationPrice.Visible = True
                    End If

                    'Text Customization (Required)
                    'Hide certain fields
                    If strCustomType = "r" Then
                        valCustomText.Visible = True
                        phdCustomizationCancel.Visible = False
                    Else
                        valCustomText.Visible = False
                        phdCustomizationCancel.Visible = True
                    End If
                End If
                popCustomText.Show()
                updPnlCustomText.Update()
            Else
                sessionID = Session("SessionID")
                BasketBLL.AddNewBasketValue(Basket.BasketItems, BasketBLL.BASKET_PARENTS.BASKET, sessionID, numVersionID, numQuantity, "", strOptions, numBasketValueID)
                Dim strUpdateBasket As String = GetGlobalResourceObject("Basket", "ContentText_ItemsUpdated")
                If strUpdateBasket = "" Then strUpdateBasket = "The item(s) were updated to your basket."
                litContentTextItemsAdded.Text = IIf(numBasketValueID > 0, strUpdateBasket, GetGlobalResourceObject("Basket", "ContentText_ItemsAdded"))
                If strOptions <> "" Then
                    ShowAddItemToBasket(numVersionID, numQuantity, True)
                Else
                    ShowAddItemToBasket(numVersionID, numQuantity)
                End If
            End If
        End If
    End Sub

    ''' <summary>
    ''' Cancel button on custom text dialog. If this is pushed, the
    ''' item is added to the basket without customization.
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnCancelCustomText_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancelCustomText.Click
        Dim numSessionID As Long
        Dim numBasketID, numVersionID As Long
        Dim numQuantity As Double
        Dim strOptions As String

        If IsNumeric(hidBasketID.Value) Then numBasketID = CLng(hidBasketID.Value) Else numBasketID = 0

        If numBasketID = 0 Then

            numSessionID = Session("SessionID")
            numVersionID = CLng(hidCustomVersionID.Value)
            numQuantity = CDbl(hidCustomQuantity.Value)
            strOptions = hidOptions.Value

            BasketBLL.AddNewBasketValue(Basket.BasketItems, BasketBLL.BASKET_PARENTS.BASKET, numSessionID, numVersionID, numQuantity, "", strOptions)

            ShowAddItemToBasket(numVersionID, numQuantity)
        End If
    End Sub

    ''' <summary>
    ''' Show 'add to basket' shows for items where this
    ''' is not triggered by client-side javascript, such as options
    ''' products (which need error checking on whether required options
    ''' were selected)
    ''' </summary>
    ''' <param name="numVersionID"></param>
    ''' <param name="numQuantity"></param>
    ''' <param name="blnDisplayPopup"></param>
    ''' <remarks></remarks>
    Private Sub ShowAddItemToBasket(ByVal numVersionID As Integer, ByVal numQuantity As Double, Optional ByVal blnDisplayPopup As Boolean = False)

        Dim tblVersion As DataTable
        tblVersion = VersionsBLL._GetVersionByID(numVersionID)
        If tblVersion.Rows.Count > 0 Then
            ''// add basket item quantity to new item qty and check for stock
            Dim numBasketQty As Double = 0
            For Each itmBasket As BasketItem In BasketItems
                If numVersionID = itmBasket.VersionID Then
                    numBasketQty = itmBasket.Quantity
                    Exit For
                End If
            Next
            If tblVersion.Rows(0).Item("V_QuantityWarnLevel") > 0 And (numBasketQty + numQuantity) > tblVersion.Rows(0).Item("V_Quantity") And KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock") <> "y" Then
                Response.Redirect("~/Basket.aspx")
            End If
        End If

        'This section below we now only
        'need to run for options products
        Dim strBasketBehavior As String
        strBasketBehavior = LCase(KartSettingsManager.GetKartConfig("frontend.basket.behaviour"))

        If blnDisplayPopup = True Then

            If IsNumeric(strBasketBehavior) Then
                popAddToBasket.Show()
                tmrAddToBasket.Interval = CDbl(strBasketBehavior) * 1000
                tmrAddToBasket.Enabled = True
                updPnlAddToBasket.Update()
            ElseIf strBasketBehavior = "y" Then
                tmrAddToBasket.Enabled = False
                Response.Redirect("~/Basket.aspx")
            Else
                tmrAddToBasket.Enabled = False
            End If
        Else
            'Got to handle redirect to basket
            'for products that use the js
            'code to speed up the 'add to basket'
            'dis
            If strBasketBehavior = "y" Then
                Response.Redirect("~/Basket.aspx")
            End If
        End If
    End Sub

    ''' <summary>
    ''' Timer for how long 'add to basket' shows for items where this
    ''' is not triggered by client-side javascript, such as options
    ''' products (which need error checking on whether required options
    ''' were selected)
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub tmrAddToBasket_Tick(ByVal sender As Object, ByVal e As System.EventArgs) Handles tmrAddToBasket.Tick
        tmrAddToBasket.Enabled = False
        popAddToBasket.Hide()
    End Sub

    ''' <summary>
    ''' Set shipping when a choice is made from the shipping
    ''' dropdown menu
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub UC_ShippingMethodsDropdown_ShippingSelected(ByVal sender As Object, ByVal e As System.EventArgs) Handles UC_ShippingMethodsDropdown.ShippingSelected
        SetShipping(UC_ShippingMethodsDropdown.SelectedShippingID, UC_ShippingMethodsDropdown.SelectedShippingAmount, ShippingDestinationID)
        updPnlMainBasket.Update()
    End Sub

    ''' <summary>
    ''' Refresh shipping methods - use this when a new
    ''' selection is chosen, as this may change what
    ''' shipping options are available
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub RefreshShippingMethods()
        SetShipping(UC_ShippingMethodsDropdown.SelectedShippingID, UC_ShippingMethodsDropdown.SelectedShippingAmount, ShippingDestinationID)

        UC_ShippingMethodsDropdown.DestinationID = ShippingDestinationID
        UC_ShippingMethodsDropdown.Boundary = ShippingBoundary
        UC_ShippingMethodsDropdown.ShippingDetails = ShippingDetails
        UC_ShippingMethodsDropdown.Refresh()

        updPnlMainBasket.Update()
    End Sub

End Class
