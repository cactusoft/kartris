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
Imports CkartrisEnumerations
Imports KartSettingsManager
Imports System.Linq

Partial Class UserControls_Back_SiteLanguages

    Inherits System.Web.UI.UserControl
    Public Event ShowMasterUpdate()
    Public Event NeedCategoryRefresh()

    'Set folder for country flag icons
    Dim strLanguageImages As String = "~/Images/Languages/"

    ''' <summary> 
    ''' Page Load - load language and set skin and masterpage selection dropdowns 
    ''' </summary> 
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            SetThemeDropDown()
            LoadLanguages()
        End If
    End Sub

    ''' <summary> 
    ''' Handles update
    ''' </summary> 
    Protected Sub gvwLanguages_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwLanguages.RowCommand
        If e.CommandName = "CreateNewLanguage" Then
            PrepareNewLanguage()
            phdLanguageDetails.Visible = True
            updLanguage.Update()
        ElseIf e.CommandName = "FixElements" Then
            If litFullElemetsLanguageID.Text > 0 Then
                Dim strMessage As String = Nothing
                If Not LanguageElementsBLL._FixLanguageElements(litFullElemetsLanguageID.Text, e.CommandArgument, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                Else
                    LoadLanguages()
                    RaiseEvent ShowMasterUpdate()
                End If
            End If
        ElseIf e.CommandName = "FixStrings" Then
            If litFullStringsLanguageID.Text > 0 Then
                Dim strMessage As String = Nothing
                If Not LanguageStringsBLL._FixLanguageStrings(litFullStringsLanguageID.Text, e.CommandArgument, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                Else
                    LoadLanguages()
                    RaiseEvent ShowMasterUpdate()
                End If
            End If
        End If
    End Sub

    ''' <summary> 
    ''' Sets up language image
    ''' </summary> 
    Protected Sub gvwLanguages_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwLanguages.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            CType(e.Row.Cells(2).FindControl("phdImageNotExist"), PlaceHolder).Visible = True
            CType(e.Row.Cells(2).FindControl("phdImageExist"), PlaceHolder).Visible = False
            Dim strImageName As String = CType(e.Row.Cells(2).FindControl("litImageName"), Literal).Text '& ".gif"
            Dim dirLanguageImages As New DirectoryInfo(Server.MapPath(strLanguageImages))
            For Each objFile As FileInfo In dirLanguageImages.GetFiles()
                If objFile.Name.StartsWith(strImageName & ".") Then
                    CType(e.Row.Cells(2).FindControl("imgLanguage"), Image).ImageUrl = strLanguageImages & objFile.Name & "?nocache=" & Now.ToBinary
                    CType(e.Row.Cells(2).FindControl("phdImageExist"), PlaceHolder).Visible = True
                    CType(e.Row.Cells(2).FindControl("phdImageNotExist"), PlaceHolder).Visible = False
                    Exit For
                End If
            Next
        End If
    End Sub

    Protected Sub _UC_UploaderPopup_NeedCategoryRefresh() Handles _UC_UploaderPopup.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    ''' <summary> 
    ''' Handles file upload for language image 
    ''' </summary> 
    Protected Sub _UC_UploaderPopupUploadClicked() Handles _UC_UploaderPopup.UploadClicked
        If _UC_UploaderPopup.HasFile() AndAlso _
           Not String.IsNullOrEmpty(litImageStatus.Text) AndAlso litImageStatus.Text <> "none" AndAlso _
           Not String.IsNullOrEmpty(litImageName.Text) AndAlso litImageName.Text <> "none" Then

            Dim strImageName As String = litImageName.Text
            Dim dirLanguageImages As New DirectoryInfo(Server.MapPath(strLanguageImages))
            For Each objFile As FileInfo In dirLanguageImages.GetFiles()
                If objFile.Name.StartsWith(strImageName & ".") Then
                    File.Delete(Server.MapPath(strLanguageImages & objFile.Name))
                End If
            Next

            Dim strFileName As String = litImageName.Text & Right(_UC_UploaderPopup.FileName(), 4)
            litImageStatus.Text = "none" : litImageName.Text = "none"
            Dim strUploadFolder As String = strLanguageImages
            If Not Directory.Exists(Server.MapPath(strUploadFolder)) Then Directory.CreateDirectory(Server.MapPath(strUploadFolder))
            Dim strSavedPath As String = strUploadFolder & strFileName
            _UC_UploaderPopup.SaveFile(Server.MapPath(strSavedPath))
            If Not File.Exists(Server.MapPath(strSavedPath)) Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, "File Not Saved !!")
                Return
            Else
                File.SetAttributes(Server.MapPath(strSavedPath), FileAttributes.Normal)
                LoadLanguage(GetLanguageID)
            End If
        End If
    End Sub

    ''' <summary> 
    ''' Handles language selected 
    ''' </summary> 
    Protected Sub gvwLanguages_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvwLanguages.SelectedIndexChanged
        LoadLanguage(CByte(gvwLanguages.SelectedValue()))
        phdLanguageDetails.Visible = True
        updLanguage.Update()
    End Sub

    ''' <summary> 
    ''' Fills skin dropdown from contents of 'Skins' folder'
    ''' For legacy reasons, it uses the term 'theme' instead
    ''' of 'skin'
    ''' </summary> 
    Sub SetThemeDropDown()
        Dim blnSkip As Boolean

        ddlTheme.Items.Clear()
        ddlTheme.Items.Add(New ListItem("-", ""))

        Dim dirThemes As New DirectoryInfo(Server.MapPath("~/Skins"))
        If dirThemes.Exists Then
            For Each dirTheme As DirectoryInfo In dirThemes.GetDirectories
                blnSkip = False
                If (dirTheme.Name.ToLower = ("admin")) Then blnSkip = True 'skip admin theme
                If (dirTheme.Name.ToLower = ("invoice")) Then blnSkip = True 'skip invoice theme
                If blnSkip = False Then
                    ddlTheme.Items.Add(New ListItem(dirTheme.Name, dirTheme.Name))
                End If
            Next
        End If

    End Sub

    ''' <summary> 
    ''' When skin selection changed, refresh masterpage dropdown
    ''' </summary> 
    Protected Sub ddlTheme_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlTheme.SelectedIndexChanged
        SetMasterDropDown()
        updLanguage.Update()
    End Sub

    ''' <summary> 
    ''' Fills masterpage dropdown from contents of the
    ''' selected skin folder
    ''' </summary> 
    Sub SetMasterDropDown()
        Dim blnSkip As Boolean

        'Let's start with empty menu
        ddlMasterPage.Items.Clear()

        'Add the "-" default selection
        ddlMasterPage.Items.Add(New ListItem("-", ""))

        'If a skin is selected...
        If ddlTheme.SelectedValue <> "" Then
            Try
                'Try to format a list of masterpages
                'from the files within the selected skin
                Dim dirMasterPages As New DirectoryInfo(Server.MapPath("~/Skins/" & ddlTheme.SelectedValue))
                If dirMasterPages.Exists Then

                    For Each filMasterPage As FileInfo In dirMasterPages.GetFiles
                        blnSkip = False

                        'We want to exclude an invoice skin, or files
                        'that are not .master
                        If (filMasterPage.Name.ToLower.StartsWith("invoice.")) Then blnSkip = True 'skip invoice master
                        If Not (filMasterPage.Name.ToLower.EndsWith(".master")) Then blnSkip = True 'skip any file that is not a master (including .vb)
                        If blnSkip = False Then
                            ddlMasterPage.Items.Add(New ListItem(filMasterPage.Name, filMasterPage.Name))
                        End If
                    Next
                    'Good if we get to here, activate
                    'the masterpage menu
                    ddlMasterPage.Enabled = True
                Else
                    'Selected skin folder does not exist
                    '(this should not be possible unless it was deleted
                    'after the present page was served)
                    ddlMasterPage.Enabled = False
                End If
            Catch ex As Exception
                'Some error, disable the masterpage menu
                ddlMasterPage.Enabled = False
            End Try
        Else
            'No skin selected, so cannot choose
            'a masterpage
            ddlMasterPage.Enabled = False
        End If

    End Sub

    ''' <summary> 
    ''' Reset language form
    ''' </summary> 
    Private Sub PrepareNewLanguage()
        gvwLanguages.Visible = False

        litLanguageID.Text = "0"
        chkIsDefault.Checked = False

        txtBackName.Text = Nothing
        txtFrontName.Text = Nothing
        txtEmailOrders.Text = Nothing
        txtEmailContact.Text = Nothing
        txtReplayEmail.Text = Nothing
        txtDateFormat.Text = "d MMM yy"
        txtDateTimeFormat.Text = "d MMM yy, HH:mm"
        chkFrontLive.Checked = Nothing
        chkBackLive.Checked = Nothing
        txtLanguageCulture.Text = "xx-XX"
        txtLanguageUICulture.Text = "xx"
        txtMaster.Text = Nothing
        txtTheme.Text = Nothing

        phdImageExist.Visible = False
        phdImageNotExist.Visible = True

        SetMasterDropDown()
    End Sub

    ''' <summary> 
    ''' Load languages from database
    ''' </summary> 
    Private Sub LoadLanguages()
        '' Total Elements ----------------------------------------------
        Dim tblTotalElements As DataTable = LanguageElementsBLL._GetTotalsPerLanguage()
        Dim numMaxTotalElements = (From Total In tblTotalElements _
                           Select Total.Item("Total")).Max()

        Dim numLangFullElemets As Byte = 0
        For Each row As DataRow In tblTotalElements.Rows
            If row("Total") = numMaxTotalElements Then
                numLangFullElemets = row("ID")
                Exit For
            End If
        Next
        litFullElemetsLanguageID.Text = numLangFullElemets

        '' Total Strings ----------------------------------------------
        Dim tblTotalStrings As DataTable = LanguageStringsBLL._GetTotalsPerLanguage()
        Dim numMaxTotalStrings = (From Total In tblTotalStrings _
                                  Select Total.Item("Total")).Max()

        Dim numLangFullStrings As Byte = 0
        For Each row As DataRow In tblTotalStrings.Rows
            If row("Total") = numMaxTotalStrings Then
                numLangFullStrings = row("ID")
                Exit For
            End If
        Next
        litFullStringsLanguageID.Text = numLangFullStrings


        Dim tblLanguages As DataTable = GetLanguagesFromCache()
        Try
            tblLanguages.Columns.Remove("MissingElements")
            tblLanguages.Columns.Remove("NeedFixElements")
            tblLanguages.Columns.Remove("MissingStrings")
            tblLanguages.Columns.Remove("NeedFixStrings")
        Catch ex As Exception
        End Try
        tblLanguages.Columns.Add(New DataColumn("MissingElements", Type.GetType("System.String")))
        tblLanguages.Columns.Add(New DataColumn("NeedFixElements", Type.GetType("System.Boolean")))
        tblLanguages.Columns.Add(New DataColumn("MissingStrings", Type.GetType("System.String")))
        tblLanguages.Columns.Add(New DataColumn("NeedFixStrings", Type.GetType("System.Boolean")))

        For Each row As DataRow In tblLanguages.Rows
            Dim numLanguageID As Byte = row("LANG_ID")
            '' Elements
            Dim numTotalElements = From Total In tblTotalElements _
                           Where Total.Item("ID") = numLanguageID _
                           Select Total.Item("Total")
            If numMaxTotalElements - numTotalElements(0) = 0 Then
                row("MissingElements") = "-"
                row("NeedFixElements") = False
            Else
                row("MissingElements") = numMaxTotalElements - numTotalElements(0)
                row("NeedFixElements") = True
            End If

            '' Strings
            Dim numTotalStrings = From Total In tblTotalStrings _
                           Where Total.Item("ID") = numLanguageID _
                           Select Total.Item("Total")
            If numMaxTotalStrings - numTotalStrings(0) = 0 Then
                row("MissingStrings") = "-"
                row("NeedFixStrings") = False
            Else
                row("MissingStrings") = numMaxTotalStrings - numTotalStrings(0)
                row("NeedFixStrings") = True
            End If
        Next

        gvwLanguages.DataSource = tblLanguages
        gvwLanguages.DataBind()
        gvwLanguages.Visible = True
        updLanguages.Update()
    End Sub

    ''' <summary> 
    ''' Load single language
    ''' </summary> 
    Private Sub LoadLanguage(ByVal LanguageID As Byte)

        gvwLanguages.Visible = False

        Dim drwLanguage As DataRow() = LanguagesBLL._GetByLanguageID(LanguageID)

        litLanguageID.Text = CStr(LanguageID)
        chkIsDefault.Checked = (LanguagesBLL.GetDefaultLanguageID() = LanguageID)

        txtBackName.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_BackName")))
        txtFrontName.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_FrontName")))
        txtEmailOrders.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_EmailTo")))
        txtEmailContact.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_EmailToContact")))
        txtReplayEmail.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_EmailFrom")))
        txtDateFormat.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_DateFormat")))
        txtDateTimeFormat.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_DateAndTimeFormat")))
        chkFrontLive.Checked = CBool(drwLanguage(0)("LANG_LiveFront"))
        chkBackLive.Checked = CBool(drwLanguage(0)("LANG_LiveBack"))
        txtLanguageCulture.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_Culture")))
        txtLanguageUICulture.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_UICulture")))

        litCulture.Text = CStr(FixNullFromDB(drwLanguage(0)("LANG_Culture")))

        phdImageExist.Visible = False
        phdImageNotExist.Visible = True

        Dim strImageName As String = litCulture.Text
        Dim dirLanguageImages As New DirectoryInfo(Server.MapPath(strLanguageImages))
        For Each objFile As FileInfo In dirLanguageImages.GetFiles()
            If objFile.Name.StartsWith(strImageName & ".") Then
                imgLanguage.ImageUrl = strLanguageImages & objFile.Name & "?nocache=" & Now.ToBinary
                phdImageExist.Visible = True
                phdImageNotExist.Visible = False
                Exit For
            End If
        Next

        'Set skin dropdown
        Try
            ddlTheme.SelectedValue = CStr(FixNullFromDB(drwLanguage(0)("LANG_Theme")))
        Catch ex As Exception
            'Ignore
        End Try

        'Need to form the masterpage dropdown, do it here
        'because we need to set the skin first above before
        'this will work first time out
        SetMasterDropDown()

        'Set master page dropdown
        Try
            ddlMasterPage.SelectedValue = CStr(FixNullFromDB(drwLanguage(0)("LANG_Master")))
        Catch ex As Exception
            'Ignore
        End Try

        'Not in expert mode
        'Disable 'new' config setting link
        If KartSettingsManager.GetKartConfig("backend.expertmode") <> "y" Then
            txtDateFormat.Enabled = False
            txtDateTimeFormat.Enabled = False
            txtMaster.Enabled = False
            ddlMasterPage.Enabled = False
            ddlTheme.Enabled = False
        End If


        If chkIsDefault.Checked Then
            chkFrontLive.Enabled = False
            chkBackLive.Enabled = False
        Else
            chkFrontLive.Enabled = True
            chkBackLive.Enabled = True
        End If

    End Sub

    Private Sub HideDetails()
        phdLanguageDetails.Visible = False
        updLanguage.Update()
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        LoadLanguages()
        HideDetails()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        If SaveChanges() Then
            LoadLanguages()
            HideDetails()
            RaiseEvent ShowMasterUpdate()
        End If
    End Sub

    Private Function SaveChanges() As Boolean
        If GetLanguageID() = 0 Then '' new
            If Not SaveLanguage(DML_OPERATION.INSERT) Then Return False
        Else                        '' update
            If Not SaveLanguage(DML_OPERATION.UPDATE) Then Return False
        End If
        Return True
    End Function

    Private Function SaveLanguage(ByVal enumOperation As DML_OPERATION) As Boolean

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 1. Language Main Info.
        Dim strBackName As String = txtBackName.Text
        Dim strFrontName As String = txtFrontName.Text

        'Not used at present as multi-language skin (master page) used
        'Dim strSkinLocation As String = txtSkinLocation.Text
        Dim strSkinLocation As String = ""

        Dim strEmailOrders As String = txtEmailOrders.Text
        Dim strEmailContact As String = txtEmailContact.Text
        Dim strReplayEmail As String = txtReplayEmail.Text
        Dim strDateFormat As String = txtDateFormat.Text
        Dim strDateTimeFormat As String = txtDateTimeFormat.Text
        Dim blnFrontLive As Boolean = chkFrontLive.Checked
        Dim blnBackLive As Boolean = chkBackLive.Checked
        Dim strLanguageCulture As String = txtLanguageCulture.Text
        Dim strLanguageUICulture As String = txtLanguageUICulture.Text

        Dim strMaster As String = ddlMasterPage.SelectedValue

        Dim strTheme As String = ddlTheme.SelectedValue

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ' 2. Saving the changes
        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not LanguagesBLL._UpdateLanguage( _
                                GetLanguageID(), strBackName, strFrontName, strSkinLocation, blnFrontLive, blnBackLive, _
                                strReplayEmail, strEmailOrders, strEmailContact, strDateFormat, strDateTimeFormat, _
                                strLanguageCulture, strLanguageUICulture, strMaster, strTheme, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.INSERT
                If Not LanguagesBLL._AddLanguage( _
                                strBackName, strFrontName, strSkinLocation, blnFrontLive, blnBackLive, _
                                strReplayEmail, strEmailOrders, strEmailContact, strDateFormat, strDateTimeFormat, _
                                strLanguageCulture, strLanguageUICulture, strMaster, strTheme, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        '' Change the name of the image
        Try
            If litCulture.Text <> strLanguageCulture Then
                Dim strImageName As String = litCulture.Text
                Dim dirLanguageImages As New DirectoryInfo(Server.MapPath(strLanguageImages))
                For Each objFile As FileInfo In dirLanguageImages.GetFiles()
                    If objFile.Name.StartsWith(strImageName & ".") Then
                        File.Copy(Server.MapPath(strLanguageImages & objFile.Name), _
                            Server.MapPath(strLanguageImages & strLanguageCulture & Right(objFile.Name, 4)), True)
                        File.Delete(Server.MapPath(strLanguageImages & objFile.Name))
                        Exit For
                    End If
                Next
            End If
        Catch ex As Exception
        End Try

        Return True
    End Function

    Private Function GetLanguageID() As Byte
        If litLanguageID.Text <> "" Then Return CByte(litLanguageID.Text)
        Return 0
    End Function

    Protected Sub lnkChangeImage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkChangeImage.Click
        litImageStatus.Text = "change"
        litImageName.Text = litCulture.Text
        _UC_UploaderPopup.OpenFileUpload()
    End Sub

    Protected Sub lnkDeleteImage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkDeleteImage.Click
        litImageStatus.Text = "delete"
        litImageName.Text = litCulture.Text
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub lnkSetImage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkSetImage.Click
        litImageStatus.Text = "set"
        litImageName.Text = litCulture.Text
        _UC_UploaderPopup.OpenFileUpload()
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strImageName As String = litImageName.Text
        Dim dirLanguageImages As New DirectoryInfo(Server.MapPath(strLanguageImages))
        '' Try to delete language image (flag)
        Try
            For Each objFile As FileInfo In dirLanguageImages.GetFiles()
                If objFile.Name.StartsWith(strImageName & ".") Then
                    File.Delete(Server.MapPath(strLanguageImages & objFile.Name))
                End If
            Next
        Catch ex As Exception
        End Try
        phdImageNotExist.Visible = True
        phdImageExist.Visible = False
        updLanguageImages.Update()
    End Sub
End Class
