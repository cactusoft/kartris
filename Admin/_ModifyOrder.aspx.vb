'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_ModifyOrder
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetLocalResourceObject("PageTitle_EditOrder") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_EditOrder.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        CType(Me.Master, Skins_Admin_Template).LoadTaskList()
    End Sub

End Class
