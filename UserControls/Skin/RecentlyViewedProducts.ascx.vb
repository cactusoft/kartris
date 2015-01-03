'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

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

Partial Class UserControls_Skin_RecentlyViewedProducts
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If CInt(GetKartConfig("frontend.display.recentproducts")) = 0 Then
            Me.Visible = False
        End If

        If Not Page.IsPostBack Then
            Try

                Dim tblRecentlyViewedProducts As New DataTable
                tblRecentlyViewedProducts.Columns.Add(New DataColumn("P_ID", Type.GetType("System.Int32")))
                tblRecentlyViewedProducts.Columns.Add(New DataColumn("P_Name", Type.GetType("System.String")))

                Dim arrRecentProducts() As String = CStr(Session("RecentProducts")).Split("||||")
                Dim numMaxProductsToDisplay As Integer = 0
                If IsNumeric(GetKartConfig("frontend.display.recentproducts")) Then numMaxProductsToDisplay = CInt(GetKartConfig("frontend.display.recentproducts"))
                If numMaxProductsToDisplay = 0 Then numMaxProductsToDisplay = 100
                Dim arrAddedProducts(numMaxProductsToDisplay - 1) As Integer, numCounter As Integer = 0
                For i = arrRecentProducts.Length - 1 To 0 Step -1

                    If Not String.IsNullOrEmpty(arrRecentProducts(i)) AndAlso arrRecentProducts(i).Contains("~~~~") Then
                        Dim arrProduct() As String = arrRecentProducts(i).Split("~~~~")
                        If arrAddedProducts.Contains(arrProduct(0)) OrElse arrProduct(0) = GetIntegerQS("P_ID") Then Continue For

                        If IsNumeric(arrProduct(0)) AndAlso arrProduct(0) > 0 Then

                            tblRecentlyViewedProducts.Rows.Add(arrProduct(0), arrProduct(4))
                            arrAddedProducts(numCounter) = arrProduct(0)
                            numCounter += 1
                        End If
                        If tblRecentlyViewedProducts.Rows.Count = numMaxProductsToDisplay Then Exit For
                    End If
                Next

                If tblRecentlyViewedProducts.Rows.Count = 0 Then
                    Me.Visible = False
                    Exit Sub
                End If
                rptRecentViewedProducts.DataSource = tblRecentlyViewedProducts.DefaultView
                rptRecentViewedProducts.DataBind()
            Catch ex As Exception
                'This could happen if for example a product is deleted
                'by the store owner while is on your recent products
                'session. Just clear session in this case, it's not
                'so important that we need to keep it.
                Session("RecentProducts") = String.Empty
            End Try

        End If
    End Sub

    Protected Sub rptRecentViewedProducts_ItemDataBound(ByVal Sender As Object, ByVal e As RepeaterItemEventArgs) Handles rptRecentViewedProducts.ItemDataBound
        If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
            Try
                CType(e.Item.FindControl("lnkRecentlyViewed"), HyperLink).NavigateUrl = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, CType(e.Item.DataItem, DataRowView)("P_ID"))
            Catch ex As Exception
                'must be image view, link not visible
            End Try

        End If
    End Sub
End Class
