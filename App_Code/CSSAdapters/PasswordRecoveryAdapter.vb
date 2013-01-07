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
    Public Class PasswordRecoveryAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter
        Private Enum State
            UserName
            VerifyingUser
            UserLookupError
            Question
            VerifyingAnswer
            AnswerLookupError
            SendMailError
            Success
        End Enum
        Dim _state As State = State.UserName
        Dim _currentErrorText As String = ""

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

        Private ReadOnly Property PasswordRecoveryMembershipProvider() As MembershipProvider
            Get
                Dim provider As MembershipProvider = Membership.Provider
                Dim passwordRecovery As PasswordRecovery = Control
                If ((Not IsNothing(passwordRecovery)) AndAlso (Not String.IsNullOrEmpty(passwordRecovery.MembershipProvider)) AndAlso (Not IsNothing(Membership.Providers(passwordRecovery.MembershipProvider)))) Then
                    provider = Membership.Providers(passwordRecovery.MembershipProvider)
                End If
                Return provider
            End Get
        End Property

        Public Sub New()
            _state = State.UserName
            _currentErrorText = ""
        End Sub

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PROTECTED        

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            Dim passwordRecovery As PasswordRecovery = Control
            If (Extender.AdapterEnabled AndAlso (Not IsNothing(passwordRecovery))) Then
                RegisterScripts()
                AddHandler passwordRecovery.AnswerLookupError, AddressOf OnAnswerLookupError
                AddHandler passwordRecovery.SendMailError, AddressOf OnSendMailError
                AddHandler passwordRecovery.UserLookupError, AddressOf OnUserLookupError
                AddHandler passwordRecovery.VerifyingAnswer, AddressOf OnVerifyingAnswer
                AddHandler passwordRecovery.VerifyingUser, AddressOf OnVerifyingUser
                _state = State.UserName
                _currentErrorText = ""
            End If
        End Sub

        Protected Overrides Sub CreateChildControls()
            MyBase.CreateChildControls()

            Dim passwordRecovery As PasswordRecovery = Control
            If (Not IsNothing(passwordRecovery)) Then
                If ((Not IsNothing(passwordRecovery.UserNameTemplate)) AndAlso (Not IsNothing(passwordRecovery.UserNameTemplateContainer))) Then
                    passwordRecovery.UserNameTemplateContainer.Controls.Clear()
                    passwordRecovery.UserNameTemplate.InstantiateIn(passwordRecovery.UserNameTemplateContainer)
                    passwordRecovery.UserNameTemplateContainer.DataBind()
                End If

                If ((Not IsNothing(passwordRecovery.QuestionTemplate)) AndAlso (Not IsNothing(passwordRecovery.QuestionTemplateContainer))) Then
                    passwordRecovery.QuestionTemplateContainer.Controls.Clear()
                    passwordRecovery.QuestionTemplate.InstantiateIn(passwordRecovery.QuestionTemplateContainer)
                    passwordRecovery.QuestionTemplateContainer.DataBind()
                End If

                If ((Not IsNothing(passwordRecovery.SuccessTemplate)) AndAlso (Not IsNothing(passwordRecovery.SuccessTemplateContainer))) Then
                    passwordRecovery.SuccessTemplateContainer.Controls.Clear()
                    passwordRecovery.SuccessTemplate.InstantiateIn(passwordRecovery.SuccessTemplateContainer)
                    passwordRecovery.SuccessTemplateContainer.DataBind()
                End If
            End If
        End Sub

        Protected Sub OnAnswerLookupError(ByVal sender As Object, ByVal e As EventArgs)
            _state = State.AnswerLookupError
            Dim passwordRecovery As PasswordRecovery = Control
            If (Not IsNothing(passwordRecovery)) Then
                _currentErrorText = passwordRecovery.GeneralFailureText
                If (Not String.IsNullOrEmpty(passwordRecovery.QuestionFailureText)) Then
                    _currentErrorText = passwordRecovery.QuestionFailureText
                End If
            End If
        End Sub

        Protected Sub OnSendMailError(ByVal sender As Object, ByVal e As SendMailErrorEventArgs)
            If (Not e.Handled) Then
                _state = State.SendMailError
                _currentErrorText = e.Exception.Message
            End If
        End Sub

        Protected Sub OnUserLookupError(ByVal sender As Object, ByVal e As EventArgs)
            _state = State.UserLookupError
            Dim passwordRecovery As PasswordRecovery = Control
            If (Not IsNothing(passwordRecovery)) Then
                _currentErrorText = passwordRecovery.GeneralFailureText
                If (Not String.IsNullOrEmpty(passwordRecovery.UserNameFailureText)) Then
                    _currentErrorText = passwordRecovery.UserNameFailureText
                End If
            End If
        End Sub

        Protected Sub OnVerifyingAnswer(ByVal sender As Object, ByVal e As LoginCancelEventArgs)
            _state = State.VerifyingAnswer
        End Sub

        Protected Sub OnVerifyingUser(ByVal sender As Object, ByVal e As LoginCancelEventArgs)
            _state = State.VerifyingUser
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                Extender.RenderBeginTag(writer, "Kartris-PasswordRecovery")
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub

        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)
            MyBase.OnPreRender(e)

            Dim passwordRecovery As PasswordRecovery = Control
            If (Not IsNothing(passwordRecovery)) Then
                Dim provider As String = passwordRecovery.MembershipProvider
            End If

            '  By this time we have finished doing our event processing.  That means that if errors have
            '  occurred, the event handlers (OnAnswerLookupError, OnSendMailError or 
            '  OnUserLookupError) will have been called.  So, if we were, for example, verifying the
            '  user and didn't cause an error then we know we can move on to the next step, getting
            '  the answer to the security question... if the membership system demands it.

            Select Case _state
                Case State.AnswerLookupError
                    ' Leave the state alone because we hit an error.
                    Exit Select
                Case State.Question
                    ' Leave the state alone. Render a form to get the answer to the security question.
                    _currentErrorText = ""
                    Exit Select
                Case State.SendMailError
                    ' Leave the state alone because we hit an error.
                    Exit Select
                Case State.Success
                    ' Leave the state alone. Render a concluding message.
                    _currentErrorText = ""
                    Exit Select
                Case State.UserLookupError
                    ' Leave the state alone because we hit an error.
                    Exit Select
                Case State.UserName
                    ' Leave the state alone. Render a form to get the user name.
                    _currentErrorText = ""
                    Exit Select
                Case State.VerifyingAnswer
                    ' Success! We did not encounter an error while verifying the answer to the security question.
                    _state = State.Success
                    _currentErrorText = ""
                    Exit Select
                Case State.VerifyingUser
                    ' We have a valid user. We did not encounter an error while verifying the user.
                    If (PasswordRecoveryMembershipProvider.RequiresQuestionAndAnswer) Then
                        _state = State.Question
                    Else
                        _state = State.Success
                    End If
                    _currentErrorText = ""
                    Exit Select
            End Select
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
                Dim passwordRecovery As PasswordRecovery = Control
                If (Not IsNothing(passwordRecovery)) Then
                    If ((_state = State.UserName) OrElse (_state = State.UserLookupError)) Then
                        If ((Not IsNothing(passwordRecovery.UserNameTemplate)) AndAlso (Not IsNothing(passwordRecovery.UserNameTemplateContainer))) Then
                            Dim c As Control
                            For Each c In passwordRecovery.UserNameTemplateContainer.Controls
                                c.RenderControl(writer)
                            Next
                        Else
                            WriteTitlePanel(writer, passwordRecovery)
                            WriteInstructionPanel(writer, passwordRecovery)
                            WriteHelpPanel(writer, passwordRecovery)
                            If (_state = State.UserLookupError) Then
                                WriteFailurePanel(writer, passwordRecovery)
                            End If
                            WriteUserPanel(writer, passwordRecovery)
                            WriteSubmitPanel(writer, passwordRecovery)
                        End If
                    ElseIf ((_state = State.Question) OrElse (_state = State.AnswerLookupError)) Then
                        If ((Not IsNothing(passwordRecovery.QuestionTemplate)) AndAlso (Not IsNothing(passwordRecovery.QuestionTemplateContainer))) Then
                            Dim c As Control
                            For Each c In passwordRecovery.QuestionTemplateContainer.Controls
                                c.RenderControl(writer)
                            Next
                        Else
                            WriteTitlePanel(writer, passwordRecovery)
                            WriteInstructionPanel(writer, passwordRecovery)
                            WriteHelpPanel(writer, passwordRecovery)
                            If (_state = State.AnswerLookupError) Then
                                WriteFailurePanel(writer, passwordRecovery)
                            End If
                            WriteUserPanel(writer, passwordRecovery)
                            WriteQuestionPanel(writer, passwordRecovery)
                            WriteAnswerPanel(writer, passwordRecovery)
                            WriteSubmitPanel(writer, passwordRecovery)
                        End If
                    ElseIf (_state = State.SendMailError) Then
                        WriteFailurePanel(writer, passwordRecovery)
                    ElseIf (_state = State.Success) Then
                        If ((Not IsNothing(passwordRecovery.SuccessTemplate)) AndAlso (Not IsNothing(passwordRecovery.SuccessTemplateContainer))) Then
                            Dim c As Control
                            For Each c In passwordRecovery.SuccessTemplateContainer.Controls
                                c.RenderControl(writer)
                            Next
                        Else
                            WriteSuccessTextPanel(writer, passwordRecovery)
                        End If
                    Else
                        '  We should never get here.
                        System.Diagnostics.Debug.Fail("The PasswordRecovery control adapter was asked to render a state that it does not expect.")
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
        ' Step 1: user name
        '///////////////////////////////////////////////////////

        Private Sub WriteTitlePanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            If ((_state = State.UserName) OrElse (_state = State.UserLookupError)) Then
                If (Not String.IsNullOrEmpty(passwordRecovery.UserNameTitleText)) Then
                    Dim className As String = ""
                    If ((Not IsNothing(passwordRecovery.TitleTextStyle)) AndAlso (Not String.IsNullOrEmpty(passwordRecovery.TitleTextStyle.CssClass))) Then
                        className = passwordRecovery.TitleTextStyle.CssClass & " "
                    End If
                    className &= "Kartris-PasswordRecovery-UserName-TitlePanel"
                    WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                    WebControlAdapterExtender.WriteSpan(writer, "", passwordRecovery.UserNameTitleText)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            ElseIf ((_state = State.Question) OrElse (_state = State.AnswerLookupError)) Then
                If (Not String.IsNullOrEmpty(passwordRecovery.QuestionTitleText)) Then
                    Dim className As String = ""
                    If ((Not IsNothing(passwordRecovery.TitleTextStyle)) AndAlso (Not String.IsNullOrEmpty(passwordRecovery.TitleTextStyle.CssClass))) Then
                        className = passwordRecovery.TitleTextStyle.CssClass & " "
                    End If
                    className &= "Kartris-PasswordRecovery-Question-TitlePanel"
                    WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                    WebControlAdapterExtender.WriteSpan(writer, "", passwordRecovery.QuestionTitleText)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            End If
        End Sub

        Private Sub WriteInstructionPanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            If ((_state = State.UserName) OrElse (_state = State.UserLookupError)) Then
                If (Not String.IsNullOrEmpty(passwordRecovery.UserNameInstructionText)) Then
                    Dim className As String = ""
                    If ((Not IsNothing(passwordRecovery.InstructionTextStyle)) AndAlso (Not String.IsNullOrEmpty(passwordRecovery.InstructionTextStyle.CssClass))) Then
                        className = passwordRecovery.InstructionTextStyle.CssClass & " "
                    End If
                    className &= "Kartris-PasswordRecovery-UserName-InstructionPanel"
                    WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                    WebControlAdapterExtender.WriteSpan(writer, "", passwordRecovery.UserNameInstructionText)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            ElseIf ((_state = State.Question) OrElse (_state = State.AnswerLookupError)) Then
                If (Not String.IsNullOrEmpty(passwordRecovery.QuestionInstructionText)) Then
                    Dim className As String = ""
                    If ((Not IsNothing(passwordRecovery.InstructionTextStyle)) AndAlso (Not String.IsNullOrEmpty(passwordRecovery.InstructionTextStyle.CssClass))) Then
                        className = passwordRecovery.InstructionTextStyle.CssClass & " "
                    End If
                    className &= "Kartris-PasswordRecovery-Question-InstructionPanel"
                    WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                    WebControlAdapterExtender.WriteSpan(writer, "", passwordRecovery.QuestionInstructionText)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            End If
        End Sub

        Private Sub WriteFailurePanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            If (Not String.IsNullOrEmpty(_currentErrorText)) Then
                Dim className As String = ""
                If ((Not IsNothing(passwordRecovery.FailureTextStyle)) AndAlso (Not String.IsNullOrEmpty(passwordRecovery.FailureTextStyle.CssClass))) Then
                    className = passwordRecovery.FailureTextStyle.CssClass & " "
                End If
                className &= "Kartris-PasswordRecovery-FailurePanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", _currentErrorText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteHelpPanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            If ((Not String.IsNullOrEmpty(passwordRecovery.HelpPageIconUrl)) OrElse (Not String.IsNullOrEmpty(passwordRecovery.HelpPageText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-PasswordRecovery-HelpPanel", "")
                WebControlAdapterExtender.WriteImage(writer, passwordRecovery.HelpPageIconUrl, "Help")
                WebControlAdapterExtender.WriteLink(writer, passwordRecovery.HyperLinkStyle.CssClass, passwordRecovery.HelpPageUrl, "Help", passwordRecovery.HelpPageText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteUserPanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            If ((_state = State.UserName) OrElse (_state = State.UserLookupError)) Then
                Dim container As Control = passwordRecovery.UserNameTemplateContainer
                Dim textBox As TextBox = Nothing
                If (Not IsNothing(container)) Then
                    textBox = CType(container.FindControl("UserName"), TextBox)
                End If
                Dim rfv As RequiredFieldValidator = Nothing
                If (Not IsNothing(textBox)) Then
                    rfv = CType(container.FindControl("UserNameRequired"), RequiredFieldValidator)
                End If
                Dim id As String = ""
                If (Not IsNothing(rfv)) Then
                    id = container.ID & "_" & textBox.ID
                End If
                If (Not String.IsNullOrEmpty(id)) Then
                    Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                    WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-PasswordRecovery-UserName-UserPanel", "")
                    Extender.WriteTextBox(writer, False, passwordRecovery.LabelStyle.CssClass, passwordRecovery.UserNameLabelText, passwordRecovery.TextBoxStyle.CssClass, id, passwordRecovery.UserName)
                    WebControlAdapterExtender.WriteRequiredFieldValidator(writer, rfv, passwordRecovery.ValidatorTextStyle.CssClass, "UserName", passwordRecovery.UserNameRequiredErrorMessage)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            ElseIf ((_state = State.Question) OrElse (_state = State.AnswerLookupError)) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-PasswordRecovery-Question-UserPanel", "")
                Extender.WriteReadOnlyTextBox(writer, passwordRecovery.LabelStyle.CssClass, passwordRecovery.UserNameLabelText, passwordRecovery.TextBoxStyle.CssClass, passwordRecovery.UserName)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteSubmitPanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            If ((_state = State.UserName) OrElse (_state = State.UserLookupError)) Then
                Dim container As Control = passwordRecovery.UserNameTemplateContainer
                Dim id As String = IIf(Not IsNothing(container), container.ID & "_Submit", "Submit")

                Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType("Submit", passwordRecovery.SubmitButtonType)
                Dim btn As Control = Nothing
                If (Not IsNothing(container)) Then
                    btn = container.FindControl(idWithType)
                End If

                If (Not IsNothing(btn)) Then
                    Page.ClientScript.RegisterForEventValidation(btn.UniqueID)

                    Dim options As PostBackOptions = New PostBackOptions(btn, "", "", False, False, False, True, True, passwordRecovery.UniqueID)
                    Dim javascript As String = "javascript:" & Page.ClientScript.GetPostBackEventReference(options)
                    javascript = Page.Server.HtmlEncode(javascript)

                    WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-PasswordRecovery-UserName-SubmitPanel", "")
                    Extender.WriteSubmit(writer, passwordRecovery.SubmitButtonType, passwordRecovery.SubmitButtonStyle.CssClass, id, passwordRecovery.SubmitButtonImageUrl, javascript, passwordRecovery.SubmitButtonText)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            ElseIf ((_state = State.Question) OrElse (_state = State.AnswerLookupError)) Then
                Dim container As Control = passwordRecovery.QuestionTemplateContainer
                Dim id As String = IIf(Not IsNothing(container), container.ID & "_Submit", "Submit")
                Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType("Submit", passwordRecovery.SubmitButtonType)
                Dim btn As Control = Nothing
                If (Not IsNothing(container)) Then
                    btn = container.FindControl(idWithType)
                End If

                If Not btn Is Nothing Then
                    Page.ClientScript.RegisterForEventValidation(btn.UniqueID)

                    Dim options As PostBackOptions = New PostBackOptions(btn, "", "", False, False, False, True, True, passwordRecovery.UniqueID)
                    Dim javascript As String = "javascript:" & Page.ClientScript.GetPostBackEventReference(options)
                    javascript = Page.Server.HtmlEncode(javascript)

                    WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-PasswordRecovery-Question-SubmitPanel", "")
                    Extender.WriteSubmit(writer, passwordRecovery.SubmitButtonType, passwordRecovery.SubmitButtonStyle.CssClass, id, passwordRecovery.SubmitButtonImageUrl, javascript, passwordRecovery.SubmitButtonText)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            End If
        End Sub

        '///////////////////////////////////////////////////////
        ' Step 2: question
        '///////////////////////////////////////////////////////

        Private Sub WriteQuestionPanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-PasswordRecovery-QuestionPanel", "")
            Extender.WriteReadOnlyTextBox(writer, passwordRecovery.LabelStyle.CssClass, passwordRecovery.QuestionLabelText, passwordRecovery.TextBoxStyle.CssClass, passwordRecovery.Question)
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub

        Private Sub WriteAnswerPanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            Dim container As Control = passwordRecovery.QuestionTemplateContainer
            Dim textBox As TextBox = Nothing
            If (Not IsNothing(container)) Then
                textBox = CType(container.FindControl("Answer"), TextBox)
            End If
            Dim rfv As RequiredFieldValidator = Nothing
            If (Not IsNothing(textBox)) Then
                rfv = CType(container.FindControl("AnswerRequired"), RequiredFieldValidator)
            End If
            Dim id As String = ""
            If (Not IsNothing(rfv)) Then
                id = container.ID & "_" & TextBox.ID
            End If
            If (Not String.IsNullOrEmpty(id)) Then
                Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-PasswordRecovery-AnswerPanel", "")
                Extender.WriteTextBox(writer, False, passwordRecovery.LabelStyle.CssClass, passwordRecovery.AnswerLabelText, passwordRecovery.TextBoxStyle.CssClass, id, "")
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, rfv, passwordRecovery.ValidatorTextStyle.CssClass, "Answer", passwordRecovery.AnswerRequiredErrorMessage)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        '///////////////////////////////////////////////////////
        ' Step 3: success
        '///////////////////////////////////////////////////////

        Private Sub WriteSuccessTextPanel(ByVal writer As HtmlTextWriter, ByVal passwordRecovery As PasswordRecovery)
            If (Not String.IsNullOrEmpty(passwordRecovery.SuccessText)) Then
                Dim className As String = ""
                If ((Not IsNothing(passwordRecovery.SuccessTextStyle)) AndAlso (Not String.IsNullOrEmpty(passwordRecovery.SuccessTextStyle.CssClass))) Then
                    className = passwordRecovery.SuccessTextStyle.CssClass & " "
                End If
                className &= "Kartris-PasswordRecovery-SuccessTextPanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", passwordRecovery.SuccessText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub
    End Class
End Namespace
