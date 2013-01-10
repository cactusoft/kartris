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
Imports CkartrisImages

''' <summary>
''' Used in Compare.aspx, to view products in a comparison table, the products to be compared are 
'''   read from Session Item Named "ProductsToCompare"
''' </summary>
''' <remarks></remarks>
Partial Class ProductCompare
    Inherits System.Web.UI.UserControl

    '' Class attributes to hold the Product's info. to be compared, and the list of execluded attributes.
    Private c_tblProductsToCompare As New DataTable()
    Private c_strNotIncludedAttributeList As String()

    ''' <summary>
    ''' Loads the products to be compared.
    ''' </summary>
    ''' <param name="pTblProductsToCompare"></param>
    ''' <param name="pNotIncludedAttributeList"></param>
    ''' <remarks></remarks>
    Public Sub LoadProductComparison(ByVal pTblProductsToCompare As DataTable, ByVal pNotIncludedAttributeList As String())

        '' Copying the table of "ProductsToCompare" into the class datatable, 
        ''   so it could be used to get read the attributes for each product.
        c_tblProductsToCompare = pTblProductsToCompare.Copy()

        '' Getting the Execluded Attributes
        c_strNotIncludedAttributeList = pNotIncludedAttributeList

        '' Getting the ProductsToCompare session variable, and filter it from the left & right parentheses
        ''  so, it could be sent to the stored procedure as a coma separated string of products to be processed.
        Dim strProductList As String
        strProductList = Session("ProductsToCompare")
        strProductList = strProductList.Replace("(", "")
        strProductList = strProductList.Replace(")", "")

        Dim numCGroupID As Short = 0
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            numCGroupID = CShort(DirectCast(Page, PageBaseClass).CurrentLoggedUser.CustomerGroupID)
        End If

        '' Get the ID, Name, and MinPrice for each product in the session variable "ProductsToCompare"
        Dim tblProducts As DataTable
        tblProducts = VersionsBLL.GetMinPriceByProductList(strProductList, Session("LANG"), numCGroupID)

        '' Bind the resulted dataTable to the repeater that will hold the ProductName, Pic. & its Price.
        rptCompareProducts.DataSource = tblProducts
        rptCompareProducts.DataBind()

    End Sub

    Protected Sub rptCompareProducts_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptCompareProducts.ItemDataBound

        For Each ctlItem As Control In e.Item.Controls
            Select Case ctlItem.ID
                Case "UC_ImageViewer"
                    CType(e.Item.FindControl("UC_ImageViewer"), ImageViewer).CreateImageViewer(IMAGE_TYPE.enum_ProductImage, _
                        CType(e.Item.FindControl("litP_ID"), Literal).Text, _
                        KartSettingsManager.GetKartConfig("frontend.display.images.thumb.height"), _
                        KartSettingsManager.GetKartConfig("frontend.display.images.thumb.width"), _
                        SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, CType(e.Item.FindControl("litP_ID"), Literal).Text), _
                        "")

                Case "UC_ProductCompareValues"
                    '' If the Item is an instance of ProductCompareValues, then load the attributes for that product.
                    CType(e.Item.FindControl("UC_ProductCompareValues"), ProductCompareValues).LoadProductComparisonValues( _
                    CInt(CType(e.Item.FindControl("litP_ID"), Literal).Text), c_tblProductsToCompare, Session("LANG"), c_strNotIncludedAttributeList)

                Case "lnkRemove"
                    '' If the Item is the remove link under the product, then generate its remove NavigationURL String.
                    Dim strProductID As String
                    strProductID = CType(e.Item.FindControl("litP_ID"), Literal).Text
                    Dim strRemoveURL As String = Request.Url.ToString.ToLower()

                    '' As a remove link, we need to remove the product from the compared products,
                    '' so need to send a (del) as action to be taken.
                    If strRemoveURL.Contains("action=add") Then
                        strRemoveURL = strRemoveURL.Replace("action=add", "action=del")
                    Else
                        If strRemoveURL.Contains("action=del") Then
                            'already have action=del, so do nothing
                        Else
                            strRemoveURL = strRemoveURL.Replace(".aspx", ".aspx?action=del")
                        End If
                    End If

                    '' Changing the value of (id) query string key to hold the id of the product
                    '' to be removed from comaprison. If no id, add it.
                    If strRemoveURL.Contains("&id=") Then
                        strRemoveURL = strRemoveURL.Replace("&id=" & Request.QueryString("id"), "&id=" & strProductID)
                    Else
                        strRemoveURL = strRemoveURL.Replace(".aspx?action=del", ".aspx?action=del&id=" & strProductID)
                    End If


                    '' Assigning the generated URL String to the remove link.
                    CType(e.Item.FindControl("lnkRemove"), HyperLink).NavigateUrl = strRemoveURL
                Case "lnkProductName"
                    CType(e.Item.FindControl("lnkProductName"), HyperLink).NavigateUrl = _
                        SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, CType(e.Item.FindControl("litP_ID"), Literal).Text)
                Case Else

            End Select
        Next

    End Sub
End Class
