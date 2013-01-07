Imports System
Imports System.Data
Imports System.Collections
Imports System.Configuration
Imports System.IO
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Namespace Kartris
    Public Class LoginAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter

        Private Enum State
            LoggingIn
            Failed
            Success
        End Enum
        Dim _state As State = State.LoggingIn

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

        Public Sub New()
            _state = State.LoggingIn
        End Sub

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PROTECTED        

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            Dim login As Login = Control
            If (Extender.AdapterEnabled AndAlso (Not IsNothing(login))) Then
                RegisterScripts()

                AddHandler login.LoggedIn, AddressOf OnLoggedIn
                AddHandler login.LoginError, AddressOf OnLoginError
                _state = State.LoggingIn
            End If
        End Sub

        Protected Overrides Sub CreateChildControls()
            MyBase.CreateChildControls()
            Dim login As Login = Control
            If ((Not IsNothing(login)) AndAlso (login.Controls.Count = 1) AndAlso (Not IsNothing(login.LayoutTemplate))) Then
                Dim container As Control = login.Controls(0)
                If (Not IsNothing(container)) Then
                    container.Controls.Clear()
                    login.LayoutTemplate.InstantiateIn(container)
                    container.DataBind()
                End If
            End If
        End Sub

        Protected Sub OnLoggedIn(ByVal sender As Object, ByVal e As EventArgs)
            _state = State.Success
        End Sub

        Protected Sub OnLoginError(ByVal sender As Object, ByVal e As EventArgs)
            _state = State.Failed
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderBeginTag(writer, "Kartris-Login")
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderEndTag(writer)
            Else
                MyBase.RenderEndTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Dim login As Login = Control
                If (Not IsNothing(login)) Then
                    If (Not IsNothing(login.LayoutTemplate)) Then
                        If (login.Controls.Count = 1) Then
                            Dim container As Control = login.Controls(0)
                            If (Not IsNothing(container)) Then
                                Dim c As Control
                                For Each c In container.Controls
                                    c.RenderControl(writer)
                                Next
                            End If
                        End If
                    Else
                        WriteTitlePanel(writer, login)
                        WriteInstructionPanel(writer, login)
                        WriteHelpPanel(writer, login)
                        WriteUserPanel(writer, login)
                        WritePasswordPanel(writer, login)
                        WriteRememberMePanel(writer, login)
                        If (_state = State.Failed) Then
                            WriteFailurePanel(writer, login)
                        End If
                        WriteSubmitPanel(writer, login)
                        WriteCreateUserPanel(writer, login)
                        WritePasswordRecoveryPanel(writer, login)
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

        Private Sub WriteTitlePanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            If (Not String.IsNullOrEmpty(login.TitleText)) Then
                Dim className As String = ""
                If ((Not IsNothing(login.TitleTextStyle)) AndAlso (Not String.IsNullOrEmpty(login.TitleTextStyle.CssClass))) Then
                    className = login.TitleTextStyle.CssClass & " "
                End If
                className &= "Kartris-Login-TitlePanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", login.TitleText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteInstructionPanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            If (Not String.IsNullOrEmpty(login.InstructionText)) Then
                Dim className As String = ""
                If ((Not IsNothing(login.InstructionTextStyle)) AndAlso (Not String.IsNullOrEmpty(login.InstructionTextStyle.CssClass))) Then
                    className = login.InstructionTextStyle.CssClass & " "
                End If
                className &= "Kartris-Login-InstructionPanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", login.InstructionText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteFailurePanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            If (Not String.IsNullOrEmpty(login.FailureText)) Then
                Dim className As String = ""
                If ((Not IsNothing(login.FailureTextStyle)) AndAlso (Not String.IsNullOrEmpty(login.FailureTextStyle.CssClass))) Then
                    className = login.FailureTextStyle.CssClass & " "
                End If
                className &= "Kartris-Login-FailurePanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", login.FailureText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteHelpPanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            If ((Not String.IsNullOrEmpty(login.HelpPageIconUrl)) OrElse (Not String.IsNullOrEmpty(login.HelpPageText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-Login-HelpPanel", "")
                WebControlAdapterExtender.WriteImage(writer, login.HelpPageIconUrl, "Help")
                WebControlAdapterExtender.WriteLink(writer, login.HyperLinkStyle.CssClass, login.HelpPageUrl, "Help", login.HelpPageText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteUserPanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            Page.ClientScript.RegisterForEventValidation(login.FindControl("UserName").UniqueID)
            WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-Login-UserPanel", "")
            Extender.WriteTextBox(writer, False, login.LabelStyle.CssClass, login.UserNameLabelText, login.TextBoxStyle.CssClass, "UserName", login.UserName)
            WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(login.FindControl("UserNameRequired"), RequiredFieldValidator), login.ValidatorTextStyle.CssClass, "UserName", login.UserNameRequiredErrorMessage)
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub

        Private Sub WritePasswordPanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            Page.ClientScript.RegisterForEventValidation(login.FindControl("Password").UniqueID)
            WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-Login-PasswordPanel", "")
            Extender.WriteTextBox(writer, True, login.LabelStyle.CssClass, login.PasswordLabelText, login.TextBoxStyle.CssClass, "Password", "")
            WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(login.FindControl("PasswordRequired"), RequiredFieldValidator), login.ValidatorTextStyle.CssClass, "Password", login.PasswordRequiredErrorMessage)
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub

        Private Sub WriteRememberMePanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            If login.DisplayRememberMe Then
                Page.ClientScript.RegisterForEventValidation(login.FindControl("RememberMe").UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-Login-RememberMePanel", "")
                Extender.WriteCheckBox(writer, login.LabelStyle.CssClass, login.RememberMeText, login.CheckBoxStyle.CssClass, "RememberMe", login.RememberMeSet)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteSubmitPanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            Dim id As String = "Login"
            Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType(id, login.LoginButtonType)
            Dim btn As Control = login.FindControl(idWithType)
            If (Not IsNothing(btn)) Then
                Page.ClientScript.RegisterForEventValidation(btn.UniqueID)

                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-Login-SubmitPanel", "")

                Dim options As PostBackOptions = New PostBackOptions(btn, "", "", False, False, False, True, True, login.UniqueID)
                Dim javascript As String = "javascript:" & Page.ClientScript.GetPostBackEventReference(options)
                javascript = Page.Server.HtmlEncode(javascript)

                Extender.WriteSubmit(writer, login.LoginButtonType, login.LoginButtonStyle.CssClass, id, login.LoginButtonImageUrl, javascript, login.LoginButtonText)

                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteCreateUserPanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            If ((Not String.IsNullOrEmpty(login.CreateUserUrl)) OrElse (Not String.IsNullOrEmpty(login.CreateUserText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-Login-CreateUserPanel", "")
                WebControlAdapterExtender.WriteImage(writer, login.CreateUserIconUrl, "Create user")
                WebControlAdapterExtender.WriteLink(writer, login.HyperLinkStyle.CssClass, login.CreateUserUrl, "Create user", login.CreateUserText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WritePasswordRecoveryPanel(ByVal writer As HtmlTextWriter, ByVal login As Login)
            If ((Not String.IsNullOrEmpty(login.PasswordRecoveryUrl)) OrElse (Not String.IsNullOrEmpty(login.PasswordRecoveryText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-Login-PasswordRecoveryPanel", "")
                WebControlAdapterExtender.WriteImage(writer, login.PasswordRecoveryIconUrl, "Password recovery")
                WebControlAdapterExtender.WriteLink(writer, login.HyperLinkStyle.CssClass, login.PasswordRecoveryUrl, "Password recovery", login.PasswordRecoveryText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub
    End Class
End Namespace
