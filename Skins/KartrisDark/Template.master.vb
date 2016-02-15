'========================================================================
'KARTRIS by cactusoft
'Copyright 2016 CACTUSOFT - www.kartris.com
'This skin is licensed under a
'Creative Commons Attribution-ShareAlike 3.0 Unported License

'http://creativecommons.org/licenses/by-sa/3.0/deed.en_GB
'========================================================================
Imports System.Xml
Imports System.Web.Security

Partial Public Class Skin_KartrisDark_Template

    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        baseTag.Attributes("href") = CkartrisBLL.WebShopURL()
        lnkFavIcon1.Href = CkartrisBLL.WebShopURL() & "favicon.ico"
        If Not Page.IsPostBack Then UC_AdminBar.Visible = HttpSecureCookie.IsBackendAuthenticated
    End Sub

End Class
