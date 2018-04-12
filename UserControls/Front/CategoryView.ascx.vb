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
Imports KartSettingsManager

''' <summary>
''' Used in the Categories.aspx, to view the main info. about the currently viewed category.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class CategoryView
    Inherits System.Web.UI.UserControl

    Private _CategoryID As Integer

    '' The display type of the products under this category.
    Private _ProductsDisplayType As Char

    '' The display type of the categories under this category (SubCategories).
    Private _SubCategoryDisplayType As Char

    '' The display order (sorting) of the products under this category.
    Private _ProductsDisplayOrder As String

    '' The display the direction of the order (sorting) of the products under this category.
    Private _ProductsSortDirection As Char

    Private _IsCategoryExist As Boolean

    '' ReadOnly Properties useful to pass parameters to other UCs. 
    Public ReadOnly Property Category() As Integer
        Get
            Return _CategoryID
        End Get
    End Property

    Public ReadOnly Property ProductsDisplayType() As Char
        Get
            Return _ProductsDisplayType
        End Get
    End Property

    Public ReadOnly Property SubCategoryDisplayType() As Char
        Get
            Return _SubCategoryDisplayType
        End Get
    End Property

    Public ReadOnly Property ProductsDisplayOrder() As String
        Get
            Return _ProductsDisplayOrder
        End Get
    End Property

    Public ReadOnly Property ProductsSortDirection() As Char
        Get
            Return _ProductsSortDirection
        End Get
    End Property

    Public ReadOnly Property IsCategoryExist() As Boolean
        Get
            Return _IsCategoryExist
        End Get
    End Property

    ''' <summary>
    ''' Loads the Category's info. to a DataTable, and then calls the Template to hold these info.
    ''' </summary>
    ''' <param name="pCategoryID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadCategory(ByVal pCategoryID As Integer, ByVal pLanguageID As Short)

        _CategoryID = pCategoryID

        '' DataTable that will hold the category information.
        Dim tblCategories As New DataTable
        tblCategories = CategoriesBLL.GetCategoryByID(_CategoryID, pLanguageID)

        '' If there is no category, then exit.
        If tblCategories.Rows.Count = 0 Then _IsCategoryExist = False : Exit Sub

        '' Checking the customer group of the category
        Dim numCGroupID As Short = 0, numCurrentGroup As Short = 0
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            numCGroupID = CShort(DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID)
        End If

        Dim node As SiteMapNode = SiteMap.CurrentNode
        If Not node Is Nothing Then
            numCurrentGroup = node("CG_ID")
            If numCurrentGroup <> 0 AndAlso numCurrentGroup <> numCGroupID Then
                _IsCategoryExist = False : Exit Sub
            End If
        End If

        _IsCategoryExist = True

        '' Get the Display Type for the Subcategories and the Products under the current category as well.
        _SubCategoryDisplayType = FixNullFromDB(tblCategories.Rows(0)("CAT_SubCatDisplayType"))
        _ProductsDisplayType = FixNullFromDB(tblCategories.Rows(0)("CAT_ProductDisplayType"))

        _ProductsDisplayOrder = FixNullFromDB(tblCategories.Rows(0)("CAT_OrderProductsBy"))
        _ProductsSortDirection = FixNullFromDB(tblCategories.Rows(0)("CAT_ProductsSortDirection"))

        '' If the category id is 0, then its the root of all categories and it has no info.
        ''  So, exit without calling the Template.
        If _CategoryID = 0 Then UC_CategoryTemplate.HideImage() : Exit Sub

        '' Category's Page Title
        Dim strPageTitle As String = FixNullFromDB(tblCategories.Rows(0)("CAT_PageTitle"))
        Page.Title = IIf(strPageTitle = "", _
                            FixNullFromDB(tblCategories.Rows(0)("CAT_Name")) & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname")), _
                            strPageTitle & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname")))


        '' Calls for the Template to be loaded and view the catgory info.
        UC_CategoryTemplate.LoadCategoryTemplate(_CategoryID, _
                                                 FixNullFromDB(tblCategories.Rows(0)("CAT_Name")), _
                                                 FixNullFromDB(tblCategories.Rows(0)("CAT_Desc")))

    End Sub

End Class
