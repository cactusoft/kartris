'========================================================================
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
Imports CkartrisImages
Imports KartSettingsManager

''' <summary>
''' User Control Template for the Tabular View of the Products.
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class ProductTemplateTabular
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim strNavigateURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.Product, litProductID.Text, Request.QueryString("strParent"), Request.QueryString("CategoryID"))
        Dim blnCallForPrice As Boolean = ObjectConfigBLL.GetValue("K:product.callforprice", litProductID.Text) = 1

        lnkProductName.NavigateUrl = strNavigateURL

        UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_ProductImage,
            litProductID.Text,
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.height"),
            KartSettingsManager.GetKartConfig("frontend.display.images.thumb.width"),
            strNavigateURL, , , lnkProductName.Text)

        'Determine what to show for 'from' price
        Select Case GetKartConfig("frontend.products.display.fromprice").ToLower
            Case "y" 'From $X.XX
                If blnCallForPrice Then
                    litPriceFrom.Visible = True
                    litPriceFrom.Text = GetGlobalResourceObject("Versions", "ContentText_CallForPrice")
                    litPriceView.Visible = False
                    divPrice.Visible = True
                Else
                    litPriceView.Text = CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), CDbl(litPriceHidden.Text))
                    litPriceFrom.Visible = True
                    litPriceView.Visible = True
                End If

            Case "p" '$X.XX
                If blnCallForPrice Then
                    litPriceFrom.Visible = True
                    litPriceFrom.Text = GetGlobalResourceObject("Versions", "ContentText_CallForPrice")
                    litPriceView.Visible = False
                    divPrice.Visible = True
                Else
                    litPriceView.Text = CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), CDbl(litPriceHidden.Text))
                    litPriceFrom.Visible = False
                    litPriceView.Visible = True
                End If

            Case Else 'No display
                litPriceFrom.Visible = False
                litPriceView.Visible = False
        End Select
    End Sub

    'Do this with function as can use try catch,
    'easier to trap errors if bad data import,
    'or apply other rules
    Public Function DisplayProductName() As String
        Try
            Return Server.HtmlEncode(Eval("P_Name"))
        Catch ex As Exception
            'do nowt
            Return ""
        End Try
    End Function
End Class
