'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.IO
Imports CkartrisDataManipulation

Partial Class Admin_MarkupPrices

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Page.Title = GetGlobalResourceObject("_MarkupPrices", "PageTitle_MarkupPrices") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
            InitializeContents()
        End If
        If ddlSupplier.Items.Count <= 1 Then
            Dim drwSuppliers As DataRow() = KartSettingsManager.GetSuppliersFromCache.Select("SUP_Live = 1")
            ddlSupplier.DataTextField = "SUP_Name"
            ddlSupplier.DataValueField = "SUP_ID"
            ddlSupplier.DataSource = drwSuppliers
            ddlSupplier.DataBind()
        End If
    End Sub

    Sub InitializeContents()
        litCurrencySymbol1.Text = CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency())
        litCurrencySymbol2.Text = litCurrencySymbol1.Text

        Dim dtbCategories As DataTable = CategoriesBLL._GetWithProducts(Session("_LANG"))
        Dim dvwCategories As DataView = dtbCategories.DefaultView
        dvwCategories.Sort = "CAT_Name"
        chklistCategories.Items.Clear()
        chklistCategories.DataTextField = "CAT_Name"
        chklistCategories.DataValueField = "CAT_ID"
        chklistCategories.DataSource = dvwCategories
        chklistCategories.DataBind()

        ddlMarkType.Items.Clear()
        ddlMarkType.Items.Add(New ListItem("%", "p"))
        ddlMarkType.Items.Add(New ListItem(CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency), "v"))
    End Sub

    Protected Sub rdo_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rdoAllCategories.CheckedChanged, rdoSelectedCategories.CheckedChanged
        phdCategories.Visible = Not rdoAllCategories.Checked
        updCategories.Update()
    End Sub

    Protected Sub btnSubmitStep1_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmitStep1.Click
        Dim numFromPrice As Single = -1 '' default min price
        Dim numToPrice As Single = 99999999999 '' default max price
        Dim strCategories As String = Nothing, strCategoryIDs As String = "0"
        Dim numSupplierID As Integer

        'Collect value of supplier dropdown
        numSupplierID = ddlSupplier.SelectedValue

        If Not String.IsNullOrEmpty(txtFromPrice.Text) AndAlso IsNumeric(txtFromPrice.Text) Then
            numFromPrice = CSng(txtFromPrice.Text)
        End If
        If Not String.IsNullOrEmpty(txtToPrice.Text) AndAlso IsNumeric(txtToPrice.Text) Then
            numToPrice = CSng(txtToPrice.Text)
        End If
        If rdoSelectedCategories.Checked Then
            strCategoryIDs = ""
            For Each itm As ListItem In chklistCategories.Items
                '' comma separeted category info (IDs and Names)
                If itm.Selected Then strCategories += itm.Text + " ," : strCategoryIDs += itm.Value + ","
            Next
            If Not String.IsNullOrEmpty(strCategories) AndAlso strCategories.EndsWith(",") Then strCategories = strCategories.TrimEnd(",") : strCategories = strCategories.Trim()
            If Not String.IsNullOrEmpty(strCategoryIDs) AndAlso strCategoryIDs.EndsWith(",") Then strCategoryIDs = strCategoryIDs.TrimEnd(",")
        End If

        If String.IsNullOrEmpty(strCategoryIDs) Then '' no categories were selected
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_MarkupPrices", "ContentText_MarkupCategoriesNotSelected"))
            Exit Sub
        End If

        Dim dtbVersionsRaw As DataTable = VersionsBLL._GetVersionsByCategoryList(Session("_LANG"), numFromPrice, numToPrice, strCategoryIDs)

        'Here we filter the raw versions by supplier ID if the supplier ID is not zero
        If numSupplierID > 0 Then
            dtbVersionsRaw.DefaultView.RowFilter = ("P_SupplierID=" & numSupplierID)
        Else
            'Just leave as is
        End If

        Dim dtbVersions As DataTable = dtbVersionsRaw.DefaultView.ToTable

        'Build up list of version IDs in order to pull
        'out qty discounts
        Dim strVersionIDs As String = ""
        For Each drwVersion As DataRow In dtbVersions.Rows
            If strVersionIDs <> "" Then strVersionIDs += ","
            strVersionIDs &= drwVersion("V_ID")
        Next

        If ddlTargetField.SelectedValue = "qd" Then
            dtbVersions = VersionsBLL._GetQuantityDiscountsByVersionIDList(strVersionIDs, Session("_LANG"))
        Else
            dtbVersions.Columns.Add(New DataColumn("QD_Quantity", Type.GetType("System.String")))
        End If

        dtbVersions.Columns.Add(New DataColumn("V_OldPrice", Type.GetType("System.String"))) '' Original price with symbol
        dtbVersions.Columns.Add(New DataColumn("V_NewPrice", Type.GetType("System.String"))) '' New price with symbol
        dtbVersions.Columns.Add(New DataColumn("V_OldRRP", Type.GetType("System.String"))) '' Original rrp with symbol
        dtbVersions.Columns.Add(New DataColumn("V_NewRRP", Type.GetType("System.String"))) '' New rrp with symbol

        Dim numValue As Single = 0.0F
        numValue = CSng(txtMarkValue.Text)
        If ddlMarkType.SelectedValue = "v" Then '' Fixed increase/decrease value
            If ddlMarkUpDown.SelectedValue = "down" Then numValue = 0 - numValue '' price will be marked down
            For Each drwVersion As DataRow In dtbVersions.Rows
                If ddlTargetField.SelectedValue = "price" Then
                    drwVersion("V_OldPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("V_Price"))
                    drwVersion("V_NewPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("V_Price") + numValue)
                ElseIf ddlTargetField.SelectedValue = "rrp" Then
                    drwVersion("V_OldRRP") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwVersion("V_RRP")))
                    drwVersion("V_NewRRP") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwVersion("V_RRP")) + numValue)
                ElseIf ddlTargetField.SelectedValue = "qd" Then
                    drwVersion("V_OldPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwVersion("QD_Price")))
                    drwVersion("V_NewPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, FixNullFromDB(drwVersion("QD_Price")) + numValue)
                End If
            Next
        Else '' Percente increase/decrease value
            For Each drwVersion As DataRow In dtbVersions.Rows
                If ddlTargetField.SelectedValue = "price" Then
                    drwVersion("V_OldPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("V_Price"))
                    '' price will be marked up
                    If ddlMarkUpDown.SelectedValue = "up" Then drwVersion("V_NewPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("V_Price") + ((numValue * drwVersion("V_Price")) / 100))
                    '' price will be marked down
                    If ddlMarkUpDown.SelectedValue = "down" Then drwVersion("V_NewPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("V_Price") - ((numValue * drwVersion("V_Price")) / 100))
                ElseIf ddlTargetField.SelectedValue = "rrp" Then
                    Dim sngRRP As Single = FixNullFromDB(drwVersion("V_RRP"))
                    drwVersion("V_OldRRP") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, sngRRP)
                    '' price will be marked up
                    If ddlMarkUpDown.SelectedValue = "up" Then drwVersion("V_NewRRP") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, sngRRP + ((numValue * sngRRP) / 100))
                    '' price will be marked down
                    If ddlMarkUpDown.SelectedValue = "down" Then drwVersion("V_NewRRP") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, sngRRP - ((numValue * sngRRP) / 100))
                ElseIf ddlTargetField.SelectedValue = "qd" Then
                    drwVersion("V_OldPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("QD_Price"))
                    '' price will be marked up
                    If ddlMarkUpDown.SelectedValue = "up" Then drwVersion("V_NewPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("QD_Price") + ((numValue * drwVersion("QD_Price")) / 100))
                    '' price will be marked down
                    If ddlMarkUpDown.SelectedValue = "down" Then drwVersion("V_NewPrice") = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, drwVersion("QD_Price") - ((numValue * drwVersion("QD_Price")) / 100))
                End If
            Next
        End If

        If ddlTargetField.SelectedValue = "price" Then
            gvwVersions.Columns(1).Visible = False
            gvwVersions.Columns(2).Visible = True
            gvwVersions.Columns(3).Visible = True
            gvwVersions.Columns(4).Visible = False
            gvwVersions.Columns(5).Visible = False
        ElseIf ddlTargetField.SelectedValue = "rrp" Then
            gvwVersions.Columns(1).Visible = False
            gvwVersions.Columns(2).Visible = False
            gvwVersions.Columns(3).Visible = False
            gvwVersions.Columns(4).Visible = True
            gvwVersions.Columns(5).Visible = True
        ElseIf ddlTargetField.SelectedValue = "qd" Then
            gvwVersions.Columns(1).Visible = True
            gvwVersions.Columns(2).Visible = True
            gvwVersions.Columns(3).Visible = True
            gvwVersions.Columns(4).Visible = False
            gvwVersions.Columns(5).Visible = False
        End If

        gvwVersions.DataSource = dtbVersions
        gvwVersions.DataBind()


        mvwMain.SetActiveView(viwStep2)
        updMain.Update()
    End Sub

    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack.Click
        gvwVersions.DataSource = Nothing
        gvwVersions.DataBind()
        mvwMain.SetActiveView(viwStep1)
        updMain.Update()
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        SaveChanges()
    End Sub

    ''' <summary>
    ''' Save new prices
    ''' </summary>
    ''' <remarks></remarks>
    Sub SaveChanges()
        Dim strIDsPrices As String = Nothing, strSymbol As String = CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency)
        Dim numCounter As Integer = 0

        '' loop through all gridview rows and get info. to update prices for checked versions
        For Each gvr As GridViewRow In gvwVersions.Rows
            If gvr.RowType = DataControlRowType.DataRow Then
                If CType(gvr.Cells(3).FindControl("chkSave"), CheckBox).Checked Then
                    numCounter += 1
                    '' Appened to list of IDs & Prices in the form of (ID1#Price1;ID2#Price2; ...) 
                    ''    during this will currency symbol will be ignored from the price
                    If ddlTargetField.SelectedValue = "price" Then
                        strIDsPrices &= CType(gvr.Cells(0).FindControl("litID"), Literal).Text & "#" & Replace(HttpContext.Current.Server.HtmlDecode(gvr.Cells(3).Text), strSymbol, "") & ";"
                    ElseIf ddlTargetField.SelectedValue = "rrp" Then
                        strIDsPrices &= CType(gvr.Cells(0).FindControl("litID"), Literal).Text & "#" & Replace(HttpContext.Current.Server.HtmlDecode(gvr.Cells(5).Text), strSymbol, "") & ";"
                    ElseIf ddlTargetField.SelectedValue = "qd" Then
                        strIDsPrices &= CType(gvr.Cells(0).FindControl("litID"), Literal).Text & "," & HttpContext.Current.Server.HtmlDecode(gvr.Cells(1).Text) &
                            "#" & Replace(HttpContext.Current.Server.HtmlDecode(gvr.Cells(3).Text), strSymbol, "") & ";"
                    End If
                End If
            End If
        Next

        If numCounter = 0 Then '' no versions were selected
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_MarkupPrices", "ContentText_MarkupNoneSelected"))
            Exit Sub
        Else
            If strIDsPrices.EndsWith(";") Then strIDsPrices = strIDsPrices.TrimEnd(";")
            Dim strMessage As String = Nothing
            If Not VersionsBLL._MarkupPrices(strIDsPrices, ddlTargetField.SelectedValue, strMessage) Then
                '' error occurred while updating the db
                _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage)
                Exit Sub
            End If
            ClearForm() '' clear the form for new entry
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub

    Sub ClearForm()
        txtFromPrice.Text = Nothing
        txtToPrice.Text = Nothing
        txtMarkValue.Text = Nothing
        ddlMarkType.SelectedIndex = 0
        ddlMarkUpDown.SelectedIndex = 0
        '' clear selection from separate categories
        For Each itm As ListItem In chklistCategories.Items
            itm.Selected = False
        Next
        rdoAllCategories.Checked = True
        rdoSelectedCategories.Checked = False
        rdo_CheckedChanged(Me, New EventArgs)
        mvwMain.SetActiveView(viwStep1)
        updMain.Update()
    End Sub

    Protected Sub SelectAllChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        For Each gvrVersion As GridViewRow In gvwVersions.Rows
            If gvrVersion.RowType = DataControlRowType.DataRow Then
                CType(gvrVersion.Cells(3).FindControl("chkSave"), CheckBox).Checked = CType(sender, CheckBox).Checked
            End If
        Next
    End Sub

    Protected Sub btnUploadPriceList_Click(sender As Object, e As System.EventArgs) Handles btnUploadPriceList.Click
        If filUploader.HasFile Then
            Dim strFileExt As String = Path.GetExtension(filUploader.PostedFile.FileName)
            Dim arrExcludedFileTypes() As String = ConfigurationManager.AppSettings("ExcludedUploadFiles").ToString().Split(",")
            For i As Integer = 0 To arrExcludedFileTypes.GetUpperBound(0)
                If Replace(strFileExt.ToLower, ".", "") = arrExcludedFileTypes(i).ToLower Then
                    'Banned file type, don't upload
                    'Log error so attempts can be seen in logs
                    CkartrisFormatErrors.LogError("Attempt to upload a file of type: " & arrExcludedFileTypes(i).ToLower)
                    _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, "It is not permitted to upload files of this type. Change 'ExcludedUploadFiles' in the web.config if you need to upload this file.")
                    Exit Sub
                End If
            Next
            If Not Directory.Exists(Server.MapPath(KartSettingsManager.GetKartConfig("general.uploadfolder") & "temp/")) Then
                Directory.CreateDirectory(Server.MapPath(KartSettingsManager.GetKartConfig("general.uploadfolder") & "temp/"))
            End If
            Dim strFileName As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "temp/" & Guid.NewGuid.ToString() & strFileExt
            filUploader.SaveAs(Server.MapPath(strFileName))
            Dim f As New StreamReader(Server.MapPath(strFileName))
            txtPriceList.Text = f.ReadToEnd
            f.Dispose()
            Try
                IO.File.Delete(Server.MapPath(strFileName))
            Catch ex As Exception
            End Try
        Else
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_NoFile"))
        End If
    End Sub

    Protected Sub btnSubmitPriceList_Click(sender As Object, e As System.EventArgs) Handles btnSubmitPriceList.Click
        Dim numLines As Integer = 0, strMessage As String = String.Empty
        If VersionsBLL._UpdatePriceList(txtPriceList.Text.Replace(Chr(10), "#"), numLines, strMessage) Then
            txtPriceList.Text = Nothing : updPriceList.Update() '' clear the list for new entry
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        Else
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage & "<br/> Line " & numLines)
        End If
    End Sub
End Class
