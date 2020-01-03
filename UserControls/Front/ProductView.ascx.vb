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
Imports CkartrisDataManipulation
Imports CkartrisImages

''' <summary>
''' Used in the Products.aspx, it loads all the sections (as UCs) that are related to the Current Product.
'''   Attributes, Versions, Promotions, Reviews, and CarryOnShopping.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class ProductView
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer
    Private _LanguageID As Short
    Private _ProductName As String
    Private _DisplayType As Char
    Private _ReviewsEnabled As Char
    Private _IsProductExit As Boolean

    Public ReadOnly Property ProductID() As Integer
        Get
            Return _ProductID
        End Get
    End Property

    Public ReadOnly Property LanguageID() As Short
        Get
            Return _LanguageID
        End Get
    End Property

    Public ReadOnly Property DisplayType() As Char
        Get
            Return _DisplayType
        End Get
    End Property

    Public ReadOnly Property IsProductExist() As Boolean
        Get
            Return _IsProductExit
        End Get
    End Property

    Public ReadOnly Property ProductName() As String
        Get
            Return _ProductName
        End Get
    End Property

    ''' <summary>
    ''' Loads/Shows the Product Info.
    ''' </summary>
    ''' <param name="pProductID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadProduct(ByVal pProductID As Integer, ByVal pLanguageID As Short)
        _ProductID = pProductID
        _LanguageID = pLanguageID

        'Gets the details of the current product
        Dim tblProducts As New DataTable
        tblProducts = ProductsBLL.GetProductDetailsByID(_ProductID, _LanguageID)

        'If there is no products returned, then go to the categories page.
        If tblProducts.Rows.Count = 0 Then _IsProductExit = False : Exit Sub

        'Checking the customer group of the category
        Dim numCGroupID As Short = 0, numParentGroup As Short = 0, numCurrentGroup As Short = 0
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            numCGroupID = CShort(DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID)
        End If

        numCurrentGroup = FixNullFromDB(tblProducts.Rows(0)("P_CustomerGroupID"))
        Try
            Dim node As SiteMapNode = SiteMap.CurrentNode
            numParentGroup = node.ParentNode("CG_ID")
            If numParentGroup <> 0 AndAlso numParentGroup <> numCGroupID Then
                _IsProductExit = False : Exit Sub
            ElseIf numCurrentGroup <> 0 AndAlso numCurrentGroup <> numCGroupID Then
                _IsProductExit = False : Exit Sub
            End If
        Catch ex As Exception
            If numCurrentGroup <> 0 AndAlso numCurrentGroup <> numCGroupID Then
                _IsProductExit = False : Exit Sub
            End If
        End Try

        _IsProductExit = True

        _ProductName = FixNullFromDB(tblProducts.Rows(0)("P_Name"))
        Dim strStrapline As String = FixNullFromDB(tblProducts.Rows(0)("P_Strapline"))
        _DisplayType = FixNullFromDB(tblProducts.Rows(0)("P_VersionDisplayType"))

        'Checking if the reviews are enabled for the Product.
        _ReviewsEnabled = IIf(tblProducts.Rows(0)("P_Reviews") Is DBNull.Value, "n", tblProducts.Rows(0)("P_Reviews"))

        'Product's Page Title
        Dim strPageTitle As String = FixNullFromDB(tblProducts.Rows(0)("P_PageTitle"))
        Page.Title = IIf(strPageTitle = "", _
                         _ProductName & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname")), _
                         strPageTitle & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname")))

        tblProducts.Rows(0)("MinPrice") = CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), FixNullFromDB(tblProducts.Rows(0)("MinPrice")))

        'Set H1 tag
        litProductName.Text = Server.HtmlEncode(_ProductName)
        litProductStrapLine.Text = Server.HtmlEncode(strStrapline)

        'Bind the DataTable to the FormView that is used to view the Product's Info.
        fvwProduct.DataSource = tblProducts
        fvwProduct.DataBind()

        Dim blnUseCombinationPrice As Boolean = IIf(ObjectConfigBLL.GetValue("K:product.usecombinationprice", ProductID) = "1", True, False) And ProductsBLL._NumberOfCombinations(ProductID) > 0

        'Create the image view 
        UC_ImageView.CreateImageViewer(IMAGE_TYPE.enum_ProductImage, _
            _ProductID, _
            KartSettingsManager.GetKartConfig("frontend.display.images.normal.height"), _
            KartSettingsManager.GetKartConfig("frontend.display.images.normal.width"), _
            "", _
            "", , _ProductName)

        'We have two types of largeview links, depending on the config settings.
        'One type is an AJAX popup, with the large image resized to fit.
        'The other is a new page, with the large image full size.
        If KartSettingsManager.GetKartConfig("frontend.display.images.large.linktype") = "n" Then
            
        Else
            'If tblProducts.Rows(0)("P_Desc").ToString.Contains("<overridelargeimagelinktype>") Then
            If CBool(ObjectConfigBLL.GetValue("K:product.showlargeimageinline", pProductID)) Then
                'Override triggered - for MTMC large images
                UC_ImageView.Visible = False

                'Need to override the Foundation column widths
                'To make sure both full 12 width, so image
                'stacks over text
                litImageColumnClasses.Text = "imagecolumn small-12 columns"
                litTextColumnClasses.Text = "textcolumn small-12 columns"

                'Set full size image visible
                UC_ImageView2.CreateImageViewer(IMAGE_TYPE.enum_ProductImage,
                    _ProductID,
                    0,
                    0,
                    "",
                    "rrr")
                UC_ImageView2.Visible = True
            End If

        End If

        UC_MediaGallery.ParentID = _ProductID

        '-------------------------------------
        'MEDIA POPUP
        '-------------------------------------
        'We set width and height later with
        'javascript, as popup size will vary
        'depending on the media type

        'UC_PopUpMedia.SetTitle = _ProductName 'blank this out to match Foundation popup for large images which has no title
        UC_PopUpMedia.SetMediaPath = _ProductID

        UC_PopUpMedia.PreLoadPopup()

    End Sub

    Protected Sub fvwProduct_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles fvwProduct.DataBound

        'We will set number of visible tabs and
        'keep track. This is only required for
        'mobile display, so we can have numbered
        'tabs instead of named ones to keep the
        'page width down.
        Dim numVisibleTabs As Integer = 1

        'Handle compare link
        SetCompareLink()

        'Handle price display
        Dim litPriceTemp As Literal = CType(fvwProduct.FindControl("litPrice"), Literal)

        '=================================
        'Handle main tab
        '=================================
        Dim litContentTextHome As Literal = CType(tabMain.FindControl("litContentTextHome"), Literal)

        '=================================
        'Handle attributes tab
        '=================================
        UC_ProductAttributes.LoadProductAttributes(_ProductID, LanguageID)

        'If no attributes, then hide tab
        If UC_ProductAttributes.Visible = False Then
            Dim tabAttributes As AjaxControlToolkit.TabPanel = CType(tbcProduct.FindControl("tabAttributes"), AjaxControlToolkit.TabPanel) 'Finds tab panel in container
            tabAttributes.Enabled = False
            tabAttributes.Visible = False
        Else
            numVisibleTabs += 1
            Dim litContentTextAttributes As Literal = CType(tabAttributes.FindControl("litContentTextAttributes"), Literal)
        End If

        '=================================
        'Handle specs tab
        'Specs tab added in v2.9014
        '=================================
        Dim strSpecs As String = CkartrisDisplayFunctions.StripHTML(CkartrisDataManipulation.FixNullFromDB(ObjectConfigBLL.GetValue("K:product.spectable", _ProductID)))
        If Trim(strSpecs) <> "" Then
            'Great, we have specs - show tab
            numVisibleTabs += 1
            Dim litSpecsTable As Literal = CType(tabSpecs.FindControl("litSpecsTable"), Literal)
            litSpecsTable.Text = strSpecs
        Else
            'Nevermind, hide it
            Dim tabSpecs As AjaxControlToolkit.TabPanel = CType(tbcProduct.FindControl("tabSpecs"), AjaxControlToolkit.TabPanel) 'Finds tab panel in container
            tabSpecs.Enabled = False
            tabSpecs.Visible = False
        End If

        '=================================
        'Handle quantity discounts tab
        '=================================
        ' Check if Call for Price Product, will not process quantity discount
        If ObjectConfigBLL.GetValue("K:product.callforprice", _ProductID) <> 1 Then
            UC_QuantityDiscounts.LoadProductQuantityDiscounts(_ProductID, _LanguageID)
        Else
            UC_QuantityDiscounts.Visible = False
        End If

        'If no quantity discounts, then hide tab
        If UC_QuantityDiscounts.Visible = False Then
            Dim tabQuantityDiscounts As AjaxControlToolkit.TabPanel = CType(tbcProduct.FindControl("tabQuantityDiscounts"), AjaxControlToolkit.TabPanel) 'Finds tab panel in container
            tabQuantityDiscounts.Enabled = False
            tabQuantityDiscounts.Visible = False
        Else
            numVisibleTabs += 1
            Dim litContentTextViewQuantityDiscount As Literal = CType(tabQuantityDiscounts.FindControl("litContentTextViewQuantityDiscount"), Literal)
        End If

        '=================================
        'Handle reviews tab
        '=================================
        Dim tabReviews As AjaxControlToolkit.TabPanel = CType(tbcProduct.FindControl("tabReviews"), AjaxControlToolkit.TabPanel) 'Finds tab panel in container
        If KartSettingsManager.GetKartConfig("frontend.reviews.enabled") = "y" AndAlso _ReviewsEnabled <> "n" Then
            numVisibleTabs += 1
            UC_Reviews.LoadReviews(_ProductID, _LanguageID, _ProductName)
            Dim litContentTextCustomerReviews As Literal = CType(tabReviews.FindControl("litContentTextCustomerReviews"), Literal)
        Else
            tabReviews.Visible = False
            tabReviews.Enabled = False
        End If

        'Handle versions
        UC_ProductVersions.LoadProductVersions(_ProductID, _LanguageID, _DisplayType)

        'Handle promotions
        UC_Promotions.LoadProductPromotions(_ProductID, _LanguageID)
        If KartSettingsManager.GetKartConfig("frontend.promotions.enabled") = "y" Then
            UC_Promotions.Visible = True
        Else
            UC_Promotions.Visible = False
        End If

    End Sub

    Sub SetCompareLink()
        Dim tabMain As AjaxControlToolkit.TabPanel = CType(tbcProduct.FindControl("tabMain"), AjaxControlToolkit.TabPanel)
        Dim fvwProduct As FormView = CType(tabMain.FindControl("fvwProduct"), FormView)

        'If comparison is enabled, proceed, else hide link
        If LCase(KartSettingsManager.GetKartConfig("frontend.products.comparison.enabled")) <> "n" Then

            'Is this coming from comparison page?
            If Request.QueryString.ToString.ToLower.Contains("strpagehistory=compare") Then
                CType(fvwProduct.FindControl("phdCompareLink"), PlaceHolder).Visible = False
            Else
                CType(fvwProduct.FindControl("phdCompareLink"), PlaceHolder).Visible = True

                'Setting the Compare URL ...
                Dim strCompareLink As String = Request.Url.ToString.ToLower
                If Request.Url.ToString.ToLower.Contains("category.aspx") Then
                    strCompareLink = strCompareLink.Replace("category.aspx", "Compare.aspx")
                ElseIf Request.Url.ToString.ToLower.Contains("product.aspx") Then
                    strCompareLink = strCompareLink.Replace("product.aspx", "Compare.aspx")
                Else
                    strCompareLink = "~/Compare.aspx"
                End If
                If strCompareLink.Contains("?") Then
                    strCompareLink += "&action=add&id=" & _ProductID
                Else
                    strCompareLink += "?action=add&id=" & _ProductID
                End If

                CType(fvwProduct.FindControl("lnkCompare"), HyperLink).NavigateUrl = strCompareLink
            End If
        Else
            CType(fvwProduct.FindControl("phdCompareLink"), PlaceHolder).Visible = False
        End If

    End Sub

    Function ShowLineBreaks(ByVal strInput As Object) As String
        Dim strOutput As String = CStr(CkartrisDataManipulation.FixNullFromDB(strInput))
        If strOutput IsNot Nothing Then
            If InStr(strInput, "<") > 0 And InStr(strInput, ">") > 0 Then
                'Input probably contains HTML, so we want to ignore line
                'breaks for display purposes

                'Do nothing
            Else
                strOutput = Replace(strOutput, vbCrLf, "<br />" & vbCrLf)
                strOutput = Replace(strOutput, vbLf, "<br />" & vbCrLf)
            End If
        End If

        Return strOutput
    End Function

End Class
