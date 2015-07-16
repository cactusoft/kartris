Imports Microsoft.VisualBasic
Namespace Kartris
    ''' <summary>
    ''' Used to modify the entirety of a basket according to any rule set
    ''' </summary>
    ''' <remarks>Used to apply coupons, promotions, shipping etc. to a basket.</remarks>
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
            End Get
            Set(ByVal value As Double)
                _IncTax = value
            End Set
        End Property

        Public Property TaxRate() As Double
            Get
                Dim numRounding As Integer = 0
                If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" And ConfigurationManager.AppSettings("TaxRegime").ToLower <> "simple" Then
                    numRounding = 4
                Else
                    numRounding = 6
                End If
                Return Math.Round(_TaxRate, numRounding)
            End Get
            Set(ByVal value As Double)
                _TaxRate = value
            End Set
        End Property

        Public ReadOnly Property TaxAmount() As Double
            Get
                Dim numRounding As Integer = 0
                If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" And ConfigurationManager.AppSettings("TaxRegime").ToLower <> "simple" Then
                    numRounding = 2
                Else
                    numRounding = 4
                End If
                Return Math.Round(IncTax - ExTax, numRounding)
            End Get
        End Property

    End Class
End Namespace
