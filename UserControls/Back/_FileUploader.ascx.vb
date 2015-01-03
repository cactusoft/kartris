'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'Mods for multiple file upload - August 2014:
'Craig Moore
'Deadline Automation Limited
'www.deadline-automation.com

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisImages
Partial Class _FileUploader
    Inherits System.Web.UI.UserControl

    Private c_enumImageType As IMAGE_TYPE = IMAGE_TYPE.enum_CategoryImage
    Private c_strUploadPath As String
    Private c_numItemID As Long
    Private c_numParentID As Integer
    Private c_strFileName As String
    Private c_blnOneFileOnly As Boolean

    Public Event NeedCategoryRefresh()

    Public WriteOnly Property ImageType() As IMAGE_TYPE
        Set(ByVal value As IMAGE_TYPE)
            c_enumImageType = value
        End Set
    End Property

    Public Property AllowMultiple As Boolean
        Get
            Return _UC_UploaderPopup.AllowMultiple
        End Get
        Set(value As Boolean)
            _UC_UploaderPopup.AllowMultiple = value
        End Set
    End Property


    Public Property ItemID() As Long
        Set(ByVal value As Long)
            c_numItemID = value
        End Set
        Get
            Return c_numItemID
        End Get
    End Property

    Public Property ParentID() As Integer
        Set(ByVal value As Integer)
            c_numParentID = value
        End Set
        Get
            Return c_numParentID
        End Get
    End Property

    Public Sub LoadImages()
        If c_numItemID = 0 Then Return
        c_strUploadPath = CreateFolderURL(c_enumImageType, CStr(c_numItemID), CStr(c_numParentID))
        litInfo.Text = c_strUploadPath
        _UC_ItemSorter.ClearItems()
        _UC_ItemSorter.FolderPath = c_strUploadPath
        btnAddFile.Visible = True

        If Not Directory.Exists(Server.MapPath(c_strUploadPath)) Then Return
        _UC_ItemSorter.LoadItemsInSorter()
        If chkOneItemOnly.Checked AndAlso _UC_ItemSorter.NoOfItems() > 0 Then
            btnAddFile.Visible = False
        End If
    End Sub

    Public WriteOnly Property OneItemOnly() As Boolean
        Set(ByVal value As Boolean)
            c_blnOneFileOnly = value
            chkOneItemOnly.Checked = value
            _UC_UploaderPopup.AllowMultiple = Not value
        End Set
    End Property

    Public Sub ClearItems()
        _UC_ItemSorter.ClearItems()
    End Sub

    Protected Sub btnAddFile_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddFile.Click
        _UC_UploaderPopup.OpenFileUpload()
    End Sub

    Public Sub SaveFile()

        Select Case c_enumImageType
            Case IMAGE_TYPE.enum_CategoryImage
                Session("tab") = "images"
            Case IMAGE_TYPE.enum_ProductImage
                Session("tab") = "images"
            Case IMAGE_TYPE.enum_VersionImage
                Session("tab") = "versions"
                Session("inner-tab") = "images"
            Case IMAGE_TYPE.enum_PromotionImage
                Session("tab") = "images"
        End Select
        If _UC_UploaderPopup.HasFile() Then
            CreatePath()
            If Not Directory.Exists(Server.MapPath(c_strUploadPath)) Then
                Directory.CreateDirectory(Server.MapPath(c_strUploadPath))
            End If
            ' Load a list of extensions for each file in the upload control.
            Dim strFileExts As New List(Of String)
            For Each FileName As String In _UC_UploaderPopup.GetFileNames()
                strFileExts.Add(Path.GetExtension(FileName))
            Next

            'Need to check the file being uploaded is not
            'of a type listed in the excludedUploadFiles
            'setting in the web.config. For security, we
            'block the uploader from uploading files of
            'such types. This prevents an attacker who has
            'gained back end access to Kartris from being
            'able to upload files that could be used to
            'modify or write new files, or read sensitive
            'info such as from the web.config. Basically,
            'damage limitation.

            '(Similar code in _UploaderPopup.ascx.vb)
            Dim arrExcludedFileTypes() As String = ConfigurationManager.AppSettings("ExcludedUploadFiles").ToString().Split(",")
            For Each ext As String In strFileExts
                For i As Integer = 0 To arrExcludedFileTypes.GetUpperBound(0)
                    If Replace(ext.ToLower, ".", "") = arrExcludedFileTypes(i).ToLower Then
                        'Banned file type, don't upload
                        'Log error so attempts can be seen in logs
                        CkartrisFormatErrors.LogError("Attempt to upload a file of type: " & arrExcludedFileTypes(i).ToLower)
                        litStatus.Text = "It is not permitted to upload files of this type. Change 'ExcludedUploadFiles' in the web.config if you need to upload this file."
                        popExtender.Show()
                        Exit Sub
                    End If
                Next
            Next

            'This is a softer check, it checks images are of an acceptable
            'type. The security check on file type above will overrule
            'this 'allow' list here.
            Dim arrAllowedImageTypes() As String = KartSettingsManager.GetKartConfig("backend.imagetypes").Split(",")
            Dim CheckPassed As Boolean = False
            For Each ext As String In strFileExts
                CheckPassed = False     ' Per loop reset.
                For i As Integer = 0 To arrAllowedImageTypes.GetUpperBound(0)
                    If ext.ToLower = arrAllowedImageTypes(i).ToLower Then
                        'UploadFile()
                        CheckPassed = True
                        Exit For
                        'Exit Sub
                    End If
                Next
                If Not CheckPassed Then
                    ' Check failed, there is a file that is not acceptable.
                    CkartrisFormatErrors.LogError("Attempt to upload a file with rejected extension: " & ext.ToLower)
                    litStatus.Text = "An attempt was made to upload a file with an extension that is not permitted. Add this file to the accepted file extension list if required. Extension was " & ext.ToLower
                    popExtender.Show()
                    Exit Sub
                End If
            Next
            UploadFile()
        Else
            litStatus.Text = GetGlobalResourceObject("_Kartris", "ContentText_NoFile")
            popExtender.Show()
        End If
    End Sub

    Private Sub CreatePath()
        Select Case c_enumImageType
            Case IMAGE_TYPE.enum_CategoryImage
                c_strFileName = "c" + CStr(c_numItemID) + "_"
            Case IMAGE_TYPE.enum_ProductImage
                c_strFileName = "p" + CStr(c_numItemID) + "_"
            Case IMAGE_TYPE.enum_VersionImage
                c_strFileName = "v" + CStr(c_numItemID) + "_"
            Case IMAGE_TYPE.enum_PromotionImage
                c_strFileName = CStr(c_numItemID)
            Case IMAGE_TYPE.enum_OtherImage
                c_strFileName = "o" + CStr(c_numItemID) + "_"
        End Select
    End Sub

    Private Sub UploadFile()
        Try
            Dim existingFiles() As String = Nothing
            Dim numTotalFiles = 0
            ' --------------------------
            Dim strTempName As String = String.Empty

            Dim FileNames As List(Of String) = _UC_UploaderPopup.GetFileNames

            If c_blnOneFileOnly And FileNames.Count > 1 Then
                ' Error. Too many files. 
                CkartrisFormatErrors.LogError("Attempt to upload too many files. OneFileOnly set as true while uploaded file count is " & FileNames.Count.ToString)
                litStatus.Text = "An attempt was made to upload more than one file. This is not permitted in the current context."
                popExtender.Show()
                Exit Sub
            End If

            For I = 0 To FileNames.Count - 1
                ' Cycle through all of the file names in order and save each one individually.
                ' Get list of existing files.
                existingFiles = Directory.GetFiles(Server.MapPath(c_strUploadPath))
                numTotalFiles = existingFiles.Length()

