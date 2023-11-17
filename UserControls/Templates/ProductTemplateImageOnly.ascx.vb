'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

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
''' User Control Template for tiny image thumbs for basket, recent products, etc.
''' Now using GetImageURL function in BasketBLL.vb, so will show version image if available
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class ProductTemplateImageOnly
    Inherits System.Web.UI.UserControl

    Function CreateImageTag() As String
        Dim strImageURL As String = " "
        Dim strImageTag As String = " "
        Dim strItemType As String = "p"
        Dim blnPlaceHolder As Boolean = (KartSettingsManager.GetKartConfig("frontend.display.image.products.placeholder") = "y")

        'Dim strNavigateURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.Product, litProductID.Text, Request.QueryString("strParent"), Request.QueryString("CategoryID"))

        'If recent products, the above can generate a bad path on pages called
        'with unfriend URLs, such as from search results. So let's
        'use canonical URL instead.
        Dim strNavigateURL = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, litProductID.Text)

        strImageURL = BasketBLL.GetImageURL(litVersionID.Text, litProductID.Text)

        If strImageURL <> "" Then
            strImageTag = "<a href=""" & strNavigateURL & """><img alt=""" & litP_Name.Text & """ src=""" & strImageURL & """ /></a>"
        Else
            If blnPlaceHolder Then
                strImageURL = CkartrisBLL.WebShopURL & "Image.ashx?strItemType=" & strItemType & "&amp;numMaxHeight=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height") & "&amp;numMaxWidth=" & KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width") & "&amp;numItem=0&amp;strParent=0"
                strImageTag = "<a href=""" & strNavigateURL & """><img alt=""No image"" src=""" & strImageURL & """ /></a>"
            Else
                Me.Visible = False 'turn off this whole control
            End If
        End If

        Return strImageTag
    End Function

End Class

