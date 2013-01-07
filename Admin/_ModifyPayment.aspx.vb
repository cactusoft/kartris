'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_ModifyPayment
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Payments", "PageTitle_EditPayment") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub
    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        If Request.QueryString("s") = "update" Then ShowMasterUpdateMessage()
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_EditPayment.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        CType(Me.Master, Skins_Admin_Template).LoadTaskList()
    End Sub
End Class
