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
Partial Class UserControls_Skin_NewestItems
    Inherits System.Web.UI.UserControl


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadNewestProducts()
        End If
    End Sub

    Sub LoadNewestProducts()
        Dim tblNewestProducts As New DataTable
        tblNewestProducts.Columns.Add(New DataColumn("P_ID", Type.GetType("System.Int32")))
        tblNewestProducts.Columns.Add(New DataColumn("P_Name", Type.GetType("System.String")))

        Dim drwNewProducts As DataRow() = ProductsBLL.GetNewestProducts(Session("LANG"))

        Dim numItemCount As Integer = KartSettingsManager.GetKartConfig("frontend.display.newestproducts")

        If numItemCount > drwNewProducts.Length Then numItemCount = drwNewProducts.Length
        For i As Integer = 0 To numItemCount - 1
            tblNewestProducts.Rows.Add(drwNewProducts(i)("P_ID"), drwNewProducts(i)("P_Name"))
        Next

        rptNewestItems.DataSource = tblNewestProducts
        rptNewestItems.DataBind()

    End Sub

    'Protected Sub rptNewestItems_ItemDataBound(ByVal Sender As Object, ByVal e As RepeaterItemEventArgs) Handles rptNewestItems.ItemDataBound
    '    If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
    '        CType(e.Item.FindControl("lnkProduct"), HyperLink).NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, CType(e.Item.DataItem, DataRowView).Item(0))
    '    End If
    'End Sub
End Class
