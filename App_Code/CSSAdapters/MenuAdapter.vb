Imports System
Imports System.Collections
Imports System.Reflection
Imports System.IO
Imports System.Web
Imports System.Web.Configuration
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.HtmlControls

Namespace Kartris
    Public Class MenuAdapter
        Inherits System.Web.UI.WebControls.Adapters.MenuAdapter
        Private _extender As WebControlAdapterExtender = Nothing
        Private ReadOnly Property Extender() As WebControlAdapterExtender
            Get
                If ((_extender Is Nothing) AndAlso (Control IsNot Nothing)) OrElse ((_extender IsNot Nothing) AndAlso (Control IsNot _extender.AdaptedControl)) Then
                    _extender = New WebControlAdapterExtender(Control)
                End If

                System.Diagnostics.Debug.Assert(_extender IsNot Nothing, "CSS Friendly adapters internal error", "Null extender instance")
                Return _extender
            End Get
        End Property

        Protected Overloads Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            If Extender.AdapterEnabled Then
                RegisterScripts()
            End If
        End Sub

        Private Sub RegisterScripts()
            Extender.RegisterScripts()

            Dim folderPath As String = WebConfigurationManager.AppSettings.Get("CSSFriendly-JavaScript-Path")
            If (String.IsNullOrEmpty(folderPath)) Then
                folderPath = "~/JavaScript"
            End If

            Dim filePath As String = IIf(folderPath.EndsWith("/"), folderPath & "MenuAdapter.js", folderPath & "/MenuAdapter.js")
            Page.ClientScript.RegisterClientScriptInclude(Me.GetType(), Me.GetType().ToString(), Page.ResolveUrl(filePath))
        End Sub

        Protected Overloads Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderBeginTag(writer, "KartrisMenu-" + Control.Orientation.ToString())
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub

        Protected Overloads Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderEndTag(writer)
            Else
                MyBase.RenderEndTag(writer)
            End If
        End Sub

        Protected Overloads Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                writer.Indent += 1
                BuildItems(Control.Items, True, writer)
                writer.Indent -= 1
                writer.WriteLine()
            Else
                MyBase.RenderContents(writer)
            End If
        End Sub

        Private Sub BuildItems(ByVal items As MenuItemCollection, ByVal isRoot As Boolean, ByVal writer As HtmlTextWriter)
            If items.Count > 0 Then
                writer.WriteLine()

                writer.WriteBeginTag("ul")
                If isRoot Then
                    writer.WriteAttribute("class", "KartrisMenu")
                Else
                    writer.WriteAttribute("class", "KartrisSubMenu dropdown")
                End If
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent += 1

                For Each item As MenuItem In items
                    BuildItem(item, writer)
                Next

                writer.Indent -= 1
                writer.WriteLine()
                writer.WriteEndTag("ul")
            End If
        End Sub

        Private Sub BuildItem(ByVal item As MenuItem, ByVal writer As HtmlTextWriter)
            Dim menu As Menu = TryCast(Control, Menu)
            If (menu IsNot Nothing) AndAlso (item IsNot Nothing) AndAlso (writer IsNot Nothing) Then
                writer.WriteLine()
                writer.WriteBeginTag("li")

                Dim theClass As String = IIf((item.ChildItems.Count > 0), "KartrisMenu-WithChildren has-dropdown", "KartrisMenu-Leaf")
                Dim selectedStatusClass As String = GetSelectStatusClass(item)
                If Not [String].IsNullOrEmpty(selectedStatusClass) Then
                    theClass += " " + selectedStatusClass
                End If
                writer.WriteAttribute("class", theClass)

                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Indent += 1
                writer.WriteLine()

                If ((item.Depth < menu.StaticDisplayLevels) AndAlso (menu.StaticItemTemplate IsNot Nothing)) OrElse ((item.Depth >= menu.StaticDisplayLevels) AndAlso (menu.DynamicItemTemplate IsNot Nothing)) Then
                    writer.WriteBeginTag("div")
                    writer.WriteAttribute("class", GetItemClass(menu, item))
                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Indent += 1
                    writer.WriteLine()

                    Dim container As New MenuItemTemplateContainer(menu.Items.IndexOf(item), item)
                    'added to solve the <a href='<%# Eval("Text")%>'> binding problem
                    'http://forums.asp.net/t/1069719.aspx
                    'http://msdn2.microsoft.com/en-us/library/system.web.ui.control.bindingcontainer.aspx
                    'The BindingContainer property is the same as the NamingContainer property, 
                    'except when the control is part of a template. In that case, the BindingContainer 
                    'property is set to the Control that defines the template.
                    menu.Controls.Add(container)

                    If (item.Depth < menu.StaticDisplayLevels) AndAlso (menu.StaticItemTemplate IsNot Nothing) Then
                        menu.StaticItemTemplate.InstantiateIn(container)
                    Else
                        menu.DynamicItemTemplate.InstantiateIn(container)
                    End If
                    container.DataBind()
                    'Databinding must occurs before rendering
                    container.RenderControl(writer)
                    writer.Indent -= 1
                    writer.WriteLine()
                    writer.WriteEndTag("div")
                Else
                    If IsLink(item) Then
                        writer.WriteBeginTag("a")
                        If Not [String].IsNullOrEmpty(item.NavigateUrl) Then
                            writer.WriteAttribute("href", Page.Server.HtmlEncode(menu.ResolveClientUrl(item.NavigateUrl)))
                        Else
                            writer.WriteAttribute("href", Page.ClientScript.GetPostBackClientHyperlink(menu, "b" + item.ValuePath.Replace(menu.PathSeparator.ToString(), "\"), True))
                        End If

                        writer.WriteAttribute("class", GetItemClass(menu, item))
                        WebControlAdapterExtender.WriteTargetAttribute(writer, item.Target)

                        If Not [String].IsNullOrEmpty(item.ToolTip) Then
                            writer.WriteAttribute("title", item.ToolTip)
                        ElseIf Not [String].IsNullOrEmpty(menu.ToolTip) Then
                            writer.WriteAttribute("title", menu.ToolTip)
                        End If
                        'Optionally, depending on the config settings, we
                        'can write a unique ID to each menu link. This makes
                        'it possible to write special CSS styles for any
                        'particular link in the menu. Keep turned off if not
                        'using this feature to keep page size down.
                        If KartSettingsManager.GetKartConfig("frontend.navigationmenu.cssids") = "y" Then
                            writer.WriteAttribute("id", ((item.Text).Replace(" ", "")).Replace("&", ""))
                        End If
                        writer.Write(HtmlTextWriter.TagRightChar)
                            writer.Indent += 1
                            writer.WriteLine()
                        Else
                            writer.WriteBeginTag("span")
                        writer.WriteAttribute("class", GetItemClass(menu, item))
                        writer.Write(HtmlTextWriter.TagRightChar)
                        writer.Indent += 1
                        writer.WriteLine()
                    End If

                    If Not [String].IsNullOrEmpty(item.ImageUrl) Then
                        writer.WriteBeginTag("img")
                        writer.WriteAttribute("src", menu.ResolveClientUrl(item.ImageUrl))
                        writer.WriteAttribute("alt", IIf(Not [String].IsNullOrEmpty(item.ToolTip), item.ToolTip, (IIf(Not [String].IsNullOrEmpty(menu.ToolTip), menu.ToolTip, item.Text))))
                        writer.Write(HtmlTextWriter.SelfClosingTagEnd)
                    End If

                    writer.Write(HttpUtility.HtmlEncode(item.Text))

                    If IsLink(item) Then
                        writer.Indent -= 1
                        writer.WriteEndTag("a")
                    Else
                        writer.Indent -= 1
                        writer.WriteEndTag("span")

                    End If
                End If

                If (item.ChildItems IsNot Nothing) AndAlso (item.ChildItems.Count > 0) Then
                    BuildItems(item.ChildItems, False, writer)
                End If

                writer.Indent -= 1
                writer.WriteLine()
                writer.WriteEndTag("li")
            End If
        End Sub

        Protected Overridable Function IsLink(ByVal item As MenuItem) As Boolean
            Return (item IsNot Nothing) AndAlso item.Enabled AndAlso ((Not [String].IsNullOrEmpty(item.NavigateUrl)) OrElse item.Selectable)
        End Function

        Private Function GetItemClass(ByVal menu As Menu, ByVal item As MenuItem) As String
            Dim value As String = "KartrisMenu-NonLink"
            If item IsNot Nothing Then
                If ((item.Depth < menu.StaticDisplayLevels) AndAlso (menu.StaticItemTemplate IsNot Nothing)) OrElse ((item.Depth >= menu.StaticDisplayLevels) AndAlso (menu.DynamicItemTemplate IsNot Nothing)) Then
                    value = "KartrisMenu-Template"
                ElseIf IsLink(item) Then
                    value = "KartrisMenu-Link"
                End If
                Dim selectedStatusClass As String = GetSelectStatusClass(item)
                If Not [String].IsNullOrEmpty(selectedStatusClass) Then
                    value += " " + selectedStatusClass
                End If
            End If
            Return value
        End Function

        Private Function GetSelectStatusClass(ByVal item As MenuItem) As String
            Dim value As String = ""
            If item.Selected Then
                value += " KartrisMenu-Selected"
            ElseIf IsChildItemSelected(item) Then
                value += " KartrisMenu-ChildSelected"
            ElseIf IsParentItemSelected(item) Then
                value += " KartrisMenu-ParentSelected"
            End If
            Return value
        End Function

        Private Function IsChildItemSelected(ByVal item As MenuItem) As Boolean
            Dim bRet As Boolean = False

            If (item IsNot Nothing) AndAlso (item.ChildItems IsNot Nothing) Then
                bRet = IsChildItemSelected(item.ChildItems)
            End If

            Return bRet
        End Function

        Private Function IsChildItemSelected(ByVal items As MenuItemCollection) As Boolean
            Dim bRet As Boolean = False

            If items IsNot Nothing Then
                For Each item As MenuItem In items
                    If item.Selected OrElse IsChildItemSelected(item.ChildItems) Then
                        bRet = True
                        Exit For
                    End If
                Next
            End If

            Return bRet
        End Function

        Private Function IsParentItemSelected(ByVal item As MenuItem) As Boolean
            Dim bRet As Boolean = False

            If (item IsNot Nothing) AndAlso (item.Parent IsNot Nothing) Then
                If item.Parent.Selected Then
                    bRet = True
                Else
                    bRet = IsParentItemSelected(item.Parent)
                End If
            End If

            Return bRet
        End Function

    End Class
End Namespace

