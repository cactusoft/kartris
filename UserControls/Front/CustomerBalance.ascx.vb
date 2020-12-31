'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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
Partial Class UserControls_Front_CustomerBalance
    Inherits System.Web.UI.UserControl

    Private numCustomerID As Int64
    Private numCurrencyID As Int16

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            numCustomerID = DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID
        Catch ex As Exception
            FormsAuthentication.SignOut()
            numCustomerID = 0
        End Try

        Try
            numCurrencyID = HttpContext.Current.Session("CUR_ID")
        Catch ex As Exception
            numCurrencyID = CurrenciesBLL.GetDefaultCurrency
        End Try

        'Get orders for user and total them, set literal to this value
        Dim dblOrdersTotal As Double = OrdersBLL._GetOrderTotalByCustomerID(numCustomerID) 'total value of orders made
        Dim dblPaymentsTotal As Double = OrdersBLL._GetPaymentTotalByCustomerID(numCustomerID) 'total payments made
        Dim dblUpdatedBalance As Double = dblPaymentsTotal - dblOrdersTotal

        litCustomerBalance.Text = CurrenciesBLL.FormatCurrencyPrice(numCurrencyID, dblUpdatedBalance)

    End Sub
End Class
