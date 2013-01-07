'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_Languages
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Language", "PageTitle_Languages") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_SiteLanguages.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
