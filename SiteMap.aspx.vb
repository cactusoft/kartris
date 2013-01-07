'[[[NEW COPYRIGHT NOTICE]]]
Imports System.Xml

Partial Class SiteMap
    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'New usercontrol
        Dim objCategoryMenuUserControl As Control
        objCategoryMenuUserControl = LoadControl("~/UserControls/Skin/CategoryMenuAccordion.ascx")

        'Add appropriate menu control
        phdCategoryMenu.Controls.Add(objCategoryMenuUserControl)
    End Sub

End Class
