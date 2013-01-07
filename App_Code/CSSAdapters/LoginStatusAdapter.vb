Imports System
Imports System.Data
Imports System.Collections
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Namespace Kartris
    Public Class LoginStatusAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter

        Protected This As WebControlAdapterExtender = Nothing
        Private _extender As WebControlAdapterExtender = Nothing
        Private ReadOnly Property Extender() As WebControlAdapterExtender
            Get
                If ((IsNothing(_extender) AndAlso (Not IsNothing(Control))) OrElse _
                    ((Not IsNothing(_extender)) AndAlso (Not Control.Equals(_extender.AdaptedControl)))) Then
                    _extender = New WebControlAdapterExtender(Control)
                End If

                System.Diagnostics.Debug.Assert(Not IsNothing(_extender), "CSS Friendly adapters internal error", "Null extender instance")
                Return _extender
            End Get
        End Property

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PROTECTED        

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            If (Extender.AdapterEnabled) Then
                RegisterScripts()
            End If
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                '  The LoginStatus is very simple INPUT or A tag so we don't wrap it with an being/end tag (e.g., no DIV wraps it).
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                '  The LoginStatus is very simple INPUT or A tag so we don't wrap it with an being/end tag (e.g., no DIV wraps it).
            Else
                MyBase.RenderEndTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                Dim loginStatus As LoginStatus = Control
                If (Not IsNothing(loginStatus)) Then
                    Dim className As String = IIf(Not String.IsNullOrEmpty(loginStatus.CssClass), "Kartris-LoginStatus " & loginStatus.CssClass, "Kartris-LoginStatus")
                    If Membership.GetUser() Is Nothing Then
                        If (Not String.IsNullOrEmpty(loginStatus.LoginImageUrl)) Then
                            Dim ctl As Control = loginStatus.FindControl("ctl03")
                            If (Not IsNothing(ctl)) Then
                                writer.WriteBeginTag("input")
                                writer.WriteAttribute("id", loginStatus.ClientID)
                                writer.WriteAttribute("type", "image")
                                writer.WriteAttribute("name", ctl.UniqueID)
                                writer.WriteAttribute("title", loginStatus.ToolTip)
                                writer.WriteAttribute("class", className)
                                writer.WriteAttribute("src", loginStatus.ResolveClientUrl(loginStatus.LoginImageUrl))
                                writer.WriteAttribute("alt", loginStatus.LoginText)
                                writer.Write(HtmlTextWriter.SelfClosingTagEnd)
                                Page.ClientScript.RegisterForEventValidation(ctl.UniqueID)
                            End If
                        Else
                            Dim ctl As Control = loginStatus.FindControl("ctl02")
                            If (Not IsNothing(ctl)) Then
                                writer.WriteBeginTag("a")
                                writer.WriteAttribute("id", loginStatus.ClientID)
                                writer.WriteAttribute("title", loginStatus.ToolTip)
                                writer.WriteAttribute("class", className)
                                writer.WriteAttribute("href", Page.ClientScript.GetPostBackClientHyperlink(loginStatus.FindControl("ctl02"), ""))
                                writer.Write(HtmlTextWriter.TagRightChar)
                                writer.Write(loginStatus.LoginText)
                                writer.WriteEndTag("a")
                                Page.ClientScript.RegisterForEventValidation(ctl.UniqueID)
                            End If
                        End If
                    Else
                        If (Not String.IsNullOrEmpty(loginStatus.LogoutImageUrl)) Then
                            Dim ctl As Control = loginStatus.FindControl("ctl01")
                            If (Not IsNothing(ctl)) Then
                                writer.WriteBeginTag("input")
                                writer.WriteAttribute("id", loginStatus.ClientID)
                                writer.WriteAttribute("type", "image")
                                writer.WriteAttribute("name", ctl.UniqueID)
                                writer.WriteAttribute("title", loginStatus.ToolTip)
                                writer.WriteAttribute("class", className)
                                writer.WriteAttribute("src", loginStatus.ResolveClientUrl(loginStatus.LogoutImageUrl))
                                writer.WriteAttribute("alt", loginStatus.LogoutText)
                                writer.Write(HtmlTextWriter.SelfClosingTagEnd)
                                Page.ClientScript.RegisterForEventValidation(ctl.UniqueID)
                            End If
                        Else
                            Dim ctl As Control = loginStatus.FindControl("ctl00")
                            If (Not IsNothing(ctl)) Then
                                writer.WriteBeginTag("a")
                                writer.WriteAttribute("id", loginStatus.ClientID)
                                writer.WriteAttribute("title", loginStatus.ToolTip)
                                writer.WriteAttribute("class", className)
                                writer.WriteAttribute("href", Page.ClientScript.GetPostBackClientHyperlink(loginStatus.FindControl("ctl00"), ""))
                                writer.Write(HtmlTextWriter.TagRightChar)
                                writer.Write(loginStatus.LogoutText)
                                writer.WriteEndTag("a")
                                Page.ClientScript.RegisterForEventValidation(ctl.UniqueID)
                            End If
                        End If
                    End If
                End If
            Else
                MyBase.RenderContents(writer)
            End If
        End Sub

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PRIVATE        

        Private Sub RegisterScripts()
        End Sub
    End Class
End Namespace
