'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Front_CreditCardInput
    Inherits UserControl

    Private _AcceptsPaypal As Boolean = False

    Public WriteOnly Property AcceptsPaypal() As Boolean
        Set(ByVal value As Boolean)
            _AcceptsPaypal = value
        End Set
    End Property

    Public ReadOnly Property CardNumber() As String
        Get
            If Not String.IsNullOrEmpty(txtCardNumber.Text) Then
                Return txtCardNumber.Text
            Else
                Return Nothing
            End If
        End Get
    End Property

    Public ReadOnly Property CardType() As String
        Get
            Return ddlCardType.SelectedValue
        End Get
    End Property

    Public ReadOnly Property CardIssueNumber() As String
        Get
            If Not String.IsNullOrEmpty(txtCardIssueNumber.Text) Then
                Return txtCardIssueNumber.Text
            Else
                Return 999
            End If
        End Get
    End Property

    Public ReadOnly Property CardSecurityNumber() As String
        Get
            If Not String.IsNullOrEmpty(txtCardSecurityNumber.Text) Then
                Return txtCardSecurityNumber.Text
            Else
                Return Nothing
            End If

        End Get
    End Property

    Public ReadOnly Property StartDate() As String
        Get
            Return ddlCardStartMonth.SelectedItem.Text & Right(ddlCardStartYear.SelectedItem.Text, 2)

        End Get
    End Property

    Public ReadOnly Property ExpiryDate() As String
        Get
            Return ddlCardExpiryMonth.SelectedItem.Text & Right(ddlCardExpiryYear.SelectedItem.Text, 2)
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        If Not IsPostBack Then

            'Create card dropdown
            Dim tblCardTypes As DataTable = OrdersBLL.GetCardTypeList
            ddlCardType.Items.Insert(0, New ListItem(GetGlobalResourceObject("Kartris", "ContentText_DropdownSelectDefault"), ""))
            For Each rowCards As DataRow In tblCardTypes.Rows
                ddlCardType.Items.Add(rowCards(0).ToString)
            Next
            If _AcceptsPaypal Then ddlCardType.Items.Add("PayPal")

            'Add years to valid-from dropdown
            For numStartYear = (Year(Now) - 10) To Year(Now)
                ddlCardStartYear.Items.Add(numStartYear.ToString)
            Next

            'Add years to valid-to dropdown
            For numEndYear = Year(Now) To (Year(Now) + 10)
                ddlCardExpiryYear.Items.Add(numEndYear.ToString)
            Next
        End If

    End Sub


End Class