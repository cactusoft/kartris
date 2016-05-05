Imports Microsoft.VisualBasic
Namespace Kartris
    ''' <summary>
    ''' Contains a promotion item and is used to modify a basket with the contents of the promotion
    ''' </summary>
    ''' <remarks>A promotion may define that all items over $100 are discounted by 10%, this modifier is responsible for actioning the details of the promotion upon the basket</remarks>
    <Serializable()> _
    Public Class PromotionBasketModifier
        Private _PromotionID As Integer
        Private _Name As String
        Private _ExTax As Decimal
        Private _IncTax As Decimal
        Private _TaxAmount As Decimal
        Private _TaxRate As Decimal
        Private _Quantity As Double
        Private _TotalExTax As Decimal
        Private _TotalIncTax As Decimal
        Private _isFixedValuePromo As Boolean
        Private _ApplyTax As Boolean

        ''' <summary>
        ''' The database identifier number for the promotion
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property PromotionID() As Integer
            Get
                Return _PromotionID
            End Get
            Set(ByVal value As Integer)
                _PromotionID = value
            End Set
        End Property

        ''' <summary>
        ''' Promotion name
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
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

        Public Property IncTax() As Decimal
            Get
                Return _IncTax
            End Get
            Set(ByVal value As Decimal)
                _IncTax = (value)
            End Set
        End Property

        Public Property TaxAmount() As Decimal
            Get
                Return IIf(Not (ApplyTax), 0, (ExTax * ComputedTaxRate))
            End Get
            Set(ByVal value As Decimal)
                _TaxAmount = value
            End Set
        End Property

        Public Property ComputedTaxRate() As Decimal
            Get
                Return _TaxRate
            End Get
            Set(ByVal value As Decimal)
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

        Public Property TotalExTax() As Decimal
            Get
                Return _TotalExTax
            End Get
            Set(ByVal value As Decimal)
                _TotalExTax = value
            End Set
        End Property

        Public Property TotalIncTax() As Decimal
            Get
                Return _TotalIncTax
            End Get
            Set(ByVal value As Decimal)
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
End Namespace
