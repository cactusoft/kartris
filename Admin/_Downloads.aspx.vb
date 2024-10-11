'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.HttpContext
Imports CkartrisEnumerations
Imports Kartris
Imports CkartrisDataManipulation
Imports KartSettingsManager

Imports CkartrisDisplayFunctions

Partial Class Admin_Downloads
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Versions", "PageTitle_VersionDownloads") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        '' The following line is important for the confirmation msg box
        ''  => it will allow the event of the server side button to be fired
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)

        If Not Page.IsPostBack Then
            LoadDownloads()
            LoadLinks()
            CheckTempFolder()
        End If
    End Sub

    Protected Sub gvwLinks_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwLinks.PageIndexChanging
        gvwLinks.PageIndex = e.NewPageIndex
        LoadLinks()
    End Sub

    Protected Sub gvwNonLinkedFiles_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwNonLinkedFiles.PageIndexChanging
        gvwNonLinkedFiles.PageIndex = e.NewPageIndex
        LoadDownloads()
    End Sub

    Protected Sub gvwDownloads_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwDownloads.PageIndexChanging
        gvwDownloads.PageIndex = e.NewPageIndex
        LoadDownloads()
    End Sub

    Sub LoadDownloads()
        mvwDownloads.SetActiveView(viwDownloadData)
        Dim objVersionsBLL As New VersionsBLL
        Dim tblDownloads As DataTable = objVersionsBLL._GetDownloadableFiles(Session("_LANG"))
        If tblDownloads.Rows.Count = 0 Then mvwDownloads.SetActiveView(viwNoDownloads)
        gvwDownloads.DataSource = tblDownloads
        gvwDownloads.DataBind()
        FindNonRelatedFiles(tblDownloads)
        updMain.Update()
    End Sub

    Sub LoadLinks()
        mvwLinks.SetActiveView(viwLinksData)
        Dim objVersionsBLL As New VersionsBLL
        Dim tblLinks As DataTable = objVersionsBLL._GetDownloadableLinks(Session("_LANG"))
        If tblLinks.Rows.Count = 0 Then mvwLinks.SetActiveView(viwNoLinks)
        gvwLinks.DataSource = tblLinks
        gvwLinks.DataBind()
        updMain.Update()
    End Sub

    Sub FindNonRelatedFiles(ByVal tblDownloads As DataTable)
        mvwNonLinked.SetActiveView(viwNonLinkedData)
        Dim _dirInfo As New DirectoryInfo(Server.MapPath(GetKartConfig("general.uploadfolder")))
        Dim tblNonRelatedFiles As DataTable = New DataTable
        tblNonRelatedFiles.Columns.Add(New DataColumn("FileName", Type.GetType("System.String")))
        tblNonRelatedFiles.Columns.Add(New DataColumn("FileSize", Type.GetType("System.String")))
        lstNonRelatedFiles.Items.Clear()
        For Each _file As FileInfo In _dirInfo.GetFiles
            Dim drFiles As DataRow() = tblDownloads.Select("V_DownloadInfo='" & _file.Name & "'")
            If drFiles.Length = 0 Then
                tblNonRelatedFiles.Rows.Add(_file.Name, GetFileLength(_file.Length))
                lstNonRelatedFiles.Items.Add(_file.Name)
            End If
        Next
        litNonLinkedFiles.Text = CStr(lstNonRelatedFiles.Items.Count + CheckTempFolder())
        If tblNonRelatedFiles.Rows.Count = 0 Then mvwNonLinked.SetActiveView(viwNoNonLinked)
        gvwNonLinkedFiles.DataSource = tblNonRelatedFiles
        gvwNonLinkedFiles.DataBind()
    End Sub

    Function CheckTempFolder() As Integer
        Dim _dirInfo As New DirectoryInfo(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/"))
        Dim numNoTempFiles As Integer = _dirInfo.GetFiles.Count
        If numNoTempFiles > 0 Then
            litTempFiles.Text = numNoTempFiles
            phdNoTempFiles.Visible = False
            phdTempFilesExist.Visible = True
        End If
        Return numNoTempFiles
    End Function

    Protected Sub gvwDownloads_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwDownloads.RowCommand
        Select Case e.CommandName
            Case "OpenFile"
                DownloadFile(e.CommandArgument)
            Case "ChangeFile", "NewFile"
                gvwDownloads.SelectedIndex = e.CommandArgument Mod gvwDownloads.PageSize
                _UC_UploaderPopup.OpenFileUpload()
            Case "RenameFile"
                litType.Text = "u"
                mvwPopup.SetActiveView(viwPopupDownload)
                gvwDownloads.SelectedIndex = e.CommandArgument Mod gvwDownloads.PageSize
                litPopupVersionName.Text = CType(gvwDownloads.SelectedRow.Cells(1).FindControl("litVersionName"), Literal).Text
                litPopupFileName.Text = CType(gvwDownloads.SelectedRow.Cells(2).FindControl("litFile"), Literal).Text
                txtPopupFileName.Text = CType(gvwDownloads.SelectedRow.Cells(2).FindControl("litFile"), Literal).Text
                lnkSave.ValidationGroup = "FileRename"
                popExtender.Show()
        End Select
    End Sub

    Protected Sub gvwDownloads_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwDownloads.RowDataBound
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim strFileName As String = _
                    CType(e.Row.Cells(3).FindControl("lnkFile"), LinkButton).Text
                If Not String.IsNullOrEmpty(strFileName) Then
                    If File.Exists(Server.MapPath(GetKartConfig("general.uploadfolder") & strFileName)) Then
                        Dim _FileInfo As FileInfo
                        _FileInfo = New FileInfo(Server.MapPath(GetKartConfig("general.uploadfolder") & strFileName))
                        CType(e.Row.Cells(3).FindControl("litSize"), Literal).Text = GetFileLength(_FileInfo.Length)
                    Else
                        CType(e.Row.Cells(2).FindControl("lnkFile"), LinkButton).Visible = False
                        CType(e.Row.Cells(2).FindControl("litFile"), Literal).Visible = True
                        CType(e.Row.Cells(3).FindControl("litSize"), Literal).Text = GetGlobalResourceObject("_Kartris", "ContentText_Missing")
                        CType(e.Row.Cells(4).FindControl("lnkBtnRenameFile"), LinkButton).Visible = False
                        CType(e.Row.Cells(4).FindControl("lnkBtnChangeDownloadFile"), LinkButton).Visible = False
                        CType(e.Row.Cells(4).FindControl("lnkBtnUploadFile"), LinkButton).Visible = True
                        e.Row.CssClass = "Kartris-GridView-Green"
                    End If
                Else
                    CType(e.Row.Cells(2).FindControl("litFile"), Literal).Text = GetGlobalResourceObject("_Kartris", "ContentText_Unassigned")
                    CType(e.Row.Cells(2).FindControl("litFile"), Literal).Visible = True
                    CType(e.Row.Cells(3).FindControl("litSize"), Literal).Text = "-"
                    CType(e.Row.Cells(3).FindControl("litSize"), Literal).Visible = True
                    CType(e.Row.Cells(4).FindControl("lnkBtnRenameFile"), LinkButton).Visible = False
                    CType(e.Row.Cells(4).FindControl("lnkBtnChangeDownloadFile"), LinkButton).Visible = False
                    CType(e.Row.Cells(4).FindControl("lnkBtnUploadFile"), LinkButton).Visible = True
                    e.Row.CssClass = "Kartris-GridView-Red"
                End If
            End If
        Catch ex As Exception
        End Try
    End Sub

    Protected Sub gvwLinks_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwLinks.RowCommand
        Select Case e.CommandName
            Case "ChangeLink"
                litType.Text = "l"
                mvwPopup.SetActiveView(viwPopupLink)
                gvwLinks.SelectedIndex = e.CommandArgument Mod gvwLinks.PageSize
                litPopupVersionName.Text = CType(gvwLinks.SelectedRow.Cells(1).FindControl("litVersionName"), Literal).Text
                litPopupLinkLocation.Text = CType(gvwLinks.SelectedRow.Cells(2).FindControl("lnkLinkLocation"), HyperLink).Text
                txtPopupLinkLocation.Text = CType(gvwLinks.SelectedRow.Cells(2).FindControl("lnkLinkLocation"), HyperLink).Text
                popExtender.Show()
        End Select
    End Sub

    Protected Sub gvwLinks_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwLinks.RowDataBound
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim strLinkLocation As String = _
                    CType(e.Row.Cells(2).FindControl("litLinkLocation"), Literal).Text
                If String.IsNullOrEmpty(strLinkLocation) Then
                    CType(e.Row.Cells(2).FindControl("litLinkLocation"), Literal).Text = "-"
                    CType(e.Row.Cells(2).FindControl("litLinkLocation"), Literal).Visible = True
                    e.Row.CssClass = "Kartris-GridView-Red"
                End If
            End If
        Catch ex As Exception
        End Try
    End Sub

    Function GetFileLength(ByVal numSizeInBytes As Long) As String
        Return CStr(Math.Ceiling(numSizeInBytes / 1024.0F)) & " KB"
    End Function

    Protected Sub _UC_UploaderPopup_NeedCategoryRefresh() Handles _UC_UploaderPopup.NeedCategoryRefresh
        CType(Me.Master, Skins_Admin_Template).LoadCategoryMenu()
    End Sub

    Protected Sub _UC_UploaderPopupUploadClicked() Handles _UC_UploaderPopup.UploadClicked
        If _UC_UploaderPopup.HasFile() Then
            Dim strCodeNumber As String = CType(gvwDownloads.SelectedRow.Cells(0).FindControl("litCodeNumber"), Literal).Text
            Dim lngVersionNumber As Long = CLng(gvwDownloads.SelectedValue)
            Dim strFileName As String = strCodeNumber & "_" & _UC_UploaderPopup.GetFileName()
            Dim strUploadFolder As String = GetKartConfig("general.uploadfolder")
            Dim strTempFolder As String = strUploadFolder & "temp/"
            If Not Directory.Exists(Server.MapPath(strTempFolder)) Then Directory.CreateDirectory(Server.MapPath(strTempFolder))
            Dim strSavedPath As String = strTempFolder & strFileName
            _UC_UploaderPopup.SaveFile(Server.MapPath(strSavedPath))
            Dim strMessage As String = String.Empty
            Dim objVersionsBLL As New VersionsBLL
            If Not objVersionsBLL._UpdateVersionDownloadInfo(lngVersionNumber, strFileName, "u", strMessage) Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                File.SetAttributes(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/" & strFileName), FileAttributes.Normal)
                File.Delete(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/" & strFileName))
                Return
            End If
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
            LoadDownloads()
        End If
    End Sub

    Protected Sub lnkSave_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lnkSave.ValidationGroup = ""
        Dim objVersionsBLL As New VersionsBLL
        If litType.Text = "u" Then
            Dim strUploadFolder As String = GetKartConfig("general.uploadfolder")
            If File.Exists(Current.Server.MapPath(strUploadFolder & litPopupFileName.Text)) Then
                File.Copy(Current.Server.MapPath(strUploadFolder & litPopupFileName.Text), _
                          Current.Server.MapPath(strUploadFolder & "temp/" & txtPopupFileName.Text))
                Dim lngVersionNumber As Long = CLng(gvwDownloads.SelectedValue)
                Dim strMessage As String = String.Empty

                If Not objVersionsBLL._UpdateVersionDownloadInfo(lngVersionNumber, txtPopupFileName.Text, "u", strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    File.SetAttributes(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/" & txtPopupFileName.Text), FileAttributes.Normal)
                    File.Delete(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/" & txtPopupFileName.Text))
                    Return
                End If
                File.SetAttributes(Server.MapPath(GetKartConfig("general.uploadfolder") & litPopupFileName.Text), FileAttributes.Normal)
                File.Delete(Server.MapPath(GetKartConfig("general.uploadfolder") & litPopupFileName.Text))
                CType(Me.Master, Skins_Admin_Template).DataUpdated()
                LoadDownloads()
            End If
        Else
            Dim lngVersionNumber As Long = CLng(gvwLinks.SelectedValue)
            Dim strMessage As String = String.Empty
            If Not objVersionsBLL._UpdateVersionDownloadInfo(lngVersionNumber, Replace(txtPopupLinkLocation.Text, "http://", ""), "l", strMessage) Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                Return
            End If
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
            LoadLinks()
        End If

    End Sub

    Protected Sub gvwNonLinkedFiles_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwNonLinkedFiles.RowCommand
        Select Case e.CommandName
            Case "OpenFile"
                DownloadFile(e.CommandArgument)
            Case "DeleteFile"
                Try
                    File.SetAttributes(Server.MapPath(GetKartConfig("general.uploadfolder") & e.CommandArgument), FileAttributes.Normal)
                    File.Delete(Server.MapPath(GetKartConfig("general.uploadfolder") & e.CommandArgument))
                    CType(Me.Master, Skins_Admin_Template).DataUpdated()
                    LoadDownloads()
                Catch ex As Exception
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_FilePermissionsError"))
                End Try
            Case "DeleteAllFiles"
                DeleteNonRelatedFiles()
        End Select

    End Sub

    Protected Sub lnkBtnDeleteTempFiles_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteTempFiles.Click
        Dim _dirInfo As New DirectoryInfo(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/"))
        For Each _file As FileInfo In _dirInfo.GetFiles
            Try
                File.SetAttributes(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/" & _file.Name), FileAttributes.Normal)
                File.Delete(Server.MapPath(GetKartConfig("general.uploadfolder") & "temp/" & _file.Name))
            Catch ex As Exception
            End Try
        Next
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        LoadDownloads()
    End Sub

    Sub DeleteNonRelatedFiles()
        Dim objVersionsBLL As New VersionsBLL
        Dim tblDownloads As DataTable = objVersionsBLL._GetDownloadableFiles(Session("_lang"))
        Dim _dirInfo As New DirectoryInfo(Server.MapPath(GetKartConfig("general.uploadfolder")))
        For Each _file As FileInfo In _dirInfo.GetFiles
            Dim drFiles As DataRow() = tblDownloads.Select("V_DownloadInfo='" & _file.Name & "'")
            If drFiles.Length = 0 Then
                Try
                    File.SetAttributes(Server.MapPath(GetKartConfig("general.uploadfolder") & _file.Name), FileAttributes.Normal)
                    File.Delete(Server.MapPath(GetKartConfig("general.uploadfolder") & _file.Name))
                Catch ex As Exception
                End Try
            End If
        Next
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        LoadDownloads()
    End Sub

    Function FormatFileURL(ByVal strURL As String) As String
        If Left(strURL.ToLower, 4) = "http" Then
            'absolute link
            Return strURL
        Else
            'local url
            Return "../" & strURL
        End If
    End Function
End Class
