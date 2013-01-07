'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Promotions
    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If KartSettingsManager.GetKartConfig("frontend.promotions.enabled") = "y" Then
            Page.Title = GetGlobalResourceObject("Kartris", "SubHeading_Promotions") & " | " & Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))
            UC_Promotions.LoadAllPromotions(Session("LANG"))
        Else
            mvwMain.SetActiveView(viwNotExist)
        End If
    End Sub
End Class
