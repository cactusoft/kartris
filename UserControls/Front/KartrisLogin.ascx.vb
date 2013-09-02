'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System
Imports KartSettingsManager
Imports System.Web.HttpContext
Imports CkartrisDataManipulation
Imports CkartrisBLL


Partial Class KartrisLogin
    Inherits System.Web.UI.UserControl

    Private strEmail As String
    Private strForSection As String

    Public ReadOnly Property UserEmailAddress() As String
        Get
            If Page.User.Identity.IsAuthenticated Then
                Return Page.User.Identity.Name
            Else
                If String.IsNullOrEmpty(strEmail) Then Return Session("C_Email") Else Return strEmail
            End If
        End Get
    End Property

    Public ReadOnly Property UserPassword() As String
        Get
            Return Session("_NewPassword")
        End Get
    End Property

    Public Property Cleared() As Boolean
        Get
            If Session("blnLoginCleared") Is Nothing Then
                Session("blnLoginCleared") = False
            End If
            Return Session("blnLoginCleared")
        End Get
        Set(ByVal value As Boolean)
            Session("blnLoginCleared") = value
        End Set
    End Property

    Public Property ForSection() As String
        Get
            Return strForSection
        End Get
        Set(ByVal value As String)
            strForSection = value
        End Set
    End Property

    Public Event JustAuthenticated()

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If Not Page.IsPostBack Then
            If Not Page.User.Identity.IsAuthenticated And Request.QueryString("new") <> "y" Then
                Session("blnLoginCleared") = False
            End If
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Not Page.User.Identity.IsAuthenticated Then
                Dim strUserAccess As String = LCase(GetKartConfig("frontend.users.access"))
                If strUserAccess = "yes" Or strUserAccess = "browse" Then
                    rblNeworOld.Items.Remove(rblNeworOld.Items.FindByValue("New"))
                    SelectExistingCustomerOption()
                End If

                If Not String.IsNullOrEmpty(Request.QueryString("m")) Then
                    If Request.QueryString("m") = "u" Then litMessage.Text = "<li><div class=""updatemessage"">" & GetGlobalResourceObject("Login", "ContentText_PasswordUpdated") & "</div></li>"
                    SelectExistingCustomerOption()
                End If
                txtUserPassword.Attributes.Add("onkeydown", "if(event.which || event.keyCode){if ((event.which == 13) || (event.keyCode == 13)) {document.getElementById('" + btnSignIn.ClientID + "').click();return false;}} else {return true}; ")
            End If
        End If
    End Sub

    Private Sub SelectExistingCustomerOption()
        phdEmail.Visible = True
        phdPassword.Visible = True
        phdSubmitButtons.Visible = True
        rblNeworOld.SelectedValue = "Existing"
    End Sub

    Public Function CheckEmailExist(ByVal strEmailAddress As String) As Boolean
        Dim tblUserDetails As System.Data.DataTable = UsersBLL.GetDetails(strEmailAddress)
        If tblUserDetails.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    'Set which page to redirect to after login
    Public Function RedirectTo(Optional ByVal blnNew As Boolean = False) As String

        Dim strRedirectTo As String = ""
        Select Case Me.ForSection
            Case "checkout"
                strRedirectTo = "~/Checkout.aspx"
                If blnNew Then strRedirectTo += "?new=y"
            Case "myaccount"
                strRedirectTo = "~/Customer.aspx"
            Case "support"
                strRedirectTo = "~/CustomerTickets.aspx"
            Case Else
                strRedirectTo = "~/Error.aspx"
        End Select
        Return strRedirectTo
    End Function

    Protected Sub btnSignIn_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSignIn.Click
        Page.Validate("Checkout")
        If Page.IsValid Then

            Dim strFldEmailAddress As String = C_Email.Text
            Dim strUserPassword As String = txtUserPassword.Text
            If rblNeworOld.SelectedValue = "New" Then
                'New Customer
                If Not CheckEmailExist(strFldEmailAddress) Then
                    litTitle.Text = "New Customer - Enter Details"
                    mvwLoginPopup.ActiveViewIndex = "0"
                    popLogin.OkControlID = ""
                    txtNewEmail.Text = C_Email.Text

                    Dim strUserPasswordRule As String = GetKartConfig("frontend.users.password.required")
                    Select Case strUserPasswordRule.ToLower
                        Case "automatic"
                            'automatic (password is randomly generated for the customer like in CactuShop prior to v6)
                            phdNewPassword.Visible = False
                        Case "optional"
                            'optional (if not specified, randomly generated)
                            psNewPassword.Enabled = False
                            lblPasswordOptional.Visible = True
                        Case "required"
                            'required (customer must enter a password during checkout).
                            psNewPassword.Enabled = True
                            lblPasswordOptional.Visible = False
                    End Select

                    txtConfirmEmail.Focus()
                Else

                    popLogin.OkControlID = "btnOk"
                    mvwLoginPopup.ActiveViewIndex = "1"
                    litTitle.Text = GetGlobalResourceObject("Kartris", "PageTitle_Problems")
                    litErrorDetails.Text = GetLocalResourceObject("ContentText_EmailAddressAlreadyExists")
                End If

            ElseIf rblNeworOld.SelectedValue = "Existing" Then
                'Existing customer check
                If String.IsNullOrEmpty(strUserPassword) Then

                    popLogin.OkControlID = "btnOk"
                    mvwLoginPopup.ActiveViewIndex = "1"
                    litTitle.Text = GetGlobalResourceObject("Kartris", "PageTitle_Problems")
                    litErrorDetails.Text = GetLocalResourceObject("ContentText_EmailAddressAlreadyExists")
                Else
                    If Membership.ValidateUser(strFldEmailAddress, strUserPassword) Then
                        Session("blnLoginCleared") = True
                        FormsAuthentication.SetAuthCookie(strFldEmailAddress, True)

                        strEmail = strFldEmailAddress

                        Response.Redirect(RedirectTo())

                    Else
                        popLogin.OkControlID = "btnOk"
                        mvwLoginPopup.ActiveViewIndex = "1"
                        litTitle.Text = GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors")
                        litErrorDetails.Text = GetGlobalResourceObject("Login", "ContentText_NoMatch")
                    End If
                End If
            Else
                popLogin.OkControlID = "btnOk"
                mvwLoginPopup.ActiveViewIndex = "1"
                litTitle.Text = GetGlobalResourceObject("Kartris", "PageTitle_Problems")
                litErrorDetails.Text = GetGlobalResourceObject("Kartris", "ContentText_NoSelection")
            End If
            popLogin.Show()
        End If

    End Sub

    Protected Sub btnContinue_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnContinue.Click
        Dim strUserPasswordRule As String = GetKartConfig("frontend.users.password.required")
        'check if either password or confirm password field has a value
        Dim blnValueEntered As Boolean = False
        Dim strNewPassword = Trim(txtNewPassword.Text)
        If Not String.IsNullOrEmpty(strNewPassword) Then blnValueEntered = True
        If Not String.IsNullOrEmpty(Trim(txtConfirmPassword.Text)) Then blnValueEntered = True

        If txtNewEmail.Text <> txtConfirmEmail.Text Then
            litFailureText.Text = "<div class=""errortext"">" & GetLocalResourceObject("ContentText_EmailsMustMatch") & "</div>"
            popLogin.Show()
        ElseIf (txtNewPassword.Text <> txtConfirmPassword.Text) AndAlso (strUserPasswordRule = "required" Or blnValueEntered) Then
            litFailureText.Text = "<div class=""errortext"">" & GetLocalResourceObject("ContentText_PasswordsMustMatch") & "</div>"
            popLogin.Show()
        ElseIf (String.IsNullOrEmpty(txtNewPassword.Text.Trim) Or String.IsNullOrEmpty(txtConfirmPassword.Text.Trim)) AndAlso (strUserPasswordRule = "required" Or blnValueEntered) Then
            litFailureText.Text = "<div class=""errortext"">" & GetGlobalResourceObject("Kartris", "ContentText_SomeFieldsBlank") & "</div>"
            popLogin.Show()
        Else

            strEmail = txtNewEmail.Text
            Session("C_Email") = txtNewEmail.Text
            Dim strPassword As String = ""
            If strUserPasswordRule.ToLower = "automatic" Or String.IsNullOrEmpty(strNewPassword) Then strPassword = Membership.GeneratePassword(10, 0) Else strPassword = strNewPassword
            Session("_NewPassword") = strPassword
            Session("blnLoginCleared") = True
            litFailureText.Text = ""
            If ForSection = "myaccount" Or ForSection = "support" Then
                Dim intUserID As Integer = UsersBLL.Add(strEmail, strPassword)
                If intUserID > 0 And Membership.ValidateUser(strEmail, strPassword) Then
                    If KartSettingsManager.GetKartConfig("frontend.users.emailnewaccountdetails") = "y" Then
                        'Build up email text
                        Dim strSubject As String = GetGlobalResourceObject("Email", "Config_SubjectLine5")
                        Dim sbEmailText As StringBuilder = New StringBuilder
                        sbEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpHeader") & vbCrLf & vbCrLf)
                        sbEmailText.Append(GetGlobalResourceObject("Email", "EmailText_EmailAddress") & strEmail & vbCrLf)
                        sbEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerCode") & strPassword & vbCrLf & vbCrLf)
                        sbEmailText.Append(GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter1") & CkartrisBLL.WebShopURL & "customer.aspx" & GetGlobalResourceObject("Email", "EmailText_CustomerSignedUpFooter2"))
                        sbEmailText.Replace("<br>", vbCrLf).Replace("<br />", vbCrLf)

                        Dim blnHTMLEmail As Boolean = KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y"
                        If blnHTMLEmail Then
                            Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("NewCustomerSignUp")
                            'build up the HTML email if template is found
                            If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                                strHTMLEmailText = strHTMLEmailText.Replace("[webshopurl]", WebShopURL)
                                strHTMLEmailText = strHTMLEmailText.Replace("[websitename]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                                strHTMLEmailText = strHTMLEmailText.Replace("[customeremail]", strEmail)
                                strHTMLEmailText = strHTMLEmailText.Replace("[customerpassword]", strPassword)
                                sbEmailText.Clear()
                                sbEmailText.Append(strHTMLEmailText)
                            End If
                        End If

                        'Send the email
                        SendEmail(LanguagesBLL.GetEmailFrom(CInt(Session("LANG"))), strEmail, strSubject, sbEmailText.ToString)
                    End If
                    Session("_NewPassword") = Nothing
                    FormsAuthentication.SetAuthCookie(strEmail, True)
                End If
            End If

            Response.Redirect(RedirectTo(True))
        End If

    End Sub

    Protected Sub rblNeworOld_Select(ByVal Sender As Object, ByVal e As System.EventArgs) Handles rblNeworOld.SelectedIndexChanged
        If rblNeworOld.SelectedValue = "New" Then
            phdEmail.Visible = True
            phdPassword.Visible = False
            phdSubmitButtons.Visible = True
        ElseIf rblNeworOld.SelectedValue = "Existing" Then
            phdEmail.Visible = True
            phdPassword.Visible = True
            phdSubmitButtons.Visible = True
        End If
        C_Email.Focus()
    End Sub

    Protected Sub btnRecover_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Page.Validate("RecoverPassword")
        Dim strEmailAddress As String = DirectCast(PasswordRecover.UserNameTemplateContainer.FindControl("UserName"), TextBox).Text
        If Page.IsValid Then
            Dim dtUserDetails As DataTable = UsersBLL.GetDetails(strEmailAddress)
            If dtUserDetails.Rows.Count > 0 Then
                Dim intUserID As Integer = dtUserDetails(0)("U_ID")
                Dim strTempPassword As String = FixNullFromDB(dtUserDetails(0)("U_TempPassword"))
                Dim dateExpiry As DateTime = IIf(IsDate(FixNullFromDB(dtUserDetails(0)("U_TempPasswordExpiry"))), dtUserDetails(0)("U_TempPasswordExpiry"), _
                                            CkartrisDisplayFunctions.NowOffset.AddMinutes(-1))
                If String.IsNullOrEmpty(strTempPassword) Then dateExpiry = Now.AddMinutes(-1)

                If dateExpiry < CkartrisDisplayFunctions.NowOffset Or String.IsNullOrEmpty(strTempPassword) Then
                    Dim strRandomPassword As String = Membership.GeneratePassword(12, 0)
                    Dim strOldSalt As String = UsersBLL.GetSaltByEmail(strEmailAddress)
                    Dim intSuccess As Integer = UsersBLL.ResetPassword(intUserID, strRandomPassword)
                    If intSuccess = intUserID Then
                        litRecoveryMessage.Text = GetLocalResourceObject("ContentText_CustomerNumberEmailSent") & " " & strEmailAddress
                        Dim strPasswordResetLink As String = CkartrisBLL.WebShopURL & "CustomerDetails.aspx?ref=" & HttpUtility.UrlEncode(UsersBLL.EncryptSHA256Managed(UsersBLL.EncryptSHA256Managed(strRandomPassword, strOldSalt), strOldSalt))

                        Dim strBodyText As String = GetGlobalResourceObject("Email", "EmailText_CustomerNumberDesc") & " " & _
                            GetGlobalResourceObject("Kartris", "Config_Webshopname") & vbCrLf & vbCrLf
                        strBodyText += GetGlobalResourceObject("Kartris", "FormLabel_EmailAddress") & ": " & strEmailAddress & vbCrLf
                        strBodyText += GetGlobalResourceObject("Kartris", "ContentText_ChangePasswordLink") & vbCrLf & vbCrLf & strPasswordResetLink

                        Dim strSubjectLine As String = GetGlobalResourceObject("Email", "EmailText_CustomerNumberSubject") & " " & _
                            GetGlobalResourceObject("Kartris", "Config_Webshopname")

                        Dim intCurrentLanguage As Byte = GetLanguageIDfromSession()

                        Dim blnHTMLEmail As Boolean = KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y"
                        If blnHTMLEmail Then
                            Dim strHTMLEmailText As String = RetrieveHTMLEmailTemplate("PasswordReset")
                            'build up the HTML email if template is found
                            If Not String.IsNullOrEmpty(strHTMLEmailText) Then
                                strHTMLEmailText = strHTMLEmailText.Replace("[passwordresetlink]", strPasswordResetLink)
                                strHTMLEmailText = strHTMLEmailText.Replace("[customeremail]", strEmailAddress)
                                strHTMLEmailText = strHTMLEmailText.Replace("[websitename]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
                                strBodyText = strHTMLEmailText
                            Else
                                blnHTMLEmail = False
                            End If
                        End If

                        SendEmail(LanguagesBLL.GetEmailFrom(intCurrentLanguage), strEmailAddress, strSubjectLine, strBodyText, , , , , blnHTMLEmail)
                    Else
                        litRecoveryMessage.Text = GetGlobalResourceObject("Kartris", "ContentText_ErrorText")
                    End If
                Else
                    litRecoveryMessage.Text = GetGlobalResourceObject("Kartris", "ContentText_PasswordRequestAlreadySubmitted")
                End If

            Else
                litRecoveryMessage.Text = GetGlobalResourceObject("Kartris", "ContentText_NotFoundInDB")
            End If
        End If
        popRecovery.Show()

    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If String.IsNullOrEmpty(Current.Session("Back_Auth")) AndAlso Not Request.IsSecureConnection Then
            SSLHandler.RedirectToSecuredPage()
        End If
    End Sub
End Class
