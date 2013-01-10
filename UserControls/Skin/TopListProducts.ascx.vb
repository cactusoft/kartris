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
Partial Class UserControls_Skin_TopListProducts
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadTopListProducts()
        End If
    End Sub

    Sub LoadTopListProducts()
        Dim tblTopListProducts As New DataTable
        tblTopListProducts.Columns.Add(New DataColumn("P_ID", Type.GetType("System.Int32")))
        tblTopListProducts.Columns.Add(New DataColumn("P_Name", Type.GetType("System.String")))

        Dim intTruncateLength As Integer = CInt(KartSettingsManager.GetKartConfig("frontend.display.topsellers.truncate"))
        Dim drwTopSeller As DataRow() = KartSettingsManager.GetTopListProductsFromCache.Select("LANG_ID=" & Session("LANG"))
        Dim numItemCount As Integer = KartSettingsManager.GetKartConfig("frontend.display.topsellers.quantity")

        If numItemCount > drwTopSeller.Length Then numItemCount = drwTopSeller.Length

        For i As Integer = 0 To numItemCount - 1
            tblTopListProducts.Rows.Add(drwTopSeller(i)("P_ID"), IIf(intTruncateLength > 0, _
                CkartrisDisplayFunctions.TruncateDescription(drwTopSeller(i)("P_Name"), intTruncateLength) _
                    , drwTopSeller(i)("P_Name")))
        Next

        rptTopListProducts.DataSource = tblTopListProducts
        rptTopListProducts.DataBind()
        
    End Sub

End Class
