'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Front_NavigationMenu
    Inherits System.Web.UI.UserControl

    Protected Sub menFrontEnd_MenuItemDataBound(ByVal sender As Object, ByVal e As MenuEventArgs) Handles menFrontEnd.MenuItemDataBound

        Dim node As SiteMapNode = e.Item.DataItem
        Select Case node.Item("Value")
            Case "support"
                If KartSettingsManager.GetKartConfig("frontend.knowledgebase.enabled") <> "y" AndAlso _
                        KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") <> "y" Then
                    Try
                        menFrontEnd.Items.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                    Try
                        e.Item.Parent.ChildItems.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                End If
            Case "news"
                If KartSettingsManager.GetKartConfig("frontend.navigationmenu.sitenews") <> "y" Then
                    Try
                        menFrontEnd.Items.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                    Try
                        e.Item.Parent.ChildItems.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                End If
            Case "promotions"
                If KartSettingsManager.GetKartConfig("frontend.promotions.enabled") <> "y" Then
                    Try
                        menFrontEnd.Items.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                    Try
                        e.Item.Parent.ChildItems.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                End If
            Case "comparison"
                If KartSettingsManager.GetKartConfig("frontend.products.comparison.enabled") <> "y" Then
                    Try
                        menFrontEnd.Items.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                    Try
                        e.Item.Parent.ChildItems.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                End If
            Case "knowledgebase"
                If KartSettingsManager.GetKartConfig("frontend.knowledgebase.enabled") <> "y" Then
                    Try
                        menFrontEnd.Items.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                    Try
                        e.Item.Parent.ChildItems.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                End If
            Case "supporttickets"
                If KartSettingsManager.GetKartConfig("frontend.supporttickets.enabled") <> "y" Then
                    Try
                        menFrontEnd.Items.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                    Try
                        e.Item.Parent.ChildItems.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                End If
            Case "wishlist"
                If KartSettingsManager.GetKartConfig("frontend.users.wishlists.enabled") <> "y" Then
                    Try
                        menFrontEnd.Items.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                    Try
                        e.Item.Parent.ChildItems.Remove(e.Item)
                    Catch ex As Exception
                        'item not found
                    End Try
                End If
        End Select
    End Sub


End Class
