'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisImages
Imports KartSettingsManager

''' <summary>
''' User Control Template for the Extended View of the Products.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class ProductTemplateExtended
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim strNavigateURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.Product, litProductID.Text, Request.QueryString("strParent"), Request.QueryString("CategoryID"))

        lnkProductName.NavigateUrl = strNavigateURL
        lnknMore.NavigateUrl = strNavigateURL

        UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_ProductImage,
            litProductID.Text,
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.height"),
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.width"),
            strNavigateURL, , , lnkProductName.Text)

        SetCompareURL()

        Try
            '' Call to load the UC Product Versions for the Current Product.
            UC_ProductVersions.LoadProductVersions(litProductID.Text, Session("LANG"), litVersionsViewType.Text)
        Catch ex As Exception
        End Try

        If Not UC_ProductVersions.HasPrice Then
            phdMinPrice.Visible = True
        End If

    End Sub

    Sub SetCompareURL()
        '' Setting the Compare URL ...
        Dim strCompareLink As String = Request.Url.ToString.ToLower
        If Request.Url.ToString.ToLower.Contains("category.aspx") Then
            strCompareLink = strCompareLink.Replace("category.aspx", "Compare.aspx")
        ElseIf Request.Url.ToString.ToLower.Contains("product.aspx") Then
            strCompareLink = strCompareLink.Replace("product.aspx", "Compare.aspx")
        Else
            strCompareLink = "~/Compare.aspx"
        End If
        If strCompareLink.Contains("?") Then
            strCompareLink += "&action=add&id=" & litProductID.Text
        Else
            strCompareLink += "?action=add&id=" & litProductID.Text
        End If

    End Sub


End Class
