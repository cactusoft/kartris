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
Imports System.Data
Imports CkartrisDataManipulation
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisImages
Imports KartSettingsManager

Partial Class admin_MediaTypes
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Kartris", "BackMenu_MediaTypes") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
        If Not Page.IsPostBack Then
            LoadMediaTypes()
        End If
    End Sub

    Sub LoadMediaTypes()
        Dim tblMediaTypes As DataTable = MediaBLL._GetMediaTypes()
        gvwMediaTypes.DataSource = tblMediaTypes
        gvwMediaTypes.DataBind()
        mvwMedia.SetActiveView(vwTypeList)
        updMediaTypes.Update()
    End Sub

    Protected Sub gvwMediaTypes_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwMediaTypes.RowCommand
        If e.CommandName = "EditMediaType" Then
            EditMediaType(e.CommandArgument)
        End If
    End Sub
    Sub EditMediaType(ByVal numMediaTypeID As Integer)
        Dim drType As DataRow = MediaBLL._GetMediaTypesByID(numMediaTypeID).Rows(0)
        litMediaTypeID.Text = FixNullFromDB(drType("MT_ID"))
        txtMediaType.Text = FixNullFromDB(drType("MT_Extension"))
        txtMediaType.ReadOnly = True
        txtDefaultHeight.Text = FixNullFromDB(drType("MT_DefaultHeight"))
        txtDefaultWidth.Text = FixNullFromDB(drType("MT_DefaultWidth"))
        txtDefaultParameters.Text = FixNullFromDB(drType("MT_DefaultParameters"))
        chkDownloadable.Checked = CBool(FixNullFromDB(drType("MT_DefaultisDownloadable")))
        chkEmbed.Checked = CBool(FixNullFromDB(drType("MT_Embed")))
        chkInline.Checked = CBool(FixNullFromDB(drType("MT_Inline")))
        PreviewIcon()
        mvwMedia.SetActiveView(vwEditType)
        updMediaTypes.Update()
    End Sub

    Protected Sub lnkUploadIcon_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkUploadIcon.Click
        _UC_IconUploaderPopup.OpenFileUpload()
    End Sub
    Function GetMediaTypeID() As Integer
        Dim numMediaTypeID As Integer = 0
        Try
            numMediaTypeID = CInt(litMediaTypeID.Text)
        Catch ex As Exception
            numMediaTypeID = 0
        End Try
        Return numMediaTypeID
    End Function
    Protected Sub _UC_IconUploaderPopup_UploadClicked() Handles _UC_IconUploaderPopup.UploadClicked
        If _UC_IconUploaderPopup.HasFile Then
            Dim strFileExt As String = Path.GetExtension(_UC_IconUploaderPopup.GetFileName())
            Dim strMessage As String = Nothing
            If IsValidFileType(strFileExt, strMessage, True) Then
                phdUploadError.Visible = False : litUploadError.Text = Nothing
                Dim strIconsFolder As String = "~/Images/MediaTypes/"
                Dim strFileName As String = _UC_IconUploaderPopup.GetFileName
                Dim strExtension As String = Mid(strFileName, strFileName.LastIndexOf(".") + 1)
                litOriginalIconName.Text = strFileName
                If GetMediaTypeID() = 0 Then
                    Dim strTempFolder As String = strIconsFolder & "temp/"
                    litTempIconName.Text = Guid.NewGuid.ToString & strExtension
                    If Not Directory.Exists(Server.MapPath(strTempFolder)) Then Directory.CreateDirectory(Server.MapPath(strTempFolder))
                    _UC_IconUploaderPopup.SaveFile(Server.MapPath(strTempFolder & litTempIconName.Text))
                    imgMediaIcon.ImageUrl = strTempFolder & litTempIconName.Text & "?nocache=" & Now.Hour & Now.Minute & Now.Second
                    imgMediaIcon.Visible = True : lnkUploadIcon.Visible = False
                    lnkRemoveIcon.Visible = True
                Else
                    If Not Directory.Exists(Server.MapPath(strIconsFolder)) Then Directory.CreateDirectory(Server.MapPath(strIconsFolder))
                    Dim strIconName As String = txtMediaType.Text & strExtension
                    Dim strExistingIcon = GetIconName(txtMediaType.Text)
                    If strExistingIcon IsNot Nothing Then File.Delete(Server.MapPath(strIconsFolder & strExistingIcon))
                    _UC_IconUploaderPopup.SaveFile(Server.MapPath(strIconsFolder & strIconName))
                    PreviewIcon()
                End If
            Else
                phdUploadError.Visible = True : litUploadError.Text = strMessage
            End If
        End If
    End Sub

    Function GetIconName(ByVal strMediaType As String) As String
        Dim strImageName As String = strMediaType
        Dim strIconsFolder As String = "~/Images/MediaTypes/"
        Dim dirMediaIconImages As New DirectoryInfo(Server.MapPath(strIconsFolder))
        For Each objFile As FileInfo In dirMediaIconImages.GetFiles()
            If objFile.Name.StartsWith(strImageName & ".") Then
                Return objFile.Name
            End If
        Next
        Return Nothing
    End Function

    Sub PreviewIcon()
        Dim strExistingIcon = GetIconName(txtMediaType.Text)
        If strExistingIcon IsNot Nothing Then
            imgMediaIcon.ImageUrl = "~/Images/MediaTypes/" & strExistingIcon & "?nocache=" & Now.Hour & Now.Minute & Now.Second
            imgMediaIcon.Visible = True : lnkUploadIcon.Visible = False
            lnkRemoveIcon.Visible = True
        Else
            imgMediaIcon.ImageUrl = Nothing
            imgMediaIcon.Visible = False : lnkUploadIcon.Visible = True
            lnkRemoveIcon.Visible = False
        End If
    End Sub
    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        mvwMedia.SetActiveView(vwTypeList)
        updMediaTypes.Update()
    End Sub

    Protected Sub lnkBtnNewType_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewType.Click
        PrepareNewType()
    End Sub
    Sub PrepareNewType()
        litMediaTypeID.Text = "0"
        txtMediaType.Text = Nothing
        txtMediaType.ReadOnly = False
        txtDefaultHeight.Text = Nothing
        txtDefaultWidth.Text = Nothing
        txtDefaultParameters.Text = Nothing
        chkDownloadable.Checked = False
        chkEmbed.Checked = False
        chkInline.Checked = False
        imgMediaIcon.ImageUrl = Nothing
        imgMediaIcon.Visible = False : lnkUploadIcon.Visible = True
        lnkRemoveIcon.Visible = False
        mvwMedia.SetActiveView(vwEditType)
        updMediaTypes.Update()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        If GetMediaTypeID() = 0 Then  '' on new
            SaveMediaType(DML_OPERATION.INSERT)
        Else                        '' on update
            SaveMediaType(DML_OPERATION.UPDATE)
        End If
    End Sub
    Private Sub SaveMediaType(ByVal enumOperation As DML_OPERATION)

        Dim strMediaTypeName As String, numDefaultHeight As Integer
        Dim numDefaultWidth As Integer, blnDownloadable As Boolean, strDefaultParameters As String
        Dim blnEmbed, blnInline As Boolean, strMessage As String = ""

        strMediaTypeName = txtMediaType.Text
        numDefaultHeight = txtDefaultHeight.Text
        numDefaultWidth = txtDefaultWidth.Text
        strDefaultParameters = txtDefaultParameters.Text
        blnDownloadable = chkDownloadable.Checked
        blnEmbed = chkEmbed.Checked
        blnInline = chkInline.Checked

        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not MediaBLL._UpdateMediaType( _
                                 numDefaultHeight, numDefaultWidth, strDefaultParameters, _
                                 blnDownloadable, blnEmbed, blnInline, GetMediaTypeID, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                CType(Me.Master, Skins_Admin_Template).DataUpdated()
                LoadMediaTypes()
            Case DML_OPERATION.INSERT
                If Not MediaBLL._AddMediaType( _
                                 strMediaTypeName, numDefaultHeight, numDefaultWidth, _
                                 strDefaultParameters, blnDownloadable, blnEmbed, blnInline, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                '' Icon Saving
                Dim strMediaIconsFolder As String = "~/Images/MediaTypes/"
                Dim strTempFolder As String = strMediaIconsFolder & "temp/"
                Dim strIconName As String = Nothing
                If Not String.IsNullOrEmpty(litTempIconName.Text) Then
                    Try
                        Dim strExtension As String = Mid(litTempIconName.Text, litTempIconName.Text.LastIndexOf(".") + 1)
                        If File.Exists(Server.MapPath(strMediaIconsFolder & strMediaTypeName & strExtension)) Then
                            File.Delete(Server.MapPath(strMediaIconsFolder & strMediaTypeName & strExtension))
                        End If
                        File.Move(Server.MapPath(strTempFolder & litTempIconName.Text), _
                                  Server.MapPath(strMediaIconsFolder & strMediaTypeName & strExtension))
                        strIconName = strMediaTypeName & strExtension
                    Catch ex As Exception
                    End Try
                End If
                CType(Me.Master, Skins_Admin_Template).DataUpdated()
                LoadMediaTypes()
        End Select

    End Sub

    Protected Sub lnkRemoveIcon_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkRemoveIcon.Click
        Dim strMediaIconsFolder As String = "~/Images/MediaTypes/"
        Dim strImageURL As String = imgMediaIcon.ImageUrl
        If strImageURL.Contains("/temp/") Then strMediaIconsFolder &= "temp/"
        Dim strFileName As String = Mid(strImageURL, strImageURL.LastIndexOf("/") + 2)
        strFileName = Mid(strFileName, 1, strFileName.LastIndexOf("?"))
        If File.Exists(Server.MapPath(strMediaIconsFolder & strFileName)) Then File.Delete(Server.MapPath(strMediaIconsFolder & strFileName))
        imgMediaIcon.ImageUrl = Nothing
        imgMediaIcon.Visible = False : lnkUploadIcon.Visible = True
        lnkRemoveIcon.Visible = False
    End Sub

    Function IsValidFileType(ByVal strFileExt As String, ByRef strMessage As String, ByVal blnCheckImageTypes As Boolean) As Boolean
        Dim arrExcludedFileTypes() As String = ConfigurationManager.AppSettings("ExcludedUploadFiles").ToString().Split(",")
        For i As Integer = 0 To arrExcludedFileTypes.GetUpperBound(0)
            If Replace(strFileExt.ToLower, ".", "") = arrExcludedFileTypes(i).ToLower Then
                'Banned file type, don't upload
                'Log error so attempts can be seen in logs
                CkartrisFormatErrors.LogError("Attempt to upload a file of type: " & arrExcludedFileTypes(i).ToLower)
                strMessage = "It is not permitted to upload files of this type. Change 'ExcludedUploadFiles' in the web.config if you need to upload this file."
                Return False
            End If
        Next

        If blnCheckImageTypes Then
            'This is a softer check, it checks images are of an acceptable
            'type. The security check on file type above will overrule
            'this 'allow' list here.
            Dim arrAllowedImageTypes() As String = KartSettingsManager.GetKartConfig("backend.imagetypes").Split(",")
            For i As Integer = 0 To arrAllowedImageTypes.GetUpperBound(0)
                If strFileExt.ToLower = arrAllowedImageTypes(i).ToLower Then
                    Return True
                End If
            Next

            strMessage = GetGlobalResourceObject("_Kartris", "ContentText_ErrorChkUploadFileType")
            Return False
        End If

        Return True
    End Function

    Protected Sub _UC_IconUploaderPopup_NeedCategoryRefresh() Handles _UC_IconUploaderPopup.NeedCategoryRefresh
        CType(Me.Master, Skins_Admin_Template).LoadCategoryMenu()
    End Sub
End Class
