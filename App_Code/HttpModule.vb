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
Imports System
Imports System.IO
Imports System.Web
Imports System.Text
Imports System.Security.Cryptography
Imports System.Web.UI

Public Class KartrisHttpModule
    Implements IHttpModule

    Private Shared HasAppStarted As Boolean = False
    Private Shared ReadOnly _syncObject As New Object()

    Public Sub Dispose() Implements System.Web.IHttpModule.Dispose
    End Sub

    Public Sub Init(ByVal context As HttpApplication) Implements System.Web.IHttpModule.Init
        AddHandler context.BeginRequest, AddressOf Kartris_BeginRequest
        AddHandler context.PreRequestHandlerExecute, AddressOf Kartris_PreRequestExecute

        If Not HasAppStarted Then
            SyncLock _syncObject
                If Not HasAppStarted Then
                    'Run application StartUp code here
                    If context.Application("DBConnected") Then
                        KartSettingsManager.RefreshCache()
                        KartSettingsManager.RefreshCurrencyCache()
                        LanguagesBLL.GetLanguages(True) 'Refresh cache for the front end dropdown
                        KartSettingsManager.RefreshLanguagesCache()
                        KartSettingsManager.RefreshLETypesFieldsCache()
                        KartSettingsManager.RefreshTopListProductsCache()
                        KartSettingsManager.RefreshNewestProductsCache()
                        KartSettingsManager.RefreshFeaturedProductsCache()
                        KartSettingsManager.RefreshCustomerGroupsCache()
                        KartSettingsManager.RefreshSuppliersCache()
                        KartSettingsManager.RefreshTaxRateCache()
                        KartSettingsManager.RefreshSiteNewsCache()
                        CkartrisBLL.LoadSkinConfigToCache()
                        HttpRuntime.Cache.Insert("CategoryMenuKey", DateTime.Now)
                        HasAppStarted = True
                    End If
                End If
            End SyncLock
        End If

    End Sub

    Sub Kartris_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)
        Dim context As HttpContext = HttpContext.Current
        Dim strCurrentPath As String = context.Request.RawUrl.ToString
        If Not context.Application("CorrectGlobalizationTag") Then
            'read the web.config file and check if the globalization tags and language string providers are properly set
            ' - if not then we probably need to redirect to 'admin/install.aspx'
            Dim webConfigFile As String = Path.Combine(HttpContext.Current.Request.PhysicalApplicationPath, "web.config")
            Dim webConfigReader As New System.Xml.XmlTextReader(New StreamReader(webConfigFile))

            If Not ((webConfigReader.ReadToFollowing("globalization")) AndAlso (webConfigReader.GetAttribute("resourceProviderFactoryType") = "SqlResourceProviderFactory")) Then
                'display 
                If InStr(strCurrentPath.ToLower, "admin/install.aspx") = 0 AndAlso InStr(strCurrentPath.ToLower, ".css") = 0 AndAlso _
                InStr(strCurrentPath.ToLower, ".png") = 0 AndAlso InStr(strCurrentPath.ToLower, ".axd") = 0 Then
                    context.Response.Redirect("~/Admin/Install.aspx")
                    context.Response.End()
                End If
            Else
                context.Application("CorrectGlobalizationTag") = True
            End If

            webConfigReader.Close()
        End If

        'Rewrite URLs if SEO friendly URLs config is on
        If context.Application("DBConnected") AndAlso KartSettingsManager.GetKartConfig("general.seofriendlyurls.enabled") = "y" Then
            '' Support for the old SEO format, the code below will still handle the page     
            If (InStr(strCurrentPath, "/c-p-") OrElse InStr(strCurrentPath, "/c-s-") OrElse InStr(strCurrentPath, "/p-") OrElse _
                InStr(strCurrentPath, "/n-") OrElse InStr(strCurrentPath, "/k-")) _
                AndAlso InStr(strCurrentPath.ToLower, "webkit.js") = 0 AndAlso Right(strCurrentPath, 1) = "/" Then
                If strCurrentPath.EndsWith("/") Then strCurrentPath = strCurrentPath.TrimEnd("/")
                strCurrentPath &= ".aspx"
                strCurrentPath = strCurrentPath.Replace("/c-p-", "__c-p-")
                strCurrentPath = strCurrentPath.Replace("/c-s-", "__c-s-")
                strCurrentPath = strCurrentPath.Replace("/p-", "__p-")
                strCurrentPath = strCurrentPath.Replace("/n-", "__n-")
                strCurrentPath = strCurrentPath.Replace("/k-", "__k-")
                If strCurrentPath <> "" Then
                    context.Response.StatusCode = 301
                    context.Response.Status = "301 Moved Permanently"
                    context.Response.AddHeader("Location", strCurrentPath)
                End If
            End If

            'Check if the current URL contains either "/c-p-" or "/p-" which indicates
            'it is a category or product fakelink which needs to be rewritten
            If (InStr(strCurrentPath, "__c-p-") OrElse InStr(strCurrentPath, "__c-s-") OrElse InStr(strCurrentPath, "__p-") OrElse _
                InStr(strCurrentPath, "__n-") OrElse InStr(strCurrentPath, "/t-") OrElse InStr(strCurrentPath, "__k-")) _
                AndAlso InStr(strCurrentPath.ToLower, "webkit.js") = 0 Then
                strCurrentPath = SiteMapHelper.SEORewrite(strCurrentPath)
                If strCurrentPath <> "" Then context.RewritePath(strCurrentPath)
            End If
        End If
    End Sub

    Sub Kartris_PreRequestExecute(ByVal sender As Object, ByVal e As EventArgs)
        'this event occurs after the beginrequest event above
        'but occurs just before ASP.NET starts executing an event handler (ie. , a page , user control or a web service).

        Dim context As HttpContext = HttpContext.Current
        Dim strCurrentPath As String = context.Request.RawUrl.ToLower.ToString
    End Sub
End Class

