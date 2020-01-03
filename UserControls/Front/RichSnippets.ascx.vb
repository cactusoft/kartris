'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation

Partial Class UserControls_Front_RichSnippets
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer
    Public WriteOnly Property ProductID() As Integer
        Set(value As Integer)
            _ProductID = value
        End Set
    End Property

    Protected Sub UserControls_Front_RichSnippets_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack AndAlso _ProductID > 0 Then
            LoadSnippets()
        End If
    End Sub

    Sub LoadSnippets()
        Dim dr As DataRow = ProductsBLL.GetRichSnippetProperties(_ProductID, Session("LANG"))(0)

        Dim strURL As String = CkartrisBLL.WebShopURL.ToLower & "======" & SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, _ProductID) ' added the === bit to make it easier to remove the double slash from joining webshopURL with the page URL local
        strURL = Replace(strURL, "/======/", "/")

        '' Name, SKU and Category
        litProductMain.Text = litProductMain.Text.Replace("[product_name]", Replace(CkartrisDisplayFunctions.StripHTML(FixNullFromDB(dr("P_Name"))), """", "\"""))
        litProductMain.Text = litProductMain.Text.Replace("[product_desc]", Replace(CkartrisDisplayFunctions.StripHTML(FixNullFromDB(dr("P_Desc"))), """", "\"""))
        litProductMain.Text = litProductMain.Text.Replace("[sku]", FixNullFromDB(dr("P_SKU")))
        litProductMain.Text = litProductMain.Text.Replace("[category]", FixNullFromDB(dr("P_Category")))

        '' Image
        Dim dirFolder As New DirectoryInfo(Server.MapPath(CkartrisImages.strProductImagesPath & "/" & _ProductID & "/"))
        If dirFolder.Exists Then
            If dirFolder.GetFiles().Length > 0 Then
                For Each objFile In dirFolder.GetFiles()
                    litImage.Text = litImage.Text.Replace(
                        "[image_source]", Replace(CkartrisImages.strProductImagesPath, "~/", CkartrisBLL.WebShopURL()) & "/" & _ProductID & "/" & objFile.Name)
                    Exit For
                Next
            Else
                litImage.Visible = False
            End If
        Else
            litImage.Visible = False
        End If

        '' Reviews
        If FixNullFromDB(dr("P_TotalReview")) > 0 Then
            litReview.Text = litReview.Text.Replace("[review_avg]", FixNullFromDB(dr("P_AverageReview")))
            litReview.Text = litReview.Text.Replace("[review_total]", FixNullFromDB(dr("P_TotalReview")))
        Else
            litReview.Visible = False
        End If

        '' Price
        If FixNullFromDB(dr("P_Type")) = "s" Then
            '' Single Version
            litOffer.Text = litOffer.Text.Replace("[currency]", CurrenciesBLL.CurrencyCode(Session("CUR_ID")))
            litOffer.Text = litOffer.Text.Replace("[price]", CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), FixNullFromDB(dr("P_Price")), False))
            litOffer.Text = litOffer.Text.Replace("[url]", strURL)
            litOfferAggregate.Visible = False

        ElseIf FixNullFromDB(dr("P_MinPrice")) = FixNullFromDB(dr("P_MaxPrice")) Then
            litOffer.Text = litOffer.Text.Replace("[currency]", CurrenciesBLL.CurrencyCode(Session("CUR_ID")))
            litOffer.Text = litOffer.Text.Replace("[price]", CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), FixNullFromDB(dr("P_MinPrice")), False))
            litOffer.Text = litOffer.Text.Replace("[url]", strURL)
            litOfferAggregate.Visible = False
        Else
            litOfferAggregate.Text = litOfferAggregate.Text.Replace("[currency]", CurrenciesBLL.CurrencyCode(Session("CUR_ID")))
            litOfferAggregate.Text = litOfferAggregate.Text.Replace("[lowprice]", CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), FixNullFromDB(dr("P_MinPrice"))), False))
            litOfferAggregate.Text = litOfferAggregate.Text.Replace("[highprice]", CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), FixNullFromDB(dr("P_MaxPrice"))), False))
            litOfferAggregate.Text = litOfferAggregate.Text.Replace("[url]", strURL)
            litOffer.Visible = False
        End If




        ''' Disable Offer if Call for Price is set
        'If FixNullFromDB(dr("P_CallForPrice")) = 1 Then
        '    litOffer.Visible = False
        '    litOfferAggregate.Visible = False
        'End If

    End Sub
End Class

