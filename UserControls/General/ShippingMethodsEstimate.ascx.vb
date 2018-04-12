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
Imports System.Collections.Generic
Imports KartSettingsManager
Imports KartrisClasses

Partial Class UserControls_ShippingMethodsEstimate
    Inherits System.Web.UI.UserControl
    Private _boundary As Double
    Private _destinationid As Integer
    Private _shippingdetails As Kartris.Interfaces.objShippingDetails

    ''' <summary>
    ''' Handle refresh
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Sub Refresh()

        'Hide this control if not turned on from config settings
        If GetKartConfig("frontend.minibasket.shippingestimate") <> "y" Then
            Me.Visible = False
            Response.End()
        End If

        Dim strPickupAvailable As String = ""
        Dim CUR_ID As Integer = CInt(Session("CUR_ID"))

        If GetKartConfig("frontend.checkout.shipping.pickupoption") = "y" Then strPickupAvailable = GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup")

        If ddlCountry.SelectedValue = 0 Then
            Dim intSessionShippingCountry As Integer = Session("ShippingEstimateCountry")
            If intSessionShippingCountry > 0 Then

                Try
                    ddlCountry.SelectedValue = intSessionShippingCountry
                Catch ex As Exception
                End Try
                _destinationid = intSessionShippingCountry
            Else
                '' try to get the default shipping destination if session is empty
                _destinationid = GetDefaultDestinationForUser()
                If _destinationid = 0 Then _destinationid = KartSettingsManager.GetKartConfig("frontend.checkout.defaultcountry")
                If _destinationid = 0 Then _destinationid = GetDestinationFromBrowser()
                If _destinationid = 0 Then
                    ddlCountry.SelectedValue = 0
                Else
                    Try
                        Dim objCountry As KartrisClasses.Country = KartrisClasses.Country.Get(_destinationid)
                        Dim strIso As String = objCountry.IsoCode
                        Dim lstCountries As List(Of Country) = KartrisClasses.Country.GetAll()
                        Dim varC = From c In lstCountries
                                   Where c.IsoCode = strIso
                                   Order By c.Name
                                   Select c.CountryId

                        ddlCountry.SelectedValue = varC.First()
                    Catch ex As Exception
                    End Try
                End If
            End If
        Else
            _destinationid = ddlCountry.SelectedValue
            'remember selected shipping country
            Session("ShippingEstimateCountry") = ddlCountry.SelectedValue
        End If

        Dim lstShippingMethods As List(Of ShippingMethod) = ShippingMethod.GetAll(_shippingdetails, _destinationid, CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, _boundary, CUR_ID))

        If lstShippingMethods IsNot Nothing Then
            lblError.Visible = False
            'add customer pickup if it is enabled in config
            If Not String.IsNullOrEmpty(strPickupAvailable) Then
                Dim spPickup As New ShippingMethod(strPickupAvailable, GetGlobalResourceObject("Shipping", "ContentText_ShippingPickupDesc"), 0, 0)
                lstShippingMethods.Add(spPickup)
            End If


            If GetKartConfig("frontend.display.showtax") <> "y" Then
                If GetKartConfig("general.tax.pricesinctax") <> "y" Then
                    'Show extax
                    gvwShippingMethods.Columns(2).HeaderText = GetGlobalResourceObject("Kartris", "ContentText_Price")
                    gvwShippingMethods.Columns(3).Visible = False
                Else
                    'Show inctax
                    gvwShippingMethods.Columns(2).Visible = False
                    gvwShippingMethods.Columns(3).HeaderText = GetGlobalResourceObject("Kartris", "ContentText_Price")
                End If
            End If
            'hide extax field field showtax config is set to 'n'
            'If GetKartConfig("frontend.display.showtax") <> "y" Then
            '    gvwShippingMethods.Columns(2).Visible = False
            '    gvwShippingMethods.Columns(3).HeaderText = GetGlobalResourceObject("Kartris", "ContentText_Price")
            'Else
            '    gvwShippingMethods.Columns(2).Visible = True
            'End If

            gvwShippingMethods.DataSource = lstShippingMethods
            gvwShippingMethods.DataBind()
        Else
            lblError.Visible = True
        End If

    End Sub

    ''' <summary>
    ''' Apply appropriate pricing
    ''' Inc/Ex tax, or just price
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Sub gvwShippingMethods_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwShippingMethods.RowDataBound
        If e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Header And e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Footer Then
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim litShippingMethodNameExTax As Literal = DirectCast(e.Row.FindControl("litShippingMethodNameExTax"), Literal)
                Dim litShippingMethodNameIncTax As Literal = DirectCast(e.Row.FindControl("litShippingMethodNameIncTax"), Literal)

                Dim CUR_ID As Integer = CInt(Session("CUR_ID"))
                'format shipping method's extax and inctax values
                Dim strIncTax As String = CurrenciesBLL.FormatCurrencyPrice(CUR_ID, CurrenciesBLL.ConvertCurrency(CUR_ID, CDbl(litShippingMethodNameIncTax.Text)))
                Dim strExTax As String = CurrenciesBLL.FormatCurrencyPrice(CUR_ID, CurrenciesBLL.ConvertCurrency(CUR_ID, CDbl(litShippingMethodNameExTax.Text)))

                litShippingMethodNameExTax.Text = strExTax
                litShippingMethodNameIncTax.Text = strIncTax
            End If
        End If
    End Sub

    Public WriteOnly Property Boundary() As Double
        Set(ByVal value As Double)
            _boundary = value
        End Set
    End Property

    Public WriteOnly Property ShippingDetails() As Interfaces.objShippingDetails
        Set(ByVal value As Interfaces.objShippingDetails)
            _shippingdetails = value
        End Set
    End Property

    ''' <summary>
    ''' Find user's location based on address if they
    ''' are logged in
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Function GetDefaultDestinationForUser() As Integer
        If DirectCast(Page, PageBaseClass).CurrentLoggedUser IsNot Nothing Then
            '' will try to find the default shipping address, if not then default billing address for the current user
            Dim lstUsrAddresses As Collections.Generic.List(Of KartrisClasses.Address) = Nothing
            lstUsrAddresses = KartrisClasses.Address.GetAll(CType(Page, PageBaseClass).CurrentLoggedUser.ID)
            Dim Addresses As List(Of Address) = lstUsrAddresses.FindAll(Function(p) p.Type = "b" Or p.Type = "u")
            If CType(Page, PageBaseClass).CurrentLoggedUser.DefaultShippingAddressID <> 0 Then
                Dim adrs As Address = Addresses.Find(Function(p) p.ID = CType(Page, PageBaseClass).CurrentLoggedUser.DefaultShippingAddressID)
                If adrs IsNot Nothing Then Return adrs.CountryID
            ElseIf CType(Page, PageBaseClass).CurrentLoggedUser.DefaultBillingAddressID <> 0 Then
                Dim adrs As Address = Addresses.Find(Function(p) p.ID = CType(Page, PageBaseClass).CurrentLoggedUser.DefaultBillingAddressID)
                If adrs IsNot Nothing Then Return adrs.CountryID
            End If
        End If
        Return 0
    End Function

    ''' <summary>
    ''' Guess the user's location from browser culture
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Function GetDestinationFromBrowser() As Integer
        'Not perfect, but better than nothing. Could be
        'done by IP, but this would require a lookup and
        'browser culture is probably better guide (some
        'countries use multiple languages, or someone
        'might be using their computer overseas)
        Try
            Dim ClientLanguages() As String = HttpContext.Current.Request.UserLanguages
            If ClientLanguages IsNot Nothing AndAlso ClientLanguages.Length > 0 Then
                Dim culture As System.Globalization.CultureInfo = System.Globalization.CultureInfo.CreateSpecificCulture(ClientLanguages(0).ToLowerInvariant.Trim())
                If culture IsNot Nothing Then Return KartrisClasses.Country.GetByIsoCode(New System.Globalization.RegionInfo(culture.LCID).TwoLetterISORegionName, Session("LangID")).CountryId
            End If
        Catch ex As Exception
        End Try
        Return 0
    End Function

End Class
