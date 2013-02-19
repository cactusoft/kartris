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
Imports CkartrisEnumerations

Partial Class Admin_LoginsList

    Inherits _PageBaseClass

    Private Shared intSelectedLoginID As Integer
    Private Shared Login_Protected As Boolean
    Private Shared LOGIN_LanguageID As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetLocalResourceObject("PageTitle_Logins") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub gvwLogins_RowEditing(ByVal sender As Object, ByVal e As GridViewEditEventArgs) Handles gvwLogins.RowEditing
        hidLoginID.Value = e.NewEditIndex
    End Sub

    Protected Sub gvwLogins_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles gvwLogins.RowDataBound
        ' hide delete button if login is protected
        If e.Row.DataItem IsNot Nothing Then
            Dim LoginRow As DataRowView = CType(e.Row.DataItem, DataRowView)
            Login_Protected = LoginRow("LOGIN_Protected")
            If Login_Protected Then
                DirectCast(e.Row.Cells(8).Controls(0), LinkButton).Visible = False
            End If
        End If
    End Sub

    Private Sub EditLogin(ByVal src As Object, ByVal e As GridViewCommandEventArgs) Handles gvwLogins.RowCommand

        ' get the row index stored in the CommandArgument property 
        Dim intRowIndex As Integer = Convert.ToInt32(e.CommandArgument)

        ' get the GridViewRow where the command is raised 
        Dim rowLogins As GridViewRow = DirectCast(e.CommandSource, GridView).Rows(intRowIndex)

        intSelectedLoginID = CInt(DirectCast(rowLogins.Cells(5).Controls(1), HiddenField).Value)
        Login_Protected = CBool(DirectCast(rowLogins.Cells(6).Controls(1), HiddenField).Value)
        Dim LOGIN_UserName As String = rowLogins.Cells(0).Text

        If e.CommandName = "DeleteLogins" Then
            If Not Login_Protected Then
                Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", LOGIN_UserName)
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
            End If
        Else
            txtPassword.Visible = False
            valRequiredUserPassword.Enabled = False
            lblPassword.Visible = True
            btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "ContentText_ConfigChange2")
            btnChangePassword.Visible = True

            Call EnableAll()
            Dim LOGIN_EmailAddress As String = rowLogins.Cells(1).Text
            Dim LOGIN_Password As String = rowLogins.Cells(2).Text
            Dim LOGIN_Config As CheckBox = rowLogins.Cells(3).Controls(1)
            Dim LOGIN_Products As CheckBox = rowLogins.Cells(3).Controls(3)
            Dim LOGIN_Orders As CheckBox = rowLogins.Cells(3).Controls(5)
            Dim LOGIN_Tickets As CheckBox = rowLogins.Cells(3).Controls(7)
            Dim LOGIN_Live As CheckBox = rowLogins.Cells(4).Controls(1)


            LOGIN_LanguageID = CInt(DirectCast(rowLogins.Cells(7).Controls(1), HiddenField).Value)

            radNo.Checked = Not LOGIN_Live.Checked
            radYes.Checked = LOGIN_Live.Checked

            chkLoginEditConfig.Checked = LOGIN_Config.Checked
            chkLoginEditProducts.Checked = LOGIN_Products.Checked
            chkLoginEditOrders.Checked = LOGIN_Orders.Checked
            chkLoginEditTickets.Checked = LOGIN_Tickets.Checked

            If Login_Protected Then
                chkLoginEditConfig.Enabled = False
                chkLoginEditOrders.Enabled = False
                chkLoginEditProducts.Enabled = False
                chkLoginEditTickets.Enabled = False
                radYes.Enabled = False
                radNo.Enabled = False
            End If

            txtPassword.Text = LOGIN_Password
            txtUsername.Text = LOGIN_UserName
            txtEmailAddress.Text = LOGIN_EmailAddress

            ddlLanguages.SelectedValue = LOGIN_LanguageID

            ' hide the gridview
            gvwLogins.Visible = False
        End If

    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If intSelectedLoginID = LoginsBLL.Delete(intSelectedLoginID) Then
            gvwLogins.DataBind()
            updMain.Update()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_Error"))
        End If

    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        pnlEdit.Visible = False
        gvwLogins.Visible = True
    End Sub

    Protected Sub lnkNewLogin_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNewLogin.Click
        Call EnableAll()

        intSelectedLoginID = 0
        Login_Protected = False
        LOGIN_LanguageID = 1

        radNo.Checked = True
        radYes.Checked = False
        chkLoginEditConfig.Checked = False
        chkLoginEditProducts.Checked = False
        chkLoginEditOrders.Checked = False
        chkLoginEditTickets.Checked = False
        btnChangePassword.Visible = False

        txtPassword.Text = ""
        txtEmailAddress.Text = ""
        txtUsername.Text = ""
        ddlLanguages.SelectedValue = LOGIN_LanguageID

        txtPassword.Visible = True
        valRequiredUserPassword.Enabled = True
        lblPassword.Visible = False

        ' hide the gridview
        gvwLogins.Visible = False
    End Sub

    Private Sub EnableAll()
        pnlEdit.Visible = True
        chkLoginEditConfig.Enabled = True
        chkLoginEditOrders.Enabled = True
        chkLoginEditProducts.Enabled = True
        chkLoginEditTickets.Enabled = True
        radYes.Enabled = True
        radNo.Enabled = True
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        If UserNameExist() Then Exit Sub
        Page.Validate("UserDetails")
        If Page.IsValid Then
            If intSelectedLoginID = 0 Then
                LoginsBLL.Add(txtUsername.Text, txtPassword.Text, radYes.Checked, chkLoginEditOrders.Checked, chkLoginEditProducts.Checked, chkLoginEditConfig.Checked, Login_Protected, ddlLanguages.SelectedValue, txtEmailAddress.Text, chkLoginEditTickets.Checked)
            ElseIf intSelectedLoginID > 0 Then
                Dim strPassword As String
                If txtPassword.Visible Then strPassword = txtPassword.Text Else strPassword = ""
                LoginsBLL.Update(intSelectedLoginID, txtUsername.Text, strPassword, radYes.Checked, chkLoginEditOrders.Checked, chkLoginEditProducts.Checked, chkLoginEditConfig.Checked, Login_Protected, ddlLanguages.SelectedValue, txtEmailAddress.Text, chkLoginEditTickets.Checked)
                txtPassword.Visible = False
                valRequiredUserPassword.Enabled = False
                lblPassword.Visible = True
                btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "ContentText_ConfigChange2")
            End If
            pnlEdit.Visible = False
            gvwLogins.Visible = True
            gvwLogins.DataBind()
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub

    Function UserNameExist() As Boolean
        For Each row As GridViewRow In gvwLogins.Rows
            If row.RowType = DataControlRowType.DataRow Then
                If intSelectedLoginID <> CInt(DirectCast(row.Cells(5).Controls(1), HiddenField).Value) Then
                    If row.Cells(0).Text.ToLower = txtUsername.Text.ToLower Then
                        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Login", "ContentText_UserNameAlreadyExist"))
                        Return True
                    End If
                End If
            End If
        Next
        Return False
    End Function

    Protected Sub btnChangePassword_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If txtPassword.Visible Then
            txtPassword.Visible = False
            valRequiredUserPassword.Enabled = False
            lblPassword.Visible = True
            btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "ContentText_ConfigChange2")
        Else
            txtPassword.Visible = True
            valRequiredUserPassword.Enabled = True
            lblPassword.Visible = False
            btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "FormButton_Cancel")
        End If
    End Sub
End Class
