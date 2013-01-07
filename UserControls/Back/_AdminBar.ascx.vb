'[[[NEW COPYRIGHT NOTICE]]]
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

        Dim numProductID As Long = 0
        Try
            numProductID = Request.QueryString("ProductID")
        Catch ex As Exception
            'Doesn't exist
        End Try
        If numProductID > 0 Then
            lnkFront.NavigateUrl = "~/Product.aspx?ProductID=" & numProductID.ToString
        End If
    End Sub
End Class
