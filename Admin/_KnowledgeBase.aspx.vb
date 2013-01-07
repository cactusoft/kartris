'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_KnowledgeBase
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Knowledgebase", "PageTitle_KnowledgeBase") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            If KartSettingsManager.GetKartConfig("frontend.knowledgebase.enabled") <> "y" Then
                litFeatureDisabled.Text = Replace( _
                    GetGlobalResourceObject("_Kartris", "ContentText_DisabledInFrontEnd"), "[name]", _
                    GetGlobalResourceObject("_Knowledgebase", "PageTitle_KnowledgeBase"))
                phdFeatureDisabled.Visible = True
            Else
                phdFeatureDisabled.Visible = False
            End If
        End If
    End Sub
    Protected Sub ShowMasterUpdateMessage() Handles _UC_KB.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
