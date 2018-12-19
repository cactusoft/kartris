﻿'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
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

            If Application("subsiteId") > 0 Then
                phdExitSubsiteLink.Visible = True
                Dim subsiteCookie As New HttpCookie("subsiteId")
                subsiteCookie.Value = Application("subsiteId")
                subsiteCookie.Expires = DateTime.Now.AddDays(30)
                Response.Cookies.Add(subsiteCookie)
            End If

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


    Protected Sub lnkExitSubsitePreview_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkExitSubsitePreview.Click
        Dim subsiteIdStr As String = "subsiteId"

        If Application(subsiteIdStr) > 0 Then
            Application(subsiteIdStr) = 0
            Dim subsiteCookie As New HttpCookie(subsiteIdStr)
            subsiteCookie.Values.Remove(subsiteIdStr)
            subsiteCookie.Expires = DateTime.Now.AddDays(1)
            Response.Cookies.Add(subsiteCookie)

            Response.Redirect("~/Admin/_Default.aspx")
        End If

    End Sub
End Class
