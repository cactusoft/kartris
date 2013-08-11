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
Imports System.Xml.Serialization
Imports kartrisBasketDataTableAdapters
Imports kartrisBasketData
Imports System.Collections.Generic
Imports System.Web.HttpContext
Imports System.Math
Imports CkartrisDataManipulation
Imports KartSettingsManager
Imports SiteMapHelper
Imports KartrisClasses

<Serializable()> _
Public Class BasketModifier

    Private _ExTax As Double
    Private _IncTax As Double
    Private _TaxRate As Double

    Public Property ExTax() As Double
        Get
            Return Math.Round(_ExTax, 2)
        End Get
        Set(ByVal value As Double)
            _ExTax = value
        End Set
    End Property

    Public Property IncTax() As Double
        Get
            Return Math.Round(_IncTax, 2)
            ''Return (_IncTax)
        End Get
        Set(ByVal value As Double)
            _IncTax = value
        End Set
    End Property

    Public Property TaxRate() As Double
        Get
            Return Math.Round(_TaxRate, 4)
        End Get
        Set(ByVal value As Double)
            _TaxRate = value
        End Set
    End Property

    Public ReadOnly Property TaxAmount() As Double
        Get
            Return Math.Round(IncTax - ExTax, 2)
            ''Return (IncTax - ExTax)
        End Get
    End Property

End Class

