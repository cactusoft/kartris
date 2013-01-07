'[[[NEW COPYRIGHT NOTICE]]]
Imports System.Xml
Imports System.Web.Security

Partial Public Class Skin_Kartris_Template

    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        baseTag.Attributes("href") = CkartrisBLL.WebShopURL()
        lnkFavIcon1.Href = CkartrisBLL.WebShopURL() & "favicon.ico"
        lnkFavIcon2.Href = lnkFavIcon1.Href
        If Not Page.IsPostBack Then UC_AdminBar.Visible = HttpSecureCookie.IsBackendAuthenticated
    End Sub

End Class
