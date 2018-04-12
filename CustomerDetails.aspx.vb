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

Partial Class Customer_Details
    Inherits PageBaseClass

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Me.Load


        If Not User.Identity.IsAuthenticated Then
            If Not String.IsNullOrEmpty(Request.QueryString("ref")) Then
                lblCurrentPassword.Text = GetGlobalResourceObject("Kartris", "FormLabel_EmailAddress")
                txtCurrentPassword.TextMode = TextBoxMode.SingleLine
                Dim strRef As String = Request.QueryString("ref")
                phdDefaultAddresses.Visible = False
            Else
                Response.Redirect(WebShopURL() & "CustomerAccount.aspx")
            End If
        Else
            If Not IsPostBack Then
                ViewState("lstUsrAddresses") = KartrisClasses.Address.GetAll(CurrentLoggedUser.ID)
                Dim arrNameAndVAT As Array = Split(UsersBLL.GetNameandEUVAT(CurrentLoggedUser.ID), "|||")
                txtCustomerName.Text = arrNameAndVAT(0)
                txtEUVATNumber.Text = arrNameAndVAT(1)
            End If

            If ViewState("lstUsrAddresses") Is Nothing Then ViewState("lstUsrAddresses") = KartrisClasses.Address.GetAll(CurrentLoggedUser.ID)
            If mvwAddresses.ActiveViewIndex = "0" Then
                If CurrentLoggedUser.DefaultBillingAddressID > 0 And Not IsNothing(CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultBillingAddressID)) Then
                    UC_DefaultBilling.Address = CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultBillingAddressID)
                    litContentTextNoAddress.Visible = False
                Else
                    UC_DefaultBilling.Visible = False
                    litContentTextNoAddress.Visible = True
                End If
                If CurrentLoggedUser.DefaultShippingAddressID > 0 And Not IsNothing(CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultShippingAddressID)) Then
                    UC_DefaultShipping.Address = CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultShippingAddressID)
                    litContentTextNoAddress2.Visible = False
                Else
                    UC_DefaultShipping.Visible = False
                    litContentTextNoAddress2.Visible = True
                End If

            ElseIf mvwAddresses.ActiveViewIndex = "1" Then
                CreateBillingAddressesDetails()
            ElseIf mvwAddresses.ActiveViewIndex = "2" Then
                CreateShippingAddressesDetails()
            End If


        End If
        If Not Page.IsPostBack Then

            UC_Updated.reset()
        End If
    End Sub

    Private Sub Page_LoadComplete(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        If mvwAddresses.ActiveViewIndex > 0 Then btnBack.Visible = True Else btnBack.Visible = False
    End Sub

    Protected Sub lnkEditBilling_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkEditBilling.Click

        mvwAddresses.ActiveViewIndex = "1"
        CreateBillingAddressesDetails()
        'UC_NewEditAddress.DisplayType = "Billing"
        UC_NewEditAddress.ValidationGroup = "Billing"
        btnSaveNewAddress.OnClientClick = "Page_ClientValidate('Billing');"
        UC_Updated.reset()
    End Sub

    Protected Sub lnkEditShipping_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkEditShipping.Click

        mvwAddresses.ActiveViewIndex = "2"
        CreateShippingAddressesDetails()
        'UC_NewEditAddress.DisplayType = "Shipping"
        UC_NewEditAddress.ValidationGroup = "Shipping"
        btnSaveNewAddress.OnClientClick = "Page_ClientValidate('Shipping');"
        UC_Updated.reset()
    End Sub

    Protected Sub btnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnBack.Click
        mvwAddresses.ActiveViewIndex = "0"
        If CurrentLoggedUser.DefaultBillingAddressID > 0 And Not IsNothing(CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultBillingAddressID)) Then
            UC_DefaultBilling.Address = CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultBillingAddressID)
            litContentTextNoAddress.Visible = False
        Else
            UC_DefaultBilling.Visible = False
            litContentTextNoAddress.Visible = True
        End If
        If CurrentLoggedUser.DefaultShippingAddressID > 0 And Not IsNothing(CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultShippingAddressID)) Then
            UC_DefaultShipping.Address = CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = CurrentLoggedUser.DefaultShippingAddressID)
            litContentTextNoAddress2.Visible = False
        Else
            UC_DefaultShipping.Visible = False
            litContentTextNoAddress2.Visible = True
        End If
        UC_Updated.reset()
    End Sub

    Protected Sub btnSaveNewAddress_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveNewAddress.Click
        Page.Validate()
        If Page.IsValid Then

            If chkAlso.Checked = False Then
                If UC_NewEditAddress.DisplayType = "Billing" Then UC_NewEditAddress.AddressType = "b" Else UC_NewEditAddress.AddressType = "s"
            Else
                UC_NewEditAddress.AddressType = "u"
            End If

            Dim intGeneratedAddressID As Integer = KartrisClasses.Address.AddUpdate(UC_NewEditAddress.EnteredAddress, CurrentLoggedUser.ID, chkMakeDefault.Checked, UC_NewEditAddress.EnteredAddress.ID)
            If intGeneratedAddressID > 0 Then

                Dim objAddress As KartrisClasses.Address = UC_NewEditAddress.EnteredAddress
                objAddress.ID = intGeneratedAddressID

                If UC_NewEditAddress.EnteredAddress.ID > 0 Then
                    Dim AddresstobeDeleted As KartrisClasses.Address = CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Find(Function(p) p.ID = intGeneratedAddressID)
                    CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Remove(AddresstobeDeleted)
                End If

                CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Add(objAddress)
                If UC_NewEditAddress.DisplayType = "Billing" Then
                    pnlBilling.Controls.Clear()
                    CreateBillingAddressesDetails()
                Else
                    pnlShipping.Controls.Clear()
                    CreateShippingAddressesDetails()
                End If

                If chkMakeDefault.Checked Then
                    If UC_NewEditAddress.DisplayType = "Billing" Then CurrentLoggedUser.DefaultBillingAddressID = intGeneratedAddressID Else CurrentLoggedUser.DefaultShippingAddressID = intGeneratedAddressID
                    If chkAlso.Checked Then If UC_NewEditAddress.DisplayType = "Billing" Then CurrentLoggedUser.DefaultShippingAddressID = intGeneratedAddressID
                End If
                ResetAddressInput()
                UC_Updated.ShowAnimatedText()
            End If
        Else
            popExtender.Show()
        End If
    End Sub

    Protected Sub btnAddAddress_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAddBilling.Click, lnkAddShipping.Click
        UC_Updated.reset()
        ResetAddressInput()
        If UC_NewEditAddress.DisplayType = "Billing" Then
            UC_NewEditAddress.ValidationGroup = "Billing"
            chkAlso.Text = GetGlobalResourceObject("Address", "ContentText_CanAlsoBeUsedAsShippingAddress")
        Else
            UC_NewEditAddress.ValidationGroup = "Shipping"
            chkAlso.Text = GetGlobalResourceObject("Address", "ContentText_CanAlsoBeUsedAsBillingAddress")
        End If

        litAddressTitle.Text = GetGlobalResourceObject("Address", "ContentText_AddEditAddress")
        popExtender.Show()
    End Sub

    Protected Sub btnEditAddress_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        UC_Updated.reset()
        litAddressTitle.Text = GetGlobalResourceObject("Kartris", "ContentText_Edit")
        Dim lnkEdit As LinkButton = CType(sender, LinkButton)

        UC_NewEditAddress.InitialAddressToDisplay = CType(lnkEdit.Parent.Parent, UserControls_General_AddressDetails).Address

        If UC_NewEditAddress.DisplayType = "Billing" Then
            chkAlso.Text = GetGlobalResourceObject("Address", "ContentText_CanAlsoBeUsedAsShippingAddress")
            If CurrentLoggedUser.DefaultBillingAddressID = CType(lnkEdit.Parent.Parent, UserControls_General_AddressDetails).Address.ID Then chkMakeDefault.Checked = True
            If CurrentLoggedUser.DefaultBillingAddressID = UC_NewEditAddress.EnteredAddress.ID Then chkMakeDefault.Checked = True Else chkMakeDefault.Checked = False
            UC_NewEditAddress.ValidationGroup = "Billing"
        Else
            chkAlso.Text = GetGlobalResourceObject("Address", "ContentText_CanAlsoBeUsedAsBillingAddress")
            If CurrentLoggedUser.DefaultShippingAddressID = CType(lnkEdit.Parent.Parent, UserControls_General_AddressDetails).Address.ID Then chkMakeDefault.Checked = True
            If CurrentLoggedUser.DefaultShippingAddressID = UC_NewEditAddress.EnteredAddress.ID Then chkMakeDefault.Checked = True Else chkMakeDefault.Checked = False
            UC_NewEditAddress.ValidationGroup = "Shipping"
        End If

        If UC_NewEditAddress.EnteredAddress.Type = "u" Then chkAlso.Checked = True Else chkAlso.Checked = False
        UC_Updated.reset()
        popExtender.Show()
    End Sub

    Protected Sub btnDeleteAddress_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim UC_Delete As UserControls_General_AddressDetails = CType(CType(sender, LinkButton).Parent.Parent, UserControls_General_AddressDetails)
        Dim intAddressID As Integer = UC_Delete.Address.ID
        Dim objAddress As KartrisClasses.Address = UC_Delete.Address

        If KartrisClasses.Address.Delete(intAddressID, CurrentLoggedUser.ID) > 0 Then
            CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).Remove(objAddress)
            If UC_NewEditAddress.DisplayType = "Shipping" Then pnlShipping.Controls.Remove(UC_Delete) Else pnlBilling.Controls.Remove(UC_Delete)
        End If
    End Sub

    Private Sub ResetAddressInput()
        UC_NewEditAddress.Clear()
        chkMakeDefault.Checked = False
        chkAlso.Checked = False
    End Sub

    Public Sub CreateShippingAddressesDetails()
        Dim lstShippingAddresses As Collections.Generic.List(Of KartrisClasses.Address) = CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).FindAll(Function(ShippingAdd) ShippingAdd.Type = "s" Or ShippingAdd.Type = "u")
        For Each objAddress In lstShippingAddresses
            Dim UC_Shipping As UserControls_General_AddressDetails = DirectCast(LoadControl("~/UserControls/General/AddressDetails.ascx"), UserControls_General_AddressDetails)
            UC_Shipping.ID = "dtlShipping-" & objAddress.ID
            pnlShipping.Controls.Add(UC_Shipping)

            Dim UC_ShippingInstance As UserControls_General_AddressDetails = DirectCast(mvwAddresses.Views(2).FindControl("dtlShipping-" & objAddress.ID), UserControls_General_AddressDetails)
            UC_ShippingInstance.Address = objAddress
            UC_ShippingInstance.ShowButtons = True
            AddHandler UC_ShippingInstance.btnEditClicked, AddressOf Me.btnEditAddress_Click
            AddHandler UC_ShippingInstance.btnDeleteClicked, AddressOf Me.btnDeleteAddress_Click
        Next
    End Sub

    Public Sub CreateBillingAddressesDetails()
        Dim lstBillingAddresses As Collections.Generic.List(Of KartrisClasses.Address) = CType(ViewState("lstUsrAddresses"), Collections.Generic.List(Of KartrisClasses.Address)).FindAll(Function(BillingAdd) BillingAdd.Type = "b" Or BillingAdd.Type = "u")
        For Each objAddress In lstBillingAddresses
            Dim UC_Billing As UserControls_General_AddressDetails = DirectCast(LoadControl("~/UserControls/General/AddressDetails.ascx"), UserControls_General_AddressDetails)
            UC_Billing.ID = "UC_Billing-" & objAddress.ID
            pnlBilling.Controls.Add(UC_Billing)
            Dim UC_BillingInstance As UserControls_General_AddressDetails = CType(mvwAddresses.Views(1).FindControl("UC_Billing-" & objAddress.ID), UserControls_General_AddressDetails)
            UC_BillingInstance.Address = objAddress
            UC_BillingInstance.ShowButtons = True
            AddHandler UC_BillingInstance.btnEditClicked, AddressOf Me.btnEditAddress_Click
            AddHandler UC_BillingInstance.btnDeleteClicked, AddressOf Me.btnDeleteAddress_Click
        Next
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
                Dim datExpiry As DateTime = IIf(IsDate(FixNullFromDB(dtbUserDetails(0)("U_TempPasswordExpiry"))), dtbUserDetails(0)("U_TempPasswordExpiry"), _
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

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        Page.Validate("NameAndVat")
        If Page.IsValid Then
            If UsersBLL.UpdateNameandEUVAT(CurrentLoggedUser.ID, txtCustomerName.Text, txtEUVATNumber.Text) = CurrentLoggedUser.ID Then UC_Updated.ShowAnimatedText()
        End If
    End Sub
End Class