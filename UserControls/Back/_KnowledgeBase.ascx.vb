'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

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

Partial Class UserControls_Back_KnowledgeBase
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        valCreationDate.ValidationGroup = LANG_ELEM_TABLE_TYPE.KnowledgeBase
        valUpdateDate.ValidationGroup = LANG_ELEM_TABLE_TYPE.KnowledgeBase
        lnkBtnSaveKB.ValidationGroup = LANG_ELEM_TABLE_TYPE.KnowledgeBase

        Dim strKB_ID As String = Request.QueryString("kb")


        If Not Page.IsPostBack Then
            'Set number of records per page
            Dim intRowsPerPage As Integer = 25
            Try
                intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
            Catch ex As Exception
                'Stays at 25
            End Try
            gvwKB.PageSize = intRowsPerPage

            LoadKB()

            'We can read querystring if this
            'link comes in from front end admin
            'dropdown menu
            If strKB_ID <> "" Then
                litKBID.Text = strKB_ID
                hidKBID.Value = CkartrisBLL.WebShopURL & "Knowledgebase.aspx?kb=" & strKB_ID
                mvwKB.SetActiveView(viwKBInfo)
                LoadKBInformationByID(strKB_ID)
                updKBDetails.Update()
            End If
        End If

        If GetKBID() = 0 Then
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.KnowledgeBase, True)
        Else
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.KnowledgeBase, False, GetKBID())
        End If

    End Sub

    Protected Sub LoadKB()
        mvwKBs.SetActiveView(viwKBList)
        Dim tblKB As DataTable
        tblKB = KBBLL._GetKB(Session("_LANG"))
        Dim dvwKB As DataView = tblKB.DefaultView
        If Not String.IsNullOrEmpty(txtSearchKBID.Text) Then
            dvwKB.RowFilter = "KB_ID=" & CLng(txtSearchKBID.Text)
        End If
        If dvwKB.Count = 0 Then mvwKBs.SetActiveView(viwNoKB) : Return
        gvwKB.DataSource = dvwKB
        gvwKB.DataBind()
        updKBList.Update()
    End Sub

    Protected Sub lnkAddKB_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAddKB.Click
        PrepareNewKB()
    End Sub

    Private Sub PrepareNewKB()
        litKBID.Text = "0"
        chkLive.Checked = True
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.KnowledgeBase, True)
        calCreationDate.SelectedDate = CkartrisDisplayFunctions.NowOffset
        calUpdateDate.SelectedDate = CkartrisDisplayFunctions.NowOffset

        lnkBtnDeleteKB.Visible = False

        mvwKB.SetActiveView(viwKBInfo)
        updKBDetails.Update()
        phdKBList.Visible = False
        lnkPreview.Visible = False
    End Sub

    Private Function GetKBID() As Integer
        If IsNumeric(litKBID.Text) Then
            Return CByte(litKBID.Text)
        End If
        litKBID.Text = "0"
        Return 0
    End Function


    Protected Sub gvwKB_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwKB.RowCommand

        Try
            gvwKB.SelectedIndex = CInt(e.CommandArgument) Mod gvwKB.PageSize
        Catch ex As Exception
            Return
        End Try
        Select Case e.CommandName
            Case "EditKB"
                mvwKB.SetActiveView(viwKBInfo)
                litKBID.Text = gvwKB.SelectedValue()
                hidKBID.Value = CkartrisBLL.WebShopURL & "Knowledgebase.aspx?kb=" & gvwKB.SelectedValue()
                LoadKBInformation()
                updKBDetails.Update()
            Case ""

        End Select
    End Sub

    Private Sub LoadKBInformation()
        chkLive.Checked = CType(gvwKB.SelectedRow.Cells(2).FindControl("chkLive"), CheckBox).Checked

        txtCreationDate.Text = CDate(CType(gvwKB.SelectedRow.Cells(3).FindControl("litDateCreatedNumeric"), Literal).Text).ToString("yyyy/MM/dd")
        txtUpdateDate.Text = CkartrisDisplayFunctions.NowOffset.Date.ToString("yyyy/MM/dd")
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.KnowledgeBase, False, GetKBID())

        lnkBtnDeleteKB.Visible = True

        lnkPreview.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Knowledgebase, GetKBID)

        lnkPreview.Visible = True
        phdKBList.Visible = False
    End Sub

    Private Sub LoadKBInformationByID(ByVal numKB_ID As Integer)
        Dim tblKB As DataTable
        tblKB = KBBLL._GetKB(Session("_LANG"))
        Dim dvwKB As DataView = tblKB.DefaultView
        If Not String.IsNullOrEmpty(numKB_ID) Then
            dvwKB.RowFilter = "KB_ID=" & CLng(numKB_ID)
        End If
        If dvwKB.Count = 0 Then mvwKBs.SetActiveView(viwNoKB) : Return
        gvwKB.DataSource = dvwKB
        gvwKB.DataBind()

        chkLive.Checked = CType(gvwKB.Rows(0).Cells(2).FindControl("chkLive"), CheckBox).Checked

        txtCreationDate.Text = CDate(CType(gvwKB.Rows(0).Cells(3).FindControl("litDateCreatedNumeric"), Literal).Text).ToString("yyyy/MM/dd")
        txtUpdateDate.Text = CDate(CType(gvwKB.Rows(0).Cells(4).FindControl("litLastUpdatedNumeric"), Literal).Text).ToString("yyyy/MM/dd")

        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.KnowledgeBase, False, GetKBID())

        lnkBtnDeleteKB.Visible = True
        
        lnkPreview.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Knowledgebase, numKB_ID)


        lnkPreview.Visible = True
        phdKBList.Visible = False

        updKBList.Update()
    End Sub

    Private Sub BackToKBList()
        litKBID.Text = ""
        mvwKB.SetActiveView(viwKBEmpty)
        phdKBList.Visible = True
        updKBList.Update()
        updKBDetails.Update()
    End Sub

    Protected Sub lnkBtnCancelKB_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancelKB.Click
        BackToKBList()
    End Sub

    Protected Sub lnkBtnSaveKB_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveKB.Click
        Page.Validate()
        If Page.IsValid Then
            If SaveChanges() Then
                If GetKBID() = 0 Then
                    BackToKBList()
                    LoadKB()
                End If
            End If
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ID") & " -->> " & _
                                          GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue") & " (" & _
                                          GetGlobalResourceObject("_KB", "ContentText_KBIDMustBeUnique") & ")")
        End If
    End Sub

    Private Function SaveChanges() As Boolean
        If GetKBID() = 0 Then
            '' if new => INSERT
            If Not SaveKB(DML_OPERATION.INSERT) Then Return False
        Else
            '' if update => UPDATE
            If Not SaveKB(DML_OPERATION.UPDATE) Then Return False
        End If

        Return True
    End Function

    Private Function SaveKB(ByVal enumOperation As DML_OPERATION) As Boolean
        Dim tblLanguageContents As New DataTable
        tblLanguageContents = _UC_LangContainer.ReadContent()

        Dim blnLive As Boolean = chkLive.Checked
        Dim datCreated As Date = CDate(txtCreationDate.Text)
        Dim datUpdated As Date = CDate(txtUpdateDate.Text)

        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.INSERT
                If Not KBBLL._AddKB(tblLanguageContents, datCreated, datUpdated, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.UPDATE
                If Not KBBLL._UpdateKB(tblLanguageContents, GetKBID(), datCreated, datUpdated, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        RaiseEvent ShowMasterUpdate()

        Return True
    End Function

    Protected Sub lnkBtnDeleteKB_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteKB.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = Nothing

        If Not KBBLL._DeleteKB(GetKBID(), strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            BackToKBList()
            LoadKB()
            RaiseEvent ShowMasterUpdate()

        End If
    End Sub


    Protected Sub gvwKB_SelectedIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSelectEventArgs) Handles gvwKB.SelectedIndexChanging
        gvwKB.PageIndex = e.NewSelectedIndex
        LoadKB()
    End Sub
    Protected Sub gvwKB_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwKB.PageIndexChanging
        gvwKB.PageIndex = e.NewPageIndex
        LoadKB()
    End Sub

    Protected Sub btnFind_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFind.Click
        LoadKB()
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClear.Click
        txtSearchKBID.Text = Nothing
        LoadKB()
    End Sub
End Class
