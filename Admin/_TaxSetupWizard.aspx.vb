'[[[NEW COPYRIGHT NOTICE]]]
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports System.Linq

Partial Class Admin_Destinations
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_RegionalWizard", "PageTitle_RegionalSetupWizard") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            Dim strTaxRegime As String = TaxRegime.Name
            litTaxRegime.Text = strTaxRegime
            'set default config settings for each region
            Select Case strTaxRegime
                Case "EU"
                    ddlPricesIncTaxConfig.SelectedValue = "y"
                    ddlShowTaxConfig.SelectedValue = "n"
                Case Else
                    ddlPricesIncTaxConfig.SelectedValue = "n"
                    ddlShowTaxConfig.SelectedValue = "n"
            End Select

            'Populate currency dropdown
            Dim dtbCurrencies As DataTable = KartSettingsManager.GetCurrenciesFromCache()
            Dim drwCurrencies As DataRow() = dtbCurrencies.Select()
            If drwCurrencies.Length > 0 Then
                ddlCurrency.Items.Clear()
                ddlCurrency.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "noselection"))
                For i As Byte = 0 To drwCurrencies.Length - 1
                    ddlCurrency.Items.Add(New ListItem(drwCurrencies(i)("CUR_Symbol") & " " & drwCurrencies(i)("CUR_ISOCode"), drwCurrencies(i)("CUR_ID")))
                Next
            End If
        Else
            pnlSummary.Visible = False
        End If

    End Sub

    Protected Sub ShowMasterUpdateMessage()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    ''' <summary>
    ''' Handle currency selection dropdown
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ddlCurrency_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCurrency.SelectedIndexChanged

        'If no currency, hide the rest of things
        If ddlCurrency.SelectedValue <> "noselection" Then
            'Currency selected
            mvwRegionalSetupWizard.Visible = True
        Else
            'No currency, hide bits below
            mvwRegionalSetupWizard.Visible = False
            pnlSummary.Visible = False
        End If

        Dim strActiveTaxRegime As String = TaxRegime.Name
        Select Case strActiveTaxRegime
            Case "EU"
                mvwRegionalSetupWizard.SetActiveView(viwEU)
            Case "US"
                mvwRegionalSetupWizard.SetActiveView(viwUS)
                ddlUSStates.Items.Clear()
                ddlUSStates.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "noselection"))
                For Each objCountry In GetCountryListFromTaxConfig()
                    ddlUSStates.Items.Add(New ListItem(objCountry.Name, objCountry.CountryId))
                Next
                txtUSStateTaxRate.Text = ""
                phdUSStateTaxRate.Visible = False
            Case "CANADA"
                mvwRegionalSetupWizard.SetActiveView(viwCanada)
                ddlCanadaBaseProvince.Items.Clear()
                ddlCanadaBaseProvince.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "noselection"))
                For Each objCountry In GetCountryListFromTaxConfig()
                    ddlCanadaBaseProvince.Items.Add(New ListItem(objCountry.Name, objCountry.CountryId))
                Next
                txtCanadaGST.Text = ""
                txtCanadaPST.Text = ""
                phdCanadaProvinceTax.Visible = False
            Case "SIMPLE"
                mvwRegionalSetupWizard.SetActiveView(viwOther)
                ddlSimpleBaseCountry.Items.Clear()
                ddlSimpleBaseCountry.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "noselection"))

                Dim tblAllCountries As DataTable = ShippingBLL._GetDestinationsByLanguage(Session("_LANG"))
                For Each drwCountry As DataRow In tblAllCountries.Rows
                    ddlSimpleBaseCountry.Items.Add(New ListItem(drwCountry("D_Name"), drwCountry("D_ID")))
                Next

                txtSimpleTaxRate.Text = ""
                phdSimpleTaxRate.Visible = False
        End Select

    End Sub

    ''' <summary>
    ''' Handle 'VAT registered?' dropdown
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ddlQVATRegistered_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlEUVatRegistered.SelectedIndexChanged
        If ddlEUVatRegistered.SelectedValue = "y" Then
            'Yes
            ddlEUCountries.Items.Clear()
            ddlEUCountries.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "noselection"))
            For Each objCountry In GetCountryListFromTaxConfig()
                ddlEUCountries.Items.Add(New ListItem(objCountry.Name, objCountry.CountryId))
            Next
            phdEUBaseCountry.Visible = True
        ElseIf ddlEUVatRegistered.SelectedValue = "n" Then
            'No
            phdEUBaseCountry.Visible = False
            phdEUVATRate.Visible = False
            pnlSummary.Visible = True
        Else
            'No selection
            phdEUBaseCountry.Visible = False
            phdEUVATRate.Visible = False
            pnlSummary.Visible = False
        End If

    End Sub

    ''' <summary>
    ''' Handle EU country dropdown selection
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ddlEUCountries_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlEUCountries.SelectedIndexChanged
        If ddlEUCountries.SelectedValue = "noselection" Then
            'No country selected, hide bits below
            phdEUVATRate.Visible = False
            pnlSummary.Visible = False
        Else
            'Country selected, show VAT rate field
            txtQVatRate.Text = ""
            phdEUVATRate.Visible = True
        End If
    End Sub

    ''' <summary>
    ''' Handle US state dropdown selection
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ddlUSStates_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlUSStates.SelectedIndexChanged
        If ddlUSStates.SelectedValue = "noselection" Then
            'No state selected, hide bits below
            phdUSStateTaxRate.Visible = False
            pnlSummary.Visible = False
        Else
            'State selected, show tax rate field
            txtUSStateTaxRate.Text = ""
            phdUSStateTaxRate.Visible = True
        End If

    End Sub

    ''' <summary>
    ''' Handle Canada province/territory dropdown selection
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ddlCanadaBaseProvince_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCanadaBaseProvince.SelectedIndexChanged
        If ddlCanadaBaseProvince.SelectedValue = "noselection" Then
            'No province/territory selected, hide bits below
            phdCanadaProvinceTax.Visible = False
            pnlSummary.Visible = False
        Else
            'Province/territory selected, show tax rate fields
            lblCanadaBaseProvince.Text = ddlCanadaBaseProvince.SelectedItem.Text
            txtCanadaGST.Text = ""
            txtCanadaPST.Text = ""
            phdCanadaProvinceTax.Visible = True
        End If

    End Sub

    ''' <summary>
    ''' Handle country dropdown selection
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ddlSimpleBaseCountry_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlSimpleBaseCountry.SelectedIndexChanged
        If ddlCanadaBaseProvince.SelectedValue = "noselection" Then
            'No country selected, hide bits below
            phdSimpleTaxRate.Visible = False
            pnlSummary.Visible = False
        Else
            'Country selected, show tax rate fields
            txtSimpleTaxRate.Text = ""
            phdSimpleTaxRate.Visible = True
        End If

    End Sub

    ''' <summary>
    ''' Handle tax rate text box being changed
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub txtQVatRate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles txtQVatRate.TextChanged, txtUSStateTaxRate.TextChanged,
                                                                                                        txtSimpleTaxRate.TextChanged, txtCanadaPST.TextChanged

        'If tax rate is blank (we total all boxes
        'so we can do check on one line) then we
        'hide next section
        If txtQVatRate.Text & txtUSStateTaxRate.Text & txtSimpleTaxRate.Text & txtCanadaPST.Text = "" Then
            pnlSummary.Visible = False
        Else
            pnlSummary.Visible = True
        End If

    End Sub

    Protected Sub btnConfirmSetup_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnConfirmSetup.Click

        'CURRENCY
        Dim intSelectedCurrencyID As Integer = ddlCurrency.SelectedValue
        If intSelectedCurrencyID <> 1 Then
            Dim dtbCurrencies As DataTable = KartSettingsManager.GetCurrenciesFromCache()

            'Get current default currency details
            Dim drwDefaultCurrency As DataRow() = dtbCurrencies.Select("CUR_ID=1")
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Currencies, False, 1)
            Dim dtbDefaultCurrencyLE As DataTable = _UC_LangContainer.ReadContent()

            'Get new default currency details
            Dim drwNewDefaultCurrency As DataRow() = dtbCurrencies.Select("CUR_ID=" & intSelectedCurrencyID)
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.Currencies, False, intSelectedCurrencyID)
            Dim dtNewDefaultCurrencyLE As DataTable = _UC_LangContainer.ReadContent()

            If drwDefaultCurrency.Length > 0 And drwNewDefaultCurrency.Length > 0 Then
                'Update 1st currency record to the newly selected currency, can't update the isocode and symbol yet because we have unique constraints on both fields
                CurrenciesBLL._UpdateCurrency(dtNewDefaultCurrencyLE, 1, "temp", "tmp",
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_ISOCodeNumeric"), "i"), 1,
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_HasDecimals"), "b"), FixNullToDB(drwNewDefaultCurrency(0)("CUR_Live"), "b"),
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_Format")), FixNullToDB(drwNewDefaultCurrency(0)("CUR_ISOFormat")),
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_DecimalPoint")), FixNullToDB(drwNewDefaultCurrency(0)("CUR_RoundNumbers"), "i"), "")
                'Put the old default currency details to the selected currency's db record - to switch them around
                CurrenciesBLL._UpdateCurrency(dtbDefaultCurrencyLE, intSelectedCurrencyID, FixNullToDB(drwDefaultCurrency(0)("CUR_SYMBOL")), FixNullToDB(drwDefaultCurrency(0)("CUR_ISOCode")),
                                              FixNullToDB(drwDefaultCurrency(0)("CUR_ISOCodeNumeric"), "i"), FixNullToDB(drwNewDefaultCurrency(0)("CUR_ExchangeRate"), "d"),
                                              FixNullToDB(drwDefaultCurrency(0)("CUR_HasDecimals"), "b"), FixNullToDB(drwDefaultCurrency(0)("CUR_Live"), "b"),
                                              FixNullToDB(drwDefaultCurrency(0)("CUR_Format")), FixNullToDB(drwDefaultCurrency(0)("CUR_ISOFormat")),
                                              FixNullToDB(drwDefaultCurrency(0)("CUR_DecimalPoint")), FixNullToDB(drwDefaultCurrency(0)("CUR_RoundNumbers"), "i"), "")
                'Now that the records are switched, put the correct symbol and isocode to the new default currency
                CurrenciesBLL._UpdateCurrency(dtNewDefaultCurrencyLE, 1, FixNullToDB(drwNewDefaultCurrency(0)("CUR_SYMBOL")), FixNullToDB(drwNewDefaultCurrency(0)("CUR_ISOCode")),
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_ISOCodeNumeric"), "i"), 1,
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_HasDecimals"), "b"), FixNullToDB(drwNewDefaultCurrency(0)("CUR_Live"), "b"),
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_Format")), FixNullToDB(drwNewDefaultCurrency(0)("CUR_ISOFormat")),
                                              FixNullToDB(drwNewDefaultCurrency(0)("CUR_DecimalPoint")), FixNullToDB(drwNewDefaultCurrency(0)("CUR_RoundNumbers"), "i"), "")
            End If
        End If
        '/CURRENCY

        Dim dtbAllCountries As DataTable = ShippingBLL._GetDestinationsByLanguage(CkartrisBLL.GetLanguageIDfromSession)
        Dim lstRegionCountries As List(Of KartrisClasses.Country) = GetCountryListFromTaxConfig()

        Select Case TaxRegime.Name
            Case "EU"
                'VAT Registered?
                If ddlEUVatRegistered.SelectedValue = "y" Then
                    'Yes - All EU Countries should be charged tax and set to live, everything else turn off tax

                    Dim strSelectedEUCountryISO As String = ""

                    'loop through all countries in the destination table
                    For Each drwCountry As DataRow In dtbAllCountries.Rows
                        Dim intCountryID As Integer = drwCountry("D_ID")
                        If lstRegionCountries.FirstOrDefault(Function(item) item.CountryId = intCountryID) IsNot Nothing Then
                            'country belongs to EU - charge tax and live
                            ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), 1, FixNullFromDB(drwCountry("D_Tax2")),
                                                                       drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                       FixNullFromDB(drwCountry("D_Region")), True, "", FixNullFromDB(drwCountry("D_TaxExtra")))
                        Else
                            'not EU - don't charge tax
                            ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), 0, FixNullFromDB(drwCountry("D_Tax2")),
                                                                       drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                       FixNullFromDB(drwCountry("D_Region")), drwCountry("D_Live"), "", FixNullFromDB(drwCountry("D_TaxExtra")))
                        End If
                        If ddlEUCountries.SelectedValue = intCountryID Then
                            strSelectedEUCountryISO = drwCountry("D_ISOCode")
                        End If
                    Next

                    'Set general.tax.euvatcountry config to selected country
                    KartSettingsManager.SetKartConfig("general.tax.euvatcountry", strSelectedEUCountryISO, False)

                    'Set TaxRate Record 2 to entered tax rate value
                    TaxBLL._UpdateTaxRate(2, txtQVatRate.Text, "", "")
                Else
                    'No - Don't charge tax for all countries
                    For Each drwCountry As DataRow In dtbAllCountries.Rows
                        ShippingBLL._UpdateDestinationForTaxWizard(drwCountry("D_ID"), drwCountry("D_ShippingZoneID"), 0, FixNullFromDB(drwCountry("D_Tax2")),
                                           drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                           FixNullFromDB(drwCountry("D_Region")), drwCountry("D_Live"), "", FixNullFromDB(drwCountry("D_TaxExtra")))
                    Next
                    'Set general.tax.euvatcountry config to blank, don't refresh cache yet
                    KartSettingsManager.SetKartConfig("general.tax.euvatcountry", "", False)
                End If

            Case "US"
                'loop through all countries in the destination table
                For Each drwCountry As DataRow In dtbAllCountries.Rows
                    Dim intCountryID As Integer = drwCountry("D_ID")

                    If lstRegionCountries.FirstOrDefault(Function(item) item.CountryId = intCountryID) IsNot Nothing Then
                        'a US state so set to live and only charge tax if its the base state
                        Dim sngD_Tax As Single
                        If ddlUSStates.SelectedValue = intCountryID Then
                            sngD_Tax = txtUSStateTaxRate.Text
                        Else
                            sngD_Tax = 0
                        End If
                        ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), sngD_Tax, FixNullFromDB(drwCountry("D_Tax2")),
                                                                   drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                   FixNullFromDB(drwCountry("D_Region")), True, "", FixNullFromDB(drwCountry("D_TaxExtra")))
                    Else
                        'Not US State
                        If intCountryID = 201 Then
                            'Hardcode - Turn off main USA destination record - ID : 201
                            ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), drwCountry("D_Tax"), FixNullFromDB(drwCountry("D_Tax2")),
                                                                       drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                       FixNullFromDB(drwCountry("D_Region")), False, "", FixNullFromDB(drwCountry("D_TaxExtra")))
                        Else
                            'just don't charge tax
                            ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), 0, FixNullFromDB(drwCountry("D_Tax2")),
                                                                   drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                   FixNullFromDB(drwCountry("D_Region")), drwCountry("D_Live"), "", FixNullFromDB(drwCountry("D_TaxExtra")))
                        End If

                    End If
                Next

            Case "CANADA"

                For Each drwCountry As DataRow In dtbAllCountries.Rows
                    Dim intCountryID As Integer = drwCountry("D_ID")

                    If lstRegionCountries.FirstOrDefault(Function(item) item.CountryId = intCountryID) IsNot Nothing Then
                        'a Canadian state so set to live 

                        Dim sngGST As Single
                        Dim sngPST As Single
                        Dim strTaxExtra As String
                        If ddlCanadaBaseProvince.SelectedValue = intCountryID Then
                            sngGST = txtCanadaGST.Text
                            sngPST = txtCanadaPST.Text
                            If chkCanadaPSTChargedOnPST.Checked Then
                                strTaxExtra = "compounded"
                            Else
                                strTaxExtra = ""
                            End If
                        Else
                            sngGST = 0
                            sngPST = 0
                            strTaxExtra = Nothing
                        End If
                        ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), IIf(sngGST <> 0, sngPST, FixNullFromDB(drwCountry("D_Tax2"))),
                                                                   IIf(sngPST <> 0, sngPST, FixNullFromDB(drwCountry("D_Tax2"))),
                                                                   drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                   FixNullFromDB(drwCountry("D_Region")), True, "", strTaxExtra)
                    Else
                        'Not a Canadian State
                        If intCountryID = 39 Then
                            'Hardcode - Turn off main CANADA destination record - ID : 39
                            ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), drwCountry("D_Tax"), FixNullFromDB(drwCountry("D_Tax2")),
                                                                       drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                       FixNullFromDB(drwCountry("D_Region")), False, "", FixNullFromDB(drwCountry("D_TaxExtra")))
                        Else
                            'just don't charge tax
                            ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), 0, FixNullFromDB(drwCountry("D_Tax2")),
                                                                   drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                                   FixNullFromDB(drwCountry("D_Region")), drwCountry("D_Live"), "", FixNullFromDB(drwCountry("D_TaxExtra")))
                        End If

                    End If
                Next

            Case "SIMPLE"
                For Each drwCountry As DataRow In dtbAllCountries.Rows
                    Dim intCountryID As Integer = drwCountry("D_ID")
                    If ddlSimpleBaseCountry.SelectedValue = intCountryID Then
                        'charge tax and set to live
                        ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), 1, FixNullFromDB(drwCountry("D_Tax2")),
                                                               drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                               FixNullFromDB(drwCountry("D_Region")), True, "", FixNullFromDB(drwCountry("D_TaxExtra")))
                    Else
                        'just don't charge tax
                        ShippingBLL._UpdateDestinationForTaxWizard(intCountryID, drwCountry("D_ShippingZoneID"), 0, FixNullFromDB(drwCountry("D_Tax2")),
                                                               drwCountry("D_ISOCode"), drwCountry("D_ISOCode3Letter"), drwCountry("D_ISOCodeNumeric"),
                                                               FixNullFromDB(drwCountry("D_Region")), drwCountry("D_Live"), "", FixNullFromDB(drwCountry("D_TaxExtra")))
                    End If
                Next

                'Set TaxRate Record 2 to entered tax rate value
                TaxBLL._UpdateTaxRate(2, txtSimpleTaxRate.Text, "", "")
        End Select

        'CONFIG SETTINGS - set "general.tax.pricesinctax" and "frontend.display.showtax" values
        KartSettingsManager.SetKartConfig("general.tax.pricesinctax", ddlPricesIncTaxConfig.SelectedValue, False)
        KartSettingsManager.SetKartConfig("frontend.display.showtax", ddlShowTaxConfig.SelectedValue, False)

        _UC_LangContainer.Visible = False
        ShowMasterUpdateMessage()
        pnlSummary.Visible = True
        CkartrisBLL.RefreshKartrisCache()
    End Sub

    Protected Function GetCountryListFromTaxConfig() As List(Of KartrisClasses.Country)
        Dim lstCountries As List(Of KartrisClasses.Country) = Nothing
        Dim docXML As XmlDocument = New XmlDocument
        'Load the TaxScheme Config file file from web root
        docXML.Load(HttpContext.Current.Server.MapPath("~/TaxRegime.Config"))

        Dim lstNodes As XmlNodeList
        Dim ndeDestination As XmlNode
        Dim ndeDestinationFilter As XmlNode


        Dim strRegimeNodePath As String = "/configuration/" & TaxRegime.Name & "TaxRegime/DestinationsFilter"
        Dim strKeyFieldName As String = ""
        Dim strKeyFieldValue As String = ""

        ndeDestinationFilter = docXML.SelectSingleNode(strRegimeNodePath)
        Try
            strKeyFieldName = ndeDestinationFilter.Attributes.GetNamedItem("KeyFieldName").Value
            strKeyFieldValue = ndeDestinationFilter.Attributes.GetNamedItem("KeyFieldValue").Value
        Catch ex As Exception

        End Try

        'Retrieve all countries
        Dim tblAllCountries As DataTable = ShippingBLL._GetDestinationsByLanguage(Session("_LANG"))
        lstCountries = New List(Of KartrisClasses.Country)
        For Each drwCountry As DataRow In tblAllCountries.Rows
            lstCountries.Add(KartrisClasses.Country.Get(drwCountry("D_ID")))
        Next

        'Key field value is given which means we need to filter the countries
        If Not String.IsNullOrEmpty(strKeyFieldValue) Then
            If Not String.IsNullOrEmpty(strKeyFieldName) Then
                Dim lstValidCountries As New List(Of KartrisClasses.Country)
                For Each objCountry In lstCountries
                    'Exclude 9,39,201 - Australia, Canada, USA as we're sure that we're dealing with provinces/states when this bit of code is hit
                    If objCountry.IsoCode.ToLower = strKeyFieldValue.ToLower And
                        (objCountry.CountryId <> 9 And objCountry.CountryId <> 39 And objCountry.CountryId <> 201) Then lstValidCountries.Add(objCountry)
                Next
                Return lstValidCountries
            End If
        Else
            'No Key Field given - Retrieve valid destination list from the Tax Regime Config
            lstNodes = docXML.SelectNodes(strRegimeNodePath & "/Destination")
            lstCountries = New List(Of KartrisClasses.Country)
            For Each ndeDestination In lstNodes
                lstCountries.Add(KartrisClasses.Country.GetByIsoCode(ndeDestination.Attributes.GetNamedItem("Key").Value))
            Next
        End If

        Return lstCountries
    End Function
End Class
