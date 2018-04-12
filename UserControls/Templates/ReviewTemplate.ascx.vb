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


        Dim numRating As Short = 5 'Default to highest

        'Try to see if there is a value stored. Occasionally
        'upgrades can lead to null values, we just need
        'to handle those without the page crashing
        Try
            numRating = CShort(litReviewRatingHidden.Text)
        Catch ex As Exception
            'oh well, it's a 5
        End Try

        '' POSITIVE STARS
        For i As Short = 1 To numRating
            Dim imgReviewYes As New Image
            SetImage(imgReviewYes, IMAGE_TYPE.enum_OtherImage, "reviewYes")
            If Not File.Exists(Server.MapPath(imgReviewYes.ImageUrl)) Then imgReviewYes.Visible = False
            imgReviewYes.AlternateText = "*"
            phdStars.Controls.Add(imgReviewYes)
        Next

        '' NEGATIVE STARS 
        For i As Short = numRating + 1 To 5
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
