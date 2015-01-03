'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisEnumerations
Imports KartSettingsManager

Partial Class UserControls_Back_SiteNews

    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        valCreationDate.ValidationGroup = LANG_ELEM_TABLE_TYPE.News
        lnkBtnSaveNews.ValidationGroup = LANG_ELEM_TABLE_TYPE.News
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.News

        Dim strNewsID As String = Request.QueryString("NewsID")

        If Not Page.IsPostBack Then
            LoadNews()

            'We can read querystring if this
            'link comes in from front end admin
            'dropdown menu
            If strNewsID <> "" Then
                litNewsID.Text = strNewsID
                hidNewsID.Value = CkartrisBLL.WebShopURL & "News.aspx?NewsID=" & strNewsID
                mvwNewsList.SetActiveView(viwNewsInfo)
                LoadNewsInformationByID(strNewsID)
                updNewsList.Update()
            End If
        End If

        If GetNewsID() = 0 Then
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.News, True)
        Else
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.News, False, GetNewsID())
        End If
    End Sub

    Protected Sub LoadNews()
        mvwSiteNews.SetActiveView(viwNewsData)
        Dim dvwNews As DataView = NewsBLL._GetSummaryNews(Session("_LANG"))
        If dvwNews.Count = 0 Then mvwSiteNews.SetActiveView(viwNoNews) : Return
        gvwNews.DataSource = dvwNews
        gvwNews.DataBind()
    End Sub

    Protected Sub lnkAddNews_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAddNews.Click
        PrepareNewSiteNews()
    End Sub

    Private Sub PrepareNewSiteNews()
        litNewsID.Text = "0"
        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.News, True)
        calDate.SelectedDate = CkartrisDisplayFunctions.NowOffset
        lnkBtnDeleteNews.Visible = False
        lnkPreview.Visible = False

        mvwNewsList.SetActiveView(viwNewsInfo)
        updNewsList.Update()
    End Sub

    Private Function GetNewsID() As Integer
        If IsNumeric(litNewsID.Text) Then
            Return CByte(litNewsID.Text)
        End If
        litNewsID.Text = "0"
        Return 0
    End Function

    Protected Sub gvwNews_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwNews.PageIndexChanging
        gvwNews.PageIndex = e.NewPageIndex
        LoadNews()
    End Sub

    Protected Sub gvwNews_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwNews.RowCommand
        Try
            gvwNews.SelectedIndex = CInt(e.CommandArgument) Mod gvwNews.PageSize
        Catch ex As Exception
            Return
        End Try
        Select Case e.CommandName
            Case "EditNews"
                mvwNewsList.SetActiveView(viwNewsInfo)
                litNewsID.Text = gvwNews.SelectedValue()
                hidNewsID.Value = CkartrisBLL.WebShopURL & "News.aspx?NewsID=" & gvwNews.SelectedValue()
                LoadNewsInformation()
                updNewsList.Update()
            Case ""

        End Select
    End Sub

    Private Sub LoadNewsInformation()
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.News, False, GetNewsID())
        Try
            calDate.SelectedDate = CDate(CType(gvwNews.SelectedRow.Cells(3).FindControl("hidDateCreated"), HiddenField).Value)
        Catch ex As Exception
        End Try
        lnkBtnDeleteNews.Visible = True
        lnkPreview.NavigateUrl = "~/News.aspx?NewsID=" & GetNewsID()
        lnkPreview.Visible = True
    End Sub

    Private Sub LoadNewsInformationByID(ByVal numNewsID As Integer)

        mvwSiteNews.SetActiveView(viwNewsData)
        Dim dvwNews As DataView = NewsBLL._GetSummaryNews(Session("_LANG"))

        If Not String.IsNullOrEmpty(numNewsID) Then
            dvwNews.RowFilter = "N_ID=" & CLng(numNewsID)
        End If

        If dvwNews.Count = 0 Then mvwSiteNews.SetActiveView(viwNoNews) : Return
        gvwNews.DataSource = dvwNews
        gvwNews.DataBind()

        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.News, False, GetNewsID())
        Try
            calDate.SelectedDate = CDate(CType(gvwNews.Rows(0).Cells(3).FindControl("hidDateCreated"), HiddenField).Value)
        Catch ex As Exception
        End Try
        lnkBtnDeleteNews.Visible = True
        lnkPreview.NavigateUrl = "~/News.aspx?NewsID=" & GetNewsID()
        lnkPreview.Visible = True
    End Sub

    Private Sub BackToNewsList()
        litNewsID.Text = ""
        LoadNews()
        mvwNewsList.SetActiveView(viwList)
        updNewsList.Update()
    End Sub

    'Click back to listing
    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack.Click
        Response.Redirect("_SiteNews.aspx")
    End Sub

    Protected Sub lnkBtnCancelNews_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancelNews.Click
        BackToNewsList()
    End Sub

    Protected Sub lnkBtnSaveNews_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveNews.Click
        Try
            If CDate(txtCreationDate.Text) > CkartrisDisplayFunctions.NowOffset Then
                Throw New ApplicationException()
            End If
        Catch ex As Exception
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_NotValidDate"))
            Exit Sub
        End Try
        If SaveChanges() Then BackToNewsList() : LoadNews()
    End Sub

    Private Function SaveChanges() As Boolean
        If GetNewsID() = 0 Then
            '' if new => INSERT
            If Not SaveNews(DML_OPERATION.INSERT) Then Return False
        Else
            '' if update => UPDATE
            If Not SaveNews(DML_OPERATION.UPDATE) Then Return False
        End If
        Return True
    End Function

    Private Function SaveNews(ByVal enumOperation As DML_OPERATION) As Boolean
        Dim tblLanguageContetns As New DataTable
        tblLanguageContetns = _UC_LangContainer.ReadContent()

        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.INSERT
                If Not NewsBLL._AddNews(tblLanguageContetns, CDate(txtCreationDate.Text), strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.UPDATE
                If Not NewsBLL._UpdateNews(tblLanguageContetns, CDate(txtCreationDate.Text), GetNewsID(), strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select
        RefreshSiteNewsCache()
        RaiseEvent ShowMasterUpdate()
        Return True
    End Function

    Protected Sub lnkBtnDeleteNews_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteNews.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = Nothing
        If NewsBLL._DeleteNews(GetNewsID(), strMessage) Then
            RefreshSiteNewsCache()
            LoadNews() : BackToNewsList()
            RaiseEvent ShowMasterUpdate()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If

    End Sub
End Class
