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

        '' SKU and Category
        litProductMain.Text = litProductMain.Text.Replace("[sku]", FixNullFromDB(dr("P_SKU")))
        litProductMain.Text = litProductMain.Text.Replace("[category]", FixNullFromDB(dr("P_Category")))

        '.Text.Replace("[sku]", FixNullFromDB(dr("")))
        '' Image
        Dim dirFolder As New DirectoryInfo(Server.MapPath(CkartrisImages.strProductImagesPath & "/" & _ProductID & "/"))
        If dirFolder.Exists Then
            If dirFolder.GetFiles().Length > 0 Then
                For Each objFile In dirFolder.GetFiles()
                    litImage.Text = litImage.Text.Replace( _
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
            litOffer.Text = litOffer.Text.Replace("[price]", FixNullFromDB(dr("P_Price")))
            litOfferAggregate.Visible = False
        ElseIf FixNullFromDB(dr("P_MinPrice")) = FixNullFromDB(dr("P_MaxPrice")) Then
            litOffer.Text = litOffer.Text.Replace("[currency]", CurrenciesBLL.CurrencyCode(Session("CUR_ID")))
            litOffer.Text = litOffer.Text.Replace("[price]", FixNullFromDB(dr("P_MinPrice")))
            litOfferAggregate.Visible = False
        Else
            litOfferAggregate.Text = litOffer.Text.Replace("[currency]", CurrenciesBLL.CurrencyCode(Session("CUR_ID")))
            litOfferAggregate.Text = litOffer.Text.Replace("[lowPrice]", FixNullFromDB(dr("P_MinPrice")))
            litOfferAggregate.Text = litOffer.Text.Replace("[highPrice]", FixNullFromDB(dr("P_MinPrice")))
            litOffer.Visible = False
        End If

    End Sub
End Class
