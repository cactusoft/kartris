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
Imports System.Linq
Imports KartSettingsManager
Imports CkartrisDataManipulation

Partial Class UserControls_Skin_FeaturedProducts
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If CInt(GetKartConfig("frontend.featuredproducts.display.max")) = 0 Then Me.Visible = False
        LoadFeaturedProducts()

    End Sub

    Private Sub LoadFeaturedProducts()
        Dim drwFeaturedProducts As DataRow()
        drwFeaturedProducts = ProductsBLL.GetFeaturedProducts(Session("LANG"))

        Dim tblFeaturedProducts As New DataTable
        With tblFeaturedProducts.Columns
            .Add(New DataColumn("P_ID", Type.GetType("System.Int32")))
            .Add(New DataColumn("P_Name", Type.GetType("System.String")))
            .Add(New DataColumn("P_Desc", Type.GetType("System.String")))

            .Add(New DataColumn("P_OrderVersionsBy", Type.GetType("System.String")))
            .Add(New DataColumn("P_VersionsSortDirection", Type.GetType("System.String")))
            .Add(New DataColumn("P_VersionDisplayType", Type.GetType("System.String")))
            .Add(New DataColumn("P_Type", Type.GetType("System.String")))
            .Add(New DataColumn("P_PageTitle", Type.GetType("System.String")))
            .Add(New DataColumn("P_Reviews", Type.GetType("System.String")))
            .Add(New DataColumn("P_Featured", Type.GetType("System.Int32")))
            .Add(New DataColumn("P_CustomerGroupID", Type.GetType("System.Int32")))
            .Add(New DataColumn("MinPrice", Type.GetType("System.Single")))
            .Add(New DataColumn("MinTaxRate", Type.GetType("System.Single")))

            .Add(New DataColumn("P_StrapLine", Type.GetType("System.String")))
            .Add(New DataColumn("LANG_ID", Type.GetType("System.Int32")))
        End With

        Dim numMaxNumberToDisplay As Integer = CInt(GetKartConfig("frontend.featuredproducts.display.max"))
        For i As Integer = 0 To drwFeaturedProducts.Length - 1
            Dim numMinPrice As Single = FixNullFromDB(drwFeaturedProducts(i)("MinPrice"))
            If Page.User.Identity.IsAuthenticated AndAlso CType(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID <> 0 Then
                numMinPrice = ProductsBLL.GetMinPriceByCG(drwFeaturedProducts(i)("P_ID"), _
                                                          CType(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID)
            End If
            tblFeaturedProducts.Rows.Add(drwFeaturedProducts(i)("P_ID"), _
                                         drwFeaturedProducts(i)("P_Name"), _
                                         drwFeaturedProducts(i)("P_Desc"), _
                                         drwFeaturedProducts(i)("P_OrderVersionsBy"), _
                                         drwFeaturedProducts(i)("P_VersionsSortDirection"), _
                                         drwFeaturedProducts(i)("P_VersionDisplayType"), _
                                         drwFeaturedProducts(i)("P_Type"), _
                                         drwFeaturedProducts(i)("P_PageTitle"), _
                                         drwFeaturedProducts(i)("P_Reviews"), _
                                         drwFeaturedProducts(i)("P_Featured"), _
                                         drwFeaturedProducts(i)("P_CustomerGroupID"), _
                                         CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), _
                                         numMinPrice), _
                                         drwFeaturedProducts(i)("MinTax"), _
                                         drwFeaturedProducts(i)("P_StrapLine"))

            If tblFeaturedProducts.Rows.Count = numMaxNumberToDisplay Then Exit For

        Next
        If tblFeaturedProducts.Rows.Count > 0 Then
            tblFeaturedProducts.DefaultView.Sort = "P_Featured DESC"
        Else
            'No products, hide whole control
            Me.Visible = False
        End If

        'Choose template for products based on
        'the config setting
        Select Case GetKartConfig("frontend.featuredproducts.display.default")
            Case "n"
                rptNormal.DataSource = tblFeaturedProducts
                rptNormal.DataBind()
                mvwFeaturedProducts.SetActiveView(viwNormal)
            Case "e"
                rptExtended.DataSource = tblFeaturedProducts
                rptExtended.DataBind()
                mvwFeaturedProducts.SetActiveView(viwExtended)
            Case "s"
                rptShortened.DataSource = tblFeaturedProducts
                rptShortened.DataBind()
                mvwFeaturedProducts.SetActiveView(viwShortened)
            Case "t"
                rptTabular.DataSource = tblFeaturedProducts
                rptTabular.DataBind()
                mvwFeaturedProducts.SetActiveView(viwTabular)
            Case Else
                'litGroupName.Visible = False
        End Select

    End Sub
End Class
