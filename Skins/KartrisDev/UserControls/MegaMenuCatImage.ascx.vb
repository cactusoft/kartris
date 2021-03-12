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
Partial Class MegaMenuCatImage

    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'If Not Me.IsPostBack Then
        FormatTopMenu()
        'End If

    End Sub


    ''' <summary>
    ''' Formats the top level category menu
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub FormatTopMenu()
        Dim tblCategories As New DataTable

        'Saving the current page's subcategories in tblCategories, depending on the pageIndex "CPGR"
        tblCategories = CategoriesBLL.GetCategoriesPageByParentID(0, Session("LANG"), 0,
                                        100, 0, 1000)

        If tblCategories.Rows.Count <> 0 Then
            rptTopCats.DataSource = tblCategories
            rptTopCats.DataBind()
        End If
    End Sub

    ''' <summary>
    ''' Format the category menu friendly links
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub rptTopCats_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptTopCats.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            Dim lnkTopLevel As HyperLink = e.Item.FindControl("lnkTopLevel")
            Dim rptMegaMenu As Repeater = e.Item.FindControl("rptMegaMenu")
            Dim numCAT_ID As Integer = lnkTopLevel.NavigateUrl

            lnkTopLevel.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category,
                                        numCAT_ID)

            'Create the submenu
            FormatSubMenu(numCAT_ID, rptMegaMenu)
        End If
    End Sub

    ''' <summary>
    ''' Formats the subcategory menu
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub FormatSubMenu(ByVal numSubCatID As Integer, ByVal rptMegaMenu As Repeater)
        AddHandler rptMegaMenu.ItemDataBound, AddressOf rptMegaMenu_ItemDataBound

        Dim tblSubCategories As New DataTable

        'Saving the current page's subcategories in tblCategories, depending on the pageIndex "CPGR"
        tblSubCategories = CategoriesBLL.GetCategoriesPageByParentID(numSubCatID, Session("LANG"), 0,
                                        100, 0, 1000)

        'Add the subcat ID as a parent value to subcats data, so we can pull it out and use
        'it later to format better URLs that show parent
        Dim newColumn As New Data.DataColumn("ParentID", GetType(System.Int32))
        newColumn.DefaultValue = numSubCatID
        tblSubCategories.Columns.Add(newColumn)

        If tblSubCategories.Rows.Count <> 0 Then
            rptMegaMenu.DataSource = tblSubCategories
            rptMegaMenu.DataBind()
        End If
    End Sub

    ''' <summary>
    ''' Format the category menu friendly links
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub rptMegaMenu_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs)

        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then

            'Find and create controls
            Dim lnkSubCat As HyperLink = e.Item.FindControl("lnkSubCat")
            Dim hidParentID As HiddenField = e.Item.FindControl("hidParentID")
            Dim imgSubCat As Image = e.Item.FindControl("imgSubCat")

            'Pull values 
            Dim numSubCAT_ID As Integer = lnkSubCat.NavigateUrl
            Dim numParentID As Integer = hidParentID.Value

            'Set properties for links, etc.
            lnkSubCat.NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.Category,
                                        numSubCAT_ID, numParentID)
            imgSubCat.ImageUrl = "~/Image.ashx?strItemType=c&numMaxHeight=50&numMaxWidth=50&numItem=" & numSubCAT_ID

        End If
    End Sub
End Class

