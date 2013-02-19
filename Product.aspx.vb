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
Imports CkartrisDataManipulation

Partial Class Product
    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim strCurrentPath As String = Request.RawUrl.ToString.ToLower

        'We set a value to keep track of any trapped
        'error handled, this way, we can avoid throwing
        'a generic error on top of the handled one.
        Dim strErrorThrown As String = ""

        If Not (InStr(strCurrentPath, "/skins/") > 0 Or InStr(strCurrentPath, "/javascript/") > 0 Or InStr(strCurrentPath, "/images/") > 0) Then
            Try
                Dim intProductID As Integer = Request.QueryString("ProductID")

                Dim numLangID As Short = CShort(Session("LANG"))
                UC_ProductView.LoadProduct(intProductID, numLangID)

                If UC_ProductView.IsProductExist Then

                    If Not Page.IsPostBack Then
                        If KartSettingsManager.GetKartConfig("general.products.hittracking") = "y" Then StatisticsBLL.AddNewStatsRecord("P", GetIntegerQS("ProductID"), GetIntegerQS("strParent"))
                        Session("RecentProducts") = Session("RecentProducts") & GetIntegerQS("ProductID") & "~~~~" & _
                        Server.HtmlDecode(UC_ProductView.ProductName) & "||||"

                        'Above we use four hashes or pipes because these should not occur naturally in product names
                        If intProductID > 0 Then
                            Me.CanonicalTag = SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, intProductID)
                            Me.MetaDescription = ProductsBLL.GetMetaDescriptionByProductID(intProductID, numLangID)
                            Me.MetaKeywords = ProductsBLL.GetMetaKeywordsByProductID(intProductID, numLangID)
                        End If
                    End If
                Else
                    'An item was called with correctly formatted URL, but
                    'the ID doesn't appear to pull out an item, so it's
                    'likely the item is no longer available.
                    strErrorThrown = "404"
                    HttpContext.Current.Server.Transfer("~/404.aspx")
                End If
            Catch ex As Exception
                'Some other error occurred - it seems the ID of the item
                'exists, but loading or displaying the item caused some
                'other error.
                CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If strErrorThrown = "" Then HttpContext.Current.Server.Transfer("~/Error.aspx")
            End Try
        End If
    End Sub

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        If Session("NewBasketItem") = 1 Then
            Dim MiniBasket As Object = Master.FindControl("UC_MiniBasket")
            MiniBasket.LoadMiniBasket()
            Session("NewBasketItem") = 0
        End If
    End Sub
End Class
