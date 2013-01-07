'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_StockWarning

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_StockLevel", "PageTitle_StockLevelWarnings") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub _UC_StockWarning_ShowMasterUpdate() Handles _UC_StockWarning.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
