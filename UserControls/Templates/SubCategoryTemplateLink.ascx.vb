'[[[NEW COPYRIGHT NOTICE]]]

''' <summary>
''' User Control Template for the Link View of the Child Categories (SubCategories)
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class SubCategoryTemplateLink
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        lnkCategoryName.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category, _
                                        litCategoryIDHidden.Text, Request.QueryString("strParent") & "," & Request.QueryString("CategoryID"))
    End Sub
End Class
