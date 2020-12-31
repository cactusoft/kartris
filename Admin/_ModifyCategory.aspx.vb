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
Imports CkartrisImages
Imports CkartrisDataManipulation

Partial Class Admin_ModifyCategory
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Category", "BackMenu_Categories") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        litContentTextSubCatsProducts.Text = HttpUtility.HtmlEncode(GetGlobalResourceObject("_Kartris", "ContentText_SubCatsProducts"))

        litCategoryID.Text = _GetCategoryID()
        litSiteID.Text = _GetSiteID()

        'v3 mod
        'Object config now available for categories
        _UC_ObjectConfig.ItemID = _GetCategoryID()
        If Not IsPostBack Then
            _UC_ObjectConfig.LoadObjectConfig()
        End If

        If _GetCategoryID() = 0 Then
            PrepareNewCategory()
        Else
            PrepareExistingCategory()
        End If

        tabXmlFilters.Visible = PowerpackBLL._IsFiltersEnabled()

        _UC_Uploader.OneItemOnly = True
        _UC_Uploader.ImageType = IMAGE_TYPE.enum_CategoryImage
        _UC_Uploader.ItemID = _GetCategoryID()
        _UC_Uploader.LoadImages()
    End Sub

    Sub PrepareNewCategory()
        litCategoryName.Text = GetGlobalResourceObject("_Category", "PageTitle_NewCategory")
        For Each t As AjaxControlToolkit.TabPanel In tabContainerProduct.Tabs
            If t.ID <> "tabMainInfo" Then
                t.Enabled = False : t.Visible = False
            End If
        Next
        Page.Title = GetGlobalResourceObject("_Category", "PageTitle_NewCategory") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Sub PrepareExistingCategory()
        litCategoryName.Text = CategoriesBLL._GetNameByCategoryID(_GetCategoryID(), Session("_LANG"))
        For Each t As AjaxControlToolkit.TabPanel In tabContainerProduct.Tabs
            t.Enabled = True : t.Visible = True
        Next
        _UC_CategoryIndicator.CheckCategoryStatus()
        Page.Title = litCategoryName.Text & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub _UC_EditCategory_CategoryNotExist() Handles _UC_EditCategory.CategoryNotExist
        RedirectToNewCategory()
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_EditCategory.ShowMasterUpdate,
                                                    _UC_CategoryView.ShowMasterUpdate,
                                                    _UC_CategoryFilter.ShowMasterUpdate,
                                                    _UC_ObjectConfig.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub CategoryUpdated(ByVal strNewCategoryName As String) Handles _UC_EditCategory.CategoryUpdated
        '' It will redirect only if the name of the category is changed.
        If litCategoryName.Text <> strNewCategoryName Then Response.Redirect(Request.Url.AbsoluteUri)
        ShowMasterUpdateMessage()
        _UC_CategoryView.LoadSubCategories()
        _UC_CategoryView.LoadProducts()
        updRelatedData.Update()
        'Check the category status again, it might
        'now might be visible or invisible on front
        'end due to changes made.
        _UC_CategoryIndicator.CheckCategoryStatus()
    End Sub

    Sub RedirectToNewCategory()
        Response.Redirect("~/Admin/_ModifyCategory.aspx?CategoryID=0&SiteID" = litSiteID.Text)
    End Sub

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        If Session("tab") = "images" Then
            tabContainerProduct.ActiveTab = tabImages
            Session("tab") = ""
        End If

    End Sub

    Protected Sub _UC_Uploader_NeedCategoryRefresh() Handles _UC_Uploader.NeedCategoryRefresh
        CType(Me.Master, Skins_Admin_Template).LoadCategoryMenu()
    End Sub
End Class
