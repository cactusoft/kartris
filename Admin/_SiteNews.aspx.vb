'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_SiteNews

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_News", "PageTitle_FrontNewsItems") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            If KartSettingsManager.GetKartConfig("frontend.navigationmenu.sitenews") <> "y" Then
                litFeatureDisabled.Text = Replace( _
                    GetGlobalResourceObject("_Kartris", "ContentText_DisabledInFrontEnd"), "[name]", _
                    GetGlobalResourceObject("_News", "PageTitle_FrontNewsItems"))
                phdFeatureDisabled.Visible = True
            Else
                phdFeatureDisabled.Visible = False
            End If
        End If
    End Sub
End Class
