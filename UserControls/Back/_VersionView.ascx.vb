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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports CkartrisImages
Imports KartSettingsManager
Partial Class _VersionView
    Inherits System.Web.UI.UserControl

    Public Event VersionsChanged()
    Public Event NeedCategoryRefresh()
    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        lnkBtnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
        _UC_ObjectConfig.ItemID = Request.QueryString("VersionID")
        If Not Page.IsPostBack Then

            'Handle direct opening of version for editing or cloning
            Dim blnClone As Boolean = (Request.QueryString("strClone") = "yes")
            Dim numVersionID As Long = 0
            Try
                numVersionID = Request.QueryString("VersionID")
            Catch
                numVersionID = 0
            End Try
            If numVersionID > 0 Then
                If blnClone Then
                    CloneVersion(numVersionID)
                Else
                    EditVersion(numVersionID)

                End If

                mvwVersions.SetActiveView(viwVersionDetails)
                HighLightTab()
            End If

        End If
        lnkImages.Visible = False
        If (Request.QueryString("strClone") <> "yes") AndAlso ProductsBLL._GetProductType_s(_GetProductID()) = "m" Then
            lnkImages.Visible = True
            LoadVersionImages()
        End If

    End Sub

    Public Sub ShowProductVersions()
        LoadVersions()
    End Sub

    ''' <summary>
    ''' This is called to edit a specific version "used in the _modifyproduct.aspx.vb to modify the selected version
    '''   that is stored in the session.
    ''' </summary>
    ''' <param name="VersionID"></param>
    ''' <remarks></remarks>
    Public Sub EditVersion(ByVal VersionID As Long)
        litVersionID.Text = CStr(VersionID)
        LoadVersionInformation()
    End Sub

    Public Sub CloneVersion(ByVal VersionID As Long)
        litVersionID.Text = CStr(VersionID)
        LoadVersionInformation(True)
    End Sub

    Public Sub LoadVersionInformation(Optional ByVal blnClone As Boolean = False)
        lnkImages.Visible = False
        If blnClone Then
            HideVersionTabs()
            litVersionName.Text = GetGlobalResourceObject("_Version", "PageTitle_CloneVersion")
            updEditVersion.Update()
            _UC_EditVersion.CreateVersionData(GetVersionID(), blnClone)
        Else
            ShowVersionTabs()
            litVersionName.Text = VersionsBLL._GetNameByVersionID(GetVersionID(), Session("_LANG"))
            lnkBtnDelete.Visible = True
            updEditVersion.Update()
            _UC_EditVersion.CreateVersionData(GetVersionID(), blnClone)
            _UC_QtyDiscount.LoadVersionQuantityDiscount(GetVersionID())
            Dim chrProductType As Char = ProductsBLL._GetProductType_s(_GetProductID())
            Select Case chrProductType
                Case "s"
                    lnkBtnDelete.Visible = False
                Case "o"
                    lnkMedia.Visible = False
                    Select Case _UC_EditVersion.GetVersionType()
                        Case "b"
                            lnkQtyDiscount.Visible = True
                            lnkCustomerGroupPrices.Visible = True
                        Case "c"
                            lnkQtyDiscount.Visible = False
                            lnkCustomerGroupPrices.Visible = False
                    End Select
                Case "m"
                    lnkImages.Visible = True
                    LoadVersionImages()
                    LoadVersionMedia()
            End Select
        End If

    End Sub

    Private Sub LoadVersionImages()
        If GetVersionID() = 0 Then Return

        _UC_Uploader.ImageType = IMAGE_TYPE.enum_VersionImage
        _UC_Uploader.ItemID = GetVersionID()
        _UC_Uploader.ParentID = _GetProductID()
        _UC_Uploader.LoadImages()

    End Sub

    Private Sub LoadVersionMedia()
        If GetVersionID() = 0 Then Return

        _UC_EditMedia.ParentType = "v"
        _UC_EditMedia.ParentID = GetVersionID()
        _UC_EditMedia.LoadMedia()
    End Sub
    Private Sub LoadVersions()

        gvwViewVersions.DataSource = Nothing
        gvwViewVersions.DataBind()

        Dim tblVersions As New DataTable
        tblVersions = VersionsBLL._GetByProduct(_GetProductID(), Session("_LANG"))

        If tblVersions.Rows.Count = 0 Then ShowNoVersions() : Exit Sub

        If ConfigurationManager.AppSettings("TaxRegime").tolower = "us" Then gvwViewVersions.Columns(4).Visible = False

        Dim chrProductType As Char = ProductsBLL._GetProductType_s(_GetProductID)
        If chrProductType <> "m" Then
            For Each rw In tblVersions.Rows
                rw("SortByValue") = 0
            Next
        End If

        gvwViewVersions.DataSource = tblVersions
        gvwViewVersions.DataBind()

        If chrProductType = "m" Then ShowHideUpDownArrowsVersions(tblVersions.Rows.Count)

        lnkImages.Visible = False
        Select Case ProductsBLL._GetProductType_s(_GetProductID())
            Case "s", "o"
                CType(gvwViewVersions.HeaderRow.FindControl("lnkNewVersion"), LinkButton).Visible = False
                For i As Integer = 0 To gvwViewVersions.Rows.Count - 1
                    Try
                        CType(gvwViewVersions.Rows(i).FindControl("phdCloneLink"), PlaceHolder).Visible = False
                    Catch ex As Exception
                    End Try
                Next
            Case "m"
                lnkImages.Visible = True
                LoadVersionImages()
                LoadVersionMedia()
        End Select

    End Sub

    Private Sub ShowHideUpDownArrowsVersions(ByVal TotalRows As Integer)
        Try
            CType(gvwViewVersions.Rows(0).Cells(5).FindControl("lnkBtnMoveUp"), LinkButton).Enabled = False
            CType(gvwViewVersions.Rows(TotalRows - 1).Cells(5).FindControl("lnkBtnMoveDown"), LinkButton).Enabled = False
            CType(gvwViewVersions.Rows(0).Cells(5).FindControl("lnkBtnMoveUp"), LinkButton).CssClass &= " triggerswitch_disabled"
            CType(gvwViewVersions.Rows(TotalRows - 1).Cells(5).FindControl("lnkBtnMoveDown"), LinkButton).CssClass &= " triggerswitch_disabled"
        Catch ex As Exception
        End Try
    End Sub

    Private Sub ShowNoVersions()
        mvwVersions.SetActiveView(viwNoVersions)
        updVersions.Update()
    End Sub

    Public Sub PrepareNewVersion()
        litVersionID.Text = "0"
        litVersionName.Text = GetGlobalResourceObject("_Version", "PageTitle_NewVersion")
        HideVersionTabs()
        lnkBtnDelete.Visible = False
        updEditVersion.Update()
        _UC_EditVersion.CreateVersionData(0)
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        FinishEditing()
        LoadVersions()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click

        If Not Page.IsValid Then Return
        If _UC_EditVersion.SaveChanges() Then
            FinishEditing(True)
        End If

    End Sub

    Protected Sub gvwViewVersions_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwViewVersions.PageIndexChanging
        gvwViewVersions.PageIndex = e.NewPageIndex
        LoadVersions()
    End Sub

    Protected Sub gvwViewVersions_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwViewVersions.RowCommand
        Select Case e.CommandName
            Case "NewVersion"
                PrepareNewVersion()
            Case "EditVersion"
                gvwViewVersions.SelectedIndex = CInt(e.CommandArgument) - (gvwViewVersions.PageSize * gvwViewVersions.PageIndex)
                litVersionID.Text = CStr(gvwViewVersions.SelectedValue)
                _UC_Uploader.ClearItems()
                LoadVersions()
                LoadVersionInformation()
            Case "CloneVersion"
                gvwViewVersions.SelectedIndex = CInt(e.CommandArgument) - (gvwViewVersions.PageSize * gvwViewVersions.PageIndex)
                litVersionID.Text = CStr(gvwViewVersions.SelectedValue)
                _UC_Uploader.ClearItems()
                LoadVersions()
                LoadVersionInformation(True)
            Case "MoveUp"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    VersionsBLL._ChangeSortValue(e.CommandArgument, _GetProductID(), "u")
                    LoadVersions()
                    updVersions.Update()
                Catch ex As Exception
                End Try
                Exit Sub
            Case "MoveDown"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    VersionsBLL._ChangeSortValue(e.CommandArgument, _GetProductID(), "d")
                    LoadVersions()
                    updVersions.Update()
                Catch ex As Exception
                End Try
                Exit Sub
        End Select
        SetInnerTab("main")
        updVersions.Update()

    End Sub

    Private Sub FinishEditing(Optional ByVal blnDataChanged As Boolean = False)
        Session("tab") = "version"
        mvwVersions.SetActiveView(viwVersionList)
        updVersions.Update()
        LoadVersions()
        If blnDataChanged Then RaiseEvent VersionsChanged()
    End Sub

    Protected Sub lnkBtnCreateNewVersion_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCreateNewVersion.Click
        mvwVersions.SetActiveView(viwVersionDetails)
        updVersions.Update()
        PrepareNewVersion()
    End Sub

    Protected Sub ctrl_NeedCategoryRefresh() Handles _UC_EditVersion.NeedCategoryRefresh, _UC_EditMedia.NeedCategoryRefresh, _UC_Uploader.NeedCategoryRefresh
        RaiseEvent NeedCategoryRefresh()
    End Sub

    Protected Sub _UC_EditVersion_VersionSaved() Handles _UC_EditVersion.VersionSaved
        RaiseEvent VersionsChanged()
    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", litVersionName.Text)
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Private Function GetVersionID() As Long
        If litVersionID.Text <> "" Then
            Return CLng(litVersionID.Text)
        End If
        Return 0
    End Function

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If Page.IsPostBack Then
            Dim strMessage As String = "", strDownloadFiles = ""
            If VersionsBLL._DeleteVersion(GetVersionID(), strDownloadFiles, strMessage) Then

                If GetKartConfig("backend.files.delete.cleanup ") = "y" Then KartrisDBBLL.DeleteNotNeededFiles()
                RemoveDownloadFiles(strDownloadFiles)

                Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & _GetProductID() & "&CategoryID=" & _GetCategoryID() & _
                        "&strParent=" & _GetParentCategory() & "&strTab=versions")

            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            End If
        End If

    End Sub

    Public Sub SetInnerTab(ByVal strTabName As String)
        Select Case strTabName
            Case "main"
                mvwVersionsDetails.ActiveViewIndex = 0
            Case "images"
                mvwVersionsDetails.ActiveViewIndex = 1
            Case "quantity"
                mvwVersionsDetails.ActiveViewIndex = 2
        End Select
        HighLightTab()
        mvwVersions.SetActiveView(viwVersionDetails)
        updVersions.Update()
    End Sub

    Protected Sub lnkBtnShowVersionsList_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnShowVersionsList.Click
        FinishEditing()
    End Sub

    Sub HighLightTab()
        If mvwVersionsDetails.ActiveViewIndex = 0 Then lnkMainInfo.CssClass = "active" Else lnkMainInfo.CssClass = ""
        If mvwVersionsDetails.ActiveViewIndex = 1 Then lnkImages.CssClass = "active" Else lnkImages.CssClass = ""
        If mvwVersionsDetails.ActiveViewIndex = 2 Then lnkMedia.CssClass = "active" Else lnkMedia.CssClass = ""
        If mvwVersionsDetails.ActiveViewIndex = 3 Then lnkQtyDiscount.CssClass = "active" Else lnkQtyDiscount.CssClass = ""
        If mvwVersionsDetails.ActiveViewIndex = 4 Then lnkCustomerGroupPrices.CssClass = "active" Else lnkCustomerGroupPrices.CssClass = ""
        If mvwVersionsDetails.ActiveViewIndex = 5 Then lnkObjectConfig.CssClass = "active" Else lnkObjectConfig.CssClass = ""
    End Sub

    Sub lnkMainInfo_Click() Handles lnkMainInfo.Click
        mvwVersionsDetails.ActiveViewIndex = 0
        HighLightTab()
    End Sub

    Sub lnkImages_Click() Handles lnkImages.Click
        mvwVersionsDetails.ActiveViewIndex = 1
        HighLightTab()
    End Sub

    Sub lnkMedia_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkMedia.Click
        mvwVersionsDetails.ActiveViewIndex = 2
        HighLightTab()
    End Sub

    Sub lnkQtyDiscount_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkQtyDiscount.Click
        mvwVersionsDetails.ActiveViewIndex = 3
        HighLightTab()
    End Sub

    Sub lnkCustomerGroupPrices_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkCustomerGroupPrices.Click
        mvwVersionsDetails.ActiveViewIndex = 4
        HighLightTab()

        Dim numVersionID As Long = 0
        Try
            numVersionID = Request.QueryString("VersionID")
        Catch
        End Try

        _UC_CustomerGroupPrices.VersionID = numVersionID
        _UC_CustomerGroupPrices.LoadCustomerGroupPrices(CInt(Session("_LANG")))

    End Sub

    Sub lnkObjectConfig_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkObjectConfig.Click
        mvwVersionsDetails.ActiveViewIndex = 5
        HighLightTab()
        _UC_ObjectConfig.LoadObjectConfig()
    End Sub


    Sub ShowVersionTabs()
        lnkMainInfo.Visible = True
        lnkImages.Visible = True
        lnkMedia.Visible = True
        lnkQtyDiscount.Visible = True
        lnkCustomerGroupPrices.Visible = True
    End Sub

    Sub HideVersionTabs()
        lnkImages.Visible = False
        lnkMedia.Visible = False
        lnkQtyDiscount.Visible = False
        lnkCustomerGroupPrices.Visible = False
    End Sub

    Protected Sub gvwViewVersions_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwViewVersions.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Not IsNumeric(e.Row.Cells(3).Text) Then Exit Sub
            e.Row.Cells(3).Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency(), CSng(e.Row.Cells(3).Text))
            e.Row.Cells(3).Text = _HandleDecimalValues(e.Row.Cells(3).Text)
        End If
    End Sub

    'This communicates update message for the user controls
    'that are nested within the versionview
    Protected Sub ShowMasterUpdateMessage() Handles _UC_QtyDiscount.ShowMasterUpdate,
                                                    _UC_CustomerGroupPrices.ShowMasterUpdate, _
                                                    _UC_ObjectConfig.ShowMasterUpdate
        RaiseEvent VersionsChanged()
    End Sub


End Class
