'[[[NEW COPYRIGHT NOTICE]]]
Partial Class UserControls_Back_LoginConsole
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If String.IsNullOrEmpty(Session("Back_Auth")) Then
                pnlConsole.Visible = False
            Else
                Dim arrAuth As String() = HttpSecureCookie.DecryptValue(Session("Back_Auth"), "Login Console")
                litMessage.Text = arrAuth(0)

                If Not CBool(arrAuth(1)) Then imgConfig.ImageUrl = "~/Skins/Admin/Images/tick_empty.gif"
                If Not CBool(arrAuth(2)) Then imgProducts.ImageUrl = "~/Skins/Admin/Images/tick_empty.gif"
                If Not CBool(arrAuth(3)) Then imgOrders.ImageUrl = "~/Skins/Admin/Images/tick_empty.gif"
                If Not CBool(arrAuth(8)) Then imgSupport.ImageUrl = "~/Skins/Admin/Images/tick_empty.gif"
            End If
        End If
    End Sub

    'Handle logouts
    Protected Sub btnLogout_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnLogOut.Click
        Dim cokLogout As HttpCookie
        cokLogout = New HttpCookie(KartSettingsManager.GetKartConfig("general.webshopurl"), "")
        cokLogout.Expires = CkartrisDisplayFunctions.NowOffset.AddDays(-1D)
        Response.Cookies.Add(cokLogout)
        Session("Back_Auth") = ""
        Session("_LANG") = LanguagesBLL.GetDefaultLanguageID()
        Response.Redirect("~/Admin/")
    End Sub
End Class
