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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisImages
Imports KartSettingsManager

Partial Class UserControls_Back_EditCategory
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' raised when the category does not exist
    ''' </summary>
    ''' <remarks></remarks>
    Public Event CategoryNotExist()
    Public Event ShowMasterUpdate()
    Public Event CategoryUpdated(ByVal strNewName As String)

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        '' validation group for the save button
        lnkBtnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.Categories
        If ddlCustomerGroup.Items.Count <= 1 Then
            Dim drwCGs As DataRow() = GetCustomerGroupsFromCache.Select("CG_Live = 1 AND LANG_ID=" & Session("_LANG"))
            ddlCustomerGroup.DataTextField = "CG_Name"
            ddlCustomerGroup.DataValueField = "CG_ID"
            ddlCustomerGroup.DataSource = drwCGs
            ddlCustomerGroup.DataBind()
        End If
        If _GetCategoryID() = 0 Then '' Creating New Category
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Categories, True)
            If Not Page.IsPostBack Then AddParentCategory()
            lnkBtnDelete.Visible = False '' delete button invisible while creating new category
            lnkPreview.Visible = False
        Else                        '' Updating an existing Category
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Categories, False, _GetCategoryID())
            If Not Page.IsPostBack Then LoadCategoryInfo()
            lnkBtnDelete.Visible = True  '' delete button shown for existing category
            lnkPreview.NavigateUrl = "~/Category.aspx?CategoryID=" & _GetCategoryID()
            lnkPreview.Visible = True
        End If

    End Sub

    ''' <summary>
    ''' reads the parent category from the query string and add it to the parents' list
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub AddParentCategory()

        Dim numParentCategoryID As Integer = _GetParentCategory()

        lbxParentCategories.Items.Clear()

        If numParentCategoryID <> 0 Then '' there is a value for the strParent variable
            If lbxParentCategories.Items.FindByValue(CStr(numParentCategoryID)) Is Nothing Then
                lbxParentCategories.Items.Add( _
                    New ListItem(CategoriesBLL._GetNameByCategoryID(numParentCategoryID, Session("_LANG")), CStr(numParentCategoryID)))
                lbxParentCategories.SelectedIndex = lbxParentCategories.Items.Count - 1
            End If
        End If

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
                If (Not strCategoryName Is Nothing) AndAlso numCategoryID <> _GetCategoryID() Then
                    If lbxParentCategories.Items.FindByValue(CStr(numCategoryID)) Is Nothing Then
                        lbxParentCategories.Items.Add(New ListItem(strCategoryName, CStr(numCategoryID)))
                        lbxParentCategories.SelectedIndex = lbxParentCategories.Items.Count - 1
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
    Protected Sub lnkBtnRemoveParentCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnRemoveParentCategory.Click
        Dim selectedIndx As Integer = lbxParentCategories.SelectedIndex
        If selectedIndx >= 0 Then
            lbxParentCategories.Items.RemoveAt(selectedIndx)
            If lbxParentCategories.Items.Count >= selectedIndx Then
                lbxParentCategories.SelectedIndex = selectedIndx - 1
            Else
                If lbxParentCategories.Items.Count <> 0 Then
                    lbxParentCategories.SelectedIndex = lbxParentCategories.Items.Count - 1
                End If
            End If
        End If
    End Sub

    ''' <summary>
    ''' will read the info. of the category and show them in the page
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadCategoryInfo()
        Dim tblCategory As New DataTable
        tblCategory = CategoriesBLL._GetByID(_GetCategoryID())

        If tblCategory.Rows.Count = 0 Then RaiseEvent CategoryNotExist() : Exit Sub '' ERROR .. no category with this ID

        '' Load Category Main Info.
        Dim drwCategory As DataRow = tblCategory.Rows(0)
        chkLive.Checked = CBool(drwCategory("CAT_Live"))
        ddlProductDisplay.SelectedValue = CStr(FixNullFromDB(drwCategory("CAT_ProductDisplayType")))
        ddlSubCategoryDisplay.SelectedValue = CStr(FixNullFromDB(drwCategory("CAT_SubCatDisplayType")))
        ddlSortProductBy.SelectedValue = CStr(FixNullFromDB(drwCategory("CAT_OrderProductsBy")))
        ddlProductsSortDirection.SelectedValue = CChar(FixNullFromDB(drwCategory("CAT_ProductsSortDirection")))
        ddlCustomerGroup.SelectedValue = CStr(FixNullFromDB(drwCategory("CAT_CustomerGroupID")))
        ddlSortCategoryBy.SelectedValue = CStr(FixNullFromDB(drwCategory("CAT_OrderCategoriesBy")))
        ddlCategoriesSortDirection.SelectedValue = CChar(FixNullFromDB(drwCategory("CAT_CategoriesSortDirection")))

        '' Load Category Parents into the 'Parent List'
        Dim tblParents As New DataTable
        tblParents = CategoriesBLL._GetParentsByID(Session("_LANG"), _GetCategoryID())
        lbxParentCategories.Items.Clear() '' should be cleared to read them again
        For Each rowParent In tblParents.Rows
            Dim itm As New ListItem
            itm.Value = CStr(FixNullFromDB(rowParent("ParentID")))
            itm.Text = CStr(FixNullFromDB(rowParent("ParentName")))
            lbxParentCategories.Items.Add(itm)
            litParentCategories_Hidden.Text &= itm.Value & ","
        Next
    End Sub

    ''' <summary>
    ''' saving the changes 
    '''  - (update for the existing category)
    '''  - (insert for the new category)
    '''  Steps:
    '''  1. read the Language Elements of the category to save them.
    '''  2. read the parents' cat. to be saved in the category hierarchy.
    '''  3. read the main category info.
    '''  4. save the changes (update/insert)
    '''  5. refresh the sitemap to reflect the changes to the menu
    '''  6. redirect the page with the new changes
    ''' </summary>
    ''' <param name="enumOperation"></param>
    ''' <remarks></remarks>
    Private Sub SaveCategory(ByVal enumOperation As DML_OPERATION)

        Dim tblLanguageContents As New DataTable()
        Dim sbdParentsList As New StringBuilder("")
        Dim blnLive As Boolean, chrProductDisplay As Char, chrSubCategoryDisplay As Char
        Dim strParentList As String, strSortProductBy As String, numCustomerGroup As Integer
        Dim chrProductsSortDirection As Char
        Dim strSortSubcatBy As String
        Dim chrSubcatSortDirection As Char

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 1. Language Contents

        tblLanguageContents = _UC_LangContainer.ReadContent()

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 2. Parents List
        For Each itm As ListItem In lbxParentCategories.Items
            sbdParentsList.Append(itm.Value)
            sbdParentsList.Append(",")
        Next
        If sbdParentsList.ToString = "" Then
            sbdParentsList.Length = 0 : sbdParentsList.Capacity = 0
            'sbdParentsList.Append("0")
        Else
            Dim strNewParents As String = sbdParentsList.ToString
            If strNewParents.EndsWith(",") Then strNewParents = strNewParents.TrimEnd(",")
            Dim strOriginalParents As String = litParentCategories_Hidden.Text
            If strOriginalParents.EndsWith(",") Then strOriginalParents = strOriginalParents.TrimEnd(",")

            Dim arrNewParents() As String = IIf(String.IsNullOrEmpty(strNewParents), Nothing, Split(strNewParents, ","))
            Dim arrOriginalParents() As String = IIf(String.IsNullOrEmpty(strOriginalParents), Nothing, Split(strOriginalParents, ","))

            'Now compare arrays
            If arrOriginalParents IsNot Nothing AndAlso arrNewParents IsNot Nothing AndAlso arrNewParents.Length = arrOriginalParents.Length Then
                Dim blnSameList As Boolean = True
                Array.Sort(arrNewParents)
                Array.Sort(arrOriginalParents)
                For x As Integer = 0 To arrNewParents.Length - 1
                    If arrNewParents(x) <> arrOriginalParents(x) Then
                        blnSameList = False
                        Exit For
                    End If
                    If Not blnSameList Then Exit For
                Next
                If blnSameList Then sbdParentsList = Nothing
            End If
        End If

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 3. Category Main Info.
        blnLive = chkLive.Checked
        chrProductDisplay = CChar(ddlProductDisplay.SelectedValue())
        chrSubCategoryDisplay = CChar(ddlSubCategoryDisplay.SelectedValue())
        strSortProductBy = CStr(ddlSortProductBy.SelectedValue())
        chrProductsSortDirection = CChar(ddlProductsSortDirection.SelectedValue())
        numCustomerGroup = CInt(ddlCustomerGroup.SelectedValue())
        strSortSubcatBy = CStr(ddlSortCategoryBy.SelectedValue())
        chrSubcatSortDirection = CChar(ddlCategoriesSortDirection.SelectedValue())
        If sbdParentsList Is Nothing Then
            strParentList = Nothing
        Else
            strParentList = sbdParentsList.ToString
        End If
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        Dim strMessage As String = ""
        Dim intCategoryID As Integer = _GetCategoryID()
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not CategoriesBLL._UpdateCategory( _
                                tblLanguageContents, strParentList, intCategoryID, blnLive, _
                                 chrProductDisplay, chrSubCategoryDisplay, strSortProductBy, _
                                 chrProductsSortDirection, strSortSubcatBy, chrSubcatSortDirection, numCustomerGroup, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                RefreshSiteMap()
                '' To check the name of the category, if its changed will cause redirect, otherwise it will show the update message
                Dim drwLanguageContent As DataRow() = tblLanguageContents.Select("_LE_LanguageID=" & Session("_LANG") & " AND _LE_FieldID = " & LANG_ELEM_FIELD_NAME.Name)
                If drwLanguageContent.Length > 0 Then RaiseEvent CategoryUpdated(CStr(drwLanguageContent(0)("_LE_Value")))
                RaiseEvent ShowMasterUpdate()
            Case DML_OPERATION.INSERT
                If Not CategoriesBLL._AddCategory( _
                    tblLanguageContents, strParentList, intCategoryID, blnLive, _
                    chrProductDisplay, chrSubCategoryDisplay, strSortProductBy, _
                    chrProductsSortDirection, strSortSubcatBy, chrSubcatSortDirection, numCustomerGroup, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Exit Sub
                End If
                RefreshSiteMap()
                Select Case lbxParentCategories.Items.Count
                    Case 0
                        Response.Redirect("~/Admin/_ModifyCategory.aspx?CategoryID=" & intCategoryID & "&strParent=0")
                    Case 1
                        Response.Redirect("~/Admin/_ModifyCategory.aspx?CategoryID=" & intCategoryID & "&strParent=" & lbxParentCategories.Items(0).Value)
                    Case Else
                        Response.Redirect("~/Admin/_ModifyCategory.aspx?CategoryID=" & intCategoryID)
                End Select
        End Select

    End Sub

    ''' <summary>
    ''' used to reset the original info. from the db
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub ResetChanges()
        '' 1. reset the controls
        '' 2. reset the language elements ... (clear the controls)
        '' 3. reads the language elements for the current category
        '' 4. loads the category info. from db

        chkLive.Checked = False
        ddlProductDisplay.SelectedValue = 0
        ddlSubCategoryDisplay.SelectedValue = 0
        ddlSortProductBy.SelectedValue = 0
        ddlCustomerGroup.SelectedValue = 0

        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Categories, True)
        _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Categories, False, _GetCategoryID())

        updMain.Update()
        LoadCategoryInfo()

    End Sub

    ''' <summary>
    ''' if the delete is confirmed "Yes is chosen"
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If CategoriesBLL._GetTotalSubCategories_s(_GetCategoryID()) = 0 Then
            '' If there is no subcategories, then use the normal delete (transaction is enabled)
            If CategoriesBLL._DeleteCategory(_GetCategoryID(), strMessage) Then
                RefreshSiteMap()
                'RemoveImages(IMAGE_TYPE.enum_CategoryImage, _GetCategoryID())
                If GetKartConfig("backend.files.delete.cleanup") = "y" Then KartrisDBBLL.DeleteNotNeededFiles()
                Response.Redirect("~/Admin/_Category.aspx?CategoryID=" & _GetParentCategory())
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            End If
        Else
            '' If there are subcategories, then use the delete cascade (transaction is disabled)
            If CategoriesBLL._DeleteCategoryCascade(_GetCategoryID(), strMessage) Then
                RefreshSiteMap()
                If GetKartConfig("backend.files.delete.cleanup") = "y" Then KartrisDBBLL.DeleteNotNeededFiles()
                Response.Redirect("~/Admin/_Category.aspx?CategoryID=" & _GetParentCategory())
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            End If
        End If
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        If _GetCategoryID() = 0 Then '' on new
            SaveCategory(DML_OPERATION.INSERT)
        Else                        '' on update
            SaveCategory(DML_OPERATION.UPDATE)
        End If
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        If _GetCategoryID() = 0 Then '' on new 
            Response.Redirect("~/Admin/_Category.aspx?CategoryID=" & _GetParentCategory())
        Else                        '' on update
            ResetChanges()
        End If
    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        Dim strConfirmationText As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", _
                                            CategoriesBLL._GetNameByCategoryID(_GetCategoryID(), Session("_LANG")))
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strConfirmationText)
        
    End Sub
End Class
