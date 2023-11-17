'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

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
''' Used in Categories.aspx, to list the categories that belong to the currently browsed category.
''' It uses the 4 UCs Category's View Templates "Link, Shortened, Text, and Normal" to Display SubCategories.
''' The UC ItemPager.ascx is used here to allow the paging for large number of categories.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class UserControls_Front_New_SubCategoryView
    Inherits System.Web.UI.UserControl

    '' The URL Query String Key that holds the SubCategory's PageNo. to display.
    Const c_PAGER_QUERY_STRING_KEY As String = "CPGR"

    '' No. of categories in each page. Its the CONFIG Setting Key (frontend.categories.display.[viewName].pagesize)
    Private _RowsPerPage As Short

    '' The total number of Categories under the Parent Category.
    Private c_numTotalCategoriesInParent As Integer

    Private _ParentCategoryID As Integer
    Private _LanguageID As Short
    Private _DisplayType As Char

    Public ReadOnly Property SubCategoryDisplayType() As String
        Get
            Return _DisplayType
        End Get
    End Property

    Public ReadOnly Property TotalItems() As Integer
        Get
            Return c_numTotalCategoriesInParent
        End Get
    End Property

    ''' <summary>
    ''' Loads the child categories(SubCategories) under the Currently Browsed Category.
    ''' </summary>
    ''' <param name="pParentCategoryID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <param name="pViewType"></param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadSubCategories(ByVal pParentCategoryID As Integer, ByVal pLanguageID As Short, ByVal pViewType As Char)

        _ParentCategoryID = pParentCategoryID
        _LanguageID = pLanguageID
        _DisplayType = pViewType

        '' If the displayType is 'd'(Default), Get the Default displayType from the CONFIG Settings
        If _DisplayType = "d" Or _ParentCategoryID = 0 Then _DisplayType = GetKartConfig("frontend.categories.display.default")

        Dim tblCategories As New DataTable

        '' Loads the SubCategoryList in the tblCategories DataTable depending
        ''  on the View Type of the SubCategories. "ByRef"
        GenerateSubCategoriesList(tblCategories)

        '' If there is no child Categories, show the empty view Control and Exit.
        If tblCategories.Rows.Count = 0 Then Me.Visible = False : Exit Sub

        'litGroupName.Visible = True

        '' Binding the tblCategories to the proper repeater, depending on the View Type.
        '' And then activate the corresponding View Control.
        Select Case _DisplayType
            Case "n"
                rptNormal.DataSource = tblCategories.DefaultView
                rptNormal.DataBind()
                multiSubCategories.SetActiveView(viewNormal)
            Case "s"
                rptShortened.DataSource = tblCategories.DefaultView
                rptShortened.DataBind()
                multiSubCategories.SetActiveView(viewShortened)
            Case "l"
                rptLink.DataSource = tblCategories.DefaultView
                rptLink.DataBind()
                multiSubCategories.SetActiveView(viewLink)
            Case "t"
                rptText.DataSource = tblCategories.DefaultView
                rptText.DataBind()
                multiSubCategories.SetActiveView(viewText)
            Case Else
                multiSubCategories.SetActiveView(viewError)
        End Select

    End Sub

    ''' <summary>
    ''' Generates and Fills the tblCategories with the Categories that belong to the Current Category Page.
    ''' Also, initializes the ItemPager.ascx to create the pages(if any).
    ''' </summary>
    ''' <param name="prTblCategories"></param>
    ''' <remarks>By Mohammad</remarks>
    Private Sub GenerateSubCategoriesList(ByRef prTblCategories As DataTable)


        '' Gets the value of the Paging Key "CPGR" from the URL.
        Dim numPageIndx As Short
        Try

        If Request.QueryString(c_PAGER_QUERY_STRING_KEY) Is Nothing Then
                numPageIndx = 0
            Else
                numPageIndx = Request.QueryString(c_PAGER_QUERY_STRING_KEY)
            End If
        Catch ex As Exception
        End Try

        Dim strViewName As String = ""

        Select Case _DisplayType
            Case "n" : strViewName = "normal"
            Case "s" : strViewName = "shortened"
            Case "l" : strViewName = "link"
            Case "t" : strViewName = "text"
            Case Else
                strViewName = "normal"
        End Select

        '' Gets No. of Categories/Page from the CONFIG Setting, depending on the viewName(viewType)
        _RowsPerPage = GetKartConfig("frontend.categories.display." & strViewName & ".pagesize")

        Dim numCGroupID As Short = 0
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            numCGroupID = CShort(DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID)
        End If

        '' Saving the current page's subcategories in tblCategories, depending on the pageIndex "CPGR"
        Dim objCategoriesBLL As New CategoriesBLL
        prTblCategories = objCategoriesBLL.GetCategoriesPageByParentID(_ParentCategoryID, _LanguageID, numPageIndx,
                                        _RowsPerPage, numCGroupID, c_numTotalCategoriesInParent)

        If prTblCategories.Rows.Count <> 0 Then
            '' If the total child categories couldn't be fitted in 1 Page, Then Initialize the Pager.
            If c_numTotalCategoriesInParent > _RowsPerPage Then

                '' Load the Header & Footer Pagers
                UC_ItemPager_Header.LoadPager(c_numTotalCategoriesInParent, _RowsPerPage, c_PAGER_QUERY_STRING_KEY)
                UC_ItemPager_Footer.LoadPager(c_numTotalCategoriesInParent, _RowsPerPage, c_PAGER_QUERY_STRING_KEY)
        
                UC_ItemPager_Header.DisableLink(numPageIndx)
                UC_ItemPager_Footer.DisableLink(numPageIndx)
        
                '' Make the pager visible.
                UC_ItemPager_Header.Visible = True
                UC_ItemPager_Footer.Visible = True
            End If
        End If
        
    End Sub
End Class
