'[[[NEW COPYRIGHT NOTICE]]]
Partial Class UserControls_Front_NavigationMenu
    Inherits System.Web.UI.UserControl

    Protected Sub menFrontEnd_MenuItemDataBound(ByVal sender As Object, ByVal e As MenuEventArgs) Handles menFrontEnd.MenuItemDataBound

        Dim node As SiteMapNode = e.Item.DataItem
        Select Case node.Item("Value")
            Case "support"
                If KartSettingsManager.GetKartConfig("frontend.knowledgebase.enabled") <> "y" AndAlso _
                        KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") <> "y" Then
                    menFrontEnd.Items.Remove(e.Item)
                End If
            Case "news"
                If KartSettingsManager.GetKartConfig("frontend.navigationmenu.sitenews") <> "y" Then menFrontEnd.Items.Remove(e.Item)
            Case "promotions"
                If KartSettingsManager.GetKartConfig("frontend.promotions.enabled") <> "y" Then e.Item.Parent.ChildItems.Remove(e.Item)
            Case "comparison"
                If KartSettingsManager.GetKartConfig("frontend.products.comparison.enabled") <> "y" Then e.Item.Parent.ChildItems.Remove(e.Item)
            Case "knowledgebase"
                If KartSettingsManager.GetKartConfig("frontend.knowledgebase.enabled") <> "y" Then e.Item.Parent.ChildItems.Remove(e.Item)
            Case "supporttickets"
                If KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") <> "y" Then e.Item.Parent.ChildItems.Remove(e.Item)
        End Select
    End Sub


End Class
