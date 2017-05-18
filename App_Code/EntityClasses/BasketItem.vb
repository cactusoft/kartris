Imports Microsoft.VisualBasic
Imports KartSettingsManager
Namespace Kartris
    ''' <summary>
    ''' A single row in a basket
    ''' </summary>
    ''' <remarks>Can contain multiple quantity of an item</remarks>
    ''' 
    <Serializable()> _
    Public Class BasketItem

        Public _VersionID As Long           ' The version ID
        Public ComboVersionID As Long       ' The ID of the combination version
        Private _Quantity As Single         ' The quantity of the item within this basket row
        Private _StockQty As Double
        Public _AppliedPromo As Integer     ' The number of promotion already applied for this version
        Private _ExTax As Double            ' The price of the item, before tax

        Private _TaxRate1 As Double         ' The tax rate applied to this item
        Private _TaxRate2 As Double         ' In scenarios where there is a two tier tax system (e.g. Canada) this would be the second tax rate.
        Private _ComputedTaxRate As Double  ' A single tax rate which is calculated by taking all of the individual tax rates for the individual items and producing one single rate. This is because different items may have different tax rates. in this way we can apply tax to an entire basket in one operation which is useful with coupons etc. which are applied to the whole basket.

        Public FreeShipping As Boolean      ' Whether the item has free shipping
        Public Weight As Double             ' Weight of a single item
        Public RRP As Double                ' The RRP of the version

        Public ApplyTax As Boolean          ' Whether the tax is on or off
        Public PricesIncTax As Boolean      ' Whether prices are entered incl or ex of tax

        Public HasCombinations As Boolean   ' Whether the options have specific combinations
        Public VersionCode As String
        Public Price As Double              ' This is the display price, which might be inc or ex tax 

        Public TableText As String
        Private _DownloadType As String
        Private _QtyWarnLevel As Double
        Private _IncTax As Double           ' Price for a single item (not row, which is items multiplied by quantity) including tax.

        Private _CodeNumber As String       ' Product SKU
        Private _VersionName As String      ' Version name taken from language table
        Private _ProductName As String
        Private _ProductType As String      ' Product type as set in the product setup. Tells us if there is one version or if there are potentially options etc. At time of writting options are 'Single Version', 'Multiple Version', 'Options Product'
        Private _VersionType As String      ' How should the various product options be displayed (dropdown, list etc.)
        Private _ID As Long                 ' Id of the basket item
        Private _ProductID As Long          ' Id of the product from the product table
        Private _CategoryIDs As String      ' Comma delimited string of categor IDs
        Private _OptionPrice As Double      ' Price of an opion
        Private _OptionText As String       ' Text associated with an option
        Private _OptionLink As String
        Private _Free As Boolean            ' Item is free (without charge)
        Private _ApplyTax As Boolean        ' We should apply tax to this item
        Private _CustomText As String       'Some products can have custom text assigned to them when they are added to the basket. e.g. A product that allows you to engrave a custom message
        Private _CustomType As String
        Private _CustomDesc As String
        Private _CustomCost As Double
        Private _TaxRateItem As Double
        Private _AdjustedQty As Boolean
        Private _VersionBaseID As Long      ' Where a product has multiple versions this is the base / genesis version that has all of the text, images etc. that may be missing from the child versions
        Private _PromoQty As Long

        Private _ExcludeFromCustomerDiscount As Boolean 'v2.9010 addition, allows items to be excluded from the % customer discount available to customer

        ''' <summary>
        ''' Some products can have custom text assigned to them when they are added to the basket.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>e.g. A product that allows you to engrave a custom message</remarks>
        Public Property CustomText() As String
            Get
                Return _CustomText
            End Get
            Set(ByVal value As String)
                _CustomText = value
            End Set
        End Property

        ''' <summary>
        ''' Product SKU
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property CodeNumber() As String
            Get
                Return _CodeNumber
            End Get
            Set(ByVal value As String)
                _CodeNumber = value
            End Set
        End Property

        ''' <summary>
        ''' Exclude this item from customer discount
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property ExcludeFromCustomerDiscount() As String
            Get
                Return _ExcludeFromCustomerDiscount
            End Get
            Set(ByVal value As String)
                _ExcludeFromCustomerDiscount = value
            End Set
        End Property

        ''' <summary>
        ''' Name of product version taken from language table
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property VersionName() As String
            Get
                Return _VersionName
            End Get
            Set(ByVal value As String)
                _VersionName = value
            End Set
        End Property

        ''' <summary>
        '''  Name of the product
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property ProductName() As String
            Get
                Return _ProductName
            End Get
            Set(ByVal value As String)
                _ProductName = value
            End Set
        End Property

        'Duplicate, used in basket for image control
        Public Property P_Name() As String
            Get
                Return _ProductName
            End Get
            Set(ByVal value As String)
                _ProductName = value
            End Set
        End Property

        ''' <summary>
        ''' Product type as set in the product setup. Tells us if there is one version or if there are potentially options etc.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>At time of writting options are 'Single Version', 'Multiple Version', 'Options Product'</remarks>
        Public Property ProductType() As String
            Get
                Return _ProductType
            End Get
            Set(ByVal value As String)
                _ProductType = value
            End Set
        End Property

        ''' <summary>
        ''' How should the various product options be displayed
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>options list = 'o', default = 'd', none = 'l', rows = 'r' etc.</remarks>
        Public Property VersionType() As String
            Get
                Return _VersionType
            End Get
            Set(ByVal value As String)
                _VersionType = value
            End Set
        End Property

        ''' <summary>
        ''' Basket item ID as it is in the Basket item table
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property

        ''' <summary>
        ''' Product ID from the product table
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property ProductID() As Long
            Get
                Return _ProductID
            End Get
            Set(ByVal value As Long)
                _ProductID = value
            End Set
        End Property

        ''' <summary>
        ''' Duplicate, used in basket for image control
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property P_ID() As Long
            Get
                Return _ProductID
            End Get
            Set(ByVal value As Long)
                _ProductID = value
            End Set
        End Property

        Public Property CategoryIDs() As String
            Get
                Return _CategoryIDs
            End Get
            Set(ByVal value As String)
                _CategoryIDs = value
            End Set
        End Property

        Public Property CustomType() As String
            Get
                Return _CustomType
            End Get
            Set(ByVal value As String)
                _CustomType = value
            End Set
        End Property

        Public Property CustomDesc() As String
            Get
                Return _CustomDesc
            End Get
            Set(ByVal value As String)
                _CustomDesc = value
            End Set
        End Property

        Public Property CustomCost() As Double
            Get
                Return Math.Round(_CustomCost, BasketBLL.CurrencyRoundNumber)
            End Get
            Set(ByVal value As Double)
                _CustomCost = value
            End Set
        End Property

        Public Property PromoQty() As Long
            Get
                Return _PromoQty
            End Get
            Set(ByVal value As Long)
                _PromoQty = value
            End Set
        End Property

        ''' <summary>
        ''' Returns false
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks>Appears to be legacy, returns False</remarks>
        Public Function HasOptions() As Boolean
            'The item has options if the first option group ID > 0
            Return False
        End Function

        ''' <summary>
        ''' The quantity of this product that appears in this basket row. 
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property Quantity() As Single
            Get
                Return _Quantity
            End Get
            Set(ByVal value As Single)
                _Quantity = value
                If _Quantity > 2147483647 Then _Quantity = 2147483647
            End Set
        End Property

        ''' <summary>
        ''' The quantity of this item that are currently in stock 
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Used for validation control incase the user tries to purchase more stock than is available</remarks>
        Public Property StockQty() As Double
            Get
                Return _StockQty
            End Get
            Set(ByVal value As Double)
                _StockQty = value
            End Set
        End Property

        ''' <summary>
        ''' Indicates that the quantity was automatically adjusted by the system as a result of a validation step.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>If the customer attempts to order a higher quantity than is available and validation is set the quantity will be reduced and this flag will be set to TRUE</remarks>
        Public Property AdjustedQty() As Boolean
            Get
                Return _AdjustedQty
            End Get
            Set(ByVal value As Boolean)
                _AdjustedQty = value
            End Set
        End Property

        ''' <summary>
        ''' Used as a boolean value to indicate if a promotion has been applied
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>At time of writting only values of 0 an 1 were possible here.</remarks>
        Public Property AppliedPromo() As Double
            Get
                Return _AppliedPromo
            End Get
            Set(ByVal value As Double)
                _AppliedPromo = CLng(value)
                If _AppliedPromo > 32767 Then _AppliedPromo = 32767
            End Set
        End Property

        ''' <summary>
        ''' Add a given amount to the current quantity
        ''' </summary>
        ''' <param name="value"></param>
        ''' <remarks></remarks>
        Public Sub IncreaseQuantity(ByVal value As Double)
            Quantity = _Quantity + value
        End Sub

        ''' <summary>
        ''' Subtract a given amount from the current quantity
        ''' </summary>
        ''' <param name="value"></param>
        ''' <remarks></remarks>
        Public Sub DecreaseQuantity(ByVal value As Double)
            Quantity = _Quantity - value
        End Sub

        ''' <summary>
        ''' No function.
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks>returns a blank string</remarks>
        Public Function GetLinkQS() As String
            Return ""
        End Function

        ''' <summary>
        ''' Used for downloadable items (not physical items that are stocked and shipped).
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property DownloadType() As String
            Get
                Return _DownloadType
            End Get
            Set(ByVal value As String)
                _DownloadType = value
            End Set
        End Property

        ''' <summary>
        ''' At which quantity level should the shop owner be alerted about being low on stock.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property QtyWarnLevel() As Double
            Get
                Return _QtyWarnLevel
            End Get
            Set(ByVal value As Double)
                _QtyWarnLevel = value
            End Set
        End Property

        ''' <summary>
        ''' if it is an options product, the options can optionally have a value (plus or minus)
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property OptionPrice() As Double
            Get
                Return Math.Round(_OptionPrice, BasketBLL.CurrencyRoundNumber)
            End Get
            Set(ByVal value As Double)
                _OptionPrice = value
            End Set
        End Property

        ''' <summary>
        ''' If this is an option product this will contain the text of that option.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property OptionText() As String
            Get
                Return _OptionText
            End Get
            Set(ByVal value As String)
                _OptionText = value
            End Set
        End Property

        ''' <summary>
        ''' POSSIBLY NOT USED. Is read when creating a URL.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Is read from in several places but never written to (except to set it as a ZLS)</remarks>
        Public Property OptionLink() As String
            Get
                Return _OptionLink
            End Get
            Set(ByVal value As String)
                _OptionLink = value
            End Set
        End Property

        ''' <summary>
        '''  Is product free (zero cost)?
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>some promotional offers will react differently to a product marked as free compared to a product of zero cost ($0.00).</remarks>
        Public Property Free() As Boolean
            Get
                Return _Free
            End Get
            Set(ByVal value As Boolean)
                _Free = value
            End Set
        End Property

        ''' <summary>
        ''' Where a product has multiple versions this is the version ID. 
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property VersionID() As Long
            Get
                Return _VersionID
            End Get
            Set(ByVal value As Long)
                _VersionID = value
            End Set
        End Property

        ''' <summary>
        ''' This is the ID of the base version of an options product
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property VersionBaseID() As Long
            Get
                Return _VersionBaseID
            End Get
            Set(ByVal value As Long)
                _VersionBaseID = value
            End Set
        End Property

        ''' <summary>
        ''' Display name
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Normally product name but it may contain a version name also</remarks>
        Public ReadOnly Property Name() As String
            Get
                If ProductName = VersionName Then
                    Return ProductName
                Else
                    Return ProductName & " - " & VersionName
                End If
            End Get
        End Property

        ''' <summary>
        ''' [assumed] Price per item excluding tax - remember a row can have multiples of a single item.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property ExTax() As Double
            Get
                Return Math.Round(_ExTax, BasketBLL.CurrencyRoundNumber)
            End Get
            Set(ByVal value As Double)
                _ExTax = value
            End Set
        End Property

        ''' <summary>
        ''' [assumed] Price per item including tax - remember a row can have multiples of a single item.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property IncTax() As Double
            Get
                Return Math.Round(_ExTax + TaxAmount, BasketBLL.CurrencyRoundNumber)
            End Get
            Set(ByVal value As Double)
                _IncTax = value
            End Set
        End Property

        ''' <summary>
        ''' How much tax is applied to a single item within this basket row.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property TaxAmount() As Double
            Get
                Dim numRounding As Integer = 0
                If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" And ConfigurationManager.AppSettings("TaxRegime").ToLower <> "simple" Then
                    numRounding = 4
                Else
                    numRounding = 6
                End If
                Return Math.Round(IIf(Not (ApplyTax), 0, _ExTax * ComputedTaxRate), numRounding)
            End Get
        End Property

        ''' <summary>
        ''' The tax rate for the entire basket combining the various different tax rates that the individual items each have into one average tax rate.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>If you have some items in an order that have VAT, and some without, the total VAT % on the order won't be 20% as it would if all items have VAT. The computed tax rate is the total % of VAT on the order. We use this to correctly handle coupons, so they are split between the taxable and non taxable parts of an order in the right proportion. For example, let's say we have prices ex tax, and two items in the basket that are 10 GBP. One is taxable, the other is not. The </remarks>
        Public Property ComputedTaxRate() As Double
            Get
                Return Math.Round(_ComputedTaxRate, 6)
            End Get
            Set(ByVal value As Double)
                _ComputedTaxRate = value
            End Set
        End Property

        ''' <summary>
        ''' This is the primary tax rate for the item, normally in the EU countries this is the VAT %
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property TaxRate1() As Double
            Get
                Return Math.Round(_TaxRate1, 6)
            End Get
            Set(ByVal value As Double)
                _TaxRate1 = value
            End Set
        End Property

        ''' <summary>
        ''' Used in countries with a two tier tax system
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Canada has a two tier tax regime, with both national and provincial tax rates often separate (though some provinces merge them into a single 'HST' - harmonized sales tax). In EU countries this value is therefore blank, but will be used in Canada.</remarks>
        Public Property TaxRate2() As Double
            Get
                Return Math.Round(_TaxRate2, 6)
            End Get
            Set(ByVal value As Double)
                _TaxRate2 = value
            End Set
        End Property

        ''' <summary>
        ''' What is the rate of tax for a single item within the basket row.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property TaxRateItem() As Double
            Get
                Return Math.Round(_TaxRateItem, 6)
            End Get
            Set(ByVal value As Double)
                _TaxRateItem = value
            End Set
        End Property

        ''' <summary>
        ''' Price excluding tax without any rounding applied.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>used for calculations but not generally for display</remarks>
        Public ReadOnly Property ExTaxNoRound() As Double
            Get
                Return _ExTax
            End Get
        End Property

        ''' <summary>
        ''' Prince including tax without any rounding applied
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>used for calculations but not generally for display</remarks>
        Public ReadOnly Property IncTaxNoRound() As Double
            Get
                Return _ExTax * (IIf(Not (ApplyTax), 0, ComputedTaxRate) + 1)
            End Get
        End Property

        ''' <summary>
        ''' Price of the basket item row excluding tax
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>remember that a row can include multiples of a single product</remarks>
        Public ReadOnly Property RowExTax() As Double
            Get
                Dim numRounding As Integer = 0
                If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" And ConfigurationManager.AppSettings("TaxRegime").ToLower <> "simple" Then
                    numRounding = BasketBLL.CurrencyRoundNumber
                Else
                    numRounding = 4
                End If
                Return Math.Round(IIf(PricesIncTax, ExTax * Quantity, ExTaxNoRound * Quantity), numRounding)
            End Get
        End Property

        ''' <summary>
        ''' Price of a row including the tax. 
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>remember that a row can include multiples of a single product</remarks>
        Public ReadOnly Property RowIncTax() As Double
            Get
                Return Math.Round(IIf(PricesIncTax, IncTax * Quantity, IncTaxNoRound * Quantity), BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Amount of tax for the row in the basket
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>remember that a row can include multiples of a single product</remarks>
        Public ReadOnly Property RowTaxAmount() As Double
            Get
                Return Math.Round(IIf(Not (ApplyTax), 0, IIf(PricesIncTax, RowIncTax - RowExTax, IncTaxNoRound * Quantity - RowExTax)), BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' Weight of the basket row
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>remember that a row can include multiples of a single product</remarks>
        Public ReadOnly Property RowWeight() As Double
            Get
                Return Weight * Quantity
            End Get
        End Property

        ''' <summary>
        ''' Amount of money saved compared to RRP
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>Calcualates tax within function automatically.</remarks>
        Public ReadOnly Property RowAmountSaved() As Double
            Get
                Return Math.Round(IIf(PricesIncTax, Math.Max(Quantity * (RRP - IncTax), 0), Math.Max(Quantity * (RRP - ExTax), 0)), BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' The amount of tax for each item within a single Invoice Row. Used when more than one of a single item is purchased
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>price of each item. Depending on the tax mode you're using (inc/ex) 
        ''' this field will hold either the extax or inctax price per item (unit price). </remarks>
        Public ReadOnly Property IR_PricePerItem() As Double
            Get
                Return Math.Round(IIf(PricesIncTax, IncTax, ExTax), BasketBLL.CurrencyRoundNumber)
            End Get
        End Property

        ''' <summary>
        ''' The amount of tax for each item within a single Invoice Row. Used when more than one of a single item is purchased
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks>IR= invoice rows, a row can have multiple items on it if you purchase several of the same item, 
        ''' so the tax per row and tax per item can be different. Having values for each is important because where 
        ''' the rounding happens depends on whether the store uses inc or ex tax pricing. 
        ''' If prices ex tax, the IR_TaxPerItem field holds a % tax, if prices inc tax, it holds the tax amount in currency 
        ''' (since rounding occurs per item, we can calculate and round this, 
        ''' unlike for ex tax pricing where tax is calculated per row, not per item).</remarks>
        Public ReadOnly Property IR_TaxPerItem() As Double
            Get
                If PricesIncTax Then
                    'Return currency amount
                    Return Math.Round((TaxAmount), BasketBLL.CurrencyRoundNumber)
                Else
                    'Return number (e.g. tax rate 17.5%, returns 0.175)
                    Return ComputedTaxRate
                End If
            End Get
        End Property

        ''' <summary>
        ''' Create a new instance of the BasketItem object
        ''' </summary>
        ''' <remarks></remarks>
        Public Sub New()
            PricesIncTax = (LCase(GetKartConfig("general.tax.pricesinctax")) = "y")

            HasCombinations = False
            VersionID = 0

            '' added
            _VersionID = 0
            ComboVersionID = 0
            _Free = False
        End Sub

    End Class
End Namespace
