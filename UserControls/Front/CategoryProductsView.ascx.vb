'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

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
        If tblProducts.Rows.Count = 0 Then Me.Visible = False : Exit Sub

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


    'Dim strXml As String = _
    '    "<?xml version=""1.0"" encoding=""utf-8""?>" & _
    '    "<KartrisCategoryFilters>" & _
    '        "<PriceRange>" & _
    '            "<Range BottomValue=""0"" TopValue=""234""></Range>" & _
    '        "</PriceRange>" & _
    '        "<Attributes>" & _
    '            "<Attribute Name=""Attribute 1"">" & _
    '                "<AttributeValue>Att1_Value1</AttributeValue>" & _
    '                "<AttributeValue>Att1_Value2</AttributeValue>" & _
    '                "<AttributeValue>Att1_Value3</AttributeValue>" & _
    '                "<AttributeValue>Att1_Value4</AttributeValue>" & _
    '                "<AttributeValue>Att1_Value5</AttributeValue>" & _
    '            "</Attribute>" & _
    '            "<Attribute Name=""Attribute 2"">" & _
    '                "<AttributeValue>Att2_Value1</AttributeValue>" & _
    '                "<AttributeValue>Att2_Value2</AttributeValue>" & _
    '                "<AttributeValue>Att2_Value3</AttributeValue>" & _
    '                "<AttributeValue>Att2_Value4</AttributeValue>" & _
    '                "<AttributeValue>Att2_Value5</AttributeValue>" & _
    '            "</Attribute>" & _
    '            "<Attribute Name=""Attribute 3"">" & _
    '                "<AttributeValue>Att3_Value1</AttributeValue>" & _
    '                "<AttributeValue>Att3_Value2</AttributeValue>" & _
    '                "<AttributeValue>Att3_Value3</AttributeValue>" & _
    '                "<AttributeValue>Att3_Value4</AttributeValue>" & _
    '            "</Attribute>" & _
    '            "<Attribute Name=""Attribute 4"">" & _
    '                "<AttributeValue>Att4_Value1</AttributeValue>" & _
    '                "<AttributeValue>Att4_Value2</AttributeValue>" & _
    '                "<AttributeValue>Att4_Value3</AttributeValue>" & _
    '                "<AttributeValue>Att4_Value4</AttributeValue>" & _
    '                "<AttributeValue>Att4_Value5</AttributeValue>" & _
    '            "</Attribute>" & _
    '        "</Attributes>" & _
    '    "</KartrisCategoryFilters>"

    ''Dim dataSet As DataSet = New DataSet
    Dim arrSelectedValues() As String = Nothing
    Dim xmlDoc As New XmlDocument

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadCategoryFilters()
            'Dim strXml As String = ObjectConfigBLL._GetValue("K:category.productfilterxml", CategoryID())
            'If String.IsNullOrEmpty(strXml) Then
            'phdCategoryFilters.Visible = False
            'Else
            '    LoadCategoryFilters(strXml)
            'End If
        End If
    End Sub

    Sub LoadCategoryFilters()
        'phdCategoryFilters.Visible = False
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
    'Sub LoadCategoryFilters(strXml As String)

    '    xmlDoc.LoadXml(strXml)
    '    '' Load Price
    '    phdPriceRange.Visible = False
    '    Dim _xmlNode As XmlNode = xmlDoc.DocumentElement
    '    Dim _xmlPriceNodeList As XmlNodeList = _xmlNode.SelectNodes("/KartrisCategoryFilters/PriceRange")
    '    If _xmlPriceNodeList.Count = 1 Then
    '        Dim chrCurrencySymbol As Char = CurrenciesBLL.CurrencySymbol(Session("CUR_ID"))
    '        Dim numMaxPrice As Integer = 0
    '        For Each chld As XmlNode In _xmlPriceNodeList.Item(0).ChildNodes
    '            If IsNumeric(chld.Attributes("TopValue").Value) AndAlso IsNumeric(chld.Attributes("BottomValue").Value) Then
    '                If numMaxPrice < chld.Attributes("TopValue").Value Then numMaxPrice = chld.Attributes("TopValue").Value
    '                Dim sPriceRange As String = "Price: " & chrCurrencySymbol & chld.Attributes("BottomValue").Value & " - " & _
    '                                            chrCurrencySymbol & chld.Attributes("TopValue").Value
    '                ddlPriceRange.Items.Add( _
    '                    New ListItem(sPriceRange, chld.Attributes("BottomValue").Value & "," & chld.Attributes("TopValue").Value))
    '            End If
    '        Next
    '        ddlPriceRange.Items.Add(New ListItem("Custom Price", "0,0"))
    '        ddlPriceRange.Items.Insert(0, New ListItem("Any Price (" & chrCurrencySymbol & "0 - " & _
    '                                            chrCurrencySymbol & numMaxPrice & ")", "0," & numMaxPrice))
    '        If IsNumeric(_xmlPriceNodeList.Item(0).ChildNodes(0).Attributes("TopValue").Value) Then
    '            txtFromPrice.Text = "0" '_xmlPriceNodeList.Item(0).ChildNodes(0).Attributes("TopValue").Value
    '            txtToPrice.Text = numMaxPrice
    '            litFromSymbol.Text = chrCurrencySymbol & " "
    '            litToSymbol.Text = chrCurrencySymbol & " "
    '        End If
    '        phdCustomPrice.Visible = False
    '        If ddlPriceRange.Items.Count > 2 Then phdPriceRange.Visible = True
    '    End If
    '    '' Set Filters in Controls
    '    If Request.QueryString("f") = 1 Then
    '        Dim strKeys As String = Request.QueryString("key")
    '        Dim sngMinPrice As Single = IIf(Not String.IsNullOrEmpty(Request.QueryString("from")) _
    '                                        AndAlso IsNumeric(Request.QueryString("from")), _
    '                                        CSng(Request.QueryString("from")), -1.0F)
    '        Dim sngMaxPrice As Single = IIf(Not String.IsNullOrEmpty(Request.QueryString("to")) _
    '                                        AndAlso IsNumeric(Request.QueryString("to")), _
    '                                        CSng(Request.QueryString("to")), -1.0F)
    '        Dim strAttributeValues As String = Request.QueryString("filters")
    '        Dim strOrderBy As String = IIf(String.IsNullOrEmpty(Request.QueryString("sort")), "P_Name", "P_" & Request.QueryString("sort"))
    '        Dim strOrderDirection As String = IIf(String.IsNullOrEmpty(Request.QueryString("dir")), "A", Request.QueryString("dir"))

    '        txtSearch.Text = strKeys

    '        If ddlPriceRange.Items.Count > 0 Then
    '            ddlPriceRange.SelectedIndex = ddlPriceRange.Items.Count - 1
    '            If sngMinPrice > -1 AndAlso sngMaxPrice > -1 Then
    '                Dim blnFound As Boolean = False
    '                For i As Integer = 0 To ddlPriceRange.Items.Count - 2
    '                    If ddlPriceRange.Items(i).Value = sngMinPrice & "," & sngMaxPrice Then
    '                        ddlPriceRange.SelectedIndex = i
    '                        blnFound = True
    '                        Exit For
    '                    End If
    '                Next
    '                If Not blnFound Then
    '                    txtFromPrice.Text = sngMinPrice
    '                    txtToPrice.Text = sngMaxPrice
    '                    phdCustomPrice.Visible = True
    '                End If
    '            Else
    '                If sngMinPrice > -1 Then txtFromPrice.Text = sngMinPrice Else txtFromPrice.Text = "0"
    '                If sngMaxPrice > -1 Then txtToPrice.Text = sngMaxPrice Else txtToPrice.Text = ddlPriceRange.Items(0).Value.Split(",")(1)
    '                phdCustomPrice.Visible = True
    '            End If
    '        End If

    '        ddlOrderBy.SelectedValue = ".sort=" & strOrderBy.ToLower.Replace("p_", "") & ".dir=" & strOrderDirection.ToLower()

    '        If Not String.IsNullOrEmpty(strAttributeValues) Then
    '            If strAttributeValues.EndsWith(",") Then strAttributeValues = strAttributeValues.TrimEnd(",")
    '            arrSelectedValues = strAttributeValues.ToLower.Split(",")
    '        End If
    '    End If
    '    '' Load Attributes
    '    phdAttributes.Visible = False
    '    Dim dtAttributes As New DataTable
    '    dtAttributes.Columns.Add(New DataColumn("AttributeName", Type.GetType("System.String")))
    '    Dim _xmlAttributesNodeList As XmlNodeList = _xmlNode.SelectNodes("/KartrisCategoryFilters/Attributes")
    '    For x As Integer = 0 To _xmlAttributesNodeList.Count - 1
    '        For Each nodeAttributes As XmlNode In _xmlAttributesNodeList.Item(x).ChildNodes
    '            dtAttributes.Rows.Add(nodeAttributes.Attributes("Name").Value)
    '        Next
    '    Next
    '    If dtAttributes.Rows.Count > 0 Then
    '        phdAttributes.Visible = True
    '        rptAttributes.DataSource = dtAttributes
    '        rptAttributes.DataBind()
    '    End If
    'End Sub

    Protected Sub rptAttributes_ItemDataBound(sender As Object, e As RepeaterItemEventArgs) Handles rptAttributes.ItemDataBound
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            PowerpackBLL.BoundRepeaterAttributeItem(xmlDoc, arrSelectedValues, e.Item)
            'Dim strAttributeName As String = CType(e.Item.FindControl("lblAttributeName"), Label).Text
            'Dim chkList As CheckBoxList = CType(e.Item.FindControl("chkList"), CheckBoxList)
            'Dim _xmlNode As XmlNode = xmlDoc.DocumentElement
            'Dim _xmlNodeList As XmlNodeList = _xmlNode.SelectNodes("/KartrisCategoryFilters/Attributes")
            'For x As Integer = 0 To _xmlNodeList.Count - 1
            '    For Each nodeAttributes As XmlNode In _xmlNodeList.Item(x).ChildNodes
            '        If nodeAttributes.Attributes("Name").Value.ToLower() = strAttributeName.ToLower() Then
            '            For Each nodeValues As XmlNode In nodeAttributes.ChildNodes
            '                If arrSelectedValues IsNot Nothing AndAlso arrSelectedValues.Length > 0 AndAlso arrSelectedValues.ToList.IndexOf(nodeValues.InnerText.ToLower()) > -1 Then
            '                    Dim lstItm As New ListItem(nodeValues.InnerText)
            '                    lstItm.Selected = True
            '                    chkList.Items.Add(lstItm)
            '                Else
            '                    chkList.Items.Add(New ListItem(nodeValues.InnerText))
            '                End If
            '            Next
            '        End If
            '    Next
            'Next
        End If
    End Sub

    Protected Sub lnkBtnSearch_Click(sender As Object, e As EventArgs) Handles lnkBtnSearch.Click
        '' Read selected attribute values
        Dim strAttributeValues As String = String.Empty
        For Each itm As RepeaterItem In rptAttributes.Items
            If itm.ItemType = ListItemType.Item OrElse itm.ItemType = ListItemType.AlternatingItem Then
                Dim chkList As CheckBoxList = CType(itm.FindControl("chkList"), CheckBoxList)
                For Each ls As ListItem In chkList.Items
                    If ls.Selected Then strAttributeValues += ls.Text + ","
                Next
            End If
        Next
        If strAttributeValues.EndsWith(",") Then strAttributeValues.TrimEnd(",")
        PowerpackBLL.GoToFilterURL(Request, txtFromPrice.Text, txtToPrice.Text, StripHTML(txtSearch.Text), strAttributeValues, ddlOrderBy.SelectedValue)
        'Dim strURL As String = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category, Request.QueryString("CategoryID"), Request.QueryString("strParent"))
        'strURL += "?f=1"
        'strURL += ddlOrderBy.SelectedValue.Replace(".", "&")
        'If Not String.IsNullOrEmpty(txtFromPrice.Text) Then strURL += "&from=" & txtFromPrice.Text
        'If Not String.IsNullOrEmpty(txtToPrice.Text) Then strURL += "&to=" & txtToPrice.Text
        'If Not String.IsNullOrEmpty(txtSearch.Text) Then strURL += "&key=" & txtSearch.Text
        'If Not String.IsNullOrEmpty(strAttributeValues) Then strURL += "&filters=" & strAttributeValues
        'Response.Redirect(strURL)
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
        End If
    End Sub
End Class
