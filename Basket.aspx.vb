'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Basket
    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("Basket", "PageTitle_ShoppingBasket") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

        If Not IsPostBack Then
            If Request.QueryString("error") = "minimum" Then
                UC_PopUpErrors.SetTextMessage = GetLocalResourceObject("Popup_OrderBelowMin")
                UC_PopUpErrors.SetTitle = GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors")
                UC_PopUpErrors.ShowPopup()
            End If
        End If
    End Sub
End Class
