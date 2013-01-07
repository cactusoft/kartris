﻿'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisImages

''' <summary>
''' User Control Template for the Product Review.
''' </summary>
''' <remarks></remarks>
Partial Class UserControls_Templates_New_ReviewTemplate
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        '' Creating the POSITIVE/NEGATIVE Stars of the current Review:
        '' 1. Creating new Image Control
        '' 2. Calling the SetImage Function to set the POSITIVE star Image. (kartris.vb)
        '' 3. Adding the newly created Image to the PlaceHolder

        '' POSITIVE STARS
        For i As Short = 1 To CShort(litReviewRatingHidden.Text)
            Dim imgReviewYes As New Image
            SetImage(imgReviewYes, IMAGE_TYPE.enum_OtherImage, "reviewYes")
            If Not File.Exists(Server.MapPath(imgReviewYes.ImageUrl)) Then imgReviewYes.Visible = False
            imgReviewYes.AlternateText = "*"
            phdStars.Controls.Add(imgReviewYes)
        Next

        '' NEGATIVE STARS 
        For i As Short = CShort(litReviewRatingHidden.Text) + 1 To 5
            Dim imgReviewNo As New Image
            SetImage(imgReviewNo, IMAGE_TYPE.enum_OtherImage, "reviewNo")
            If Not File.Exists(Server.MapPath(imgReviewNo.ImageUrl)) Then imgReviewNo.Visible = False
            imgReviewNo.AlternateText = "-"
            phdStars.Controls.Add(imgReviewNo)
        Next

        '' Formats the creation date of the review.
        '' A CONFIG Setting Key 'frontend.reviews.dateformat' holds the default reviews date's format.
        litReviewDateCreated.Text = _
            Format(CDate(litReviewDateCreated.Text), KartSettingsManager.GetKartConfig("frontend.reviews.dateformat"))

    End Sub
End Class
