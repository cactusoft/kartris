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
Imports CkartrisDisplayFunctions
Imports CkartrisImages
Imports KartSettingsManager

Partial Class UserControls_Back_EditMedia
    Inherits System.Web.UI.UserControl

    Public Event NeedCategoryRefresh()
    Private _strInlineJS As String

    Public Property ParentType() As String
        Set(ByVal value As String)
            litParentType.Text = value
        End Set
        Get
            Return litParentType.Text
        End Get
    End Property

    Public Property ParentID() As Long
        Set(ByVal value As Long)
            litParentID.Text = value
        End Set
        Get
            Return litParentID.Text
        End Get
    End Property

    Public Event ShowMasterUpdate()

    Public Sub LoadMedia()
        GetMediaLinks()

        If ddlMediaType.Items.Count = 1 Then
            Dim tblMediaTypes As DataTable = MediaBLL._GetMediaTypes()
            ddlMediaType.DataTextField = "MT_Extension"
            ddlMediaType.DataValueField = "MT_ID"
            ddlMediaType.DataSource = tblMediaTypes
            ddlMediaType.DataBind()
        End If

        '-------------------------------------
        'MEDIA POPUP
        '-------------------------------------
        'We set width and height later with
        'javascript, as popup size will vary
        'depending on the media type

        UC_PopUpMedia.SetTitle = GetGlobalResourceObject("_Kartris", "FormButton_Preview")
        UC_PopUpMedia.SetMediaPath = litParentID.Text

        UC_PopUpMedia.PreLoadPopup()

    End Sub

    Sub GetMediaLinks()
        Dim tblMediaLinks As DataTable = MediaBLL._GetMediaLinksByParent(ParentID, ParentType)
        rptMediaLinks.DataSource = tblMediaLinks
        rptMediaLinks.DataBind()
        ShowHideUpDownArrows(tblMediaLinks.Rows.Count)

        mvwMedia.SetActiveView(viwMediaList)
        updMain.Update()
    End Sub


    Private Sub ShowHideUpDownArrows(ByVal TotalRows As Integer)
        Try
            CType(rptMediaLinks.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).Enabled = False
            CType(rptMediaLinks.Items(TotalRows - 1).FindControl("lnkBtnMoveDown"), LinkButton).Enabled = False
            CType(rptMediaLinks.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).CssClass &= " triggerswitch_disabled"
            CType(rptMediaLinks.Items(TotalRows - 1).FindControl("lnkBtnMoveDown"), LinkButton).CssClass &= " triggerswitch_disabled"
        Catch ex As Exception
        End Try
    End Sub

    Protected Sub rptMediaLinks_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptMediaLinks.ItemCommand
        Select Case e.CommandName
            Case "EditMedia"
                PrepareExistingMedia(e.CommandArgument)
            Case "MoveUp"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    MediaBLL._ChangeMediaLinkOrder(e.CommandArgument, ParentID, ParentType, "u")
                    GetMediaLinks()
                Catch ex As Exception
                End Try
            Case "MoveDown"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    MediaBLL._ChangeMediaLinkOrder(e.CommandArgument, ParentID, ParentType, "d")
                    GetMediaLinks()
                Catch ex As Exception
                End Try
        End Select
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub rptMediaLinks_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptMediaLinks.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
            e.Item.ItemType = ListItemType.Item Then

            Dim strWebShopURL As String = CkartrisBLL.WebShopURL

            Dim strIconLink As String

            Dim drvMediaLink As DataRowView = CType(e.Item.DataItem, DataRowView)

            'get this item's media type details
            Dim strMT_Extension As String = FixNullFromDB(drvMediaLink.Item("MT_Extension"))
            Dim blnisEmbedded As Boolean = CType(FixNullFromDB(drvMediaLink.Item("MT_Embed")), Boolean)
            Dim blnisDownloadable As Boolean
            Try
                blnisDownloadable = CType(drvMediaLink.Item("ML_isDownloadable"), Boolean)
            Catch ex As Exception
                blnisDownloadable = CType(FixNullFromDB(drvMediaLink.Item("MT_DefaultisDownloadable")), Boolean)
            End Try


            Dim intHeight As Integer = FixNullFromDB(drvMediaLink.Item("ML_Height"))
            Dim intWidth As Integer = FixNullFromDB(drvMediaLink.Item("ML_Width"))

            'get the default height and width from the media type if the item doesn't have its height and width set

            intHeight = (drvMediaLink.Item("MT_DefaultHeight"))
            
            intWidth = (drvMediaLink.Item("MT_DefaultWidth"))


            Dim strMT_IconFolder As String = "Images/MediaTypes/"
            Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"

            Dim intML_ID As Integer = drvMediaLink.Item("ML_ID")
            Dim strML_EmbedSource As String = FixNullFromDB(drvMediaLink.Item("ML_EmbedSource"))
            Dim strML_Type As String = FixNullFromDB(drvMediaLink.Item("ML_ParentType"))

            'Get thumbnail or media type icon
            strIconLink = GetThumbPath(intML_ID, strMT_Extension, False)

            If String.IsNullOrEmpty(strML_EmbedSource) Then
                strML_EmbedSource = strMediaLinksFolder & intML_ID & "." & strMT_Extension
            End If

            'check if the media link item already contains the embed code
            If blnisEmbedded Then
                Dim litInline As New Literal
                litInline.Text = "<div id='inline_" & intML_ID & "'>"
                'embed - just write it directly to the page
                litInline.Text += strML_EmbedSource & "</div>"
                phdInline.Controls.Add(litInline)
            End If
            'Show media popup
            Dim strMediaImageLink As String = "<img alt="""" class=""media_image"" src=""" & _
                            "../Image.aspx?strFullPath=" & strIconLink & "&numMaxHeight=80&numMaxWidth=80"" />"

            CType(e.Item.FindControl("litMediaLink"), Literal).Text = "<a class = """ & intML_ID & """>" & _
                            strMediaImageLink & "</a>"
        End If
    End Sub

    Sub PrepareExistingMedia(ByVal numMediaID As Integer)
        'Get media link
        Dim drwLink As DataRow = MediaBLL._GetMediaLinkByID(numMediaID).Rows(0)

        'Get media type
        Dim drwMediaType As DataRow = MediaBLL._GetMediaTypesByID(drwLink("ML_MediaTypeID")).Rows(0)

        Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
        Dim strMT_IconFolder As String = "Images/MediaTypes/"
        Dim strMT_Extension As String = FixNullFromDB(drwLink("MT_Extension"))
        Dim blnDefaultMediaThumb = True
        Dim strThumbNameLink As String = GetThumbPath(numMediaID, strMT_Extension, blnDefaultMediaThumb)
        Dim strFileName As String = numMediaID & "." & FixNullFromDB(drwLink("MT_Extension"))
        Dim strFileName2 As String = ""
        If strMT_Extension = "html5video" Then
            strFileName = numMediaID & ".mp4"
            strFileName2 = numMediaID & ".webm"
        End If
        Dim intHeight As Integer = 0
        Dim intWidth As Integer = 0

        '' Thumb
        Dim blnThumbExist As Boolean = False
        If strThumbNameLink IsNot Nothing Then
            imgMediaThumb.ImageUrl = strThumbNameLink & "?nocache=" & Now.Hour & Now.Minute & Now.Second
            litImgName.Text = strThumbNameLink
            litImgName.Visible = True
            blnThumbExist = True
        Else
            litImgName.Visible = False
        End If

        'If blnDefaultMediaThumb Then lnkRemoveThumb.Visible = False
        lnkUploadThumb.Visible = blnDefaultMediaThumb : lnkRemoveThumb.Visible = Not blnDefaultMediaThumb

        '' File


        Dim blnFileExist As Boolean = File.Exists(Server.MapPath(strMediaLinksFolder & strFileName))
        lnkUploadFile.Visible = Not blnFileExist : lnkRemoveFile.Visible = blnFileExist

        If strMT_Extension = "html5video" Then
            Dim blnFileExist2 As Boolean = File.Exists(Server.MapPath(strMediaLinksFolder & strFileName2))
            lnkUploadFile2.Visible = Not blnFileExist2 : lnkRemoveFile2.Visible = blnFileExist2
            litMediaFileName2.Text = strFileName2
        Else
            lnkUploadFile2.Visible = False : lnkRemoveFile2.Visible = False
        End If

        litMediaFileName.Text = strFileName
        litTempThumbName.Text = Nothing
        litOriginalThumbName.Text = Nothing
        litTempFileName.Text = Nothing
        litOriginalFileName.Text = Nothing

        litTempFileName2.Text = Nothing
        litOriginalFileName2.Text = Nothing

        lnkBtnDelete.Visible = True

        litMediaLinkID.Text = numMediaID
        ddlMediaType.SelectedValue = FixNullFromDB(drwLink("ML_MediaTypeID"))
        CheckType()
        txtEmbedSource.Text = FixNullFromDB(drwLink("ML_EmbedSource"))

        'Set height and width from media link values passed through
        intHeight = FixNullFromDB(drwLink("ML_Height"))
        intWidth = FixNullFromDB(drwLink("ML_Width"))

        'get the default height and width from the media type if the item doesn't have its height and width set
        If intHeight = 0 Then
            intHeight = FixNullFromDB(drwMediaType("MT_DefaultHeight"))
        End If
        If intWidth = 0 Then
            intWidth = FixNullFromDB(drwMediaType("MT_DefaultWidth"))
        End If

        'get parameters
        txtParameters.Text = FixNullFromDB(drwLink("ML_Parameters"))

        'Set the height and width on the page
        txtHeight.Text = intHeight
        txtWidth.Text = intWidth

        chkDownloadable.Checked = FixNullFromDB(drwLink("ML_isDownloadable"))
        chkLive.Checked = FixNullFromDB(drwLink("ML_Live"))
        mvwMedia.SetActiveView(viwEditMedia)

        'Create preview link
        CType(FindControl("litPreview"), Literal).Text = "<a alt=""" & GetGlobalResourceObject("_Kartris", "FormButton_Preview") & """ class=""button previewbutton"" href=""javascript:ShowMediaPopup('" & _
                        numMediaID & "','" & strMT_Extension & "','" & litParentID.Text & "','" & FixNullFromDB(drwLink("ML_ParentType")) & "','" & intWidth & "','" & intHeight & "')"">" & _
                        GetGlobalResourceObject("_Kartris", "FormButton_Preview") & "</a>"


        updMain.Update()
    End Sub

    Sub PrepareNewMedia()
        litMediaFileName.Text = Nothing
        litTempThumbName.Text = Nothing
        litMediaFileName2.Text = Nothing
        litOriginalThumbName.Text = Nothing
        litTempFileName.Text = Nothing
        litOriginalFileName.Text = Nothing
        litTempFileName2.Text = Nothing
        litOriginalFileName2.Text = Nothing
        chkEmbed.Checked = False
        imgMediaThumb.ImageUrl = Nothing
        litImgName.Visible = False
        lnkUploadFile.Visible = True : litPreview.Visible = False : lnkRemoveFile.Visible = False
        lnkUploadFile2.Visible = True : lnkRemoveFile2.Visible = False
        lnkBtnDelete.Visible = False
        litMediaLinkID.Text = 0
        ddlMediaType.SelectedValue = 0
        txtEmbedSource.Text = Nothing
        txtHeight.Text = Nothing
        txtWidth.Text = Nothing
        chkDownloadable.Checked = False
        chkLive.Checked = True
        mvwMedia.SetActiveView(viwEditMedia)
        updMain.Update()
    End Sub

    Function GetThumbPath(ByVal numMediaID As String, ByVal strMediaType As String, ByRef blnDefaultThumb As Boolean) As String
        Dim strWebShopURL As String = CkartrisBLL.WebShopURL

        Dim strImagesFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
        Dim dirMediaImages As New DirectoryInfo(Server.MapPath(strImagesFolder))
        For Each objFile As FileInfo In dirMediaImages.GetFiles(numMediaID & "_thumb.*")
            blnDefaultThumb = False
            Return strImagesFolder & objFile.Name
        Next

        'Media Link doesn't have thumbnail so get the default media type icon
        strImagesFolder = "~/Images/MediaTypes/"
        Dim dirMediaIconImages As New DirectoryInfo(Server.MapPath(strImagesFolder))
        For Each objFile As FileInfo In dirMediaIconImages.GetFiles(strMediaType & ".*")
            blnDefaultThumb = True
            Return strImagesFolder & objFile.Name
        Next

        Return Nothing
    End Function

    Protected Sub ddlMediaType_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlMediaType.TextChanged
        If ddlMediaType.SelectedValue <> 0 Then CheckType(True) Else phdMediaDetails.Visible = False
    End Sub

    Sub CheckType(Optional ByVal blnSetDefaultValues As Boolean = False)
        phdMediaDetails.Visible = True
        Dim drwType As DataRow = MediaBLL._GetMediaTypesByID(ddlMediaType.SelectedValue).Rows(0)
        litDefaultHeight.Text = FixNullFromDB(drwType("MT_DefaultHeight"))
        litDefaultWidth.Text = FixNullFromDB(drwType("MT_DefaultWidth"))
        litDefaultParameter.Text = FixNullFromDB(drwType("MT_DefaultParameters"))
        If GetMediaLinkID() = 0 Then chkDownloadable.Checked = CBool(FixNullFromDB(drwType("MT_DefaultisDownloadable")))
        Dim blnIsEmbed As Boolean = CBool(FixNullFromDB(drwType("MT_Embed")))
        chkEmbed.Checked = blnIsEmbed
        phdEmbed.Visible = blnIsEmbed
        phdNonEmbedControls.Visible = Not blnIsEmbed
        valRequiredEmbedSource.Enabled = blnIsEmbed
        If Not blnIsEmbed Then
            valRequiredHeight.Enabled = Not chkDefaultHeight.Checked
            valRequiredWidth.Enabled = Not chkDefaultWidth.Checked
            valRequiredParameters.Enabled = Not chkDefaultParameters.Checked
            If FixNullFromDB(drwType("MT_Extension")) = "html5video" Then
                lblUploadFile2.Visible = True
                lblUploadFile2.Text = GetGlobalResourceObject("_Media", "ContentText_MediaFile") & " (WebM)"
                lblUploadFile.Text = GetGlobalResourceObject("_Media", "ContentText_MediaFile") & " (MP4)"
                If Not String.IsNullOrEmpty(litMediaFileName2.Text) Then
                    lnkUploadFile2.Visible = False
                    lnkRemoveFile2.Visible = True
                Else
                    lnkUploadFile2.Visible = True
                    lnkRemoveFile2.Visible = False
                End If
                cvMediaFile2.Enabled = True
            Else
                lblUploadFile2.Visible = False
                lnkRemoveFile2.Visible = False
                lnkUploadFile2.Visible = False
                lblUploadFile.Text = GetGlobalResourceObject("_Media", "ContentText_MediaFile")
                cvMediaFile2.Enabled = False
            End If
        Else
            valRequiredHeight.Enabled = False
            valRequiredWidth.Enabled = False
            valRequiredParameters.Enabled = False
        End If
        If GetMediaLinkID() = 0 AndAlso litImgName.Text = "" And imgMediaThumb.ImageUrl = Nothing Then
            Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
            Dim strMT_IconFolder As String = "Images/MediaTypes/"
            Dim strMT_Extension As String = FixNullFromDB(drwType("MT_Extension"))
            Dim strIconLink As String
            strIconLink = GetThumbPath("", strMT_Extension, False)
            lnkUploadThumb.Visible = True
            lnkRemoveThumb.Visible = False
            imgMediaThumb.ImageUrl = strIconLink & "?nocache=" & Now.Hour & Now.Minute & Now.Second
            litImgName.Text = strIconLink
        End If
        If GetMediaLinkID() = 0 AndAlso blnSetDefaultValues Then
            chkDefaultHeight.Checked = True : chkDefaultHeight_CheckedChanged(Me, New EventArgs)
            chkDefaultWidth.Checked = True : chkDefaultWidth_CheckedChanged(Me, New EventArgs)
            chkDefaultParameters.Checked = True : chkDefaultParameters_CheckedChanged(Me, New EventArgs)
        End If
    End Sub

    Protected Sub chkDefaultParameters_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkDefaultParameters.CheckedChanged
        txtParameters.Enabled = Not chkDefaultParameters.Checked
        If chkDefaultParameters.Checked Then
            txtParameters.Text = litDefaultParameter.Text
            valRequiredParameters.Enabled = False
        Else
            valRequiredParameters.Enabled = Not chkEmbed.Checked
        End If
    End Sub

    Protected Sub chkDefaultHeight_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkDefaultHeight.CheckedChanged
        txtHeight.Enabled = Not chkDefaultHeight.Checked
        If chkDefaultHeight.Checked Then
            txtHeight.Text = litDefaultHeight.Text
            valRequiredHeight.Enabled = False
        Else
            valRequiredHeight.Enabled = Not chkEmbed.Checked
        End If
    End Sub

    Protected Sub chkDefaultWidth_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkDefaultWidth.CheckedChanged
        txtWidth.Enabled = Not chkDefaultWidth.Checked
        If chkDefaultWidth.Checked Then
            txtWidth.Text = litDefaultWidth.Text
            valRequiredWidth.Enabled = False
        Else
            valRequiredWidth.Enabled = Not chkEmbed.Checked
        End If
    End Sub

    Protected Sub lnkUploadThumb_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkUploadThumb.Click
        _UC_ThumbUploaderPopup.OpenFileUpload()
    End Sub

    Protected Sub _UC_ThumbUploaderPopup_NeedCategoryRefresh() Handles _UC_ThumbUploaderPopup.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub _UC_ThumbUploaderPopup_UploadClicked() Handles _UC_ThumbUploaderPopup.UploadClicked
        If _UC_ThumbUploaderPopup.HasFile Then
            Dim strFileExt As String = Path.GetExtension(_UC_ThumbUploaderPopup.GetFileName())
            Dim strMessage As String = Nothing
            If IsValidFileType(strFileExt, strMessage, True) Then
                phdThumbUploadError.Visible = False : litThumbUploadError.Text = Nothing
                Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
                Dim strFileName As String = _UC_ThumbUploaderPopup.GetFileName
                Dim strExtension As String = Mid(strFileName, strFileName.LastIndexOf(".") + 1)
                litOriginalThumbName.Text = strFileName
                If GetMediaLinkID() = 0 Then
                    Dim strTempFolder As String = strMediaLinksFolder & "temp/"
                    litTempThumbName.Text = Guid.NewGuid.ToString & "_thumb" & strExtension
                    If Not Directory.Exists(Server.MapPath(strTempFolder)) Then Directory.CreateDirectory(Server.MapPath(strTempFolder))
                    _UC_ThumbUploaderPopup.SaveFile(Server.MapPath(strTempFolder & litTempThumbName.Text))
                    imgMediaThumb.ImageUrl = strTempFolder & litTempThumbName.Text & "?nocache=" & Now.Hour & Now.Minute & Now.Second
                    litImgName.Text = strTempFolder & litTempThumbName.Text
                    litImgName.Visible = True
                    lnkUploadThumb.Visible = False
                    lnkRemoveThumb.Visible = True
                Else
                    If Not Directory.Exists(Server.MapPath(strMediaLinksFolder)) Then Directory.CreateDirectory(Server.MapPath(strMediaLinksFolder))
                    Dim strThumbName As String = GetMediaLinkID() & "_thumb" & strExtension
                    If File.Exists(Server.MapPath(strMediaLinksFolder & strThumbName)) Then File.Delete(Server.MapPath(strMediaLinksFolder & strThumbName))
                    _UC_ThumbUploaderPopup.SaveFile(Server.MapPath(strMediaLinksFolder & strThumbName))
                    PrepareExistingMedia(GetMediaLinkID)
                End If
            Else
                phdThumbUploadError.Visible = True : litThumbUploadError.Text = strMessage
            End If
        End If
    End Sub

    Protected Sub lnkUploadFile_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkUploadFile.Click
        _UC_FileUploaderPopup.OpenFileUpload()
    End Sub

    Protected Sub _UC_FileUploaderPopup_NeedCategoryRefresh() Handles _UC_FileUploaderPopup.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub _UC_FileUploaderPopup_UploadClicked() Handles _UC_FileUploaderPopup.UploadClicked
        If _UC_FileUploaderPopup.HasFile Then
            Dim strFileExt As String = Path.GetExtension(_UC_FileUploaderPopup.GetFileName())
            Dim strMessage As String = Nothing
            If IsValidFileType(strFileExt, strMessage, False) Then
                phdFileUploadError.Visible = False : litFileUploadError.Text = Nothing
                Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
                Dim strFileName As String = _UC_FileUploaderPopup.GetFileName
                Dim strExtension As String = Mid(strFileName, strFileName.LastIndexOf(".") + 1)
                litOriginalFileName.Text = strFileName
                If GetMediaLinkID() = 0 Then
                    Dim strTempFolder As String = strMediaLinksFolder & "temp/"
                    litTempFileName.Text = Guid.NewGuid.ToString & strExtension
                    If Not Directory.Exists(Server.MapPath(strTempFolder)) Then Directory.CreateDirectory(Server.MapPath(strTempFolder))
                    _UC_FileUploaderPopup.SaveFile(Server.MapPath(strTempFolder & litTempFileName.Text))
                    lnkUploadFile.Visible = False
                    litPreview.Visible = True
                    lnkRemoveFile.Visible = True
                Else
                    If Not Directory.Exists(Server.MapPath(strMediaLinksFolder)) Then Directory.CreateDirectory(Server.MapPath(strMediaLinksFolder))
                    Dim strMediaName As String = GetMediaLinkID() & strExtension
                    If File.Exists(Server.MapPath(strMediaLinksFolder & strMediaName)) Then File.Delete(Server.MapPath(strMediaLinksFolder & strMediaName))
                    _UC_FileUploaderPopup.SaveFile(Server.MapPath(strMediaLinksFolder & strMediaName))
                    PrepareExistingMedia(GetMediaLinkID)
                End If
            Else
                phdFileUploadError.Visible = True : litFileUploadError.Text = strMessage
            End If
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, "No File Found!")
        End If
    End Sub

    Protected Sub lnkUploadFile2_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkUploadFile2.Click
        _UC_FileUploaderPopup2.OpenFileUpload()
    End Sub

    Protected Sub _UC_FileUploaderPopup2_NeedCategoryRefresh() Handles _UC_FileUploaderPopup2.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub _UC_FileUploaderPopup2_UploadClicked() Handles _UC_FileUploaderPopup2.UploadClicked
        If _UC_FileUploaderPopup2.HasFile Then
            Dim strFileExt As String = Path.GetExtension(_UC_FileUploaderPopup2.GetFileName())
            Dim strMessage As String = Nothing
            If IsValidFileType(strFileExt, strMessage, False) Then
                phdFileUploadError2.Visible = False : litFileUploadError2.Text = Nothing
                Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
                Dim strFileName As String = _UC_FileUploaderPopup2.GetFileName
                Dim strExtension As String = Mid(strFileName, strFileName.LastIndexOf(".") + 1)
                litOriginalFileName2.Text = strFileName
                If GetMediaLinkID() = 0 Then
                    Dim strTempFolder As String = strMediaLinksFolder & "temp/"
                    litTempFileName2.Text = Guid.NewGuid.ToString & strExtension
                    If Not Directory.Exists(Server.MapPath(strTempFolder)) Then Directory.CreateDirectory(Server.MapPath(strTempFolder))
                    _UC_FileUploaderPopup2.SaveFile(Server.MapPath(strTempFolder & litTempFileName2.Text))
                    lnkUploadFile2.Visible = False
                    litPreview.Visible = True
                    lnkRemoveFile2.Visible = True
                Else
                    If Not Directory.Exists(Server.MapPath(strMediaLinksFolder)) Then Directory.CreateDirectory(Server.MapPath(strMediaLinksFolder))
                    Dim strMediaName As String = GetMediaLinkID() & strExtension
                    If File.Exists(Server.MapPath(strMediaLinksFolder & strMediaName)) Then File.Delete(Server.MapPath(strMediaLinksFolder & strMediaName))
                    _UC_FileUploaderPopup2.SaveFile(Server.MapPath(strMediaLinksFolder & strMediaName))
                    PrepareExistingMedia(GetMediaLinkID)
                End If
            Else
                phdFileUploadError2.Visible = True : litFileUploadError2.Text = strMessage
            End If
        End If
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

    Function GetMediaLinkID() As Integer
        Dim numMediaLinkID As Integer = 0
        Try
            numMediaLinkID = CInt(litMediaLinkID.Text)
        Catch ex As Exception
            numMediaLinkID = 0
        End Try
        Return numMediaLinkID
    End Function

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        mvwMedia.SetActiveView(viwMediaList)
        updMain.Update()
    End Sub

    Protected Sub btnNewMedia_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnNewMedia.Click
        PrepareNewMedia()
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        If Page.IsValid Then
            If GetMediaLinkID() = 0 Then  '' on new
                SaveMediaLink(DML_OPERATION.INSERT)
            Else                        '' on update
                SaveMediaLink(DML_OPERATION.UPDATE)
            End If
        End If
    End Sub

    Private Sub SaveMediaLink(ByVal enumOperation As DML_OPERATION)

        Dim numParentID As Integer, chrParentType As Char
        Dim strEmbedSource As String, numMediaTypeID As Short, numHeight As Integer
        Dim numWidth As Integer, blnDownloadable As Boolean, strParameter As String
        Dim blnLive As Boolean, numNewID As Integer, strMessage As String = ""

        numParentID = ParentID
        chrParentType = ParentType
        numMediaTypeID = ddlMediaType.SelectedValue
        blnLive = chkLive.Checked
        If chkEmbed.Checked Then
            strEmbedSource = txtEmbedSource.Text
            numHeight = 0
            numWidth = 0
            strParameter = Nothing
            blnDownloadable = False
        Else
            strEmbedSource = Nothing
            numHeight = txtHeight.Text
            numWidth = txtWidth.Text
            strParameter = txtParameters.Text
            blnDownloadable = chkDownloadable.Checked
        End If

        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not MediaBLL._UpdateMediaLink( _
                                GetMediaLinkID, strEmbedSource, numMediaTypeID, _
                                numHeight, numWidth, blnDownloadable, strParameter, blnLive, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                RaiseEvent ShowMasterUpdate()
                GetMediaLinks()
            Case DML_OPERATION.INSERT
                If Not MediaBLL._AddMediaLink( _
                                 numParentID, chrParentType, strEmbedSource, _
                                 numMediaTypeID, numHeight, numWidth, blnDownloadable, _
                                 strParameter, blnLive, numNewID, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
                Dim strTempFolder As String = strMediaLinksFolder & "temp/"
                '' Thumb Saving
                If Not String.IsNullOrEmpty(litTempThumbName.Text) Then
                    Try
                        Dim strExtension As String = Mid(litTempThumbName.Text, litTempThumbName.Text.LastIndexOf(".") + 1)
                        If File.Exists(Server.MapPath(strMediaLinksFolder & numNewID & "_thumb" & strExtension)) Then
                            File.Delete(Server.MapPath(strMediaLinksFolder & numNewID & "_thumb" & strExtension))
                        End If
                        File.Move(Server.MapPath(strTempFolder & litTempThumbName.Text), _
                                  Server.MapPath(strMediaLinksFolder & numNewID & "_thumb" & strExtension))
                    Catch ex As Exception
                    End Try
                End If
                '' File Saving
                If Not String.IsNullOrEmpty(litTempFileName.Text) Then
                    Try
                        Dim strExtension As String = Mid(litTempFileName.Text, litTempFileName.Text.LastIndexOf(".") + 1)
                        If File.Exists(Server.MapPath(strMediaLinksFolder & numNewID & strExtension)) Then
                            File.Delete(Server.MapPath(strMediaLinksFolder & numNewID & strExtension))
                        End If
                        File.Move(Server.MapPath(strTempFolder & litTempFileName.Text), _
                                  Server.MapPath(strMediaLinksFolder & numNewID & strExtension))
                    Catch ex As Exception
                    End Try
                End If
                '' File Saving 2
                If Not String.IsNullOrEmpty(litTempFileName2.Text) Then
                    Try
                        Dim strExtension As String = Mid(litTempFileName2.Text, litTempFileName2.Text.LastIndexOf(".") + 1)
                        If File.Exists(Server.MapPath(strMediaLinksFolder & numNewID & strExtension)) Then
                            File.Delete(Server.MapPath(strMediaLinksFolder & numNewID & strExtension))
                        End If
                        File.Move(Server.MapPath(strTempFolder & litTempFileName2.Text), _
                                  Server.MapPath(strMediaLinksFolder & numNewID & strExtension))
                    Catch ex As Exception
                    End Try
                End If
                RaiseEvent ShowMasterUpdate()
                GetMediaLinks()
        End Select

    End Sub

    Protected Sub lnkRemoveThumb_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkRemoveThumb.Click
        Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
        Dim strImageURL As String = imgMediaThumb.ImageUrl
        If strImageURL.Contains("/temp/") Then strMediaLinksFolder &= "temp/"
        Dim strFileName As String = Mid(strImageURL, strImageURL.LastIndexOf("/") + 2)
        strFileName = Mid(strFileName, 1, strFileName.LastIndexOf("?"))
        If File.Exists(Server.MapPath(strMediaLinksFolder & strFileName)) Then File.Delete(Server.MapPath(strMediaLinksFolder & strFileName))
        imgMediaThumb.ImageUrl = Nothing
        If GetMediaLinkID() = 0 Then
            If ddlMediaType.SelectedValue > 0 Then CheckType()
            lnkUploadThumb.Visible = True
            lnkRemoveThumb.Visible = False
        Else
            PrepareExistingMedia(GetMediaLinkID)
        End If
        RaiseEvent ShowMasterUpdate()
    End Sub

    Protected Sub lnkRemoveFile_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkRemoveFile.Click
        Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
        If GetMediaLinkID() = 0 Then
            If Not String.IsNullOrEmpty(litTempFileName.Text) Then
                If File.Exists(Server.MapPath(strMediaLinksFolder & "temp/" & litTempFileName.Text)) Then File.Delete(Server.MapPath(strMediaLinksFolder & "temp/" & litTempFileName.Text))
            End If
            If ddlMediaType.SelectedValue > 0 Then CheckType()
            lnkUploadFile.Visible = True
            lnkRemoveFile.Visible = False
        Else
            If File.Exists(Server.MapPath(strMediaLinksFolder & litMediaFileName.Text)) Then File.Delete(Server.MapPath(strMediaLinksFolder & litMediaFileName.Text))
            PrepareExistingMedia(GetMediaLinkID)
        End If

    End Sub

    Protected Sub lnkRemoveFile2_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkRemoveFile2.Click
        Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
        If GetMediaLinkID() = 0 Then
            If Not String.IsNullOrEmpty(litTempFileName2.Text) Then
                If File.Exists(Server.MapPath(strMediaLinksFolder & "temp/" & litTempFileName2.Text)) Then File.Delete(Server.MapPath(strMediaLinksFolder & "temp/" & litTempFileName2.Text))
            End If
            If ddlMediaType.SelectedValue > 0 Then CheckType()
            'lnkUploadThumb.Visible = True
            'lnkRemoveThumb.Visible = False
        Else
            If File.Exists(Server.MapPath(strMediaLinksFolder & litMediaFileName2.Text)) Then File.Delete(Server.MapPath(strMediaLinksFolder & litMediaFileName2.Text))
            PrepareExistingMedia(GetMediaLinkID)
        End If

    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        Dim strMessage As String = GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified")
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If MediaBLL._DeleteMediaLink(GetMediaLinkID, strMessage) Then
            Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
            If File.Exists(Server.MapPath(strMediaLinksFolder & litMediaFileName.Text)) Then
                File.Delete(Server.MapPath(strMediaLinksFolder & litMediaFileName.Text))
            End If
            GetMediaLinks()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub

    Protected Sub ValidateMediaFile(ByVal source As Object, ByVal args As System.Web.UI.WebControls.ServerValidateEventArgs) Handles cvMediaFile.ServerValidate
        If Not chkEmbed.Checked AndAlso lnkUploadFile.Visible Then
            args.IsValid = False
            updUploadFile.Update()
        Else
            args.IsValid = True
        End If
    End Sub

    Protected Sub ValidateMediaFile2(ByVal source As Object, ByVal args As System.Web.UI.WebControls.ServerValidateEventArgs) Handles cvMediaFile2.ServerValidate
        If Not chkEmbed.Checked AndAlso lnkUploadFile2.Visible Then
            args.IsValid = False
            updUploadFile2.Update()
        Else
            args.IsValid = True
        End If
    End Sub
End Class
