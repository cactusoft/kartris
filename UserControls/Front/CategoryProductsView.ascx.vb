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
Imports KartSettingsManager
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions

Imports System.Web.HttpContext

Imports CkartrisEnumerations
Imports CkartrisImages
Imports System.Linq
''' <summary>
''' Used in Categories.aspx, to list the products that belong to the currently browsed category.
''' It uses the 3 UCs Product's View Templates "Extened, Shortened, and Normal" to Display Products.
''' The UC ItemPager.ascx is used here to allow the paging for large number of products.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class CategoryProductsView
    Inherits System.Web.UI.UserControl

    '' The URL Query String Key that holds the Products' PageNo. to display.
    Const c_PAGER_QUERY_STRING_KEY As String = "PPGR"


    Private _CategoryID As Integer
    Private _LanguageID As Short
    Private _ViewType As Char
    Private _DisplayOrder As String
    Private _DisplayDirection As Char

    '' No. of products in each page. Its the CONFIG Setting Key (frontend.products.display.[viewName].pagesize)
    Private _RowsPerPage As Short

    '' The total number of Products under the category.
    Private c_numTotalProductsInCategory As Integer

    Public ReadOnly Property CategoryID() As Integer
        Get
            Return _CategoryID
        End Get
    End Property

    Public ReadOnly Property TotalItems() As Integer
        Get
            Return c_numTotalProductsInCategory
        End Get
    End Property

    Dim tblProducts As New DataTable
    ''' <summary>
    ''' Loads/Prepares the products of the Category.
    ''' </summary>
    ''' <param name="pCategoryID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <param name="pViewType">e->Extended, n->Normal, s->Shortened, and d->Default "CONFIG Setting Key"</param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub LoadCategoryProducts(ByVal pCategoryID As Integer, ByVal pLanguageID As Short, _
                                    ByVal pViewType As Char, ByVal pDisplayOrder As String, ByVal pDisplayDirection As Char)

        If pCategoryID = 0 Then Exit Sub

        _CategoryID = pCategoryID
        _LanguageID = pLanguageID
        _ViewType = pViewType
        _DisplayOrder = pDisplayOrder
        _DisplayDirection = pDisplayDirection

        '' Gets the View Type value from the CONFIG Settings if the viewType parameter is set to Default.
        If _ViewType = "d" Then _ViewType = GetKartConfig("frontend.products.display.default")

        '' Loads the Products in the tblProducts DataTable depending
        ''  on the View Type of the products. "ByRef"
        GenerateProductsList(tblProducts)

        '' If there is no products under the category, then exit.
        If tblProducts.Rows.Count = 0 Then
            If Request.QueryString("f") <> 1 Then
                Me.Visible = False
            Else
                'phdCategoryFilters.Visible = True
                'Me.Visible = True
                mvwCategoryProducts.SetActiveView(viwNoItems)
                Exit Sub
            End If
        End If

        '' Binding the tblProducts to the proper repeater, depending on the View Type.
        '' And then activate the corresponding View Control.
        Select Case _ViewType
            Case "n"
                rptNormal.DataSource = tblProducts.DefaultView
                rptNormal.DataBind()
                mvwCategoryProducts.SetActiveView(viwNormal)
            Case "e"
                rptExtended.DataSource = tblProducts.DefaultView
                rptExtended.DataBind()
                mvwCategoryProducts.SetActiveView(viwExtended)
            Case "s"
                rptShortened.DataSource = tblProducts.DefaultView
                rptShortened.DataBind()
                mvwCategoryProducts.SetActiveView(viwShortened)
            Case "t"
                rptTabular.DataSource = tblProducts.DefaultView
                rptTabular.DataBind()
                mvwCategoryProducts.SetActiveView(viwTabular)
            Case Else
                'litGroupName.Visible = False
        End Select
    End Sub

    ''' <summary>
    ''' Generates and Fills the tblProducts with the products that belong to the Current Category Page.
    ''' Also, initializes the ItemPager.ascx to create the pages(if any).
    ''' </summary>
    ''' <param name="pTblProducts">Reference to the products' dataTable</param>
    ''' <remarks></remarks>
    Private Sub GenerateProductsList(ByRef pTblProducts As DataTable)

        '' Checking if the Products' Paging is Enabled in the CONFIG Settings

        '' Gets the value of the Paging Key "PPGR" from the URL.
        Dim numPageIndx As Short
        Try
            If Request.QueryString(c_PAGER_QUERY_STRING_KEY) Is Nothing Then
                numPageIndx = 0
            Else
                numPageIndx = Request.QueryString(c_PAGER_QUERY_STRING_KEY)
            End If
        Catch ex As Exception
        End Try
        Dim strViewName As String = Nothing

        Select Case _ViewType
            Case "n" : strViewName = "normal"
            Case "e" : strViewName = "extended"
            Case "s" : strViewName = "shortened"
            Case "t" : strViewName = "tabular"
            Case Else
        End Select

        '' Gets No. of Products/Page from the CONFIG Setting, depending on the viewName(viewType)
        _RowsPerPage = GetKartConfig("frontend.products.display." & strViewName & ".pagesize")

        Dim numCGroupID As Short = 0
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            numCGroupID = CShort(DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID)
        End If

        '' Saving the current page's products in tblProducts, depending on the pageIndex "PPGR"
        pTblProducts = ProductsBLL.GetProductsPageByCategory(Request, _CategoryID, _LanguageID, numPageIndx, _
                                                                _RowsPerPage, numCGroupID, c_numTotalProductsInCategory)

        If pTblProducts.Rows.Count <> 0 Then
            '' If the total products couldn't be fitted in 1 Page, Then Initialize the Pager.
            If c_numTotalProductsInCategory > _RowsPerPage Then

                '' Load the Header & Footer Pagers
                UC_ItemPager_Header.LoadPager(c_numTotalProductsInCategory, _RowsPerPage, c_PAGER_QUERY_STRING_KEY)
                UC_ItemPager_Footer.LoadPager(c_numTotalProductsInCategory, _RowsPerPage, c_PAGER_QUERY_STRING_KEY)

                UC_ItemPager_Header.DisableLink(numPageIndx)
                UC_ItemPager_Footer.DisableLink(numPageIndx)

                '' Make the pager visible.
                UC_ItemPager_Header.Visible = True
                UC_ItemPager_Footer.Visible = True
            End If
        End If

        '' Converting the price currency in the retrieved products, depending on the current currency.
        For Each row As DataRow In pTblProducts.Rows
            row("MinPrice") = CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), CDbl(row("MinPrice")))
        Next

    End Sub

    Dim arrSelectedValues() As String = Nothing
    Dim xmlDoc As New XmlDocument

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadCategoryFilters()
        Else
            If GetPostBackControlId(page) = "chkList" then
                lnkBtnSearch_Click(sender, e)
            End if
        End If
    End Sub

    Sub LoadCategoryFilters()
        PowerpackBLL.LoadCategoryFilters(CategoryID(), Request, _
                                        xmlDoc, arrSelectedValues, _
                                        Session("CUR_ID"), phdCategoryFilters, _
                                        phdPriceRange, ddlPriceRange, _
                                        txtFromPrice, txtToPrice, _
                                        litFromSymbol, litToSymbol, _
                                        phdCustomPrice, txtSearch, _
                                        ddlOrderBy, phdAttributes, _
                                        rptAttributes)
    End Sub


