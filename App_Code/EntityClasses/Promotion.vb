Imports Microsoft.VisualBasic
Namespace Kartris
    ''' <summary>
    ''' A promotion that can be added to a basket to affect the items in the basket such as discount all items by 10% etc.
    ''' </summary>
    ''' <remarks></remarks>
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

        ''' <summary>
        ''' The database idenitifer for the promotion.
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
            End Set
        End Property

        ''' <summary>
        ''' Date from which the promotion is active. The promotion is not active before this date
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property StartDate() As Date
            Get
                Return _StartDate
            End Get
            Set(ByVal value As Date)
                _StartDate = value
            End Set
        End Property

        ''' <summary>
        ''' Date to which the promotion is active. The promotion is not active after this date
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property EndDate() As Date
            Get
                Return _EndDate
            End Get
            Set(ByVal value As Date)
                _EndDate = value
            End Set
        End Property

        ''' <summary>
        ''' Promotion is active
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
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
End Namespace
