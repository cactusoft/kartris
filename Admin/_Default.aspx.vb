'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_Home
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim arrAuth As String() = HttpSecureCookie.Decrypt(Session("Back_Auth"))
        phdOrderStats.Visible = CBool(arrAuth(3)) Or CBool(arrAuth(1))
    End Sub
End Class
