'[[[NEW COPYRIGHT NOTICE]]]
Imports System.Web
Imports CkartrisBLL
Imports System.Web.HttpContext
Imports CkartrisDisplayFunctions

Imports KartSettingsManager

Partial Class UserControls_Front_AdminBar

    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
 
        If (Not Me.IsPostBack) AndAlso HttpSecureCookie.IsBackendAuthenticated Then

            Dim strResolvedFrontEndURL As String = ""
            Dim strResolvedBackEndURL As String = ""

            'We use the FindItemBackEndURL function, which is
            'developed from the SEORewrite one in the
            'SiteMapProvider to transform the friendly
            'URL or a parametrized one to the appropriate back
            'end link to allow us to edit the item.
            strResolvedFrontEndURL = Context.Request.RawUrl.ToLower
            strResolvedBackEndURL = SiteMapHelper.FindItemBackEndURL(Context.Request.RawUrl.ToLower)

            'Category Page
            If strResolvedBackEndURL.ToLower.Contains("_modifycategory.aspx") Then
                lnkMenuMain.NavigateUrl = strResolvedBackEndURL
                lnkNavigateToCategory.NavigateUrl = Replace(strResolvedBackEndURL, "_ModifyCategory.aspx", "_Category.aspx")
                lnkNewProductHere.NavigateUrl = Replace(strResolvedBackEndURL, "_ModifyCategory.aspx?", "_ModifyProduct.aspx?ProductID=0&")
                phdCategoryLink.Visible = True
            End If

            'Product Page
            If strResolvedBackEndURL.ToLower.Contains("_modifyproduct.aspx") Then
                lnkMenuMain.NavigateUrl = strResolvedBackEndURL
                phdCategoryLink.Visible = False
            End If

            'News Page
            If strResolvedBackEndURL.ToLower.Contains("_sitenews.aspx") Then
                lnkMenuMain.NavigateUrl = strResolvedBackEndURL
                phdCategoryLink.Visible = False
            End If

            'KB Page
            If strResolvedBackEndURL.ToLower.Contains("_knowledgebase.aspx") Then
                lnkMenuMain.NavigateUrl = strResolvedBackEndURL
                phdCategoryLink.Visible = False
            End If

            'custom CMS page
            If strResolvedBackEndURL.ToLower.Contains("_custompages.aspx") Then
                lnkMenuMain.NavigateUrl = strResolvedBackEndURL
                phdCategoryLink.Visible = False
            End If

            'home page
            If lnkMenuMain.NavigateUrl.ToLower.Contains("default.aspx") Then
                If strResolvedFrontEndURL.ToLower.Contains("default.aspx") Then
                    phdEditHomePageLink.Visible = True
                End If
                lnkEditHomePage.NavigateUrl = "~/Admin/_CustomPages.aspx?strPage=Default"
            End If
        End If

    End Sub

End Class