''' <summary>
''' Gets the ID of the post back control.
''' 
''' See: http://geekswithblogs.net/mahesh/archive/2006/06/27/83264.aspx
''' </summary>
''' <param name = "page">The page.</param>
''' <returns></returns>
    Public Shared Function GetPostBackControlId(page As Page) As String
      If Not page.IsPostBack Then
        Return String.Empty
      End If

      Dim control As Control = Nothing
      ' first we will check the "__EVENTTARGET" because if post back made by the controls
      ' which used "_doPostBack" function also available in Request.Form collection.
      Dim controlName As String = page.Request.Params("__EVENTTARGET")
      If Not [String].IsNullOrEmpty(controlName) Then
        control = page.FindControl(controlName)
      Else
        ' if __EVENTTARGET is null, the control is a button type and we need to
        ' iterate over the form collection to find it

        ' ReSharper disable TooWideLocalVariableScope
        Dim controlId As String
        Dim foundControl As Control
        ' ReSharper restore TooWideLocalVariableScope

        For Each ctl As String In page.Request.Form
          ' handle ImageButton they having an additional "quasi-property" 
          ' in their Id which identifies mouse x and y coordinates
          If ctl.EndsWith(".x") OrElse ctl.EndsWith(".y") Then
            controlId = ctl.Substring(0, ctl.Length - 2)
            foundControl = page.FindControl(controlId)
          Else
            foundControl = page.FindControl(ctl)
          End If

          If Not (TypeOf foundControl Is Button OrElse TypeOf foundControl Is ImageButton) Then
            Continue For
          End If

          control = foundControl
          Exit For
        Next
      End If

      Return If(control Is Nothing, [String].Empty, control.ID)
    End Function

    Protected Sub rptAttributes_ItemDataBound(sender As Object, e As RepeaterItemEventArgs) Handles rptAttributes.ItemDataBound
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            PowerpackBLL.BoundRepeaterAttributeItem(xmlDoc, arrSelectedValues, e.Item)
        End If
    End Sub

    Protected Sub lnkBtnSearch_Click(sender As Object, e As EventArgs) Handles lnkBtnSearch.Click, lnkBtnSearch2.Click
        '' Read selected attribute values
        Dim strAttributeValues As String = String.Empty
        'We need the attribute counter below so we know which attribute a value belongs to.
        'For example, you could have two attributes, 'text colour' and 'background colour', which
        'both have black/white as values. Previously we only looked at the attribute name, so
        'we'd see 'white' and check any box that is for white, even if it was in the wrong attribute.
        'To avoid this, we append which number attribute it is to the value with ||| as a separator
        'because this should not occur in attribute names or values.
        Dim numAttributeCounter As Integer = 0
        For Each itm As RepeaterItem In rptAttributes.Items
            numAttributeCounter += 1
            Dim strAttributeName As String = CType(itm.FindControl("lblAttributeName"), Label).Text
            If itm.ItemType = ListItemType.Item OrElse itm.ItemType = ListItemType.AlternatingItem Then
                Dim chkList As CheckBoxList = CType(itm.FindControl("chkList"), CheckBoxList)
                For Each ls As ListItem In chkList.Items
                    'Note below we add attribute value + "|||" + attribute number, this
                    'avoids falsely assuming any attribute value match checks a box. Now, it 
                    'will only be checked if it is in the right attribute. So 'black' will only
                    'be checked for 'background colour' for example, and not for 'text colour',
                    'if appropriate.

                    'See powerpackBLL.vb - BoundRepeaterAttributeItem
                    If ls.Selected Then strAttributeValues += Replace(ls.Text & "|||" & strAttributeName, ",", "[;]") + ","
                Next
            End If
        Next
        If strAttributeValues.EndsWith(",") Then strAttributeValues.TrimEnd(",")
        PowerpackBLL.GoToFilterURL(Request, txtFromPrice.Text, txtToPrice.Text, StripHTML(txtSearch.Text), strAttributeValues, ddlOrderBy.SelectedValue)
    End Sub

    Protected Sub ddlPriceRange_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlPriceRange.SelectedIndexChanged
        txtFromPrice.Text = ddlPriceRange.SelectedValue.Split(",")(0)
        txtToPrice.Text = ddlPriceRange.SelectedValue.Split(",")(1)
        If ddlPriceRange.SelectedIndex = ddlPriceRange.Items.Count - 1 Then
            txtToPrice.Text = ddlPriceRange.Items(0).Value.Split(",")(1)
            phdCustomPrice.Visible = True
            txtToPrice.Focus()
        Else
            phdCustomPrice.Visible = False
            lnkBtnSearch_Click(sender, e)
        End If

    End Sub

    Protected Sub ddlOrderBy_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlOrderBy.SelectedIndexChanged
        lnkBtnSearch_Click(sender, e)
    End Sub

End Class
