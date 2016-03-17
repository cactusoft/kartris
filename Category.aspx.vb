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

Partial Class Category
    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'We set a value to keep track of any trapped
        'error handled, this way, we can avoid throwing
        'a generic error on top of the handled one.
        Dim strErrorThrown As String = ""

        If Not Page.IsPostBack Then
            Dim strCurrentPath As String = Request.RawUrl.ToString.ToLower
            If Not (InStr(strCurrentPath, "/skins/") > 0 Or InStr(strCurrentPath, "/javascript/") > 0 Or InStr(strCurrentPath, "/images/") > 0) Then
                Try
                    Dim strActiveTab As String = Request.QueryString("T")
                    Dim intCategoryID As Integer = Request.QueryString("CategoryID")

                    Dim numLangID As Short = 1 'default to default language
                    Try
                        numLangID = CShort(Session("LANG"))
                    Catch ex As Exception
                        'numLangID = Request.QueryString("L")
                    End Try

                    UC_CategoryView.LoadCategory(intCategoryID, Session("LANG"))
                    If UC_CategoryView.IsCategoryExist OrElse intCategoryID = 0 Then
                        Me.CanonicalTag = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalCategory, intCategoryID)
                        Me.MetaDescription = CategoriesBLL.GetMetaDescriptionByCategoryID(intCategoryID, numLangID)
                        Me.MetaKeywords = CategoriesBLL.GetMetaKeywordsByCategoryID(intCategoryID, numLangID)

                        UC_SubCategoryView.LoadSubCategories(intCategoryID, Session("LANG"), UC_CategoryView.SubCategoryDisplayType)
                        UC_CategoryProductsView.LoadCategoryProducts(intCategoryID, Session("LANG"), UC_CategoryView.ProductsDisplayType, UC_CategoryView.ProductsDisplayOrder, UC_CategoryView.ProductsSortDirection)

                        If UC_SubCategoryView.TotalItems > 0 Then
                            litSubCatHeader.Text &= " <span class=""total"">(" & UC_SubCategoryView.TotalItems & ")</span>"
                            If strActiveTab = "S" Then tabContainer.ActiveTabIndex = 0
                        Else
                            tabSubCats.Enabled = False
                            tabSubCats.Visible = False
                        End If
                        If UC_CategoryProductsView.TotalItems > 0 Then
                            litProductsHeader.Text &= " <span class=""total"">(" & UC_CategoryProductsView.TotalItems & ")</span>"
                            If strActiveTab <> "S" Then tabContainer.ActiveTabIndex = 1
                        ElseIf Request.QueryString("f") <> "1" Then
                            tabProducts.Enabled = False
                            tabProducts.Visible = False
                        End If

                        If Not Page.IsPostBack AndAlso KartSettingsManager.GetKartConfig("general.products.hittracking") = "y" Then
                            StatisticsBLL.AddNewStatsRecord("C", _
                                            GetIntegerQS("CategoryID"), GetIntegerQS("strParent"))
                        End If
                        If intCategoryID = 0 Then UC_BreadCrumbTrail.SiteMapProvider = "BreadCrumbSitemap"
                    Else
                        'An item was called with correctly formatted URL, but
                        'the ID doesn't appear to pull out an item, so it's
                        'likely the item is no longer available.
                        strErrorThrown = "404"
                        Try
                            HttpContext.Current.Server.Transfer("~/404.aspx")
                        Catch exError As Exception

                        End Try
                    End If
                Catch ex As Exception
                    'Some other error occurred - it seems the ID of the item
                    'exists, but loading or displaying the item caused some
                    'other error.
                    CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                    If strErrorThrown = "" Then HttpContext.Current.Server.Execute("~/Error.aspx")
                End Try
            End If
        End If
    End Sub

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        If Session("NewBasketItem") = 1 Then
            Dim MiniBasket As Object = Master.FindControl("UC_MiniBasket")
            MiniBasket.LoadMiniBasket()
            Session("NewBasketItem") = 0
        End If
    End Sub
End Class

