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
Imports System.Collections
Imports System.Collections.Generic
Imports Payment
Imports KartrisClasses

Partial Class UserControls_Back_NewOrderAddress

    Inherits ValidatableUserControl

    Public Overrides WriteOnly Property ErrorMessagePrefix() As String
        Set(ByVal value As String)
            MyBase.ErrorMessagePrefix = value
            If value = "Billing " Then
                _UC_CustomerAddress.DisplayType = "Billing"
            Else
                _UC_CustomerAddress.DisplayType = "Shipping"
            End If

        End Set
    End Property

    Public Overloads Overrides WriteOnly Property ValidationGroup() As String
        Set(ByVal value As String)
            MyBase.ValidationGroup = value
            _UC_CustomerAddress.ValidationGroup = value
        End Set
    End Property

    Public WriteOnly Property EnableValidation() As Boolean
        Set(ByVal value As Boolean)
            _UC_CustomerAddress.EnableValidation = value
        End Set
    End Property

    Public WriteOnly Property Title() As String
        Set(ByVal value As String)
            litAddressTitle.Text = value
        End Set
    End Property

    Public Property CustomerID() As Long
        Set(ByVal value As Long)
            ViewState("CustomerID") = value
        End Set
        Get
            Return ViewState("CustomerID")
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        InitializeControls(sender, e)

        Dim strValidationGroup As String = _UC_CustomerAddress.DisplayType
        _UC_CustomerAddress.ValidationGroup = strValidationGroup
        If Not IsPostBack Then
            btnAccept.OnClientClick = "Page_ClientValidate('" & strValidationGroup & "');"
        End If

    End Sub

    Private Sub InitializeControls(ByVal sender As Object, ByVal e As EventArgs)
        If Not IsNothing(Addresses) Then
            If Addresses.Count > 0 Then
                If ddlAddresses.Items.FindByValue("NEW") Is Nothing Then
                    ddlAddresses.DataSource = Addresses
                    ddlAddresses.DataTextField = "Label"
                    ddlAddresses.DataValueField = "ID"
                    ddlAddresses.DataBind()
                    Dim lstAddNew As ListItem = New ListItem(GetGlobalResourceObject("Kartris", "ContentText_AddNew"), "NEW")
                    ddlAddresses.Items.Add(lstAddNew)
                End If

                If ddlAddresses.SelectedIndex = -1 And Trim(ddlAddresses.SelectedValue) <> "NEW" Then
                    ddlAddresses.SelectedIndex = 0
                    _UC_CustomerAddress.EnableValidation = False
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
                ddlAddresses.Visible = True
                'lnkNew.Visible = False
            Else
                'will need to put this in a sub
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
                'lnkNew.Visible = True
                _UC_CustomerAddress.EnableValidation = False
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
            If value IsNot Nothing Then
                InitializeControls(Nothing, Nothing)
            End If
        End Set
    End Property

    Protected Sub ddlAddresses_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlAddresses.SelectedIndexChanged
        If Not ddlAddresses.SelectedValue = "NEW" Then

            ViewState("_SelectedAddress") = Addresses.Find(Function(p) p.ID = ddlAddresses.SelectedValue)
            SelectedID = ddlAddresses.SelectedValue
            RefreshAddressDetails()
            pnlNewAddress.Visible = True
            'lnkNew.Visible = True
            _UC_CustomerAddress.EnableValidation = False
            RaiseEvent CountryUpdated(sender, e)
        Else
            _UC_CustomerAddress.Clear()
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
            _UC_CustomerAddress.EnableValidation = False

            phdAddressDetails.Visible = True
            phdAddNewAddress.Visible = True
            phdNoAddress.Visible = False

        End If

    End Sub

    Public Sub Clear()
        ddlAddresses.Items.Clear()
        ViewState("_SelectedAddress") = Nothing
        ViewState("_Addresses") = Nothing
        ViewState("_SelectedID") = 0
        phdAddressDetails.Visible = False
        phdAddNewAddress.Visible = False
        phdNoAddress.Visible = True
    End Sub

    Protected Sub btnEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnEdit.Click
        If ViewState("_SelectedAddress") IsNot Nothing Then _UC_CustomerAddress.InitialAddressToDisplay = DirectCast(ViewState("_SelectedAddress"), Address)
        popExtender.Show()
    End Sub

    Protected Sub btnAccept_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAccept.Click
        _UC_CustomerAddress.ValidationGroup = _UC_CustomerAddress.DisplayType
        _UC_CustomerAddress.EnableValidation = True

        Page.Validate(_UC_CustomerAddress.DisplayType)

        If Page.IsValid Then
            If String.IsNullOrEmpty(_UC_CustomerAddress.AddressID) Or _UC_CustomerAddress.AddressID = 0 Then
                ddlAddresses.SelectedValue = "NEW"
                Dim _Addresses As List(Of Address) = DirectCast(ViewState("_Addresses"), List(Of Address))
                If _Addresses IsNot Nothing Then
                    _Addresses.Add(_UC_CustomerAddress.EnteredAddress)
                    ViewState("_Addresses") = _Addresses
                    RefreshAddressDetails()
                End If

                'lnkNew.Visible = False

            Else
                Dim intGeneratedAddressID As Integer = Address.AddUpdate(_UC_CustomerAddress.EnteredAddress, CustomerID, , _UC_CustomerAddress.EnteredAddress.ID)
                If intGeneratedAddressID > 0 Then
                    'Refresh Addresses List if its an existing address
                    If _UC_CustomerAddress.EnteredAddress.ID > 0 Then
                        Dim _Addresses As List(Of Address) = DirectCast(ViewState("_Addresses"), List(Of Address))
                        _Addresses.Item(_Addresses.FindIndex(Function(p) p.ID = _UC_CustomerAddress.EnteredAddress.ID)) = _UC_CustomerAddress.EnteredAddress
                        ViewState("_Addresses") = _Addresses
                    End If

                    DirectCast(ViewState("_SelectedAddress"), Address).ID = intGeneratedAddressID
                    SelectedID = intGeneratedAddressID
                End If
            End If
            Dim blnSameCountry As Boolean = False
            If SelectedAddress IsNot Nothing Then
                If SelectedAddress.CountryID = _UC_CustomerAddress.EnteredAddress.CountryID Then blnSameCountry = True
            End If

            ViewState("_SelectedAddress") = _UC_CustomerAddress.EnteredAddress
            RefreshAddressDetails()
            If Not blnSameCountry Then RaiseEvent CountryUpdated(sender, e)
        Else
            popExtender.Show()
        End If
    End Sub

    Protected Sub lnkNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAdd.Click
        _UC_CustomerAddress.Clear()
        popExtender.Show()
    End Sub

    Public Event CountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs)
End Class