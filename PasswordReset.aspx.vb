'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation
Imports CkartrisBLL

Partial Class PasswordReset
    Inherits PageBaseClass

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Me.Load


        If Not String.IsNullOrEmpty(Request.QueryString("ref")) Then
            lblCurrentPassword.Text = GetGlobalResourceObject("Kartris", "FormLabel_EmailAddress")
            txtCurrentPassword.TextMode = TextBoxMode.SingleLine
            Dim strRef As String = Request.QueryString("ref")

        Else
            Response.Redirect(WebShopURL() & "CustomerAccount.aspx")
        End If

    End Sub



    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click
        If String.IsNullOrEmpty(Request.QueryString("ref")) Then
            Dim strUserPassword As String = txtCurrentPassword.Text
            Dim strNewPassword As String = txtNewPassword.Text

            'Only update if validators ok
            If Me.IsValid Then
                If Membership.ValidateUser(CurrentLoggedUser.Email, strUserPassword) Then
                    If UsersBLL.ChangePassword(CurrentLoggedUser.ID, strUserPassword, strNewPassword) > 0 Then UC_Updated.ShowAnimatedText()
                Else
                    Dim strErrorMessage As String = Replace(GetGlobalResourceObject("Kartris", "ContentText_CustomerCodeIncorrect"), "[label]", GetLocalResourceObject("FormLabel_ExistingCustomerCode"))
                    litWrongPassword.Text = "<span class=""error"">" & strErrorMessage & "</span>"
                End If
            End If

        Else
            Dim strRef As String = Request.QueryString("ref")
            Dim strEmailAddress As String = txtCurrentPassword.Text

            Dim dtbUserDetails As DataTable = UsersBLL.GetDetails(strEmailAddress)
            If dtbUserDetails.Rows.Count > 0 Then
                Dim intUserID As Integer = dtbUserDetails(0)("U_ID")
                Dim strTempPassword As String = FixNullFromDB(dtbUserDetails(0)("U_TempPassword"))
                Dim datExpiry As DateTime = IIf(IsDate(FixNullFromDB(dtbUserDetails(0)("U_TempPasswordExpiry"))), dtbUserDetails(0)("U_TempPasswordExpiry"),
                                            CkartrisDisplayFunctions.NowOffset.AddMinutes(-1))
                If String.IsNullOrEmpty(strTempPassword) Then datExpiry = CkartrisDisplayFunctions.NowOffset.AddMinutes(-1)

                If datExpiry > CkartrisDisplayFunctions.NowOffset Then
                    If UsersBLL.EncryptSHA256Managed(strTempPassword, UsersBLL.GetSaltByEmail(strEmailAddress)) = strRef Then
                        Dim intSuccess As Integer = UsersBLL.ChangePasswordViaRecovery(intUserID, txtConfirmPassword.Text)
                        If intSuccess = intUserID Then
                            UC_Updated.ShowAnimatedText()
                            Response.Redirect(WebShopURL() & "CustomerAccount.aspx?m=u")
                        Else
                            litWrongPassword.Text = "<span class=""error"">" & GetGlobalResourceObject("Kartris", "ContentText_ErrorText") & "</span>"
                        End If
                    Else
                        litWrongPassword.Text = "<span class=""error"">" & GetGlobalResourceObject("Kartris", "ContentText_LinkExpiredOrIncorrect") & "</span>"
                    End If

                Else
                    litWrongPassword.Text = "<span class=""error"">" & GetGlobalResourceObject("Kartris", "ContentText_LinkExpiredOrIncorrect") & "</span>"
                End If

            Else
                litWrongPassword.Text = "<span class=""error"">" & GetGlobalResourceObject("Kartris", "ContentText_NotFoundInDB") & "</span>"
            End If
        End If

    End Sub

End Class