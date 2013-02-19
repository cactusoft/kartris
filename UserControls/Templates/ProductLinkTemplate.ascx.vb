'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

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
''' User Control Template for the Tabular View of the Products.
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class Templates_ProductLinkTemplate
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim strNavigateURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.Product, litProductID.Text, Request.QueryString("strParent"), Request.QueryString("CategoryID"))

        lnkProductName.NavigateUrl = strNavigateURL

        UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_ProductImage, _
            litProductID.Text, _
            KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height"), _
            KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width"), _
            strNavigateURL, _
            "")

    End Sub

End Class