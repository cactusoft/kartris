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
Imports CkartrisDisplayFunctions

''' <summary>
''' User Control Template for the Write Review Form, used in ProductReview.ascx
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class WriteReviewTemplate
    Inherits System.Web.UI.UserControl

    Public Event ReviewCreated()

    Private _ProductID As Integer
    Private _ProductName As String

    Public ReadOnly Property ProductName() As String
        Get
            Return _ProductName
        End Get
    End Property

    '' Creates/Loads the important info. about writing reviews.
    Public Sub CreateWriter(ByVal pProductID As Integer, ByVal pProductName As String)
        _ProductID = pProductID
        _ProductName = pProductName

        litProductName.Text = pProductName
        
    End Sub

    '' Fills the Rating's DropDownList with the rating values.
    Sub FillRatingValues()
        For i As Short = 1 To CShort(KartSettingsManager.GetKartConfig("frontend.reviews.ratings.maxvalue"))
            ddlRating.Items.Add(New ListItem(i, i))
        Next
    End Sub

    '' INSERT TO DB, adding the new review to the Review Table.
    Protected Sub btnAddReview_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddReview.Click
        Page.Validate("ReviewForm")
        If Page.IsValid AndAlso ajaxNoBotReview.IsValid Then
            '' Calling the INSERT STATEMENT of the Review's Table
            '' Sets the result of the INSERT, by getting the value from the Cached Resources
            If ReviewsBLL.AddNewReview(_ProductID, Session("LANG"), StripHTML(txtTitle.Text), StripHTML(txtReviewText.Text),
                                CShort(ddlRating.SelectedValue), StripHTML(txtName.Text), StripHTML(txtEmail.Text), StripHTML(txtLocation.Text), 0, "") Then
                litResult.Text = Replace(GetGlobalResourceObject("Reviews", "ContentText_ReviewAdded3"), "[itemname]", ProductName)
            Else
                litResult.Text = GetGlobalResourceObject("Kartris", "ContentText_Error")
            End If

            ClearForm() '' Clear the form for new reviews.
            mvwWriting.SetActiveView(viwWritingResult)   '' Activates the Result View.
        End If
        updReviewMain.Update()
    End Sub

    '' Clears the FORM Controls, for new writting.
    Sub ClearForm()
        ddlRating.SelectedIndex = 0
        txtTitle.Text = Nothing
        txtReviewText.Text = Nothing
        txtName.Text = Nothing
        txtLocation.Text = Nothing
        txtEmail.Text = Nothing
    End Sub

    '' Activates the Writting FORM from the result view.
    Protected Sub BtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        mvwWriting.SetActiveView(viwWritingForm)
    End Sub

    '' "Enter your review below for [itemname]"
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        litAddRevew.Text = Replace(GetGlobalResourceObject("Reviews", "ContentText_AddReview"), "[itemname]", litProductName.Text)

        If Not Page.IsPostBack Then
            ' Filling the Rating's DropDownList with the allowed values to be used(if the rating is enabled).
            ddlRating.Items.Clear()
            Select Case KartSettingsManager.GetKartConfig("frontend.reviews.ratings.enabled")
                Case "y"
                    ddlRating.Items.Add(New ListItem("-", ""))
                    FillRatingValues()
                Case "r"
                    FillRatingValues()
                Case "n"
                    ddlRating.Enabled = False
            End Select
        End If
        
    End Sub
End Class
