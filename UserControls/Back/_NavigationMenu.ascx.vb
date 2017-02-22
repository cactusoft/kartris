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
Partial Class UserControls_Back_NavigationMenu
    Inherits System.Web.UI.UserControl

    Protected Sub menBackEnd_MenuItemDataBound(ByVal sender As Object, ByVal e As MenuEventArgs) Handles menBackEnd.MenuItemDataBound

        If String.IsNullOrEmpty(Session("Back_Auth")) Then
            If e.Item.Parent Is Nothing Then menBackEnd.Items.Remove(e.Item) Else e.Item.Parent.ChildItems.Remove(e.Item)
        Else
            Dim arrAuth As String() = HttpSecureCookie.DecryptValue(Session("Back_Auth"), "Backend Navigation Menu")
            Dim node As SiteMapNode = e.Item.DataItem
            Dim strValue As String = node.Item("Value")
            Dim blnVisible As Boolean = True
            If Not String.IsNullOrEmpty(node("visible")) Then
                If Boolean.TryParse(node("visible"), blnVisible) Then
                    If Not blnVisible Then If e.Item.Parent Is Nothing Then menBackEnd.Items.Remove(e.Item) Else e.Item.Parent.ChildItems.Remove(e.Item)
                End If
            End If
            If blnVisible Then
                Select Case strValue
                    Case "orders"
                        Dim blnOrders As Boolean = arrAuth(3)
                        If Not blnOrders Then
                            If e.Item.Parent Is Nothing Then menBackEnd.Items.Remove(e.Item) Else e.Item.Parent.ChildItems.Remove(e.Item)
                        End If
                    Case "products"
                        Dim blnProducts As Boolean = arrAuth(2)
                        If Not blnProducts Then
                            If e.Item.Parent Is Nothing Then menBackEnd.Items.Remove(e.Item) Else e.Item.Parent.ChildItems.Remove(e.Item)
                        End If
                    Case "config"
                        Dim blnConfig As Boolean = arrAuth(1)
                        If Not blnConfig Then
                            If e.Item.Parent Is Nothing Then menBackEnd.Items.Remove(e.Item) Else e.Item.Parent.ChildItems.Remove(e.Item)
                        End If
                    Case "support"
                        Dim blnSupport As Boolean = CBool(arrAuth(8))
                        If Not blnSupport Then
                            If e.Item.Parent Is Nothing Then menBackEnd.Items.Remove(e.Item) Else e.Item.Parent.ChildItems.Remove(e.Item)
                        End If
                End Select
            End If
        End If

    End Sub

End Class

