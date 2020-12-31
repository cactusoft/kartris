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
''' User Control Template for the search results.
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class Templates_ProductTemplateSearchResult
    Inherits System.Web.UI.UserControl

    Public Sub LoadSearchResult(ByVal ptblResult As DataTable)
        rptSearchResult.DataSource = ptblResult
        rptSearchResult.DataBind()
    End Sub

    Protected Sub rptSearchResult_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptSearchResult.ItemDataBound

        'What page of results did user click from?
        Dim intPageNumber As Integer = 0
        Try
            intPageNumber = Request.QueryString("PPGR")
        Catch ex As Exception
            intPageNumber = 0
        End Try

        Dim blnCallForPrice As Boolean = ObjectConfigBLL.GetValue("K:product.callforprice", CType(e.Item.FindControl("litProductID"), Literal).Text) = 1
        For Each ctlElement As Control In e.Item.Controls

            Dim strNavigateURL As String = "~/Product.aspx?ProductID=" & _
            CType(e.Item.FindControl("litProductID"), Literal).Text
            strNavigateURL &= "&strReferer=search"
            strNavigateURL &= "&PPGR=" & intPageNumber

            Select Case ctlElement.ID
                Case "lnkProductName"
                    CType(e.Item.FindControl("lnkProductName"), HyperLink).NavigateUrl = strNavigateURL

                Case "litPriceView"
                    If Not blnCallForPrice Then

                        Dim numPrice As Single = 0.0F
                        numPrice = CDbl(CType(e.Item.FindControl("litPriceHidden"), Literal).Text)
                        numPrice = CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), numPrice)
                        CType(e.Item.FindControl("litPriceView"), Literal).Text = _
                        CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), numPrice)
                    End If
                Case "UC_ImageView"
                    'Format image
                    Dim UC_ImageView As ImageViewer = CType(e.Item.FindControl("UC_ImageView"), ImageViewer)
                    UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_ProductImage, _
                        CType(e.Item.FindControl("litProductID"), Literal).Text, _
                        KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.height"), _
                        KartSettingsManager.GetKartConfig("frontend.display.images.minithumb.width"), _
                        strNavigateURL, _
                        "")
                Case Else
            End Select
        Next

        'Determine what to show for 'from' price
        Select Case GetKartConfig("frontend.products.display.fromprice").ToLower

            Case "y" 'From $X.XX
                If blnCallForPrice Then
                    CType(e.Item.FindControl("litPriceFrom"), Literal).Visible = True
                    CType(e.Item.FindControl("litPriceView"), Literal).Visible = False
                    CType(e.Item.FindControl("litPriceFrom"), Literal).Text = GetGlobalResourceObject("Versions", "ContentText_CallForPrice")
                Else
                    CType(e.Item.FindControl("litPriceFrom"), Literal).Visible = True
                    CType(e.Item.FindControl("litPriceView"), Literal).Visible = True
                End If

            Case "p" '$X.XX
                If blnCallForPrice Then
                    CType(e.Item.FindControl("litPriceFrom"), Literal).Visible = True
                    CType(e.Item.FindControl("litPriceView"), Literal).Visible = False
                    CType(e.Item.FindControl("litPriceFrom"), Literal).Text = GetGlobalResourceObject("Versions", "ContentText_CallForPrice")
                Else
                    CType(e.Item.FindControl("litPriceFrom"), Literal).Visible = False
                    CType(e.Item.FindControl("litPriceView"), Literal).Visible = True
                End If

            Case Else 'No display
                CType(e.Item.FindControl("litPriceFrom"), Literal).Visible = False
                CType(e.Item.FindControl("litPriceView"), Literal).Visible = False

        End Select

    End Sub

    'Do this with function as can use try catch,
    'easier to trap errors if bad data import,
    'or apply other rules
    Public Function DisplayProductName() As String
        Try
            Return (Eval("P_Name"))
        Catch ex As Exception
            'do nowt
            Return ""
        End Try
    End Function
End Class
