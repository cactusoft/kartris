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
Imports System.Collections
Imports System.Collections.Generic
Imports Payment
Imports KartrisClasses
Imports KartSettingsManager

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
            lnkNew.Visible = True
            UC_CustomerAddress.EnableValidation = False
            RaiseEvent CountryUpdated(sender, e)
        Else
            UC_CustomerAddress.Clear()
            RunAddressLookupRoutine()
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

                Try
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
                Catch ex As Exception
                    'This can happen if switch language and the country of the address
                    'doesn't have a suitable translation
                End Try

                litPostcode.Text = Server.HtmlEncode(.Postcode)
                litPhone.Text = Server.HtmlEncode(.Phone)
            End With
            UC_CustomerAddress.EnableValidation = False

            phdAddressDetails.Visible = True
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
        If ViewState("_SelectedAddress") IsNot Nothing Then UC_CustomerAddress.InitialAddressToDisplay = DirectCast(ViewState("_SelectedAddress"), Address)
        phdAddressEnterForm.Visible = True
        phdAddressLookup.Visible = False
        popExtender.Show()
    End Sub

    Protected Sub btnAccept_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAccept.Click
        UC_CustomerAddress.ValidationGroup = UC_CustomerAddress.DisplayType
        UC_CustomerAddress.EnableValidation = True
        Dim numCustomerID As Integer
        Try
            numCustomerID = DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID
        Catch ex As Exception
            numCustomerID = CustomerID
        End Try

        Page.Validate(UC_CustomerAddress.DisplayType)

        If Page.IsValid Then
            If String.IsNullOrEmpty(UC_CustomerAddress.AddressID) Or UC_CustomerAddress.AddressID = 0 Then
                ddlAddresses.SelectedValue = "NEW"
                lnkNew.Visible = False
            Else
                Dim intGeneratedAddressID As Integer = Address.AddUpdate(UC_CustomerAddress.EnteredAddress, numCustomerID, , UC_CustomerAddress.EnteredAddress.ID)
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

            'Previously we only triggered 'countryupdate' when the country
            'was updated, however we should really do this whenever an 
            'address is changed, as it's possible on some shipping setups
            'that the postcode or maybe other details could affect the
            'shipping price
            'If Not blnSameCountry Then RaiseEvent CountryUpdated(sender, e)
            RaiseEvent CountryUpdated(sender, e)
        Else
            popExtender.Show()
        End If
    End Sub

    Protected Sub lnkNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNew.Click, lnkAdd.Click
        UC_CustomerAddress.Clear()
        RunAddressLookupRoutine()
        popExtender.Show()
    End Sub

    Public Event CountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs)

    ''' <summary>
    ''' Postcodes4u is a UK based web service that
    ''' provides full address details from a postcode.
    ''' If the site has an account setup with them, 
    ''' we can use this to populate UK addresses to 
    ''' the address control
    ''' </summary>
    Private Sub RunAddressLookupRoutine()
        If GetKartConfig("general.services.postcodes4u.username") <> "" Then
            'We are using postcodes4u
            phdAddressEnterForm.Visible = False
            phdAddressLookup.Visible = True
            txtZipCode.Text = ""
            lbxChooseAddress.ClearSelection()

        End If
    End Sub

    ''' <summary>
    ''' Postcodes4u - when country selected, show
    ''' main form and pre-select country. This is
    ''' for non-UK selections
    ''' </summary>
    Protected Sub ddlCountry_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCountry.SelectedIndexChanged

        'Not uk, so stop checking, just show the form
        'and select the country
        phdAddressEnterForm.Visible = True
        phdAddressLookup.Visible = False
        UC_CustomerAddress.CountryId = ddlCountry.SelectedValue

        popExtender.Show()
    End Sub

    ''' <summary>
    ''' Postcode entered, we need to look this up
    ''' and provide a list of addresses
    ''' </summary>
    Protected Sub lnkLookup_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkLookup.Click
        Dim dtsAddresses As DataSet = PostcodeSearch(txtZipCode.Text)
        Try
            If dtsAddresses.Tables("Summary").Rows.Count = 0 Then
                litNotValidError.Text = "<span class=""error"">Postcode is not valid!</span>"
            Else
                litNotValidError.Text = ""
                lbxChooseAddress.DataSource = dtsAddresses.Tables("Summary")
                lbxChooseAddress.DataValueField = "Id"
                lbxChooseAddress.DataTextField = "StreetAddress"
                lbxChooseAddress.DataBind()
                phdChooseAddress.Visible = True
            End If
        Catch ex As Exception
            'Probably got an error back
            litNotValidError.Text = "<span class=""error"">Postcode is not valid!</span>"
        End Try
        popExtender.Show()
    End Sub

    ''' <summary>
    ''' This gets a dataset of addresses from
    ''' postcodes4u, containing Id, Street Address
    ''' and place
    ''' </summary>
    Private Function PostcodeSearch(ByVal strPostcode As String) As DataSet
        Dim strFormat As String = "xml"
        Dim strKey As String = GetKartConfig("general.services.postcodes4u.key")
        Dim strUsername As String = GetKartConfig("general.services.postcodes4u.username")
        Dim strURL As String = "http://services.3xsoftware.co.uk/search/bypostcode/"
        strURL &= System.Web.HttpUtility.UrlEncode(strFormat)
        strURL &= "?username=" + System.Web.HttpUtility.UrlEncode(strUsername)
        strURL &= "&key=" + System.Web.HttpUtility.UrlEncode(strKey)
        strURL &= "&postcode=" + System.Web.HttpUtility.UrlEncode(Replace(strPostcode, " ", "").ToUpper)

        'Create the dataset  
        Dim dtsAddresses = New DataSet()
        dtsAddresses.ReadXml(strURL)

        'Check for an error      
        If (dtsAddresses.Tables("Error") IsNot Nothing) AndAlso (dtsAddresses.Tables("Error").Columns("Description") IsNot Nothing) Then
            Dim exc As String = dtsAddresses.Tables("Error").Rows(0)("Description").ToString()
            'Throw New Exception(exc)
            Return Nothing
        Else
            litNotValidError.Text = ""
            If dtsAddresses.Tables("Summary") IsNot Nothing Then
                dtsAddresses.Tables("Summary").Constraints.Clear()
                If dtsAddresses.Tables("Summary").Rows.Count > 0 Then
                    'We want to merge Street Address & Place together
                    For i = 0 To dtsAddresses.Tables("Summary").Rows.Count - 1
                        dtsAddresses.Tables("Summary").Rows(i)("StreetAddress") &= ", " & dtsAddresses.Tables("Summary").Rows(i)("Place")
                    Next
                End If

            End If
            dtsAddresses.Relations.Clear()
            If dtsAddresses.Tables("Summaries") IsNot Nothing Then
                dtsAddresses.Tables.Remove("Summaries")
            End If
            'Return the dataset  
            Return dtsAddresses
        End If

        'FYI: The dataset contains the following columns:     
        'Id        
        'StreetAddress      
        'Place   
    End Function

    ''' <summary>
    ''' Looks up address details from selected
    ''' address ID
    ''' </summary>
    Private Function AddressLookupByID(ByVal numID As Integer) As DataSet
        Dim strFormat As String = "xml"
        Dim strKey As String = GetKartConfig("general.services.postcodes4u.key")
        Dim strUsername As String = GetKartConfig("general.services.postcodes4u.username")
        Dim strURL As String = "http://services.3xsoftware.co.uk/search/byid/"
        strURL &= System.Web.HttpUtility.UrlEncode(strFormat)
        strURL &= "?username=" + System.Web.HttpUtility.UrlEncode(strUsername)
        strURL &= "&key=" + System.Web.HttpUtility.UrlEncode(strKey)
        strURL &= "&id=" + System.Web.HttpUtility.UrlEncode(numID)

        'Create the dataset  
        Dim dtsAddress = New DataSet()
        dtsAddress.ReadXml(strURL)

        'Check for an error      
        If (dtsAddress.Tables("Error") IsNot Nothing) AndAlso (dtsAddress.Tables("Error").Columns("Description") IsNot Nothing) Then
            Dim exc As String = dtsAddress.Tables("Error").Rows(0)("Description").ToString()
            Throw New Exception(exc)
        End If
        If dtsAddress.Tables("Summary") IsNot Nothing Then
            dtsAddress.Tables("Summary").Constraints.Clear()
        End If
        dtsAddress.Relations.Clear()

        'Return the dataset  
        Return dtsAddress
    End Function

    ''' <summary>
    ''' Postcodes4u - when a looked up
    ''' address is chosen, grab the ID
    ''' look up details, fill address form
    ''' </summary>
    Protected Sub lbxChooseAddress_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbxChooseAddress.SelectedIndexChanged

        'Lookup address by ID from postcodes4u
        Dim dtsAddress As DataSet = AddressLookupByID(lbxChooseAddress.SelectedValue)
        Dim strAddress As String = ""

        'Let's format a string for street address
        'This will include building name, number and street
        'if available. We use pipes to separate, this way we
        'can work out any blank entries and end up joining 
        'what is left with comma-spaces
        strAddress &= "|" & dtsAddress.Tables("Address").Rows(0)("BuildingName") & "|"
        strAddress &= "|" & Trim(dtsAddress.Tables("Address").Rows(0)("BuildingNumber") & " " & dtsAddress.Tables("Address").Rows(0)("PrimaryStreet")) & "|"

        'Remove four pipes, this gets rid of any blank entries from above
        'where have buildingname and primarystreet only
        strAddress = Replace(strAddress, "||||", "")

        'Remove three pipes, this gets rid of any blank entries from above
        strAddress = Replace(strAddress, "|||", "")

        'Any two pipes left should be joins between two values
        strAddress = Replace(strAddress, "||", ", ")

        'Single pipes might be left and start or finish
        'so remove them
        strAddress = Replace(strAddress, "|", "")

        'Set customer address form fields to values returned from
        'postcodes4u
        UC_CustomerAddress.Company = dtsAddress.Tables("Address").Rows(0)("Company")
        UC_CustomerAddress.Address = strAddress
        UC_CustomerAddress.City = dtsAddress.Tables("Address").Rows(0)("PostTown")
        UC_CustomerAddress.State = dtsAddress.Tables("Address").Rows(0)("County")
        UC_CustomerAddress.Postcode = dtsAddress.Tables("Address").Rows(0)("Postcode")

        'We also want to pre-select country. But some stores
        'in UK may have multiple UK destination records for
        'shipping purposes, for example Mainland, NI, Highlands
        'and Islands etc. So what we'll do is try to select
        'it by name rather than value, this should not select
        'anything if there are multiple UK records
        Try
            UC_CustomerAddress.CountryId = 199
            If UC_CustomerAddress.CountryName = "United Kingdom" Then
                UC_CustomerAddress.CountryId = 0
            End If
        Catch ex As Exception

        End Try


        phdAddressEnterForm.Visible = True
        phdAddressLookup.Visible = False
        popExtender.Show()
    End Sub
End Class