'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_OptionGroups
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Options", "PageTitle_OptionGroups") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            _UC_OptionGroup.ShowOptionGroups()
        End If
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_OptionGroup.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
