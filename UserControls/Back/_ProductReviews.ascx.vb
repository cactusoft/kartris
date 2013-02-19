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
Imports CkartrisDataManipulation
Imports CkartrisEnumerations
Imports CkartrisImages
Imports KartSettingsManager

Partial Class _ProductReviews

    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '***Ratings blank if the if/endif is used as does not run on reviews tab of edit-product

    End Sub

    Public Sub LoadProductReviews()

        Dim intRowsPerPage As Integer = 25
        Try
            intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
        Catch ex As Exception
            'Stays at 25
        End Try

        gvwProductReviews.PageSize = intRowsPerPage

        If ddlLanguages.Items.Count = 0 Then
            Dim tblLanguages As DataTable = GetLanguagesFromCache()
            ddlLanguages.DataTextField = "LANG_BackName"
            ddlLanguages.DataValueField = "LANG_ID"
            ddlLanguages.DataSource = tblLanguages
            ddlLanguages.DataBind()
        End If

        Dim tblProductReviews As New DataTable

        If _GetProductID() <> 0 Then
            tblProductReviews = ReviewsBLL._GetReviewsByProductID(_GetProductID(), Session("_LANG"))
            gvwProductReviews.Columns(2).Visible = False
        Else
            tblProductReviews = ReviewsBLL._GetReviews()
            gvwProductReviews.Columns(2).Visible = True
        End If

        If tblProductReviews.Rows.Count = 0 Then pnlNoReview.Visible = True : pnlReviewColors.Visible = False : Return

        Dim dv As DataView = tblProductReviews.DefaultView

        If Not Request.QueryString("strModerate") Is Nothing AndAlso _
            Request.QueryString("strModerate") = "y" Then
            dv.RowFilter = "REV_Live = 'a'"
        End If

        gvwProductReviews.DataSource = dv
        gvwProductReviews.DataBind()

    End Sub

    Protected Sub gvwProductReviews_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwProductReviews.PageIndexChanging
        gvwProductReviews.PageIndex = e.NewPageIndex
        LoadProductReviews()
    End Sub

    Protected Sub gvwProductReviews_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwProductReviews.RowCommand
        Select Case e.CommandName
            Case "EditReview"
                EditReview(CShort(e.CommandArgument))
        End Select
    End Sub

    Private Sub EditReview(ByVal ReviewID As Short)
        phdEditReview.Visible = True
        phdReviewsList.Visible = False
        litReviewID.Text = CStr(ReviewID)

        Dim tblReview As DataTable = ReviewsBLL._GetReviewByID(ReviewID)
        Dim productID As Integer = CInt(FixNullFromDB(tblReview.Rows(0)("REV_ProductID")))

        litProductName.Text = ProductsBLL._GetNameByProductID(productID, Session("_LANG"))
        txtTitle.Text = FixNullFromDB(tblReview.Rows(0)("REV_Title"))
        txtReviewText.Text = FixNullFromDB(tblReview.Rows(0)("REV_Text"))
        txtName.Text = FixNullFromDB(tblReview.Rows(0)("REV_Name"))
        txtLocation.Text = FixNullFromDB(tblReview.Rows(0)("REV_Location"))
        txtEmail.Text = FixNullFromDB(tblReview.Rows(0)("REV_Email"))

        ddlRating.Text = FixNullFromDB(tblReview.Rows(0)("REV_Rating"))
        ddlLanguages.SelectedValue = FixNullFromDB(tblReview.Rows(0)("REV_LanguageID"))
        ddlStatus.SelectedValue = FixNullFromDB(tblReview.Rows(0)("REV_Live"))

        updMain.Update()
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        FinishEditing()
    End Sub

    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack.Click
        FinishEditing()
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        Dim numReviewID As Short = CShort(litReviewID.Text)
        Dim numLanguageID As Byte = CByte(ddlLanguages.SelectedValue)
        Dim numCustomerID As Integer = 0
        Dim strTitle As String = txtTitle.Text
        Dim strText As String = txtReviewText.Text
        Dim numRating As Byte = CByte(ddlRating.SelectedValue)
        Dim strName As String = txtName.Text
        Dim strLocation As String = txtLocation.Text
        Dim strEmail As String = txtEmail.Text
        Dim chrStatus As Char = CChar(ddlStatus.SelectedValue)
        Dim strMessage As String = ""
        If Not ReviewsBLL._UpdateReview(numReviewID, numLanguageID, strTitle, strText, numRating, strName, _
                                                    strEmail, strLocation, chrStatus, numCustomerID, strMessage) Then
            _UC_DeleteConfirmation.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RaiseEvent ShowMasterUpdate()
        FinishEditing()
    End Sub

    Sub FinishEditing()
        phdEditReview.Visible = False
        phdReviewsList.Visible = True
        LoadProductReviews()
        updMain.Update()
    End Sub

    Protected Sub gvwProductReviews_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwProductReviews.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then

            Select Case CType(e.Row.Cells(1).FindControl("litReviewStatus"), Literal).Text
                Case "a"
                    If e.Row.RowState = DataControlRowState.Alternate Then
                        e.Row.CssClass = "Kartris-GridView-Alternate-Green"
                    Else
                        e.Row.CssClass = "Kartris-GridView-Green"
                    End If
                Case "n"
                    If e.Row.RowState = DataControlRowState.Alternate Then
                        e.Row.CssClass = "Kartris-GridView-Alternate-Red"
                    Else
                        e.Row.CssClass = "Kartris-GridView-Red"
                    End If
            End Select

            If gvwProductReviews.Columns(0).Visible Then
                Dim numProductID As Integer = CInt(CType(e.Row.Cells(0).FindControl("litProductID"), Literal).Text)
                CType(e.Row.Cells(0).FindControl("lnkBtnProductName"), LinkButton).Text = _
                    ProductsBLL._GetNameByProductID(numProductID, Session("_LANG"))
                CType(e.Row.Cells(0).FindControl("lnkBtnProductName"), LinkButton).PostBackUrl = _
                    "~/Admin/_ModifyProduct.aspx?ProductID=" & numProductID
            End If

            Dim numRating As Byte = CByte(CType(e.Row.Cells(1).FindControl("litRating"), Literal).Text)

            '' POSITIVE STARS
            For i As Short = 1 To numRating

                Dim reviewYes As New Image
                reviewYes.ImageUrl = "~/Skins/Admin/Images/reviewYes.gif"
                reviewYes.AlternateText = "*"
                If Not File.Exists(Server.MapPath(reviewYes.ImageUrl)) Then reviewYes.Visible = False

                CType(e.Row.Cells(1).FindControl("phdStars"), PlaceHolder).Controls.Add(reviewYes)
            Next

            '' NEGATIVE STARS 
            For i As Short = numRating + 1 To 5

                Dim reviewNo As New Image
                reviewNo.ImageUrl = "~/Skins/Admin/Images/reviewNo.gif"
                reviewNo.AlternateText = "-"
                If Not File.Exists(Server.MapPath(reviewNo.ImageUrl)) Then reviewNo.Visible = False

                CType(e.Row.Cells(1).FindControl("phdStars"), PlaceHolder).Controls.Add(reviewNo)
            Next
        End If
    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        _UC_DeleteConfirmation.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_DeleteConfirmation.Confirmed
        Dim strMessage As String = ""
        If Not ReviewsBLL._DeleteReview(CShort(litReviewID.Text), strMessage) Then
            _UC_DeleteConfirmation.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RaiseEvent ShowMasterUpdate()
        FinishEditing()
    End Sub
End Class
