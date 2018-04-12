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
        tblNewestProducts.Columns.Add(New DataColumn("MinPrice", Type.GetType("System.Decimal")))

        Dim drwNewProducts As DataRow() = ProductsBLL.GetNewestProducts(Session("LANG"))

        Dim numItemCount As Integer = KartSettingsManager.GetKartConfig("frontend.display.newestproducts")

        If numItemCount > drwNewProducts.Length Then numItemCount = drwNewProducts.Length
        For i As Integer = 0 To numItemCount - 1
            tblNewestProducts.Rows.Add(drwNewProducts(i)("P_ID"), drwNewProducts(i)("P_Name"), drwNewProducts(i)("MinPrice"))
        Next

        rptNewestItems.DataSource = tblNewestProducts
        rptNewestItems.DataBind()

        'Hide whole control if no products to show
        If numItemCount = 0 Then Me.Visible = False
    End Sub
End Class
