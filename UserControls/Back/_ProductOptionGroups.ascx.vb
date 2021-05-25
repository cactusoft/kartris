'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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
Imports CkartrisCombinations
Imports KartSettingsManager

Partial Class _ProductOptionGroups
    Inherits System.Web.UI.UserControl

    Public Event VersionChanged()
    Public Event AllOptionsDeleted()
    Public Event ShowMasterUpdate()
    Public Event OptionsSaved()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Session("_tab") = "options" Then
            If TaxRegime.VTax_Type = "rate" Then
                If ddlBasicTaxBand.Items.Count <= 1 Then
                    ddlBasicTaxBand.DataTextField = "T_TaxRateString"
                    ddlBasicTaxBand.DataValueField = "T_ID"
                    ddlBasicTaxBand.DataSource = GetTaxRateFromCache()
                    ddlBasicTaxBand.DataBind()
                End If
            End If
            If TaxRegime.VTax_Type2 = "rate" Then
                If ddlBasicTaxBand2.Items.Count <= 1 Then
                    ddlBasicTaxBand2.DataTextField = "T_TaxRateString"
                    ddlBasicTaxBand2.DataValueField = "T_ID"
                    ddlBasicTaxBand2.DataSource = GetTaxRateFromCache()
                    ddlBasicTaxBand2.DataBind()
                End If
            End If
        End If
        chkBasicStockTracking.Text = GetGlobalResourceObject("_Version", "ContentText_StockTrackingText") & "*"

        'Style the filter links on first load
        If Not Me.IsPostBack Then
            If Session("_ProductOptionFilters") = "ShowAll" Then
                phdFilterBox.Visible = False
                lnkShowAll.CssClass = "filterselected"
                lnkJustSelected.CssClass = ""
            Else
                phdFilterBox.Visible = True
                lnkShowAll.CssClass = ""
                lnkJustSelected.CssClass = "filterselected"
            End If
        End If
    End Sub

    Protected Sub lnkShowAll_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkShowAll.Click
        Session("_ProductOptionFilters") = "ShowAll"
        phdFilterBox.Visible = False
        lnkShowAll.CssClass = "filterselected"
        lnkJustSelected.CssClass = ""
        GetProductOptionGroups()
        updOptionGroups.Update()
    End Sub

    Protected Sub lnkJustSelected_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkJustSelected.Click
        Session("_ProductOptionFilters") = "JustSelected"
        phdFilterBox.Visible = True
        lnkShowAll.CssClass = ""
        lnkJustSelected.CssClass = "filterselected"
        GetProductOptionGroups()
        updOptionGroups.Update()
    End Sub

    Protected Sub btnFilterSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFilterSubmit.Click
        GetProductOptionGroups()
        updOptionGroups.Update()
    End Sub

    Public Sub CreateProductOptionGroups()
        litProductID.Text = CStr(_GetProductID())
        RefreshPage()
    End Sub

    Private Sub GetBasicInformation()

        Dim tblBasicVersion As New DataTable
        tblBasicVersion = VersionsBLL._GetBasicVersionByProduct(CInt(litProductID.Text))

        Select Case tblBasicVersion.Rows.Count
            Case 0 'No Basic Version
                tabContainerMain.ActiveTab = tabBasicInformation
                tabProductOptions.Enabled = False
                tabOptionCombinations.Enabled = False
                lnkBtnSaveBasicVersion.CommandName = "new"
                txtBasicCodeNumber.Text = ""
                txtBasicStockQuantity.Text = "0"
                txtBasicWarningLevel.Text = "0"
                txtBasicIncTax.Text = ""
                If TaxRegime.VTax_Type = "rate" Then
                    ddlBasicTaxBand.SelectedIndex = 0
                ElseIf TaxRegime.VTax_Type = "boolean then" Then
                    chkTaxBand.Checked = False
                End If
                If TaxRegime.VTax_Type2 = "rate" Then
                    ddlBasicTaxBand2.SelectedIndex = 0
                ElseIf TaxRegime.VTax_Type2 = "boolean then" Then
                    chkTaxBand2.Checked = False
                End If
                txtBasicWeight.Text = "0"
                txtBasicRRP.Text = "0"
            Case 1 'One Basic Version "Should be always"
                Dim drBasic As DataRow = tblBasicVersion.Rows(0)

                litBasicVersionID.Text = FixNullFromDB(drBasic("V_ID"))
                litBasicVersionType.Text = FixNullFromDB(drBasic("V_Type"))
                txtBasicCodeNumber.Text = FixNullFromDB(drBasic("V_CodeNumber"))

                If FixNullFromDB(drBasic("V_QuantityWarnLevel")) <> 0 Then
                    chkBasicStockTracking.Checked = True
                Else
                    chkBasicStockTracking.Checked = False
                End If

                chkBasicStockTracking_CheckedChanged(Me, New EventArgs)
                txtBasicStockQuantity.Text = FixNullFromDB(drBasic("V_Quantity"))
                txtBasicWarningLevel.Text = FixNullFromDB(drBasic("V_QuantityWarnLevel"))
                txtBasicIncTax.Text = _HandleDecimalValues(CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), CStr(FixNullFromDB(drBasic("V_Price"))), False))
                'txtBasicIncTax.Text = FixNullFromDB(drBasic("V_Price"))
                If TaxRegime.VTax_Type = "rate" Then
                    ddlBasicTaxBand.SelectedValue = CStr(FixNullFromDB(drBasic("V_Tax")))
                ElseIf TaxRegime.VTax_Type = "boolean then" Then
                    Try
                        Dim drTax() As DataRow = GetTaxRateFromCache.Select("T_ID=" & FixNullFromDB(drBasic("V_Tax")))
                        If drTax(0)("T_TaxRate") > 0 Then chkTaxBand.Checked = True Else chkTaxBand.Checked = False
                    Catch ex As Exception
                    End Try
                End If
                If TaxRegime.VTax_Type2 = "rate" Then
                    ddlBasicTaxBand2.SelectedValue = CStr(FixNullFromDB(drBasic("V_Tax2")))
                ElseIf TaxRegime.VTax_Type2 = "boolean then" Then
                    Try
                        Dim drTax() As DataRow = GetTaxRateFromCache.Select("T_ID=" & FixNullFromDB(drBasic("V_Tax2")))
                        If drTax(0)("T_TaxRate") > 0 Then chkTaxBand2.Checked = True Else chkTaxBand2.Checked = False
                    Catch ex As Exception
                    End Try
                End If
                txtBasicWeight.Text = FixNullFromDB(drBasic("V_Weight"))
                txtBasicRRP.Text = _HandleDecimalValues(CurrenciesBLL.FormatCurrencyPrice(HttpContext.Current.Session("CUR_ID"), CStr(FixNullFromDB(drBasic("V_RRP"))), False))
                tabProductOptions.Enabled = True
                tabOptionCombinations.Enabled = True
                lnkBtnSaveBasicVersion.CommandName = "update"

                'If is combinations product, the stock value is set at version/combination
                'level, not for the base version
                Dim objProductsBLL As New ProductsBLL
                If objProductsBLL._NumberOfCombinations(CInt(litProductID.Text)) > 0 Then
                    'Is combinations product
                    'Hide the stock level on first tab
                    phdStockQuantity.Visible = False
                Else
                    phdStockQuantity.Visible = True
                End If
            Case Else 'More than one Basic Version "Error"

        End Select

    End Sub

    Protected Sub lnkBtnSaveBasicVersion_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveBasicVersion.Click
        SaveBasicVersionInformation()
        If tabNewCombinations.Enabled = True Then
            GenerateNewCombinations()
        End If
        RaiseEvent VersionChanged()
    End Sub

    Private Sub SaveBasicVersionInformation()

        If txtBasicStockQuantity.Text = "" Then txtBasicStockQuantity.Text = "0"
        If txtBasicWarningLevel.Text = "" Then txtBasicWarningLevel.Text = "0"
        If txtBasicRRP.Text = "" Then txtBasicRRP.Text = "0"
        If txtBasicWeight.Text = "" Then txtBasicWeight.Text = "0"

        Dim strCodeNumber As String = txtBasicCodeNumber.Text
        Dim numPrice As Decimal = HandleDecimalValues(txtBasicIncTax.Text)
        Dim numTaxBand As Integer = 0
        Dim numTaxBand2 As Integer = 0

        If TaxRegime.VTax_Type = "rate" Then
            numTaxBand = CByte(ddlBasicTaxBand.SelectedValue)
        ElseIf TaxRegime.VTax_Type = "boolean" Then
            Dim dtTaxes As DataTable = GetTaxRateFromCache()
            For Each rw As DataRow In dtTaxes.Rows
                If chkTaxBand.Checked Then '' taxable, need to find the 1st non-zero tax
                    If rw("T_TaxRate") > 0 Then numTaxBand = rw("T_ID") : Exit For
                Else                        '' not taxable, need to find the 1st zero tax
                    If rw("T_TaxRate") = 0 Then numTaxBand = rw("T_ID") : Exit For
                End If
            Next
        End If
        If TaxRegime.VTax_Type2 = "rate" Then
            numTaxBand2 = CByte(ddlBasicTaxBand2.SelectedValue)
        ElseIf TaxRegime.VTax_Type2 = "boolean" Then
            Dim dtTaxes As DataTable = GetTaxRateFromCache()
            For Each rw As DataRow In dtTaxes.Rows
                If chkTaxBand2.Checked Then '' taxable, need to find the 1st non-zero tax
                    If rw("T_TaxRate") > 0 Then numTaxBand2 = rw("T_ID") : Exit For
                Else                        '' not taxable, need to find the 1st zero tax
                    If rw("T_TaxRate") = 0 Then numTaxBand2 = rw("T_ID") : Exit For
                End If
            Next
        End If

        Dim numStockQty As Integer = CInt(txtBasicStockQuantity.Text)
        Dim numQtyLevel As Integer = CInt(txtBasicWarningLevel.Text)
        Dim numRRP As Decimal = HandleDecimalValues(txtBasicRRP.Text)
        Dim numWeight As Single = HandleDecimalValues(txtBasicWeight.Text)
        Dim chrType As Char = ""

        Dim tblLanguageContents As New DataTable()
        tblLanguageContents.Columns.Add(New DataColumn("_LE_LanguageID"))
        tblLanguageContents.Columns.Add(New DataColumn("_LE_FieldID"))
        tblLanguageContents.Columns.Add(New DataColumn("_LE_Value"))

        Dim strProductName As String = ""
        Dim tblLanguages As DataTable = GetLanguagesFromCache()
        For Each row As DataRow In tblLanguages.Rows
            strProductName = ProductsBLL._GetNameByProductID(_GetProductID(), CShort(row("LANG_ID")))
            If strProductName Is Nothing Then Continue For 'Means the Name doesn't exist for that language, so no need to add it.
            tblLanguageContents.Rows.Add(row("LANG_ID"), CByte(LANG_ELEM_FIELD_NAME.Name), strProductName)
            tblLanguageContents.Rows.Add(row("LANG_ID"), CByte(LANG_ELEM_FIELD_NAME.Description), "")
        Next

        Dim strMsg As String = ""
        Select Case lnkBtnSaveBasicVersion.CommandName
            Case "new"
                If VersionsBLL._IsCodeNumberExist(txtBasicCodeNumber.Text) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
                    Exit Sub
                End If
                If Not VersionsBLL._AddNewVersion(tblLanguageContents, strCodeNumber, _GetProductID(), numPrice, _
                                                                     numTaxBand, numTaxBand2, "", numWeight, Nothing, numStockQty, numQtyLevel, _
                                                                     True, Nothing, "n", numRRP, "b", _
                                                                     Nothing, "n", Nothing, 0, strMsg) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMsg)
                Else
                    GetBasicInformation()
                    updMain.Update()
                    RaiseEvent VersionChanged()
                End If
            Case "update"
                Dim lngCurrentVersion As Long = CLng(litBasicVersionID.Text)
                If VersionsBLL._IsCodeNumberExist(txtBasicCodeNumber.Text, , lngCurrentVersion) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
                    Exit Sub
                End If

                Dim tblVersionInfo As DataTable = VersionsBLL._GetVersionByID(lngCurrentVersion)
                Dim drwVersion As DataRow = tblVersionInfo.Rows(0)
                'On update Basic Info. no need to change the languageElements, so will send it as Nothing..'
                'So, languageElements will be not included in the Update.
                If VersionsBLL._UpdateVersion( _
                    Nothing, lngCurrentVersion, strCodeNumber, _GetProductID(), numPrice, numTaxBand, numTaxBand2, "", numWeight, _
                    FixNullFromDB(drwVersion("V_DeliveryTime")), numStockQty, numQtyLevel, FixNullFromDB(drwVersion("V_Live")), _
                    FixNullFromDB(drwVersion("V_DownLoadInfo")), FixNullFromDB(drwVersion("V_DownloadType")), _
                    numRRP, FixNullFromDB(drwVersion("V_Type")), _
                    FixNullFromDB(drwVersion("V_CustomerGroupID")), FixNullFromDB(drwVersion("V_CustomizationType")), _
                    FixNullFromDB(drwVersion("V_CustomizationDesc")), FixNullFromDB(drwVersion("V_CustomizationCost")), strMsg) Then

                    GetExistingCombinations()
                    updCombinations.Update()
                    RaiseEvent VersionChanged()
                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMsg)
                End If
            Case Else

        End Select


    End Sub

    Private Sub GetProductOptionGroups()

        Dim tblOptionGrp As New DataTable
        tblOptionGrp = OptionsBLL._GetOptionGroups()

        Dim colMustSelected As New DataColumn("MustSelected")
        Dim colExistInTheProduct As New DataColumn("ExistInTheProduct")
        colMustSelected.DefaultValue = False
        colExistInTheProduct.DefaultValue = False
        tblOptionGrp.Columns.Add(colMustSelected)
        tblOptionGrp.Columns.Add(colExistInTheProduct)

        'For Each drwGroup As DataRow In tblOptionGrp.Rows
        '    drwGroup("MustSelected") = False
        '    drwGroup("ExistInTheProduct") = False
        'Next

        Dim tblProductGrps As New DataTable
        tblProductGrps = OptionsBLL._GetOptionGroupsByProductID(CInt(litProductID.Text))

        For Each drwProduct As DataRow In tblProductGrps.Rows
            For Each drwGroup As DataRow In tblOptionGrp.Rows
                If drwProduct("P_OPTG_OptionGroupID") = drwGroup("OPTG_ID") Then
                    drwGroup("OPTG_DefOrderByValue") = drwProduct("P_OPTG_OrderByValue")
                    drwGroup("MustSelected") = drwProduct("P_OPTG_MustSelected")
                    drwGroup("ExistInTheProduct") = True
                    Exit For 'Found the match, no need to hang about expecting more
                End If
            Next
        Next

        'Some sites have a very large number of 
        'options. In such cases, rather than show
        'all and have the page grind to a halt, we
        'just show the selected ones. There is a
        'radio button option to show all if required
        'and a text box to include extra ones (which
        'can be checked to add them in)
        Dim dvwOptions As DataView = New DataView(tblOptionGrp)

        'We store the number of option groups here so we
        'can use it to determine whether to expand the
        'selected options or not. Basically over 25 we
        'will collapse by default, over 25 we will expand
        hidNumberOfOptionGroups.Value = tblOptionGrp.Rows.Count

        If tblOptionGrp.Rows.Count > 25 Then
            'We have larger number of options, so by default
            'we're just going to show the selected ones, and
            'filter tools to show all, or add more
            If Session("_ProductOptionFilters") <> "ShowAll" Then
                If txtFilterText.Text = "" Then
                    'No filter text
                    dvwOptions.RowFilter = "ExistInTheProduct=True"
                Else
                    'We have some filter text
                    dvwOptions.RowFilter = "ExistInTheProduct=True OR OPTG_BackendName LIKE'%" & txtFilterText.Text & "%'"
                    dvwOptions.Sort = "ExistInTheProduct"
                End If

            End If
        Else
            'Here only a low number of options so no filtering
            'We also can hide the filters
            phdOptionsAllSelected.Visible = False
        End If

        'Bind to the filtered data
        rptProductOptions.DataSource = dvwOptions
        rptProductOptions.DataBind()
        CheckForCombination()
    End Sub

    Private Sub GetExistingCombinations()

        Dim tblCurrentCombinations As New DataTable
        tblCurrentCombinations = VersionsBLL._GetCombinationsByProductID(CInt(litProductID.Text))
        tblCurrentCombinations.Columns.Add(New DataColumn("IsStockTracking", Type.GetType("System.Boolean")))
        tblCurrentCombinations.Columns.Add(New DataColumn("UseCombinationPrices", Type.GetType("System.Boolean")))

        'If the base set to stop stock tracking, then will hide the quantity & the warn level
        Dim blnStockTrackingEnabled As Boolean = False
        If VersionsBLL.IsStockTrackingInBase(CInt(litProductID.Text)) Then blnStockTrackingEnabled = True
        'Check whether the product will use the combination prices or not
        Dim blnUseCombinationPrices As Boolean = IIf(ObjectConfigBLL.GetValue("K:product.usecombinationprice", CInt(litProductID.Text)) = "1", True, False)
        For Each drwCombination As DataRow In tblCurrentCombinations.Rows
            drwCombination("IsStockTracking") = blnStockTrackingEnabled
            drwCombination("UseCombinationPrices") = blnUseCombinationPrices
        Next

        litCurrentCombinationsHeader.Text = GetGlobalResourceObject("_Options", "ContentText_CurrentCombinationsOfProduct") & _
                                            " (" & tblCurrentCombinations.Rows.Count & ")"

        If tblCurrentCombinations.Rows.Count = 0 Then
            rptCurrentCombinations.DataSource = Nothing
            rptCurrentCombinations.DataBind()
            If rptNewCombinations.Items.Count = 0 Then phdCombinationList.Visible = False
        Else
            phdCombinationList.Visible = True
            chkBasicStockTracking.Visible = True
            rptCurrentCombinations.DataSource = tblCurrentCombinations
            rptCurrentCombinations.DataBind()
            If rptCurrentCombinations.Items.Count > 0 Then
                CType(rptCurrentCombinations.Controls(0).FindControl("phdHeaderStock"), PlaceHolder).Visible = blnStockTrackingEnabled
                CType(rptCurrentCombinations.Controls(0).FindControl("phdHeaderPrice"), PlaceHolder).Visible = blnUseCombinationPrices
            End If
        End If

    End Sub

    Private Sub ResetCreateCombinations()

        rptNewCombinations.DataSource = Nothing
        rptNewCombinations.DataBind()

        tabNewCombinations.Enabled = False
        updCreateCombination.Update()

        If rptCurrentCombinations.Items.Count = 0 Then
            phdCombinationList.Visible = False
        Else
            ActivateCurrentCombinationsTab()
        End If

    End Sub

    Protected Sub rptProductOptions_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptProductOptions.ItemCommand

        Select Case e.CommandName
            Case "select"
                Dim itmSelection As UserControls_Back_ItemSelection
                itmSelection = CType(e.Item.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection)
                itmSelection.Checked = Not itmSelection.IsSelected
                ItemSelected(e.Item)
            Case "reset"
                GetProductOptionGroups()
                ResetCreateCombinations()
            Case "save"
                SaveProductOptions()
                CheckForCombination()
                ResetCreateCombinations()
                GetExistingCombinations() 'Need to Update the Current Combinations (No more..!! All are Suspended ..)
                updCombinations.Update()
            Case "expand"
                ItemExpanded(e.Item)
        End Select

    End Sub

    Sub ItemSelected(ByVal itm As RepeaterItem)
        Dim phdOptions As PlaceHolder = CType(itm.FindControl("phdOptions"), PlaceHolder)
        phdOptions.Visible = Not phdOptions.Visible
        CType(itm.FindControl("pnlOptions"), Panel).Enabled = _
            CType(itm.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection).IsSelected
    End Sub

    'This is used to toggle the option values
    'section under an option group if the +/- is
    'clicked
    Sub ItemExpanded(ByVal itm As RepeaterItem)
        Dim phdOptions As PlaceHolder = CType(itm.FindControl("phdOptions"), PlaceHolder)
        phdOptions.Visible = Not phdOptions.Visible
    End Sub

    Sub CheckAllItems(ByVal itm As RepeaterItem)
        Dim phdOptions As PlaceHolder = CType(itm.FindControl("phdOptions"), PlaceHolder)
        phdOptions.Visible = Not phdOptions.Visible
    End Sub

    Protected Sub rptProductOptions_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptProductOptions.ItemDataBound
        'We stored the number of option groups earlier
        'to use here to decide whether to expand items
        'or not.
        Dim numOptionGroupCount As Integer = CInt(hidNumberOfOptionGroups.Value)
        Try
            Dim intGrpID As Integer = CInt(CType(e.Item.FindControl("litOptionGrpID"), Literal).Text)

            CType(e.Item.FindControl("_UC_ProductOptions"), _ProductOptions).CreateOptionsByGroupID(intGrpID, _GetProductID())

            Dim blnOptionSelected As Boolean = _
                (CType(e.Item.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection).IsSelected)
            CType(e.Item.FindControl("phdOptions"), PlaceHolder).Visible = blnOptionSelected And numOptionGroupCount < 25
            CType(e.Item.FindControl("pnlOptions"), Panel).Enabled = blnOptionSelected
        Catch ex As Exception
        End Try

        Try
            CType(e.Item.FindControl("chkMustSelect"), CheckBox).Checked = Not CType(e.Item.FindControl("chkMustSelect"), CheckBox).Checked
        Catch ex As Exception

        End Try

    End Sub

    'Reads all the selected values (Groups & Options) into the received datatables.
    Public Sub GetSelectedValues(ByRef tblSelectedGroups As DataTable, ByRef tblSelectedOptions As DataTable)

        Dim intGroupID As Integer = 0, intProductID As Integer = 0, intOrderByValue As Integer = 0
        Dim blnMustSelected As Boolean = False, tblOptions As New DataTable

        For Each itm As RepeaterItem In rptProductOptions.Items

            If CType(itm.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection).IsSelected Then

                tblOptions = New DataTable
                tblOptions = CType(itm.FindControl("_uc_ProductOptions"),  _
                        _ProductOptions).GetSelectedOptions()

                'If no options are selected then, no need to save any item-related data
                If tblOptions.Rows.Count = 0 Then Continue For

                intProductID = CInt(litProductID.Text)
                intGroupID = CInt(CType(itm.FindControl("litOptionGrpID"), Literal).Text)
                intOrderByValue = CInt(CType(itm.FindControl("txtOrderByValue"), TextBox).Text)
                blnMustSelected = Not CType(itm.FindControl("chkMustSelect"), CheckBox).Checked

                tblSelectedGroups.Rows.Add(intProductID, intGroupID, intOrderByValue, blnMustSelected)
                tblSelectedOptions.Merge(tblOptions)

            End If
        Next

    End Sub

    Protected Sub ItemSelectionChanged(ByVal sender As UserControls_Back_ItemSelection)
        ItemSelected(rptProductOptions.Items(sender.GetItemNo()))
    End Sub

    Private Sub CheckForCombination()

        pnlCreateCombination.Visible = False
        pnlCannotCreateCombinations.Visible = True

        Dim numSelectedGroups As Integer = 0
        Dim chk As New CheckBox
        For Each itm As RepeaterItem In rptProductOptions.Items
            If itm.ItemType = ListItemType.AlternatingItem OrElse itm.ItemType = ListItemType.Item Then
                If CType(itm.FindControl("_UC_ItemSelection"), UserControls_Back_ItemSelection).IsSelected Then
                    numSelectedGroups += 1
                    If numSelectedGroups > 0 Then
                        pnlCannotCreateCombinations.Visible = False
                        pnlCreateCombination.Visible = True
                        Exit For
                    End If
                End If
            End If
        Next

        updCreateCombination.Update()
    End Sub

    Protected Sub btnSubmitCombination_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmitCombination.Click
        pnlCreateCombination.Visible = False
        GenerateNewCombinations()
    End Sub

    Private Sub GenerateNewCombinations()
        rptNewCombinations.DataSource = Nothing
        rptNewCombinations.DataBind()

        Dim tblExistingCombinations As New DataTable
        Dim tblSuspendedCombinations As New DataTable
        Dim tblNewCombinations As New DataTable

        tblExistingCombinations = VersionsBLL._GetVersionOptionsByProductID(CInt(litProductID.Text))

        Dim varExisting = From a In tblExistingCombinations _
                  Select New With _
                  { _
                        .ID = a.Field(Of Int64)("V_ID"), _
                        .Type = a.Field(Of String)("V_Type") _
                  } _
                  Distinct


        If GetProductCombinations(CInt(litProductID.Text), tblNewCombinations, Session("_LANG")) Then
            tblNewCombinations.Columns.Add(New DataColumn("CodeNumber"))
            tblNewCombinations.Columns.Add(New DataColumn("Price"))
            tblNewCombinations.Columns.Add(New DataColumn("Quantity"))
            tblNewCombinations.Columns.Add(New DataColumn("QuantityWarnLevel"))
            tblNewCombinations.Columns.Add(New DataColumn("IsExist"))
            tblNewCombinations.Columns.Add(New DataColumn("OldVersionID"))
            Dim strNewIDs() As String = New String() {""}
            Dim numRowCount As Integer = 0
            For Each drwNewCombination As DataRow In tblNewCombinations.Rows
                numRowCount += 1
                drwNewCombination("CodeNumber") = txtBasicCodeNumber.Text & "-" & numRowCount
                drwNewCombination("Price") = CDec(txtBasicIncTax.Text)
                drwNewCombination("Quantity") = CInt(txtBasicStockQuantity.Text)
                drwNewCombination("QuantityWarnLevel") = CInt(txtBasicWarningLevel.Text)
                drwNewCombination("IsExist") = False
                drwNewCombination("OldVersionID") = -1

                strNewIDs = Split(CStr(drwNewCombination("ID_List")), ",")

                For Each nextCombination In varExisting

                    Dim drwExistingCombination() As DataRow = tblExistingCombinations.Select("V_ID=" & nextCombination.ID)
                    Dim strExistingIDs() As String = New String() {""}
                    ReDim strExistingIDs(drwExistingCombination.GetUpperBound(0))
                    For i As Integer = 0 To drwExistingCombination.GetUpperBound(0)
                        strExistingIDs(i) = drwExistingCombination(i)("V_OPT_OptionID")
                    Next

                    'Sort the arrays, so to make them identical if they have the same Option IDs
                    Array.Sort(strNewIDs)
                    Array.Sort(strExistingIDs)

                    'Returns true if the 2 arrays are identical
                    If IsTheSameArray(strNewIDs, strExistingIDs) Then

                        If nextCombination.Type = "s" Then
                            Dim tblTemp As DataTable = VersionsBLL._GetSuspendedByVersionID(nextCombination.ID, Session("_LANG"))
                            If tblTemp.Rows.Count <> 1 Then Exit For

                            Dim drwSuspended As DataRow = tblTemp.Rows(0)

                            drwNewCombination("OPT_Name") = drwSuspended("V_Name")
                            drwNewCombination("CodeNumber") = drwSuspended("V_CodeNumber")
                            drwNewCombination("Price") = drwSuspended("V_Price")
                            drwNewCombination("Quantity") = drwSuspended("V_Quantity")
                            drwNewCombination("QuantityWarnLevel") = drwSuspended("V_QuantityWarnLevel")
                            drwNewCombination("OldVersionID") = drwSuspended("V_ID")

                            Exit For
                        Else
                            drwNewCombination("IsExist") = True
                            Exit For
                        End If
                    End If

                Next
            Next

            tblNewCombinations.Columns.Add(New DataColumn("IsStockTracking", Type.GetType("System.Boolean")))
            tblNewCombinations.Columns.Add(New DataColumn("UseCombinationPrices", Type.GetType("System.Boolean")))

            'If the base set to stop stock tracking, then will hide the quantity & the warn level
            Dim blnStockTrackingEnabled As Boolean = False
            If VersionsBLL.IsStockTrackingInBase(CInt(litProductID.Text)) Then blnStockTrackingEnabled = True
            'Check whether the product will use the combination prices or not
            Dim blnUseCombinationPrices As Boolean = IIf(ObjectConfigBLL.GetValue("K:product.usecombinationprice", CInt(litProductID.Text)) = "1", True, False)
            For Each drwNewCombination As DataRow In tblNewCombinations.Rows
                drwNewCombination("IsStockTracking") = blnStockTrackingEnabled
                drwNewCombination("UseCombinationPrices") = blnUseCombinationPrices
            Next

            Dim dvwNewCombinations As DataView = tblNewCombinations.DefaultView
            dvwNewCombinations.RowFilter = "IsExist = " & False
            rptNewCombinations.DataSource = dvwNewCombinations
            rptNewCombinations.DataBind()

            If rptNewCombinations.Items.Count > 0 Then
                litNewCombinationsHeader.Text = GetGlobalResourceObject("_Options", "ContentText_NewCombinationsOfProduct") & _
                                                " (" & rptNewCombinations.Items.Count & ")"

                If rptNewCombinations.Items.Count > 0 Then
                    CType(rptNewCombinations.Controls(0).FindControl("phdHeaderStock"), PlaceHolder).Visible = blnStockTrackingEnabled
                    CType(rptNewCombinations.Controls(0).FindControl("phdHeaderPrice"), PlaceHolder).Visible = blnUseCombinationPrices
                End If

                phdCombinationList.Visible = True
                tabNewCombinations.Enabled = True
                tabCombinations.ActiveTab = tabNewCombinations
                updCombinations.Update()
            Else
                tabNewCombinations.Enabled = False
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Information, GetGlobalResourceObject("_Options", "ContentText_NewCombinationsExist"))
            End If

        Else
            tabNewCombinations.Enabled = False
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Options", "ContentText_TooManyCombos"))
        End If
    End Sub

    Protected Function IsTheSameArray(ByVal arr1() As String, ByVal arr2() As String) As Boolean
        If arr1.GetUpperBound(0) <> arr2.GetUpperBound(0) Then Return False
        For i As Integer = 0 To arr1.GetUpperBound(0)
            If arr1(i) <> arr2(i) Then
                Return False
            End If
        Next
        Return True
    End Function

    Sub SaveProductOptions()

        Dim tblSelectedGroupList As DataTable = OptionsBLL._GetProductGroupSchema()
        Dim tblSelectedOptionList As DataTable = OptionsBLL._GetProductOptionSchema()

        GetSelectedValues(tblSelectedGroupList, tblSelectedOptionList)

        Dim strMessage As String = ""
        If Not OptionsBLL._CreateProductOptions(CInt(litProductID.Text), tblSelectedGroupList, tblSelectedOptionList, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If

        RaiseEvent ShowMasterUpdate()

    End Sub

    Protected Sub chkBasicStockTracking_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkBasicStockTracking.CheckedChanged
        txtBasicStockQuantity.Enabled = chkBasicStockTracking.Checked
        txtBasicWarningLevel.Enabled = chkBasicStockTracking.Checked

        If chkBasicStockTracking.Checked Then
            If txtBasicWarningLevel.Text = 0 Then txtBasicWarningLevel.Text = 1
        Else
            txtBasicWarningLevel.Text = 0
        End If
    End Sub

    Protected Sub rptNewCombinations_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptNewCombinations.ItemCommand
        Select Case e.CommandName
            Case "save"
                If IsValidCodeNumber(rptNewCombinations) Then
                    If SaveNewCombinations() Then
                        ResetCreateCombinations()
                        GetExistingCombinations()
                        ActivateCurrentCombinationsTab()
                    End If
                End If
        End Select

    End Sub

    Protected Sub rptCurrentCombinations_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptCurrentCombinations.ItemCommand
        Select Case e.CommandName
            Case "update"
                If IsValidCodeNumber(rptCurrentCombinations) Then
                    If UpdateCurrentCombinations() Then
                        GetExistingCombinations()
                        ActivateCurrentCombinationsTab()
                    End If
                End If
            Case "deletecombinations"
                _UC_PopupMsg_DeleteCombinations.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Options", "ContentText_DeleteCombinationsConfirm"))
        End Select
    End Sub

    Function SaveNewCombinations() As Boolean

        'Create datatable for 'new' combinations
        Dim tblNewCombinations As New DataTable
        tblNewCombinations = VersionsBLL._GetSchema()
        tblNewCombinations.Columns.Add(New DataColumn("ID_List", Type.GetType("System.String")))

        'Create datatable for existing combinations
        Dim tblCurrentCombinations As New DataTable
        tblCurrentCombinations.Columns.Add(New DataColumn("ID", Type.GetType("System.Int64")))
        tblCurrentCombinations.Columns.Add(New DataColumn("Name", Type.GetType("System.String")))
        tblCurrentCombinations.Columns.Add(New DataColumn("CodeNumber", Type.GetType("System.String")))
        tblCurrentCombinations.Columns.Add(New DataColumn("Price", Type.GetType("System.Single")))
        tblCurrentCombinations.Columns.Add(New DataColumn("StockQty", Type.GetType("System.Int32")))
        tblCurrentCombinations.Columns.Add(New DataColumn("QtyWarnLevel", Type.GetType("System.Int32")))
        tblCurrentCombinations.Columns.Add(New DataColumn("Live", Type.GetType("System.Boolean")))

        Dim vPrice As Decimal = FixNullToDB(HandleDecimalValues(txtBasicIncTax.Text), "z")
        Dim vTax As Byte, vTax2 As Byte
        If TaxRegime.VTax_Type = "rate" Then
            vTax = CByte(ddlBasicTaxBand.SelectedValue)
        ElseIf TaxRegime.VTax_Type = "boolean" Then
            Dim dtTaxes As DataTable = GetTaxRateFromCache()
            For Each rw As DataRow In dtTaxes.Rows
                If chkTaxBand.Checked Then '' taxable, need to find the 1st non-zero tax
                    If rw("T_TaxRate") > 0 Then vTax = rw("T_ID") : Exit For
                Else                        '' not taxable, need to find the 1st zero tax
                    If rw("T_TaxRate") = 0 Then vTax = rw("T_ID") : Exit For
                End If
            Next
        End If
        If TaxRegime.VTax_Type2 = "rate" Then
            vTax2 = CByte(ddlBasicTaxBand2.SelectedValue)
        ElseIf TaxRegime.VTax_Type2 = "boolean" Then
            Dim dtTaxes As DataTable = GetTaxRateFromCache()
            For Each rw As DataRow In dtTaxes.Rows
                If chkTaxBand2.Checked Then '' taxable, need to find the 1st non-zero tax
                    If rw("T_TaxRate") > 0 Then vTax2 = rw("T_ID") : Exit For
                Else                        '' not taxable, need to find the 1st zero tax
                    If rw("T_TaxRate") = 0 Then vTax2 = rw("T_ID") : Exit For
                End If
            Next
        End If
        Dim vRRP As Decimal = FixNullToDB(HandleDecimalValues(txtBasicRRP.Text), "z")
        Dim vWeight As Single = FixNullToDB(HandleDecimalValues(txtBasicWeight.Text), "d")
        Dim vProductID As Integer = FixNullToDB(litProductID.Text, "i")
        Dim blnUseCombinationPrices As Boolean = IIf(ObjectConfigBLL.GetValue("K:product.usecombinationprice", vProductID) = "1", True, False)
        For Each itm As RepeaterItem In rptNewCombinations.Items
            If itm.ItemType = ListItemType.Item OrElse itm.ItemType = ListItemType.AlternatingItem Then
                Dim vOldVersionID As Int64 = CLng(FixNullToDB(CType(itm.FindControl("hidOldVersionID"), TextBox).Text))
                Dim vIDList As String = FixNullToDB(CType(itm.FindControl("litIDList"), Literal).Text, "s")
                Dim vName As String = FixNullToDB(CType(itm.FindControl("txtCombinationOptionName"), TextBox).Text, "s")
                Dim vCode As String = FixNullToDB(CType(itm.FindControl("txtCombinationCodeNumber"), TextBox).Text, "s")
                '' If this product is using the combinations' price, then read the entered value from the form (repeater)
                If blnUseCombinationPrices Then vPrice = FixNullToDB(HandleDecimalValues(CType(itm.FindControl("txtCombinationPrice"), TextBox).Text), "g")
                Dim vQty As String = CInt(CType(itm.FindControl("txtCombinationStockQuantity"), TextBox).Text)
                Dim vQtyLevel As String = CInt(CType(itm.FindControl("txtCombinationWarningLevel"), TextBox).Text)
                If vQty = "" Then vQty = "0"
                If vQtyLevel = "" Then vQtyLevel = "0"

                'Kartris v3 change
                'We need to decide whether to update this combination
                'or create a new one. This way, we can retain the original
                'version ID if there is a suspended combination recovered,
                'and the combination image that goes with it, plus any
                'other things linked to that version (notifications, 
                'tracking, etc.)
                If vOldVersionID > 0 Then
                    'Add to existing combinations table
                    tblCurrentCombinations.Rows.Add(vOldVersionID, vName, vCode, vPrice, CInt(vQty), CInt(vQtyLevel), True)
                Else
                    'Add to new combinations table
                    tblNewCombinations.Rows.Add(Nothing, Nothing, vName, Nothing, vCode, vProductID, vPrice,
                                             FixNullToDB(vTax, "i"), vWeight, 0, CInt(vQty), CInt(vQtyLevel), 1, Nothing, Nothing,
                                                0, vRRP, "c", Nothing, "n", Nothing, 0, FixNullToDB(vTax2, "i"), Nothing, Nothing, vIDList)
                End If

            End If
        Next

        Dim strMsg As String = ""

        'Update Kartris v3. We want to preserve the combinations with their original
        'version ID numbers if possible, rather than delete all and recreate. This way
        'anything linked to the version will be maintained, such as combination images.
        'What we're going to do is run an update rather than 'create new' first. This
        'will update the suspended versions with the new data values, since we know
        'the 'old version ID'. We'll also change the type from 's' (suspended) to 'c'
        '(combination). After that, we should in theory be able to run the normal
        'create combinations code which deletes suspended versions and then creates
        'new versions.
        'To ensure we only create the combinations of items that were not updated, we're
        'keeping two tbls instead of one above.
        'tblNewCombinations
        'tblUpdatedCombinations

        'First, update existing combinations
        If VersionsBLL._UpdateCurrentCombinations(tblCurrentCombinations, "") Then
            If VersionsBLL._CreateNewCombinations(tblNewCombinations, vProductID, CLng(litBasicVersionID.Text), strMsg) Then
                RaiseEvent VersionChanged()
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMsg)
                Return False
            End If
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMsg)
            Return False
        End If

        Return True
    End Function

    Sub ActivateCurrentCombinationsTab()
        tabCombinations.ActiveTab = tabCurrentCombinations
        updCombinations.Update()
    End Sub

    Sub ActivateNewCombinationsTab()
        tabCombinations.ActiveTab = tabNewCombinations
        updCombinations.Update()
    End Sub

    Function UpdateCurrentCombinations() As Boolean

        Dim tblCurrentCombinations As New DataTable
        tblCurrentCombinations.Columns.Add(New DataColumn("ID", Type.GetType("System.Int64")))
        tblCurrentCombinations.Columns.Add(New DataColumn("Name", Type.GetType("System.String")))
        tblCurrentCombinations.Columns.Add(New DataColumn("CodeNumber", Type.GetType("System.String")))
        tblCurrentCombinations.Columns.Add(New DataColumn("Price", Type.GetType("System.Single")))
        tblCurrentCombinations.Columns.Add(New DataColumn("StockQty", Type.GetType("System.Int32")))
        tblCurrentCombinations.Columns.Add(New DataColumn("QtyWarnLevel", Type.GetType("System.Int32")))
        tblCurrentCombinations.Columns.Add(New DataColumn("Live", Type.GetType("System.Boolean")))

        For Each itm As RepeaterItem In rptCurrentCombinations.Items
            If itm.ItemType = ListItemType.Item OrElse itm.ItemType = ListItemType.AlternatingItem Then
                Dim VersionID As Long = CLng(CType(itm.FindControl("litVersionID"), Literal).Text)
                Dim VersionName As String = CType(itm.FindControl("txtCombinationOptionName"), TextBox).Text
                Dim VersionCode As String = CType(itm.FindControl("txtCombinationCodeNumber"), TextBox).Text
                Dim VersionPrice As String = CType(itm.FindControl("txtCombinationPrice"), TextBox).Text
                Dim VersionQty As Integer = CInt(CType(itm.FindControl("txtCombinationStockQuantity"), TextBox).Text)
                Dim VersionWarnLevel As Integer = CInt(CType(itm.FindControl("txtCombinationWarningLevel"), TextBox).Text)
                Dim VersionLive As Boolean = CType(itm.FindControl("chkCombinationLive"), CheckBox).Checked

                tblCurrentCombinations.Rows.Add(VersionID, VersionName, VersionCode, VersionPrice, VersionQty, VersionWarnLevel, VersionLive)

            End If
        Next

        If tblCurrentCombinations.Rows.Count = 0 Then Return True
        Dim strMsg As String = ""
        If VersionsBLL._UpdateCurrentCombinations(tblCurrentCombinations, strMsg) Then
            RaiseEvent VersionChanged()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMsg)
            Return False
        End If

        Return True
    End Function

    Private Function IsValidCodeNumber(ByRef dList As Repeater) As Boolean
        'This Function Checkes if the CodeNumber is  valid or not
        ' --> 1. Need to check the code in the new combinations... 
        '     2. Need to check the code in the database for Other Products
        '     3. Need to check the code in the Base Version
        '     NOTE: The existing suspended ones are already with the new combinations.

        'Checking in both data lists (new & current)
        For i As Integer = 0 To dList.Items.Count - 2
            If dList.Items(i).ItemType = ListItemType.Item Or _
                dList.Items(i).ItemType = ListItemType.AlternatingItem Then
                Dim txtBox1 As TextBox = CType(dList.Items(i).FindControl("txtCombinationCodeNumber"), TextBox)
                txtBox1.CssClass = "codenumber"
                For j As Integer = i + 1 To dList.Items.Count - 1
                    If dList.Items(j).ItemType = ListItemType.Item Or _
                        dList.Items(j).ItemType = ListItemType.AlternatingItem Then
                        Dim txtBox2 As TextBox = CType(dList.Items(j).FindControl("txtCombinationCodeNumber"), TextBox)
                        txtBox2.CssClass = "codenumber"
                        If txtBox1.Text = txtBox2.Text Then
                            txtBox1.CssClass = "codenumber errortextbox" : txtBox2.CssClass = "codenumber errortextbox"
                            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
                            Return False
                        End If
                    End If
                Next
            End If
        Next

        'Checking the DB in both data lists (new & current)
        For i As Integer = 0 To dList.Items.Count - 1
            If dList.Items(i).ItemType = ListItemType.Item Or _
                dList.Items(i).ItemType = ListItemType.AlternatingItem Then
                Dim txtBox As TextBox = CType(dList.Items(i).FindControl("txtCombinationCodeNumber"), TextBox)
                txtBox.CssClass = "codenumber"
                'Need to check the code number, will scan all the versions' table, except the Product's Versions
                If VersionsBLL._IsCodeNumberExist(txtBox.Text, _GetProductID()) Then
                    txtBox.CssClass = "codenumber errortextbox"
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
                    Return False
                End If
                'Checking the BaseVersion
                If txtBox.Text = txtBasicCodeNumber.Text Then
                    txtBox.CssClass = "codenumber errortextbox"
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_AlreadyExists"))
                    Return False
                End If
            End If
        Next

        Return True
    End Function

    Protected Sub lnkDeleteAllOptions_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkDeleteAllOptions.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Options", "ContentText_DeleteProductOptionsConfirm"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = "", strDownloadFiles = ""
        If Not VersionsBLL._DeleteProductVersions(_GetProductID(), strDownloadFiles, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RemoveDownloadFiles(strDownloadFiles)
        RefreshPage()
        RaiseEvent AllOptionsDeleted()
    End Sub

    Sub RefreshPage()
        GetBasicInformation()
        GetProductOptionGroups()
        GetExistingCombinations()
        CheckForCombination()
    End Sub

    Public Sub RefreshOptions()
        RefreshPage()
    End Sub


    'Nice way to handle alternate style for row without duplication
    'of using alternating template
    Public Function GetRowClass(ByVal numRowIndex As Integer) As String
        Dim blnAlt As Boolean = (numRowIndex / 2 = System.Math.Round(numRowIndex / 2, 0))

        If blnAlt Then
            Return ""
        Else
            Return "Kartris-GridView-Alternate"
        End If

    End Function

    Protected Sub _UC_PopupMsg_DeleteCombinations_Confirmed() Handles _UC_PopupMsg_DeleteCombinations.Confirmed
        Dim strMessage As String = ""
        If Not VersionsBLL._DeleteExistingCombinations(_GetProductID(), strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If

        chkBasicStockTracking.Visible = False

        GetExistingCombinations()
        CheckForCombination()
        updCombinations.Update()
    End Sub

    Public Function FixNull(ByVal numPrice As Object) As Decimal
        Try
            Return CDec(numPrice)

        Catch ex As Exception
            Return 0
        End Try

    End Function
End Class
