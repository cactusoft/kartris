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
    Public Class CreateUserWizardAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter

        Private Enum State
            CreateUser
            Failed
            Success
        End Enum
        Dim _state As State = State.CreateUser
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

        Private ReadOnly Property WizardMembershipProvider() As MembershipProvider
            Get
                Dim provider As MembershipProvider = Membership.Provider
                Dim wizard As CreateUserWizard = Control
                If ((Not IsNothing(wizard)) AndAlso (Not String.IsNullOrEmpty(wizard.MembershipProvider)) AndAlso (Not IsNothing(Membership.Providers(wizard.MembershipProvider)))) Then
                    provider = Membership.Providers(wizard.MembershipProvider)
                End If
                Return provider
            End Get
        End Property

        Public Sub New()
            _state = State.CreateUser
            _currentErrorText = ""
        End Sub

        '/ ///////////////////////////////////////////////////////////////////////////////
        '/ PROTECTED        

        Protected Overrides Sub OnInit(ByVal e As EventArgs)
            MyBase.OnInit(e)

            Dim wizard As CreateUserWizard = Control
            If (Extender.AdapterEnabled AndAlso (Not IsNothing(wizard))) Then
                RegisterScripts()
                AddHandler wizard.CreatedUser, AddressOf OnCreatedUser
                AddHandler wizard.CreateUserError, AddressOf OnCreateUserError
                _state = State.CreateUser
                _currentErrorText = ""
            End If
        End Sub

        Protected Sub OnCreatedUser(ByVal sender As Object, ByVal e As EventArgs)
            _state = State.Success
            _currentErrorText = ""
        End Sub

        Protected Sub OnCreateUserError(ByVal sender As Object, ByVal e As CreateUserErrorEventArgs)
            _state = State.Failed
            _currentErrorText = "An error has occurred. Please try again."

            Dim wizard As CreateUserWizard = Control
            If (Not IsNothing(wizard)) Then
                _currentErrorText = wizard.UnknownErrorMessage
                Select Case e.CreateUserError
                    Case MembershipCreateStatus.DuplicateEmail
                        _currentErrorText = wizard.DuplicateEmailErrorMessage
                        Exit Select
                    Case MembershipCreateStatus.DuplicateUserName
                        _currentErrorText = wizard.DuplicateUserNameErrorMessage
                        Exit Select
                    Case MembershipCreateStatus.InvalidAnswer
                        _currentErrorText = wizard.InvalidAnswerErrorMessage
                        Exit Select
                    Case MembershipCreateStatus.InvalidEmail
                        _currentErrorText = wizard.InvalidEmailErrorMessage
                        Exit Select
                    Case MembershipCreateStatus.InvalidPassword
                        _currentErrorText = wizard.InvalidPasswordErrorMessage
                        Exit Select
                    Case MembershipCreateStatus.InvalidQuestion
                        _currentErrorText = wizard.InvalidQuestionErrorMessage
                        Exit Select
                End Select
            End If
        End Sub

        Protected Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If (Extender.AdapterEnabled) Then
                Extender.RenderBeginTag(writer, "Kartris-CreateUserWizard")
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
                Dim wizard As CreateUserWizard = Control
                If (Not IsNothing(wizard)) Then
                    Dim activeStep As TemplatedWizardStep = wizard.ActiveStep
                    If (Not IsNothing(activeStep)) Then
                        If (Not IsNothing(activeStep.ContentTemplate)) Then

                            'activeStep.RenderControl(writer)

                            'Medz edit - Added code to clear the controls inside the activestep before rendering
                            Dim creatediv As New WebControl(HtmlTextWriterTag.Div)
                            activeStep.ContentTemplate.InstantiateIn(creatediv)
                            activeStep.ContentTemplateContainer.Controls.Clear()
                            activeStep.ContentTemplateContainer.Controls.Add(creatediv)
                            creatediv.RenderControl(writer)

                            If (wizard.CreateUserStep.Equals(activeStep)) Then
                                WriteCreateUserButtonPanel(writer, wizard)
                            End If
                            ' Might need to add logic here to render nav buttons for other kinds of
                            ' steps (besides the CreateUser step, which we handle above).
                        ElseIf (wizard.CreateUserStep.Equals(activeStep)) Then
                            WriteHeaderTextPanel(writer, wizard)
                            WriteStepTitlePanel(writer, wizard)
                            WriteInstructionPanel(writer, wizard)
                            WriteHelpPanel(writer, wizard)
                            WriteUserPanel(writer, wizard)
                            WritePasswordPanel(writer, wizard)
                            WritePasswordHintPanel(writer, wizard)
                            WriteConfirmPasswordPanel(writer, wizard)
                            WriteEmailPanel(writer, wizard)
                            WriteQuestionPanel(writer, wizard)
                            WriteAnswerPanel(writer, wizard)
                            WriteFinalValidators(writer, wizard)
                            If (_state = State.Failed) Then
                                WriteFailurePanel(writer, wizard)
                            End If
                            WriteCreateUserButtonPanel(writer, wizard)
                        ElseIf (wizard.CompleteStep.Equals(activeStep)) Then
                            WriteStepTitlePanel(writer, wizard)
                            WriteSuccessTextPanel(writer, wizard)
                            WriteContinuePanel(writer, wizard)
                            WriteEditProfilePanel(writer, wizard)
                        Else
                            System.Diagnostics.Debug.Fail("The adapter isn't equipped to handle a CreateUserWizard with a step that is neither templated nor either the CreateUser step or the Complete step.")
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
        ' Step 1: Create user step
        '///////////////////////////////////////////////////////

        Private Sub WriteHeaderTextPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If (Not String.IsNullOrEmpty(wizard.HeaderText)) Then
                Dim className As String = ""
                If ((Not IsNothing(wizard.HeaderStyle)) AndAlso (Not String.IsNullOrEmpty(wizard.HeaderStyle.CssClass))) Then
                    className = wizard.HeaderStyle.CssClass & " "
                End If
                className &= "Kartris-CreateUserWizard-HeaderTextPanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", wizard.HeaderText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteStepTitlePanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If (Not String.IsNullOrEmpty(wizard.ActiveStep.Title)) Then
                Dim className As String = ""
                If ((Not IsNothing(wizard.TitleTextStyle)) AndAlso (Not String.IsNullOrEmpty(wizard.TitleTextStyle.CssClass))) Then
                    className = wizard.TitleTextStyle.CssClass & " "
                End If
                className &= "Kartris-CreateUserWizard-StepTitlePanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", wizard.ActiveStep.Title)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteInstructionPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If (Not String.IsNullOrEmpty(wizard.InstructionText)) Then
                Dim className As String = ""
                If ((Not IsNothing(wizard.InstructionTextStyle)) AndAlso (Not String.IsNullOrEmpty(wizard.InstructionTextStyle.CssClass))) Then
                    className = wizard.InstructionTextStyle.CssClass & " "
                End If
                className &= "Kartris-CreateUserWizard-InstructionPanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", wizard.InstructionText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteFailurePanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            Dim className As String = ""
            If ((Not IsNothing(wizard.ErrorMessageStyle)) AndAlso (Not String.IsNullOrEmpty(wizard.ErrorMessageStyle.CssClass))) Then
                className = wizard.ErrorMessageStyle.CssClass & " "
            End If
            className &= "Kartris-CreateUserWizard-FailurePanel"
            WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
            WebControlAdapterExtender.WriteSpan(writer, "", _currentErrorText)
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub

        Private Sub WriteHelpPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If ((Not String.IsNullOrEmpty(wizard.HelpPageIconUrl)) OrElse (Not String.IsNullOrEmpty(wizard.HelpPageText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-HelpPanel", "")
                WebControlAdapterExtender.WriteImage(writer, wizard.HelpPageIconUrl, "Help")
                WebControlAdapterExtender.WriteLink(writer, wizard.HyperLinkStyle.CssClass, wizard.HelpPageUrl, "Help", wizard.HelpPageText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteUserPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            Dim textBox As TextBox = wizard.FindControl("CreateUserStepContainer").FindControl("UserName")
            If (Not IsNothing(textBox)) Then
                Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-UserPanel", "")
                Extender.WriteTextBox(writer, False, wizard.LabelStyle.CssClass, wizard.UserNameLabelText, wizard.TextBoxStyle.CssClass, "CreateUserStepContainer_UserName", wizard.UserName)
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("UserNameRequired"), RequiredFieldValidator), wizard.ValidatorTextStyle.CssClass, "UserName", wizard.UserNameRequiredErrorMessage)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WritePasswordPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            Dim textBox As TextBox = wizard.FindControl("CreateUserStepContainer").FindControl("Password")
            If (Not IsNothing(textBox)) Then
                Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-PasswordPanel", "")
                Extender.WriteTextBox(writer, True, wizard.LabelStyle.CssClass, wizard.PasswordLabelText, wizard.TextBoxStyle.CssClass, "CreateUserStepContainer_Password", "")
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("PasswordRequired"), RequiredFieldValidator), wizard.ValidatorTextStyle.CssClass, "Password", wizard.PasswordRequiredErrorMessage)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WritePasswordHintPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If (Not String.IsNullOrEmpty(wizard.PasswordHintText)) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-PasswordHintPanel", "")
                WebControlAdapterExtender.WriteSpan(writer, "", wizard.PasswordHintText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteConfirmPasswordPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            Dim textBox As TextBox = wizard.FindControl("CreateUserStepContainer").FindControl("ConfirmPassword")
            If (Not IsNothing(textBox)) Then
                Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-ConfirmPasswordPanel", "")
                Extender.WriteTextBox(writer, True, wizard.LabelStyle.CssClass, wizard.ConfirmPasswordLabelText, wizard.TextBoxStyle.CssClass, "CreateUserStepContainer_ConfirmPassword", "")
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("ConfirmPasswordRequired"), RequiredFieldValidator), wizard.ValidatorTextStyle.CssClass, "ConfirmPassword", wizard.ConfirmPasswordRequiredErrorMessage)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteEmailPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            Dim textBox As TextBox = wizard.FindControl("CreateUserStepContainer").FindControl("Email")
            If (Not IsNothing(textBox)) Then
                Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-EmailPanel", "")
                Extender.WriteTextBox(writer, False, wizard.LabelStyle.CssClass, wizard.EmailLabelText, wizard.TextBoxStyle.CssClass, "CreateUserStepContainer_Email", "")
                WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("EmailRequired"), RequiredFieldValidator), wizard.ValidatorTextStyle.CssClass, "Email", wizard.EmailRequiredErrorMessage)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteQuestionPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If ((Not IsNothing(WizardMembershipProvider)) AndAlso WizardMembershipProvider.RequiresQuestionAndAnswer) Then
                Dim textBox As TextBox = wizard.FindControl("CreateUserStepContainer").FindControl("Question")
                If (Not IsNothing(textBox)) Then
                    Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                    WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-QuestionPanel", "")
                    Extender.WriteTextBox(writer, False, wizard.LabelStyle.CssClass, wizard.QuestionLabelText, wizard.TextBoxStyle.CssClass, "CreateUserStepContainer_Question", "")
                    WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("QuestionRequired"), RequiredFieldValidator), wizard.ValidatorTextStyle.CssClass, "Question", wizard.QuestionRequiredErrorMessage)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            End If
        End Sub

        Private Sub WriteAnswerPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If ((Not IsNothing(WizardMembershipProvider)) AndAlso WizardMembershipProvider.RequiresQuestionAndAnswer) Then
                Dim textBox As TextBox = wizard.FindControl("CreateUserStepContainer").FindControl("Answer")
                If (Not IsNothing(textBox)) Then
                    Page.ClientScript.RegisterForEventValidation(textBox.UniqueID)
                    WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-AnswerPanel", "")
                    Extender.WriteTextBox(writer, False, wizard.LabelStyle.CssClass, wizard.AnswerLabelText, wizard.TextBoxStyle.CssClass, "CreateUserStepContainer_Answer", "")
                    WebControlAdapterExtender.WriteRequiredFieldValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("AnswerRequired"), RequiredFieldValidator), wizard.ValidatorTextStyle.CssClass, "Answer", wizard.AnswerRequiredErrorMessage)
                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            End If
        End Sub

        Private Sub WriteFinalValidators(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-FinalValidatorsPanel", "")
            WebControlAdapterExtender.WriteCompareValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("PasswordCompare"), CompareValidator), wizard.ValidatorTextStyle.CssClass, "ConfirmPassword", wizard.ConfirmPasswordCompareErrorMessage, "Password")
            WebControlAdapterExtender.WriteRegularExpressionValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("PasswordRegExpValidator"), RegularExpressionValidator), wizard.ValidatorTextStyle.CssClass, "Password", wizard.PasswordRegularExpressionErrorMessage, wizard.PasswordRegularExpression)
            WebControlAdapterExtender.WriteRegularExpressionValidator(writer, CType(wizard.FindControl("CreateUserStepContainer").FindControl("EmailRegExpValidator"), RegularExpressionValidator), wizard.ValidatorTextStyle.CssClass, "Email", wizard.EmailRegularExpressionErrorMessage, wizard.EmailRegularExpression)
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub

        Private Sub WriteCreateUserButtonPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            Dim btnParentCtrl As Control = wizard.FindControl("__CustomNav0")
            If Not btnParentCtrl Is Nothing Then
                Dim id As String = "_CustomNav0_StepNextButton"
                Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType("StepNextButton", wizard.CreateUserButtonType)
                Dim btn As Control = btnParentCtrl.FindControl(idWithType)
                If (Not IsNothing(btn)) Then
                    Page.ClientScript.RegisterForEventValidation(btn.UniqueID)

                    Dim options As PostBackOptions = New PostBackOptions(btn, "", "", False, False, False, True, True, wizard.ID)
                    Dim javascript As String = "javascript:" + Page.ClientScript.GetPostBackEventReference(options)
                    javascript = Page.Server.HtmlEncode(javascript)

                    WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-CreateUserButtonPanel", "")

                    Extender.WriteSubmit(writer, wizard.CreateUserButtonType, wizard.CreateUserButtonStyle.CssClass, id, wizard.CreateUserButtonImageUrl, javascript, wizard.CreateUserButtonText)

                    If (wizard.DisplayCancelButton) Then
                        Extender.WriteSubmit(writer, wizard.CancelButtonType, wizard.CancelButtonStyle.CssClass, "_CustomNav0_CancelButton", wizard.CancelButtonImageUrl, "", wizard.CancelButtonText)
                    End If

                    WebControlAdapterExtender.WriteEndDiv(writer)
                End If
            End If
        End Sub

        '///////////////////////////////////////////////////////
        ' Complete step
        '///////////////////////////////////////////////////////

        Private Sub WriteSuccessTextPanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If (Not String.IsNullOrEmpty(wizard.CompleteSuccessText)) Then
                Dim className As String = ""
                If ((Not IsNothing(wizard.CompleteSuccessTextStyle)) AndAlso (Not String.IsNullOrEmpty(wizard.CompleteSuccessTextStyle.CssClass))) Then
                    className = wizard.CompleteSuccessTextStyle.CssClass & " "
                End If
                className &= "Kartris-CreateUserWizard-SuccessTextPanel"
                WebControlAdapterExtender.WriteBeginDiv(writer, className, "")
                WebControlAdapterExtender.WriteSpan(writer, "", wizard.CompleteSuccessText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteContinuePanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            Dim id As String = "ContinueButton"
            Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType(id, wizard.ContinueButtonType)
            Dim btn As Control = wizard.FindControl("CompleteStepContainer").FindControl(idWithType)
            If (Not IsNothing(btn)) Then
                Page.ClientScript.RegisterForEventValidation(btn.UniqueID)
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-ContinuePanel", "")
                Extender.WriteSubmit(writer, wizard.ContinueButtonType, wizard.ContinueButtonStyle.CssClass, "CompleteStepContainer_ContinueButton", wizard.ContinueButtonImageUrl, "", wizard.ContinueButtonText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub

        Private Sub WriteEditProfilePanel(ByVal writer As HtmlTextWriter, ByVal wizard As CreateUserWizard)
            If ((Not String.IsNullOrEmpty(wizard.EditProfileUrl)) OrElse (Not String.IsNullOrEmpty(wizard.EditProfileText))) Then
                WebControlAdapterExtender.WriteBeginDiv(writer, "Kartris-CreateUserWizard-EditProfilePanel", "")
                WebControlAdapterExtender.WriteImage(writer, wizard.EditProfileIconUrl, "Edit profile")
                WebControlAdapterExtender.WriteLink(writer, wizard.HyperLinkStyle.CssClass, wizard.EditProfileUrl, "EditProfile", wizard.EditProfileText)
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub
    End Class
End Namespace
