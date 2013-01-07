'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_Reviews
    Inherits _PageBaseClass

    Protected Sub Page_Load1(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Reviews", "PageTitle_Reviews") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            _UC_ProductReviews.LoadProductReviews()
        End If
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_ProductReviews.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

End Class
