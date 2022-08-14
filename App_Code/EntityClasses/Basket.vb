Imports Microsoft.VisualBasic
Imports System.Web.HttpContext

Namespace Kartris
    ''' <summary>
    ''' The customer basket which will contain zero or more basket items (rows)
    ''' </summary>
    ''' <remarks></remarks>
    <Serializable()> _
    Public Class Basket

        Public DB_C_CustomerID As Integer           ' Customer ID (User ID) that owns this basket

        ' Basket modifiers. These affect the entire basket in one hit.
        Public ShippingPrice As BasketModifier
        Public OrderHandlingPrice As BasketModifier
        Public CouponDiscount As BasketModifier
        Public CustomerDiscount As BasketModifier
        Public PromotionDiscount As BasketModifier

        Public Property CustomerDiscountPercentage() As Double

        ''' <summary>
        ''' All of the items that are in the basket
        ''' </summary>
        ''' <remarks></remarks>
        Private _BasketItems As List(Of Kartris.BasketItem)

        Private _AllFreeShipping, _HasFreeShipping, _PricesIncTax, _AllDigital, _HasCustomerDiscountExemption As Boolean
        Private _TotalWeight, _TotalExTax, _TotalTaxAmount, _TotalAmountSaved As Double
        Private _TotalItems As Single
        Private _ShippingTotalWeight, _ShippingTotalExTax, _ShippingTotalTaxAmount As Double

        Private _TotalDiscountPriceIncTax, _TotalDiscountPriceExTax As Double
        Private _TotalDiscountPriceTaxAmount, _TotalDiscountPriceTaxRate As Double

        'v2.9010 added way to exclude items from customer discount
        'Often we have mods which require calculating a subtotal of 
        'cart items. We'll create variables here for this, but these
        'could be used for other custom mods in future requiring
        'similar.
        Private _SubTotalExTax, _SubTotalTaxAmount As Double

        Private _TotalIncTax, _TotalTaxRate, _DTax, _DTax2 As Double
        Private _DTaxExtra As String

        Private _LastIndex, _HighlightLowStockRowNumber As Integer
        Private _AdjustedForElectronic, _ApplyTax, _AdjustedQuantities As Boolean
        Private _ShippingName, _ShippingDescription As String

        Private _CouponName As String
        Private _CouponCode As String

        Public objPromotions As New List(Of Kartris.Promotion)
        Public objPromotionsDiscount As New ArrayList

        Private numLanguageID As Integer
        Private numCurrencyID As Integer = 0
        Private numSessionID As Long

        ''' <summary>
        ''' The currency that is being used for the basket.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Taken from the currency table</remarks>
        Public Property CurrencyID() As Integer
            Get
                Return numCurrencyID
            End Get
            Set(ByVal value As Integer)
                numCurrencyID = value
            End Set
        End Property

        ''' <summary>
        ''' Total number of items in the basket.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Not the total number of rows in the basket as some rows have multiple items.</remarks>
        Public ReadOnly Property TotalItems() As Single
            Get
                Return _TotalItems
            End Get
        End Property

        ''' <summary>
        ''' There is at least one item in the basket that has free shipping.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property HasFreeShipping() As Boolean
            Get
                Return _HasFreeShipping
            End Get
        End Property

        ''' <summary>
        ''' All items in the basket have free shipping.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property AllFreeShipping() As Boolean
            Get
                Return _AllFreeShipping
            End Get
        End Property

        ''' <summary>
        ''' All items in the basket are digital downloads
        ''' </summary>
        ''' <value></value>
        ''' <returns>The basket does not contains any physical stocked or shipped items.</returns>
        ''' <remarks></remarks>
        Public ReadOnly Property AllDigital() As Boolean
            Get
                Return _AllDigital
            End Get
        End Property

        ''' <summary>
        ''' Total amount of money saved compared to RRP.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Aggregation of RowAmountSaved() from each BasketItem</remarks>
        Public ReadOnly Property TotalAmountSaved() As Double
            Get
                Return Math.Max(_TotalAmountSaved, 0)
            End Get
        End Property

        ''' <summary>
        ''' Total weight of all items to be shipped
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>will be zero for items that have free shipping</remarks>
        Public ReadOnly Property ShippingTotalWeight() As Double
            Get
                Return _ShippingTotalWeight
            End Get
        End Property

        ''' <summary>
        ''' Total price of all shipping excluding the tax
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property ShippingTotalExTax() As Double
            Get
                Return Math.Round(_ShippingTotalExTax, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Total amount of tax that is due to the shipping price
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property ShippingTotalTaxAmount() As Double
            Get
                Return Math.Round(_ShippingTotalTaxAmount, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Total price of all shipping including the tax
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property ShippingTotalIncTax() As Double
            Get
                Return Math.Round(ShippingTotalExTax + ShippingTotalTaxAmount, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' At least one item within the basket has had its quantity adjusted automatically as part of the validation process
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Because the customer has attempted to purchase more items than are available in stock and stock tracking is set to ON</remarks>
        Public ReadOnly Property AdjustedQuantities() As Boolean
            Get
                Return _AdjustedQuantities
            End Get
        End Property

        ''' <summary>
        ''' Which row number (item index in basket) has been modified due to that product being low / out of stock?
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Used to highlight the row that was stock adjusted as part of validation process. See AdjustedQuantities</remarks>
        Public ReadOnly Property HighlightLowStockRowNumber() As Integer
            Get
                Return _HighlightLowStockRowNumber
            End Get
        End Property

        ''' <summary>
        ''' If the item is electronic (such as a download) and only one download per electronic item is permitted (config setting) but the user has 
        ''' put in more than one quantity. 
        ''' If this happens we reduce the quantity to 1 and set this flag to true to indicate that the customer needs to be alerted to this fact.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property AdjustedForElectronic() As Boolean
            Get
                Return _AdjustedForElectronic
            End Get
        End Property

        ''' <summary>
        ''' The name of the selected shipping method.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>e.g. 'Standard Post', 'Express Delivery' etc. taken from view vKartrisTypeShippingMethods</remarks>
        Public ReadOnly Property ShippingName() As String
            Get
                If AllFreeShipping Then
                    ShippingPrice.IncTax = 0 : ShippingPrice.ExTax = 0
                    Return GetGlobalResourceObject("Kartris", "ContentText_ShippingElectronic")
                Else
                    Return _ShippingName & ""
                End If
            End Get
        End Property

        ''' <summary>
        ''' a description of the selection shipping method
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>e.g. 'Overnight domestic, 2 days EU' taken from view vKartrisTypeShippingMethods</remarks>
        Public ReadOnly Property ShippingDescription() As String
            Get
                If AllFreeShipping Then
                    ShippingPrice.IncTax = 0 : ShippingPrice.ExTax = 0
                    Return HttpContext.GetGlobalResourceObject("Kartris", "ContentText_ShippingElectronicDesc")
                Else
                    Return _ShippingDescription
                End If
            End Get
        End Property

        ''' <summary>
        ''' The total weight for all items in the basket
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>ignores modifiers such as free shipping items</remarks>
        Public ReadOnly Property TotalWeight() As Double
            Get
                Return _TotalWeight
            End Get
        End Property

        ''' <summary>
        ''' The total value of the items in the basket excluding the tax
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TotalExTax() As Double
            Get
                Return Math.Round(_TotalExTax, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' The total value of the items in the basket including the tax
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TotalIncTax() As Double
            Get
                Return Math.Round(TotalExTax + TotalTaxAmount, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' **Total value of items in basket within subtotal (i.e. by default items set not to be included in customer discount)
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property SubTotalExTax() As Double
            Get
                Return Math.Round(_SubTotalExTax, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' **Total amount of tax subtotal items in basket (i.e. by default items set not to be included in customer discount)
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property SubTotalTaxAmount() As Double
            Get
                Return Math.Round(_SubTotalTaxAmount, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' **Total value of items inc tax in basket within subtotal (i.e. by default items set not to be included in customer discount)
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property SubTotalIncTax() As Double
            Get
                Return Math.Round(SubTotalExTax + SubTotalTaxAmount, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' **If basket has at least one item with customer discount exemption
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property HasCustomerDiscountExemption() As Boolean
            Get
                Return _HasCustomerDiscountExemption
            End Get
        End Property

        ''' <summary>
        ''' The average rate of tax for all items in the basket
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>This is because different items in the basket may be using different tax rates (multiple tiers etc.) 
        ''' and so if you need to apply tax to the entire basket as a whole (when using coupons for example) 
        ''' you need the average tax of the basket as a whole.</remarks>
        Public ReadOnly Property TotalTaxRate() As Double
            Get
                Dim numRounding As Integer = 0
                If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" And ConfigurationManager.AppSettings("TaxRegime").ToLower <> "simple" Then
                    numRounding = 4
                Else
                    numRounding = 6
                End If
                If TotalExTax = 0 Then
                    Return 0
                Else
                    Return Math.Round(TotalTaxAmount / TotalExTax, numRounding)
                End If
            End Get
        End Property

        ''' <summary>
        ''' Total amount of tax for the entire basket
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TotalTaxAmount() As Double
            Get
                Return Math.Round(_TotalTaxAmount, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Total price of the entire basket, after discount, including tax. 
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TotalDiscountPriceIncTax() As Double
            Get
                Return Math.Round(TotalIncTax + CouponDiscount.IncTax + PromotionDiscount.IncTax + CustomerDiscount.IncTax, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Total price of the entire basket, after discount, including tax. 
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TotalDiscountPriceExTax() As Double
            Get
                Return Math.Round(TotalExTax + CouponDiscount.ExTax + PromotionDiscount.ExTax + CustomerDiscount.ExTax, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Total amount of tax that is applied to the whole basket, after the discount has been applied.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TotalDiscountPriceTaxAmount() As Double
            Get
                Return Math.Round(TotalDiscountPriceIncTax - TotalDiscountPriceExTax, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' The rate of tax that has been applied to the basket as a whole after the discount has been applied.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TotalDiscountPriceTaxRate() As Double
            Get
                Dim numRounding As Integer = 0
                If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" And ConfigurationManager.AppSettings("TaxRegime").ToLower <> "simple" Then
                    numRounding = 4
                Else
                    numRounding = 6
                End If
                Return Math.Round(IIf(TotalDiscountPriceExTax = 0, 0, TotalDiscountPriceTaxAmount / TotalDiscountPriceExTax), numRounding)
            End Get
        End Property

        ''' <summary>
        ''' The total price to be charged to the customer including  tax.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Includes the items, discounts, coupons and shipping</remarks>
        Public ReadOnly Property FinalPriceIncTax() As Double
            Get
                Dim numFinalPriceIncTax As Double
                numFinalPriceIncTax = Math.Round(TotalDiscountPriceIncTax + ShippingPrice.IncTax + OrderHandlingPrice.IncTax, BasketBLL.CurrencyRoundNumber)
                Return IIf(numFinalPriceIncTax < 0, 0, numFinalPriceIncTax)
            End Get
        End Property

        ''' <summary>
        ''' The total price to the charged to the customer excluding tax.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Includes the items, discounts, coupons and shipping</remarks>
        Public ReadOnly Property FinalPriceExTax() As Double
            Get
                Dim numFinalPriceExTax As Double
                numFinalPriceExTax = Math.Round(TotalDiscountPriceExTax + ShippingPrice.ExTax + OrderHandlingPrice.ExTax, BasketBLL.CurrencyRoundNumber)
                Return IIf(numFinalPriceExTax < 0, 0, numFinalPriceExTax)
            End Get
        End Property

        ''' <summary>
        ''' The total amount that is being charged to the customer once all charges are calculated.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Includes the items, discounts, coupons and shipping</remarks>
        Public ReadOnly Property FinalPriceTaxAmount() As Double
            Get
                Return Math.Round(FinalPriceIncTax - FinalPriceExTax, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Tax should be applied to the basket. 
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>If you write this variable all basket items will have their descrete properties for ApplyTax overwritten with this value</remarks>
        Public Property ApplyTax() As Boolean
            Get
                Return _ApplyTax
            End Get
            Set(ByVal value As Boolean)
                _ApplyTax = value
                'Loop through all basket items and set their tax setting
                For Each Item As Kartris.BasketItem In BasketItems
                    Item.ApplyTax = _ApplyTax
                Next
                'Rebuild
                Call CalculateTotals()
            End Set
        End Property

        ''' <summary>
        ''' The prices given include tax
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>If you write this variable all basket items will have their descrete properties for PricesIncTax overwritten with this value</remarks>
        Public Property PricesIncTax() As Boolean
            Get
                Return _PricesIncTax
            End Get
            Set(ByVal value As Boolean)
                If _PricesIncTax <> value Then
                    _PricesIncTax = value
                    'Loop through all basket items and set their tax setting
                    For Each Item As Kartris.BasketItem In BasketItems
                        Item.PricesIncTax = _PricesIncTax
                    Next
                    'Rebuild
                    Call CalculateTotals()
                End If
            End Set
        End Property

        ''' <summary>
        ''' The name of the applied coupon
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property CouponName() As String
            Get
                Return _CouponName
            End Get
        End Property

        ''' <summary>
        '''  The code of the applied coupon
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property CouponCode() As String
            Get
                Return _CouponCode
            End Get
        End Property

        ''' <summary>
        ''' Same as TotalExTax
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Appears to be legacy</remarks>
        Public ReadOnly Property TotalValueToAffiliate() As Double
            Get
                Return Math.Round(TotalExTax / 1, BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Prevent an accidental round down.
        ''' </summary>
        ''' <param name="numValue"></param>
        ''' <param name="numDecimalPlaces"></param>
        ''' <returns></returns>
        ''' <remarks>TODO: move into a general utility and out of the basket entity</remarks>
        Public Shared Function SafeRound(ByVal numValue As Double, ByVal numDecimalPlaces As Integer) As Double
            Return Math.Round(numValue + 0.00001, numDecimalPlaces)
        End Function

        ''' <summary>
        ''' Prevent an accidental round up.
        ''' </summary>
        ''' <param name="numValue"></param>
        ''' <param name="numDecimalPlaces"></param>
        ''' <returns></returns>
        ''' <remarks>TODO: move into a general utility and out of the basket entity</remarks>
        Public Shared Function NegSafeRound(ByVal numValue As Double, ByVal numDecimalPlaces As Integer) As Double
            NegSafeRound = Math.Round(numValue - 0.00001, numDecimalPlaces)
        End Function

        ''' <summary>
        ''' Flexible variable. Used within TaxRegime.config
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>The purpose of this variable can be altered by changing what it is doing from within the config file.</remarks>
        Public Property D_Tax() As Double
            Get
                Return _DTax
            End Get
            Set(ByVal value As Double)
                _DTax = value
            End Set
        End Property

        ''' <summary>
        ''' Flexible variable. Used within TaxRegime.config
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>The purpose of this variable can be altered by changing what it is doing from within the config file.</remarks>
        Public Property D_Tax2() As Double
            Get
                Return _DTax2
            End Get
            Set(ByVal value As Double)
                _DTax2 = value
            End Set
        End Property

        ''' <summary>
        ''' The TaxRateCalculation name that should be applied when calculating the tax rate.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>See TaxBLL.CalculateTaxRate()</remarks>
        Public Property D_TaxExtra() As String
            Get
                Return _DTaxExtra
            End Get
            Set(ByVal value As String)
                _DTaxExtra = value
            End Set
        End Property

        ''' <summary>
        ''' Get all items in the basket
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property BasketItems As List(Of Kartris.BasketItem)
            Get
                If IsNothing(_BasketItems) Then
                    ' Basket items have not been loaded
                    _LoadBasketItems()
                End If
                Return _BasketItems
            End Get
            Set(value As List(Of Kartris.BasketItem))
                _BasketItems = value
            End Set
        End Property

        ''' <summary>
        ''' Load basket items from the database into memory
        ''' </summary>
        ''' <remarks></remarks>
        Public Sub LoadBasketItems()
            ' Public accessor method
            _LoadBasketItems()
        End Sub

        ''' <summary>
        ''' Load basket items from the database into memory
        ''' </summary>
        ''' <remarks></remarks>
        Private Sub _LoadBasketItems()
            _BasketItems = BasketBLL.GetBasketItems
            _ResetBasketModifiers()
        End Sub

        ''' <summary>
        ''' Set basket modifiers to a reset state
        ''' </summary>
        ''' <remarks></remarks>
        Private Sub _ResetBasketModifiers()
            ShippingPrice = New BasketModifier
            OrderHandlingPrice = New BasketModifier
            CouponDiscount = New BasketModifier
            CustomerDiscount = New BasketModifier
            PromotionDiscount = New BasketModifier
        End Sub

        ''' <summary>
        ''' Calculate all of the total values for the basket such as price tax etc.
        ''' </summary>
        ''' <remarks></remarks>
        Public Sub CalculateTotals()
            'Set intial settings
            _AllFreeShipping = True
            _AllDigital = True
            _HasFreeShipping = False
            _TotalItems = 0
            _TotalWeight = 0
            _TotalExTax = 0
            _TotalTaxAmount = 0
            _TotalAmountSaved = 0
            _SubTotalExTax = 0
            _SubTotalTaxAmount = 0
            _HasCustomerDiscountExemption = False
            _ShippingTotalWeight = 0
            _ShippingTotalExTax = 0
            _ShippingTotalTaxAmount = 0

            'Loop through all items in the basket
            For Each Item As Kartris.BasketItem In BasketItems
                With Item
                    'Are all the items free-shipping?
                    _AllFreeShipping = _AllFreeShipping AndAlso .FreeShipping

                    'Is at least one item got free shipping?
                    _HasFreeShipping = _HasFreeShipping OrElse .FreeShipping

                    _AllDigital = _AllDigital AndAlso (.DownloadType = "l" Or .DownloadType = "u")

                    'If we have an item in the basket that is sold in fractional
                    'quantities, such as rope sold by the metre, then we need to 
                    'think about how quantities are totalled. For example, if we
                    'place 0.05 of an item in the basket, this is really one item
                    'but would be considered as 0.05 items in the count. Similarly
                    'if we purchase 2.5m, it would be considered as 2.5 items. In
                    'both cases, these are really just one item. So, we only add
                    'quantities if the item is a round number.
                    If Math.Round(.Quantity, 0) = .Quantity Then
                        _TotalItems = _TotalItems + .Quantity
                    Else
                        _TotalItems = _TotalItems + 1 'decimal qty, so assume is one item
                    End If

                    'Other totals
                    _TotalWeight = _TotalWeight + .RowWeight
                    _TotalExTax = _TotalExTax + .RowExTax
                    _TotalTaxAmount = _TotalTaxAmount + .RowTaxAmount
                    _TotalAmountSaved = _TotalAmountSaved + .RowAmountSaved

                    'Subtotals
                    If .ExcludeFromCustomerDiscount Then
                        _SubTotalExTax = _SubTotalExTax + .RowExTax
                        If ApplyTax Then
                            _SubTotalTaxAmount = _SubTotalTaxAmount + .RowTaxAmount
                        End If
                        _HasCustomerDiscountExemption = True
                    End If

                    'Shipping Totals
                    If Not .FreeShipping Then
                        _ShippingTotalWeight = _ShippingTotalWeight + .RowWeight
                        _ShippingTotalExTax = _ShippingTotalExTax + .RowExTax
                        If ApplyTax Then
                            _ShippingTotalTaxAmount = _ShippingTotalTaxAmount + .RowTaxAmount
                        End If
                    End If

                End With

            Next
            'BasketItems.Sort()
        End Sub

        Public Sub SetCouponName(ByVal value As String)
            ' Public accessor
            _CouponName = value
        End Sub

        Public Sub SetCouponCode(ByVal value As String)
            ' Public accessor
            _CouponCode = value
        End Sub

        ''' <summary>
        ''' Check to make sure all of the rows in the basket are valid and there are no data errors.
        ''' </summary>
        ''' <param name="blnAllowOutOfStock">Should we accept the basket as valid if it contains out of stock product</param>
        ''' <returns></returns>
        ''' <remarks>While validating this function also triggers some totalisers so it is not strictly just validating data</remarks>
        Public Function Validate(ByVal blnAllowOutOfStock As Boolean) As Boolean
            Dim blnAllowPurchaseOutOfStock, blnOnlyOneDownload As Boolean
            Dim blnWarn As Boolean
            Dim numWeight, numPrice As Double
            Dim V_DownloadType As String
            Dim SESS_CurrencyID As Short
            Dim numUnitSize As Single
            Dim i As Integer = 0              ' For...Each itteration counter

            If numCurrencyID > 0 Then
                SESS_CurrencyID = numCurrencyID
            Else
                SESS_CurrencyID = Current.Session("CUR_ID")
            End If

            'Set variables from application
            _AdjustedForElectronic = False
            _AdjustedQuantities = False

            ' Get configuration flags
            PricesIncTax = (LCase(KartSettingsManager.GetKartConfig("general.tax.pricesinctax")) = "y")     ' Prices include tax already when stored in the database.
            blnAllowPurchaseOutOfStock = LCase(KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock")) = "y"      ' Allow people to order stuff that is already out of stock
            blnOnlyOneDownload = LCase(KartSettingsManager.GetKartConfig("onlyonedownload")) = "y"          ' When purchasing digital downloads only allow a single download of each file.

            'Only proceed if we have basket items
            If BasketItems.Count > 0 Then

                ''Loop through all basket records
                For Each Item As Kartris.BasketItem In BasketItems
                    With Item
                        ' Craig Moore 201505061107. I cannot see why this needs to be here. .Weight is read into
                        ' numWeight and then about 100 lines down it is read back out. There are no triggers, methods
                        ' or anything else. I suspect this can be removed. along with the line later down where it is 
                        ' read back out. 
                        numWeight = .Weight

                        .ComputedTaxRate = TaxRegime.CalculateTaxRate(.TaxRate1, .TaxRate2, IIf(D_Tax > 0, D_Tax, 1), IIf(D_Tax2 > 0, D_Tax2, 1), D_TaxExtra)

                        If D_Tax > 0 Or D_Tax2 > 0 Then ApplyTax = True Else ApplyTax = False

                        'Set whether this item has free shipping
                        V_DownloadType = LCase(.DownloadType)
                        .FreeShipping = Not (V_DownloadType = "" OrElse V_DownloadType = "n")

                        'If the item is electronic, one download is allowed, and the user has
                        'more than one for quantity, change quantity and warn user
                        If blnOnlyOneDownload AndAlso (V_DownloadType = "l" OrElse V_DownloadType = "u") AndAlso .Quantity > 1 Then
                            .Quantity = 1
                            _AdjustedForElectronic = True
                        End If

                        'Adjust quantities if stock level too low
                        If Not blnAllowPurchaseOutOfStock Then
                            'Only warn if tracking turned on for this item (warn level not set to 0)
                            blnWarn = (.QtyWarnLevel <> 0)
                            If blnWarn Then
                                If .Quantity > .StockQty Then
                                    .AdjustedQty = True
                                    _AdjustedQuantities = True
                                    _HighlightLowStockRowNumber = i
                                    .Quantity = .StockQty
                                End If
                            End If
                        End If

                        'Here we check that the quantity for each items is ok
                        'with the unitsize for that item. For example, if items
                        'can only be bought in units of 10, we need to ensure
                        'the qty of that item is a multiple of 10, or fix it
                        'down.
                        Dim objObjectConfigBLL As New ObjectConfigBLL
                        numUnitSize = CkartrisDataManipulation.FixNullFromDB(objObjectConfigBLL.GetValue("K:product.unitsize", .P_ID))
                        .Quantity = (.Quantity - CkartrisDataManipulation.SafeModulus(.Quantity, numUnitSize))

                        'Get basic price, modify for customer group pricing (if lower)
                        numPrice = .Price

                        'Get basic price, modify for customer group pricing (if lower)
                        Dim numCustomerGroupPrice As Double
                        Dim numBaseVersionID As Integer = .VersionBaseID
                        Dim numActualVersionID As Integer = .VersionID
                        Dim numVersionID As Integer = 0

                        'For options products, look up customer group discounts
                        'related to the base version. For combinations products
                        'use the actual version
                        If .HasCombinations Then
                            'Set version ID to use for price to the actual version in basket
                            numVersionID = numActualVersionID
                        Else
                            'Set version ID to use for price to the base version
                            numVersionID = numBaseVersionID
                        End If

                        numCustomerGroupPrice = BasketBLL.GetCustomerGroupPriceForVersion(DB_C_CustomerID, numVersionID)

                        If numCustomerGroupPrice > 0 Then
                            'convert customer group price to current user currency
                            numCustomerGroupPrice = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, numCustomerGroupPrice)), BasketBLL.CurrencyRoundNumber)
                            numPrice = Math.Min(numCustomerGroupPrice, numPrice)
                        End If

                        If Not String.IsNullOrEmpty(.CustomText) Then
                            Dim strCustomControlName As String = objObjectConfigBLL.GetValue("K:product.customcontrolname", .ProductID)
                            If Not String.IsNullOrEmpty(strCustomControlName) Then
                                'Split the custom text field
                                Dim arrParameters As String() = Split(.CustomText, "|||")
                                ' arrParameters(0) contains the comma separated list of the custom control's parameters values
                            Else
                                numPrice += .CustomCost
                            End If

                        End If

                        'Get price break level (if lower)
                        If CInt(KartSettingsManager.GetKartConfig("general.quantitydiscounts.bands")) > 0 Then
                            Dim numDiscountPrice As Double = 0
                            numDiscountPrice = BasketBLL.GetQuantityDiscount(.VersionBaseID, .Quantity)
                            If numDiscountPrice > 0 Then
                                'convert discount price to current user currency
                                numDiscountPrice = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, numDiscountPrice)), BasketBLL.CurrencyRoundNumber)
                                numPrice = Math.Min(numDiscountPrice, numPrice)
                            End If
                        End If

                        If LCase(.ProductType) = "o" Then
                            numPrice = numPrice + CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, .OptionPrice)
                        End If

                        'Calculate the ex-tax - this differs as numPrice will hold 
                        'a different value depending on pricesinctax
                        If PricesIncTax Then
                            .ExTax = numPrice * (1 / (1 + .ComputedTaxRate))
                        Else
                            .ExTax = numPrice
                        End If

                        If Not ApplyTax Then .ComputedTaxRate = 0

                        ' Craig Moore 201505061107. I cannot see why this needs to be here. .Weight is read into
                        ' numWeight 100 lines up and then here it is read back out. There are no triggers, methods
                        ' or anything else. I suspect this can be removed. along with the line further up where it is 
                        ' read out in the first place.
                        .Weight = numWeight

                        'If item set as callforprice at product or version level,
                        'remove it from the basket

                        If ReturnCallForPrice(.ProductID, .VersionID) = 1 Then
                            .Quantity = 0
                        End If

                        If .Quantity = 0 Then
                            'BasketItems.Remove(Item)
                            'v2.9010 fix, need to delete item rather than update qty to zero,
                            'that doesn't seem to work now
                            'BasketBLL.UpdateQuantity(.ID, 0)
                            BasketBLL.DeleteBasketItems(.ID)
                            'Current.Response.Redirect("~/Basket.aspx")
                        Else
                            'IMPORTANT!
                            'If we remove items from the basket, we don't want to advance the 
                            'counter or we get an error at the "next"
                            i = i + 1
                        End If
                    End With
                Next
            End If
            Return True
        End Function

        ''' <summary>
        ''' Calculate the shipping using data within an instance of Interfaces.objShippingDetails
        ''' </summary>
        ''' <param name="numLanguageID">Language</param>
        ''' <param name="numShippingID">Selected shipping method</param>
        ''' <param name="numShippingPriceValue">NOT USED. May be here for legacy or copy / paste error.</param>
        ''' <param name="numDestinationID">Destination location</param>
        ''' <param name="objShippingDetails">Information about the items to be shipped such as total weight and value</param>
        ''' <remarks></remarks>
        Public Sub CalculateShipping(ByVal numLanguageID As Integer, ByVal numShippingID As Integer, ByVal numShippingPriceValue As Double, ByVal numDestinationID As Integer, ByVal objShippingDetails As Interfaces.objShippingDetails)

            ShippingPrice = New BasketModifier

            If numShippingID = 999 Then
                _ShippingName = GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup")
                _ShippingDescription = GetGlobalResourceObject("Shipping", "ContentText_ShippingPickupDesc")
                With ShippingPrice
                    .ExTax = 0
                    .IncTax = 0
                    .TaxRate = 0
                End With
            Else
                If numDestinationID > 0 And numShippingID > 0 Then
                    Try
                        Dim numCurrencyID As Integer
                        numCurrencyID = Current.Session("CUR_ID")
                        Dim ShippingBoundary As Double
                        If KartSettingsManager.GetKartConfig("frontend.checkout.shipping.calcbyweight") = "y" Then
                            ShippingBoundary = _ShippingTotalWeight
                        Else
                            If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") <> "y" Then
                                ShippingBoundary = _ShippingTotalExTax
                            Else
                                ShippingBoundary = ShippingTotalIncTax
                            End If
                        End If

                        Dim SelectedSM As KartrisClasses.ShippingMethod = KartrisClasses.ShippingMethod.GetByID(objShippingDetails, numShippingID, numDestinationID, CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, ShippingBoundary, numCurrencyID), numLanguageID)
                        With SelectedSM
                            _ShippingName = .Name & ""
                            _ShippingDescription = .Description & ""

                            ShippingPrice.ExTax = CurrenciesBLL.ConvertCurrency(numCurrencyID, .ExTax)
                            ShippingPrice.IncTax = CurrenciesBLL.ConvertCurrency(numCurrencyID, .IncTax)
                            ShippingPrice.TaxRate = IIf(ApplyTax, .ComputedTaxRate, 0)
                        End With
                    Catch ex As Exception
                        CkartrisFormatErrors.LogError("BasketBLL.CalculateShipping: " & ex.Message & vbCrLf & _
                                                              "DestinationID: " & numDestinationID & vbCrLf _
                                                              & "ShippingID: " & numShippingID & vbCrLf _
                                                              & "This can happen if there is no valid shipping method for the weight/cost of this order.")

                        _ShippingName = ""
                        _ShippingDescription = ""
                        'Current.Response.Redirect("~/Checkout.aspx")
                    End Try
                Else
                    _ShippingName = ""
                    _ShippingDescription = ""
                    If numShippingID > 0 Then CkartrisFormatErrors.LogError("BasketBLL.CalculateShipping Error - " & _
                                                              "DestinationID: " & numDestinationID & vbCrLf _
                                                              & "ShippingID: " & numShippingID)

                End If
            End If

        End Sub

        ' ''' <summary>
        ' ''' [DO NOT USE] Get all items within the basket
        ' ''' </summary>
        ' ''' <returns>ArrayList of BasketItem</returns>
        ' ''' <remarks>Each item is a row, so if you have multiples of a product that would still be one item but with a quantity greater than 1</remarks>
        'Public Function GetItems() As List(Of Kartris.BasketItem)
        '    'Return BasketItems
        '    Throw New ApplicationException("GetItems() no longer implemented. Instead just reference the BasketItems List Object")
        'End Function

        ''' <summary>
        ''' Create a new basket object
        ''' </summary>
        ''' <remarks></remarks>
        Sub New()
            _ApplyTax = True
            _ResetBasketModifiers()
        End Sub

        Protected Overrides Sub Finalize()
            MyBase.Finalize()
        End Sub

        ''' <summary>
        ''' Call for Price
        ''' </summary>
        ''' <remarks></remarks>
        Function ReturnCallForPrice(ByVal numP_ID As Int64, Optional numV_ID As Int64 = 0) As Int16
            Dim objObjectConfigBLL As New ObjectConfigBLL
            Dim objValue As Object = objObjectConfigBLL.GetValue("K:product.callforprice", numP_ID)
            If CInt(objValue) = 0 And numV_ID <> 0 Then
                'Product not call for price, maybe there is a version
                objValue = objObjectConfigBLL.GetValue("K:version.callforprice", numV_ID)
            End If
            Return objValue
        End Function

    End Class
End Namespace

