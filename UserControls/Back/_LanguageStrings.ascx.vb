'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class _LanguageStrings
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        phdMessageError.Visible = False

        If Not Page.IsPostBack Then
            'Set number of records per page
            Dim intRowsPerPage As Integer = 25
            Try
                intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
            Catch ex As Exception
                'Stays at 25
            End Try
            gvwLS.PageSize = intRowsPerPage

            'Not in expert mode
            'Disable 'new' languagestring link
            If KartSettingsManager.GetKartConfig("backend.expertmode") <> "y" Then
                btnNew.Visible = False
            End If

            ddlLanguages.Items.Clear()
            ddlLanguages.DataSource = GetLanguagesFromCache()
            ddlLanguages.DataBind()

            '' Data sent by QueryString
            If Not Request.QueryString("fb") Is Nothing AndAlso _
                Not Request.QueryString("lang") Is Nothing AndAlso _
                Not Request.QueryString("name") Is Nothing Then

                '' Front/Back
                Select Case Request.QueryString("fb")
                    Case "f"
                        chkFront.Checked = True
                    Case "b"
                        chkBack.Checked = True
                    Case Else '' Wrong value
                        Response.Redirect("~/Admin/_LanguageStrings.aspx")
                        Exit Sub
                End Select

                '' Language
                Try
                    ddlLanguages.SelectedValue = Request.QueryString("LANG")
                Catch ex As Exception
                    Response.Redirect("~/Admin/_LanguageStrings.aspx")
                    Exit Sub
                End Try

                '' Name
                txtSearchStarting.Text = Request.QueryString("name")

                ShowNewSearchPanel()
            End If

            SearchLanguageStrings()
        End If

    End Sub

    Private Sub PrepareNewEntry()
        gvwLS.SelectedIndex = -1
        mvwLS.SetActiveView(viwEdit)
        ddlLSFrontBack.SelectedIndex = 0

        ddlLSLanguage.Items.Clear()
        ddlLSLanguage.DataSource = GetLanguagesFromCache()
        ddlLSLanguage.DataTextField = "LANG_BackName"
        ddlLSLanguage.DataValueField = "LANG_ID"
        ddlLSLanguage.DataBind()
        ddlLSLanguage.SelectedValue = CStr(LanguagesBLL.GetDefaultLanguageID())

        ClearTextControls()
        DisableInsertControls()
        phdCheckChange.Visible = True
        ddlLSFrontBack.Focus()
    End Sub

    Private Sub PrepareForEdit(Optional ByVal blnIsDefault As Boolean = True)

        EnableInsertControls()

        ddlLSLanguage.Items.Clear()
        ddlLSLanguage.DataSource = GetLanguagesFromCache()
        ddlLSLanguage.DataBind()
        ddlLSLanguage.SelectedValue = CByte(gvwLS.SelectedDataKey("LS_LANGID"))

        phdCheckChange.Visible = False
        txtLSVirtualPath.Enabled = blnIsDefault
        txtLSClassName.Enabled = blnIsDefault

        Dim tblLS As DataTable = _
        LanguageStringsBLL._GetByID( _
                    CByte(gvwLS.SelectedDataKey("LS_LANGID")), _
                    CChar(gvwLS.SelectedDataKey("LS_FrontBack")), _
                    CStr(gvwLS.SelectedDataKey("LS_Name")))

        ddlLSFrontBack.SelectedValue = FixNullFromDB(tblLS.Rows(0)("LS_FrontBack"))
        txtLSName.Text = FixNullFromDB(tblLS.Rows(0)("LS_Name"))
        txtLSValue.Text = FixNullFromDB(tblLS.Rows(0)("LS_Value"))
        txtLSDefaultValue.Text = FixNullFromDB(tblLS.Rows(0)("LS_DefaultValue"))
        txtLSDesc.Text = FixNullFromDB(tblLS.Rows(0)("LS_Description"))
        txtLSVirtualPath.Text = FixNullFromDB(tblLS.Rows(0)("LS_VirtualPath"))
        txtLSClassName.Text = FixNullFromDB(tblLS.Rows(0)("LS_ClassName"))

        'Not in expert mode
        'Disable some fields (they are also hidden within the user control ascx)
        If KartSettingsManager.GetKartConfig("backend.expertmode") <> "y" Then
            txtLSName.Enabled = False
            txtLSDefaultValue.Enabled = False
            txtLSDesc.Enabled = False
            txtLSVirtualPath.Enabled = False
            txtLSClassName.Enabled = False

        End If

    End Sub

    Private Sub ClearTextControls()
        txtLSName.Text = String.Empty
        txtLSValue.Text = String.Empty
        txtLSDefaultValue.Text = String.Empty
        txtLSDesc.Text = String.Empty
        txtLSVirtualPath.Text = String.Empty
        txtLSClassName.Text = String.Empty
    End Sub

    Private Sub EnableInsertControls()
        phdNameAlreadyExists.Visible = False
        litPleaseEnterValue.Visible = False
        lnkBtnLSCheckName.Visible = False
        lnkBtnLSChangeName.Visible = True

        ddlLSFrontBack.Enabled = False
        txtLSName.ReadOnly = True

        txtLSValue.Enabled = True
        txtLSDefaultValue.Enabled = True
        txtLSDesc.Enabled = True
        txtLSVirtualPath.Enabled = True
        txtLSClassName.Enabled = True

        txtLSValue.Focus()
    End Sub

    Private Sub DisableInsertControls()

        phdNameAlreadyExists.Visible = False
        litPleaseEnterValue.Visible = False
        lnkBtnLSCheckName.Visible = True
        lnkBtnLSChangeName.Visible = False

        ddlLSFrontBack.Enabled = True
        txtLSName.ReadOnly = False

        txtLSValue.Enabled = False
        txtLSDefaultValue.Enabled = False
        txtLSDesc.Enabled = False
        txtLSVirtualPath.Enabled = False
        txtLSClassName.Enabled = False

    End Sub

    Private Sub SearchLanguageStrings(Optional ByVal pIndx As Integer = 0)

        Dim strSearchBy As String = ddlSearchBy.SelectedValue
        Dim strSearchKey As String = txtSearchStarting.Text
        Dim numLangID As Byte = CByte(ddlLanguages.SelectedValue)
        Dim strFrontBack As String = ""
        If chkFront.Checked AndAlso (Not chkBack.Checked) Then
            strFrontBack = "f"
        ElseIf chkBack.Checked AndAlso (Not chkFront.Checked) Then
            strFrontBack = "b"
        Else
            strFrontBack = ""
        End If

        Dim tblLS As New DataTable
        tblLS = LanguageStringsBLL._Search(strSearchBy, strSearchKey, strFrontBack, numLangID)

        If tblLS.Rows.Count = 0 Then
            mvwLS.SetActiveView(viwNoResult)
        Else

            gvwLS.DataSource = tblLS
            gvwLS.DataBind()

            mvwLS.SetActiveView(viwResult)
        End If
    End Sub

    Private Sub ShowNewSearchPanel()
        pnlFind.Visible = False
        pnlNewSearch.Visible = True
    End Sub

    Protected Sub lnkBtnBack_Click() Handles lnkBtnBack.Click
        ClearTextControls()
        DisableInsertControls()
        mvwLS.SetActiveView(viwResult)
    End Sub

    Private Function IsLSExist() As Boolean

        Dim chrFB As Char = CChar(ddlLSFrontBack.SelectedValue)
        Dim numLang As Byte = CByte(ddlLSLanguage.SelectedValue)
        Dim strLSName As String = CStr(txtLSName.Text)

        If LanguageStringsBLL._GetByID(numLang, chrFB, strLSName).Rows.Count <> 0 Then
            Return True 'Exist already
        End If

        Return False
    End Function

    Private Sub ViewFromEdit()
        txtSearchStarting.Text = txtLSName.Text
        chkBack.Checked = (ddlLSFrontBack.SelectedValue = "b")
        chkFront.Checked = (ddlLSFrontBack.SelectedValue = "f")
        ddlLanguages.SelectedValue = ddlLSLanguage.SelectedValue
        ddlSearchBy.SelectedValue = "Name"
        SearchLanguageStrings()
    End Sub

    Protected Sub gridViewLS_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwLS.PageIndexChanging
        gvwLS.PageIndex = e.NewPageIndex
        SearchLanguageStrings()
    End Sub

    Protected Sub gridViewLS_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvwLS.SelectedIndexChanged
        If gvwLS.SelectedIndex = -1 Then Return
        PrepareForEdit( _
            CByte(gvwLS.SelectedDataKey("LS_LANGID")) = LanguagesBLL.GetDefaultLanguageID())
        mvwLS.SetActiveView(viwEdit)
    End Sub

    Private Sub SaveChanges(ByVal enumOperation As DML_OPERATION)

        Dim chrFB As Char = "", numLanguageID As Byte
        Dim strName As String = "", strValue As String = "", strDesc As String = "", strDefaultValue As String = ""
        Dim strClassName As String = "", strVirtualPath As String = "", strMessage As String = ""

        chrFB = CChar(ddlLSFrontBack.SelectedValue)
        numLanguageID = CByte(ddlLSLanguage.SelectedValue)
        strName = txtLSName.Text
        strValue = txtLSValue.Text
        strDefaultValue = txtLSDefaultValue.Text
        strDesc = txtLSDesc.Text
        strVirtualPath = txtLSVirtualPath.Text
        strClassName = txtLSClassName.Text

        Select Case enumOperation
            Case DML_OPERATION.INSERT
                If Not LanguageStringsBLL._AddLanguageString( _
                        numLanguageID, chrFB, strName, strValue, strDesc, strDefaultValue, _
                        strVirtualPath, strClassName, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    phdMessageError.Visible = True
                    Exit Sub
                End If
            Case DML_OPERATION.UPDATE
                If Not LanguageStringsBLL._UpdateLanguageString( _
                        numLanguageID, chrFB, strName, strValue, strDesc, strDefaultValue, _
                        strVirtualPath, strClassName, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    phdMessageError.Visible = True
                    Exit Sub
                Else
                    LanguageStringProviders.Refresh()
                End If
        End Select



        RaiseEvent ShowMasterUpdate()
        ViewFromEdit()

    End Sub

    Protected Sub btnNewSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnNewSearch.Click
        Response.Redirect("~/Admin/_LanguageStrings.aspx")
    End Sub

    Protected Sub btnFind_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFind.Click
        SearchLanguageStrings()
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClear.Click
        txtSearchStarting.Text = String.Empty
        SearchLanguageStrings()
    End Sub

    Protected Sub btnNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnNew.Click
        PrepareNewEntry()
    End Sub

    Protected Sub lnkBtnLSCheckName_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnLSCheckName.Click
        If txtLSName.Text = "" Then Exit Sub
        If Not IsLSExist() Then
            EnableInsertControls()
        Else
            phdNameAlreadyExists.Visible = True
        End If
    End Sub

    Protected Sub lnkBtnLSChangeName_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnLSChangeName.Click
        DisableInsertControls()
    End Sub

    Protected Sub lnkBtnViewLSName_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnViewLSName.Click
        ViewFromEdit()
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        If gvwLS.SelectedIndex = -1 Then
            SaveChanges(DML_OPERATION.INSERT)
        Else
            SaveChanges(DML_OPERATION.UPDATE)
        End If
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        ClearTextControls()
        DisableInsertControls()
        mvwLS.SetActiveView(viwResult)
    End Sub

End Class
