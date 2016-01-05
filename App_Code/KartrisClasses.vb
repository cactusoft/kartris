'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports Microsoft.VisualBasic
Imports System.Web.HttpContext
Imports System.Collections.Generic
Imports System.Data.Common
Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports System.Web.Configuration
Imports System.Xml
Imports System.Xml.Serialization
Imports KartSettingsManager
Imports System.Web.UI.TemplateControl
Imports System.Globalization
Imports System.Web.UI
''' <summary>
''' This holds the 3 primary classes that the checkout uses - ADDRESS, COUNTRY AND SHIPPING METHOD CLASS.
''' Also holds the CURRENCY and LANGUAGE classes which is used by the selection dropdowns on the Master Page.
''' and the VALIDATABLE USER CONTROL CLASS used by some user controls on the front end.
''' </summary>
''' 
Public Class KartrisClasses
#Region "COUNTRY CLASS"
    <Serializable()> _
    Public Class Country
        Private m_countryID As Integer
        Private m_shippingzoneID As Integer
        Private m_name As String, m_codeISO3166 As String, m_TaxExtra As String
        Private _TaxRate1 As Double
        Private _TaxRate2 As Double
        Private _ComputedTaxRate As Double
        Private m_tax As Boolean
        Private _isLive As Boolean
        Private Shared _connectionstring As String


        Public ReadOnly Property CountryId() As Integer
            Get
                Return m_countryID
            End Get
        End Property
        Public Property Name() As String
            Get
                Return m_name
            End Get
            Set(ByVal value As String)
                m_name = value
            End Set
        End Property
        Public Property D_Tax() As Boolean
            Get
                Return m_tax
            End Get
            Set(ByVal value As Boolean)
                m_tax = value
            End Set
        End Property

        Public Property TaxRate1() As Double
            Get
                Return _TaxRate1
            End Get
            Set(ByVal value As Double)
                _TaxRate1 = value
            End Set
        End Property
        Public Property TaxRate2() As Double
            Get
                Return _TaxRate2
            End Get
            Set(ByVal value As Double)
                _TaxRate2 = value
            End Set
        End Property
        Public Property ComputedTaxRate() As Double
            Get
                Return _ComputedTaxRate
            End Get
            Set(ByVal value As Double)
                _ComputedTaxRate = value
            End Set
        End Property
        Public Property TaxExtra() As String
            Get
                Return m_TaxExtra
            End Get
            Set(ByVal value As String)
                m_TaxExtra = value
            End Set
        End Property
        Public ReadOnly Property ShippingZoneID() As Integer
            Get
                Return m_shippingzoneID
            End Get
        End Property
        Public Property IsoCode() As String
            Get
                Return m_codeISO3166
            End Get
            Set(ByVal value As String)
                m_codeISO3166 = value
            End Set
        End Property
        Public Property isLive() As Boolean
            Get
                Return _isLive
            End Get
            Set(ByVal value As Boolean)
                _isLive = value
            End Set
        End Property
        Shared Sub New()
            _connectionstring = WebConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
        End Sub
        Public Sub New(ByVal reader As SqlDataReader)
            m_countryID = CType(reader("D_ID"), Integer)
            m_shippingzoneID = CType(reader("D_ShippingZoneID"), Integer)
            m_name = CType(reader("D_Name"), String)
            m_codeISO3166 = CType(reader("D_ISOCode"), String)

            _TaxRate1 = CDbl(FixNullFromDB(reader("D_Tax")))
            _TaxRate2 = CDbl(FixNullFromDB(reader("D_Tax2")))

            Try
                _isLive = FixNullFromDB(reader("D_Live"))
            Catch ex As Exception
                _isLive = True
            End Try

            If _TaxRate1 > 0 Or _TaxRate2 > 0 Then m_tax = True Else m_tax = False

            _ComputedTaxRate = TaxRegime.CalculateTaxRate(1, 1, _TaxRate1, _TaxRate2, "")
        End Sub
        ''' <summary>
        ''' 
        ''' </summary>
        ''' <param name="LanguageID">Optional. Gets the default language if not specified</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetAll(Optional ByVal LanguageID As Int16 = 0) As List(Of Country)
            Dim results As New List(Of Country)()
            Dim numLANGID As Int16
            If LanguageID = 0 Then
                numLANGID = GetLanguageIDfromSession()
            Else
                numLANGID = LanguageID
            End If

            If HttpContext.Current.Cache("CountryList" & numLANGID) Is Nothing Then
                Dim con As New SqlConnection(_connectionstring)
                Dim cmd As New SqlCommand("spKartrisDestinations_GetAll", con)
                cmd.Parameters.Add("@LANG_ID", SqlDbType.Int).Value = numLANGID
                cmd.CommandType = CommandType.StoredProcedure

                Using con
                    con.Open()
                    Dim reader As SqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        results.Add(New Country(reader))
                    End While
                End Using
                con.Close()
                HttpContext.Current.Cache.Insert("CountryList" & numLANGID, results, Nothing, System.Web.Caching.Cache.NoAbsoluteExpiration, TimeSpan.FromMinutes(60))
            Else
                results = HttpContext.Current.Cache("CountryList" & numLANGID)
            End If

            Return results
        End Function

        ''' <param name="LanguageID">Optional. Gets the default language if not specified</param>
        Public Shared Function [Get](ByVal countryId As Integer, Optional ByVal LanguageID As Int16 = 0) As Country
            Dim numLANGID As Int16
            If LanguageID = 0 Then
                numLANGID = GetLanguageIDfromSession()
            Else
                numLANGID = LanguageID
            End If

            Dim con As New SqlConnection(_connectionstring)
            Dim cmd As New SqlCommand("spKartrisDestinations_Get", con)
            cmd.Parameters.Add("@D_ID", SqlDbType.Int).Value = countryId
            cmd.Parameters.Add("@LANG_ID", SqlDbType.Int).Value = numLANGID
            cmd.CommandType = CommandType.StoredProcedure

            Dim result As Country
            Using con
                con.Open()
                Dim reader As SqlDataReader = cmd.ExecuteReader()
                While reader.Read()
                    result = (New Country(reader))
                    Return result
                End While
            End Using
            con.Close()
            If countryId = 0 Then Return Nothing
            CkartrisFormatErrors.LogError("Can't retrieve country info in the specified language -- COUNTRY_ID: " & countryId & "  LANGUAGE_ID: " & numLANGID)
            Return Nothing
        End Function

        ''' <param name="LanguageID">Optional. Gets the default language if not specified</param>
        Public Shared Function [GetByIsoCode](ByVal countryIsoCode As String, Optional ByVal LanguageID As Int16 = 0) As Country
            Dim numLANGID As Int16
            If LanguageID = 0 Then
                numLANGID = GetLanguageIDfromSession()
            Else
                numLANGID = LanguageID
            End If
            Dim con As New SqlConnection(_connectionstring)
            Dim cmd As New SqlCommand("spKartrisDestinations_GetbyIsoCode", con)
            cmd.Parameters.Add("@D_IsoCode", SqlDbType.Char).Value = countryIsoCode
            cmd.Parameters.Add("@LANG_ID", SqlDbType.Int).Value = numLANGID
            cmd.CommandType = CommandType.StoredProcedure

            Dim result As Country
            Using con
                con.Open()
                Dim reader As SqlDataReader = cmd.ExecuteReader()
                While reader.Read()
                    result = (New Country(reader))
                    Return result
                End While
            End Using
            con.Close()
            Return Nothing
        End Function
        ''' <param name="LanguageID">Optional. Gets the default language if not specified</param>
        Public Shared Function [GetByName](ByVal countryName As String, Optional ByVal LanguageID As Int16 = 0) As Country
            Dim numLANGID As Int16
            If LanguageID = 0 Then
                numLANGID = GetLanguageIDfromSession()
            Else
                numLANGID = LanguageID
            End If
            Dim con As New SqlConnection(_connectionstring)
            Dim cmd As New SqlCommand("_spKartrisDestinations_GetbyName", con)
            cmd.Parameters.Add("@D_Name", SqlDbType.Char).Value = countryName
            cmd.Parameters.Add("@LANG_ID", SqlDbType.Int).Value = numLANGID
            cmd.CommandType = CommandType.StoredProcedure

            Dim result As Country
            Using con
                con.Open()
                Dim reader As SqlDataReader = cmd.ExecuteReader()
                While reader.Read()
                    result = (New Country(reader))
                    Return result
                End While
            End Using
            con.Close()
            Return Nothing
        End Function
    End Class
#End Region

#Region "SHIPPING METHOD CLASS"
    <Serializable()> _
    Public Class ShippingMethod
        Private _ID As Integer
        Private _name As String, _desc As String

        Private _value As Double, _exTax As Double, _incTax As Double, _taxrate1 As Double, _taxrate2 As Double, _computedtaxrate As Double, _taxamount As Double

        Private _countryID As Integer
        Private _boundary As Double
        Private Shared _connectionstring As String
        Private numShippingTaxRate As Double = -1

        Public ReadOnly Property ID() As Integer
            Get
                Return _ID
            End Get
        End Property
        Public WriteOnly Property DestinationID() As Integer
            Set(ByVal value As Integer)
                _countryID = value
            End Set
        End Property
        Public WriteOnly Property Boundary() As Double
            Set(ByVal value As Double)
                _boundary = value
            End Set
        End Property
        Public ReadOnly Property Name() As String
            Get
                Return _name
            End Get
        End Property
        Public ReadOnly Property Description() As String
            Get
                Return _desc
            End Get
        End Property
        Public ReadOnly Property Rate() As Double
            Get
                Return _value
            End Get
        End Property

        Public ReadOnly Property ExTax() As Double
            Get
                Return _exTax
            End Get
        End Property
        Public ReadOnly Property IncTax() As Double
            Get
                Return _incTax
            End Get
        End Property
        Public ReadOnly Property TaxRate1() As Double
            Get
                Return _taxrate1
            End Get
        End Property
        Public ReadOnly Property TaxRate2() As Double
            Get
                Return _taxrate2
            End Get
        End Property
        Public ReadOnly Property ComputedTaxRate() As Double
            Get
                Return _computedtaxrate
            End Get
        End Property
        Public ReadOnly Property TaxAmount() As Double
            Get
                Return _taxamount
            End Get
        End Property
        Public ReadOnly Property DropdownValue() As String
            Get
                Return _ID & ":" & _value & ":" & _name
            End Get
        End Property
        Public ReadOnly Property DropdownText() As String
            Get
                Return _name & ":" & _exTax & ":" & _incTax
            End Get
        End Property
        Public Sub New(ByVal ShippingCountry As Country, ByVal objShippingOption As Interfaces.objShippingOption, ByVal intTempID As Integer)
            Dim blnUStaxEnabled As Boolean = ConfigurationManager.AppSettings("TaxRegime").ToLower = "us"
            Dim blnSimpletaxEnabled As Boolean = ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple"
            Dim blnNormalShippingTax As Boolean = False
            If numShippingTaxRate = -1 Then
                If blnUStaxEnabled Or blnSimpletaxEnabled Then
                    numShippingTaxRate = ShippingCountry.ComputedTaxRate
                Else
                    blnNormalShippingTax = True
                End If
            End If


            'If blnNormalShippingTax Then
            '    Dim T_ID1 As Byte = CInt(GetKartConfig("frontend.checkout.shipping.taxband"))
            '    numShippingTaxRate = TaxBLL.GetTaxRate(T_ID1)

            '    If numShippingTaxRate > 0 Then numShippingTaxRate = numShippingTaxRate / 100
            'End If

            Try
                If Current.Session("blnEUVATValidated") IsNot Nothing Then
                    If CBool(Current.Session("blnEUVATValidated")) Then
                        ShippingCountry.D_Tax = False
                        ShippingCountry.TaxRate1 = 0
                        ShippingCountry.TaxRate2 = 0
                        ShippingCountry.ComputedTaxRate = 0
                    End If
                End If
            Catch ex As Exception

            End Try

            _ID = intTempID 'CType(reader("SM_ID"), Integer)
            _name = objShippingOption.Code 'CType(reader("SM_Name"), String)
            _desc = "" 'CType(reader("SM_Desc"), String)
            _value = objShippingOption.Cost 'CType(reader("S_ShippingRate"), Double)

            If LCase(objShippingOption.CurrencyISOCode) <> LCase(CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency)) Then
                _value = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, _value, CurrenciesBLL.CurrencyID(objShippingOption.CurrencyISOCode))
            End If

            If IsNothing(numShippingTaxRate) Then
                Dim ex As Exception = New Exception("badshiptaxband")
                Throw ex
            Else
                'If objBasket.D_Tax <> "" Then shippingPrice.TaxRate = (objRecordSetMisc("T_Taxrate") / 100) * objBasket.D_Tax Else shippingPrice.TaxRate = (objRecordSetMisc("T_Taxrate") / 100)
                'Calculate shipping costs
                Dim blnPricesIncTax As Boolean '= KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y"

                If blnUStaxEnabled Or blnSimpletaxEnabled Then blnPricesIncTax = False Else blnPricesIncTax = GetKartConfig("general.tax.pricesinctax") = "y"

                'Set shipping inc and ex tax values


                'Tax rate for shipping
                If Not ShippingCountry.D_Tax Then
                    numShippingTaxRate = 0
                    _taxamount = 0
                End If

                'Set the extax and inctax shipping values
                _exTax = _value
                _incTax = Math.Round(_exTax * (1 + numShippingTaxRate), 2)
                If numShippingTaxRate > 0 Then
                    _taxamount = Math.Round(ExTax * numShippingTaxRate, 2)
                End If

                _computedtaxrate = numShippingTaxRate
                If ShippingCountry.ComputedTaxRate = 0 Then _taxrate1 = 0 : _taxrate2 = 0
            End If

        End Sub
        Public Sub New(ByVal Name As String, ByVal Description As String, ByVal ExTax As Double, ByVal IncTax As Double)
            _name = Name
            _desc = Description
            _exTax = ExTax
            _incTax = IncTax
        End Sub
        Public Sub New(ByVal reader As DataRow, ByVal ShippingCountry As Country)
            Dim blnUStaxEnabled As Boolean = ConfigurationManager.AppSettings("TaxRegime").ToLower = "us"
            Dim blnSimpletaxEnabled As Boolean = ConfigurationManager.AppSettings("TaxRegime").ToLower = "simple"
            Dim blnNormalShippingTax As Boolean = False
            If numShippingTaxRate = -1 Then
                If blnUStaxEnabled Or blnSimpletaxEnabled Then
                    numShippingTaxRate = ShippingCountry.ComputedTaxRate
                Else
                    blnNormalShippingTax = True
                End If
            End If

            If blnNormalShippingTax Then
                Dim T_ID1, T_ID2 As Byte '= CInt(GetKartConfig("frontend.checkout.shipping.taxband"))
                T_ID1 = CType(CkartrisDataManipulation.FixNullFromDB(reader("SM_Tax")), Byte)
                T_ID2 = CType(CkartrisDataManipulation.FixNullFromDB(reader("SM_Tax2")), Byte)
                numShippingTaxRate = TaxRegime.CalculateTaxRate(TaxBLL.GetTaxRate(T_ID1), TaxBLL.GetTaxRate(T_ID2), IIf(ShippingCountry.TaxRate1 > 0, ShippingCountry.TaxRate1, 1),
                                                                IIf(ShippingCountry.TaxRate2 > 0, ShippingCountry.TaxRate2, 1), ShippingCountry.TaxExtra)
                'If numShippingTaxRate > 0 Then numShippingTaxRate = numShippingTaxRate / 100
            End If

            Try
                If Current.Session("blnEUVATValidated") IsNot Nothing Then
                    If CBool(Current.Session("blnEUVATValidated")) Then
                        ShippingCountry.D_Tax = False
                        ShippingCountry.TaxRate1 = 0
                        ShippingCountry.TaxRate2 = 0
                        ShippingCountry.ComputedTaxRate = 0
                    End If
                End If
            Catch ex As Exception

            End Try

            _ID = CType(reader("SM_ID"), Integer)
            _name = CType(FixNullFromDB(reader("SM_Name")), String)
            _desc = CType(FixNullFromDB(reader("SM_Desc")), String)
            _value = CType(reader("S_ShippingRate"), Double)

            If IsNothing(numShippingTaxRate) Then
                Dim ex As Exception = New Exception("badshiptaxband")
                Throw ex
            Else
                'If objBasket.D_Tax <> "" Then shippingPrice.TaxRate = (objRecordSetMisc("T_Taxrate") / 100) * objBasket.D_Tax Else shippingPrice.TaxRate = (objRecordSetMisc("T_Taxrate") / 100)
                'Calculate shipping costs
                Dim blnPricesIncTax As Boolean '= KartSettingsManager.GetKartConfig("general.tax.pricesinctax") = "y"

                If blnUStaxEnabled Or blnSimpletaxEnabled Then blnPricesIncTax = False Else blnPricesIncTax = GetKartConfig("general.tax.pricesinctax") = "y"

                'Set shipping inc and ex tax values

                If blnPricesIncTax Then
                    'Set the extax and inctax shipping values
                    _exTax = Math.Round(_value * (1 / (1 + numShippingTaxRate)), 2)

                    'If tax is off, then inc tax can be set to just the ex tax
                    If ShippingCountry.D_Tax Then
                        _incTax = _value
                        _taxamount = _value - _exTax
                    Else
                        _incTax = _exTax
                        _taxamount = 0
                    End If

                Else
                    'Tax rate for shipping
                    If Not ShippingCountry.D_Tax Then
                        numShippingTaxRate = 0
                        _taxamount = 0
                    End If

                    'Set the extax and inctax shipping values
                    _exTax = _value
                    _incTax = Math.Round(_exTax * (1 + numShippingTaxRate), 2)
                    If numShippingTaxRate > 0 Then
                        _taxamount = Math.Round(ExTax * numShippingTaxRate, 2)
                    End If
                End If
                _computedtaxrate = numShippingTaxRate
                If ShippingCountry.ComputedTaxRate = 0 Then _taxrate1 = 0 : _taxrate2 = 0
            End If

        End Sub


        Public Shared Function GetAll(ByVal objShippingDetails As Interfaces.objShippingDetails, ByVal DestinationID As Integer, ByVal Boundary As Double, Optional ByVal LanguageID As Int16 = 0) As List(Of ShippingMethod)
            Dim results As New List(Of ShippingMethod)()
            Dim intLastID As Integer
            Dim numLANGID As Int16

            If LanguageID = 0 Then
                numLANGID = GetLanguageIDfromSession()
            Else
                numLANGID = LanguageID
            End If

            Dim ShippingCountry As Country = Country.Get(DestinationID, numLANGID)

            Dim dtShippingMethods As DataTable = ShippingBLL.GetShippingMethodsRatesByLanguage(DestinationID, Boundary, numLANGID)

            Dim blnShippingGatewayUsed As Boolean = False

            Try
                Dim intTempID As Integer = 1000
                For Each drShippingMethods In dtShippingMethods.Rows
                    blnShippingGatewayUsed = False
                    If intLastID <> CType(drShippingMethods("SM_ID"), Integer) Then

                        If Not String.IsNullOrEmpty(CStr(FixNullFromDB(drShippingMethods("S_ShippingGateways")))) Then
                            Dim strGatewayName As String = CStr(FixNullFromDB(drShippingMethods("S_ShippingGateways")))
                            Dim clsPlugin As Interfaces.ShippingGateway = Nothing
                            blnShippingGatewayUsed = True 'Thanks to Jcosmo for fix, see http://forum.kartris.com/Topic6296.aspx

                            clsPlugin = Payment.SPLoader(strGatewayName)
                            'Dim xmlShippingDetails As New Kartris.Interfaces.objShippingDetails
                            If LCase(clsPlugin.Status) <> "off" Then
                                Dim lstShippingOptions As List(Of Interfaces.objShippingOption) = Nothing

                                If LCase(clsPlugin.Currency) <> LCase(CurrenciesBLL.CurrencyCode(HttpContext.Current.Session("CUR_ID"))) Then
                                    objShippingDetails.ShippableItemsTotalPrice = CurrenciesBLL.ConvertCurrency(CurrenciesBLL.CurrencyID(clsPlugin.Currency), objShippingDetails.ShippableItemsTotalPrice, HttpContext.Current.Session("CUR_ID"))
                                End If

                                lstShippingOptions = clsPlugin.GetRates(Payment.Serialize(objShippingDetails))
                                If clsPlugin.CallSuccessful And lstShippingOptions IsNot Nothing Then
                                    For Each objShippingOption As Interfaces.objShippingOption In lstShippingOptions
                                        objShippingOption.Code = clsPlugin.GatewayName & " - " & objShippingOption.Code
                                        results.Add(New ShippingMethod(ShippingCountry, objShippingOption, intTempID))
                                        intTempID += 1
                                    Next
                                Else
                                    CkartrisFormatErrors.LogError(clsPlugin.GatewayName & " - " & clsPlugin.CallMessage)
                                End If
                            End If
                            clsPlugin = Nothing
                        End If

                        If Not blnShippingGatewayUsed Then results.Add(New ShippingMethod(drShippingMethods, ShippingCountry))
                        intLastID = CType(drShippingMethods("SM_ID"), Integer)
                    End If

                Next
            Catch e As Exception
                results = Nothing
                CkartrisFormatErrors.LogError(e.Message)
            End Try
            Return results
        End Function
        Public Shared Function GetByName(ByVal ShippingName As String, ByVal DestinationID As Integer, ByVal Boundary As Double, ByVal LanguageID As Int16) As ShippingMethod
            Dim result As ShippingMethod
            Dim numLANGID As Int16

            If LanguageID = 0 Then
                numLANGID = GetLanguageIDfromSession()
            Else
                numLANGID = LanguageID
            End If

            Dim ShippingCountry As Country = Country.Get(DestinationID, numLANGID)
            Dim dtShippingMethods As DataTable = ShippingBLL.GetShippingMethodsRatesByLanguage(DestinationID, CType(Boundary, Decimal), numLANGID)
            Try

                Dim ShippingRow As DataRow = Nothing
                For Each row As DataRow In dtShippingMethods.Rows
                    If row("SM_Name") = ShippingName Then
                        ShippingRow = row
                        Exit For
                    End If
                Next
                result = New ShippingMethod(ShippingRow, ShippingCountry)
            Catch e As Exception
                result = Nothing
                CkartrisFormatErrors.LogError(e.Message)
            End Try
            Return result
        End Function
        Public Shared Function GetByID(ByVal objShippingDetails As Interfaces.objShippingDetails, ByVal ShippingID As Integer, ByVal DestinationID As Integer, ByVal Boundary As Double, ByVal LanguageID As Int16) As ShippingMethod
            Dim result As ShippingMethod
            Dim numLANGID As Int16

            If LanguageID = 0 Then
                numLANGID = GetLanguageIDfromSession()
            Else
                numLANGID = LanguageID
            End If

            Dim ShippingCountry As Country = Country.Get(DestinationID, numLANGID)
            Dim dtShippingMethods As DataTable = ShippingBLL.GetShippingMethodsRatesByLanguage(DestinationID, CType(Boundary, Decimal), numLANGID)
            Try
                Dim intLastID As Integer
                Dim intTempID As Integer = 1000

                Dim ShippingRow As DataRow = Nothing
                For Each row As DataRow In dtShippingMethods.Rows
                    If ShippingID >= 1000 Then
                        If intLastID <> CType(row("SM_ID"), Integer) Then
                            If Not String.IsNullOrEmpty(CStr(FixNullFromDB(row("S_ShippingGateways")))) Then
                                Dim strGatewayName As String = CStr(FixNullFromDB(row("S_ShippingGateways")))
                                Dim clsPlugin As Interfaces.ShippingGateway = Nothing

                                clsPlugin = Payment.SPLoader(strGatewayName)
                                'Dim xmlShippingDetails As New Kartris.Interfaces.objShippingDetails

                                Dim lstShippingOptions As List(Of Interfaces.objShippingOption) = clsPlugin.GetRates(Payment.Serialize(objShippingDetails))
                                For Each objShippingOption As Interfaces.objShippingOption In lstShippingOptions
                                    objShippingOption.Code = clsPlugin.GatewayName & " - " & objShippingOption.Code
                                    If intTempID = ShippingID Then Return New ShippingMethod(ShippingCountry, objShippingOption, intTempID)
                                    intTempID += 1
                                Next
                                clsPlugin = Nothing
                            End If
                        End If
                    Else
                        If row("SM_ID") = ShippingID Then
                            ShippingRow = row
                            Exit For
                        End If
                    End If
                Next
                result = New ShippingMethod(ShippingRow, ShippingCountry)
            Catch e As Exception
                result = Nothing
                CkartrisFormatErrors.LogError(e.Message)
            End Try
            Return result
        End Function
    End Class
#End Region

#Region "CURRENCY CLASS"
    ''' <summary>
    ''' Currency Class
    ''' </summary>
    Public Class Currency
        Private _ID As Integer
        Private _Name As String
        Private _Symbol As String
        Private _ISOCode As String

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal Value As Integer)
                _ID = Value
            End Set
        End Property

        Public Property Name() As String
            Get
                Return _Name
            End Get
            Set(ByVal Value As String)
                _Name = Value
            End Set
        End Property
        Public Property Symbol() As String
            Get
                Return _Symbol
            End Get
            Set(ByVal Value As String)
                _Symbol = Value
            End Set
        End Property
        Public Property ISOCode() As String
            Get
                Return _ISOCode
            End Get
            Set(ByVal Value As String)
                _ISOCode = Value
            End Set
        End Property
        Public ReadOnly Property MenuDisplay() As String
            Get
                Return _Symbol & " (" & _ISOCode & ")"
            End Get
        End Property
        ''' <summary>
        ''' Load the active currencies
        ''' </summary>
        Public Shared Function LoadCurrencies() As List(Of Currency)
            ' Initialize command

            Dim tblCurrencies As DataTable = GetCurrenciesFromCache() 'CurrenciesBLL.GetCurrencies
            Dim results As New List(Of Currency)()

            For Each row As DataRow In tblCurrencies.Rows
                results.Add(New Currency(row))
            Next
            Return results
        End Function

        Public Sub New(ByVal reader As DataRow)
            _ID = CType(reader("CUR_ID"), Integer)
            '_Name = CType(reader("CUR_Name1"), String)
            _Symbol = CType(reader("CUR_Symbol"), String)
            _ISOCode = CType(reader("CUR_ISOCode"), String)
        End Sub
    End Class
#End Region

#Region "VALIDATABLEUSERCONTROL CLASS"
    Public Class ValidatableUserControl
        Inherits UserControl
        Public Overridable WriteOnly Property ValidationGroup() As String
            Set(ByVal value As String)
                For Each control As Control In Controls
                    If TypeOf control Is WebControls.BaseValidator Then
                        DirectCast(control, WebControls.BaseValidator).ValidationGroup = value
                    End If
                Next
            End Set
        End Property

        Public Overridable WriteOnly Property ErrorMessagePrefix() As String
            Set(ByVal value As String)
                For Each control As Control In Controls
                    If TypeOf control Is WebControls.BaseValidator Then
                        DirectCast(control, WebControls.BaseValidator).ErrorMessage = value + DirectCast(control, WebControls.BaseValidator).ErrorMessage
                    End If
                Next
            End Set
        End Property
    End Class
#End Region

#Region "CUSTOMPRODUCT CONTROL CLASS"
    Public MustInherit Class CustomProductControl
        Inherits System.Web.UI.UserControl

        ''' <summary>
        ''' Returns the comma separated list of values from the selected options in the control
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public MustOverride ReadOnly Property ParameterValues As String

        ''' <summary>
        ''' Returns the item description based on the selected options in the control
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public MustOverride ReadOnly Property ItemDescription As String

        ''' <summary>
        ''' Returns the computed price from the selected options in the control
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public MustOverride ReadOnly Property ItemPrice As Double

        ''' <summary>
        ''' Instructs the user control to compute and populate the properties with the correct values based on the selected options in the user control
        ''' This function must be called before retrieving the 3 properties - ParameterValues, ItemDescription and ItemPrice
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks>should return either "success" or an error message</remarks>
        Public MustOverride Function ComputeFromSelectedOptions() As String

        ''' <summary>
        ''' Calculates the price that will result from processing the given parameter values
        ''' Primarily used to check if stored price in the db/basket is correct
        ''' </summary>
        ''' <param name="ParameterValues">Comma separated list of parameters to be computed</param>
        ''' <returns></returns>
        ''' <remarks>returns -1 if parameters are invalid</remarks>
        Public MustOverride Function CalculatePrice(ByVal ParameterValues As String) As Double

    End Class
#End Region

#Region "ADDRESS CLASS"
    <Serializable()> _
    Class Address
        Public Enum ADDRESS_TYPE
            BILLING = 1
            SHIPPING = 2
            BOTH = 3
        End Enum
        Private _ID As Integer
        Private _AddressLabel As String
        Private _FullName As String
        Private _FirstName As String
        Private _LastName As String
        Private _Company As String
        Private _StreetAddress As String
        Private _TownCity As String
        Private _County As String
        Private _Postcode As String
        Private _CountryID As Integer
        Private _CountryName As String
        Private _CountryISO As String
        Private _Country As Country
        Private _Phone As String
        Private _Type As String

        Public Sub New(ByVal fullName As String, ByVal company As String, ByVal streetAddress As String, ByVal TownCity As String, _
    ByVal County As String, ByVal Postcode As String, ByVal countryId As Integer, ByVal phone As String, Optional ByVal id As Integer = 0, _
    Optional ByVal addressLabel As String = "default", Optional ByVal type As String = "u")
            'Me.FirstName = firstName
            'Me.LastName = lastName
            Me.FullName = fullName
            Me.Company = company
            Me.StreetAddress = streetAddress
            Me.TownCity = TownCity

            Me.County = County
            Me.Postcode = Postcode
            Me.CountryID = countryId
            Me.Country = Country.Get(countryId)
            Me.Phone = phone
            Me.Label = addressLabel
            Me.ID = id
            Me.Type = type
        End Sub
        Public Property Type() As String
            Get
                Return _Type
            End Get
            Set(ByVal value As String)
                _Type = value
            End Set
        End Property
        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
            End Set
        End Property
        Public Property Label() As String
            Get
                If Trim(_AddressLabel) = "" Then
                    Return _FullName & "," & Postcode & " " & Country.Name
                Else
                    Return _AddressLabel
                End If

            End Get
            Set(ByVal value As String)
                _AddressLabel = value
            End Set
        End Property
        Public Property FirstName() As String
            Get
                Return _FirstName
            End Get
            Set(ByVal value As String)
                _FirstName = value
            End Set
        End Property

        Public Property LastName() As String
            Get
                Return _LastName
            End Get
            Set(ByVal value As String)
                _LastName = value
            End Set
        End Property
        Public Property CountryID() As Integer
            Get
                Return _CountryID
            End Get
            Set(ByVal value As Integer)
                _CountryID = value
            End Set
        End Property
        Public Property FullName() As String
            Get
                Return _FullName
            End Get
            Set(ByVal value As String)
                _FullName = value
            End Set
        End Property
        Public Property Company() As String
            Get
                Return _Company
            End Get
            Set(ByVal value As String)
                _Company = value
            End Set
        End Property
        Public Property StreetAddress() As String
            Get
                Return _StreetAddress
            End Get
            Set(ByVal value As String)
                _StreetAddress = value
            End Set
        End Property
        Public Property TownCity() As String
            Get
                Return _TownCity
            End Get
            Set(ByVal value As String)
                _TownCity = value
            End Set
        End Property
        Public Property County() As String
            Get
                County = _County
            End Get
            Set(ByVal value As String)
                _County = value
            End Set
        End Property
        Public Property Postcode() As String
            Get
                Return _Postcode
            End Get
            Set(ByVal value As String)
                _Postcode = value
            End Set
        End Property
        Public Property Country() As Country
            Get
                Return _Country
            End Get
            Set(ByVal value As Country)
                _Country = value
                If _Country IsNot Nothing Then
                    _CountryID = Country.CountryId
                End If
            End Set
        End Property
        Public Property Phone() As String
            Get
                Return _Phone
            End Get
            Set(ByVal value As String)
                _Phone = value
            End Set
        End Property
        Public Shared Function [Delete](ByVal ADR_ID As Integer, ByVal ADR_UserID As Integer) As Integer
            Dim introwsAffected As Integer
            Try
                Dim _connectionString As String = WebConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
                Dim con As New SqlConnection(_connectionString)
                Dim cmd As New SqlCommand("spKartrisUsers_DeleteAddress", con)
                cmd.Parameters.Add("@ADR_UserID", SqlDbType.Int).Value = ADR_UserID
                cmd.Parameters.Add("@ADR_ID", SqlDbType.Int).Value = ADR_ID
                cmd.CommandType = CommandType.StoredProcedure
                Using con
                    con.Open()
                    introwsAffected = cmd.ExecuteNonQuery
                End Using
                con.Close()
            Catch ex As Exception

            End Try

            Return introwsAffected
        End Function
        Public Shared Function [AddUpdate](ByVal NewAddress As Address, ByVal USR_ID As Integer, Optional ByVal blnMakeDefault As Boolean = False, Optional ByVal ADR_ID As Integer = 0) As Integer
            Dim intID As Integer = 0
            Try
                Dim _connectionString As String = WebConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
                Dim con As New SqlConnection(_connectionString)
                Dim cmd As New SqlCommand("spKartrisUsers_AddUpdateAddress", con)
                cmd.Parameters.Add("@ADR_UserID", SqlDbType.Int).Value = USR_ID
                cmd.Parameters.Add("@ADR_Label", SqlDbType.NVarChar).Value = NewAddress.Label
                cmd.Parameters.Add("@ADR_Name", SqlDbType.NVarChar).Value = NewAddress.FullName
                cmd.Parameters.Add("@ADR_Company", SqlDbType.NVarChar).Value = NewAddress.Company
                cmd.Parameters.Add("@ADR_StreetAddress", SqlDbType.NVarChar).Value = NewAddress.StreetAddress
                cmd.Parameters.Add("@ADR_TownCity", SqlDbType.NVarChar).Value = NewAddress.TownCity
                cmd.Parameters.Add("@ADR_County", SqlDbType.NVarChar).Value = NewAddress.County
                cmd.Parameters.Add("@ADR_PostCode", SqlDbType.NVarChar).Value = NewAddress.Postcode
                cmd.Parameters.Add("@ADR_Country", SqlDbType.Int).Value = NewAddress.CountryID
                cmd.Parameters.Add("@ADR_Telephone", SqlDbType.NVarChar).Value = NewAddress.Phone
                cmd.Parameters.Add("@ADR_ID", SqlDbType.Int).Value = ADR_ID
                cmd.Parameters.Add("@ADR_Type", SqlDbType.NVarChar).Value = NewAddress.Type

                If blnMakeDefault Then
                    cmd.Parameters.Add("@ADR_MakeDefault", SqlDbType.Bit).Value = 1
                Else
                    cmd.Parameters.Add("@ADR_MakeDefault", SqlDbType.Bit).Value = 0
                End If
                cmd.CommandType = CommandType.StoredProcedure
                Using con
                    con.Open()
                    Dim reader As SqlDataReader = cmd.ExecuteReader
                    While reader.Read
                        intID = reader(0)
                    End While

                End Using
                con.Close()
            Catch ex As Exception

            End Try

            Return intID
        End Function
        Public Shared Function [GetAll](ByVal U_ID As Integer) As List(Of Address)
            Dim _connectionString As String = WebConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
            Dim con As New SqlConnection(_connectionString)
            Dim cmd As New SqlCommand("spKartrisUsers_GetAddressByID", con)
            cmd.Parameters.Add("@U_ID", SqlDbType.Int).Value = U_ID
            cmd.CommandType = CommandType.StoredProcedure

            Dim results As New List(Of Address)()
            Using con
                con.Open()
                Dim reader As SqlDataReader = cmd.ExecuteReader()
                While reader.Read()
                    results.Add(New Address(CType(FixNullFromDB(reader("ADR_Name")), String), CType(FixNullFromDB(reader("ADR_Company")), String), _
                                            CType(FixNullFromDB(reader("ADR_StreetAddress")), String), CType(FixNullFromDB(reader("ADR_TownCity")), String), _
                                            CType(FixNullFromDB(reader("ADR_County")), String), CType(reader("ADR_PostCode"), String), _
                                            CType(reader("ADR_Country"), Integer), CType(FixNullFromDB(reader("ADR_Telephone")), String), _
                                            CType(reader("ADR_ID"), Integer), CType(FixNullFromDB(reader("ADR_Label")), String), _
                                            CType(FixNullFromDB(reader("ADR_Type")), String)))
                End While
            End Using
            con.Close()
            Return results
        End Function
        Public Shared Function [Get](ByVal ADR_ID As Integer) As Address
            Dim _connectionString As String = WebConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
            Dim con As New SqlConnection(_connectionString)
            Dim cmd As New SqlCommand("spKartrisAddresses_Get", con)
            cmd.Parameters.Add("@ADR_ID", SqlDbType.Int).Value = ADR_ID
            cmd.CommandType = CommandType.StoredProcedure
            Dim results As Address = Nothing
            Using con
                con.Open()
                Dim reader As SqlDataReader = cmd.ExecuteReader()
                While reader.Read()
                    results = New Address(CType(FixNullFromDB(reader("ADR_Name")), String), CType(FixNullFromDB(reader("ADR_Company")), String), _
                                          CType(FixNullFromDB(reader("ADR_StreetAddress")), String), CType(FixNullFromDB(reader("ADR_TownCity")), String), _
                                          CType(FixNullFromDB(reader("ADR_County")), String), CType(FixNullFromDB(reader("ADR_PostCode")), String), _
                                                CType(reader("ADR_Country"), Integer), CType(FixNullFromDB(reader("ADR_Telephone")), String), _
                                                CType(reader("ADR_ID"), Integer), CType(FixNullFromDB(reader("ADR_Label")), String), CType(FixNullFromDB(reader("ADR_Type")), String))
                End While
            End Using
            con.Close()
            Return results
        End Function
        Public Shared Function CompareAddress(ByVal Address1 As Address, ByVal Address2 As Address) As Boolean
            With Address1
                If Not .FullName = Address2.FullName Then Return False
                If Not .StreetAddress = Address2.StreetAddress Then Return False
                If Not .Company = Address2.Company Then Return False
                If Not .TownCity = Address2.TownCity Then Return False
                If Not .County = Address2.County Then Return False
                If Not .CountryID = Address2.CountryID Then Return False
                If Not .Postcode = Address2.Postcode Then Return False
                If Not .Phone = Address2.Phone Then Return False
            End With
            Return True
        End Function
    End Class
#End Region

#Region "LANGUAGE CLASS"
    ''' <summary>
    ''' Language Class
    ''' </summary>
    Public Class Language
        Private _ID As Integer
        Private _Name As String
        Private _Culture As String
        Private _BackEndName As String


        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal Value As Integer)
                _ID = Value
            End Set
        End Property

        Public Property Name() As String
            Get
                Return _Name
            End Get
            Set(ByVal Value As String)
                _Name = Value
            End Set
        End Property
        Public Property BackendName() As String
            Get
                Return _BackEndName
            End Get
            Set(ByVal Value As String)
                _BackEndName = Value
            End Set
        End Property

        Public Property Culture() As String
            Get
                Return _Culture
            End Get
            Set(ByVal Value As String)
                _Culture = Value
            End Set
        End Property
        ''' <summary>
        ''' Load the active Languages
        ''' </summary>
        Public Shared Function LoadLanguages() As List(Of Language)
            ' Initialize command
            Dim tblLanguages As DataTable = LanguagesBLL.GetLanguages

            Dim results As New List(Of Language)()

            For Each row As DataRow In tblLanguages.Rows
                results.Add(New Language(row))
            Next
            Return results
        End Function

        Public Sub New(ByVal reader As DataRow)
            Try
                _ID = CType(reader("LANG_ID"), Integer)
                _Name = CType(reader("LANG_FrontName"), String)
                _Culture = CType(reader("LANG_Culture"), String)
                _BackEndName = CType(reader("LANG_BackName"), String)
            Catch ex As Exception
                'skip
            End Try

        End Sub
    End Class
#End Region
End Class
