'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Customer_Account
    Inherits PageBaseClass
    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Me.Load

        'Don't show this page if user already logged in, go to the customer home page
        If Not Page.IsPostBack Then
            If LCase(KartSettingsManager.GetKartConfig("frontend.users.access")) = "yes" Then litMustBeLoggedIn.Visible = True
            If User.Identity.IsAuthenticated Then Response.Redirect("~/Customer.aspx?action=home")
        End If

    End Sub

End Class