generateNewName:
                Randomize()

                If c_blnOneFileOnly Then
                    ' Used if the target folder will only ever have one file in it. 
                    strTempName = c_numItemID & Path.GetExtension(FileNames(I))
                Else
                    strTempName = c_strFileName & CStr(Int(2 * Rnd() + (numTotalFiles * Rnd() + numTotalFiles / 2))) & Path.GetExtension(_UC_UploaderPopup.GetFileName())
                End If

                If Not File.Exists(Server.MapPath(c_strUploadPath & strTempName)) Then
                    _UC_UploaderPopup.SaveFile(Server.MapPath(c_strUploadPath & strTempName), I, I < (FileNames.Count - 1))
                    Dim strCompressQuality As String = KartSettingsManager.GetKartConfig("general.imagequality")
                    If IsNumeric(strCompressQuality) AndAlso strCompressQuality > 0 AndAlso strCompressQuality < 100 Then CompressImage(Server.MapPath(c_strUploadPath & strTempName), CLng(strCompressQuality))
                    ' Method below REM'd out as pointless. It is supersceded by the later call to LoadImages()
                    '_UC_ItemSorter.AddNewItem(strTempName)
                ElseIf c_blnOneFileOnly Then
                    ' Prevent infinite loop.
                    CkartrisFormatErrors.LogError("Existing file found when c_blnOneFileOnly = True")
                    litStatus.Text = "A file already exists where we are trying to put a new file. Internal Error."
                    popExtender.Show()
                    Exit Sub
                Else
                    GoTo generateNewName
                End If
            Next
            ' Show images.
            LoadImages()
            updMain.Update()
        Catch ex As Exception
            litStatus.Text = "Fail " & ex.Message
        End Try
    End Sub

    Protected Sub _UC_ItemSorter_ItemRemoved() Handles _UC_ItemSorter.ItemRemoved
        If chkOneItemOnly.Checked AndAlso _UC_ItemSorter.NoOfItems() > 0 Then
            btnAddFile.Visible = False
        Else
            btnAddFile.Visible = True
        End If
        updUploaderArea.Update()
    End Sub

    Protected Sub _UC_UploaderPopup_NeedCategoryRefresh() Handles _UC_UploaderPopup.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub _UC_ItemSorter_NeedCategoryRefresh() Handles _UC_ItemSorter.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub _UC_UploaderPopup_UploadClicked() Handles _UC_UploaderPopup.UploadClicked
        SaveFile()
    End Sub

    Public Function NoOfItems() As Integer
        Return _UC_ItemSorter.NoOfItems()
    End Function

    Public Sub ShowUploadButton()
        btnAddFile.Visible = True
        updUploaderArea.Update()
    End Sub

    Public Sub HideUploadButton()
        btnAddFile.Visible = False
        updUploaderArea.Update()
    End Sub

End Class
