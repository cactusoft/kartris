'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

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

Partial Class _CategoryView

    Inherits System.Web.UI.UserControl

    Private c_ShowPages As Boolean = True
    Protected Shared sortByValueBool As Boolean = False
    Const c_PROD_PAGER_QUERY_STRING_KEY As String = "_PPGR"
    Const c_CAT_PAGER_QUERY_STRING_KEY As String = "_CPGR"

    Public Event ShowMasterUpdate()

    Public WriteOnly Property ShowHeader() As Boolean
        Set(ByVal value As Boolean)
            phdHeader.Visible = value
        End Set
    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        lnkPreview.NavigateUrl = "~/Category.aspx?CategoryID=" & _GetCategoryID()

        If Not Page.IsPostBack Then
            If _GetCategoryID() <> 0 Then
                If CategoriesBLL._GetByID(_GetCategoryID()).Rows.Count = 0 Then RedirectToMainCategory()
                litCatName.Text = CategoriesBLL._GetNameByCategoryID(_GetCategoryID(), Session("_LANG"))
                LoadProducts() '' Only if its not the main category will show the products
            Else
                phdBreadCrumbTrail.Visible = False
                phdEditCategory.Visible = True
                phdProducts.Visible = False '' if categoryID = 0 then no products under it directly
            End If
            LoadSubCategories()
        End If

        If _GetCategoryID() = 0 Then
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Categories, False, _GetCategoryID())
            lnkBtnModifyPage.Visible = False
        End If
    End Sub

    Protected Sub btnUpdatePreference_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdatePreference.Click
        UpdatePreference()
    End Sub


    Protected Sub UpdatePreference()
        If Request.Form("CAT_ID") <> currentPreference.Value Then

            Dim preferenceIds As Integer() = (From p In Request.Form("CAT_ID").Split(",")
                                              Select Integer.Parse(p)).ToArray()
            Dim preference As Integer = 1
            For Each categoryId As Integer In preferenceIds
                Me.UpdatePreference(categoryId, preference, _GetCategoryID())
                preference += 1
            Next

        End If
    End Sub

    Private Sub UpdatePreference(id As Integer, preference As Integer, parent As Integer)
        Dim _connectionstring As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
        Using con As New SqlConnection(_connectionstring)
            Using cmd As New SqlCommand("UPDATE tblKartrisCategoryHierarchy SET CH_OrderNo = @Preference WHERE CH_ChildId = @Id AND CH_ParentID = @Parent")
                Using sda As New SqlDataAdapter()
                    cmd.CommandType = CommandType.Text
                    cmd.Parameters.AddWithValue("@Id", id)
                    cmd.Parameters.AddWithValue("@Preference", preference)
                    cmd.Parameters.AddWithValue("@Parent", parent)
                    cmd.Connection = con
                    con.Open()
                    cmd.ExecuteNonQuery()
                    con.Close()
                End Using
            End Using
        End Using
    End Sub

    Protected Sub btnUpdatePreferenceProducts_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdatePreferenceProducts.Click
        UpdatePreferenceProducts()
    End Sub


    Protected Sub UpdatePreferenceProducts()
        If Request.Form("P_ID") <> currentPreferenceProducts.Value Then

            Dim preferenceIds As Integer() = (From p In Request.Form("P_ID").Split(",")
                                              Select Integer.Parse(p)).ToArray()
            Dim preference As Integer = 1
            For Each productId As Integer In preferenceIds
                Me.UpdatePreferenceProducts(productId, preference, _GetCategoryID())
                preference += 1
            Next

        End If
    End Sub

    Private Sub UpdatePreferenceProducts(id As Integer, preference As Integer, categoryId As Integer)
        Dim _connectionstring As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
        Using con As New SqlConnection(_connectionstring)
            Using cmd As New SqlCommand("UPDATE tblKartrisProductCategoryLink SET PCAT_OrderNo = @Preference WHERE PCAT_ProductID = @Id AND PCAT_CategoryID = @CategoryId")
                Using sda As New SqlDataAdapter()
                    cmd.CommandType = CommandType.Text
                    cmd.Parameters.AddWithValue("@Id", id)
                    cmd.Parameters.AddWithValue("@Preference", preference)
                    cmd.Parameters.AddWithValue("@CategoryId", categoryId)
                    cmd.Connection = con
                    con.Open()
                    cmd.ExecuteNonQuery()
                    con.Close()
                End Using
            End Using
        End Using
    End Sub

    'Load subcategories
    Public Sub LoadSubCategories()
        Dim numCategoryPageSize As Integer = 1000
        If KartSettingsManager.GetKartConfig("backend.categories.paging.enabled") = "y" Then
            numCategoryPageSize = KartSettingsManager.GetKartConfig("backend.categories.display.pagesize")
        End If
        Dim numTotalNumberOfCategories As Integer = 0

        Dim numPageIndx As Short
        Try
            If Request.QueryString(c_CAT_PAGER_QUERY_STRING_KEY) Is Nothing Then
                numPageIndx = 0
            Else
                numPageIndx = CShort(Request.QueryString(c_CAT_PAGER_QUERY_STRING_KEY))
            End If
        Catch ex As Exception
            numPageIndx = 0
        End Try


        Dim tblCategories As New DataTable

        If c_ShowPages Then
            tblCategories = CategoriesBLL._GetCategoriesPageByParentID(_GetCategoryID(), Session("_LANG"), numPageIndx,
                                            numCategoryPageSize, numTotalNumberOfCategories)
            If tblCategories.Rows.Count <> 0 Then
                If numTotalNumberOfCategories > numCategoryPageSize Then
                    _UC_ItemPager_CAT_Header.LoadPager(numTotalNumberOfCategories, numCategoryPageSize, c_CAT_PAGER_QUERY_STRING_KEY)
                    _UC_ItemPager_CAT_Header.DisableLink(numPageIndx)
                    _UC_ItemPager_CAT_Header.Visible = True
                End If
                dtlSubCategories.DataSource = tblCategories
                dtlSubCategories.DataBind()
                ShowHideUpDownArrowsSubCategories(numTotalNumberOfCategories)
            Else
                dtlSubCategories.Visible = False
                phdNoSubCategories.Visible = True
            End If
        Else
            tblCategories = CategoriesBLL._GetCategoriesPageByParentID(_GetCategoryID(), Session("_LANG"), 0,
                                            500, 500)
            If tblCategories.Rows.Count <> 0 Then
                dtlSubCategories.DataSource = tblCategories
                dtlSubCategories.DataBind()
            Else
                dtlSubCategories.Visible = False
                phdNoSubCategories.Visible = True
            End If
        End If
        Dim currentPreferencesItems = tblCategories.AsEnumerable().Select(Function(row) New With {.catId = row.Field(Of Int32)("CAT_ID")})
        Dim sb As StringBuilder = New StringBuilder()
        Dim currentPreferences As String = String.Join(",", currentPreferencesItems.ToList()).ToString().Replace("{", "").Replace("}", "").Replace("catId = ", "").Replace(" ", "").Replace("vbCrLf", "")
        currentPreference.Value = currentPreferences
    End Sub

    'Whether to show the up/down subcat buttons
    Private Sub ShowHideUpDownArrowsSubCategories(ByVal TotalRows As Integer)
        Try
            CType(dtlSubCategories.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).Enabled = False
            CType(dtlSubCategories.Items(TotalRows - 1).FindControl("lnkBtnMoveDown"), LinkButton).Enabled = False
            CType(dtlSubCategories.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).CssClass &= " triggerswitch_disabled"
            CType(dtlSubCategories.Items(TotalRows - 1).FindControl("lnkBtnMoveDown"), LinkButton).CssClass &= " triggerswitch_disabled"
        Catch ex As Exception
        End Try
    End Sub

    ''Load products
    Public Sub LoadProducts()
        Dim numProductPageSize As Integer = 1000
        If KartSettingsManager.GetKartConfig("backend.products.paging.enabled") = "y" Then
            numProductPageSize = KartSettingsManager.GetKartConfig("backend.products.display.pagesize")
        End If
        Dim numTotalNumberOfProducts As Integer = 0

        Dim numPageIndx As Short
        Try
            If Request.QueryString(c_PROD_PAGER_QUERY_STRING_KEY) Is Nothing Then
                numPageIndx = 0
            Else
                numPageIndx = Request.QueryString(c_PROD_PAGER_QUERY_STRING_KEY)
            End If
        Catch ex As Exception
            numPageIndx = 0
        End Try


        Dim tblProducts As New DataTable
        If c_ShowPages Then
            tblProducts = ProductsBLL._GetProductsPageByCategory(_GetCategoryID(), Session("_LANG"), numPageIndx,
                                                                numProductPageSize, numTotalNumberOfProducts)
            If tblProducts.Rows.Count <> 0 Then
                If numTotalNumberOfProducts > numProductPageSize Then
                    _UC_ItemPager_PROD_Header.LoadPager(numTotalNumberOfProducts, numProductPageSize, c_PROD_PAGER_QUERY_STRING_KEY)
                    _UC_ItemPager_PROD_Header.DisableLink(numPageIndx)
                    _UC_ItemPager_PROD_Header.Visible = True
                End If
                phdNoProducts.Visible = False
                lnkTurnProductsOn.Visible = True
                lnkTurnProductsOff.Visible = True
            Else
                dtlProducts.Visible = False
                _UC_ItemPager_PROD_Header.Visible = False
            End If
        Else
            tblProducts = ProductsBLL._GetProductsPageByCategory(_GetCategoryID(), Session("_LANG"), 0, 1000, 1000)
            If tblProducts.Rows.Count <> 0 Then
                phdNoProducts.Visible = False
            End If
        End If


        If tblProducts.Rows.Count > 0 Then
            Dim sortByValue = tblProducts.Rows(0)("SortByValue")
            If Not String.IsNullOrEmpty(sortByValue) Then
                sortByValueBool = Convert.ToBoolean(sortByValue)
            End If
            If sortByValueBool Then
                Dim currentPreferencesItems = tblProducts.AsEnumerable().Select(Function(row) New With {.pId = row.Field(Of Int32)("P_ID")})
                Dim sb As StringBuilder = New StringBuilder()
                Dim currentPreferences As String = String.Join(",", currentPreferencesItems.ToList()).ToString().Replace("{", "").Replace("}", "").Replace("pId = ", "").Replace(" ", "").Replace("vbCrLf", "")
                currentPreferenceProducts.Value = currentPreferences
            End If
        End If
        dtlProducts.DataSource = tblProducts
        dtlProducts.DataBind()
        ShowHideUpDownArrowsProducts(numTotalNumberOfProducts)
    End Sub

    ''Whether to show the up/down
    Private Sub ShowHideUpDownArrowsProducts(ByVal TotalRows As Integer)
        Try
            CType(dtlProducts.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).Enabled = False
            CType(dtlProducts.Items(TotalRows - 1).FindControl("lnkBtnMoveDown"), LinkButton).Enabled = False
            CType(dtlProducts.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).CssClass &= " triggerswitch_disabled"
            CType(dtlProducts.Items(TotalRows - 1).FindControl("lnkBtnMoveDown"), LinkButton).CssClass &= " triggerswitch_disabled"
        Catch ex As Exception
        End Try
    End Sub

    Protected Sub dtlProducts_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataListCommandEventArgs) Handles dtlProducts.ItemCommand
        Dim strTab As String = ""
        Select Case e.CommandName
            Case "select"
                dtlProducts.SelectedIndex = e.Item.ItemIndex
                LoadProducts()
            Case "AddVersion"
                If CType(dtlProducts.SelectedItem.FindControl("litProductType"), Literal).Text = "o" Then
                    strTab = "options"
                Else
                    strTab = "versions"
                End If
                Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & e.CommandArgument & "&strParent=" & _GetCategoryID() & "&strTab=" & strTab)
            Case "MoveUp"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    ProductsBLL._ChangeSortValue(_GetCategoryID(), e.CommandArgument, "u")
                    LoadProducts()
                Catch ex As Exception
                End Try
            Case "MoveDown"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    ProductsBLL._ChangeSortValue(_GetCategoryID(), e.CommandArgument, "d")
                    LoadProducts()
                Catch ex As Exception
                End Try
            Case "Refresh"
                Try
                    UpdatePreferenceProducts()
                    LoadProducts()
                Catch ex As Exception
                End Try
        End Select
    End Sub

    Public Function FormatNavURL(ByVal ParentCategoryID As String, ByVal CategoryID As Long) As String
        Dim strURL As String = IIf(String.IsNullOrEmpty(_GetParentCategory), _GetCategoryID(), _GetParentCategory() & "," & _GetCategoryID())
        If strURL = "0" Then
            Return "~/Admin/_Category.aspx?CategoryID=" & Eval("CAT_ID")
        Else
            Return "~/Admin/_Category.aspx?CategoryID=" & Eval("CAT_ID") & "&strParent=" & strURL
        End If
    End Function

    Protected Sub dtlProducts_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs) Handles dtlProducts.ItemDataBound

        Dim chrProductType As Char = ""
        Try
            chrProductType = CChar(CType(e.Item.FindControl("litProductType"), Literal).Text)
        Catch ex As Exception
            Return
        End Try
        If e.Item.ItemIndex = dtlProducts.SelectedIndex Then
            Dim numProductID As Integer = CType(e.Item.FindControl("litProductID"), Literal).Text
            Dim tblVersions As New DataTable
            tblVersions = VersionsBLL._GetByProduct(numProductID, Session("_LANG"))
            Dim dtcShowClone As DataColumn = New DataColumn("ShowClone", Type.GetType("System.Boolean"))
            dtcShowClone.DefaultValue = True
            tblVersions.Columns.Add(dtcShowClone)

            If chrProductType = "o" Then
                CType(e.Item.FindControl("phdOptionsLink"), PlaceHolder).Visible = True
            End If
            If chrProductType <> "m" _
                AndAlso tblVersions.Rows.Count > 0 Then
                CType(e.Item.FindControl("phdNewVersionLink"), PlaceHolder).Visible = False
                For Each row As DataRow In tblVersions.Rows
                    row("ShowClone") = False
                Next
            End If

            CType(e.Item.FindControl("rptVersions"), Repeater).DataSource = tblVersions
            CType(e.Item.FindControl("rptVersions"), Repeater).DataBind()

        End If
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem _
            OrElse e.Item.ItemType = ListItemType.SelectedItem Then
            If chrProductType = "o" OrElse chrProductType = "b" Then
                CType(e.Item.FindControl("phdOptionsLink"), PlaceHolder).Visible = True
            End If
        End If
    End Sub

    Protected Sub dtlSubCategories_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataListCommandEventArgs) Handles dtlSubCategories.ItemCommand
        Select Case e.CommandName
            Case "select"
                Dim numCategoryID As Integer = CType(e.Item.FindControl("litCategoryID"), Literal).Text
                Dim strParent As String
                strParent = _GetParentCategory()
                If String.IsNullOrEmpty(strParent) Then strParent = _GetCategoryID() Else strParent += "," & _GetCategoryID()
                If strParent = "0" Then
                    Response.Redirect("~/Admin/_Category.aspx?CategoryID=" & numCategoryID)
                Else
                    Response.Redirect("~/Admin/_Category.aspx?CategoryID=" & numCategoryID & "&strParent=" & strParent)
                End If
            Case "MoveUp"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    CategoriesBLL._ChangeSortValue(_GetCategoryID(), e.CommandArgument, "u")
                    LoadSubCategories()
                    RefreshSiteMap()
                    updSubCategories.Update()
                Catch ex As Exception
                End Try
            Case "MoveDown"
                '' Will use try to avoid error in case of null values or 0 values
                Try
                    CategoriesBLL._ChangeSortValue(_GetCategoryID(), e.CommandArgument, "d")
                    LoadSubCategories()
                    RefreshSiteMap()
                    updSubCategories.Update()
                Catch ex As Exception
                End Try
            Case "Refresh"
                Try
                    UpdatePreference()
                    LoadSubCategories()
                    RefreshSiteMap()
                    updSubCategories.Update()
                Catch ex As Exception
                End Try
        End Select
    End Sub

    Protected Sub lnkBtnModifyPage_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnModifyPage.Click
        If _GetCategoryID() = 0 Then
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Categories, False, _GetCategoryID())
            mvwCategory.SetActiveView(viwCategoryDetails)
            updCategoryViews.Update()
        ElseIf CStr(_GetParentCategory()) = "" Then
            Response.Redirect("_ModifyCategory.aspx?CategoryID=" & _GetCategoryID() & "&strParent=0")
        Else
            Response.Redirect("_ModifyCategory.aspx?CategoryID=" & _GetCategoryID() & "&strParent=" & _GetParentCategory())
        End If
    End Sub

    Protected Sub lnkBtnNewCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewCategory.Click
        Response.Redirect("_ModifyCategory.aspx?CategoryID=0&strParent=" & _GetCategoryID() & "&Sub=" & _GetParentCategory())
    End Sub

    Sub RedirectToMainCategory()
        Response.Redirect("~/Admin/_Category.aspx?CategoryID=0")
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        Dim tblLanguageContents As New DataTable()
        tblLanguageContents = _UC_LangContainer.ReadContent()
        Dim strMessage As String = ""
        If Not CategoriesBLL._UpdateCategory(tblLanguageContents, "", 0, Nothing, Nothing, _
                                    Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return
        End If
        RefreshSiteMap()
        RaiseEvent ShowMasterUpdate()
        ShowHierarchy()
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        ShowHierarchy()
    End Sub

    Sub ShowHierarchy()
        mvwCategory.SetActiveView(viwCategoryHierarchy)
        updCategoryViews.Update()
    End Sub

    'Turn all products in a category ON (live=true)
    Protected Sub lnkTurnProductsOn_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkTurnProductsOn.Click
        If ProductsBLL._HideShowAllByCategoryID(_GetCategoryID(), True) Then
            RaiseEvent ShowMasterUpdate()
            LoadProducts()
        End If
    End Sub

    ''Turn all products in a category OFF (live=false)
    Protected Sub lnkTurnProductsOff_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkTurnProductsOff.Click
        If ProductsBLL._HideShowAllByCategoryID(_GetCategoryID(), False) Then
            RaiseEvent ShowMasterUpdate()
            LoadProducts()
        End If
    End Sub
End Class