<Serializable()> _
Public Class BasketItem

    Public _VersionID As Long           'The version ID
    Public ComboVersionID As Long       'The ID of the combination version
    Private _Quantity As Single     'The quantity in the basket
    Private _StockQty As Double
    Public _AppliedPromo As Integer 'The number of promotion already applied for this version
    Private _ExTax As Double            'The price of the item, before tax

    Private _TaxRate1 As Double          'The tax rate applied to this item
    Private _TaxRate2 As Double
    Private _ComputedTaxRate As Double

    Public FreeShipping As Boolean  'Whether the item has free shipping
    Public Weight As Double             'Weight of a single item
    Public RRP As Double                    'The RRP of the version

    Public Shared ApplyTax As Boolean   'Whether the tax is on or off
    Public PricesIncTax As Boolean      'Whether prices are entered incl or ex of tax

    Public HasCombinations As Boolean   'Whether the options have specific combinations
    Public VersionCode As String
    Public Price As Double

    Public TableText As String
    Private _DownloadType As String
    Private _QtyWarnLevel As Double
    Private _IncTax As Double

    Private _CodeNumber As String
    Private _VersionName As String
    Private _ProductName As String
    Private _ProductType As String
    Private _ID As Long
    Private _ProductID As Long
    Private _CategoryIDs As String
    Private _OptionPrice As Double
    Private _OptionText As String
    Private _OptionLink As String
    Private _Free As Boolean
    Private _ApplyTax As Boolean
    Private _CustomText As String
    Private _CustomType, _CustomDesc As String
    Private _CustomCost As Double
    Private _TaxRateItem As Double
    Private _AdjustedQty As Boolean
    Private _VersionBaseID As Long
    Private _PromoQty As Long


    Public Property CustomText() As String
        Get
            Return _CustomText
        End Get
        Set(ByVal value As String)
            _CustomText = value
        End Set
    End Property

    Public Property CodeNumber() As String
        Get
            Return _CodeNumber
        End Get
        Set(ByVal value As String)
            _CodeNumber = value
        End Set
    End Property

    Public Property VersionName() As String
        Get
            Return _VersionName
        End Get
        Set(ByVal value As String)
            _VersionName = value
        End Set
    End Property

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

    Public Property ProductType() As String
        Get
            Return _ProductType
        End Get
        Set(ByVal value As String)
            _ProductType = value
        End Set
    End Property

    Public Property ID() As Long
        Get
            Return _ID
        End Get
        Set(ByVal value As Long)
            _ID = value
        End Set
    End Property

    Public Property ProductID() As Long
        Get
            Return _ProductID
        End Get
        Set(ByVal value As Long)
            _ProductID = value
        End Set
    End Property

    'Duplicate, used in basket for image control
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

    Public Function HasOptions() As Boolean
        'The item has options if the first option group ID > 0
        Return False
    End Function

    Public Property Quantity() As Single
        Get
            Return _Quantity
        End Get
        Set(ByVal value As Single)
            _Quantity = value
            If _Quantity > 2147483647 Then _Quantity = 2147483647
        End Set
    End Property

    Public Property StockQty() As Double
        Get
            Return _StockQty
        End Get
        Set(ByVal value As Double)
            _StockQty = value
        End Set
    End Property

    Public Property AdjustedQty() As Boolean
        Get
            Return _AdjustedQty
        End Get
        Set(ByVal value As Boolean)
            _AdjustedQty = value
        End Set
    End Property

    Public Property AppliedPromo() As Double
        Get
            Return _AppliedPromo
        End Get
        Set(ByVal value As Double)
            _AppliedPromo = value
            If LCase((GetGlobalResourceObject("KATRIS", "fractionalbasketquantities") <> "y")) Then _AppliedPromo = CLng(_AppliedPromo)
            If _AppliedPromo > 32767 Then _AppliedPromo = 32767
        End Set
    End Property

    Public Sub IncreaseQuantity(ByVal value As Double)
        Quantity = _Quantity + value
    End Sub

    Public Sub DecreaseQuantity(ByVal value As Double)
        Quantity = _Quantity - value
    End Sub

    Public Function GetLinkQS() As String
        Return ""
    End Function

    Public Property DownloadType() As String
        Get
            Return _DownloadType
        End Get
        Set(ByVal value As String)
            _DownloadType = value
        End Set
    End Property

    Public Property QtyWarnLevel() As Double
        Get
            Return _QtyWarnLevel
        End Get
        Set(ByVal value As Double)
            _QtyWarnLevel = value
        End Set
    End Property

    Public Property OptionPrice() As Double
        Get
            Return Math.Round(_OptionPrice, BasketBLL.CurrencyRoundNumber)
        End Get
        Set(ByVal value As Double)
            _OptionPrice = value
        End Set
    End Property

    Public Property OptionText() As String
        Get
            Return _OptionText
        End Get
        Set(ByVal value As String)
            _OptionText = value
        End Set
    End Property

    Public Property OptionLink() As String
        Get
            Return _OptionLink
        End Get
        Set(ByVal value As String)
            _OptionLink = value
        End Set
    End Property

    Public Property Free() As Boolean
        Get
            Return _Free
        End Get
        Set(ByVal value As Boolean)
            _Free = value
        End Set
    End Property

    Public Sub New()
        'PricesIncTax = True
        'intead of setting the initial value to true, get the proper config setting instead
        'this was done because the basketbll.getbasketitems function returns the basketitems without validating the items first
        'If LCase(GetKartConfig("general.tax.usmultistatetax")) = "y" Then PricesIncTax = False Else PricesIncTax = (LCase(GetKartConfig("general.tax.pricesinctax")) = "y")
        'If TaxRegime.Name.ToLower = "us" Then PricesIncTax = False Else 
        PricesIncTax = (LCase(GetKartConfig("general.tax.pricesinctax")) = "y")

        HasCombinations = False
        VersionID = 0

        '' added
        _VersionID = 0
        ComboVersionID = 0
        _Free = False


    End Sub

    Public Property VersionID() As Long
        Get
            Return _VersionID
        End Get
        Set(ByVal value As Long)
            _VersionID = value
        End Set
    End Property

    Public Property VersionBaseID() As Long
        Get
            Return _VersionBaseID
        End Get
        Set(ByVal value As Long)
            _VersionBaseID = value
        End Set
    End Property

    Public ReadOnly Property Name() As String
        Get
            If ProductName = VersionName Then
                Return ProductName
            Else
                Return ProductName & " - " & VersionName
            End If
        End Get
    End Property

    Public Property ExTax() As Double
        Get
            Return Math.Round(_ExTax, BasketBLL.CurrencyRoundNumber)
        End Get
        Set(ByVal value As Double)
            _ExTax = value
        End Set
    End Property

    Public Property IncTax() As Double
        Get
            Return Math.Round(_ExTax + TaxAmount, BasketBLL.CurrencyRoundNumber)
        End Get
        Set(ByVal value As Double)
            _IncTax = value
        End Set
    End Property

    Public ReadOnly Property TaxAmount() As Double
        Get
            Return Math.Round(IIf(Not (ApplyTax), 0, _ExTax * ComputedTaxRate), 4)
        End Get
    End Property


    Public Property ComputedTaxRate() As Double
        Get
            Return Math.Round(_ComputedTaxRate, 4)
        End Get
        Set(ByVal value As Double)
            _ComputedTaxRate = value
        End Set
    End Property
    Public Property TaxRate1() As Double
        Get
            Return Math.Round(_TaxRate1, 4)
        End Get
        Set(ByVal value As Double)
            _TaxRate1 = value
        End Set
    End Property

    Public Property TaxRate2() As Double
        Get
            Return Math.Round(_TaxRate2, 4)
        End Get
        Set(ByVal value As Double)
            _TaxRate2 = value
        End Set
    End Property

    Public Property TaxRateItem() As Double
        Get
            Return Math.Round(_TaxRateItem, 4)
        End Get
        Set(ByVal value As Double)
            _TaxRateItem = value
        End Set
    End Property

    Public ReadOnly Property ExTaxNoRound() As Double
        Get
            Return _ExTax
        End Get
    End Property

    Public ReadOnly Property IncTaxNoRound() As Double
        Get
            Return _ExTax * (IIf(Not (ApplyTax), 0, ComputedTaxRate) + 1)
        End Get
    End Property

    Public ReadOnly Property RowExTax() As Double
        Get
            Return Math.Round(IIf(PricesIncTax, ExTax * Quantity, ExTaxNoRound * Quantity), BasketBLL.CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property RowIncTax() As Double
        Get
            Return Math.Round(IIf(PricesIncTax, IncTax * Quantity, IncTaxNoRound * Quantity), BasketBLL.CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property RowTaxAmount() As Double
        Get
            Return Math.Round(IIf(Not (ApplyTax), 0, IIf(PricesIncTax, RowIncTax - RowExTax, IncTaxNoRound * Quantity - RowExTax)), 4)
        End Get
    End Property

    Public ReadOnly Property RowWeight() As Double
        Get
            Return Weight * Quantity
        End Get
    End Property

    Public ReadOnly Property RowAmountSaved() As Double
        Get
            Return Math.Round(IIf(PricesIncTax, Math.Max(Quantity * (RRP - IncTax), 0), Math.Max(Quantity * (RRP - ExTax), 0)), BasketBLL.CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property IR_PricePerItem() As Double
        Get
            Return Math.Round(IIf(PricesIncTax, IncTax, ExTax), BasketBLL.CurrencyRoundNumber)
        End Get
    End Property

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


End Class

<Serializable()> <XmlInclude(GetType(BasketItem))> _
Public Class BasketBLL

    Public Enum BASKET_PARENTS
        BASKET = 1
        SAVED_BASKET = 2
        WISH_LIST = 3
    End Enum

    Public Enum VIEW_TYPE
        MAIN_BASKET = 1
        CHECKOUT_BASKET = 2
        MINI_BASKET = 3
    End Enum

    Public DB_C_CustomerDiscount As Double
    Public DB_C_CustomerID As Integer

    'Basket modifiers
    Public ShippingPrice As BasketModifier
    Public OrderHandlingPrice As BasketModifier
    Public CouponDiscount As BasketModifier
    Public CustomerDiscount As BasketModifier
    Public PromotionDiscount As BasketModifier
    Protected Shared ReadOnly Property _BasketValuesAdptr() As BasketValuesTblAdptr
        Get
            Return New BasketValuesTblAdptr
        End Get
    End Property
    Protected Shared ReadOnly Property _BasketOptionsAdptr() As BasketOptionValuesTblAdptr
        Get
            Return New BasketOptionValuesTblAdptr
        End Get
    End Property
    Protected Shared ReadOnly Property _CouponsAdptr() As CouponsTblAdptr
        Get
            Return New CouponsTblAdptr
        End Get
    End Property
    Protected Shared ReadOnly Property _CustomersAdptr() As CustomersTblAdptr
        Get
            Return New CustomersTblAdptr
        End Get
    End Property

    Public BasketItems As New ArrayList

    Private _AllFreeShipping, _HasFreeShipping, _PricesIncTax, _AllDigital As Boolean
    Private _TotalWeight, _TotalExTax, _TotalTaxAmount, _TotalAmountSaved As Double
    Private _TotalItems As Single
    Private _ShippingTotalWeight, _ShippingTotalExTax, _ShippingTotalTaxAmount As Double
    Private _CustomerDiscountPercentage, _TotalDiscountPriceIncTax, _TotalDiscountPriceExTax As Double
    Private _TotalDiscountPriceTaxAmount, _TotalDiscountPriceTaxRate As Double
    Private _TotalIncTax, _TotalTaxRate, _DTax, _DTax2 As Double
    Private _DTaxExtra As String

    Private _LastIndex As Integer
    Private _AdjustedForElectronic, _ApplyTax, _AdjustedQuantities As Boolean
    Private _ShippingName, _ShippingDescription As String

    Private _CouponName As String
    Private _CouponCode As String

    Private objPromotions As New ArrayList
    Private objPromotionsDiscount As New ArrayList

    Private numLanguageID As Integer
    Private numCurrencyID As Integer = 0
    Private numSessionID As Long

    Public Property CurrencyID() As Integer
        Get
            Return numCurrencyID
        End Get
        Set(ByVal value As Integer)
            numCurrencyID = value
        End Set
    End Property

    Public ReadOnly Property TotalItems() As Single
        Get
            Return _TotalItems
        End Get
    End Property

    Public ReadOnly Property HasFreeShipping() As Boolean
        Get
            Return _HasFreeShipping
        End Get
    End Property

    Public ReadOnly Property AllFreeShipping() As Boolean
        Get
            Return _AllFreeShipping
        End Get
    End Property

    Public ReadOnly Property AllDigital() As Boolean
        Get
            Return _AllDigital
        End Get
    End Property

    Public ReadOnly Property TotalAmountSaved() As Double
        Get
            Return Math.Max(_TotalAmountSaved, 0)
        End Get
    End Property

    Public ReadOnly Property ShippingTotalWeight() As Double
        Get
            Return _ShippingTotalWeight
        End Get
    End Property

    Public ReadOnly Property ShippingTotalExTax() As Double
        Get
            Return Math.Round(_ShippingTotalExTax, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property ShippingTotalTaxAmount() As Double
        Get
            Return Math.Round(_ShippingTotalTaxAmount, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property ShippingTotalIncTax() As Double
        Get
            Return Math.Round(ShippingTotalExTax + ShippingTotalTaxAmount, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property AdjustedQuantities() As Boolean
        Get
            Return _AdjustedQuantities
        End Get
    End Property

    Public ReadOnly Property AdjustedForElectronic() As Boolean
        Get
            Return _AdjustedForElectronic
        End Get
    End Property

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

    Public ReadOnly Property ShippingDescription() As String
        Get
            If AllFreeShipping Then
                ShippingPrice.IncTax = 0 : ShippingPrice.ExTax = 0
                Return GetGlobalResourceObject("Kartris", "ContentText_ShippingElectronicDesc")
            Else
                Return _ShippingDescription
            End If
        End Get
    End Property

    Public ReadOnly Property CustomerDiscountPercentage() As Double
        Get
            Return _CustomerDiscountPercentage
        End Get
    End Property

    Public ReadOnly Property TotalWeight() As Double
        Get
            Return _TotalWeight
        End Get
    End Property

    Public ReadOnly Property TotalExTax() As Double
        Get
            Return Math.Round(_TotalExTax, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property TotalIncTax() As Double
        Get
            Return Math.Round(TotalExTax + TotalTaxAmount, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property TotalTaxRate() As Double
        Get
            If TotalExTax = 0 Then
                Return 0
            Else
                'If GetKartConfig("general.tax.usmultistatetax") = "y" Then Return _TotalTaxRate
                'If TaxRegime.Name.ToLower = "us" Then Return _TotalTaxRate

                Return Math.Round(TotalTaxAmount / TotalExTax, 4)
            End If
        End Get
    End Property

    Public ReadOnly Property TotalTaxAmount() As Double
        Get
            Return Math.Round(_TotalTaxAmount, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property TotalDiscountPriceIncTax() As Double
        Get
            Return Math.Round(TotalIncTax + CouponDiscount.IncTax + PromotionDiscount.IncTax + CustomerDiscount.IncTax, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property TotalDiscountPriceExTax() As Double
        Get
            Return Math.Round(TotalExTax + CouponDiscount.ExTax + PromotionDiscount.ExTax + CustomerDiscount.ExTax, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property TotalDiscountPriceTaxAmount() As Double
        Get
            Return Math.Round(TotalDiscountPriceIncTax - TotalDiscountPriceExTax, CurrencyRoundNumber)
        End Get
    End Property

    Public ReadOnly Property TotalDiscountPriceTaxRate() As Double
        Get
            Return Math.Round(IIf(TotalDiscountPriceExTax = 0, 0, TotalDiscountPriceTaxAmount / TotalDiscountPriceExTax), 4)
        End Get
    End Property

    Public ReadOnly Property FinalPriceIncTax() As Double
        Get
            Dim numFinalPriceIncTax As Double
            numFinalPriceIncTax = Math.Round(TotalDiscountPriceIncTax + ShippingPrice.IncTax + OrderHandlingPrice.IncTax, CurrencyRoundNumber)
            Return IIf(numFinalPriceIncTax < 0, 0, numFinalPriceIncTax)
        End Get
    End Property

    Public ReadOnly Property FinalPriceExTax() As Double
        Get
            Dim numFinalPriceExTax As Double
            numFinalPriceExTax = Math.Round(TotalDiscountPriceExTax + ShippingPrice.ExTax + OrderHandlingPrice.ExTax, CurrencyRoundNumber)
            Return IIf(numFinalPriceExTax < 0, 0, numFinalPriceExTax)
        End Get
    End Property

    Public ReadOnly Property FinalPriceTaxAmount() As Double
        Get
            Return Math.Round(FinalPriceIncTax - FinalPriceExTax, CurrencyRoundNumber)
        End Get
    End Property

    Public Property ApplyTax() As Boolean
        Get
            Return _ApplyTax
        End Get
        Set(ByVal value As Boolean)
            _ApplyTax = value
            'Loop through all basket items and set their tax setting
            For i = 0 To BasketItems.Count - 1
                BasketItems.Item(i).ApplyTax = _ApplyTax
            Next
            'Rebuild
            Call CalculateTotals()
        End Set
    End Property

    Public Property PricesIncTax() As Boolean
        Get
            Return _PricesIncTax
        End Get
        Set(ByVal value As Boolean)
            If _PricesIncTax <> value Then
                _PricesIncTax = value
                'Loop through all basket items and set their tax setting
                For i = 0 To BasketItems.Count - 1
                    BasketItems.Item(i).PricesIncTax = _PricesIncTax
                Next
                'Rebuild
                Call CalculateTotals()
            End If
        End Set
    End Property

    Public ReadOnly Property CouponName() As String
        Get
            Return _CouponName
        End Get
    End Property

    Public ReadOnly Property CouponCode() As String
        Get
            Return _CouponCode
        End Get
    End Property

    Public ReadOnly Property TotalValueToAffiliate() As Double
        Get
            Return Math.Round(TotalExTax / 1, CurrencyRoundNumber)
        End Get
    End Property

    Public Shared Function SafeRound(ByVal numValue As Double, ByVal numDecimalPlaces As Integer) As Double
        Return Math.Round(numValue + 0.00001, numDecimalPlaces)
    End Function

    Public Shared Function NegSafeRound(ByVal numValue As Double, ByVal numDecimalPlaces As Integer) As Double
        NegSafeRound = Math.Round(numValue - 0.00001, numDecimalPlaces)
    End Function

    Public Property D_Tax() As Double
        Get
            Return _DTax
        End Get
        Set(ByVal value As Double)
            _DTax = value
        End Set
    End Property
    Public Property D_Tax2() As Double
        Get
            Return _DTax2
        End Get
        Set(ByVal value As Double)
            _DTax2 = value
        End Set
    End Property
    Public Property D_TaxExtra() As String
        Get
            Return _DTaxExtra
        End Get
        Set(ByVal value As String)
            _DTaxExtra = value
        End Set
    End Property

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
        _ShippingTotalWeight = 0
        _ShippingTotalExTax = 0
        _ShippingTotalTaxAmount = 0

        'Loop through all items in the basket
        For i = 0 To BasketItems.Count - 1
            With BasketItems(i)
                'Are all the items free-shipping?
                _AllFreeShipping = _AllFreeShipping AndAlso .FreeShipping

                'Is at least one item got free shipping?
                _HasFreeShipping = _HasFreeShipping OrElse .FreeShipping

                _AllDigital = _AllDigital AndAlso (.DownloadType = "l" Or .DownloadType = "u")

                'Totals
                _TotalItems = _TotalItems + .Quantity
                _TotalWeight = _TotalWeight + .RowWeight
                _TotalExTax = _TotalExTax + .RowExTax
                _TotalTaxAmount = _TotalTaxAmount + .RowTaxAmount
                _TotalAmountSaved = _TotalAmountSaved + .RowAmountSaved

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

    End Sub

    Public Sub CalculateCoupon(ByVal strCouponCode As String, ByRef strCouponError As String, ByVal blnZeroTotalTaxRate As Boolean)
        Dim strCouponType As String = ""
        Dim numCouponValue As Double

        CouponDiscount = New BasketModifier
        CustomerDiscount = New BasketModifier

        Call GetCouponDiscount(strCouponCode, strCouponError, strCouponType, numCouponValue)

        CouponDiscount.TaxRate = TotalDiscountPriceTaxRate
        Select Case strCouponType.ToLower
            Case "p"
                'Percentage coupons
                CouponDiscount.IncTax = -Math.Round((numCouponValue * TotalDiscountPriceIncTax / 100), CurrencyRoundNumber)
                CouponDiscount.ExTax = -Math.Round((numCouponValue * TotalDiscountPriceExTax / 100), CurrencyRoundNumber)

            Case "f"
                'Fixed rate coupons
                If numCouponValue > TotalDiscountPriceExTax Then
                    CouponDiscount.ExTax = -TotalDiscountPriceExTax
                    CouponDiscount.IncTax = -TotalDiscountPriceIncTax
                Else
                    Dim blnPricesExtax As Boolean = False

                    If Not blnZeroTotalTaxRate Then
                        If GetKartConfig("general.tax.pricesinctax") = "y" Then
                            CouponDiscount.ExTax = -Math.Round(numCouponValue * (1 / (1 + CouponDiscount.TaxRate)), CurrencyRoundNumber)
                            If D_Tax = 1 Then
                                CouponDiscount.IncTax = -Math.Round(numCouponValue, CurrencyRoundNumber)
                            Else
                                CouponDiscount.IncTax = CouponDiscount.ExTax
                            End If
                        Else
                            blnPricesExtax = True
                        End If
                    Else
                        blnPricesExtax = True
                    End If

                    If blnPricesExtax Then
                        CouponDiscount.IncTax = -Math.Round(numCouponValue * (1 + CouponDiscount.TaxRate), CurrencyRoundNumber)
                        CouponDiscount.ExTax = -Math.Round(numCouponValue, CurrencyRoundNumber)
                    End If
                End If

            Case Else
                'Dodgy coupon - ignore
                CouponDiscount.IncTax = 0
                CouponDiscount.ExTax = 0
        End Select

    End Sub

    Public Sub CalculateCustomerDiscount(ByVal numCustomerDiscount As Double)

        CustomerDiscount = New BasketModifier

        CustomerDiscount.TaxRate = TotalDiscountPriceTaxRate
        CustomerDiscount.IncTax = -Math.Round(TotalDiscountPriceIncTax * (numCustomerDiscount / 100), CurrencyRoundNumber)
        CustomerDiscount.ExTax = -Math.Round(TotalDiscountPriceExTax * (numCustomerDiscount / 100), CurrencyRoundNumber)

        If Not (ApplyTax) Then
            CustomerDiscount.IncTax = CustomerDiscount.ExTax
        End If

    End Sub

    Sub New()

        _ApplyTax = True

        ShippingPrice = New BasketModifier
        OrderHandlingPrice = New BasketModifier
        CouponDiscount = New BasketModifier
        CustomerDiscount = New BasketModifier
        PromotionDiscount = New BasketModifier

    End Sub

    Public Shared Function CurrencyRoundNumber() As Short
        Try
            Dim numCurrencyID As Integer = Current.Session("CUR_ID")
            Dim rowCurrencies() As DataRow = GetCurrenciesFromCache().Select("CUR_ID = " & numCurrencyID)
            Return CInt(rowCurrencies(0)("CUR_RoundNumbers"))
        Catch ex As Exception
            Return 2
        End Try
    End Function

    Public Sub AddNewBasketValue(ByVal pParentType As BASKET_PARENTS, ByVal pParentID As Integer, _
     ByVal pVersionID As Long, ByVal pQuantity As Single, _
     Optional ByVal pCustomText As String = Nothing, _
     Optional ByVal pOptionsValues As String = Nothing, Optional ByVal numBasketValueID As Integer = 0)
        Dim chrParentType As Char = ""
        Select Case pParentType
            Case BASKET_PARENTS.BASKET
                chrParentType = "b"
            Case BASKET_PARENTS.SAVED_BASKET
                chrParentType = "s"
            Case BASKET_PARENTS.WISH_LIST
                chrParentType = "w"
        End Select

        Dim numIdenticalBasketValueID As Long = -1

        If numBasketValueID > 0 Then
            DeleteBasketItems(numBasketValueID)
        Else
            '' check if item to be added already in basket
            Dim arrOptions As String() = {""}
            If Not pOptionsValues Is Nothing Then
                arrOptions = Split(pOptionsValues, ",")
            End If

            Dim cntOption As Integer, numFoundBasketValueID As Integer = 0
            For Each oBasketItem As BasketItem In Current.Session("Basket").BasketItems
                If oBasketItem.VersionID = pVersionID Then
                    Dim strOption As String = Replace(oBasketItem.OptionLink, "&strOptions=", "")
                    If strOption = "" OrElse strOption = "0" Then '' not a version options so exit
                        If oBasketItem.CustomText = pCustomText Then
                            numIdenticalBasketValueID = oBasketItem.ID : Exit For
                        End If
                    Else
                        cntOption = 0
                        Dim arrBasketOptions As String()
                        arrBasketOptions = Split(strOption, ",")
                        If UBound(arrOptions) = UBound(arrBasketOptions) Then     ''possible it match.. same number of options
                            For i = LBound(arrOptions) To UBound(arrOptions)
                                For j = LBound(arrBasketOptions) To UBound(arrBasketOptions)
                                    If arrOptions(i) = arrBasketOptions(j) Then
                                        cntOption = cntOption + 1
                                        Exit For
                                    End If
                                Next
                            Next
                            If arrOptions.Count = cntOption Then
                                numIdenticalBasketValueID = oBasketItem.ID
                                Exit For
                            End If
                        End If
                    End If
                End If
            Next

        End If

        If numIdenticalBasketValueID = -1 Then
            '' The Item is not in the basket, so it should be added.
            Dim numNewBasketValueID As Long = Nothing
            If _BasketValuesAdptr.Insert(chrParentType, pParentID, pVersionID, _
             pQuantity, pCustomText, CkartrisDisplayFunctions.NowOffset, Nothing, numNewBasketValueID) <> 1 Then Exit Sub

            If numBasketValueID > 0 Then
                Dim aBasketItemInfo() As String = Split(Current.Session("BasketItemInfo"), ";")
                Current.Session("BasketItemInfo") = numNewBasketValueID & ";" & pVersionID & ";" & pQuantity
            End If

            '' Adding the Item options as well (if any)
            If Not pOptionsValues Is Nothing Then
                Dim arrOptions As String() = New String() {""}
                arrOptions = Split(pOptionsValues, ",")
                If arrOptions.GetUpperBound(0) >= 0 Then
                    For i As Integer = 0 To arrOptions.GetUpperBound(0)
                        If Val(arrOptions(i)) <> 0 Then AddBasketOptionValues(numNewBasketValueID, CInt(arrOptions(i)))
                    Next
                End If
            End If
            HttpContext.Current.Trace.Warn("^^^^^^^^^^^^^^ Version does NOT exist")

        Else

            '' The Item already exist in the basket, so the quantity will be increased.
            AddQuantityToMyBasket(numIdenticalBasketValueID, pQuantity)
            HttpContext.Current.Trace.Warn("^^^^^^^^^^^^^^ Version exists")

        End If

        HttpContext.Current.Session("NewBasketItem") = 1

    End Sub

    Private Function GetIdenticalBasketValueID(ByVal pParentID As Integer, ByVal pVersionID As Long, ByVal pOptionsValues As String, Optional ByVal strCustomText As String = "") As Long
        Dim numLanguageID As Short = 1
        Dim tblBasketItems As New DataTable

        tblBasketItems = GetBasketItems(pParentID, numLanguageID)

        Dim drwIdenticalVersion As DataRow()
        drwIdenticalVersion = tblBasketItems.Select("BV_VersionID=" & pVersionID & " AND isnull(BV_CustomText,'')='" & strCustomText & "'")

        Dim arrNewOptionValues As String() = New String() {}
        If Not pOptionsValues Is Nothing Then
            If pOptionsValues <> "" Then
                arrNewOptionValues = pOptionsValues.Split(",")
            End If
        End If

        If drwIdenticalVersion.Length = 0 Then
            HttpContext.Current.Trace.Warn("^^^^^^ version does NOT exist in my basket ")
            Return -1
        Else
            HttpContext.Current.Trace.Warn("^^^^^^ " & drwIdenticalVersion.GetUpperBound(0) & " Identical versions exist in my basket ")
            For i As Integer = 0 To drwIdenticalVersion.GetUpperBound(0)
                If CInt(drwIdenticalVersion(i)("NoOfOptions")) <> arrNewOptionValues.Length Then
                    Continue For
                Else
                    If CInt(drwIdenticalVersion(i)("NoOfOptions")) <> 0 Then
                        '' Read the options from database .. for the current BasketValueID
                        Dim strExistingOptionValues As String
                        strExistingOptionValues = GetMiniBasketOptions(CLng(drwIdenticalVersion(i)("BV_ID")))

                        Dim arrOldOptionValues As String() = New String() {""}
                        arrOldOptionValues = strExistingOptionValues.Split(",")

                        Dim numIdenticalOptionsCounter As Integer = 0
                        For iNew As Integer = 0 To arrNewOptionValues.GetUpperBound(0)
                            For iOld As Integer = 0 To arrOldOptionValues.GetUpperBound(0)
                                If arrNewOptionValues(iNew) = arrOldOptionValues(iOld) Then
                                    numIdenticalOptionsCounter += 1
                                    Exit For
                                End If
                            Next
                        Next

                        If numIdenticalOptionsCounter = arrNewOptionValues.Length Then
                            Return CLng(drwIdenticalVersion(i)("BV_ID"))
                        End If

                        HttpContext.Current.Trace.Warn( _
                          "^^^^^^ options identical found BV_ID=" & drwIdenticalVersion(i)("BV_ID"))
                    Else
                        Return CLng(drwIdenticalVersion(i)("BV_ID"))
                    End If
                End If
            Next
            Return -1
        End If
        Return -1
    End Function

    Private Sub AddQuantityToMyBasket(ByVal pBasketValueID As Long, ByVal pQuantityToAdd As String)
        _BasketValuesAdptr.AddQuantityToItem(pQuantityToAdd, pBasketValueID)
    End Sub

    Public Function GetBasketItems(ByVal pSessionID As Long, ByVal pLanguageID As Short) As DataTable
        Return _BasketValuesAdptr.GetBasketItems(pSessionID, pLanguageID)
    End Function

    Public Function GetMiniBasketOptions(ByVal pBasketValueID As Long) As String
        Dim tblBasketOptions As New DataTable
        tblBasketOptions = _BasketOptionsAdptr.GetBasketOptionsByBasketValueID(pBasketValueID)

        Dim strBasketOptions As String = Nothing
        For Each drwOptions As DataRow In tblBasketOptions.Rows
            strBasketOptions += CStr(drwOptions("BSKTOPT_OptionID")) + ","
        Next
        If Not strBasketOptions Is Nothing Then strBasketOptions = strBasketOptions.TrimEnd(",")

        Return strBasketOptions
    End Function

    Private Sub AddBasketOptionValues(ByVal pBasketValueID As Long, ByVal pOptionID As Integer)
        _BasketOptionsAdptr.Insert(pBasketValueID, pOptionID)
    End Sub

    Public Function GetItems() As ArrayList
        Return BasketItems
    End Function
    ''' <summary>
    ''' Loads the basket items from the database - this is usually called in every postback
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub LoadBasketItems()
        Dim objItem As BasketItem
        Dim tblBasketValues As New DataTable

        Dim SESS_CurrencyID As Short
        If numCurrencyID > 0 Then
            SESS_CurrencyID = numCurrencyID
        Else
            SESS_CurrencyID = Current.Session("CUR_ID")
        End If

        numLanguageID = Current.Session("LANG")
        numSessionID = Current.Session("SessionID")
        BasketItems.Clear()

        tblBasketValues = _BasketValuesAdptr.GetItems(numLanguageID, numSessionID)

        Try
            For Each drwBasketValues As DataRow In tblBasketValues.Rows
                objItem = New BasketItem
                objItem.ProductID = drwBasketValues("ProductID")
                objItem.ProductType = drwBasketValues("ProductType")
                objItem.TaxRate1 = FixNullFromDB(drwBasketValues("TaxRate"))
                objItem.TaxRate2 = FixNullFromDB(drwBasketValues("TaxRate2"))
                objItem.TaxRateItem = FixNullFromDB(drwBasketValues("TaxRate"))
                objItem.Weight = FixNullFromDB(drwBasketValues("Weight"))
                objItem.RRP = FixNullFromDB(drwBasketValues("RRP"))
                objItem.ProductName = drwBasketValues("ProductName") & ""
                objItem.ID = drwBasketValues("BV_ID")
                objItem.VersionBaseID = drwBasketValues("V_ID")
                objItem.VersionID = drwBasketValues("BV_VersionID")
                objItem.VersionName = drwBasketValues("VersionName") & ""
                objItem.VersionCode = drwBasketValues("CodeNumber") & ""
                objItem.CodeNumber = drwBasketValues("CodeNumber") & ""
                objItem.Price = FixNullFromDB(drwBasketValues("Price"))
                objItem.Quantity = FixNullFromDB(drwBasketValues("Quantity"))
                objItem.StockQty = FixNullFromDB(drwBasketValues("V_Quantity"))
                objItem.QtyWarnLevel = FixNullFromDB(drwBasketValues("QtyWarnLevel"))
                objItem.DownloadType = drwBasketValues("V_DownloadType") & ""
                objItem.OptionPrice = Math.Round(CDbl(FixNullFromDB(drwBasketValues("OptionsPrice"))), CurrencyRoundNumber)
                objItem.CategoryIDs = GetCategoryIDs(objItem.ProductID)
                objItem.PromoQty = objItem.Quantity

                objItem.OptionText = GetOptionText(numLanguageID, objItem.ID, objItem.OptionLink)
                If objItem.OptionText <> "" Then
                    objItem.HasCombinations = True
                    objItem.OptionLink = "&strOptions=" & objItem.OptionLink
                Else
                    objItem.OptionLink = "&strOptions=0"
                End If

                objItem.CustomText = drwBasketValues("CustomText") & ""
                objItem.CustomType = drwBasketValues("V_CustomizationType") & ""
                objItem.CustomDesc = drwBasketValues("V_CustomizationDesc") & ""
                objItem.CustomCost = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, FixNullFromDB(drwBasketValues("V_CustomizationCost")))), CurrencyRoundNumber)
                objItem.Price = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, objItem.Price)), CurrencyRoundNumber)
                objItem.TableText = ""

                If ObjectConfigBLL.GetValue("K:product.usecombinationprice", objItem.ProductID) = "1" Then
                    objItem.Price = FixNullFromDB(drwBasketValues("CombinationPrice"))
                    objItem.Price = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, objItem.Price)), CurrencyRoundNumber)
                    objItem.OptionPrice = Math.Round(0, CurrencyRoundNumber)
                End If

                'Handle the price differently if basket item is from a custom product
                Dim strCustomControlName As String = ObjectConfigBLL.GetValue("K:product.customcontrolname", objItem.ProductID)
                If Not String.IsNullOrEmpty(strCustomControlName) Then
                    Try
                        Dim strParameterValues As String = FixNullFromDB(drwBasketValues("CustomText"))
                        'Split the custom text field
                        Dim arrParameters As String() = Split(strParameterValues, "|||")

                        ' arrParameters(0) contains the comma separated list of the custom control's parameters values
                        ' we don't use this value when loading the basket, this is only needed when validating the price in the checkout

                        ' arrParameters(1) contains the custom description of the item
                        If Not String.IsNullOrEmpty(arrParameters(1)) Then
                            objItem.VersionName = arrParameters(1)
                        End If

                        ' arrParameters(2) contains the custom price
                        objItem.Price = arrParameters(2)

                        'just set the option price to 0 just to be safe
                        objItem.OptionPrice = Math.Round(0, CurrencyRoundNumber)
                    Catch ex As Exception
                        'Failed to retrieve custom price, ignore this basket item
                        objItem.Quantity = 0
                    End Try

                End If

                'there must be something wrong if quantity is 0 so don't add this item to the basketitems array
                If objItem.Quantity > 0 Then BasketItems.Add(objItem)
            Next
        Catch ex As Exception
            SqlConnection.ClearPool(_BasketValuesAdptr.Connection)
            CkartrisFormatErrors.LogError("BasketBLL.LoadBasketItems - " & ex.Message)
        End Try
        

        ShippingPrice = New BasketModifier
        OrderHandlingPrice = New BasketModifier
        CouponDiscount = New BasketModifier
        CustomerDiscount = New BasketModifier
        PromotionDiscount = New BasketModifier

    End Sub

    Public Function Validate(ByVal blnAllowOutOfStock As Boolean) As Boolean
        Dim blnAllowPurchaseOutOfStock, blnOnlyOneDownload As Boolean
        Dim objItem As New BasketItem
        Dim blnWarn As Boolean
        Dim numWeight, numPrice As Double
        Dim V_DownloadType As String
        Dim SESS_CurrencyID As Short

        If numCurrencyID > 0 Then
            SESS_CurrencyID = numCurrencyID
        Else
            SESS_CurrencyID = Current.Session("CUR_ID")
        End If

        'Set variables from application
        _AdjustedForElectronic = False
        _AdjustedQuantities = False

        'If LCase(GetKartConfig("general.tax.usmultistatetax")) = "y" Then PricesIncTax = False Else PricesIncTax = (LCase(GetKartConfig("general.tax.pricesinctax")) = "y")
        'If TaxRegime.Name.ToLower = "us" Then PricesIncTax = False Else PricesIncTax = (LCase(GetKartConfig("general.tax.pricesinctax")) = "y")
        PricesIncTax = (LCase(GetKartConfig("general.tax.pricesinctax")) = "y")

        blnAllowPurchaseOutOfStock = LCase(GetKartConfig("frontend.orders.allowpurchaseoutofstock")) = "y"
        blnOnlyOneDownload = LCase(GetKartConfig("onlyonedownload")) = "y"

        'Only proceed if we have basket items
        If BasketItems.Count > 0 Then

            ''Loop through all basket records
            For i As Integer = 0 To BasketItems.Count - 1
                objItem = BasketItems(i)
                With objItem
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
                                .Quantity = .StockQty
                            End If
                        End If
                    End If

                    'Get basic price, modify for customer group pricing (if lower)
                    numPrice = .Price

                    'Get basic price, modify for customer group pricing (if lower)
                    Dim numCustomerGroupPrice As Double
                    numCustomerGroupPrice = GetCustomerGroupPriceForVersion(DB_C_CustomerID, objItem.VersionBaseID)
                    If numCustomerGroupPrice > 0 Then
                        'convert customer group price to current user currency
                        numCustomerGroupPrice = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, numCustomerGroupPrice)), CurrencyRoundNumber)
                        numPrice = Math.Min(numCustomerGroupPrice, numPrice)
                    End If

                    If Not String.IsNullOrEmpty(.CustomText) Then
                        Dim strCustomControlName As String = ObjectConfigBLL.GetValue("K:product.customcontrolname", objItem.ProductID)
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
                        numDiscountPrice = GetQuantityDiscount(objItem.VersionBaseID, objItem.Quantity)
                        If numDiscountPrice > 0 Then
                            'convert discount price to current user currency
                            numDiscountPrice = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, numDiscountPrice)), CurrencyRoundNumber)
                            numPrice = Math.Min(numDiscountPrice, numPrice)
                        End If
                    End If

                    If LCase(.ProductType) = "o" Then
                        numPrice = numPrice + objItem.OptionPrice
                    End If

                    'Calculate the ex-tax - this differs as numPrice will hold 
                    'a different value depending on pricesinctax
                    If PricesIncTax Then
                        .ExTax = numPrice * (1 / (1 + .ComputedTaxRate))
                    Else
                        .ExTax = numPrice
                    End If

                    If Not ApplyTax Then .ComputedTaxRate = 0

                    'Set the weight
                    .Weight = numWeight

                    If .Quantity = 0 Then
                        BasketItems.Remove(objItem)
                        _BasketValuesAdptr.UpdateQuantity(.ID, 0)
                        Current.Response.Redirect("~/Basket.aspx")
                    End If

                End With
            Next
        End If
        Return True
    End Function

    Public Sub DeleteBasket(Optional ByVal numParentID As Long = 0)
        If numParentID = 0 Then numParentID = Current.Session("SessionID")
        _BasketValuesAdptr.DeleteBasketItems(1, numParentID)
    End Sub

    Public Sub DeleteBasketItems(ByVal numBasketID As Long)
        _BasketValuesAdptr.DeleteBasketItems(2, numBasketID)
    End Sub

    Public Sub UpdateQuantity(ByVal intBasketID As Integer, ByVal numQuantity As Single)
        If numQuantity > 0 Then
            _BasketValuesAdptr.UpdateQuantity(intBasketID, numQuantity)
        End If
    End Sub

    Public Sub GetCouponDiscount(ByVal strCouponCode As String, ByRef strCouponError As String, ByRef strCouponType As String, ByRef numCouponValue As Double)
        Dim tblCoupons As CouponsDataTable

        _CouponName = "" : _CouponCode = ""

        tblCoupons = _CouponsAdptr.GetCouponCode(strCouponCode)
        If tblCoupons.Rows.Count = 0 Then
            strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponDoesntExist")
        Else
            Dim drwCoupon As DataRow = tblCoupons.Rows(0)
            If drwCoupon("CP_Used") AndAlso Not (drwCoupon("CP_Reusable")) Then
                strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponExpended")
            ElseIf CDate(drwCoupon("CP_StartDate")) > CkartrisDisplayFunctions.NowOffset Then
                strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponNotYetValid")
            ElseIf CDate(drwCoupon("CP_EndDate")) < CkartrisDisplayFunctions.NowOffset OrElse Not (drwCoupon("CP_Enabled")) Then
                strCouponError = GetGlobalResourceObject("Basket", "ContentText_CouponExpired")
            Else
                numCouponValue = drwCoupon("CP_DiscountValue")
                strCouponType = drwCoupon("CP_DiscountType")
                If strCouponType.ToLower = "p" Then
                    _CouponName = drwCoupon("CP_CouponCode") & " - " & numCouponValue & "%"
                ElseIf strCouponType.ToLower = "t" Then
                    _CouponName = drwCoupon("CP_CouponCode") & " - " & GetPromotionText(drwCoupon("CP_DiscountValue"), True)
                Else
                    _CouponName = drwCoupon("CP_CouponCode") & " - " & CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), drwCoupon("CP_DiscountValue"))
                End If
                _CouponCode = drwCoupon("CP_CouponCode")
            End If
        End If

    End Sub

    Public Function GetCustomerDiscount(ByVal numCustomerID As Integer) As Double
        Dim tblCustomers As CustomersDataTable
        Dim numDiscount As Double = 0

        tblCustomers = _CustomersAdptr.GetCustomerDiscount(numCustomerID)
        If tblCustomers.Rows.Count > 0 Then
            numDiscount = tblCustomers.Rows(0).Item("Discount")
        End If

        _CustomerDiscountPercentage = numDiscount

        Return numDiscount
    End Function

    Public Function GetCustomerGroupPriceForVersion(ByVal intCustomerID As Integer, ByVal numVersionID As Long) As Double
        Dim tblCustomers As CustomersDataTable
        Dim numPrice As Double = 0

        tblCustomers = _CustomersAdptr.GetCustomerGroupPrice(intCustomerID, numVersionID)
        If tblCustomers.Rows.Count > 0 Then
            numPrice = tblCustomers.Rows(0).Item("CGP_Price")
        End If

        Return numPrice

    End Function

    Public Function GetQuantityDiscount(ByVal numVersionID As Long, ByVal numQuantity As Double) As Double
        Dim tblCustomers As CustomersDataTable
        Dim numDiscount As Double = 0

        tblCustomers = _CustomersAdptr.GetQtyDiscount(numVersionID, numQuantity)
        If tblCustomers.Rows.Count > 0 Then
            numDiscount = tblCustomers.Rows(0).Item("QD_Price")
        End If

        Return numDiscount
    End Function

    Public Function GetCustomerData(ByVal numUserID As Long) As DataTable
        Dim tblCustomers As New DataTable
        tblCustomers = _CustomersAdptr.GetCustomer(numUserID, "", "")
        Return tblCustomers
    End Function

    Public Sub SaveCustomText(ByVal numBasketItemID As Long, ByVal strCustomText As String)
        _BasketValuesAdptr.SaveCustomText(numBasketItemID, strCustomText)
    End Sub

    Public Sub SaveBasket(ByVal numCustomerID As Long, ByVal strBasketName As String, ByVal numBasketID As Long)
        _CustomersAdptr.SaveBasket(numCustomerID, strBasketName, numBasketID, CkartrisDisplayFunctions.NowOffset)
    End Sub

    Public Function GetSavedBasket(ByVal numUserID As Long, Optional ByVal PageIndex As Integer = -1, Optional ByVal PageSize As Integer = -1) As DataTable
        Dim tblSavedBaskets As New DataTable
        tblSavedBaskets = _CustomersAdptr.GetSavedBasket(1, numUserID, PageIndex, PageIndex + PageSize - 1)
        Return tblSavedBaskets
    End Function

    Public Function GetSavedBasketTotal(ByVal numUserID As Long) As Integer
        Dim tblSavedBaskets As New DataTable
        Dim numTotalBasket As Integer = 0

        tblSavedBaskets = _CustomersAdptr.GetSavedBasket(0, numUserID, 0, 0)
        If tblSavedBaskets.Rows.Count > 0 Then
            numTotalBasket = tblSavedBaskets.Rows(0).Item("TotalRec")
        End If

        tblSavedBaskets.Dispose()
        Return numTotalBasket
    End Function

    Public Sub DeleteSavedBasket(ByVal numBasketID As Long)
        _CustomersAdptr.DeleteSavedBasket(numBasketID)
    End Sub

    Public Sub LoadSavedBasket(ByVal numBasketSavedID As Long, ByVal numBasketID As Long)
        _CustomersAdptr.LoadSavedBasket(numBasketSavedID, numBasketID, CkartrisDisplayFunctions.NowOffset)
    End Sub

    Public Sub SaveWishLists(ByVal numWishlistsID As Long, ByVal numBasketID As Long, ByVal numUserID As Integer, ByVal strName As String, ByVal strPublicPassword As String, ByVal strMessage As String)
        _CustomersAdptr.SaveWishList(numWishlistsID, numBasketID, numUserID, strName, strPublicPassword, strMessage, CkartrisDisplayFunctions.NowOffset)
    End Sub

    Public Function GetWishListTotal(ByVal numUserId As Long) As Integer
        Dim tblWishList As New DataTable
        Dim numTotalWishList As Integer = 0

        tblWishList = _CustomersAdptr.GetWishList(0, numUserId, 0, 0, 0, "", "", 0)
        If tblWishList.Rows.Count > 0 Then
            numTotalWishList = tblWishList.Rows(0).Item("TotalRec")
        End If

        tblWishList.Dispose()
        Return numTotalWishList
    End Function

    Public Function GetWishLists(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = -1, Optional ByVal PageSize As Integer = -1) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(1, numUserId, PageIndex, PageIndex + PageSize - 1, 0, "", "", 0)
        Return tblWishList
    End Function

    Public Function GetWishListByID(ByVal numWishlistID As Long) As DataTable
        Dim tblWishList As DataTable
        tblWishList = _CustomersAdptr.GetWishList(2, 0, 0, 0, numWishlistID, "", "", 0)
        Return tblWishList
    End Function

    Public Function GetCustomerWishList(ByVal numCustomerID As Long, ByVal numWishlistID As Long) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(2, numCustomerID, 0, 0, numWishlistID, "", "", 0)
        Return tblWishList
    End Function

    Public Function GetWishListLogin(ByVal strEmail As String, ByVal strPassword As String) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(3, 0, 0, 0, 0, strEmail, strPassword, 0)
        Return tblWishList
    End Function

    Public Function GetRequiredWishlist(ByVal numCustomerID As Long, ByVal numWishlistID As Long, ByVal numLanguage As Short) As DataTable
        Dim tblWishList As New DataTable
        tblWishList = _CustomersAdptr.GetWishList(4, numCustomerID, 0, 0, numWishlistID, "", "", numLanguage)
        Return tblWishList
    End Function

    Public Sub DeleteWishLists(ByVal numWishListsID As Long)
        _CustomersAdptr.DeleteWishList(numWishListsID)
    End Sub

    Public Sub LoadWishlists(ByVal numWishlistsID As Long, ByVal numBasketID As Long)
        _CustomersAdptr.LoadWishlist(numWishlistsID, numBasketID, CkartrisDisplayFunctions.NowOffset)
    End Sub

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
                    If GetKartConfig("frontend.checkout.shipping.calcbyweight") = "y" Then
                        ShippingBoundary = _ShippingTotalWeight
                    Else
                        If KartSettingsManager.GetKartConfig("general.tax.pricesinctax") <> "y" Then
                            ShippingBoundary = _ShippingTotalExTax
                        Else
                            ShippingBoundary = ShippingTotalIncTax
                        End If
                    End If

                    Dim SelectedSM As ShippingMethod = ShippingMethod.GetByID(objShippingDetails, numShippingID, numDestinationID, CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, ShippingBoundary, numCurrencyID), numLanguageID)
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
                                                          & "ShippingID: " & numShippingID)

                    _ShippingName = ""
                    _ShippingDescription = ""
                    Current.Response.Redirect("~/Checkout.aspx")
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

    Public Sub CalculateOrderHandlingCharge(ByVal numShippingCountryID As Integer)
        Dim numOrderHandlingPriceValue As Double, numOrderHandlingTaxBand1 As Double = 0, numOrderHandlingTaxBand2 As Double = 0

        If numShippingCountryID = 0 Then Exit Sub

        numOrderHandlingPriceValue = KartSettingsManager.GetKartConfig("frontend.checkout.orderhandlingcharge")

        Dim SESS_CurrencyID As Short
        If numCurrencyID > 0 Then
            SESS_CurrencyID = numCurrencyID
        Else
            SESS_CurrencyID = Current.Session("CUR_ID")
        End If

        If SESS_CurrencyID <> CurrenciesBLL.GetDefaultCurrency Then numOrderHandlingPriceValue = CurrenciesBLL.ConvertCurrency(SESS_CurrencyID, numOrderHandlingPriceValue)

        Dim DestinationCountry As Country = Country.Get(numShippingCountryID)

        If ConfigurationManager.AppSettings("TaxRegime").tolower = "us" Then
            OrderHandlingPrice.TaxRate = DestinationCountry.ComputedTaxRate
            D_Tax = DestinationCountry.ComputedTaxRate

            Try
                If Current.Session("blnEUVATValidated") IsNot Nothing Then
                    If CBool(Current.Session("blnEUVATValidated")) Then
                        DestinationCountry.D_Tax = False
                        DestinationCountry.ComputedTaxRate = 0
                        DestinationCountry.TaxRate1 = 0
                        DestinationCountry.TaxRate2 = 0
                        D_Tax = 0
                    End If
                End If
            Catch ex As Exception

            End Try
        Else
            If DestinationCountry.D_Tax Then D_Tax = 1 Else D_Tax = 0

            Try
                If Current.Session("blnEUVATValidated") IsNot Nothing Then
                    If CBool(Current.Session("blnEUVATValidated")) Then
                        DestinationCountry.D_Tax = False
                        D_Tax = 0
                    End If
                End If
            Catch ex As Exception

            End Try

            Try
                numOrderHandlingTaxBand1 = KartSettingsManager.GetKartConfig("frontend.checkout.orderhandlingchargetaxband")
                numOrderHandlingTaxBand2 = KartSettingsManager.GetKartConfig("frontend.checkout.orderhandlingchargetaxband2")
            Catch ex As Exception
            End Try

            OrderHandlingPrice.TaxRate = TaxRegime.CalculateTaxRate(TaxBLL.GetTaxRate(numOrderHandlingTaxBand1), TaxBLL.GetTaxRate(numOrderHandlingTaxBand2), DestinationCountry.TaxRate1,
                                                            DestinationCountry.TaxRate2, DestinationCountry.TaxExtra)

        End If



        If PricesIncTax Then
            OrderHandlingPrice.ExTax = Math.Round(numOrderHandlingPriceValue * (1 / (1 + OrderHandlingPrice.TaxRate)), CurrencyRoundNumber)

            'If tax is off, then inc tax can be set to just the ex tax
            If DestinationCountry.D_Tax Then
                'Set the inctax order handling values
                OrderHandlingPrice.IncTax = Math.Round(numOrderHandlingPriceValue, CurrencyRoundNumber)
            Else
                OrderHandlingPrice.IncTax = OrderHandlingPrice.ExTax
                OrderHandlingPrice.TaxRate = 0
            End If
        Else
            'Set the extax order handling values
            OrderHandlingPrice.ExTax = numOrderHandlingPriceValue

            'Tax rate for order handling
            If DestinationCountry.D_Tax Then
                OrderHandlingPrice.IncTax = Math.Round(OrderHandlingPrice.ExTax * (1 + OrderHandlingPrice.TaxRate), CurrencyRoundNumber)
            Else
                OrderHandlingPrice.IncTax = numOrderHandlingPriceValue
                OrderHandlingPrice.TaxRate = 0
            End If
        End If

    End Sub

    Public Function GetCustomerOrders(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = -1, Optional ByVal PageSize As Integer = -1) As DataTable
        Dim tblCustomerOrders As New DataTable
        tblCustomerOrders = _CustomersAdptr.GetCustomerOrders(1, numUserId, PageIndex, PageIndex + PageSize - 1)
        Return tblCustomerOrders
    End Function

    Public Function GetCustomerOrdersTotal(ByVal numUserId As Long) As Integer
        Dim tblCustomerOrders As New DataTable
        Dim numTotalOrders As Integer = 0

        tblCustomerOrders = _CustomersAdptr.GetCustomerOrders(0, numUserId, 0, 0)
        If tblCustomerOrders.Rows.Count > 0 Then
            numTotalOrders = tblCustomerOrders.Rows(0).Item("TotalRec")
        End If

        tblCustomerOrders.Dispose()
        Return numTotalOrders
    End Function

    Public Function GetCustomerOrderDetails(ByVal numOrderID As Integer) As DataTable
        Dim tblCustomerOrders As New DataTable
        tblCustomerOrders = _CustomersAdptr.GetOrderDetails(numOrderID)
        Return tblCustomerOrders
    End Function

    Public Function GetDownloadableProducts(ByVal numUserID As Integer) As DataTable
        Dim tblDownloads As New DataTable
        Dim O_Shipped As Boolean = LCase(GetKartConfig("frontend.downloads.instant")) = "n"
        Dim intDaysAvailable As Integer = 0
        Try
            intDaysAvailable = CInt(LCase(GetKartConfig("frontend.downloads.daysavailable")))
        Catch ex As Exception
        End Try

        Dim datAvailableUpTo As DateTime
        If intDaysAvailable > 0 Then
            datAvailableUpTo = Today.AddDays(-intDaysAvailable)
        Else
            datAvailableUpTo = Today.AddYears(-100)
        End If
        tblDownloads = _CustomersAdptr.GetDownloadableProducts(numUserID, O_Shipped, datAvailableUpTo)
        Return tblDownloads
    End Function

    Public Shared Function GetCustomerInvoice(ByVal numOrderID As Integer, ByVal numUserID As Integer, Optional ByVal numType As Integer = 0) As DataTable
        Dim tblInvoice As New DataTable
        tblInvoice = _CustomersAdptr.GetInvoice(numOrderID, numUserID, numType)
        Return tblInvoice
    End Function

    Public Shared Function GetRandomString(ByVal numLength As Integer) As String
        Dim strRandomString As String
        Dim numRandomNumber As Integer

        Randomize()
        strRandomString = ""

        Do While Len(strRandomString) < numLength
            numRandomNumber = Int(Rnd(1) * 36) + 1
            If numRandomNumber < 11 Then
                'If it's less than 11 then we'll do a number
                strRandomString = strRandomString & Chr(numRandomNumber + 47)
            Else
                'Otherwise we'll do a letter; + 86 because 96 (min being 97, 'a') - 10 (the first 10 was for the number)
                strRandomString = strRandomString & Chr(numRandomNumber + 86)
            End If
        Loop

        'Zero and 'o' and '1' and 'I' are easily confused...
        'So we replace any of these with alternatives
        'To ensure best randomness, replace the numbers
        'with alternative letters and letters
        'with alternative numbers

        strRandomString = Replace(strRandomString, "0", "X")
        strRandomString = Replace(strRandomString, "1", "Y")
        strRandomString = Replace(strRandomString, "O", "4")
        strRandomString = Replace(strRandomString, "I", "9")

        Return strRandomString
    End Function

    Public Function GetCouponData(ByVal strCouponName As String) As DataTable
        Dim tblCoupon As New DataTable
        tblCoupon = _CouponsAdptr.GetCouponCode(strCouponName)
        Return tblCoupon
    End Function

    Public Function GetVersionCustomType(ByVal numVersionID As Long) As String
        Dim strCustomType As String = ""
        Dim tblCoupon As CustomersDataTable

        tblCoupon = _CustomersAdptr.GetCustomization(numVersionID)

        If tblCoupon.Rows.Count > 0 Then
            strCustomType = tblCoupon.Rows(0).Item("V_CustomizationType") & ""
        End If

        Return strCustomType
    End Function

    Public Function GetCustomization(ByVal numVersionID As Long) As DataTable
        Dim tblCustomization As DataTable
        tblCustomization = _CustomersAdptr.GetCustomization(numVersionID)
        Return tblCustomization
    End Function

