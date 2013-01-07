'[[[NEW COPYRIGHT NOTICE]]]
Imports Payment
Imports CkartrisDisplayFunctions
Imports KartrisClasses

''' <summary>
''' Reusable Customer Address Input Control
''' </summary>
''' <remarks>Medz</remarks>
Partial Public Class UserControls_Front_CustomerAddress
    Inherits ValidatableUserControl
    Public Event CountryUpdated(ByVal sender As Object, ByVal e As System.EventArgs)

    Public Property DisplayType() As String
        Get
            Return hidDisplayType.Value
        End Get
        Set(ByVal value As String)
            hidDisplayType.Value = value
            If hidDisplayType.Value = "Billing" Then
                lblName.Text = GetGlobalResourceObject("Address", "FormLabel_CardHolderName")
                lblCompany.Text = GetGlobalResourceObject("Address", "FormLabel_CardHolderCompany")
                lblStreetAddress.Text = GetGlobalResourceObject("Address", "FormLabel_CardHolderStreetAddress")
            ElseIf hidDisplayType.Value = "Shipping" Then
                lblName.Text = GetGlobalResourceObject("Address", "FormLabel_RecipientName")
                lblCompany.Text = GetGlobalResourceObject("Address", "FormLabel_ShippingCompany")
                lblStreetAddress.Text = GetGlobalResourceObject("Address", "FormLabel_ShippingAddress")
            End If
        End Set
    End Property

    Public Property AddressType() As String
        Get
            Return hidAddressType.Value
        End Get
        Set(ByVal value As String)
            hidAddressType.Value = value
        End Set
    End Property

    Public ReadOnly Property CountryName() As String
        Get
            Return ddlCountry.SelectedItem.Text
        End Get
    End Property

    Public WriteOnly Property AutoPostCountry() As Boolean
        Set(ByVal value As Boolean)
            ddlCountry.AutoPostBack = value
        End Set
    End Property

    Public WriteOnly Property EnableValidation() As Boolean
        Set(ByVal value As Boolean)
            valLastNameRequired.Enabled = value
            valStateRequired.Enabled = value
            valTelePhoneRequired.Enabled = value
            valCityRequired.Enabled = value
            If KartSettingsManager.GetKartConfig("frontend.checkout.postcoderequired") = "y" AndAlso value = True Then
                valZipCodeRequired.Enabled = True
            Else
                valZipCodeRequired.Enabled = False
            End If
            valAddressRequired.Enabled = value

        End Set
    End Property

    Public Property PhoneNoticeText() As String
        Get
            Return lblPhoneNotice.InnerText
        End Get
        Set(ByVal value As String)
            If Not String.IsNullOrEmpty(value) Then
                phdPhoneNotice.Visible = True
                lblPhoneNotice.InnerText = value
            End If
        End Set
    End Property

    Public WriteOnly Property ShowValidationSummary() As Boolean
        Set(ByVal value As Boolean)
            'AddressInputValidationSummary.Enabled = value
        End Set
    End Property

    Public Overloads Overrides WriteOnly Property ValidationGroup() As String
        Set(ByVal value As String)
            MyBase.ValidationGroup = value
            'FirstNameRequired.ValidationGroup = value
            valLastNameRequired.ValidationGroup = value
            valStateRequired.ValidationGroup = value
            valTelePhoneRequired.ValidationGroup = value
            valCityRequired.ValidationGroup = value
            valZipCodeRequired.ValidationGroup = value
            valAddressRequired.ValidationGroup = value
            'AddressInputValidationSummary.ValidationGroup = value
            DisplayType = value
        End Set
    End Property

    Public WriteOnly Property ShowNameFields() As Boolean
        Set(ByVal value As Boolean)
            phdName.Visible = value
        End Set
    End Property

    Public WriteOnly Property ShowSaveAs() As Boolean
        Set(ByVal value As Boolean)
            phdSaveAs.Visible = value
        End Set
    End Property

    Public ReadOnly Property SaveAs() As String
        Get
            Return txtSaveAs.Text.Trim()
        End Get
    End Property

    Public ReadOnly Property FullName() As String
        Get
            Return StripHTML(txtLastName.Text.Trim())
        End Get
    End Property

    Public ReadOnly Property LastName() As String
        Get
            Return StripHTML(txtLastName.Text.Trim())
        End Get
    End Property

    Public ReadOnly Property Company() As String
        Get
            Return StripHTML(txtCompanyName.Text.Trim())
        End Get
    End Property

    Public ReadOnly Property Address() As String
        Get
            Return StripHTML(txtAddress.Text.Trim())
        End Get
    End Property

    Public ReadOnly Property City() As String
        Get
            Return StripHTML(txtCity.Text.Trim())
        End Get
    End Property

    Public ReadOnly Property State() As String
        Get
            If String.IsNullOrEmpty(txtState.Text) OrElse String.IsNullOrEmpty(ddlCountry.SelectedValue) Then
                Return StripHTML(txtState.Text)
            End If
            Return StripHTML(txtState.Text)
        End Get
    End Property

    Public ReadOnly Property CountryId() As Integer
        Get
            If String.IsNullOrEmpty(ddlCountry.SelectedValue) Then
                Return 0
            End If
            Return Integer.Parse(ddlCountry.SelectedValue)
        End Get
    End Property

    Public ReadOnly Property Postcode() As String
        Get
            Return StripHTML(txtZipCode.Text.Trim())
        End Get
    End Property

    Public ReadOnly Property Phone() As String
        Get
            Return StripHTML(txtPhone.Text)
        End Get
    End Property

    Public ReadOnly Property AddressID() As Integer
        Get
            Return CInt(hidAddressID.Value)
        End Get
    End Property

    Public WriteOnly Property InitialAddressToDisplay() As Address
        Set(ByVal value As Address)
            txtSaveAs.Text = value.Label
            txtLastName.Text = value.FullName
            txtCompanyName.Text = IIf(String.IsNullOrEmpty(value.Company), String.Empty, value.Company)
            txtAddress.Text = value.StreetAddress
            txtCity.Text = value.TownCity
            txtState.Text = value.County
            'Imported customer data with bad country details
            'can cause errors, so we need a try/catch for safety
            Try
                ddlCountry.SelectedValue = value.CountryID.ToString()
            Catch ex As Exception
                ddlCountry.SelectedValue = 0
            End Try

            txtZipCode.Text = value.Postcode
            txtPhone.Text = value.Phone
            hidAddressID.Value = value.ID
            hidAddressType.Value = value.Type

        End Set
    End Property

    Public ReadOnly Property EnteredAddress() As Address
        Get
            Dim a As New Address(LastName, Company, Address, City, State, Postcode, CountryId, Phone, AddressID, SaveAs, AddressType)
            a.Country = Country.[Get](CountryId)
            Return a
        End Get
    End Property

    Private Const AddressChangedJavascriptBlockFormat As String = "function AddressChanged() {{ " + "if (($get('{0}').value) && " + "($get('{1}').value) && " + "($get('{2}').value) && " + "($get('{3}').value)) " + "{4}();" + "}}"

    Private m_addressChangedJavacriptCallBack As String = Nothing

    Public WriteOnly Property AddressChangedJavacriptCallBack() As String
        Set(ByVal value As String)
            txtAddress.Attributes.Add("onblur", "javascript:AddressChanged();")
            txtCity.Attributes.Add("onblur", "javascript:AddressChanged();")
            txtState.Attributes.Add("onblur", "javascript:AddressChanged();")
            ddlCountry.Attributes.Add("onblur", "javascript:AddressChanged();")
            txtZipCode.Attributes.Add("onblur", "javascript:AddressChanged();")
            m_addressChangedJavacriptCallBack = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        If m_addressChangedJavacriptCallBack IsNot Nothing Then
            ScriptManager.RegisterClientScriptBlock(Me, GetType(Page), "AddressChanged", String.Format(AddressChangedJavascriptBlockFormat, txtAddress.ClientID, txtCity.ClientID, txtState.ClientID, txtZipCode.ClientID, m_addressChangedJavacriptCallBack), True)
        End If
        If Not Page.IsPostBack Then
            Try
                ddlCountry.SelectedValue = KartSettingsManager.GetKartConfig("frontend.checkout.defaultcountry")
            Catch ex As Exception
                ddlCountry.SelectedIndex = 0
            End Try
        End If
    End Sub

    Public Sub Clear()
        txtSaveAs.Text = ""
        txtLastName.Text = ""
        txtCompanyName.Text = ""
        txtAddress.Text = ""
        txtCity.Text = ""
        txtState.Text = ""
        txtZipCode.Text = ""
        txtPhone.Text = ""
        Try
            ddlCountry.SelectedValue = KartSettingsManager.GetKartConfig("frontend.checkout.defaultcountry")
        Catch ex As Exception
            ddlCountry.SelectedIndex = 0
        End Try
        hidAddressID.Value = 0
        hidAddressType.Value = "u"
    End Sub

    Protected Sub ddlCountry_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCountry.SelectedIndexChanged
        If ddlCountry.AutoPostBack Then RaiseEvent CountryUpdated(sender, e)
    End Sub

End Class
