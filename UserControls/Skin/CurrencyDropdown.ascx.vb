'[[[NEW COPYRIGHT NOTICE]]]
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
