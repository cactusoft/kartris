'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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
Imports CkartrisDataManipulation
Imports CkartrisImages

Partial Class Admin_ModifyProduct
    Inherits _PageBaseClass
    'Dim sw As Stopwatch = New Stopwatch

    Private _ReviewsLoaded As Boolean = False
    Private _VersionsLoaded As Boolean = False
    Private _AttributesLoaded As Boolean = False
    Private _OptionsLoaded As Boolean = False
    Private _RelatedProductsLoaded As Boolean = False
    Private _ProductLoaded As Boolean = False
    Private _ConfigLoaded As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "BackMenu_Products") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
        _UC_ObjectConfig.ItemID = _GetProductID()
        If Not Page.IsPostBack Then
            litProductID.Text = _GetProductID()

            If _GetProductID() = 0 Then
                PrepareNewProduct()
            Else
                PrepareExistingProduct()
            End If

            'Highlights the first tab when page first loads
            Dim strTab As String = Request.QueryString("strTab")
            If strTab IsNot Nothing Then strTab = strTab.ToLower

            Select Case strTab
                Case "images"
                    If _GetProductID() = 0 Then Exit Select
                    lnkImages_Click()
                    _UC_Uploader.ImageType = IMAGE_TYPE.enum_ProductImage
                    _UC_Uploader.ItemID = _GetProductID()
                    _UC_Uploader.LoadImages()
                Case "media"
                    If _GetProductID() = 0 Then Exit Select
                    lnkMedia_Click()
                    _UC_EditMedia.ParentType = "p"
                    _UC_EditMedia.ParentID = _GetProductID()
                    _UC_EditMedia.LoadMedia()
                Case "attributes"
                    If _GetProductID() = 0 Then Exit Select
                    lnkAttributes_Click()

                Case "reviews"
                    If _GetProductID() = 0 Then Exit Select
                    lnkReviews_Click()

                Case "relatedproducts"
                    If _GetProductID() = 0 Then Exit Select
                    lnkRelatedProducts_Click()

                Case "versions"
                    If _GetProductID() = 0 Then Exit Select
                    lnkProductVersions_Click()

                Case "options"
                    If _GetProductID() = 0 Then Exit Select
                    lnkOptions_Click()
                Case "config"
                    If _GetProductID() = 0 Then Exit Select
                    lnkConfig_Click()
                Case Else
                    Session("_tab") = "products"

                    mvwEditProduct.ActiveViewIndex = 0
                    HighLightTab()
            End Select
        Else
            If _GetProductID() <> 0 AndAlso Request.QueryString("strTab") = "images" Then
                _UC_Uploader.ImageType = IMAGE_TYPE.enum_ProductImage
                _UC_Uploader.ItemID = _GetProductID()
                _UC_Uploader.LoadImages()
            End If
        End If

        'Need this for all tabs in order to decide whether to show
        'options tab or not
        _UC_EditProduct.ReloadProduct()

        'Does this need an options link?
        CheckToShowOptionLink()

        'Prepare the hyperlinks on tabs
        PrepareTabHyperlinks()

        'Hide breadcrumbtrail if no hierarchy info
        CheckToHideBreadCrumbTrail()
    End Sub

    Sub CheckToHideBreadCrumbTrail()
        If Request.QueryString("strParent") = "" Then
            phdBreadCrumbTrail.Visible = False
        End If
        If Request.QueryString("CategoryID") = "0" Then
            phdBreadCrumbTrail.Visible = False
        End If
    End Sub

    Sub PrepareTabHyperlinks()
        Dim intP_ID As Long = 0
        Try
            intP_ID = litProductID.Text
        Catch ex As Exception
            '
        End Try
        Dim intCAT_ID As Long = 0
        Try
            intCAT_ID = Request.QueryString("CategoryID")
        Catch ex As Exception
            '
        End Try
        Dim numSiteID As Integer = 0
        Try
            numSiteID = Request.QueryString("SiteID")
        Catch ex As Exception
            '
        End Try
        Dim strParent As String = Request.QueryString("strParent")

        lnkMainInfo.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent
        lnkImages.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=images"
        lnkMedia.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=media"
        lnkAttributes.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=attributes"
        lnkReviews.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=reviews"
        lnkRelatedProducts.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=relatedproducts"
        lnkProductVersions.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=versions"
        lnkOptions.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=options"
        lnkObjectConfig.NavigateUrl = "_ModifyProduct.aspx?ProductID=" & intP_ID & "&SiteID=" & numSiteID & "&CategoryID=" & intCAT_ID & "&strParent=" & strParent & "&strTab=config"
    End Sub

    Sub PrepareNewProduct()
        litProductName.Text = GetGlobalResourceObject("_Product", "PageTitle_NewProduct")
        pnlTabStrip.Visible = False
        _UC_ProductIndicator.Visible = False

        Page.Title = GetGlobalResourceObject("_Product", "PageTitle_NewProduct") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

    End Sub

    Sub PrepareExistingProduct()
        Dim objProductsBLL As New ProductsBLL
        litProductName.Text = objProductsBLL._GetNameByProductID(_GetProductID(), Session("_LANG"))
        pnlTabStrip.Visible = True
        _UC_ProductIndicator.CheckProductStatus()

        Page.Title = litProductName.Text & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

    End Sub

    Sub CheckToShowOptionLink()
        Dim chrProductType As Char = Nothing
        Dim objProductsBLL As New ProductsBLL
        chrProductType = objProductsBLL._GetProductType_s(_GetProductID())
        If chrProductType <> "o" Then
            lnkOptions.Visible = False
        Else
            lnkOptions.Visible = True
        End If
    End Sub

    Protected Sub _UC_ProductOptionGroups_VersionChanged() Handles _UC_ProductOptionGroups.VersionChanged
        CheckProductOptions()
        ShowMasterUpdateMessage()
    End Sub

    Protected Sub _UC_ProductOptionGroups_AllOptionsDeleted() Handles _UC_ProductOptionGroups.AllOptionsDeleted
        RefreshProductInformation()
        ShowMasterUpdateMessage()
    End Sub

    Protected Sub _UC_EditProduct_ProductSaved() Handles _UC_EditProduct.ProductSaved
        Dim objProductsBLL As New ProductsBLL
        litProductName.Text = objProductsBLL._GetNameByProductID(_GetProductID(), Session("_LANG"))
        _UC_EditProduct.LoadProductInfo()
        ShowMasterUpdateMessage()
    End Sub

    Protected Sub _UC_VersionView_VersionsChanged() Handles _UC_VersionView.VersionsChanged
        _UC_EditProduct.CheckProductType()
        ShowMasterUpdateMessage()
    End Sub

    Sub RefreshProductInformation()
        PrepareExistingProduct()
        _UC_EditProduct.LoadProductInfo()
    End Sub

    Protected Sub _UC_EditProduct_CategoryNotExist() Handles _UC_EditProduct.ProductNotExist
        RedirectToNewProduct()
    End Sub

    Sub RedirectToNewProduct()
        Response.Redirect("~/Admin/_ModifyProduct.aspx?ProductID=0")
    End Sub

    Sub CheckProductOptions()
        Dim objProductsBLL As New ProductsBLL
        If objProductsBLL._GetProductType_s(_GetProductID()) = "o" Then
            _UC_ProductOptionGroups.CreateProductOptionGroups()

            If VersionsBLL._GetNoOfVersionsByProductID(_GetProductID()) = 0 Then
                If mvwEditProduct.ActiveViewIndex = 5 Then mvwEditProduct.ActiveViewIndex = 0
            End If
            lnkOptions.Visible = True
            updMain.Update()
        Else
            lnkOptions.Visible = False
            If Not Page.IsPostBack Then
                If Request.Url.AbsoluteUri.ToLower.Contains("&strtab=options") Then
                    Response.Redirect(Request.Url.AbsoluteUri.ToLower.Replace("&strtab=options", ""))
                ElseIf Request.Url.AbsoluteUri.ToLower.Contains("strtab=options") Then
                    Response.Redirect(Request.Url.AbsoluteUri.ToLower.Replace("strtab=options", ""))
                End If
            End If
        End If
    End Sub

    Sub HighLightTab()

        lnkMainInfo.CssClass = ""
        lnkOptions.CssClass = ""
        lnkImages.CssClass = ""
        lnkMedia.CssClass = ""
        lnkAttributes.CssClass = ""
        lnkReviews.CssClass = ""
        lnkRelatedProducts.CssClass = ""
        lnkProductVersions.CssClass = ""
        lnkObjectConfig.CssClass = ""

        'rewritten the multiple 'if' statements to a single select case block
        Select Case mvwEditProduct.ActiveViewIndex
            Case 0
                lnkMainInfo.CssClass = "active"
            Case 1
                lnkImages.CssClass = "active"
            Case 2
                lnkMedia.CssClass = "active"
            Case 3
                lnkAttributes.CssClass = "active"
            Case 4
                lnkReviews.CssClass = "active"
            Case 5
                lnkRelatedProducts.CssClass = "active"
            Case 6
                lnkProductVersions.CssClass = "active"
            Case 7
                lnkOptions.CssClass = "active"
            Case 8
                lnkObjectConfig.CssClass = "active"
        End Select
    End Sub

    Sub lnkMainInfo_Click()
        Session("_tab") = "products"
        If Not _ProductLoaded Then _ProductLoaded = True : _UC_EditProduct.ReloadProduct()
        mvwEditProduct.ActiveViewIndex = 0
        HighLightTab()
    End Sub

    Sub lnkImages_Click()
        Session("_tab") = "images"
        _UC_Uploader.ImageType = IMAGE_TYPE.enum_ProductImage
        _UC_Uploader.ItemID = _GetProductID()
        _UC_Uploader.LoadImages()
        mvwEditProduct.ActiveViewIndex = 1
        HighLightTab()
    End Sub

    Sub lnkMedia_Click()
        Session("_tab") = "media"
        _UC_EditMedia.ParentType = "p"
        _UC_EditMedia.ParentID = _GetProductID()
        _UC_EditMedia.LoadMedia()
        mvwEditProduct.ActiveViewIndex = 2
        HighLightTab()
    End Sub

    Sub lnkAttributes_Click()
        Session("_tab") = "attributes"
        If Not _AttributesLoaded Then _AttributesLoaded = True : _UC_ProductAttributes.ShowProductAttributes()
        mvwEditProduct.ActiveViewIndex = 3
        HighLightTab()
    End Sub

    Sub lnkReviews_Click()
        Session("_tab") = "reviews"
        If Not _ReviewsLoaded Then _ReviewsLoaded = True : _UC_ProductReview.LoadProductReviews()
        mvwEditProduct.ActiveViewIndex = 4
        HighLightTab()
    End Sub

    Sub lnkRelatedProducts_Click()
        Session("_tab") = "relatedproducts"
        If Not _RelatedProductsLoaded Then _RelatedProductsLoaded = True : _UC_RelatedProducts.LoadRelatedProducts()
        mvwEditProduct.ActiveViewIndex = 5
        HighLightTab()
    End Sub

    Sub lnkProductVersions_Click()
        Session("_tab") = "versions"
        If Not _VersionsLoaded Then _VersionsLoaded = True : _UC_VersionView.ShowProductVersions()
        mvwEditProduct.ActiveViewIndex = 6
        HighLightTab()
    End Sub

    Sub lnkOptions_Click()
        Session("_tab") = "options"
        If Not _OptionsLoaded Then _OptionsLoaded = True : CheckProductOptions()
        mvwEditProduct.ActiveViewIndex = 7
        HighLightTab()
    End Sub

    Sub lnkConfig_Click()
        Session("_tab") = "config"
        If Not _ConfigLoaded Then _ConfigLoaded = True : _UC_ObjectConfig.LoadObjectConfig()
        mvwEditProduct.ActiveViewIndex = 8
        HighLightTab()
    End Sub

    Protected Sub ctrl_NeedCategoryRefresh() Handles _UC_EditMedia.NeedCategoryRefresh,
        _UC_Uploader.NeedCategoryRefresh, _UC_VersionView.NeedCategoryRefresh, _UC_ProductAttributes.NeedCategoryRefresh
        CType(Me.Master, Skins_Admin_Template).LoadCategoryMenu()
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_ProductAttributes.ShowMasterUpdate, _
                                                    _UC_ProductOptionGroups.ShowMasterUpdate, _
                                                    _UC_RelatedProducts.ShowMasterUpdate, _
                                                    _UC_ProductReview.ShowMasterUpdate, _
                                                    _UC_EditMedia.ShowMasterUpdate, _
                                                    _UC_ObjectConfig.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        _UC_ProductIndicator.CheckProductStatus()
        updMain.Update()
    End Sub

    Protected Sub ProductUpdated(ByVal strNewProductName As String) Handles _UC_EditProduct.ProductUpdated
        '' It will redirect only if the name of the product is changed.
        If litProductName.Text <> strNewProductName Then Response.Redirect(Request.Url.AbsoluteUri)
        _UC_EditProduct_ProductSaved()
    End Sub

End Class
