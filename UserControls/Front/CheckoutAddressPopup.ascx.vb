'[[[NEW COPYRIGHT NOTICE]]]
Imports System.Collections
Imports System.Collections.Generic
Imports Payment
Imports KartrisClasses

Partial Class UserControls_General_CheckoutAddress

    Inherits ValidatableUserControl

    Public Overrides WriteOnly Property ErrorMessagePrefix() As String
        Set(ByVal value As String)
            MyBase.ErrorMessagePrefix = value
            If value = "Billing " Then
                UC_CustomerAddress.DisplayType = "Billing"
            Else
                UC_CustomerAddress.DisplayType = "Shipping"
            End If

        End Set
    End Property

    Public Overloads Overrides WriteOnly Property ValidationGroup() As String
        Set(ByVal value As String)
            MyBase.ValidationGroup = value
            UC_CustomerAddress.ValidationGroup = value
        End Set
    End Property

    Public WriteOnly Property EnableValidation() As Boolean
        Set(ByVal value As Boolean)
            UC_CustomerAddress.EnableValidation = value
        End Set
    End Property

    Public WriteOnly Property Title() As String
        Set(ByVal value As String)
            litAddressTitle.Text = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        If Not IsNothing(Addresses) Then
            If Addresses.Count > 0 Then
                If Not Page.IsPostBack Then
                    ddlAddresses.DataSource = Addresses
                    ddlAddresses.DataTextField = "Label"
                    ddlAddresses.DataValueField = "ID"
                    ddlAddresses.DataBind()
                    Dim lstAddNew As ListItem = New ListItem(GetGlobalResourceObject("Kartris", "ContentText_AddNew"), "NEW")
                    ddlAddresses.Items.Add(lstAddNew)
                End If

                If ddlAddresses.SelectedIndex = -1 And Trim(ddlAddresses.SelectedValue) <> "NEW" Then
                    ddlAddresses.SelectedIndex = 0
                    UC_CustomerAddress.EnableValidation = False
                End If

                If ViewState("_SelectedAddress") Is Nothing Then
                    Try
                        ViewState("_SelectedAddress") = Addresses.Find(Function(p) p.ID = ddlAddresses.SelectedValue)
                        RefreshAddressDetails()
                        RaiseEvent CountryUpdated(sender, e)
                    Catch ex As Exception

                    End Try
                End If
                phdAddressDetails.Visible = True
                phdNoAddress.Visible = False
                phdAddNewAddress.Visible = True
            Else
                'will need to put this in a sub
                If SelectedAddress Is Nothing Then
                    phdAddressDetails.Visible = False
                    phdNoAddress.Visible = True
                Else
                    phdAddressDetails.Visible = True
                    phdNoAddress.Visible = False
                End If
                ddlAddresses.Visible = False
            End If

        Else
            If SelectedAddress Is Nothing Then
                phdAddressDetails.Visible = False
                phdNoAddress.Visible = True
                phdAddNewAddress.Visible = False
            Else
                phdAddressDetails.Visible = True
                phdNoAddress.Visible = False
                phdAddNewAddress.Visible = True
            End If

            ddlAddresses.Visible = False
        End If
        Dim strValidationGroup As String = UC_CustomerAddress.DisplayType
        UC_CustomerAddress.ValidationGroup = strValidationGroup
        If Not IsPostBack Then
            btnAccept.OnClientClick = "Page_ClientValidate('" & strValidationGroup & "');"
        End If

    End Sub

    Public Property SelectedID() As Integer
        Get
            Dim _value As Integer
            Try
                _value = DirectCast(ViewState("_SelectedID"), Integer)
            Catch ex As Exception
                _value = 0
            End Try
            Return _value
        End Get
        Set(ByVal value As Integer)

            ViewState("_SelectedAddress") = Addresses.Find(Function(p) p.ID = value)
            If ViewState("_SelectedAddress") IsNot Nothing Then
                ddlAddresses.SelectedValue = value
                ViewState("_SelectedID") = value
                RefreshAddressDetails()
                pnlNewAddress.Visible = True
                lnkNew.Visible = True
                UC_CustomerAddress.EnableValidation = False
                RaiseEvent CountryUpdated(Nothing, Nothing)
            End If
        End Set
    End Property

    Public ReadOnly Property SelectedAddress() As Address
        Get
            Return TryCast(ViewState("_SelectedAddress"), Address)
        End Get
    End Property

    Public Property Addresses() As List(Of Address)
        Get
            Return TryCast(ViewState("_Addresses"), List(Of Address))
        End Get
        Set(ByVal value As List(Of Address))
            ViewState("_Addresses") = value
        End Set
    End Property

    Protected Sub ddlAddresses_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlAddresses.SelectedIndexChanged
        If Not ddlAddresses.SelectedValue = "NEW" Then

            ViewState("_SelectedAddress") = Addresses.Find(Function(p) p.ID = ddlAddresses.SelectedValue)
            SelectedID = ddlAddresses.SelectedValue
            RefreshAddressDetails()
            pnlNewAddress.Visible = True
            lnkNew.Visible = True
            UC_CustomerAddress.EnableValidation = False
            RaiseEvent CountryUpdated(sender, e)
        Else
            UC_CustomerAddress.Clear()
            popExtender.Show()
        End If

    End Sub

    Private Sub RefreshAddressDetails()
        If ViewState("_SelectedAddress") IsNot Nothing Then
            With DirectCast(ViewState("_SelectedAddress"), Address)
                hidAddressID.Value = .ID
                litAddressLabel.Text = Server.HtmlEncode(.Label)
                litAddressLabel.Visible = False
                litName.Text = Server.HtmlEncode(.FullName)
                litCompany.Text = Server.HtmlEncode(IIf(String.IsNullOrEmpty(.Company), String.Empty, .Company))
                litAddress.Text = Server.HtmlEncode(.StreetAddress)
                litTownCity.Text = Server.HtmlEncode(.TownCity)
                litCounty.Text = Server.HtmlEncode(.County)
                Dim objCountry As Country = Country.Get(.CountryID)
                litCountry.Text = Server.HtmlEncode(objCountry.Name)
                If Not objCountry.isLive Then
                    phdCountryNotAvailable.Visible = True
                    hidCountryID.Value = 0
                    ViewState("_SelectedAddress") = Nothing
                Else
                    phdCountryNotAvailable.Visible = False
                    hidCountryID.Value = .CountryID
                End If

                litPostcode.Text = Server.HtmlEncode(.Postcode)
                litPhone.Text = Server.HtmlEncode(.Phone)
            End With
            UC_CustomerAddress.EnableValidation = False

            phdAddressDetails.Visible = True
            phdNoAddress.Visible = False

        End If

    End Sub

    Public Sub Clear()
        ViewState("_SelectedAddress") = Nothing
        ViewState("_Addresses") = Nothing
    End Sub

    Protected Sub btnEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnEdit.Click
        If ViewState("_SelectedAddress") IsNot Nothing Then UC_CustomerAddress.InitialAddressToDisplay = DirectCast(ViewState("_SelectedAddress"), Address)
        popExtender.Show()
    End Sub

    Protected Sub btnAccept_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAccept.Click
        UC_CustomerAddress.ValidationGroup = UC_CustomerAddress.DisplayType
        UC_CustomerAddress.EnableValidation = True

        Page.Validate(UC_CustomerAddress.DisplayType)

        If Page.IsValid Then
            If String.IsNullOrEmpty(UC_CustomerAddress.AddressID) Or UC_CustomerAddress.AddressID = 0 Then
                ddlAddresses.SelectedValue = "NEW"
                lnkNew.Visible = False
            Else
                Dim intGeneratedAddressID As Integer = Address.AddUpdate(UC_CustomerAddress.EnteredAddress, DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID, , UC_CustomerAddress.EnteredAddress.ID)
                If intGeneratedAddressID > 0 Then
                    'Refresh Addresses List if its an existing address
                    If UC_CustomerAddress.EnteredAddress.ID > 0 Then
                        Dim _Addresses As List(Of Address) = DirectCast(ViewState("_Addresses"), List(Of Address))
                        _Addresses.Item(_Addresses.FindIndex(Function(p) p.ID = UC_CustomerAddress.EnteredAddress.ID)) = UC_CustomerAddress.EnteredAddress
                        ViewState("_Addresses") = _Addresses
                    End If

                    DirectCast(ViewState("_SelectedAddress"), Address).ID = intGeneratedAddressID
                    SelectedID = intGeneratedAddressID
                End If
            End If
            Dim blnSameCountry As Boolean = False
            If SelectedAddress IsNot Nothing Then
                If SelectedAddress.CountryID = UC_CustomerAddress.EnteredAddress.CountryID Then blnSameCountry = True
            End If

            ViewState("_SelectedAddress") = UC_CustomerAddress.EnteredAddress
            RefreshAddressDetails()
            If Not blnSameCountry Then RaiseEvent CountryUpdated(sender, e)
        Else
            popExtender.Show()
        End If
    End Sub

    Protected Sub lnkNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNew.Click, lnkAdd.Click
        UC_CustomerAddress.Clear()
        popExtender.Show()
    End Sub

    Public Event CountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs)
End Class