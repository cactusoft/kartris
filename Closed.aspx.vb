'[[[NEW COPYRIGHT NOTICE]]]
Partial Class _Closed
    Inherits System.Web.UI.Page
    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Me.Load

        'If this page is called or hit by anyone when store is open, send
        'them to home page.
        If KartSettingsManager.GetKartConfig("general.storestatus") = "open" Then Response.Redirect("~/Default.aspx")

    End Sub

End Class
