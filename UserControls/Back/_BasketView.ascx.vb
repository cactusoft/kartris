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
Imports System.Collections.Generic
Imports GCheckout.Checkout
Imports GCheckout.Util
Imports System.Threading
Imports System.Globalization
Imports CkartrisBLL
Imports KartSettingsManager

Partial Class Back_BasketView
    Inherits System.Web.UI.UserControl

    Protected Shared BSKT_CustomerDiscount As Double

    Private Shared arrPromotionsDiscount As New ArrayList
    Protected objCurrency As New CurrenciesBLL
    Protected objItem As New BasketItem
    Protected blnAdjusted As Boolean
    Protected SESS_CurrencyID As Integer
    Protected APP_PricesIncTax, APP_ShowTaxDisplay, APP_USMultiStateTax As Boolean

    Private arrPromotions As New ArrayList
    Private numCustomerID As Integer
    Private _objShippingDetails As Interfaces.objShippingDetails

    Private _ViewType As BasketBLL.VIEW_TYPE = BasketBLL.VIEW_TYPE.MAIN_BASKET
    Private _ViewOnly As Boolean

    Private blnShowPromotion As Boolean = True

    Public Shared ReadOnly Property Basket() As BasketBLL
        Get
            If HttpContext.Current.Session("Basket") Is Nothing Then HttpContext.Current.Session("Basket") = New BasketBLL
            Return HttpContext.Current.Session("Basket")
        End Get
    End Property

    Public Shared Property BasketItems() As ArrayList
        Get
            If HttpContext.Current.Session("_BasketItems") Is Nothing Then HttpContext.Current.Session("_BasketItems") = New ArrayList
            Return HttpContext.Current.Session("_BasketItems")
        End Get
        Set(ByVal value As ArrayList)
            HttpContext.Current.Session("_BasketItems") = value
        End Set
    End Property

    Public ReadOnly Property GetBasket() As BasketBLL
        Get
            Return Basket
        End Get
    End Property

    Public ReadOnly Property GetBasketItems() As ArrayList
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
            End If
            Return _objShippingDetails
        End Get
        Set(ByVal value As Interfaces.objShippingDetails)
            _objShippingDetails = value
            _objShippingDetails.ShippableItemsTotalWeight = Basket.ShippingTotalWeight
            _objShippingDetails.ShippableItemsTotalPrice = Basket.ShippingTotalExTax
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
                If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y" Then
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

    Sub LoadBasket()
        SESS_CurrencyID = Session("CUR_ID")
        Dim blnIsInCheckout As Boolean = True
        
        Basket.DB_C_CustomerID = numCustomerID

        Call Basket.LoadBasketItems()
        BasketItems = Basket.GetItems

        If BasketItems.Count = 0 Then
            litBasketEmpty.Text = GetGlobalResourceObject("Basket", "ContentText_BasketEmpty")
        Else
            litBasketEmpty.Text = ""
            phdBasket.Visible = True
        End If

        Call Basket.Validate(False)

        rptBasket.DataSource = BasketItems
        rptBasket.DataBind()

        Call Basket.CalculateTotals()

        Call Basket.CalculatePromotions(arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        Dim strCouponError As String = ""
        Call Basket.CalculateCoupon(CouponCode & "", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        BSKT_CustomerDiscount = Basket.GetCustomerDiscount(numCustomerID)
        Call Basket.CalculateCustomerDiscount(BSKT_CustomerDiscount)

        Call Basket.CalculateOrderHandlingCharge(Session("numShippingCountryID"))

        phdShipping.Visible = True
        UC_ShippingMethodsDropdown.Visible = True

        If blnIsInCheckout Then
            SetShipping(UC_ShippingMethodsDropdown.SelectedShippingID, UC_ShippingMethodsDropdown.SelectedShippingAmount, ShippingDestinationID)
        End If

        If Basket.OrderHandlingPrice.IncTax = 0 Or ViewType <> BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then phdOrderHandling.Visible = False Else phdOrderHandling.Visible = True

        Try
            phdOutOfStockElectronic.Visible = Basket.AdjustedForElectronic
            phdOutOfStock.Visible = Basket.AdjustedQuantities
        Catch ex As Exception
        End Try

        Session("Basket") = Basket

    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        SESS_CurrencyID = Session("CUR_ID")

        If ConfigurationManager.AppSettings("TaxRegime").tolower = "us" Then
            APP_PricesIncTax = False
            APP_ShowTaxDisplay = False
            APP_USMultiStateTax = True
        Else
            APP_PricesIncTax = LCase(GetKartConfig("general.tax.pricesinctax")) = "y"
            APP_ShowTaxDisplay = LCase(GetKartConfig("frontend.display.showtax")) = "y"
            APP_USMultiStateTax = False
        End If

        litError.Text = ""

        If Not (IsPostBack) Then
            Call LoadBasket()
        Else
            If Basket.OrderHandlingPrice.IncTax = 0 Or ViewType <> BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then phdOrderHandling.Visible = False Else phdOrderHandling.Visible = True
        End If

        tmrAddToBasket.Enabled = False

    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender

        If ViewType = BasketBLL.VIEW_TYPE.MAIN_BASKET Then
            phdMainBasket.Visible = True
            phdControls.Visible = True
            phdBasketButtons.Visible = True
        ElseIf ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET Then
            phdControls.Visible = False
            
            If Not _ViewOnly Then phdShippingSelection.Visible = True
        End If

        If ViewType = BasketBLL.VIEW_TYPE.CHECKOUT_BASKET And ViewOnly Then
            rptBasket.DataSource = BasketItems
            rptBasket.DataBind()
        End If

        blnShowPromotion = True
        phdPromotions.Visible = True

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
                    Basket.UpdateQuantity(objItem.ID, objItem.StockQty)
                End If
            Next
        End If

        Session("Basket") = Basket
    End Sub

    Public Sub LoadMiniBasket()
        Call LoadBasket()
        Call DisplayMiniBasket()
    End Sub

    Sub DisplayMiniBasket()
        Dim vFinalPriceExTax, vFinalPriceIncTax, vFinalPriceTaxAmount As Double

        rptMiniBasket.DataSource = BasketItems
        rptMiniBasket.DataBind()

        If BasketItems Is Nothing OrElse BasketItems.Count = 0 Then
            phdMiniBasketContent.Visible = False
            phdMiniBasketEmpty.Visible = True
            If BasketItems Is Nothing Then litNumberOfItems.Text = "0" Else litNumberOfItems.Text = BasketItems.Count
        Else
            litNumberOfItems.Text = Basket.TotalItems
            phdMiniBasketEmpty.Visible = False
        End If

        phdMiniBasketPromotions.Visible = IIf(Basket.PromotionDiscount.IncTax = 0, False, True)
        phdMiniBasketCouponDiscount.Visible = IIf(Basket.CouponDiscount.IncTax = 0, False, True)
        phdMiniBasketCustomerDiscount.Visible = IIf(BSKT_CustomerDiscount <> 0, True, False)

        lnkMiniBasketPromotions.NavigateUrl = "/" & WebShopFolder() & "Basket.aspx"
        lnkMiniBasketCouponDiscount.NavigateUrl = "/" & WebShopFolder() & "Basket.aspx"
        lnkMiniBasketCustomerDiscount.NavigateUrl = "/" & WebShopFolder() & "Basket.aspx"

        If ConfigurationManager.AppSettings("TaxRegime").tolower = "us" Then
            APP_ShowTaxDisplay = False
            APP_USMultiStateTax = True
        Else
            APP_ShowTaxDisplay = LCase(GetKartConfig("frontend.display.showtax")) = "y"
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
        If KartSettingsManager.GetKartConfig("frontend.minibasket.compactversion") = "y" Then
            litCompactShoppingBasket.Text = "<span id=""compactbasket_title""><a href=""" & CkartrisBLL.WebShopURL & "Basket.aspx" & """>" & GetGlobalResourceObject("Basket", "PageTitle_ShoppingBasket") & "</a></span>" & vbCrLf
            litCompactShoppingBasket.Text &= "<span id=""compactbasket_noofitems"">(" & Basket.TotalItems.ToString & ")</span>" & vbCrLf

            If Basket.PricesIncTax Then
                litCompactShoppingBasket.Text &= "<span id=""compactbasket_totalprice"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceIncTax) & "</span>" & vbCrLf
            Else
                litCompactShoppingBasket.Text &= "<span id=""compactbasket_totalprice"">" & CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), vFinalPriceExTax) & "</span>" & vbCrLf
            End If
        End If


        updPnlMiniBasket.Update()

    End Sub

    Sub QuantityChanged(ByVal Sender As Object, ByVal Args As EventArgs)
        Dim objQuantity As TextBox = Sender.Parent.FindControl("txtQuantity")
        Dim objBasketID As HiddenField = Sender.Parent.FindControl("hdfBasketID")

        If Not IsNumeric(objQuantity.Text) Then
            objQuantity.Text = "0"
            objQuantity.Focus()
        Else
            Try
                Basket.UpdateQuantity(CInt(objBasketID.Value), CSng(objQuantity.Text))
            Catch ex As Exception
            End Try
        End If

        Call LoadBasket()

        Try
            phdOutOfStockElectronic.Visible = Basket.AdjustedForElectronic
            phdOutOfStock.Visible = Basket.AdjustedQuantities
        Catch ex As Exception
        End Try


        updPnlMainBasket.Update()

        'RaiseEvent ItemQuantityChanged()

    End Sub

    Sub RemoveItem_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim numItemID As Long
        Dim strArgument As String
        Dim numRemoveVersionID As Integer = 0

        strArgument = E.CommandArgument

        Dim arrArguments() As String = strArgument.Split(";")
        numItemID = CLng(arrArguments(0))
        numRemoveVersionID = CLng(arrArguments(1))

        Basket.DeleteBasketItems(CLng(numItemID))

        Call LoadBasket()

        updPnlMainBasket.Update()

    End Sub

    Sub RemoveCoupon_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim strCouponError As String = ""

        Call Basket.CalculateTotals()

        Call Basket.CalculatePromotions(arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        Session("CouponCode") = ""
        Call Basket.CalculateCoupon("", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        BSKT_CustomerDiscount = Basket.GetCustomerDiscount(numCustomerID)
        Call Basket.CalculateCustomerDiscount(BSKT_CustomerDiscount)

        Call Basket.CalculateOrderHandlingCharge(Session("numShippingCountryID"))

        updPnlMainBasket.Update()

    End Sub

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

    Sub ProductName_Click(ByVal sender As Object, ByVal e As CommandEventArgs)
        Dim strItemInfo As String

        strItemInfo = e.CommandArgument

        If strItemInfo <> "" Then
            Try
                Dim arrInfo As String() = Split(strItemInfo, ";")
                If arrInfo(UBound(arrInfo)) <> "o" Then
                    strItemInfo = ""
                End If
            Catch ex As Exception
            End Try
        End If

        Session("BasketItemInfo") = strItemInfo

        Dim strURL As String = e.CommandName
        Response.Redirect(strURL)

    End Sub

    Sub ApplyCoupon_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Dim strCouponError As String = ""

        Call Basket.CalculateTotals()

        Call Basket.CalculatePromotions(arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        Call Basket.CalculateCoupon(Trim(txtCouponCode.Text), strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))
        If strCouponError <> "" Then
            With popMessage
                .SetTitle = GetGlobalResourceObject("Basket", "PageTitle_ShoppingBasket")
                .SetTextMessage = strCouponError
                .SetWidthHeight(300, 50)
                .ShowPopup()
            End With
        Else
            Session("CouponCode") = Trim(txtCouponCode.Text)
        End If

        BSKT_CustomerDiscount = Basket.GetCustomerDiscount(numCustomerID)
        Call Basket.CalculateCustomerDiscount(BSKT_CustomerDiscount)

        Call Basket.CalculateOrderHandlingCharge(Session("numShippingCountryID"))

        updPnlMainBasket.Update()

        Call RefreshMiniBasket()

    End Sub

    Sub EmptyBasket_Click(ByVal Sender As Object, ByVal E As CommandEventArgs)
        Basket.DeleteBasket()
        Call LoadBasket()
        updPnlMainBasket.Update()
    End Sub

    Sub RefreshMiniBasket()
        Call LoadBasket()
        Call DisplayMiniBasket()
    End Sub

    Private Function GetProductIDs() As String
        Dim strProductIDs As String = ""

        If Not (BasketItems Is Nothing) Then
            For Each objItem As BasketItem In BasketItems
                strProductIDs = strProductIDs & objItem.ProductID & ";"
            Next
        End If

        Return strProductIDs
    End Function

    Private Function GetBasketItemByProductID(ByVal numProductID As Integer) As BasketItem

        For Each Item As BasketItem In BasketItems
            If Item.ProductID = numProductID Then Return Item
        Next

        Return Nothing
    End Function

    Public Function ShippingTotalIncTax() As Double
        Return Basket.ShippingTotalIncTax
    End Function

    Public Sub SetShipping(ByVal numShippingID As Integer, ByVal numShippingAmount As Double, ByVal numDestinationID As Integer)

        If ConfigurationManager.AppSettings("TaxRegime").tolower = "us" Then
            APP_PricesIncTax = False
            APP_ShowTaxDisplay = False
            APP_USMultiStateTax = True
        Else
            APP_PricesIncTax = LCase(GetKartConfig("general.tax.pricesinctax")) = "y"
            APP_ShowTaxDisplay = LCase(GetKartConfig("frontend.display.showtax")) = "y"
            APP_USMultiStateTax = False
        End If

        SESS_CurrencyID = Session("CUR_ID")

        Session("numShippingCountryID") = numDestinationID
        Basket.CalculateShipping(Val(HttpContext.Current.Session("LANG")), numShippingID, numShippingAmount, Session("numShippingCountryID"), ShippingDetails)

        Basket.CalculateOrderHandlingCharge(Session("numShippingCountryID"))
        If Basket.OrderHandlingPrice.IncTax = 0 Then phdOrderHandling.Visible = False Else phdOrderHandling.Visible = True

        UpdatePromotionDiscount()

        Basket.Validate(False)

        Call Basket.CalculateTotals()

        Call Basket.CalculatePromotions(arrPromotions, arrPromotionsDiscount, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        Dim strCouponError As String = ""
        Call Basket.CalculateCoupon(Session("CouponCode") & "", strCouponError, (APP_PricesIncTax = False And APP_ShowTaxDisplay = False))

        BSKT_CustomerDiscount = Basket.GetCustomerDiscount(numCustomerID)
        Call Basket.CalculateCustomerDiscount(BSKT_CustomerDiscount)

        BasketItems = Basket.GetItems

        rptBasket.DataSource = BasketItems
        rptBasket.DataBind()
        Session("Basket") = Basket
    End Sub

    Private Sub UpdatePromotionDiscount()

        For Each objItem As PromotionBasketModifier In arrPromotionsDiscount
            objItem.ApplyTax = Basket.ApplyTax
            objItem.ExTax = objItem.ExTax
            objItem.IncTax = objItem.IncTax
        Next

        rptPromotionDiscount.DataSource = arrPromotionsDiscount
        rptPromotionDiscount.DataBind()

    End Sub

    Public Sub SetOrderHandlingCharge(ByVal numShippingCountryID As Integer)

        Basket.CalculateOrderHandlingCharge(numShippingCountryID)

    End Sub

    Protected Sub rptMiniBasket_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptMiniBasket.ItemDataBound

        For Each ctlMiniBasket As Control In e.Item.Controls
            Select Case ctlMiniBasket.ID
                Case "lnkProduct", "lnkBtnProduct"
                    Dim objItem As New BasketItem
                    objItem = e.Item.DataItem

                    Dim strURL As String
                    strURL = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, objItem.ProductID)
                    If strURL.Contains("?") Then
                        strURL = strURL & objItem.OptionLink
                    Else
                        strURL = strURL & Replace(objItem.OptionLink, "&", "?")
                    End If
                    CType(e.Item.FindControl("lnkBtnProduct"), LinkButton).CommandName = strURL
                Case Else

            End Select
        Next

    End Sub

    Protected Sub rptBasket_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptBasket.ItemDataBound

        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then

            objItem = e.Item.DataItem

            If LCase(objItem.ProductType) = "s" Then
                CType(e.Item.FindControl("phdProductType1"), PlaceHolder).Visible = True
            Else
                CType(e.Item.FindControl("phdProductType2"), PlaceHolder).Visible = True
                If objItem.HasCombinations Then
                    CType(e.Item.FindControl("phdItemHasCombinations"), PlaceHolder).Visible = True
                Else
                    CType(e.Item.FindControl("phdItemHasNoCombinations"), PlaceHolder).Visible = True
                End If
            End If

            Dim strURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, objItem.ProductID)
            If strURL.Contains("?") Then
                strURL = strURL & objItem.OptionLink
            Else
                strURL = strURL & Replace(objItem.OptionLink, "&", "?")
            End If
            CType(e.Item.FindControl("lnkBtnProductName"), LinkButton).CommandName = strURL

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

    Protected Sub btnSaveCustomText_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveCustomText.Click
        Dim numSessionID, numBasketID, numVersionID As Long
        Dim numQuantity As Double
        Dim strCustomText, strOptions As String

        If IsNumeric(hidBasketID.Value) Then numBasketID = CLng(hidBasketID.Value) Else numBasketID = 0
        If numBasketID > 0 Then ''// comes from basket
            numVersionID = CLng(hidCustomVersionID.Value)
            strCustomText = Trim(txtCustomText.Text)
            strCustomText = CkartrisDisplayFunctions.StripHTML(strCustomText)

            Basket.SaveCustomText(numBasketID, strCustomText)

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
            Basket.AddNewBasketValue(BasketBLL.BASKET_PARENTS.BASKET, numSessionID, numVersionID, numQuantity, strCustomText, strOptions, numBasketID)

            ShowAddItemToBasket(numVersionID, numQuantity, True)

        End If

    End Sub

    Private Sub SaveCustomText(ByVal strCustomText As String, Optional ByVal numItemID As Integer = 0)

        If numItemID = 0 Then
            numItemID = btnSaveCustomText.CommandArgument
        End If

        Basket.SaveCustomText(numItemID, strCustomText)

        For Each objItem As BasketItem In BasketItems
            If numItemID = objItem.ID Then
                objItem.CustomText = strCustomText
            End If
        Next

        rptBasket.DataSource = BasketItems
        rptBasket.DataBind()

        updPnlMainBasket.Update()

    End Sub

    Public Sub ShowCustomText(ByVal numVersionID As Long, ByVal numQuantity As Double, Optional ByVal strOptions As String = "", Optional ByVal numBasketValueID As Integer = 0)
        Dim strCustomType As String
        Dim tblCustomization As DataTable = Basket.GetCustomization(numVersionID)
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
                Basket.AddNewBasketValue(BasketBLL.BASKET_PARENTS.BASKET, sessionID, numVersionID, numQuantity, "", strOptions, numBasketValueID)
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

    Private Sub ShowAddItemToBasket(ByVal VersionID As Integer, ByVal Quantity As Double, Optional ByVal blnDisplayPopup As Boolean = False)

        Dim tblVersion As DataTable
        tblVersion = VersionsBLL._GetVersionByID(VersionID)
        If tblVersion.Rows.Count > 0 Then
            ''// add basket item quantity to new item qty and check for stock
            Dim numBasketQty As Double = 0
            For Each itmBasket As BasketItem In BasketItems
                If VersionID = itmBasket.VersionID Then
                    numBasketQty = itmBasket.Quantity
                    Exit For
                End If
            Next
            If tblVersion.Rows(0).Item("V_QuantityWarnLevel") > 0 And (numBasketQty + Quantity) > tblVersion.Rows(0).Item("V_Quantity") Then
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

    Protected Sub tmrAddToBasket_Tick(ByVal sender As Object, ByVal e As System.EventArgs) Handles tmrAddToBasket.Tick
        tmrAddToBasket.Enabled = False
        popAddToBasket.Hide()
    End Sub

    Function SendOutputWithoutHTMLTags(ByVal strInput As String) As String
        Dim strNewString As String = ""

        For n As Integer = 1 To Len(strInput)
            If Mid(strInput, n, 1) = "<" Then
                While Mid(strInput, n, 1) <> ">"
                    n = n + 1
                End While
                n = n + 1
            End If
            strNewString = strNewString & Mid(strInput, n, 1)
        Next
        Return strNewString
    End Function

    Protected Sub UC_ShippingMethodsDropdown_ShippingSelected(ByVal sender As Object, ByVal e As System.EventArgs) Handles UC_ShippingMethodsDropdown.ShippingSelected
        SetShipping(UC_ShippingMethodsDropdown.SelectedShippingID, UC_ShippingMethodsDropdown.SelectedShippingAmount, ShippingDestinationID)
        updPnlMainBasket.Update()

    End Sub

    Public Sub RefreshShippingMethods()
        UC_ShippingMethodsDropdown.DestinationID = ShippingDestinationID
        UC_ShippingMethodsDropdown.Boundary = ShippingBoundary
        UC_ShippingMethodsDropdown.ShippingDetails = ShippingDetails
        UC_ShippingMethodsDropdown.Refresh()

        SetShipping(UC_ShippingMethodsDropdown.SelectedShippingID, UC_ShippingMethodsDropdown.SelectedShippingAmount, ShippingDestinationID)

        updPnlMainBasket.Update()

    End Sub

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

            Basket.AddNewBasketValue(BasketBLL.BASKET_PARENTS.BASKET, numSessionID, numVersionID, numQuantity, "", strOptions)

            ShowAddItemToBasket(numVersionID, numQuantity)

        End If

    End Sub
End Class
