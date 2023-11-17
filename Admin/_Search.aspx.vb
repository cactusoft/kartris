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

Partial Class Admin_Search
    Inherits _PageBaseClass

    Dim numPageSize As Integer = GetKartConfig("backend.search.pagesize")

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Search", "PageTitle_SearchResults") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Request.QueryString("key") Is Nothing AndAlso _
            Not Request.QueryString("location") Is Nothing Then

            _Search(Request.QueryString("location"), Request.QueryString("key"))

        End If
    End Sub

    Sub _Search(ByVal strSearchBy As String, ByVal strKey As String)

        Dim numTotalResult As Integer
        Select Case strSearchBy
            Case "categories"
                gvwCategories.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwCategories.DataBind()
                litCategories.Text = numTotalResult
                If numTotalResult > 0 Then pnlCategories.Visible = True
                If gvwCategories.PageCount < 2 Then gvwCategories.AllowPaging = False
            Case "products"
                gvwProducts.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwProducts.DataBind()
                litProducts.Text = numTotalResult
                If numTotalResult > 0 Then pnlProducts.Visible = True
                If gvwProducts.PageCount < 2 Then gvwProducts.AllowPaging = False
            Case "versions"
                gvwVersions.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwVersions.DataBind()
                litVersions.Text = numTotalResult
                If numTotalResult > 0 Then pnlVersions.Visible = True
                If gvwVersions.PageCount < 2 Then gvwVersions.AllowPaging = False
            Case "customers"
                gvwCustomers.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwCustomers.DataBind()
                litCustomers.Text = numTotalResult
                If numTotalResult > 0 Then pnlCustomers.Visible = True
                If gvwCustomers.PageCount < 2 Then gvwCustomers.AllowPaging = False
            Case "orders"
                gvwOrders.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwOrders.DataBind()
                litOrders.Text = numTotalResult
                pnlOrders.Visible = True
                If gvwOrders.PageCount < 2 Then gvwOrders.AllowPaging = False
            Case "site" 'language strings
                gvwSite.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwSite.DataBind()
                litSiteText.Text = numTotalResult
                If numTotalResult > 0 Then pnlSiteText.Visible = True
                If gvwSite.PageCount < 2 Then gvwSite.AllowPaging = False
            Case "config"
                gvwConfig.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwConfig.DataBind()
                litConfig.Text = numTotalResult
                If numTotalResult > 0 Then pnlConfig.Visible = True
                If gvwConfig.PageCount < 2 Then gvwConfig.AllowPaging = False
            Case "pages"
                gvwPages.DataSource = KartrisDBBLL._SearchBackEnd(strSearchBy, strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
                gvwPages.DataBind()
                litPages.Text = numTotalResult
                If numTotalResult > 0 Then pnlPages.Visible = True
                If gvwPages.PageCount < 2 Then gvwPages.AllowPaging = False
            Case Else '' all is selected
                SearchAllDB(strKey)
                Exit Sub
        End Select

        '' No results found
        If numTotalResult = 0 Then pnlNoResults.Visible = True
        updResults.Update()
    End Sub

    Protected Sub SearchAllDB(ByVal strKey As String)
        Dim numTotalResult As Integer = 0
        Dim blnResultExist As Boolean = False

        gvwCategories.DataSource = KartrisDBBLL._SearchBackEnd("categories", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwCategories.DataBind()
        litCategories.Text = numTotalResult
        If numTotalResult > 0 Then pnlCategories.Visible = True : blnResultExist = True
        If gvwCategories.PageCount < 2 Then gvwCategories.AllowPaging = False

        numTotalResult = 0
        gvwProducts.DataSource = KartrisDBBLL._SearchBackEnd("products", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwProducts.DataBind()
        litProducts.Text = numTotalResult
        If numTotalResult > 0 Then pnlProducts.Visible = True : blnResultExist = True
        If gvwProducts.PageCount < 2 Then gvwProducts.AllowPaging = False

        gvwVersions.DataSource = KartrisDBBLL._SearchBackEnd("versions", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwVersions.DataBind()
        litVersions.Text = numTotalResult
        If numTotalResult > 0 Then pnlVersions.Visible = True : blnResultExist = True
        If gvwVersions.PageCount < 2 Then gvwVersions.AllowPaging = False

        gvwCustomers.DataSource = KartrisDBBLL._SearchBackEnd("customers", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwCustomers.DataBind()
        litCustomers.Text = numTotalResult
        If numTotalResult > 0 Then pnlCustomers.Visible = True : blnResultExist = True
        If gvwCustomers.PageCount < 2 Then gvwCustomers.AllowPaging = False

        gvwOrders.DataSource = KartrisDBBLL._SearchBackEnd("orders", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwOrders.DataBind()
        litOrders.Text = numTotalResult
        If numTotalResult > 0 Then pnlOrders.Visible = True : blnResultExist = True
        If gvwOrders.PageCount < 2 Then gvwOrders.AllowPaging = False

        gvwConfig.DataSource = KartrisDBBLL._SearchBackEnd("config", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwConfig.DataBind()
        litConfig.Text = numTotalResult
        If numTotalResult > 0 Then pnlConfig.Visible = True : blnResultExist = True
        If gvwConfig.PageCount < 2 Then gvwConfig.AllowPaging = False

        gvwSite.DataSource = KartrisDBBLL._SearchBackEnd("site", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwSite.DataBind()
        litSiteText.Text = numTotalResult
        If numTotalResult > 0 Then pnlSiteText.Visible = True : blnResultExist = True
        If gvwSite.PageCount < 2 Then gvwSite.AllowPaging = False

        gvwPages.DataSource = KartrisDBBLL._SearchBackEnd("pages", strKey, Session("_LANG"), 0, numPageSize, numTotalResult)
        gvwPages.DataBind()
        litPages.Text = numTotalResult
        If numTotalResult > 0 Then pnlPages.Visible = True : blnResultExist = True
        If gvwPages.PageCount < 2 Then gvwPages.AllowPaging = False

        If Not blnResultExist Then pnlNoResults.Visible = True

        updResults.Update()
    End Sub

    Protected Sub gridView_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        CType(sender, GridView).PageIndex = e.NewPageIndex
        Dim strGridName As String = CType(sender, GridView).ID
        _Search(strGridName.Replace("gvw", "").ToLower, Request.QueryString("key"))
    End Sub

End Class
