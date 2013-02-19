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
Partial Class UserControls_Skin_CurrencyDropdown
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        
        If Not Page.IsPostBack Then
            Dim tblCurrenceis As DataTable = KartSettingsManager.GetCurrenciesFromCache() 'CurrenciesBLL.GetCurrencies()
            Dim drLiveCurrencies As DataRow() = tblCurrenceis.Select("CUR_Live = 1")
            If drLiveCurrencies.Length > 0 Then
                ddlCurrency.Items.Clear()
                For i As Byte = 0 To drLiveCurrencies.Length - 1
                    ddlCurrency.Items.Add(New ListItem(drLiveCurrencies(i)("CUR_Symbol") & " " & drLiveCurrencies(i)("CUR_ISOCode"), drLiveCurrencies(i)("CUR_ID")))
                Next
            End If
            ddlCurrency.SelectedIndex = ddlCurrency.Items.IndexOf(ddlCurrency.Items.FindByValue(Session("CUR_ID")))
        End If
    End Sub

    Protected Sub ddlCurrency_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCurrency.SelectedIndexChanged
        Session("CUR_ID") = ddlCurrency.SelectedValue
        Response.Redirect(Request.Url.ToString)
    End Sub
End Class
