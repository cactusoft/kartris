'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

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

Partial Class UserControls_Back_CustomPages

    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    ''' <summary>
    ''' Page load 
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        valRequiredPageName.ValidationGroup = LANG_ELEM_TABLE_TYPE.Pages
        lnkBtnSavePage.ValidationGroup = LANG_ELEM_TABLE_TYPE.Pages

        Dim strPage As String = Request.QueryString("strPage")

        If Not Page.IsPostBack Then
            'We can read querystring if this
            'link comes in from front end admin
            'dropdown menu
            If strPage <> "" Then
                litPageID.Text = GetPageIDFromName(strPage)

                'Default page is a special case, if editing that
                'we want link to go to home page rather than the
                'page.aspx
                If strPage.ToLower = "default" Then
                    hidPageID.Value = CkartrisBLL.WebShopURL & "Default.aspx"
                Else
                    hidPageID.Value = CkartrisBLL.WebShopURL & "Page.aspx?strPage=" & strPage
                End If

                LoadPageFromQueryString(GetPageIDFromName(strPage))
            Else
                'Load list of pages
                LoadPages()
            End If
        End If

        'If GetPageID() = 0 Then
        '    _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Pages, True)
        'Else
        '    _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Pages, False, GetPageID())
        'End If

        If GetPageID() = 0 Then
            ghost_UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.PromotionStrings, True)
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Pages, True)
        Else
            ghost_UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.PromotionStrings, False, GetPageID())
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Pages, False, GetPageID())
        End If
    End Sub

    ''' <summary>
    ''' Loads preview page
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Sub LoadPageFromQueryString(ByVal numPageID As Integer)

        Dim tblPage As DataTable = PagesBLL._GetPageByID(Session("_LANG"), numPageID)
        If tblPage.Rows.Count <> 1 Then Response.Redirect("~/Admin/_CustomPages.aspx")

        Dim rowPage As DataRow = tblPage.Rows(0)

        chkLive.Checked = CkartrisDataManipulation.FixNullFromDB(rowPage("PAGE_Live"))
        txtPageName.Text = CkartrisDataManipulation.FixNullFromDB(rowPage("PAGE_Name"))
        LoadParents(txtPageName.Text)
        ddlParentPage.SelectedValue = CkartrisDataManipulation.FixNullFromDB(rowPage("PAGE_ParentID"))
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.Pages, False, numPageID)

        lnkBtnDeletePage.Visible = True

        'Format preview link URL
        If txtPageName.Text.ToLower = "default" Then 'this is special case, home page
            lnkPreview.NavigateUrl = "~/Default.aspx"
        Else
            'Format link to page, friendly or unfriendly
            If KartSettingsManager.GetKartConfig("general.seofriendlyurls.enabled") = "y" Then
                lnkPreview.NavigateUrl = "~/t-" & txtPageName.Text & ".aspx"
            Else
                lnkPreview.NavigateUrl = "~/Page.aspx?strPage=" & txtPageName.Text
            End If
        End If

        lnkPreview.Visible = True
        phdPagesList.Visible = False

        mvwPage.SetActiveView(viwPageInfo)
        updPageDetails.Update()
    End Sub

    ''' <summary>
    ''' This finds CMS page numeric ID from text name of page
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Private Function GetPageIDFromName(ByVal strPage As String) As String

        Dim tblPages As DataTable = PagesBLL._GetAllNames()

        Dim dvwPages As DataView = tblPages.DefaultView
        dvwPages.RowFilter = "Page_Name = '" & strPage & "'"

        Return dvwPages(0).Item("Page_ID").ToString

    End Function

    ''' <summary>
    ''' Loads list of all custom pages
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Protected Sub LoadPages()
        'Set number of records per page
        'for page turning
        Dim intRowsPerPage As Integer = 25
        Try
            intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
        Catch ex As Exception
            'Stays at 25
        End Try
        gvwPages.PageSize = intRowsPerPage

        mvwCustomPages.SetActiveView(viwPagesData)
        Dim tblPages As DataTable
        tblPages = PagesBLL._GetPages(Session("_LANG"))
        If tblPages.Rows.Count = 0 Then mvwCustomPages.SetActiveView(viwNoPages) : Return
        gvwPages.DataSource = tblPages
        gvwPages.DataBind()

        updPagesList.Update()
    End Sub

    ''' <summary>
    ''' Loads parents
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Protected Sub LoadParents(Optional ByVal strExcludedName As String = "")

        ddlParentPage.Items.Clear()
        ddlParentPage.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_None"), "0"))

        Dim tblParents As DataTable
        tblParents = PagesBLL._GetAllNames()

        ddlParentPage.DataTextField = "Page_Name"
        ddlParentPage.DataValueField = "Page_ID"

        Dim dvwParents As DataView = tblParents.DefaultView
        dvwParents.RowFilter = "Page_Name <> '" & strExcludedName & "'"

        ddlParentPage.DataSource = dvwParents
        ddlParentPage.DataBind()
    End Sub

    'Handle new page link click
    Protected Sub lnkAddPage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAddPage.Click
        PrepareNewPage()
    End Sub

    'Click back to listing
    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack.Click
        BackToPagesList()
    End Sub

    ''' <summary>
    ''' Prepare new page
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Private Sub PrepareNewPage()
        litPageID.Text = "0"
        chkLive.Checked = True
        txtPageName.Text = Nothing
        LoadParents()
        ddlParentPage.SelectedValue = "0"
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.Pages, True)

        lnkBtnDeletePage.Visible = False

        mvwPage.SetActiveView(viwPageInfo)
        updPageDetails.Update()
        phdPagesList.Visible = False
        lnkPreview.Visible = False
    End Sub

    'Get the page ID
    Private Function GetPageID() As Integer
        If IsNumeric(litPageID.Text) Then
            Return CByte(litPageID.Text)
        End If
        litPageID.Text = "0"
        Return 0
    End Function

    ''' <summary>
    ''' Handles clicking of paging buttons
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Protected Sub gvwPages_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwPages.PageIndexChanging
        gvwPages.PageIndex = e.NewPageIndex
        LoadPages()
    End Sub

    ''' <summary>
    ''' Handles clicking 'edit' link on a record
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Protected Sub gvwPages_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwPages.RowCommand
        Try
            gvwPages.SelectedIndex = CInt(e.CommandArgument) Mod gvwPages.PageSize
        Catch ex As Exception
            Return
        End Try
        Select Case e.CommandName
            Case "EditPage"
                mvwPage.SetActiveView(viwPageInfo)
                litPageID.Text = gvwPages.SelectedValue()
                LoadPageInformation()
                updPageDetails.Update()
            Case ""

        End Select
    End Sub

    ''' <summary>
    ''' Loads existing page details for editing
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Private Sub LoadPageInformation()
        chkLive.Checked = CType(gvwPages.SelectedRow.Cells(2).FindControl("chkLive"), CheckBox).Checked
        txtPageName.Text = CType(gvwPages.SelectedRow.Cells(1).FindControl("litPageName"), Literal).Text

        'Default page is a special case, if editing that
        'we want link to go to home page rather than the
        'page.aspx
        If txtPageName.Text.ToLower = "default" Then
            hidPageID.Value = CkartrisBLL.WebShopURL & "Default.aspx"
        Else
            hidPageID.Value = CkartrisBLL.WebShopURL & "Page.aspx?strPage=" & CType(gvwPages.SelectedRow.Cells(1).FindControl("litPageName"), Literal).Text
        End If

        LoadParents(txtPageName.Text)

        ddlParentPage.SelectedValue = CType(gvwPages.SelectedRow.Cells(1).FindControl("litPageParentID"), Literal).Text
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.Pages, False, GetPageID())

        lnkBtnDeletePage.Visible = True
        If KartSettingsManager.GetKartConfig("general.seofriendlyurls.enabled") = "y" Then
            lnkPreview.NavigateUrl = "~/t-" & txtPageName.Text & ".aspx"
        Else
            lnkPreview.NavigateUrl = "~/Page.aspx?strPage=" & txtPageName.Text
        End If
        lnkPreview.Visible = True
        phdPagesList.Visible = False
    End Sub

    ''' <summary>
    ''' Resets page to listing, hides editing fields
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Private Sub BackToPagesList()
        litPageID.Text = ""
        LoadPages()
        mvwPage.SetActiveView(viwPageEmpty)
        phdPagesList.Visible = True
        updPagesList.Update()
        updPageDetails.Update()
    End Sub

    'Handles clicking of cancel button
    Protected Sub lnkBtnCancelPage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancelPage.Click
        BackToPagesList()
    End Sub

    ''' <summary>
    ''' Save button clicked
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Protected Sub lnkBtnSavePage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSavePage.Click
        Page.Validate()
        If Page.IsValid Then
            If SaveChanges() Then
                If GetPageID() = 0 Then
                    BackToPagesList()
                    LoadPages()
                End If
            End If
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_ID") & " -->> " & _
                                          GetGlobalResourceObject("_Kartris", "ContentText_InvalidValue") & " (" & _
                                          GetGlobalResourceObject("_Pages", "ContentText_PageIDMustBeUnique") & ")")
        End If
    End Sub

    'Check if page ID is already in use
    Protected Function IsPageNameExist() As Boolean
        Dim tblNames As DataTable
        tblNames = PagesBLL._GetAllNames()
        Dim rowPages() As DataRow = tblNames.Select("Page_Name = '" & txtPageName.Text & "'")
        If rowPages.Length > 0 Then Return True
        Return False
    End Function

    'Shows confirmations etc. and runs the 'SavePage' function
    'to actually save changes
    Private Function SaveChanges() As Boolean
        If GetPageID() = 0 Then
            '' if new => INSERT
            '' checking if the code number exist or not
            If IsPageNameExist() Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
                Return False
            End If
            If Not SavePage(DML_OPERATION.INSERT) Then Return False
        Else
            '' if update => UPDATE
            If Not SavePage(DML_OPERATION.UPDATE) Then Return False
        End If

        Return True
    End Function

    'Saves a page
    Private Function SavePage(ByVal enumOperation As DML_OPERATION) As Boolean
        Dim tblLanguageContents As New DataTable
        tblLanguageContents = _UC_LangContainer.ReadContent()

        'If tblLanguageContents.Rows(0).Field(0) = "9" Then tblLanguageContents.Rows(0).Field(0) = "1"

        Dim blnLive As Boolean = chkLive.Checked
        Dim strPageName As String = txtPageName.Text
        Dim numParentID As Short = ddlParentPage.SelectedValue

        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.INSERT
                If Not PagesBLL._AddPage(tblLanguageContents, strPageName, numParentID, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.UPDATE
                If Not PagesBLL._UpdatePage(tblLanguageContents, GetPageID(), strPageName, numParentID, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        RaiseEvent ShowMasterUpdate()

        Return True
    End Function

    'Delete a page - handles link click and shows confirmation warning
    Protected Sub lnkBtnDeletePage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeletePage.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    'Delete item if the confirmation is made on the popup
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = Nothing
        Try
            PagesBLL._DeletePage(GetPageID(), strMessage)
            BackToPagesList()
            LoadPages()

            RaiseEvent ShowMasterUpdate()

        Catch ex As Exception
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End Try
    End Sub
End Class
