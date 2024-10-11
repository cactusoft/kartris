'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================

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
