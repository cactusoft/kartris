'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_ModifyCustomerStatus
    Inherits _PageBaseClass

    Protected Sub ShowMasterUpdateMessage()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetLocalResourceObject("PageTitle_CustomerDetails") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub _UC_UserDetails__UCEvent_DataUpdated() Handles _UC_UserDetails._UCEvent_DataUpdated
        ShowMasterUpdateMessage()
    End Sub
End Class
