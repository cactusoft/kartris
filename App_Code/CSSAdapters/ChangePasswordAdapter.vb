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
    Public Class ChangePasswordAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter
        Private Enum State
            ChangePassword
            Failed
            Success
        End Enum
        Dim _state As State = State.ChangePassword

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
            _state = State.ChangePassword
        End Sub

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PROTECTED        

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            Dim changePwd As ChangePassword = Control
            If (Extender.AdapterEnabled AndAlso (Not IsNothing(changePwd))) Then
                RegisterScripts()

                AddHandler changePwd.ChangedPassword, AddressOf OnChangedPassword
                AddHandler changePwd.ChangePasswordError, AddressOf OnChangePasswordError
                _state = State.ChangePassword
            End If
        End Sub

        Protected Overrides Sub CreateChildControls()
            MyBase.CreateChildControls()

            Dim changePwd As ChangePassword = Control
            If ((Not IsNothing(changePwd)) AndAlso (changePwd.Controls.Count = 2)) Then
                If (Not IsNothing(changePwd.ChangePasswordTemplate)) Then
                    changePwd.ChangePasswordTemplateContainer.Controls.Clear()
                    changePwd.ChangePasswordTemplate.InstantiateIn(changePwd.ChangePasswordTemplateContainer)
                    changePwd.ChangePasswordTemplateContainer.DataBind()
                End If

                If (Not IsNothing(changePwd.SuccessTemplate)) Then
                    changePwd.SuccessTemplateContainer.Controls.Clear()
                    changePwd.SuccessTemplate.InstantiateIn(changePwd.SuccessTemplateContainer)
                    changePwd.SuccessTemplateContainer.DataBind()
                End If

                changePwd.Controls.Add(New ChangePasswordCommandBubbler())
            End If
        End Sub

        Protected Sub OnChangedPassword(ByVal sender As Object, ByVal e As EventArgs)
            _state = State.Success
        End Sub

        Protected Sub OnChangePasswordError(ByVal sender As Object, ByVal e As EventArgs)
            If (_state <> State.Success) Then
                _state = State.Failed
            End If
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                Extender.RenderBeginTag(writer, "Kartris-ChangePassword")
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                Extender.RenderEndTag(writer)
            Else
                MyBase.RenderEndTag(writer)
            End If
        End Sub

        Protected Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                Dim changePwd As ChangePassword = Control
                If (Not IsNothing(changePwd)) Then
                    If ((_state = State.ChangePassword) OrElse (_state = State.Failed)) Then
                        If (Not IsNothing(changePwd.ChangePasswordTemplate)) Then
                            changePwd.ChangePasswordTemplateContainer.RenderControl(writer)
                        Else
                            WriteChangePasswordTitlePanel(writer, changePwd)
                            WriteInstructionPanel(writer, changePwd)
                            WriteHelpPanel(writer, changePwd)
                            WriteUserPanel(writer, changePwd)
                            WritePasswordPanel(writer, changePwd)
                            WriteNewPasswordPanel(writer, changePwd)
                            WriteConfirmNewPasswordPanel(writer, changePwd)
                            If (_state = State.Failed) Then
                                WriteFailurePanel(writer, changePwd)
                            End If
                            WriteSubmitPanel(writer, changePwd)
                            WriteCreateUserPanel(writer, changePwd)
                            WritePasswordRecoveryPanel(writer, changePwd)
                        End If
                    ElseIf (_state = State.Success) Then
                        If (Not IsNothing(changePwd.SuccessTemplate)) Then
                            changePwd.SuccessTemplateContainer.RenderControl(writer)
                        Else
                            WriteSuccessTitlePanel(writer, changePwd)
                            WriteSuccessTextPanel(writer, changePwd)
                            WriteContinuePanel(writer, changePwd)
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

        '///////////////////////////////////////////////////////
        ' Step 1: change password
        '///////////////////////////////////////////////////////

        Private Sub WriteChangePasswordTitlePanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If (Not String.IsNullOrEmpty(changePwd.ChangePasswordTitleText)) Then
                Dim className As String = ""
                If ((Not IsNothing(changePwd.TitleTextStyle)) AndAlso (Not String.IsNullOrEmpty(changePwd.TitleTextStyle.CssClass))) Then
                    className = changePwd.TitleTextStyle.CssClass & " "
                End If
                className &= "Kartris-ChangePassword-ChangePasswordTitlePanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", changePwd.ChangePasswordTitleText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteInstructionPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If (Not String.IsNullOrEmpty(changePwd.InstructionText)) Then
                Dim className As String = ""
                If ((Not IsNothing(changePwd.InstructionTextStyle)) AndAlso (Not String.IsNullOrEmpty(changePwd.InstructionTextStyle.CssClass))) Then
                    className = changePwd.InstructionTextStyle.CssClass & " "
                End If
                className &= "Kartris-ChangePassword-InstructionPanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", changePwd.InstructionText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteFailurePanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            Dim className As String = ""
            If ((Not IsNothing(changePwd.FailureTextStyle)) AndAlso (Not String.IsNullOrEmpty(changePwd.FailureTextStyle.CssClass))) Then
                className = changePwd.FailureTextStyle.CssClass & " "
            End If
            className &= "Kartris-ChangePassword-FailurePanel"
            WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
            WebControlAdapterExtender.WriteSpan(writer, "", changePwd.ChangePasswordFailureText)
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub

        Private Sub WriteHelpPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If ((Not String.IsNullOrEmpty(changePwd.HelpPageIconUrl)) OrElse (Not String.IsNullOrEmpty(changePwd.HelpPageText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-HelpPanel", "")
                WebControlAdapterExtender.WriteImage(writer, changePwd.HelpPageIconUrl, "Help")
                WebControlAdapterExtender.WriteLink(writer, changePwd.HyperLinkStyle.CssClass, changePwd.HelpPageUrl, "Help", changePwd.HelpPageText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteUserPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If (changePwd.DisplayUserName) Then
                Dim textbox As TextBox = changePwd.ChangePasswordTemplateContainer.FindControl("UserName")
                If (Not IsNothing(textbox)) Then
                    Page.ClientScript.RegisterForEventValidation(textbox.UniqueID)
                    WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-UserPanel", "")
                    Extender.WriteTextBox(writer, False, changePwd.LabelStyle.CssClass, changePwd.UserNameLabelText, changePwd.TextBoxStyle.CssClass, changePwd.ChangePasswordTemplateContainer.ID & "_UserName", changePwd.UserName)
                    WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(changePwd.ChangePasswordTemplateContainer.FindControl("UserNameRequired"), RequiredFieldValidator), changePwd.ValidatorTextStyle.CssClass, "UserName", changePwd.UserNameRequiredErrorMessage)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            End If
        End Sub

        Private Sub WritePasswordPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            Dim textbox As TextBox = changePwd.ChangePasswordTemplateContainer.FindControl("CurrentPassword")
            If (Not IsNothing(textbox)) Then
                Page.ClientScript.RegisterForEventValidation(textbox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-PasswordPanel", "")
                Extender.WriteTextBox(writer, True, changePwd.LabelStyle.CssClass, changePwd.PasswordLabelText, changePwd.TextBoxStyle.CssClass, changePwd.ChangePasswordTemplateContainer.ID & "_CurrentPassword", "")
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(changePwd.ChangePasswordTemplateContainer.FindControl("CurrentPasswordRequired"), RequiredFieldValidator), changePwd.ValidatorTextStyle.CssClass, "CurrentPassword", changePwd.PasswordRequiredErrorMessage)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteNewPasswordPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            Dim textbox As TextBox = changePwd.ChangePasswordTemplateContainer.FindControl("NewPassword")
            If (Not IsNothing(textbox)) Then
                Page.ClientScript.RegisterForEventValidation(textbox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-NewPasswordPanel", "")
                Extender.WriteTextBox(writer, True, changePwd.LabelStyle.CssClass, changePwd.NewPasswordLabelText, changePwd.TextBoxStyle.CssClass, changePwd.ChangePasswordTemplateContainer.ID & "_NewPassword", "")
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(changePwd.ChangePasswordTemplateContainer.FindControl("NewPasswordRequired"), RequiredFieldValidator), changePwd.ValidatorTextStyle.CssClass, "NewPassword", changePwd.NewPasswordRequiredErrorMessage)
                WebControlAdapterExtender.WriteRegularExpressionValidator(writer, CType(changePwd.ChangePasswordTemplateContainer.FindControl("RegExpValidator"), RegularExpressionValidator), changePwd.ValidatorTextStyle.CssClass, "NewPassword", changePwd.NewPasswordRegularExpressionErrorMessage, changePwd.NewPasswordRegularExpression)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteConfirmNewPasswordPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            Dim textbox As TextBox = changePwd.ChangePasswordTemplateContainer.FindControl("ConfirmNewPassword")
            If (Not IsNothing(textbox)) Then
                Page.ClientScript.RegisterForEventValidation(textbox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-ConfirmNewPasswordPanel", "")
                Extender.WriteTextBox(writer, True, changePwd.LabelStyle.CssClass, changePwd.ConfirmNewPasswordLabelText, changePwd.TextBoxStyle.CssClass, changePwd.ChangePasswordTemplateContainer.ID & "_ConfirmNewPassword", "")
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(changePwd.ChangePasswordTemplateContainer.FindControl("ConfirmNewPasswordRequired"), RequiredFieldValidator), changePwd.ValidatorTextStyle.CssClass, "ConfirmNewPassword", changePwd.ConfirmPasswordRequiredErrorMessage)
                WebControlAdapterExtender.WriteCompareValidator(writer, CType(changePwd.ChangePasswordTemplateContainer.FindControl("NewPasswordCompare"), CompareValidator), changePwd.ValidatorTextStyle.CssClass, "ConfirmNewPassword", changePwd.ConfirmPasswordCompareErrorMessage, "NewPassword")
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteSubmitPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-SubmitPanel", "")

            Dim id As String = "ChangePassword"
            id &= IIf(changePwd.ChangePasswordButtonType = ButtonType.Button, "Push", "")
            Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType(id, changePwd.ChangePasswordButtonType)
            Dim btn As Control = changePwd.ChangePasswordTemplateContainer.FindControl(idWithType)
            If (Not IsNothing(btn)) Then
                Page.ClientScript.RegisterForEventValidation(btn.UniqueID)

                Dim options As PostBackOptions = New PostBackOptions(btn, "", "", False, False, False, True, True, changePwd.UniqueID)
                Dim javascript As String = "javascript:" & Page.ClientScript.GetPostBackEventReference(options)
                javascript = Page.Server.HtmlEncode(javascript)

                Extender.WriteSubmit(writer, changePwd.ChangePasswordButtonType, changePwd.ChangePasswordButtonStyle.CssClass, changePwd.ChangePasswordTemplateContainer.ID & "_" & id, changePwd.ChangePasswordButtonImageUrl, javascript, changePwd.ChangePasswordButtonText)
            End If

            id = "Cancel"
            id &= IIf(changePwd.ChangePasswordButtonType = ButtonType.Button, "Push", "")
            idWithType = WebControlAdapterExtender.MakeIdWithButtonType(id, changePwd.CancelButtonType)
            btn = changePwd.ChangePasswordTemplateContainer.FindControl(idWithType)
            If (Not IsNothing(btn)) Then
                Page.ClientScript.RegisterForEventValidation(btn.UniqueID)
                Extender.WriteSubmit(writer, changePwd.CancelButtonType, changePwd.CancelButtonStyle.CssClass, changePwd.ChangePasswordTemplateContainer.ID + "_" + id, changePwd.CancelButtonImageUrl, "", changePwd.CancelButtonText)
            End If

            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub

        Private Sub WriteCreateUserPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If ((Not String.IsNullOrEmpty(changePwd.CreateUserUrl)) OrElse (Not String.IsNullOrEmpty(changePwd.CreateUserText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-CreateUserPanel", "")
                WebControlAdapterExtender.WriteImage(writer, changePwd.CreateUserIconUrl, "Create user")
                WebControlAdapterExtender.WriteLink(writer, changePwd.HyperLinkStyle.CssClass, changePwd.CreateUserUrl, "Create user", changePwd.CreateUserText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WritePasswordRecoveryPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If ((Not String.IsNullOrEmpty(changePwd.PasswordRecoveryUrl)) OrElse (Not String.IsNullOrEmpty(changePwd.PasswordRecoveryText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-PasswordRecoveryPanel", "")
                WebControlAdapterExtender.WriteImage(writer, changePwd.PasswordRecoveryIconUrl, "Password recovery")
                WebControlAdapterExtender.WriteLink(writer, changePwd.HyperLinkStyle.CssClass, changePwd.PasswordRecoveryUrl, "Password recovery", changePwd.PasswordRecoveryText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        '///////////////////////////////////////////////////////
        ' Step 2: success
        '///////////////////////////////////////////////////////

        Private Sub WriteSuccessTitlePanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If (Not String.IsNullOrEmpty(changePwd.SuccessTitleText)) Then
                Dim className As String = ""
                If ((Not IsNothing(changePwd.TitleTextStyle)) AndAlso (Not String.IsNullOrEmpty(changePwd.TitleTextStyle.CssClass))) Then
                    className = changePwd.TitleTextStyle.CssClass & " "
                End If
                className &= "Kartris-ChangePassword-SuccessTitlePanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", changePwd.SuccessTitleText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteSuccessTextPanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            If (Not String.IsNullOrEmpty(changePwd.SuccessText)) Then
                Dim className As String = ""
                If ((Not IsNothing(changePwd.SuccessTextStyle)) AndAlso (Not String.IsNullOrEmpty(changePwd.SuccessTextStyle.CssClass))) Then
                    className = changePwd.SuccessTextStyle.CssClass & " "
                End If
                className &= "Kartris-ChangePassword-SuccessTextPanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", changePwd.SuccessText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteContinuePanel(ByVal writer As HtmlTextWriter, ByVal changePwd As ChangePassword)
            WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-ChangePassword-ContinuePanel", "")

            Dim id As String = "Continue"
            id &= IIf((changePwd.ChangePasswordButtonType = ButtonType.Button), "Push", "")
            Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType(id, changePwd.ContinueButtonType)
            Dim btn As Control = changePwd.SuccessTemplateContainer.FindControl(idWithType)
            If (Not IsNothing(btn)) Then
                Page.ClientScript.RegisterForEventValidation(btn.UniqueID)
                Extender.WriteSubmit(writer, changePwd.ContinueButtonType, changePwd.ContinueButtonStyle.CssClass, changePwd.SuccessTemplateContainer.ID + "_" + id, changePwd.ContinueButtonImageUrl, "", changePwd.ContinueButtonText)
            End If

            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub
    End Class

    Public Class ChangePasswordCommandBubbler
        Inherits Control
        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)
            MyBase.OnPreRender(e)
            If (Page.IsPostBack) Then
                Dim changePassword As ChangePassword = NamingContainer
                If (Not IsNothing(changePassword)) Then
                    Dim container As Control = changePassword.ChangePasswordTemplateContainer
                    If (Not IsNothing(container)) Then
                        Dim cmdArgs As CommandEventArgs = Nothing
                        Dim prefixes() As String = {"ChangePassword", "Cancel", "Continue"}

                        Dim postfixes() As String = {"PushButton", "Image", "Link"}

                        Dim prefix As String
                        For Each prefix In prefixes
                            Dim postfix As String
                            For Each postfix In postfixes
                                Dim id As String = prefix + postfix
                                Dim ctrl As Control = container.FindControl(id)
                                If ((Not IsNothing(ctrl)) AndAlso (Not String.IsNullOrEmpty(Page.Request.Params.Get(ctrl.UniqueID)))) Then
                                    Select Case prefix
                                        Case "ChangePassword"
                                            cmdArgs = New CommandEventArgs(changePassword.ChangePasswordButtonCommandName, Me)
                                            Exit For
                                        Case "Cancel"
                                            cmdArgs = New CommandEventArgs(changePassword.CancelButtonCommandName, Me)
                                            Exit For
                                        Case "Continue"
                                            cmdArgs = New CommandEventArgs(changePassword.ContinueButtonCommandName, Me)
                                            Exit For
                                    End Select
                                End If
                            Next
                            If (Not IsNothing(cmdArgs)) Then
                                Exit For
                            End If
                        Next

                        If ((Not IsNothing(cmdArgs)) AndAlso (cmdArgs.CommandName = changePassword.ChangePasswordButtonCommandName)) Then
                            Page.Validate()
                            If (Not Page.IsValid) Then
                                cmdArgs = Nothing
                            End If
                        End If

                        If (Not IsNothing(cmdArgs)) Then
                            RaiseBubbleEvent(Me, cmdArgs)
                        End If
                    End If
                End If
            End If
        End Sub
    End Class
End Namespace