#Region "Promotions"

    Private Function GetBasketItemVersionIDs() As String
        Dim strIDs As String = ""
        For i As Integer = 0 To BasketItems.Count - 1
            Dim objItem As BasketItem = BasketItems(i)
            strIDs = strIDs & objItem.VersionID & ","
        Next
        If strIDs <> "" Then
            strIDs = Left(strIDs, Len(strIDs) - 1)
        End If
        Return strIDs
    End Function

    Private Function GetBasketItemProductIDs() As String
        Dim strIDs As String = ""
        For i As Integer = 0 To BasketItems.Count - 1
            Dim objItem As BasketItem = BasketItems(i)
            strIDs = strIDs & objItem.ProductID & ","
        Next
        strIDs = IIf(strIDs <> "", Left(strIDs, Len(strIDs) - 1), strIDs)
        Return strIDs
    End Function

    Private Function GetBasketItemCategoryIDs() As String
        Dim strIDs As String = ""
        For i As Integer = 0 To BasketItems.Count - 1
            Dim objItem As BasketItem = BasketItems(i)
            strIDs = strIDs & objItem.CategoryIDs & ","
        Next
        strIDs = IIf(strIDs <> "", Left(strIDs, Len(strIDs) - 1), strIDs)
        Return strIDs
    End Function

    Private Function GetBasketItemByVersionID(ByVal numVersionID As Integer, Optional ByVal blnReload As Boolean = False) As BasketItem
        If blnReload Then
            LoadBasketItems()
            BasketItems = GetItems()
        End If

        For i As Integer = 0 To BasketItems.Count - 1
            Dim objItem As BasketItem = BasketItems(i)
            If objItem.VersionID = numVersionID Then Return objItem
        Next
        Return Nothing
    End Function

    Private Function GetItemMaxProductValue(ByVal numProductID As Integer) As Integer
        Dim objItem, tmpItem As New BasketItem
        Dim index As Integer = -1

        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If objItem.ProductID = numProductID And objItem.PromoQty > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax > tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function

    Private Function GetItemMinProductValue(ByVal numProductID As Integer, Optional ByVal strVersionIDArray As String = "") As Integer
        Dim objItem, tmpItem As New BasketItem
        Dim index As Integer = -1
        Dim arrVersionIDsToExclude As String() = Nothing


        If strVersionIDArray <> "" Then
            arrVersionIDsToExclude = Split(strVersionIDArray, ",")
        End If
        Dim blnSkipVersion As Boolean = False

        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If arrVersionIDsToExclude IsNot Nothing Then
                blnSkipVersion = False
                For x As Integer = 0 To arrVersionIDsToExclude.Count - 1
                    If arrVersionIDsToExclude(x) = objItem.VersionID Then
                        blnSkipVersion = True
                        Continue For
                    End If
                Next
                If blnSkipVersion Then Continue For
            End If
            'If MinVersionID > 0 AndAlso MinVersionID = objItem.VersionID Then Continue For
            If objItem.ProductID = numProductID And objItem.PromoQty > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax < tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function

    Private Function GetItemMaxCategoryValue(ByVal numProductID As Integer) As Integer
        Dim objItem, tmpItem As New BasketItem
        Dim index As Integer = -1

        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If InStr(objItem.CategoryIDs, numProductID.ToString) > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax > tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function
    Private Function GetItemMinCategoryValue(ByVal numProductID As Integer, Optional ByVal strVersionIDArray As String = "") As Integer
        Dim objItem, tmpItem As New BasketItem
        Dim index As Integer = -1
        Dim arrVersionIDsToExclude As String() = Nothing

        If strVersionIDArray <> "" Then
            arrVersionIDsToExclude = Split(strVersionIDArray, ",")
        End If
        Dim blnSkipVersion As Boolean = False

        For i As Integer = 0 To BasketItems.Count - 1
            objItem = BasketItems(i)
            If arrVersionIDsToExclude IsNot Nothing Then
                blnSkipVersion = False
                For x As Integer = 0 To arrVersionIDsToExclude.Count - 1
                    If arrVersionIDsToExclude(x) = objItem.VersionID Then
                        blnSkipVersion = True
                        Continue For
                    End If
                Next
                If blnSkipVersion Then Continue For
            End If
            If InStr(objItem.CategoryIDs, numProductID.ToString) > 0 Then
                index = IIf(index = -1, i, index)
                tmpItem = BasketItems(index)
                If objItem.IncTax < tmpItem.IncTax Then
                    index = i
                End If
            End If
        Next

        Return index
    End Function

    Public Function GetPromotions(ByVal numLanguageID As Integer) As DataTable
        Dim tblPromotions As New DataTable
        tblPromotions = _CustomersAdptr.GetPromotions(numLanguageID)
        Return tblPromotions
    End Function

    Public Function GetOptionText(ByVal numLanguageID As Integer, ByVal numBasketItemID As Integer, ByRef strOptionLink As String) As String
        Dim tblOptionText As New DataTable
        Dim strOptionText As String = ""
        Dim strOptions, strBreak As String

        strBreak = "<br />"
        strOptions = ""

        tblOptionText = _CustomersAdptr.GetOptionText(numLanguageID, numBasketItemID)
        If tblOptionText.Rows.Count > 0 Then
            For Each drwOptionText As DataRow In tblOptionText.Rows
                If LCase(drwOptionText("OPTG_OptionDisplayType") & "") = "c" Then
                    strOptionText = strOptionText & drwOptionText("LE_Value") & strBreak
                Else
                    strOptionText = strOptionText & drwOptionText("OPTG_BackendName") & ": " & drwOptionText("LE_Value") & strBreak
                End If
                strOptions = strOptions & drwOptionText("BSKTOPT_OptionID") & ","
            Next
        End If

        tblOptionText.Dispose()

        If strOptions <> "" Then strOptions = Left(strOptions, strOptions.Length - 1)
        strOptionLink = strOptions

        Return strOptionText
    End Function

    Public Function GetCategoryIDs(ByVal numProductID As Long) As String
        Dim tblCategoryIDs As New DataTable
        Dim strCategoryIDs As String = ""

        tblCategoryIDs = _CustomersAdptr.GetCategoryID(numProductID)

        If tblCategoryIDs.Rows.Count > 0 Then
            For Each drwCategoryID As DataRow In tblCategoryIDs.Rows
                strCategoryIDs = strCategoryIDs & drwCategoryID("PCAT_CategoryID") & ","
            Next
        End If

        If strCategoryIDs <> "" Then strCategoryIDs = Left(strCategoryIDs, strCategoryIDs.Length - 1)

        Return strCategoryIDs
    End Function

    Private Sub SetPromotionData(ByRef objPromotion As Promotion, ByVal drwBuy As DataRow)

        With objPromotion
            .ID = drwBuy("PROM_ID")
            .StartDate = drwBuy("PROM_StartDate")
            .EndDate = drwBuy("PROM_EndDate")
            .Live = IIf(drwBuy("PROM_Live") & "" = "", 0, drwBuy("PROM_Live") & "")
            .OrderByValue = IIf(drwBuy("PROM_OrderByValue") & "" = "", 0, drwBuy("PROM_OrderByValue"))
            .MaxQuantity = IIf(drwBuy("PROM_MaxQuantity") & "" = "", 0, drwBuy("PROM_MaxQuantity"))
            .PartNo = drwBuy("PP_PartNo") & ""
            .Type = drwBuy("PP_Type") & ""
            .Value = drwBuy("PP_Value")
            .ItemType = drwBuy("PP_ItemType") & ""
            .ItemID = drwBuy("PP_ItemID")
            .ItemName = drwBuy("PP_ItemName") & ""
        End With

    End Sub

    Private Sub SetPromotionValue(ByVal numMaxPromoQty As Integer, ByVal Item As BasketItem, ByVal strType As String, ByVal numBuyQty As Double, ByVal numBuyValue As Double, ByVal numGetQty As Double, ByVal numGetValue As Double, _
      ByRef numIncTax As Double, ByRef numExTax As Double, ByRef numQty As Double, ByRef numTaxRate As Double, Optional ByRef intExcessGetQty As Integer = 0)

        If strType.ToLower = "q" Then   ''  for free
            numIncTax = -(Item.IncTax * numGetValue)
            numExTax = -(Item.ExTax * numGetValue)
            numQty = Math.Floor(Math.Min((numBuyQty / numBuyValue), (numGetQty / numGetValue)))
            numQty = Math.Min(numMaxPromoQty, numQty)
            numTaxRate = Item.ComputedTaxRate
        ElseIf strType.ToLower = "p" Then '' percentage off
            numIncTax = -(Item.IncTax * numGetValue) / 100
            numExTax = -(Item.ExTax * numGetValue) / 100
            numQty = Math.Floor(Math.Min((numBuyQty / numBuyValue), numGetQty))
            'If (numBuyQty / numBuyValue) > numGetQty Then
            '    If (Math.Floor(numBuyQty / numBuyValue) - numGetQty) >= 1 Then
            '        blnMinItemUsedUp = True
            '    Else
            '        blnMinItemUsedUp = False
            '    End If
            'End If
            numQty = Math.Min(numMaxPromoQty, numQty)
        ElseIf strType.ToLower = "v" Then '' price off
            numIncTax = -(Item.IncTax - numGetValue)
            numExTax = -(Item.IncTax - numGetValue)
            numQty = Math.Floor(Math.Min((numBuyQty / numBuyValue), numGetQty))
            numQty = Math.Min(numMaxPromoQty, numQty)
        End If
        intExcessGetQty = Math.Floor(numBuyQty - (numBuyValue * numQty))
        If Item.PromoQty <= 0 Then numQty = 0

    End Sub

    Private Function GetPromotionText(ByVal intPromotionID As Integer, Optional ByVal blnTextOnly As Boolean = False) As String
        Dim tblPromotionParts As New DataTable    ''==== language_ID =====
        tblPromotionParts = PromotionsBLL._GetPartsByPromotion(intPromotionID, Current.Session("LANG"))

        Dim strPromotionText As String = ""
        Dim intTextCounter As Integer = 0

        numLanguageID = Current.Session("LANG")

        For Each drwPromotionParts As DataRow In tblPromotionParts.Rows

            Dim strText As String = drwPromotionParts("PS_Text")
            Dim strStringID As String = drwPromotionParts("PS_ID")
            Dim strValue As String = FixNullFromDB(drwPromotionParts("PP_Value"))
            Dim strItemID As String = FixNullFromDB(drwPromotionParts("PP_ItemID"))
            Dim intProductID As Integer = VersionsBLL.GetProductID_s(CLng(strItemID))
            Dim strItemName As String = ""
            Dim strItemLink As String = ""

            If strText.Contains("[X]") Then
                If strText.Contains("[£]") Then
                    strText = strText.Replace("[X]", CurrenciesBLL.FormatCurrencyPrice(Current.Session("CUR_ID"), CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), drwPromotionParts("PP_Value"))))
                Else
                    strText = strText.Replace("[X]", drwPromotionParts("PP_Value"))
                End If
            End If

            If strText.Contains("[C]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = CategoriesBLL.GetNameByCategoryID(CInt(strItemID), numLanguageID)
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalCategory, strItemID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[C]", strItemLink)
            End If

            If strText.Contains("[P]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = ProductsBLL.GetNameByProductID(CInt(strItemID), numLanguageID)
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalProduct, strItemID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[P]", strItemLink)
            End If

            If strText.Contains("[V]") AndAlso strItemID <> "" Then ''==== language_ID =====
                strItemName = ProductsBLL.GetNameByProductID(intProductID, numLanguageID) & " (" & VersionsBLL._GetNameByVersionID(CInt(strItemID), numLanguageID) & ")"
                strItemLink = " <b><a href='" & CreateURL(Page.CanonicalProduct, intProductID) & "'>" & strItemName & "</a></b>"
                strItemLink = IIf(blnTextOnly, strItemName, strItemLink)
                strText = strText.Replace("[V]", strItemLink)
            End If

            If strText.Contains("[£]") Then
                strText = strText.Replace("[£]", "")
            End If

            intTextCounter += 1
            If intTextCounter > 1 Then
                strPromotionText += ", "
            End If
            strPromotionText += strText
        Next

        Return strPromotionText

    End Function

    Private Function GetPromotionText_DEPRECATED(ByVal pPROM_ID As Integer, ByVal pPromTable As DataTable, Optional ByVal blnText As Boolean = False) As String

        '' This one .. should be modified .. but right now it read nothing from DB.
        Dim strPromotionPart1_BuyCategory As String = GetGlobalResourceObject("Promotions", "ContentText_PromotionTextCatBuyPart")
        Dim strPromotionPart1_Buy As String = GetGlobalResourceObject("Promotions", "ContentText_PromotionTextBuyPart1")
        Dim strPromotionPart1_Spend As String = GetGlobalResourceObject("Promotions", "ContentText_PromotionTextSpendPart1")
        Dim strPromotionPart2_GetItemFree As String = GetGlobalResourceObject("Promotions", "ContentText_PromotionTextGetItemFreePart2")
        Dim strPromotionPart2_GetPriceOff As String = GetGlobalResourceObject("Promotions", "ContentText_PromotionTextGetPriceOffPart2")
        Dim strPromotionPart2_GetPercentOff As String = GetGlobalResourceObject("Promotions", "ContentText_PromotionTextGetPercentOffPart2")

        Dim strPromotionText As String = ""
        Dim strPartA As String = ""
        Dim strPartB As String = ""

        Dim drPartA As DataRow(), drPartB As DataRow()
        drPartA = pPromTable.Select("PROM_ID=" & pPROM_ID & " AND PP_PartNo='a'")
        drPartB = pPromTable.Select("PROM_ID=" & pPROM_ID & " AND PP_PartNo='b'")

        For i As Integer = 0 To drPartA.Length - 1
            If i > 0 Then
                strPartA += ", "
            End If
            Dim strItemLink As String = ""
            Select Case CChar(drPartA(i)("PP_ItemType"))
                Case "c"
                    If CChar(drPartA(i)("PP_Type")) = "q" Then ' BUY Part1
                        strPartA += Replace(strPromotionPart1_BuyCategory, "[quantity1]", CStr(drPartA(i)("PP_Value"))) ' NEW
                    End If
                    strItemLink = " <b><a href='Category.aspx?CategoryID=" & _
                      CStr(drPartA(i)("PP_ItemID")) & "'>" & CStr(drPartA(i)("PP_ItemName")) & "</a></b>"
                    strItemLink = IIf(blnText, CStr(drPartA(i)("PP_ItemName")), strItemLink)
                    strPartA = Replace(strPartA, "[item1]", strItemLink) ' NEW

                Case "p"
                    If CChar(drPartA(i)("PP_Type")) = "q" Then
                        strPartA += Replace(strPromotionPart1_Buy, "[quantity1]", CStr(drPartA(i)("PP_Value"))) ' NEW
                    End If
                    If CChar(drPartA(i)("PP_Type")) = "v" Then
                        Dim snglPrice As Single = 0.0F
                        snglPrice = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), CDbl(drPartA(i)("PP_Value")))
                        Dim strPrice As String = ""
                        strPrice = CurrenciesBLL.FormatCurrencyPrice(Current.Session("CUR_ID"), snglPrice)
                        strPartA += Replace(strPromotionPart1_Spend, "[currencysymbol][value1]", strPrice) ' NEW
                    End If
                    strItemLink = " <b><a href='Product.aspx?ProductID=" & _
                      CStr(drPartA(i)("PP_ItemID")) & "'>" & CStr(drPartA(i)("PP_ItemName")) & "</a></b>"
                    strItemLink = IIf(blnText, CStr(drPartA(i)("PP_ItemName")), strItemLink)
                    strPartA = Replace(strPartA, "[item1]", strItemLink) ' NEW

                Case "v"
                    If CChar(drPartA(i)("PP_Type")) = "q" Then
                        strPartA += Replace(strPromotionPart1_Buy, "[quantity1]", CStr(drPartA(i)("PP_Value"))) ' NEW
                    End If
                    If CChar(drPartA(i)("PP_Type")) = "v" Then
                        Dim snglPrice As Single = 0.0F
                        snglPrice = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), CDbl(drPartA(i)("PP_Value")))
                        Dim strPrice As String = ""
                        strPrice = CurrenciesBLL.FormatCurrencyPrice(Current.Session("CUR_ID"), snglPrice)
                        strPartA += Replace(strPromotionPart1_Spend, "[currencysymbol][value1]", strPrice) ' NEW
                    End If
                    strItemLink = " <b><a href='Product.aspx?ProductID=" & _
                      VersionsBLL.GetProductID_s(CInt(drPartA(i)("PP_ItemID"))) & "'>" & CStr(drPartA(i)("PP_ItemName")) & "</a></b>"
                    strItemLink = IIf(blnText, CStr(drPartA(i)("PP_ItemName")), strItemLink)
                    strPartA = Replace(strPartA, "[item1]", strItemLink) ' NEW

            End Select
        Next

        For i As Integer = 0 To drPartB.Length - 1
            If i > 0 Then
                strPartB += ", "
            End If
            Dim strItemLink As String = ""
            Select Case CChar(drPartB(i)("PP_ItemType"))
                Case "c"                             ' Categories will not be used in part2 in this version .. 
                    If CChar(drPartB(i)("PP_Type")) = "q" Then
                        strPartB += " Get " & CStr(drPartB(i)("PP_Value")) & " Items From "
                    Else
                        strPartB += " Get " & CStr(drPartB(i)("PP_Value")) & "% Off on item From "
                    End If
                    strItemLink = " Category <b><a href='Category.aspx?CategoryID=" & _
                      CStr(drPartB(i)("PP_ItemID")) & "'>" & CStr(drPartB(i)("PP_ItemName")) & "</a></b>"
                    strItemLink = IIf(blnText, CStr(drPartB(i)("PP_ItemName")), strItemLink)
                    strPartB += strItemLink

                Case "p"
                    If CChar(drPartB(i)("PP_Type")) = "q" Then
                        strPartB += Replace(strPromotionPart2_GetItemFree, "[quantity2]", CStr(drPartB(i)("PP_Value"))) ' NEW
                    End If
                    If CChar(drPartB(i)("PP_Type")) = "p" Then
                        strPartB += Replace(strPromotionPart2_GetPercentOff, "[value2]", CStr(drPartB(i)("PP_Value"))) ' NEW
                    End If
                    If CChar(drPartB(i)("PP_Type")) = "v" Then
                        Dim snglPrice As Single = 0.0F
                        snglPrice = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), CDbl(drPartB(i)("PP_Value")))
                        Dim strPrice As String = ""
                        strPrice = CurrenciesBLL.FormatCurrencyPrice(Current.Session("CUR_ID"), snglPrice)

                        strPartB += Replace(strPromotionPart2_GetPriceOff, "[currencysymbol][value2]", strPrice) ' NEW
                    End If
                    strItemLink = " <b><a href='Product.aspx?ProductID=" & _
                      CStr(drPartB(i)("PP_ItemID")) & "'>" & CStr(drPartB(i)("PP_ItemName")) & "</a></b>"
                    strItemLink = IIf(blnText, CStr(drPartB(i)("PP_ItemName")), strItemLink)
                    strPartB = Replace(strPartB, "[item2]", strItemLink) ' NEW

                Case "v"
                    If CChar(drPartB(i)("PP_Type")) = "q" Then
                        strPartB += Replace(strPromotionPart2_GetItemFree, "[quantity2]", CStr(drPartB(i)("PP_Value"))) ' NEW
                    End If
                    If CChar(drPartB(i)("PP_Type")) = "p" Then
                        strPartB += Replace(strPromotionPart2_GetPercentOff, "[value2]", CStr(drPartB(i)("PP_Value"))) ' NEW
                    End If
                    If CChar(drPartB(i)("PP_Type")) = "v" Then
                        Dim snglPrice As Single = 0.0F
                        snglPrice = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), CDbl(drPartB(i)("PP_Value")))
                        Dim strPrice As String = ""
                        strPrice = CurrenciesBLL.FormatCurrencyPrice(Current.Session("CUR_ID"), snglPrice)

                        strPartB += Replace(strPromotionPart2_GetPriceOff, "[currencysymbol][value2]", strPrice) ' NEW
                    End If
                    strItemLink = " <b><a href='Product.aspx?ProductID=" & _
                      VersionsBLL.GetProductID_s(CInt(drPartB(i)("PP_ItemID"))) & "'>" & CStr(drPartB(i)("PP_ItemName")) & "</a></b>"
                    strItemLink = IIf(blnText, CStr(drPartB(i)("PP_ItemName")), strItemLink)
                    strPartB = Replace(strPartB, "[item2]", strItemLink) ' NEW


            End Select
        Next

        Return strPartA & ", " & strPartB

    End Function

    Private Sub AddPromotion(ByVal blnBasketPromo As Boolean, ByRef strPromoDiscountIDs As String, ByRef objPromotion As Promotion, ByVal numPromoID As Integer, ByVal numIncTax As Double, ByVal numExTax As Double,
                             ByVal numQty As Double, ByVal numTaxRate As Double, Optional ByVal blnIsFixedValuePromo As Boolean = False, Optional ByVal blnForceAdd As Boolean = False)
        Dim intMaxPromoOrder As Integer = 0

        intMaxPromoOrder = Val(GetKartConfig("frontend.promotions.maximum"))

        If (blnBasketPromo And (objPromotionsDiscount.Count < intMaxPromoOrder Or intMaxPromoOrder = 0)) OrElse blnForceAdd Then
            strPromoDiscountIDs = strPromoDiscountIDs & numPromoID & ";"
            Dim objPromotionDiscount As New PromotionBasketModifier
            With objPromotionDiscount
                .PromotionID = numPromoID
                .Name = GetPromotionText(objPromotion.ID, True)
                .ApplyTax = ApplyTax
                .ComputedTaxRate = numTaxRate
                .ExTax = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), numExTax)
                .IncTax = CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), numIncTax)
                .Quantity = numQty
                .TotalIncTax = .TotalIncTax + (.IncTax * .Quantity)
                .TotalExTax = .TotalExTax + (.ExTax * .Quantity)
                .isFixedValuePromo = blnIsFixedValuePromo
            End With
            objPromotionsDiscount.Add(objPromotionDiscount)
        Else
            '' add only to promotion if not in promotion discount yet
            Dim blnFound As Boolean = False
            For Each objPromo As PromotionBasketModifier In objPromotionsDiscount
                If objPromo.PromotionID = objPromotion.ID Then
                    blnFound = True : Exit For
                End If
            Next

            If blnFound = False Then
                objPromotion.PromoText = GetPromotionText(objPromotion.ID)
                objPromotions.Add(objPromotion)
            End If

        End If

    End Sub

    Public Sub CalculatePromotions(ByRef aryPromotions As ArrayList, ByRef aryPromotionsDiscount As ArrayList, ByVal blnZeroTotalTaxRate As Boolean)
        Dim tblPromotions As Data.DataTable
        Dim drwBuys() As Data.DataRow
        Dim drwGets() As Data.DataRow
        Dim drwSpends() As Data.DataRow
        Dim strPromoIDs, strPromoDiscountIDs, strList As String
        Dim vPromoID, vMaxPromoQty, vItemID As Integer
        Dim strItemType, strType As String
        Dim strItemVersionIDs, strItemProductIDs, strItemCategoryIDs As String
        Dim vIncTax, vExTax, vQuantity, vBuyQty, vValue, vTaxRate As Double

        If BasketItems.Count = 0 Then Exit Sub

        'Clear AppliedPromotion to all Basket Items
        For Each objBasketItem As BasketItem In BasketItems
            objBasketItem.AppliedPromo = 0
        Next

        Dim numLanguageID As Integer
        Dim objItem As New BasketItem

        numLanguageID = 1
        strPromoIDs = ";" : strPromoDiscountIDs = ";"
        strItemVersionIDs = GetBasketItemVersionIDs()
        strItemProductIDs = GetBasketItemProductIDs()
        strItemCategoryIDs = GetBasketItemCategoryIDs()
        PromotionDiscount.IncTax = 0 : PromotionDiscount.ExTax = 0

        aryPromotions.Clear() : aryPromotionsDiscount.Clear()
        objPromotions.Clear() : objPromotionsDiscount.Clear()

        Dim intCouponPromotionID As Integer = 0
        If Not String.IsNullOrEmpty(CouponCode) Then
            Dim strCouponType As String = ""
            Dim strCouponError As String = ""
            Dim numCouponValue As Double

            Call GetCouponDiscount(CouponCode, strCouponError, strCouponType, numCouponValue)
            If strCouponType = "t" Then
                intCouponPromotionID = CInt(numCouponValue)
            End If
        End If
        tblPromotions = PromotionsBLL.GetAllPromotions(numLanguageID, intCouponPromotionID)

        '' get promotions from Basket version IDs (buy promotion parts)
        strList = "PP_PartNo='a' and PP_ItemType='v' and PP_Type='q' and PP_ItemID in (" & strItemVersionIDs & ")"
        drwBuys = tblPromotions.Select(strList)

        For Each drwBuy As DataRow In drwBuys
            vPromoID = drwBuy("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drwBuy)

                objItem = GetBasketItemByVersionID(objPromotion.ItemID)

                If objItem.Quantity >= objPromotion.Value And objItem.AppliedPromo = 0 Then
                    vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0
                    vBuyQty = objItem.Quantity

                    Dim blnGetFound As Boolean = False

                    strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                    drwGets = tblPromotions.Select(strList)
                    For Each drGet As DataRow In drwGets '' loop the get items
                        strItemType = drGet("PP_ItemType") & ""
                        strType = drGet("PP_Type") & ""
                        vItemID = drGet("PP_ItemID")
                        vValue = drGet("PP_Value")
                        vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                        Select Case strItemType.ToLower
                            Case "v"                             '' buy version and get item from version
                                If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                    '' vBuyQty (qty in basket), objPromo.value (buy qty in db), objItem.Quantity(qty in basket get promo), vValue (get qty in db) 
                                    objItem = GetBasketItemByVersionID(vItemID)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    If objPromotion.ItemID = vItemID Then '' buy item is equal to get item
                                        If vBuyQty > vValue Then
                                            blnGetFound = True
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, vValue, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                        End If
                                    Else
                                        blnGetFound = True
                                        Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                    End If
                                End If

                                If vQuantity <= 0 Then blnGetFound = False
                                Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                If blnGetFound Then objItem.AppliedPromo = 1
                            Case "p"                             '' buy version and get item from product
                                If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim vTotalQtyGot, vQtyBalance As Double
                                    Dim index As Integer

                                    vTotalQtyGot = 0
                                    blnGetFound = True
                                    vTotalQtyGot = vTotalQtyGot + vQuantity
                                    vQtyBalance = (vBuyQty / objPromotion.Value) - vTotalQtyGot

                                    Do While vQtyBalance > 0
                                        index = GetItemMinProductValue(vItemID)
                                        If index < 0 Then Exit Do
                                        objItem = BasketItems(index)
                                        If objItem.AppliedPromo = 0 Then
                                            vQtyBalance = Min(vQtyBalance, objItem.Quantity)
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, vQtyBalance, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                            BasketItems(index).PromoQty = BasketItems(index).quantity - vQuantity

                                            If vQuantity <= 0 Then blnGetFound = False
                                            Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                            If blnGetFound Then objItem.AppliedPromo = 1
                                            vTotalQtyGot = vTotalQtyGot + vQuantity
                                            vQtyBalance = (vBuyQty / objPromotion.Value) - vTotalQtyGot

                                            If blnGetFound = False Then Exit Do
                                        End If
                                    Loop

                                End If

                                blnGetFound = False
                                Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                If blnGetFound Then objItem.AppliedPromo = 1
                            Case "c"                             '' buy version and get item from category
                                If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinCategoryValue(vItemID)
                                    objItem = BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                End If

                                If vQuantity <= 0 Then blnGetFound = False
                                Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                                If blnGetFound Then objItem.AppliedPromo = 1
                            Case "a"
                                vQuantity = Math.Floor(Math.Min((vBuyQty / objPromotion.Value), (objItem.Quantity / objPromotion.Value)))
                                vQuantity = Math.Min(vQuantity, vMaxPromoQty) '' Make sure it didn't exceed the MaxQty / promotion
                                If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                                vTaxRate = TotalDiscountPriceTaxRate

                                If vValue > TotalDiscountPriceExTax Then
                                    vExTax = -TotalDiscountPriceExTax
                                    vIncTax = -TotalDiscountPriceIncTax
                                Else
                                    Dim blnPricesExtax As Boolean = False

                                    If Not blnZeroTotalTaxRate Then
                                        If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                            vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                            If D_Tax = 1 Then
                                                vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                            Else
                                                vIncTax = vExTax
                                            End If
                                        Else
                                            blnPricesExtax = True
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If

                                    If blnPricesExtax Then
                                        vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                        vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                    End If
                                End If

                                Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, True)
                                objItem.AppliedPromo = 1
                        End Select
                    Next
                Else
                    Call AddPromotion(False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                End If

            End If
        Next

        '' products
        '' get promotions from basket product IDs
        strList = "PP_PartNo='a' and PP_ItemType='p' and PP_Type='q' and PP_ItemID in (" & strItemProductIDs & ")"
        drwBuys = tblPromotions.Select(strList)
        For Each drwBuy As DataRow In drwBuys
            vPromoID = drwBuy("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drwBuy)

                Dim cnt As Integer = 0
                For i As Integer = 0 To BasketItems.Count - 1
                    objItem = BasketItems(i)
                    If objItem.ProductID = objPromotion.ItemID And objItem.AppliedPromo = 0 Then cnt = cnt + objItem.Quantity
                Next

                If cnt >= objPromotion.Value Then
                    vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0
                    vBuyQty = cnt

                    Dim blnGetFound As Boolean = False

                    strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                    drwGets = tblPromotions.Select(strList)
                    Dim blnIsFixedValuePromo As Boolean = False
                    Dim blnForceAdd As Boolean = False
                    For Each drGet As DataRow In drwGets '' loop the get items
                        strItemType = drGet("PP_ItemType")
                        strType = drGet("PP_Type") & ""
                        vItemID = drGet("PP_ItemID")
                        vValue = drGet("PP_Value")
                        vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                        blnIsFixedValuePromo = False

                        Select Case strItemType.ToLower
                            Case "v"                    '' buy product and get item from version
                                If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                    objItem = GetBasketItemByVersionID(vItemID)
                                    If objItem.AppliedPromo = 1 Then Continue For
                                    blnGetFound = True
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                End If

                            Case "p"                    '' buy product and get item from product
                                If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinProductValue(vItemID)
                                    objItem = BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Continue For
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinProductValue(vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = BasketItems(index)
                                            If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If

                            Case "c"                    '' buy product and get item from category
                                If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinCategoryValue(vItemID)
                                    objItem = BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Continue For
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer = 0
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinCategoryValue(vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = BasketItems(index)
                                            If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If
                            Case "a"
                                vQuantity = Math.Floor(Math.Min((vBuyQty / objPromotion.Value), (cnt / objPromotion.Value)))
                                vQuantity = Math.Min(vQuantity, vMaxPromoQty) '' Make sure it didn't exceed the MaxQty / promotion
                                If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                                vTaxRate = TotalDiscountPriceTaxRate

                                If vValue > TotalDiscountPriceExTax Then
                                    vExTax = -TotalDiscountPriceExTax
                                    vIncTax = -TotalDiscountPriceIncTax
                                Else
                                    Dim blnPricesExtax As Boolean = False

                                    If Not blnZeroTotalTaxRate Then
                                        If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                            vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                            If D_Tax = 1 Then
                                                vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                            Else
                                                vIncTax = vExTax
                                            End If
                                        Else
                                            blnPricesExtax = True
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If

                                    If blnPricesExtax Then
                                        vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                        vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                    End If
                                End If

                                blnIsFixedValuePromo = True
                                objItem.AppliedPromo = 1
                        End Select
                    Next
                    Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                    If blnGetFound Then objItem.AppliedPromo = 1
                Else
                    Call AddPromotion(False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                End If

            End If
        Next

        '' get promotions from basket category IDs
        strList = "PP_PartNo='a' and PP_ItemType='c' and PP_Type='q' and PP_ItemID in (" & strItemCategoryIDs & ")"
        drwBuys = tblPromotions.Select(strList)
        For Each drwBuy As DataRow In drwBuys
            vPromoID = drwBuy("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drwBuy)

                Dim cnt As Integer = 0
                For i As Integer = 0 To BasketItems.Count - 1
                    objItem = BasketItems(i)
                    If InStr("," & objItem.CategoryIDs & ",", "," & objPromotion.ItemID & ",") > 0 Then
                        cnt = cnt + objItem.Quantity
                    End If
                Next

                If cnt >= objPromotion.Value Then
                    vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0
                    vBuyQty = cnt

                    Dim blnGetFound As Boolean = False

                    strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                    drwGets = tblPromotions.Select(strList)
                    Dim blnIsFixedValuePromo As Boolean = False
                    Dim blnForceAdd As Boolean = False

                    For Each drGet As DataRow In drwGets '' loop the get items
                        strItemType = drGet("PP_ItemType") & ""
                        strType = drGet("PP_Type") & ""
                        vItemID = drGet("PP_ItemID")
                        vValue = drGet("PP_Value")
                        vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                        blnIsFixedValuePromo = False
                        Select Case strItemType.ToLower
                            Case "v"                    '' buy category and get item from version
                                If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                    objItem = GetBasketItemByVersionID(vItemID)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                                End If

                            Case "p"                    '' buy category and get item from product
                                If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinProductValue(vItemID)
                                    objItem = BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer = 0
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinProductValue(vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = BasketItems(index)
                                            If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If

                            Case "c"                    '' buy category and get item from category
                                If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                    Dim index As Integer
                                    index = GetItemMinCategoryValue(vItemID)
                                    objItem = BasketItems(index)
                                    If objItem.AppliedPromo = 1 Then Exit Select
                                    blnGetFound = True
                                    Dim intExcessGetQty As Integer = 0
                                    Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                    Dim strVersionIDArray As String = ""
                                    Do While intExcessGetQty > 0
                                        If strVersionIDArray <> "" Then strVersionIDArray += ","
                                        blnIsFixedValuePromo = True
                                        objItem.AppliedPromo = 1
                                        vMaxPromoQty = vMaxPromoQty - vQuantity
                                        If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                            intExcessGetQty = 0
                                            Exit Do
                                        End If
                                        Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                        If blnGetFound Then objItem.AppliedPromo = 1
                                        strVersionIDArray = strVersionIDArray & objItem.VersionID
                                        'Dim numExcessItemsInPromo As Double = vBuyQty - (objPromotion.Value * objItem.Quantity)
                                        index = GetItemMinCategoryValue(vItemID, strVersionIDArray)
                                        If index <> -1 Then
                                            objItem = BasketItems(index)
                                            If objItem.AppliedPromo = 1 Then Continue For
                                            Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                            blnForceAdd = True
                                        Else
                                            intExcessGetQty = 0
                                        End If
                                    Loop
                                End If
                            Case "a"
                                vQuantity = Math.Floor(Math.Min((vBuyQty / objPromotion.Value), (cnt / objPromotion.Value)))
                                vQuantity = Math.Min(vQuantity, vMaxPromoQty) '' Make sure it didn't exceed the MaxQty / promotion
                                If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                                vTaxRate = TotalDiscountPriceTaxRate

                                If vValue > TotalDiscountPriceExTax Then
                                    vExTax = -TotalDiscountPriceExTax
                                    vIncTax = -TotalDiscountPriceIncTax
                                Else
                                    Dim blnPricesExtax As Boolean = False

                                    If Not blnZeroTotalTaxRate Then
                                        If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                            vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                            If D_Tax = 1 Then
                                                vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                            Else
                                                vIncTax = vExTax
                                            End If
                                        Else
                                            blnPricesExtax = True
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If

                                    If blnPricesExtax Then
                                        vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                        vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                    End If
                                End If

                                blnIsFixedValuePromo = True
                                objItem.AppliedPromo = 1
                        End Select
                    Next
                    Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                    If blnGetFound Then objItem.AppliedPromo = 1
                Else
                    Call AddPromotion(False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                End If

            End If
        Next

        '' get spend value from basket
        Dim vSpend As Double
        strList = "PP_PartNo='a' and PP_ItemType='a'"
        drwSpends = tblPromotions.Select(strList)
        For Each drSpend As DataRow In drwSpends
            vPromoID = drSpend("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"

                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drSpend)

                vSpend = drSpend("PP_Value")

                vSpend = Math.Round(CDbl(CurrenciesBLL.ConvertCurrency(Current.Session("CUR_ID"), drSpend("PP_Value"))), 2)

                vIncTax = 0 : vExTax = 0 : vQuantity = 0 : vTaxRate = 0

                Dim blnGetFound As Boolean = False

                strList = "PP_PartNo='b' and PROM_ID=" & objPromotion.ID
                drwGets = tblPromotions.Select(strList)
                Dim blnIsFixedValuePromo As Boolean = False
                Dim blnForceAdd As Boolean = False

                For Each drGet As DataRow In drwGets     '' loop the get items
                    strItemType = drGet("PP_ItemType") & ""
                    strType = drGet("PP_Type") & ""
                    vItemID = drGet("PP_ItemID")
                    vValue = drGet("PP_Value")
                    vMaxPromoQty = IIf(drGet("PROM_MaxQuantity") = 0, 1000000, drGet("PROM_MaxQuantity"))
                    blnIsFixedValuePromo = False
                    Select Case strItemType.ToLower
                        Case "v"                    '' spend a certain amount and get item from version
                            If InStr("," & strItemVersionIDs & ",", "," & vItemID & ",") > 0 Then
                                objItem = GetBasketItemByVersionID(vItemID)
                                If objItem.AppliedPromo = 1 Then Exit Select
                                blnGetFound = True
                                vBuyQty = vValue * (CInt(TotalExTax / vSpend))
                                objPromotion.Value = vValue
                                Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate)
                            End If

                        Case "p"                    '' spend a certain amount and get item from product
                            If InStr("," & strItemProductIDs & ",", "," & vItemID & ",") > 0 Then
                                Dim index As Integer
                                index = GetItemMinProductValue(vItemID)
                                objItem = BasketItems(index)
                                If objItem.AppliedPromo = 1 Then Exit Select
                                blnGetFound = True
                                vBuyQty = vValue * (CInt(TotalExTax / vSpend))
                                objPromotion.Value = vValue
                                Dim intExcessGetQty As Integer = 0
                                Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                Dim strVersionIDArray As String = ""
                                Do While intExcessGetQty > 0
                                    If strVersionIDArray <> "" Then strVersionIDArray += ","
                                    blnIsFixedValuePromo = True

                                    vMaxPromoQty = vMaxPromoQty - vQuantity
                                    If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                        intExcessGetQty = 0
                                        Exit Do
                                    End If

                                    strVersionIDArray = strVersionIDArray & objItem.VersionID
                                    index = GetItemMinProductValue(vItemID, strVersionIDArray)
                                    If index <> -1 Then
                                        If objItem.AppliedPromo = 0 Then
                                            Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                            objItem.AppliedPromo = 1
                                        End If
                                        objItem = BasketItems(index)
                                        If objItem.AppliedPromo = 1 Then Continue For
                                        Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                        blnForceAdd = True
                                    Else
                                        intExcessGetQty = 0
                                    End If
                                Loop

                            End If

                        Case "c"                    '' spend a certain amount and get item from category
                            If InStr("," & strItemCategoryIDs & ",", "," & vItemID & ",") > 0 Then
                                Dim index As Integer
                                index = GetItemMinCategoryValue(vItemID)
                                objItem = BasketItems(index)
                                If objItem.AppliedPromo = 1 Then Exit Select
                                blnGetFound = True
                                vBuyQty = vValue * (CInt(TotalExTax / vSpend))
                                objPromotion.Value = vValue

                                Dim intExcessGetQty As Integer = 0
                                Call SetPromotionValue(vMaxPromoQty, objItem, strType, vBuyQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                Dim strVersionIDArray As String = ""
                                Do While intExcessGetQty > 0
                                    If strVersionIDArray <> "" Then strVersionIDArray += ","
                                    blnIsFixedValuePromo = True
                                    vMaxPromoQty = vMaxPromoQty - vQuantity
                                    If intExcessGetQty < objPromotion.Value Or vMaxPromoQty < 1 Then
                                        intExcessGetQty = 0
                                        Exit Do
                                    End If

                                    strVersionIDArray = strVersionIDArray & objItem.VersionID
                                    index = GetItemMinCategoryValue(vItemID, strVersionIDArray)
                                    If index <> -1 Then

                                        If objItem.AppliedPromo = 0 Then
                                            Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                                            objItem.AppliedPromo = 1
                                        End If

                                        objItem = BasketItems(index)
                                        If objItem.AppliedPromo = 1 Then Continue For
                                        Call SetPromotionValue(vMaxPromoQty, objItem, strType, intExcessGetQty, objPromotion.Value, objItem.Quantity, vValue, vIncTax, vExTax, vQuantity, vTaxRate, intExcessGetQty)
                                        blnForceAdd = True
                                    Else
                                        intExcessGetQty = 0
                                    End If
                                Loop

                            End If
                        Case "a"
                            vQuantity = CInt(TotalExTax / vSpend)
                            If vQuantity > 1 Then vQuantity = 1
                            If vQuantity <= 0 Then blnGetFound = False Else blnGetFound = True

                            vTaxRate = TotalDiscountPriceTaxRate

                            If vValue > TotalDiscountPriceExTax Then
                                vExTax = -TotalDiscountPriceExTax
                                vIncTax = -TotalDiscountPriceIncTax
                            Else
                                Dim blnPricesExtax As Boolean = False

                                If Not blnZeroTotalTaxRate Then
                                    If GetKartConfig("general.tax.pricesinctax") = "y" Then
                                        vExTax = -Math.Round(vValue * (1 / (1 + vTaxRate)), CurrencyRoundNumber)
                                        If D_Tax = 1 Then
                                            vIncTax = -Math.Round(vValue, CurrencyRoundNumber)
                                        Else
                                            vIncTax = vExTax
                                        End If
                                    Else
                                        blnPricesExtax = True
                                    End If
                                Else
                                    blnPricesExtax = True
                                End If

                                If blnPricesExtax Then
                                    vIncTax = -Math.Round(vValue * (1 + vTaxRate), CurrencyRoundNumber)
                                    vExTax = -Math.Round(vValue, CurrencyRoundNumber)
                                End If
                            End If

                            blnIsFixedValuePromo = True
                    End Select
                Next

                If blnGetFound Then
                    If TotalExTax >= vSpend Then
                        Call AddPromotion(blnGetFound, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate, blnIsFixedValuePromo, blnForceAdd)
                    Else
                        Call AddPromotion(False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
                    End If
                End If

            End If
        Next


        '' get promotions from Basket version IDs (get parts)
        strList = "PP_PartNo='b' and PP_ItemType='v' and PP_Type='q' and PP_ItemID in (" & strItemVersionIDs & ")"
        drwGets = tblPromotions.Select(strList)

        For Each drGet As DataRow In drwGets
            vPromoID = drGet("PROM_ID")
            If InStr(strPromoIDs, vPromoID) = 0 Then
                strPromoIDs = strPromoIDs & vPromoID & ";"
                Dim objPromotion As New Promotion
                Call SetPromotionData(objPromotion, drGet)
                Call AddPromotion(False, strPromoDiscountIDs, objPromotion, vPromoID, vIncTax, vExTax, vQuantity, vTaxRate)
            End If
        Next

        For i As Integer = 1 To objPromotionsDiscount.Count
            PromotionDiscount.ExTax = PromotionDiscount.ExTax + objPromotionsDiscount.Item(i - 1).TotalexTax
            PromotionDiscount.IncTax = PromotionDiscount.IncTax + objPromotionsDiscount.Item(i - 1).TotalIncTax
        Next

        aryPromotions = objPromotions
        aryPromotionsDiscount = objPromotionsDiscount

    End Sub


#End Region

#Region "Affiliates"

    Public Sub UpdateCustomerAffiliateStatus(ByVal numUserID As Integer)
        _CustomersAdptr.UpdateAffiliate(1, numUserID, 0, 0)
    End Sub

    Public Sub UpdateCustomerAffiliateCommission(ByVal numUserID As Integer, ByVal numCommission As Double)
        _CustomersAdptr.UpdateAffiliate(2, numUserID, numCommission, 0)
    End Sub

    Public Sub UpdateCustomerAffiliateID(ByVal numUserID As Integer, ByVal numAffiliateID As Integer)
        _CustomersAdptr.UpdateAffiliate(3, numUserID, 0, numAffiliateID)
    End Sub

    Public Sub UpdateCustomerAffiliateLog(ByVal numAffiliateId As Integer, ByVal strReferer As String, ByVal strIP As String, ByVal strRequestedItem As String)
        _CustomersAdptr.UpdateAffiliateLog(numAffiliateId, strReferer, strIP, strRequestedItem, CkartrisDisplayFunctions.NowOffset)
    End Sub

    Public Function IsCustomerAffiliate(ByVal numUserID As Long) As Boolean
        Dim tblAffiliate As DataTable
        Dim blnIsAffiliate As Boolean = False

        tblAffiliate = GetCustomerData(numUserID)
        If tblAffiliate.Rows.Count > 0 Then
            blnIsAffiliate = tblAffiliate.Rows(0).Item("U_IsAffiliate")
        End If
        tblAffiliate.Dispose()

        Return blnIsAffiliate
    End Function

    Public Function GetCustomerAffiliateID(ByVal numUserID As Long) As Long
        Dim tblAffiliate As DataTable
        Dim numAffiliateID As Long

        tblAffiliate = GetCustomerData(numUserID)
        If tblAffiliate.Rows.Count > 0 Then
            numAffiliateID = tblAffiliate.Rows(0).Item("U_AffiliateID")
        End If
        tblAffiliate.Dispose()

        Return numAffiliateID
    End Function

    Public Shared Sub CheckAffiliateLink()
        Dim numAffiliateID, sessAffiliateID As Integer
        Dim objBasket As New BasketBLL

        numAffiliateID = Val(Current.Request.QueryString("af"))

        If numAffiliateID > 0 AndAlso objBasket.IsCustomerAffiliate(numAffiliateID) Then

            If Not (Current.Session("C_AffiliateID") Is Nothing) Then
                sessAffiliateID = Val(Current.Session("C_AffiliateID"))
            Else
                sessAffiliateID = 0
            End If

            If numAffiliateID <> sessAffiliateID Then
                Dim strReferer, strIP, strRequestedItem As String
                strReferer = Current.Request.ServerVariables("HTTP_REFERER")
                If strReferer Is Nothing Then strReferer = ""
                strIP = Current.Request.ServerVariables("REMOTE_ADDR")
                strRequestedItem = Left(Current.Request.ServerVariables("PATH_INFO") & "?" & Current.Request.ServerVariables("QUERY_STRING"), 255)

                objBasket.UpdateCustomerAffiliateLog(numAffiliateID, strReferer, strIP, strRequestedItem)
                Current.Session("C_AffiliateID") = numAffiliateID

            End If

        End If

        objBasket = Nothing
    End Sub

    Public Function GetCustomerAffiliateActivitySales(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(1, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    Public Function GetCustomerAffiliateActivityHits(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(2, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    Public Function GetCustomerAffiliateCommission(ByVal numUserID As Integer, ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(3, numUserID, numMonth, numYear)
        Return tblAffiliate
    End Function

    Public Function GetCustomerAffiliateSalesLink(ByVal numUserID As Integer, ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(4, numUserID, numMonth, numYear)
        Return tblAffiliate
    End Function

    Public Function GetCustomerAffiliatePayments(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(5, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    Public Function GetCustomerAffiliateUnpaidSales(ByVal numUserID As Integer) As DataTable
        Dim tblAffiliate As New DataTable
        tblAffiliate = _CustomersAdptr.GetAffiliateData(6, numUserID, 0, 0)
        Return tblAffiliate
    End Function

    Public Function _GetCustomerAffiliateCommissionSummary(ByVal numUserId As Long) As DataTable
        Dim tblAffiliate As New DataTable
        Dim intPaid As Integer = IIf(LCase(KartSettingsManager.GetKartConfig("frontend.users.affiliates.commissiononlyonpaid")) = "y", 1, 0)
        tblAffiliate = _CustomersAdptr._GetAffiliateCommission(0, numUserId, intPaid, 0, 0)
        Return tblAffiliate
    End Function

    Public Function _GetCustomerAffiliateUnpaidCommission(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable
        Dim tblAffiliate As New DataTable
        Dim intPaid As Integer = IIf(LCase(KartSettingsManager.GetKartConfig("frontend.users.affiliates.commissiononlyonpaid")) = "y", 1, 0)
        tblAffiliate = _CustomersAdptr._GetAffiliateCommission(1, numUserId, intPaid, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))
        Return tblAffiliate
    End Function

    Public Function _GetCustomerAffiliatePaidCommission(ByVal numUserId As Long, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable
        Dim tblAffiliate As New DataTable
        Dim intPaid As Integer = IIf(LCase(KartSettingsManager.GetKartConfig("frontend.users.affiliates.commissiononlyonpaid")) = "y", 1, 0)
        tblAffiliate = _CustomersAdptr._GetAffiliateCommission(2, numUserId, intPaid, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))
        Return tblAffiliate
    End Function

    Public Function _AddAffiliatePayments(ByVal intAffiliateID As Integer) As Integer
        Dim tblAffiliate As New DataTable

        tblAffiliate = _CustomersAdptr._AddAffiliatePayments(intAffiliateID, CkartrisDisplayFunctions.NowOffset)
        If tblAffiliate.Rows.Count > 0 Then
            Return tblAffiliate.Rows(0).Item("AFP_ID")
        Else
            Return 0
        End If

    End Function

    Public Sub _UpdateAffiliateCommission(ByVal intAffilliatePaymentID As Integer, ByVal intOrderID As Integer)

        _CustomersAdptr._UpdateAffiliateOrders(1, intAffilliatePaymentID, intOrderID)

    End Sub

    Public Sub _UpdateAffiliatePayment(ByVal intAffilliatePaymentID As Integer)

        _CustomersAdptr._UpdateAffiliateOrders(2, intAffilliatePaymentID, 0)

    End Sub

    Public Function _GetAffiliateMonthlyHitsReport(ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable

        Return _CustomersAdptr._GetAffiliateReport(1, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, 0, 0, 0, 0)

    End Function

    Public Function _GetAffiliateAnnualHitsReport() As DataTable

        Return _CustomersAdptr._GetAffiliateReport(2, 0, 0, Format(DateAdd(DateInterval.Month, -11, CkartrisDisplayFunctions.NowOffset), "yyyy/MM/01 0:00:00"), 0, 0, 0, 0)

    End Function

    Public Function _GetAffiliateMonthlySalesReport(ByVal numMonth As Integer, ByVal numYear As Integer) As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(3, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, numPaid, 0, 0, 0)

    End Function

    Public Function _GetAffiliateAnnualSalesReport() As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(4, 0, 0, Format(DateAdd(DateInterval.Month, -11, CkartrisDisplayFunctions.NowOffset), "yyyy/MM/01 0:00:00"), numPaid, 0, 0, 0)

    End Function

    Public Function _GetAffiliateSummaryReport(ByVal numMonth As Integer, ByVal numYear As Integer, ByVal numAffiliateID As Integer) As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(5, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, numPaid, numAffiliateID, 0, 0)

    End Function

    Public Function _GetAffiliateRawDataHitsReport(ByVal numMonth As Integer, ByVal numYear As Integer, ByVal numAffiliateID As Integer, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable

        Return _CustomersAdptr._GetAffiliateReport(6, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, 0, numAffiliateID, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))

    End Function

    Public Function _GetAffiliateRawDataSalesReport(ByVal numMonth As Integer, ByVal numYear As Integer, ByVal numAffiliateID As Integer, Optional ByVal PageIndex As Integer = 0, Optional ByVal PageSize As Integer = 10) As DataTable

        Dim numPaid As Short = IIf(Trim(LCase(GetKartConfig("frontend.users.affiliates.commissiononlyonpaid"))) = "y", 1, 0)
        Return _CustomersAdptr._GetAffiliateReport(7, numMonth, numYear, CkartrisDisplayFunctions.NowOffset, numPaid, numAffiliateID, ((PageIndex - 1) * PageSize) + 1, (PageIndex * PageSize))

    End Function


#End Region

#Region "MailingList"

    Public Sub UpdateCustomerMailFormat(ByVal numUserID As Integer, ByVal strMailFormat As String)
        _CustomersAdptr.UpdateMailFormat(numLanguageID, numUserID, strMailFormat)
    End Sub

    Public Sub UpdateCustomerMailingList(ByVal strEmail As String, ByRef strPassword As String, Optional ByVal strMailFormat As String = "t", Optional ByVal strSignupIP As String = "")
        Dim datSignup As DateTime
        Dim numPasswordLength As Integer

        numPasswordLength = Val(KartSettingsManager.GetKartConfig("minimumcustomercodesize"))
        If numPasswordLength = 0 Then numPasswordLength = 8
        strPassword = GetRandomString(numPasswordLength)

        datSignup = CkartrisDisplayFunctions.NowOffset

        _CustomersAdptr.UpdateMailingList(strEmail, datSignup, strSignupIP, strPassword, strMailFormat, numLanguageID)

    End Sub

    Public Function ConfirmMail(ByVal numUserID As Integer, ByVal strPassword As String, Optional ByVal strIP As String = "") As Integer
        Dim tblConfirmMail As New DataTable
        Dim UserID As Integer = 0

        tblConfirmMail = _CustomersAdptr.ConfirmMail(numUserID, strPassword, CkartrisDisplayFunctions.NowOffset, strIP)

        If tblConfirmMail.Rows.Count > 0 Then
            UserID = Val(tblConfirmMail.Rows(0).Item("UserID") & "")
        End If

        Return UserID
    End Function

#End Region

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub


End Class

<Serializable()> _
Public Class PromotionBasketModifier
    Private _ExTax As Double
    Private _IncTax As Double
    Private _TaxRate As Double
    Private _TaxAmount As Double
    Private _Quantity As Double
    Private _TotalExTax As Double
    Private _TotalIncTax As Double
    Private _PromotionID As Integer
    Private _Name As String
    Private _ApplyTax As Boolean
    Private _isFixedValuePromo As Boolean


    Public Property PromotionID() As Integer
        Get
            Return _PromotionID
        End Get
        Set(ByVal value As Integer)
            _PromotionID = value
        End Set
    End Property

    Public Property Name() As String
        Get
            Return _Name
        End Get
        Set(ByVal value As String)
            _Name = value
        End Set
    End Property

    Public Property ExTax() As Double
        Get
            Return (_ExTax)
        End Get
        Set(ByVal value As Double)
            _ExTax = (value)
        End Set
    End Property

    Public Property IncTax() As Double
        Get
            Return _IncTax
        End Get
        Set(ByVal value As Double)
            _IncTax = (value)
        End Set
    End Property

    Public Property TaxAmount() As Double
        Get
            Return IIf(Not (ApplyTax), 0, (ExTax * ComputedTaxRate))
        End Get
        Set(ByVal value As Double)
            _TaxAmount = value
        End Set
    End Property

    Public Property ComputedTaxRate() As Double
        Get
            Return _TaxRate
        End Get
        Set(ByVal value As Double)
            _TaxRate = value
        End Set

    End Property

    Public Property Quantity() As Double
        Get
            Return _Quantity
        End Get
        Set(ByVal value As Double)
            _Quantity = value
        End Set
    End Property

    Public Property TotalExTax() As Double
        Get
            Return _TotalExTax
        End Get
        Set(ByVal value As Double)
            _TotalExTax = value
        End Set
    End Property

    Public Property TotalIncTax() As Double
        Get
            Return _TotalIncTax
        End Get
        Set(ByVal value As Double)
            _TotalIncTax = value
        End Set
    End Property

    Public Property isFixedValuePromo() As Boolean
        Get
            Return _isFixedValuePromo
        End Get
        Set(ByVal value As Boolean)
            _isFixedValuePromo = value
        End Set
    End Property

    Public Property ApplyTax() As Boolean
        Get
            Return _ApplyTax
        End Get
        Set(ByVal value As Boolean)
            _ApplyTax = value
        End Set
    End Property

End Class

<Serializable()> _
Public Class Promotion
    Private _ID As Integer
    Private _StartDate As Date
    Private _EndDate As Date
    Private _Live As Integer
    Private _OrderByValue As Double
    Private _MaxQuantity As Double
    Private _PartNo As String
    Private _Type As String
    Private _Value As Double
    Private _ItemType As String
    Private _ItemID As Integer
    Private _ItemName As String
    Private _PromoText As String


    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property

    Public Property StartDate() As Date
        Get
            Return _StartDate
        End Get
        Set(ByVal value As Date)
            _StartDate = value
        End Set
    End Property

    Public Property EndDate() As Date
        Get
            Return _EndDate
        End Get
        Set(ByVal value As Date)
            _EndDate = value
        End Set
    End Property

    Public Property Live() As Integer
        Get
            Return _Live
        End Get
        Set(ByVal value As Integer)
            _Live = value
        End Set
    End Property

    Public Property OrderByValue() As Double
        Get
            Return _OrderByValue
        End Get
        Set(ByVal value As Double)
            _OrderByValue = value
        End Set
    End Property

    Public Property MaxQuantity() As Double
        Get
            Return _MaxQuantity
        End Get
        Set(ByVal value As Double)
            _MaxQuantity = value
        End Set
    End Property

    Public Property PartNo() As String
        Get
            Return _PartNo
        End Get
        Set(ByVal value As String)
            _PartNo = value
        End Set
    End Property

    Public Property Type() As String
        Get
            Return _Type
        End Get
        Set(ByVal value As String)
            _Type = value
        End Set
    End Property

    Public Property Value() As Double
        Get
            Return _Value
        End Get
        Set(ByVal value As Double)
            _Value = value
        End Set
    End Property

    Public Property ItemType() As String
        Get
            Return _ItemType
        End Get
        Set(ByVal value As String)
            _ItemType = value
        End Set
    End Property

    Public Property ItemID() As Integer
        Get
            Return _ItemID
        End Get
        Set(ByVal value As Integer)
            _ItemID = value
        End Set
    End Property

    Public Property ItemName() As String
        Get
            Return _ItemName
        End Get
        Set(ByVal value As String)
            _ItemName = value
        End Set
    End Property

    Public Property PromoText() As String
        Get
            Return _PromoText
        End Get
        Set(ByVal value As String)
            _PromoText = value
        End Set
    End Property

End Class