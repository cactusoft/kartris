'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

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
Imports CkartrisImages
Imports CkartrisDataManipulation

Partial Class UserControls_Back_EditPromotion
    Inherits System.Web.UI.UserControl

    Dim strPromotionsFolder As String = "~/Images/Promotions/"
    Dim strPromotionsTempFolder As String = "~/Images/Promotions/Temp/"
    Public Event ShowMasterUpdate()
    Public Event NeedCategoryRefresh()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        '' validation group for the controls
        valRequiredStartDate.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
        valRequiredEndDate.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
        valRequiredMaxQuantity.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
        valRequiredOrderNo.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
        valCompareCheckStartIsDate.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
        valCompareCheckPeriod.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
        valCompareCheckMaxQuantity.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
        valCompareCheckOrderBy.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions

        txtToday.Text = Now.Date

        '' loads the language elements of the promotion
        If GetPromotionID() = 0 Then '' new
            _UC_LanguageContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Promotions, True)
        Else                        '' update
            _UC_LanguageContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Promotions, False, GetPromotionID())
        End If

        GetPromotionImages()
    End Sub

    ''' <summary>
    ''' - checks if the promotion's parts contain strings or no
    ''' - calls the save function depending on the current status (new/update)
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function SaveChanges() As Boolean

        '' check if Part-A has parts or no
        If Not _UC_PromotionStringBuilder_PartA.HasStrings() Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Promotions", "ContentText_PartACannotBeEmpty"))
            Return False
        End If

        '' check if Part-B has parts or no
        If Not _UC_PromotionStringBuilder_PartB.HasStrings() Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Promotions", "ContentText_PartBCannotBeEmpty"))
            Return False
        End If

        '' calling the save method for (INSERT/UPDATE)
        If GetPromotionID() = 0 Then '' new
            If Not SavePromotion(DML_OPERATION.INSERT) Then Return False
        Else                        '' update
            If Not SavePromotion(DML_OPERATION.UPDATE) Then Return False
        End If
        Return True

    End Function

    ''' <summary>
    ''' saving the changes 
    '''  - (update for the existing promotion)
    '''  - (add new promotion)
    '''  Steps:
    '''  1. read the Language Elements of the promotion to save them.
    '''  2. read the main promotion info.
    '''  3. collecting the promotion's strings
    '''  4. saving the changes
    ''' </summary>
    ''' <param name="enumOperation"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function SavePromotion(ByVal enumOperation As DML_OPERATION) As Boolean

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 1. Language Contents
        Dim tblLanguageContents As New DataTable
        tblLanguageContents = _UC_LanguageContainer.ReadContent()

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 2. Promotion Main Info.
        Dim blnLive As Boolean = chkLive.Checked
        Dim dtStartDate As Date = CDate(txtStartDate.Text)
        Dim dtEndDate As Date = CDate(txtEndDate.Text)
        Dim intMaxQty As Byte = CByte(txtMaxQuantity.Text)
        Dim intOrderBy As Short = CShort(txtOrderNo.Text)

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 3. Collecting the promotion's strings
        Dim tblParts As New DataTable
        tblParts = _UC_PromotionStringBuilder_PartA.ReadParts("a")
        tblParts.Merge(_UC_PromotionStringBuilder_PartB.ReadParts("b"))

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 4. Saving the changes
        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not PromotionsBLL._UpdatePromotion( _
                                tblLanguageContents, GetPromotionID(), dtStartDate, dtEndDate, intMaxQty, _
                                intOrderBy, blnLive, tblParts, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False

                End If
            Case DML_OPERATION.INSERT
                Dim intPromotionID As Integer = 0
                If Not PromotionsBLL._AddNewPromotion( _
                                tblLanguageContents, intPromotionID, dtStartDate, dtEndDate, intMaxQty, intOrderBy, _
                                 blnLive, tblParts, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                    litPromotionID.Text = CStr(intPromotionID)
                    GetPromotionImages()
                End If
                '' File Saving
                If Not String.IsNullOrEmpty(litTempFileName.Text) Then
                    Try
                        Dim strExtension As String = Mid(litTempFileName.Text, litTempFileName.Text.LastIndexOf(".") + 1)
                        If Not Directory.Exists(Server.MapPath(strPromotionsFolder & intPromotionID & "/")) Then Directory.CreateDirectory(Server.MapPath(strPromotionsFolder & intPromotionID & "/"))
                        File.Move(Server.MapPath(strPromotionsTempFolder & litTempFileName.Text), _
                                  Server.MapPath(strPromotionsFolder & intPromotionID & "/" & intPromotionID & strExtension))
                    Catch ex As Exception
                    End Try
                End If
        End Select
        RaiseEvent ShowMasterUpdate()

        Return True

    End Function

    ''' <summary>
    ''' returns the promotion id (saved in a hidden control)
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function GetPromotionID() As Integer
        If litPromotionID.Text <> "" Then
            Return CInt(litPromotionID.Text)
        End If
        Return 0
    End Function

    ''' <summary>
    ''' prepares for edit
    ''' </summary>
    ''' <param name="PromotionID"></param>
    ''' <remarks></remarks>
    Public Sub EditPromotion(ByVal PromotionID As Integer)

        litPromotionID.Text = CStr(PromotionID)

        If GetPromotionID() = 0 Then '' new
            PrepareNewPromotion()
        Else                        '' update
            GetPromotionInfo()
        End If
    End Sub

    ''' <summary>
    ''' prepares the controls for new entries
    ''' </summary>
    ''' <remarks></remarks>
    Sub PrepareNewPromotion()
        chkLive.Checked = False
        txtStartDate.Text = Now.Year & "/" & Now.Month & "/" & Now.Day : txtEndDate.Text = ""
        txtMaxQuantity.Text = "0" : txtOrderNo.Text = "0"
        _UC_LanguageContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Promotions, True)

        _UC_PromotionStringBuilder_PartA.CreatePromotionPart("a")
        _UC_PromotionStringBuilder_PartA.ClearStrings()

        _UC_PromotionStringBuilder_PartB.CreatePromotionPart("b")
        _UC_PromotionStringBuilder_PartB.ClearStrings()

        GetPromotionImages()
    End Sub

    ''' <summary>
    ''' reads the promotion data from the db (for edit)
    ''' </summary>
    ''' <remarks></remarks>
    Sub GetPromotionInfo()

        Dim tblPromotion As New DataTable
        tblPromotion = PromotionsBLL._GetPromotionByID(GetPromotionID())

        If tblPromotion.Rows.Count = 0 Then Return '' The promotion is not exist

        chkLive.Checked = CBool(tblPromotion.Rows(0)("PROM_Live"))
        txtStartDate.Text = Format(CDate(FixNullFromDB(tblPromotion.Rows(0)("PROM_StartDate"))), "yyyy/MM/dd")
        txtEndDate.Text = Format(CDate(FixNullFromDB(tblPromotion.Rows(0)("PROM_EndDate"))), "yyyy/MM/dd")
        txtMaxQuantity.Text = CStr(FixNullFromDB(tblPromotion.Rows(0)("PROM_MaxQuantity")))
        txtOrderNo.Text = CStr(FixNullFromDB(tblPromotion.Rows(0)("PROM_OrderByValue")))

        _UC_LanguageContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Promotions, False, GetPromotionID())

        '' reads the promotion's strings
        _UC_PromotionStringBuilder_PartA.GetPromotionData("a", GetPromotionID())
        _UC_PromotionStringBuilder_PartB.GetPromotionData("b", GetPromotionID())

        GetPromotionImages()

    End Sub

    ''' <summary>
    ''' Event "SelectionChanged"
    '''   => used to prevent the error that caused by the autocomplete contol in case 
    '''        of more than one autocomplete control in the page.
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PromotionStringBuilder_PartA_SelectionChanged() Handles _UC_PromotionStringBuilder_PartA.SelectionChanged
        _UC_PromotionStringBuilder_PartB.ResetSelection()
    End Sub

    ''' <summary>
    ''' Event "SelectionChanged"
    '''   => used to prevent the error that caused by the autocomplete contol in case 
    '''        of more than one autocomplete control in the page.
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PromotionStringBuilder_PartB_SelectionChanged() Handles _UC_PromotionStringBuilder_PartB.SelectionChanged
        _UC_PromotionStringBuilder_PartA.ResetSelection()
    End Sub
    ''' <summary>
    ''' Loads the promotion image-related control
    ''' </summary>
    ''' <remarks></remarks>
    Sub GetPromotionImages()
        If GetPromotionID() = 0 Then
            If File.Exists(Server.MapPath(strPromotionsTempFolder & litTempFileName.Text)) Then
                imgPromotionImage.ImageUrl = strPromotionsTempFolder & litTempFileName.Text & "?nocache=" & Now.Hour & Now.Minute & Now.Second
                lnkUploadFile.Visible = False
                lnkRemoveFile.Visible = True
            Else
                imgPromotionImage.ImageUrl = Nothing
                If File.Exists(Server.MapPath("~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png")) Then
                    imgPromotionImage.ImageUrl = "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png?nocache=" & Now.Hour & Now.Minute & Now.Second
                End If
                lnkUploadFile.Visible = True
                lnkRemoveFile.Visible = False
            End If
        Else
            Dim dirMediaImages As New DirectoryInfo(Server.MapPath(strPromotionsFolder & GetPromotionID() & "/"))
            Dim objFile() As FileInfo = Nothing
            Try
                objFile = dirMediaImages.GetFiles(GetPromotionID() & ".*")
            Catch ex As Exception
            End Try
            If objFile IsNot Nothing AndAlso objFile.Length > 0 Then
                imgPromotionImage.ImageUrl = strPromotionsFolder & GetPromotionID() & "/" & objFile(0).Name & "?nocache=" & Now.Hour & Now.Minute & Now.Second
                litPromotionFileName.Text = objFile(0).Name
                lnkUploadFile.Visible = False
                lnkRemoveFile.Visible = True
            Else
                imgPromotionImage.ImageUrl = Nothing
                If File.Exists(Server.MapPath("~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png")) Then
                    imgPromotionImage.ImageUrl = "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png?nocache=" & Now.Hour & Now.Minute & Now.Second
                End If
                lnkUploadFile.Visible = True
                lnkRemoveFile.Visible = False
            End If
        End If

    End Sub
    Protected Sub lnkRemoveFile_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkRemoveFile.Click
        If GetPromotionID() = 0 Then
            If Not String.IsNullOrEmpty(litTempFileName.Text) Then
                If File.Exists(Server.MapPath(strPromotionsTempFolder & litTempFileName.Text)) Then File.Delete(Server.MapPath(strPromotionsTempFolder & litTempFileName.Text))
            End If
            imgPromotionImage.ImageUrl = Nothing
            lnkUploadFile.Visible = True
            lnkRemoveFile.Visible = False
        Else
            If File.Exists(Server.MapPath(strPromotionsFolder & GetPromotionID() & "/" & litPromotionFileName.Text)) Then File.Delete(Server.MapPath(strPromotionsFolder & GetPromotionID() & "/" & litPromotionFileName.Text))
            imgPromotionImage.ImageUrl = Nothing
            lnkUploadFile.Visible = True
            lnkRemoveFile.Visible = False
        End If
        If File.Exists(Server.MapPath("~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png")) Then
            imgPromotionImage.ImageUrl = "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png?nocache=" & Now.Hour & Now.Minute & Now.Second
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
            Dim strFileName As String = _UC_FileUploaderPopup.GetFileName
            Dim strExtension As String = Mid(strFileName, strFileName.LastIndexOf(".") + 1)
            litOriginalFileName.Text = strFileName
            If GetPromotionID() = 0 Then
                litTempFileName.Text = Guid.NewGuid.ToString & strExtension
                If Not Directory.Exists(Server.MapPath(strPromotionsTempFolder)) Then Directory.CreateDirectory(Server.MapPath(strPromotionsTempFolder))
                _UC_FileUploaderPopup.SaveFile(Server.MapPath(strPromotionsTempFolder & litTempFileName.Text))
            Else
                Dim strThisPromotionFolder As String = strPromotionsFolder & GetPromotionID() & "/"
                If Not Directory.Exists(Server.MapPath(strThisPromotionFolder)) Then Directory.CreateDirectory(Server.MapPath(strThisPromotionFolder))
                Dim strPromotionImageName As String = GetPromotionID() & strExtension
                If File.Exists(Server.MapPath(strThisPromotionFolder & strPromotionImageName)) Then File.Delete(Server.MapPath(strThisPromotionFolder & strPromotionImageName))
                _UC_FileUploaderPopup.SaveFile(Server.MapPath(strThisPromotionFolder & strPromotionImageName))
            End If
            GetPromotionImages()
        End If
    End Sub
End Class
