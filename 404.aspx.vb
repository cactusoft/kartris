'[[[NEW COPYRIGHT NOTICE]]]
Partial Class _404
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'Send a 404 code to browser
        Response.Status = "404 Not Found"
    End Sub


End Class
