'[[[NEW COPYRIGHT NOTICE]]]
Partial Class UserControls_Skin_LoginStatus
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Show main login and status links
        If Page.User.Identity.IsAuthenticated Then
            phdLoggedIn.Visible = True

        Else
            phdLoggedOut.Visible = True
        End If

    End Sub


End Class
