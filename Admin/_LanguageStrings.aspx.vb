'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_LanguageStrings
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Kartris", "BackMenu_LanguageStrings") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
        If Not Request.QueryString("_PPGR") Is Nothing Then conTabs.ActiveTab = tabStringsTranslation
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_LanguageStrings.ShowMasterUpdate, _UC_LSTranslation.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
