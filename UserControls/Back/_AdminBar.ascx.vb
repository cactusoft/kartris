'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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
Partial Class UserControls_Back_AdminBar
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If GetKartConfig("general.storestatus") = "open" Then
            lnkFront.CssClass = ""
        Else
            lnkFront.CssClass = "closed"
        End If

        'Set the front/back link to specific URL,
        'overrides the Default link
        SetFrontEndLink()
    End Sub

    Public Sub SetFrontEndLink()
        'Get current URL
        Dim strResolvedURL As String = Context.Request.RawUrl.ToLower

        'Category
        Dim numCategoryID As Long = 0
        Try
            numCategoryID = Request.QueryString("CategoryID")
        Catch ex As Exception
            'Doesn't exist
        End Try
        If numCategoryID > 0 Then
            lnkFront.NavigateUrl = "~/Category.aspx?CategoryID=" & numCategoryID.ToString
        End If

        'Product
        Dim numProductID As Long = 0
        Try
            numProductID = Request.QueryString("ProductID")
        Catch ex As Exception
            'Doesn't exist
        End Try
        If numProductID > 0 Then
            lnkFront.NavigateUrl = "~/Product.aspx?ProductID=" & numProductID.ToString
        End If

        'Basket page
        If strResolvedURL.ToLower.Contains("_createorder.aspx") Or _
            strResolvedURL.ToLower.Contains("_modifyorder.aspx") Then
            lnkFront.NavigateUrl = "~/Basket.aspx"
        End If
    End Sub
End Class
