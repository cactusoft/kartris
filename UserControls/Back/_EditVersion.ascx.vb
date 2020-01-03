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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class _EditVersion
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' raised when the version is saved
    ''' </summary>
    ''' <remarks></remarks>
    Public Event VersionSaved()
    Public Event NeedCategoryRefresh()

    Dim numProductID As Int64 = _GetProductID()
    Dim blnUseCombinationPrice As Boolean = IIf(ObjectConfigBLL.GetValue("K:product.usecombinationprice", numProductID) = "1", True, False) And ProductsBLL._NumberOfCombinations(numProductID) > 0

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        LoadVersionElements()
        If Not Page.IsPostBack Then
            Try
                '' validation group for the controls
                valRequiredCodeNumber.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRequiredPrice.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRequiredWeight.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRequiredDelivery.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRequiredRRP.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRequiredStockQty.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRequiredWarnLevel.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRequiredCustomizationCost.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRegexPrice.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRegexWeight.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRegexRRP.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valCompareDelivery.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valCompareStockQuantity.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valCompareWarningLevel.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valRegexCustomizationCost.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions

                If ddlCustomerGroup.Items.Count <= 1 Then
                    Dim drCGs As DataRow() = GetCustomerGroupsFromCache.Select("CG_Live = 1 AND LANG_ID=" & Session("_LANG"))
                    ddlCustomerGroup.DataTextField = "CG_Name"
                    ddlCustomerGroup.DataValueField = "CG_ID"
                    ddlCustomerGroup.DataSource = drCGs
                    ddlCustomerGroup.DataBind()
                End If
                If TaxRegime.VTax_Type = "rate" Then
                    If ddlTaxBand.Items.Count <= 1 Then
                        ddlTaxBand.DataTextField = "T_TaxRateString"
                        ddlTaxBand.DataValueField = "T_ID"
                        ddlTaxBand.DataSource = GetTaxRateFromCache()
                        ddlTaxBand.DataBind()
                    End If
                    valCompareTaxBand.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                End If
                If TaxRegime.VTax_Type2 = "rate" Then
                    If ddlTaxBand2.Items.Count <= 1 Then
                        ddlTaxBand2.DataTextField = "T_TaxRateString"
                        ddlTaxBand2.DataValueField = "T_ID"
                        ddlTaxBand2.DataSource = GetTaxRateFromCache()
                        ddlTaxBand2.DataBind()
                    End If
                    valCompareTaxBand2.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
                End If
            Catch ex As Exception
                '
            End Try
        End If
    End Sub

    ''' <summary>
    ''' creates the form and prepare it for insert/update/clone
    ''' </summary>
    ''' <param name="numVersionID"></param>
    ''' <param name="blnClone"></param>
    ''' <remarks></remarks>
    Public Sub CreateVersionData(ByVal numVersionID As Long, Optional ByVal blnClone As Boolean = False)

        litVersionID.Text = numVersionID

        If GetVersionID() = 0 Then  '' new
            ClearForm()
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Versions, True)
            SetVersionType() '' depending on the product's type
        Else                        '' update/clone
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Versions, False, GetVersionID())
            LoadMainInfo()  '' loads the main info of the version
        End If

        '' to indicate if operation is cloning
        chkClone.Checked = blnClone

        '' check the product type to know if we should disable some fields
        If ProductsBLL._GetProductType_s(_GetProductID()) = "s" Then
            _UC_LangContainer.SetFieldEditable(LANG_ELEM_FIELD_NAME.Name, False)
            _UC_LangContainer.SetFieldEditable(LANG_ELEM_FIELD_NAME.Description, False)
        End If
    End Sub

    ''' <summary>
    ''' loads the language elements for the current version
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadVersionElements()
        If GetVersionID() = 0 Then  '' new
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Versions, True)
        Else                        '' update/clone
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Versions, False, GetVersionID())
        End If
        '' check the product type to know if we should disable some fields
        If ProductsBLL._GetProductType_s(_GetProductID()) = "s" Then
            _UC_LangContainer.SetFieldEditable(LANG_ELEM_FIELD_NAME.Name, False)
            _UC_LangContainer.SetFieldEditable(LANG_ELEM_FIELD_NAME.Description, False)
        End If
    End Sub

    ''' <summary>
    ''' selects the proper version type (when the operation is insert only),
    '''   depending on the product's type (read-only)
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub SetVersionType()
        Select ProductsBLL._GetProductType_s(_GetProductID())
            Case "m" '' Multiple Version Product
                ddlVersionType.SelectedValue = "v"
            Case "o" '' Optional Product
                ddlVersionType.SelectedValue = "b"
            Case "s" '' Single Version Product
                ddlVersionType.SelectedValue = "v" '' will not happen, because the version should already be created.
        End Select
    End Sub

    Public Function GetVersionType() As Char
        Return CChar(ddlVersionType.SelectedValue())
    End Function


    ''' <summary>
    ''' - checkes the existance of the entered code number
    ''' - calls the save function depending on the current status (new/clone/update)
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function SaveChanges() As Boolean

        '' checking if the code number exist or not
        If VersionsBLL._IsCodeNumberExist(txtCodeNumber.Text, , IIf(chkClone.Checked, -1, GetVersionID())) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
            Return False
        End If

        If (GetVersionID() = 0) OrElse (GetVersionID() <> 0 AndAlso chkClone.Checked) Then
            '' if new or clone => INSERT
            If Not SaveVersion(DML_OPERATION.INSERT) Then Return False
        Else
            '' if update => UPDATE
            If Not SaveVersion(DML_OPERATION.UPDATE) Then Return False
        End If

        Return True

    End Function

    ''' <summary>
    ''' saving the changes 
    '''  - (update for the existing version)
    '''  - (add/clone new version)
    '''  Steps:
    '''  1. read the Language Elements of the version to save them.
    '''  2. read the main version info.
    '''  3. save the changes (update/insert) 
    '''       --> rais the VersionSaved Event.
    ''' </summary>
    ''' <param name="enumOperation"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function SaveVersion(ByVal enumOperation As DML_OPERATION) As Boolean

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 1. Language Contents
        Dim tblLanguageContents As New DataTable
        tblLanguageContents = _UC_LangContainer.ReadContent()

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 2. Version Main Info.
        Dim strCodeNumber As String = txtCodeNumber.Text
        Dim blnLive As Boolean = chkLive.Checked
        Dim intGroupID As Integer = CInt(ddlCustomerGroup.SelectedValue())
        Dim decPrice As Decimal = HandleDecimalValues(txtPriceIncTax.Text)
        Dim bytTaxBand As Byte = 0
        Dim bytTaxBand2 As Byte = 0
        If TaxRegime.VTax_Type = "rate" Then
            bytTaxBand = CByte(ddlTaxBand.SelectedValue)
        ElseIf TaxRegime.VTax_Type = "boolean" Then
            Dim dtTaxes As DataTable = GetTaxRateFromCache()
            For Each rw As DataRow In dtTaxes.Rows
                If chkTaxBand.Checked Then '' taxable, need to find the 1st non-zero tax
                    If rw("T_TaxRate") > 0 Then bytTaxBand = rw("T_ID") : Exit For
                Else                        '' not taxable, need to find the 1st zero tax
                    If rw("T_TaxRate") = 0 Then bytTaxBand = rw("T_ID") : Exit For
                End If
            Next
        End If
        If TaxRegime.VTax_Type2 = "rate" Then
            bytTaxBand2 = CByte(ddlTaxBand2.SelectedValue)
        ElseIf TaxRegime.VTax_Type2 = "boolean" Then
            Dim dtTaxes As DataTable = GetTaxRateFromCache()
            For Each rw As DataRow In dtTaxes.Rows
                If chkTaxBand2.Checked Then '' taxable, need to find the 1st non-zero tax
                    If rw("T_TaxRate") > 0 Then bytTaxBand2 = rw("T_ID") : Exit For
                Else                        '' not taxable, need to find the 1st zero tax
                    If rw("T_TaxRate") = 0 Then bytTaxBand2 = rw("T_ID") : Exit For
                End If
            Next
        End If
        Dim snglWeight As Single = HandleDecimalValues(txtWeight.Text)
        Dim decRRP As Decimal = HandleDecimalValues(txtRRP.Text)
        Dim bytDelivery As Byte = CByte(txtDeliveryTime.Text)
        Dim sngStockQty As Single = CSng(txtStockQuantity.Text)
        Dim sngWarnLevel As Single = CSng(txtWarningLevel.Text)
        Dim strDownloadType As String = CChar(ddlDownloadType.SelectedValue())
        Dim strDownloadInfo As String = String.Empty
        Select Case strDownloadType
            Case "l"
                strDownloadInfo = Replace(txtURL.Text, "http://", "")
                If String.IsNullOrEmpty(strDownloadInfo) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Versions", "ContentText_NoDownloadInfo"))
                    Return False
                End If
            Case "u"
                strDownloadInfo = litFileName.Text
                If String.IsNullOrEmpty(strDownloadInfo) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Versions", "ContentText_NoDownloadInfo"))
                    Return False
                End If
        End Select

        Dim chrVersionType As Char = CChar(ddlVersionType.SelectedValue())
        Dim intCustomerGrp As Integer
        Try
            intCustomerGrp = CInt(ddlCustomerGroup.SelectedValue())
        Catch ex As Exception
            intCustomerGrp = 0
        End Try

        Dim chrCustomizationType As Char = CChar(ddlCustomizationType.SelectedValue())
        Dim strCustomizationDesc As String = txtCustomizationDesc.Text
        Dim snglCustomizationCost As Single = HandleDecimalValues(txtCustomizationCost.Text)

        If chrCustomizationType = "n" Then
            strCustomizationDesc = "" : snglCustomizationCost = 0
        End If

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 3. Saving the changes
        Dim strMessage As String = ""
        Dim VersionID As Long = GetVersionID()
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not VersionsBLL._UpdateVersion(
                                tblLanguageContents, VersionID, strCodeNumber, _GetProductID(), decPrice, bytTaxBand, bytTaxBand2, "",
                                snglWeight, bytDelivery, sngStockQty, sngWarnLevel, blnLive, strDownloadInfo, strDownloadType,
                                 decRRP, chrVersionType, intCustomerGrp, chrCustomizationType, strCustomizationDesc,
                                snglCustomizationCost, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.INSERT
                If Not VersionsBLL._AddNewVersion(
                                tblLanguageContents, strCodeNumber, _GetProductID(), decPrice, bytTaxBand, bytTaxBand2, "",
                                snglWeight, bytDelivery, sngStockQty, sngWarnLevel, blnLive, strDownloadInfo, strDownloadType,
                                 decRRP, chrVersionType, intCustomerGrp, chrCustomizationType, strCustomizationDesc,
                                snglCustomizationCost, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, "Trying to update but...")
        Try
            If strDownloadType = "u" AndAlso Not String.IsNullOrEmpty(strDownloadInfo) AndAlso _
            Not String.IsNullOrEmpty(litOldFileName.Text) AndAlso strDownloadInfo <> litOldFileName.Text Then
                File.SetAttributes(Server.MapPath(GetKartConfig("general.uploadfolder") & litOldFileName.Text), FileAttributes.Normal)
                File.Delete(Server.MapPath(GetKartConfig("general.uploadfolder") & litOldFileName.Text))
            End If
        Catch ex As Exception
        End Try

        Return True

    End Function

    ''' <summary>
    ''' loads the selected version's info from the db
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadMainInfo()
        Dim tblVersion As New DataTable
        tblVersion = VersionsBLL._GetVersionByID(GetVersionID())

        If tblVersion.Rows.Count = 0 Then Exit Sub

        ddlVersionType.SelectedValue = CChar(FixNullFromDB(tblVersion.Rows(0)("V_Type")))
        chkLive.Checked = CBool(tblVersion.Rows(0)("V_Live"))
        txtCodeNumber.Text = CStr(FixNullFromDB(tblVersion.Rows(0)("V_CodeNumber")))
        ddlCustomerGroup.SelectedValue = CStr(FixNullFromDB(tblVersion.Rows(0)("V_CustomerGroupID"))) ''Customer Group
        txtPriceIncTax.Text = _HandleDecimalValues(CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), CStr(FixNullFromDB(tblVersion.Rows(0)("V_Price"))), False))

        If TaxRegime.VTax_Type = "rate" Then
            ddlTaxBand.SelectedValue = FixNullFromDB(tblVersion.Rows(0)("V_Tax"))
        ElseIf TaxRegime.VTax_Type = "boolean" Then
            Try
                Dim drTax() As DataRow = GetTaxRateFromCache.Select("T_ID=" & FixNullFromDB(tblVersion.Rows(0)("V_Tax")))
                If drTax(0)("T_TaxRate") > 0 Then chkTaxBand.Checked = True Else chkTaxBand.Checked = False
            Catch ex As Exception
            End Try
        End If

        If TaxRegime.VTax_Type2 = "rate" Then
            ddlTaxBand2.SelectedValue = FixNullFromDB(tblVersion.Rows(0)("V_Tax2"))
        ElseIf TaxRegime.VTax_Type2 = "boolean" Then
            Try
                Dim drTax() As DataRow = GetTaxRateFromCache.Select("T_ID=" & FixNullFromDB(tblVersion.Rows(0)("V_Tax2")))
                If drTax(0)("T_TaxRate") > 0 Then chkTaxBand2.Checked = True Else chkTaxBand2.Checked = False
            Catch ex As Exception
            End Try
        End If

        If TaxRegime.VTax_Type2 <> "" Then ddlTaxBand2.SelectedValue = FixNullFromDB(tblVersion.Rows(0)("V_Tax2"))

        txtWeight.Text = _HandleDecimalValues(CStr(tblVersion.Rows(0)("V_Weight")))
        txtRRP.Text = _HandleDecimalValues(CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), CStr(FixNullFromDB(tblVersion.Rows(0)("V_RRP"))), False))
        txtDeliveryTime.Text = CStr(tblVersion.Rows(0)("V_DeliveryTime"))

        ddlDownloadType.SelectedValue = CChar(FixNullFromDB(tblVersion.Rows(0)("V_DownloadType")))

        txtStockQuantity.Text = CStr(tblVersion.Rows(0)("V_Quantity"))
        txtWarningLevel.Text = CStr(tblVersion.Rows(0)("V_QuantityWarnLevel"))
        If CSng(FixNullFromDB(tblVersion.Rows(0)("V_QuantityWarnLevel"))) > 0.0F Then
            txtWarningLevel.Enabled = True
            chkStockTracking.Checked = True
        Else
            txtWarningLevel.Enabled = False
            chkStockTracking.Checked = False
        End If

        ddlCustomizationType.SelectedValue = CChar(tblVersion.Rows(0)("V_CustomizationType"))
        txtCustomizationDesc.Text = FixNullFromDB(tblVersion.Rows(0)("V_CustomizationDesc"))
        txtCustomizationCost.Text = _HandleDecimalValues(CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), CStr(FixNullFromDB(tblVersion.Rows(0)("V_CustomizationCost"))), False))
        CheckCustomizationType()

        litVersionType.Text = CStr(FixNullFromDB(tblVersion.Rows(0)("V_Type")))

        '' checking the version type .. 
        ''      => so that, some controls wil be read-only in case of combination version
        Dim chrVersionType As Char = CStr(FixNullFromDB(tblVersion.Rows(0)("V_Type")))
        If chrVersionType = "c" Then
            DisableCombinationControls()
        ElseIf chrVersionType = "b" Then
            EnableCombinationControls()
            phdStockTrackingInputs.Visible = False

            'Base versions 'b' could be either for options or combinations
            'products. Therefore, we need to check which type. Options products
            'cannot be stock tracked, only combinations ones can.
            If CkartrisCombinations.IsCombinationsProduct(FixNullFromDB(tblVersion.Rows(0)("V_ProductID"))) Then
                'Can stock track
                chkStockTracking.Visible = True
                litFormLabelStockTracking.Visible = True
            Else
                'No stock tracking
                chkStockTracking.Visible = False
                litFormLabelStockTracking.Visible = False
            End If

        Else
            EnableCombinationControls()
            phdStockTrackingInputs.Visible = True
        End If
        CheckDownloadType(CStr(FixNullFromDB(tblVersion.Rows(0)("V_DownloadInfo"))), False)



        updMain.Update()
    End Sub

    ''' <summary>
    ''' makes some controls editable to the user
    '''   => used only when its not combination version
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub EnableCombinationControls()
        chkLive.Enabled = True
        txtPriceIncTax.Enabled = True
        ddlTaxBand.Enabled = True
        ddlTaxBand2.Enabled = True
        txtRRP.Enabled = True
        txtWeight.Enabled = True
        txtDeliveryTime.Enabled = True
        ddlDownloadType.Enabled = True
        ddlCustomizationType.Enabled = True
        txtCustomizationDesc.Enabled = True
        txtCustomizationCost.Enabled = True

    End Sub

    ''' <summary>
    ''' makes some controls read-only to the user
    '''   => used only when its combination version
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub DisableCombinationControls()
        chkLive.Enabled = False
        If blnUseCombinationPrice Then txtPriceIncTax.Enabled = True Else txtPriceIncTax.Enabled = False
        ddlTaxBand.Enabled = False
        ddlTaxBand2.Enabled = False
        txtRRP.Enabled = False
        txtWeight.Enabled = False
        txtDeliveryTime.Enabled = False
        ddlDownloadType.Enabled = False
        ddlCustomizationType.Enabled = False
        txtCustomizationDesc.Enabled = False
        txtCustomizationCost.Enabled = False

        If Not VersionsBLL.IsStockTrackingInBase(_GetProductID()) Then
            phdStockTracking.Visible = False
        Else
            phdStockTracking.Visible = True
            txtWarningLevel.Visible = False
            chkStockTracking.Visible = False
            litFormLabelStockTrackingText.Visible = False
            litFormLabelWarningLevel.Visible = False

        End If

    End Sub

    ''' <summary>
    ''' resets all the contorls in the page
    '''   => used on create new version
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub ClearForm()

        chkLive.Checked = True : chkStockTracking.Checked = False
        txtCodeNumber.Text = Nothing : txtPriceIncTax.Text = Nothing
        ddlTaxBand.SelectedValue = "0" : ddlTaxBand2.SelectedValue = "0" : txtWeight.Text = 0
        txtRRP.Text = 0 : txtDeliveryTime.Text = 0
        txtStockQuantity.Text = "0" : txtWarningLevel.Text = "0"
        ddlDownloadType.SelectedIndex = 0
        litFilePath.Text = String.Empty
        CheckDownloadType()
        ddlCustomizationType.SelectedIndex = 0
        txtCustomizationDesc.Text = Nothing
        txtCustomizationCost.Text = "0"

    End Sub

    ''' <summary>
    ''' returns the selected version id "saved in a hidden control"
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetVersionID() As Long
        If litVersionID.Text <> "" Then
            Return CLng(litVersionID.Text)
        End If

        Return 0
    End Function

    Protected Sub ddlDownloadType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDownloadType.SelectedIndexChanged
        CheckDownloadType()
    End Sub

    Private Sub CheckDownloadType(Optional ByVal strDownloadInfo As String = "", Optional ByVal blnPopupUpload As Boolean = True)
        phdLink.Visible = False
        phdUpload.Visible = False
        Select Case ddlDownloadType.SelectedValue
            Case "l"
                phdLink.Visible = True
                If Not String.IsNullOrEmpty(strDownloadInfo) Then txtURL.Text = strDownloadInfo
            Case "u"
                phdUpload.Visible = True
                phdDownloadFileInfo.Visible = True
                If Not String.IsNullOrEmpty(strDownloadInfo) Then litFileName.Text = strDownloadInfo : litOldFileName.Text = strDownloadInfo
                If blnPopupUpload AndAlso String.IsNullOrEmpty(litFilePath.Text) Then _UC_UploaderPopup.OpenFileUpload()
            Case Else
                phdLink.Visible = False
                phdUpload.Visible = False
        End Select
        updFreeShipping.Update()
    End Sub

    Protected Sub chkStockTracking_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkStockTracking.CheckedChanged
        txtWarningLevel.Enabled = chkStockTracking.Checked
        If Not chkStockTracking.Checked Then
            txtWarningLevel.Text = "0"
        Else
            txtWarningLevel.Text = "1"
        End If
    End Sub

    Protected Sub ddlCustomizationType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCustomizationType.SelectedIndexChanged
        CheckCustomizationType()
    End Sub

    Private Sub CheckCustomizationType()
        If ddlCustomizationType.SelectedValue <> "n" Then
            phdCustomization.Visible = True
        Else
            phdCustomization.Visible = False
        End If
        updCustomizationType.Update()
    End Sub

    Protected Sub _UC_UploaderPopup_NeedCategoryRefresh() Handles _UC_UploaderPopup.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub _UC_UploaderPopup_UploadClicked() Handles _UC_UploaderPopup.UploadClicked
        If _UC_UploaderPopup.HasFile() Then
            Dim strFileName As String = txtCodeNumber.Text & "_" & _UC_UploaderPopup.GetFileName()
            Dim strUploadFolder As String = GetKartConfig("general.uploadfolder")
            Dim strTempFolder As String = strUploadFolder & "temp/"
            If Not Directory.Exists(Server.MapPath(strTempFolder)) Then Directory.CreateDirectory(Server.MapPath(strTempFolder))
            Dim strSavedPath As String = strTempFolder & strFileName
            _UC_UploaderPopup.SaveFile(Server.MapPath(strSavedPath))
            litFilePath.Text = strSavedPath
            litFileName.Text = strFileName
            phdDownloadFileInfo.Visible = True
        End If
    End Sub

    Protected Sub lnkBtnChangeDownloadFile_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnChangeDownloadFile.Click
        _UC_UploaderPopup.OpenFileUpload()
    End Sub

End Class
