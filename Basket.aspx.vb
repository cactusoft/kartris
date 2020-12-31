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
