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
Imports CkartrisDataManipulation
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisImages
Imports KartSettingsManager

Partial Class _EditProduct
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' raised when the product does not exist
    ''' </summary>
    ''' <remarks></remarks>
    Public Event ProductNotExist()

    ''' <summary>
    ''' raised when the product is saved
    ''' </summary>
    ''' <remarks></remarks>
    Public Event ProductSaved()

    Public Event ProductUpdated(ByVal strNewName As String)

    Private _ProductType As Char

    Public ReadOnly Property GetProductType() As Char
        Get
            Return _ProductType
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        btnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.Products
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.Products

        litProductID.Text = _GetProductID()
        If Not Page.IsPostBack Then AddParentCategory()

        If Session("_tab") = "products" Then
            If ddlCustomerGroup.Items.Count <= 1 Then
                Dim drwCGs As DataRow() = GetCustomerGroupsFromCache.Select("CG_Live = 1 AND LANG_ID=" & Session("_LANG"))
                ddlCustomerGroup.DataTextField = "CG_Name"
                ddlCustomerGroup.DataValueField = "CG_ID"
                ddlCustomerGroup.DataSource = drwCGs
                ddlCustomerGroup.DataBind()
            End If
            If ddlSupplier.Items.Count <= 1 Then
                Dim drwSuppliers As DataRow() = GetSuppliersFromCache.Select("SUP_Live = 1")
                ddlSupplier.DataTextField = "SUP_Name"
                ddlSupplier.DataValueField = "SUP_ID"
                ddlSupplier.DataSource = drwSuppliers
                ddlSupplier.DataBind()
            End If
            ReloadProduct()
        End If
        CheckProductType()
    End Sub

    Public Sub ReloadProduct()
        If _GetProductID() = 0 Then 'new product
            '' If there is no parent category, we should make sure that we have categories in the db.
            If _GetParentCategory() = 0 Then
                If CategoriesBLL._GetTotalCategoriesByLanguageID(Session("_LANG")) = 0 Then
                    phdNoCategories.Visible = True
                    phdEditProduct.Visible = False
                Else
                    phdNoCategories.Visible = False
                    phdEditProduct.Visible = True
                End If
            End If
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Products, True)
            chkLive.Checked = True
            lnkBtnDelete.Visible = False
            hlinkPreview.Visible = False
        Else
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Products, False, _GetProductID)
            If Not Page.IsPostBack Then LoadProductInfo()
            lnkBtnDelete.Visible = True
            hlinkPreview.NavigateUrl = "~/Product.aspx?ProductID=" & _GetProductID()
            hlinkPreview.Visible = True
        End If
    End Sub

    ''' <summary>
    ''' reads the parent category from the query string and add it to the parents' list
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub AddParentCategory()
        Dim numParentCategoryID As Integer = 0
        Try
            numParentCategoryID = _GetCategoryID()
        Catch ex As Exception
            '
        End Try

        lbxProductCategories.Items.Clear()

        If numParentCategoryID <> 0 Then
            If lbxProductCategories.Items.FindByValue(CStr(numParentCategoryID)) Is Nothing Then
                lbxProductCategories.Items.Add( _
                        New ListItem(CategoriesBLL._GetNameByCategoryID(numParentCategoryID, Session("_LANG")), _
                        CStr(numParentCategoryID)))
                lbxProductCategories.SelectedIndex = lbxProductCategories.Items.Count - 1
            End If
        End If

    End Sub

    ''' <summary>
    ''' reads the product info from the db
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub LoadProductInfo()

        Dim tblProducts As New DataTable
        tblProducts = ProductsBLL._GetProductInfoByID(_GetProductID())

        '' if no product returned "not exist in the db"
        If tblProducts.Rows.Count = 0 Then RaiseEvent ProductNotExist() : Exit Sub

        '' -----------------------------------------
        '' Load Product Main Info. into the contorls
        chkLive.Checked = CBool(tblProducts.Rows(0)("P_Live"))

        txtFeaturedLevel.Text = FixNullFromDB(tblProducts.Rows(0)("P_Featured"))

        ddlOrderVersionsBy.SelectedValue = FixNullFromDB(tblProducts.Rows(0)("P_OrderVersionsBy"))
        ddlVersionsSortDirection.SelectedValue = FixNullFromDB(tblProducts.Rows(0)("P_VersionsSortDirection"))
        ddlVersionDisplay.SelectedValue = FixNullFromDB(tblProducts.Rows(0)("P_VersionDisplayType"))
        ddlCustomerReviews.SelectedValue = FixNullFromDB(tblProducts.Rows(0)("P_Reviews"))
        Try
            ddlSupplier.SelectedValue = FixNullFromDB(tblProducts.Rows(0)("P_SupplierID"))
        Catch ex As Exception
            ddlSupplier.SelectedValue = "0"
        End Try

        ddlProductType.SelectedValue = FixNullFromDB(tblProducts.Rows(0)("P_Type"))
        _ProductType = CChar(ddlProductType.SelectedValue)

        Try
            ddlCustomerGroup.SelectedValue = FixNullFromDB(tblProducts.Rows(0)("P_CustomerGroupID")) ''Customer Group
        Catch ex As Exception
            ddlCustomerGroup.SelectedValue = "0"
        End Try

        litDateCreated.Text = FormatDate(FixNullFromDB(tblProducts.Rows(0)("P_DateCreated")), "t", Session("_LANG"))
        litLastModified.Text = FormatDate(FixNullFromDB(tblProducts.Rows(0)("P_LastModified")), "t", Session("_LANG"))

        '' -----------------------------------------

        '' -----------------------------------------
        '' checks the product's type to decide if it could be changed
        CheckProductType()
        '' -----------------------------------------

        '' -----------------------------------------
        '' Load Product's Parents into the 'Parent List'
        Dim tblProductCategories As New DataTable
        tblProductCategories = ProductsBLL._GetCategoriesByProductID(_GetProductID())
        lbxProductCategories.Items.Clear()
        For Each row In tblProductCategories.Rows
            Dim itm As New ListItem
            itm.Value = CStr(FixNullFromDB(row("PCAT_CategoryID")))
            itm.Text = CategoriesBLL._GetNameByCategoryID(CInt(itm.Value), Session("_LANG"))
            lbxProductCategories.Items.Add(itm)
        Next
        '' -----------------------------------------
        updMain.Update()
    End Sub

    ''' <summary>
    ''' checking the product type, to decide if the product's type could be changed or no
    '''    - "Multiple Version" product with more than one version --> Not allowed
    '''    - "Option Product" --> Not allowed to be changed
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub CheckProductType()
        ddlProductType.Enabled = True '' by default always allow the changes
        Select Case ddlProductType.SelectedValue
            Case "m"    '' multiple version product
                If VersionsBLL._GetNoOfVersionsByProductID(_GetProductID()) > 1 Then
                    ddlProductType.Enabled = False
                End If
                ddlVersionDisplay.Enabled = True
                ddlVersionsSortDirection.Enabled = True
                ddlOrderVersionsBy.Enabled = True
                'Try to remove the 'options' display type
                Try
                    ddlVersionDisplay.Items.Remove(ddlVersionDisplay.Items.FindByValue("o"))
                Catch ex As Exception
                    'Maybe failed because options type was
                    'selected, so reselect then try again
                    ddlVersionDisplay.SelectedValue = "r"
                    ddlVersionDisplay.Items.Remove(ddlVersionDisplay.Items.FindByValue("o"))
                End Try
                'Try to remove the 'none' display type
                Try
                    ddlVersionDisplay.Items.Remove(ddlVersionDisplay.Items.FindByValue("l"))
                Catch ex As Exception
                    'Maybe failed because options type was
                    'selected, so reselect then try again
                    ddlVersionDisplay.SelectedValue = "r"
                    ddlVersionDisplay.Items.Remove(ddlVersionDisplay.Items.FindByValue("l"))
                End Try
            Case "o"    '' option product
                If VersionsBLL._GetNoOfVersionsByProductID(_GetProductID()) > 0 Then
                    ddlProductType.Enabled = False
                End If

                'Add options in
                Dim itmNew As New ListItem
                itmNew.Text = GetGlobalResourceObject("_Product", "ContentText_OptionsVerDisplayType")
                itmNew.Value = "o"
                itmNew.Selected = True
                ddlVersionDisplay.Items.Add(itmNew)

                ddlVersionDisplay.SelectedValue = "o"
                ddlVersionDisplay.Enabled = False
                ddlVersionsSortDirection.Enabled = False
                ddlOrderVersionsBy.Enabled = False
            Case "s"    '' single version product
                'Add 'none' in
                Dim itmNew As New ListItem
                itmNew.Text = GetGlobalResourceObject("_Product", "ContentText_NoneVerDisplayType")
                itmNew.Value = "l"
                itmNew.Selected = True
                ddlVersionDisplay.Items.Add(itmNew)

                ddlVersionDisplay.SelectedValue = "l"
                ddlVersionDisplay.Enabled = False
                ddlVersionsSortDirection.Enabled = False
                ddlOrderVersionsBy.Enabled = False
        End Select
    End Sub

    ''' <summary>
    ''' checks product type and adjusts other menus accordingly
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub ddlProductType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlProductType.SelectedIndexChanged
        CheckProductType()
        updProductType.Update()
        updVersionDisplayType.Update()
        updSortVersions.Update()
        updSortDirection.Update()
    End Sub

    ''' <summary>
    ''' used to reset the original info. from the db
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub ResetChanges()
        '' 1. reset the controls
        '' 2. reset the language elements ... (clear the controls)
        '' 3. reads the language elements for the current category
        '' 4. loads the product info. from db

        chkLive.Checked = False
        ddlOrderVersionsBy.SelectedIndex = 0
        ddlVersionDisplay.SelectedIndex = 0
        ddlCustomerGroup.SelectedIndex = 0
        ddlSupplier.SelectedIndex = 0
        ddlProductType.SelectedIndex = 0
        ddlProductType.Enabled = True
        litDateCreated.Text = Nothing
        litLastModified.Text = Nothing

        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Products, True)
        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Products, False, _GetProductID())

        updMain.Update()
        LoadProductInfo()
    End Sub

    ''' <summary>
    ''' adds the selected category from autocomplete list to the parents' list
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub lnkBtnAddCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnAddCategory.Click
        Try
            Dim strCategoryText As String = _UC_AutoComplete.GetText()
            If strCategoryText <> "" Then
                Dim numCategoryID As Integer = CInt(Mid(strCategoryText, strCategoryText.LastIndexOf("(") + 2, strCategoryText.LastIndexOf(")") - strCategoryText.LastIndexOf("(") - 1))
                Dim strCategoryName As String = CategoriesBLL._GetNameByCategoryID(numCategoryID, Session("_LANG"))
                If Not strCategoryName Is Nothing Then
                    If lbxProductCategories.Items.FindByValue(CStr(numCategoryID)) Is Nothing Then
                        lbxProductCategories.Items.Add(New ListItem(strCategoryName, CStr(numCategoryID)))
                        lbxProductCategories.SelectedIndex = lbxProductCategories.Items.Count - 1
                    End If
                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidCategory"))
                End If
            End If
        Catch ex As Exception
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_InvalidCategory"))
        Finally
            _UC_AutoComplete.ClearText()
            _UC_AutoComplete.SetFoucs()
        End Try

    End Sub

    ''' <summary>
    ''' removes the selected parent category from the parents' list
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub lnkBtnRemoveProductCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnRemoveProductCategory.Click
        Dim selectedIndx As Integer = lbxProductCategories.SelectedIndex
        If selectedIndx >= 0 Then
            lbxProductCategories.Items.RemoveAt(selectedIndx)
            If lbxProductCategories.Items.Count >= selectedIndx Then
                lbxProductCategories.SelectedIndex = selectedIndx - 1
            Else
                If lbxProductCategories.Items.Count <> 0 Then
                    lbxProductCategories.SelectedIndex = lbxProductCategories.Items.Count - 1
                End If
            End If
        End If
    End Sub

    ''' <summary>
    ''' saving the changes 
    '''  - (update for the existing product)
    '''  - (insert for the new product)
    '''  Steps:
    '''  1. read the Language Elements of the product to save them.
    '''  2. read the parents' cat. to be saved in the product category link.
    '''  3. read the main product info.
    '''  4. save the changes (update/insert) 
    '''       INSERT --> redirect the page with the new changes
    '''       UPDATE --> rais the product saved event
    ''' </summary>
    ''' <param name="enumOperation"></param>
    ''' <remarks></remarks>
    Private Sub SaveProduct(ByVal enumOperation As DML_OPERATION)

        '' double check if any parent category is selected
        If lbxProductCategories.Items.Count = 0 Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Category", "ContentText_SelectParentCategory"))
            Exit Sub
        End If

        Dim tblLanguageContents As New DataTable()
        Dim sbdParentsList As New StringBuilder("")
        Dim blnLive As Boolean, chrVersionDisplayType As Char, chrReviews As Char, chrType As Char
        Dim numSupplier As Integer, numCustomerGroup As Integer, numFeatured As Byte
        Dim strOrderVersionsBy As String, chrVersionsSortDirection As Char

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 1. Language Contents

        tblLanguageContents = _UC_LangContainer.ReadContent()

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 2. Parents List
        For Each itm As ListItem In lbxProductCategories.Items
            sbdParentsList.Append(itm.Value)
            sbdParentsList.Append(",")
        Next
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 3. Product Main Info.
        blnLive = chkLive.Checked

        'numFeatured = CByte(ddlFeatured.SelectedValue())
        Try
            numFeatured = txtFeaturedLevel.Text
        Catch ex As Exception
            numFeatured = 0
        End Try

        strOrderVersionsBy = CStr(ddlOrderVersionsBy.SelectedValue())
        chrVersionsSortDirection = CChar(ddlVersionsSortDirection.SelectedValue())
        chrReviews = CChar(ddlCustomerReviews.SelectedValue)
        chrVersionDisplayType = CChar(ddlVersionDisplay.SelectedValue())
        Try
            numSupplier = CInt(ddlSupplier.SelectedValue())
        Catch ex As Exception
            numSupplier = 0
        End Try
        chrType = CChar(ddlProductType.SelectedValue())
        Try
            numCustomerGroup = CInt(ddlCustomerGroup.SelectedValue())
        Catch ex As Exception
            numCustomerGroup = 0
        End Try


        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        Dim strMessage As String = ""
        Dim intProductID As Integer = _GetProductID()
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not ProductsBLL._UpdateProduct( _
                                tblLanguageContents, sbdParentsList.ToString, intProductID, blnLive, numFeatured, _
                                 strOrderVersionsBy, chrVersionsSortDirection, chrReviews, chrVersionDisplayType, numSupplier, chrType, numCustomerGroup, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                Dim rowLanguageContents As DataRow() = tblLanguageContents.Select("_LE_LanguageID=" & Session("_LANG") & " AND _LE_FieldID = " & LANG_ELEM_FIELD_NAME.Name)
                If rowLanguageContents.Length > 0 Then RaiseEvent ProductUpdated(CStr(rowLanguageContents(0)("_LE_Value")))
                RaiseEvent ProductSaved()
            Case DML_OPERATION.INSERT
                If Not ProductsBLL._AddProduct( _
                                tblLanguageContents, sbdParentsList.ToString, intProductID, blnLive, numFeatured, _
                                 strOrderVersionsBy, chrVersionsSortDirection, chrReviews, chrVersionDisplayType, numSupplier, chrType, numCustomerGroup, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                RefreshNewestProductsCache()
                If lbxProductCategories.Items.Count >= 1 Then
                    If _GetCategoryID() <> 0 Then
                        Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & intProductID & "&CategoryID=" & _GetCategoryID() & "&strParent=" & _GetParentCategory())
                    Else
                        Try
                            Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & intProductID & "&CategoryID=" & lbxProductCategories.Items(0).Value & "&strParent=" & CategoriesBLL._GetParentsByID(Session("_lang"), lbxProductCategories.Items(0).Value).Rows(0)("ParentID").ToString())
                        Catch ex As Exception
                            Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & intProductID & "&CategoryID=" & lbxProductCategories.Items(0).Value)
                        End Try
                    End If
                Else
                    Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=" & intProductID)
                End If
        End Select
        RefreshFeaturedProductsCache()

    End Sub

    ''' <summary>
    ''' if the delete is confirmed, "Yes" is chosen
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If ProductsBLL._DeleteProduct(_GetProductID(), strMessage) Then
            RefreshFeaturedProductsCache()
            If GetKartConfig("backend.files.delete.cleanup ") = "y" Then KartrisDBBLL.DeleteNotNeededFiles()
            Response.Redirect("~/Admin/_Category.aspx?CategoryID=" & _GetParentCategory())
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub

    ''' <summary>
    ''' handles the save button being clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click

        If _GetProductID() = 0 Then  '' on new
            SaveProduct(DML_OPERATION.INSERT)
        Else                        '' on update
            SaveProduct(DML_OPERATION.UPDATE)
        End If

    End Sub

    ''' <summary>
    ''' handles the cancel button being clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        If _GetProductID() = 0 Then  '' on new
            Response.Redirect("~/Admin/_Category.aspx?CategoryId=" & _GetParentCategory())
        Else                        '' on update
            ResetChanges()
        End If
    End Sub

    ''' <summary>
    ''' handles the delete linkbutton being clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", _
                                        ProductsBLL._GetNameByProductID(_GetProductID(), Session("_LANG")))
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Protected Sub ddlCustomerGroup_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCustomerGroup.SelectedIndexChanged
        If ddlCustomerGroup.SelectedValue <> 0 Then
            txtFeaturedLevel.Text = 0
            txtFeaturedLevel.Enabled = False
        Else
            txtFeaturedLevel.Enabled = True
        End If
    End Sub
End Class
