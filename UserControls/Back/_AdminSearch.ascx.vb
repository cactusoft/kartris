'[[[NEW COPYRIGHT NOTICE]]]
Partial Class UserControls_Back_AdminSearch
    Inherits System.Web.UI.UserControl

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click
        Response.Redirect("~/Admin/_Search.aspx?key=" & Server.UrlEncode(CkartrisDisplayFunctions.RemoveXSS(txtSearch.Text)) & "&location=" & ddlFilter.SelectedValue)
    End Sub

End Class
