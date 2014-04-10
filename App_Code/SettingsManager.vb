'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Configuration
Imports System.Web.Configuration
Imports System.Web.Caching

''' <summary>
''' Kartris Config Settings Manager
''' </summary>
Public Class KartSettingsManager

    ''' <summary>
    ''' Checks if a commercial license file is present in the root. Note that this does
    ''' not check the validity of such a license, only that a file is present.
    ''' </summary>
    Public Shared Function HasCommercialLicense() As Boolean
        If File.Exists(HttpContext.Current.Server.MapPath("~/license.config")) Then
            Return True
        Else
            Return False
        End If
    End Function

    ''' <summary>
    ''' Checks if a commercial license file is present in the root. Note that this does
    ''' not check the validity of such a license, only that a file is present.
    ''' </summary>
    Public Shared Function PoweredByLink() As String
        Dim sbdLink As New StringBuilder

        'Build up string of the 'powered by kartris' tag
        sbdLink.Append("<a onmouseover=""this.style.backgroundColor = '#AD004D';this.style.color = '#fff';"" onmouseout=""this.style.backgroundColor = '#fff';this.style.color = '#AD004D';"" style=""line-height: 13px;display:inline-block;padding:1px 2px 1px 3px;font-size:7pt;font-family:tahoma,arial,helvetica;position:fixed;bottom:0;right:30px;color:#AD004D;background-color:#fff;""" & vbCrLf)
        sbdLink.Append(" href=""http://www.kartris.com/"" title=""Kartris - &copy;2014, Cactusoft International FZ LLC. Distributed free and without warranty under the terms of the GNU GPL."">Powered by <span style=""font-weight: bold"">kartris</span></a>")

        Return sbdLink.ToString
    End Function

    ''' <summary>
    ''' Set/update a config setting value. The equivalent of CactuShop's GetAppVar function
    ''' </summary>
    ''' <param name="Config_Name">The name of the config setting you want to retrieve.</param>
    ''' <param name="RefreshCache">Optional: Default value is false. Flag to refresh config cache. </param>
    Public Shared Function GetKartConfig(ByVal Config_Name As String, Optional ByVal RefreshCache As Boolean = False) As String
        If RefreshCache Or HttpRuntime.Cache("KartSettingsCache") Is Nothing Then
            KartSettingsManager.RefreshCache()
        End If

        If Config_Name <> "" Then
            Dim tblWebSettings As DataTable = CType(HttpRuntime.Cache("KartSettingsCache"), DataTable)
            Dim drwWebSettings As DataRow() = tblWebSettings.Select("CFG_Name = '" & Config_Name & "'")
            If drwWebSettings.Length = 0 Then
                ' The Config_Name was not found
                Return ""
            Else
                ' The Config_Name was found: return row
                Return drwWebSettings(0)("CFG_Value").ToString()
            End If
        Else
            ' this condition is still here in case you call:  GetKartConfig("", True)
            ' this will return nothing but still refresh the cache
            Return ""
        End If
    End Function

    ''' <summary>
    ''' Set/update a config setting value. The equivalent of CactuShop's SetAppVar function
    ''' </summary>
    ''' <param name="Config_Name">The name of the config setting you want to update.</param>
    ''' <param name="Config_Value">The new config setting value.</param>
    ''' <param name="RefreshCache">Optional: Refresh config cache. Set to either true or false. </param>
    Public Overloads Shared Sub SetKartConfig(ByVal Config_Name As String, ByVal Config_Value As String, Optional ByVal RefreshCache As Boolean = True)
        'Update Database            
        ConfigBLL._UpdateConfigValue(Config_Name, Config_Value)
    End Sub

    ''' <summary>
    ''' Refresh config settings cache.
    ''' </summary>
    Public Overloads Shared Sub RefreshCache()

        If Not HttpRuntime.Cache("KartSettingsCache") Is Nothing Then HttpRuntime.Cache.Remove("KartSettingsCache")
        Dim tblWebSettings As DataTable = New DataTable
        tblWebSettings = ConfigBLL.GetConfigCacheData()
        HttpRuntime.Cache.Add("KartSettingsCache", _
                     tblWebSettings, Nothing, Date.MaxValue, TimeSpan.Zero, _
                     Caching.CacheItemPriority.High, Nothing)
        'Replaced HttpContext.Current.Cache by HttpRuntime.Cache as it seems to be faster and more efficient
    End Sub

    ''=======  Currency Caching  =======
    Public Shared Sub RefreshCurrencyCache()

        If Not HttpRuntime.Cache("KartrisCurrenciesCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisCurrenciesCache")
        Dim tblCurrencies As DataTable = CurrenciesBLL._GetCurrencies()
        HttpRuntime.Cache.Add("KartrisCurrenciesCache", tblCurrencies, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.High, Nothing)

    End Sub

    Public Shared Function GetCurrenciesFromCache() As DataTable
        If HttpRuntime.Cache("KartrisCurrenciesCache") Is Nothing Then
            KartSettingsManager.RefreshCurrencyCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisCurrenciesCache"), DataTable)
    End Function

    ''=======  Languages Caching  =======
    Public Shared Sub RefreshLanguagesCache()
        LanguagesBLL.GetLanguages(True)
        If Not HttpRuntime.Cache("KartrisLanguagesCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisLanguagesCache")
        Dim tblLanguages As DataTable = LanguagesBLL._GetLanguages()
        HttpRuntime.Cache.Add("KartrisLanguagesCache", tblLanguages, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.High, Nothing)
    End Sub

    Public Shared Function GetLanguagesFromCache() As DataTable
        If HttpRuntime.Cache("KartrisLanguagesCache") Is Nothing Then
            KartSettingsManager.RefreshLanguagesCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisLanguagesCache"), DataTable)
    End Function

    ''=======  LE Types' Fields Caching  =======
    Public Shared Sub RefreshLETypesFieldsCache()

        If Not HttpRuntime.Cache("KartrisLETypesFieldsCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisLETypesFieldsCache")
        Dim tblLETypeFields As DataTable = LanguagesBLL._GetTypeFieldDetails()
        HttpRuntime.Cache.Add("KartrisLETypesFieldsCache", tblLETypeFields, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.High, Nothing)
    End Sub

    Public Shared Function GetLETypesFieldsFromCache() As DataTable
        If HttpRuntime.Cache("KartrisLETypesFieldsCache") Is Nothing Then
            KartSettingsManager.RefreshLETypesFieldsCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisLETypesFieldsCache"), DataTable)
    End Function

    ''=======  Featured Products Caching  ======
    Public Shared Sub RefreshFeaturedProductsCache()

        If Not HttpRuntime.Cache("KartrisFeaturedProductsCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisFeaturedProductsCache")
        Dim tblFeaturedProducts As DataTable = ProductsBLL.GetFeaturedProductForCache()
        HttpRuntime.Cache.Add("KartrisFeaturedProductsCache", tblFeaturedProducts, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.Normal, Nothing)
    End Sub

    Public Shared Function GetFeaturedProductsFromCache() As DataTable
        If HttpRuntime.Cache("KartrisFeaturedProductsCache") Is Nothing Then
            KartSettingsManager.RefreshFeaturedProductsCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisFeaturedProductsCache"), DataTable)
    End Function

    ''=======  Newest Products Caching  ======
    Public Shared Sub RefreshNewestProductsCache()

        If Not HttpRuntime.Cache("KartrisNewestProductsCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisNewestProductsCache")
        Dim tblNewestProducts As DataTable = ProductsBLL.GetNewestProductsForCache()
        HttpRuntime.Cache.Add("KartrisNewestProductsCache", tblNewestProducts, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.Normal, Nothing)

    End Sub

    Public Shared Function GetNewestProductsFromCache() As DataTable
        If HttpRuntime.Cache("KartrisNewestProductsCache") Is Nothing Then
            KartSettingsManager.RefreshNewestProductsCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisNewestProductsCache"), DataTable)
    End Function

    ''=======  TopList Products Caching  ======
    Public Shared Sub RefreshTopListProductsCache()

        If Not HttpRuntime.Cache("KartrisTopListProductsCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisTopListProductsCache")
        Dim tblTopListProducts As DataTable = ProductsBLL.GetTopListProductsForCache()
        HttpRuntime.Cache.Add("KartrisTopListProductsCache", tblTopListProducts, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.Normal, Nothing)
    End Sub

    Public Shared Function GetTopListProductsFromCache() As DataTable
        If HttpRuntime.Cache("KartrisTopListProductsCache") Is Nothing Then
            KartSettingsManager.RefreshTopListProductsCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisTopListProductsCache"), DataTable)
    End Function

    ''=======  Suppliers Caching  ======
    Public Shared Sub RefreshSuppliersCache()

        If Not HttpRuntime.Cache("KartrisSuppliersCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisSuppliersCache")
        Dim tblSuppliers As DataTable = UsersBLL._GetSuppliersForCache()
        HttpRuntime.Cache.Add("KartrisSuppliersCache", tblSuppliers, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.Low, Nothing)
    End Sub

    Public Shared Function GetSuppliersFromCache() As DataTable
        If HttpRuntime.Cache("KartrisSuppliersCache") Is Nothing Then
            KartSettingsManager.RefreshSuppliersCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisSuppliersCache"), DataTable)
    End Function

    ''=======  Customer Groups Caching  ======
    Public Shared Sub RefreshCustomerGroupsCache()

        If Not HttpRuntime.Cache("KartrisCustomerGroupsCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisCustomerGroupsCache")
        Dim tblCG As DataTable = UsersBLL._GetCustomerGroupsForCache()
        HttpRuntime.Cache.Add("KartrisCustomerGroupsCache", tblCG, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.Low, Nothing)
    End Sub

    Public Shared Function GetCustomerGroupsFromCache() As DataTable
        If HttpRuntime.Cache("KartrisCustomerGroupsCache") Is Nothing Then
            KartSettingsManager.RefreshCustomerGroupsCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisCustomerGroupsCache"), DataTable)
    End Function

    ''=======  TaxRates Caching  ======
    Public Shared Sub RefreshTaxRateCache()
        'If KartSettingsManager.GetKartConfig("general.tax.usmultistatetax") = "y" Then Return

        If Not HttpRuntime.Cache("KartrisTaxRatesCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisTaxRatesCache")
        Dim tblTaxRates As DataTable = TaxBLL._GetTaxRatesForCache()
        HttpRuntime.Cache.Add("KartrisTaxRatesCache", tblTaxRates, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.Low, Nothing)
    End Sub

    Public Shared Function GetTaxRateFromCache() As DataTable
        'If KartSettingsManager.GetKartConfig("general.tax.usmultistatetax") = "y" Then Return Nothing

        If HttpRuntime.Cache("KartrisTaxRatesCache") Is Nothing Then
            KartSettingsManager.RefreshTaxRateCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisTaxRatesCache"), DataTable)
    End Function

    ''=======  SiteNews Caching  ======
    Public Shared Sub RefreshSiteNewsCache()

        If Not HttpRuntime.Cache("KartrisSiteNewsCache") Is Nothing Then HttpRuntime.Cache.Remove("KartrisSiteNewsCache")
        Dim tblSiteNews As DataTable = NewsBLL._GetNewsForCache()
        HttpRuntime.Cache.Add("KartrisSiteNewsCache", tblSiteNews, Nothing, Date.MaxValue, TimeSpan.Zero, _
                               CacheItemPriority.Normal, Nothing)
    End Sub

    Public Shared Function GetSiteNewsFromCache() As DataTable
        If HttpRuntime.Cache("KartrisSiteNewsCache") Is Nothing Then
            KartSettingsManager.RefreshSiteNewsCache()
        End If
        Return DirectCast(HttpRuntime.Cache("KartrisSiteNewsCache"), DataTable)
    End Function

    Public Shared Function CreateKartrisCookie() As Boolean
        If HttpContext.Current.Request.Cookies(HttpSecureCookie.GetCookieName()) Is Nothing Then
            Dim cokKartris As New HttpCookie(HttpSecureCookie.GetCookieName())

            cokKartris.Expires = System.DateTime.Now.AddDays(21)

            'check if the language culture of the browser is one of the supported languages - [language-region]
            If LanguagesBLL.GetLanguageIDByCulture_s(System.Threading.Thread.CurrentThread.CurrentCulture.Name) > 0 Then
                cokKartris.Values("KartrisUserCulture") = System.Threading.Thread.CurrentThread.CurrentCulture.Name
            Else
                'check if the language culture of the browser is one of the supported languages - [language] only
                Dim intLangID As Byte = LanguagesBLL.GetLanguageIDByCultureUI_s(System.Threading.Thread.CurrentThread.CurrentCulture.Name)

                If intLangID > 0 Then
                    cokKartris.Values("KartrisUserCulture") = LanguagesBLL.GetCultureByLanguageID_s(intLangID)
                Else
                    cokKartris.Values("KartrisUserCulture") = LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID())
                End If

                'if not then get default language culture from config setting

            End If

            HttpContext.Current.Request.Cookies.Add(cokKartris)
            Return True
        Else : Return False
        End If
    End Function
End Class
