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
Imports KartSettingsManager

''' <summary>
''' Shown in Products.aspx page.
''' Contains the following sections:
'''    1.(Related Products)    : List of the products that are related to the current product.
'''                               -> Read the data from "tblKartrisRelatedProducts"
'''    2.(Try These Categories): List of the categories that are linked with the current product.
'''                               -> Read the data from "tblKartrisProductCategoryLink"
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class CarryOnShopping
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer
    Private _LanguageID As Short

    Public ReadOnly Property ProductID() As Integer
        Get
            Return _ProductID
        End Get
    End Property

    ''' <summary>
    ''' Loads the data on the UI.
    ''' </summary>
    ''' <param name="pProductID">The ProductID of the Current Page.</param>
    ''' <param name="pLanguageID"></param>
    ''' <remarks></remarks>
    Public Sub LoadCarryOnShopping(ByVal pProductID As Integer, ByVal pLanguageID As Short)

        'Any issues, let's just skip this
        Try
            _ProductID = pProductID
            _LanguageID = pLanguageID

            '' Calls to load the list of Related Products & Linked Categories as well.
            LoadRelatedProducts()
            LoadLinkedCategories()
            LoadPeopleWhoBoughtThis()

            '' Gets the Title of CarryOnShopping's section, if one of the lists has data.
            If rptRelatedProducts.Items.Count > 0 OrElse rptLinkedCategories.Items.Count > 0 OrElse rptPeopleWhoBoughtThis.Items.Count > 0 Then
                litCarryOnShoppingHeader.Text = GetGlobalResourceObject("Products", "ContentText_CarryOnShopping")
            Else
                Me.Visible = False
            End If
        Catch ex As Exception
            'possibly db timeouts on a big, busy sites or some other cache issue,
            'but we don't want to crash the page over it
        End Try

    End Sub

    ''' <summary>
    ''' Loads the list of related products.
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadRelatedProducts()

        Dim numCGroupID As Short = 0
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            numCGroupID = CShort(DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID)
        End If

        '' Add the related products to a DataTable
        Dim tblProducts As New DataTable
        tblProducts = ProductsBLL.GetRelatedProducts(_ProductID, _LanguageID, numCGroupID)

        '' If there is no related products, then exit this section.
        If tblProducts.Rows.Count = 0 Then Exit Sub

        '' Bind the linked categories in to rptRelatedProducts, and View its container.
        phdRelatedProducts.Visible = True
        rptRelatedProducts.DataSource = tblProducts.DefaultView
        rptRelatedProducts.DataBind()
    End Sub

    ''' <summary>
    ''' Loads the list of People Who Bought This Also Bought This products.
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadPeopleWhoBoughtThis()

        Dim intPeopleWhoBoughtThisMax As Integer

        Try
            intPeopleWhoBoughtThisMax = CInt(GetKartConfig("frontend.crossselling.peoplewhoboughtthis.max"))
        Catch ex As Exception
            intPeopleWhoBoughtThisMax = 0
        End Try

        If intPeopleWhoBoughtThisMax > 0 Then
            '' Add the products to a DataTable
            Dim tblProducts As New DataTable
            tblProducts = ProductsBLL.GetPeopleWhoBoughtThis(_ProductID, _LanguageID, intPeopleWhoBoughtThisMax)

            '' If there are no products, then exit this section.
            If tblProducts.Rows.Count = 0 Then Exit Sub

            '' Bind the linked categories in to rptPeopleWhoAlsoBoughtThis, and View its container.
            phdPeopleWhoBoughtThis.Visible = True
            rptPeopleWhoBoughtThis.DataSource = tblProducts.DefaultView
            rptPeopleWhoBoughtThis.DataBind()
        Else
            '' Hide people who bought this section
            phdPeopleWhoBoughtThis.Visible = False
        End If
    End Sub
    ''' <summary>
    ''' Loads the list of linked categories.
    ''' </summary>
    ''' <remarks></remarks>
    Sub LoadLinkedCategories()

        Dim intLinkedCategories As Integer

        Try
            intLinkedCategories = CInt(GetKartConfig("frontend.crossselling.trythesecategories"))
        Catch ex As Exception
            intLinkedCategories = 0
        End Try

        If intLinkedCategories > 0 Then
            '' Add the linked categories to a DataTable
            Dim tblCategories As DataTable = CategoriesBLL.GetCategoriesByProductID(_ProductID, _LanguageID).Rows.Cast(Of System.Data.DataRow)().Take(intLinkedCategories).CopyToDataTable()
            'dt.Rows.Cast<System.Data.DataRow>().Take(n)

            '' If there is no linked categories, then exit this section.
            If tblCategories.Rows.Count = 0 Then Exit Sub

            '' Bind the linked categories in to rptLinkedCategories, and View its container.
            phdLinkedCategories.Visible = True
            rptLinkedCategories.DataSource = tblCategories.DefaultView
            rptLinkedCategories.DataBind()
        Else
            phdLinkedCategories.Visible = False
        End If
    End Sub

    Protected Sub rptLinkedCategories_ItemDataBound(ByVal Sender As Object, ByVal e As RepeaterItemEventArgs) Handles rptLinkedCategories.ItemDataBound
        If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
            Try
                CType(e.Item.FindControl("lnkParentCategories"), HyperLink).NavigateUrl =
                    SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalCategory, CType(e.Item.DataItem, DataRowView).Item(0))
            Catch ex As Exception
                'Oops
            End Try
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim strCurrentPath As String = Request.RawUrl.ToString.ToLower
            If Not (InStr(strCurrentPath, "/skins/") > 0 Or InStr(strCurrentPath, "/javascript/") > 0 Or InStr(strCurrentPath, "/images/") > 0) Then
                Try
                    Dim intProductID As Integer = Request.QueryString("ProductID")

                    If intProductID > 0 Then
                        Dim numLangID As Short = CShort(Session("LANG"))
                        LoadCarryOnShopping(intProductID, numLangID)
                    End If

                Catch ex As Exception
                    CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                End Try
            End If
        End If
    End Sub
End Class
