'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

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
Imports CkartrisEnumerations

Partial Class UserControls_Back_UserDetails

    Inherits System.Web.UI.UserControl

    Public Event _UCEvent_DataUpdated()

    Protected Sub _UC_AddressDetails__UCEvent_DataUpdated() Handles _UC_Billing._UCEvent_DataUpdated, _UC_Shipping._UCEvent_DataUpdated
        RaiseEvent _UCEvent_DataUpdated()
        updUser.Update()
    End Sub

    Protected Function GetCustomerID() As Integer
        Try
            Return CInt(Request.QueryString("CustomerID"))
        Catch ex As Exception
        End Try
        Return 0
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'Export for GDPR
            If Request.QueryString("Export") = "y" Then
                btnGDPRExport_Click()
                Response.End()
            End If

            'Format back link - if we detect is coming from customer
            'list, we format back link to there with saved parameters.
            'Otherwise, create javascript history back link.
            If Request.QueryString("Page") <> "" Then
                lnkBack.NavigateUrl = "~/Admin/_CustomersList.aspx?Page=" & Request.QueryString("Page") & "&strSearch=" & Request.QueryString("strSearch")
            Else
                lnkBack.NavigateUrl = "javascript:history.back()"
            End If

            ViewState("Referer") = Request.ServerVariables("HTTP_REFERER")
            If Trim(Request.QueryString("CustomerID")) <> "" Then
                Try
                    'C_ID = CInt(Request.QueryString("CustomerID"))
                    Dim dtUserDetails As DataTable = UsersBLL._GetCustomerDetails(GetCustomerID())
                    fvwUser.DataSource = dtUserDetails
                    fvwUser.DataBind()
                    If ViewState("isNewUser") Then
                        RaiseEvent _UCEvent_DataUpdated()
                        ViewState("isNewUser") = Nothing
                    Else
                        Dim objOrdersBLL As New OrdersBLL
                        Dim dblOrdersTotal As Double = objOrdersBLL._GetOrderTotalByCustomerID(GetCustomerID())
                        Dim dblPaymentsTotal As Double = objOrdersBLL._GetPaymentTotalByCustomerID(GetCustomerID())
                        If Not (dblOrdersTotal = 0 And dblPaymentsTotal = 0) Then
                            Dim dblCustomerBalance As Double = CkartrisDataManipulation.FixNullFromDB(dtUserDetails(0)("U_CustomerBalance"))
                            Dim dblUpdatedBalance As Double = dblPaymentsTotal - dblOrdersTotal
                            Dim dtbUserOrders As DataTable = objOrdersBLL._GetByStatus(OrdersBLL.ORDERS_LIST_CALLMODE.CUSTOMER, 0, , , , , GetCustomerID())
                            'Filter to show only finished orders and those that were not cancelled
                            Dim drwFiltered As DataRow() = dtbUserOrders.Select("CO_OrderID IS NULL AND O_SENT = 1")
                            gvwCustomerOrders.DataSource = drwFiltered
                            gvwCustomerOrders.DataBind()
                            gvwCustomerPayments.DataSource = objOrdersBLL._GetPaymentByCustomerID(GetCustomerID())
                            gvwCustomerPayments.DataBind()
                            litOrdersTotalValue.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, dblOrdersTotal)
                            litPaymentsTotalValue.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, dblPaymentsTotal)
                            If dblCustomerBalance <> dblUpdatedBalance Then UsersBLL.UpdateCustomerBalance(GetCustomerID(), dblUpdatedBalance)
                        Else
                            'Hide Payment / Order History Tab
                            Dim tabContainer As AjaxControlToolkit.TabContainer = fvwUser.FindControl("tabContainerUser")
                            Dim tab As AjaxControlToolkit.TabPanel = tabContainer.FindControl("tabPaymentHistory")
                            If tab IsNot Nothing Then
                                tab.Enabled = False
                            End If
                        End If
                    End If
                    If Trim(Request.QueryString("tab")) <> "" Then
                        Dim strTab As String = Request.QueryString("tab")
                        If strTab = "a" Then
                            Dim tab As AjaxControlToolkit.TabContainer = fvwUser.FindControl("tabContainerUser")
                            If tab IsNot Nothing Then tab.ActiveTabIndex = 1
                        End If
                    End If

                Catch ex As Exception
                    CkartrisFormatErrors.LogError(ex.ToString)
                End Try
            Else
                'C_ID = 0
                fvwUser.DefaultMode = FormViewMode.Insert

            End If

            'v3 mod
            'Object config now available for categories
            Try
                _UC_ObjectConfig.ItemID = GetCustomerID()
                If Not IsPostBack Then
                    _UC_ObjectConfig.LoadObjectConfig()
                End If
            Catch ex As Exception
                'will fail if creating new user
            End Try


        End If

    End Sub

    Private Sub fvwUser_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles fvwUser.DataBound
        Dim hidUserGroup As HiddenField = DirectCast(Kartris.Interfaces.Utils.FindControlRecursive(fvwUser, "hidUserGroup"), HiddenField)
        If fvwUser.DefaultMode = FormViewMode.Edit Then
            ddlUserGroups.Items.Add(New ListItem("-", 0))
        Else
            ddlUserGroups2.Items.Add(New ListItem("-", 0))
        End If

        If GetCustomerID() > 0 Then
            Dim hidUserLanguage As HiddenField = DirectCast(Kartris.Interfaces.Utils.FindControlRecursive(fvwUser, "hidUserLanguage"), HiddenField)

            If hidUserGroup.Value = 0 Then
                ddlUserGroups.SelectedValue = 0
            Else
                ddlUserGroups.SelectedValue = hidUserGroup.Value
            End If

            If hidUserLanguage.Value = 0 Then
                ddlLanguages.SelectedValue = 1
            Else
                ddlLanguages.SelectedValue = hidUserLanguage.Value
            End If
        End If
    End Sub

    Protected Sub btnCustomerUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If GetCustomerID() > 0 Then
            Page.Validate("User")
            If Page.IsValid Then
                Dim strPassword As String
                If txtPassword.Visible Then strPassword = txtPassword.Text Else strPassword = ""
                Dim blnEmailValid As Boolean = True
                Dim strOriginalEmail As String = LCase(UsersBLL.GetEmailByID(GetCustomerID()))
                If strOriginalEmail <> LCase(txtUserEmail.Text) Then
                    If hidIsGuest.Value = False Then
                        If CheckEmailExist(txtUserEmail.Text) Then
                            blnEmailValid = False
                            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, txtUserEmail.Text & " -->> " & GetGlobalResourceObject("Login", "ContentText_EmailAddressAlreadyExists"))
                            txtUserEmail.Text = strOriginalEmail
                            Exit Sub
                        End If
                    End If

                End If

                If blnEmailValid Then
                    Dim datSupportEnd As Date = Nothing
                    If IsDate(txtUserSupportEndDate.Text) Then datSupportEnd = CDate(txtUserSupportEndDate.Text)
                    If UsersBLL._Update(GetCustomerID(), txtAccountHolderName.Text, txtUserEmail.Text, strPassword, ddlLanguages.SelectedValue, ddlUserGroups.SelectedValue, HandleDecimalValues(txtUserDiscount.Text), _
                                 chkUserApproved.Checked, chkUserisAffialite.Checked, HandleDecimalValues(txtAffiliateCommission.Text), datSupportEnd, txtUserNotes.Text) > 0 Then
                        txtPassword.Visible = False
                        valRequiredUserPassword.Enabled = False
                        lblPassword.Visible = True
                        btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "ContentText_ConfigChange2")

                        'Update VAT number
                        Try
                            Dim strUpdateVAT As String = UsersBLL.UpdateNameandEUVAT(GetCustomerID(), txtAccountHolderName.Text, txtVATNumber.Text)
                        Catch ex As Exception

                        End Try

                        'Update object config v3.0001
                        _UC_ObjectConfig.ItemID = GetCustomerID()
                        _UC_ObjectConfig.SaveConfig()

                        RaiseEvent _UCEvent_DataUpdated()
                    End If
                End If

            End If
        End If
    End Sub

    Protected Sub btnCustomerAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If GetCustomerID() = 0 Then
            Dim blnEmailValid As Boolean = True
            Dim strOriginalEmail As String = LCase(UsersBLL.GetEmailByID(GetCustomerID()))
            If strOriginalEmail <> LCase(txtUserEmail2.Text) Then
                If CheckEmailExist(txtUserEmail2.Text) Then
                    blnEmailValid = False
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, txtUserEmail2.Text & " -->> " & GetGlobalResourceObject("Login", "ContentText_EmailAddressAlreadyExists"))
                    txtUserEmail2.Text = strOriginalEmail
                    Exit Sub
                End If
            End If
            Dim intNewUserID As Integer = 0
            If blnEmailValid Then
                Dim datSupportEnd As Date = Nothing
                If IsDate(txtUserSupportEndDate2.Text) Then datSupportEnd = CDate(txtUserSupportEndDate2.Text)
                intNewUserID = UsersBLL._Add(txtAccountHolderName2.Text, txtUserEmail2.Text, txtUserPassword2.Text, ddlLanguages2.SelectedValue, ddlUserGroups2.SelectedValue, HandleDecimalValues(txtUserDiscount2.Text),
                             chkUserApproved2.Checked, chkUserisAffialite2.Checked, HandleDecimalValues(txtAffiliateCommission2.Text), datSupportEnd, txtUserNotes2.Text)

                'Update VAT number
                Try
                    Dim strUpdateVAT As String = UsersBLL.UpdateNameandEUVAT(intNewUserID, txtAccountHolderName2.Text, txtVATNumber2.Text)
                Catch ex As Exception

                End Try

            End If
            If intNewUserID > 0 Then
                ViewState("isNewUser") = True
                Response.Redirect("~/Admin/_ModifyCustomerStatus.aspx?CustomerID=" & intNewUserID)
            End If
        End If
    End Sub

    Protected Sub btnCustomerDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) ' Handles btnCustomerDelete.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If GetCustomerID() > 0 Then
            Dim blnReturnStock As Boolean
            If KartSettingsManager.GetKartConfig("backend.orders.returnstockondelete") <> "n" Then blnReturnStock = True Else blnReturnStock = False
            UsersBLL._Delete(GetCustomerID(), blnReturnStock)
            Response.Redirect("~/Admin/_CustomersList.aspx")
        End If
    End Sub

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

    Public Function CheckEmailExist(ByVal strEmailAddress As String) As Boolean
        Dim tblUserDetails As System.Data.DataTable = UsersBLL.GetDetails(strEmailAddress)
        If tblUserDetails.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Function FormatTotalColour(ByVal numBalance As Double) As String
        Select Case numBalance
            Case Is > 0
                'set to green
                Return "color: #0a0;"
            Case Is < 0
                'set to red
                Return "color: #f00;"
            Case Else
                'set to black
                Return "color: #000;"
        End Select
    End Function

    ''' <summary>
    ''' Clicked to export customer data for GDPR
    ''' </summary>
    Protected Sub btnGDPRExport_Click()
        Dim strFileName As String = CkartrisDisplayFunctions.SanitizeProductName(UsersBLL.GetEmailByID(GetCustomerID()))
        Response.ClearHeaders()
        GdprBLL.WriteToTextFile(Replace(strFileName, "@", "_at_"), GdprBLL.FormatGDPRText(GetCustomerID()))
    End Sub

    ''' <summary>
    ''' URL for the GDPR export
    ''' this avoids issues with not being able to create
    ''' the file download because response.write content
    ''' already on the page
    ''' </summary>
    Public Function FormatExportURL(ByVal strRawURL As String) As String
        Return strRawURL & "&Export=y"
    End Function

    ''' <summary>
    ''' Create a link to customer, useful if need to edit
    ''' details before placing a new order
    ''' </summary>
    Public Function FormatCustomerLink(ByVal numCustomerID As Integer) As String
        Return "~/Admin/_ModifyCustomerStatus.aspx?CustomerID=" & numCustomerID
    End Function
End Class
