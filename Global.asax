<%@ Application Language="VB" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
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

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs on application startup

        Try
            'detect application trust
            Dim p As System.Reflection.PropertyInfo = GetType(HttpRuntime).GetProperty("FileChangesMonitor", System.Reflection.BindingFlags.NonPublic Or _
               System.Reflection.BindingFlags.[Public] Or _
               System.Reflection.BindingFlags.[Static])
            Dim o As Object = p.GetValue(Nothing, Nothing)
            Dim f As System.Reflection.FieldInfo = o.[GetType]().GetField("_dirMonSubdirs", System.Reflection.BindingFlags.Instance Or _
               System.Reflection.BindingFlags.NonPublic Or _
               System.Reflection.BindingFlags.IgnoreCase)
            Dim monitor As Object = f.GetValue(o)
            Dim m As System.Reflection.MethodInfo = monitor.[GetType]().GetMethod("StopMonitoring", System.Reflection.BindingFlags.Instance Or _
             System.Reflection.BindingFlags.NonPublic)
            m.Invoke(monitor, New Object() {})
            Application("isMediumTrust") = False
        Catch
            Application("isMediumTrust") = True
        End Try

        'check if we can connect to the database
        Dim strConnectionString As String = ConfigurationManager.ConnectionStrings("kartrisSQLConnection").ToString
        Dim sqlconKartris As New SqlConnection(strConnectionString)
        Try
            sqlconKartris.Open()
            Application("DBConnected") = True
        Catch ex As Exception
            Application("DBConnected") = False
        Finally
            If sqlconKartris.State = ConnectionState.Open Then sqlconKartris.Close()
        End Try

        If Application("DBConnected") Then
            ' Register a handler for SiteMap.SiteMapResolve events so that SiteMapPath 
            ' will show the path to pages that don't appear in the site map. 
            AddHandler SiteMap.SiteMapResolve, AddressOf SiteMapHelper.ExpandPathForUnmappedPages
            AddHandler SiteMap.Providers("BreadCrumbSiteMap").SiteMapResolve, AddressOf SiteMapHelper.ExpandPathForUnmappedPages
            AddHandler SiteMap.Providers("_CategorySiteMapProvider").SiteMapResolve, AddressOf SiteMapHelper.ExpandPathForUnmappedPages
            TaxRegime.LoadTaxConfigXML()
        End If
    End Sub

    Private Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)
        'This is for payment gateway callbacks. Typically we set the
        'callback URL to something like Callback.aspx?g=paypal. But some
        'gateways seem not to pass back the querystrings, even if the specific
        'path is setup in their back end. For this reason, we want to support 
        'apparently static callback page names like Callback-paypal.aspx,
        'and then map this to the appropriate querystring value.
        Dim strFullOriginalPath As String = Request.Url.ToString()
        'Replace any ? with &
        strFullOriginalPath = Replace(strFullOriginalPath, "?", "&")
        'Replace first & back to ?
        strFullOriginalPath = Replace(strFullOriginalPath, ".aspx&g", ".aspx?g")
        If strFullOriginalPath.ToLower.Contains("/callback-") Then
            Dim strGateway As String = Replace(strFullOriginalPath.ToLower.Substring(strFullOriginalPath.ToLower.IndexOf("callback-") + 9), ".aspx", "")
            Context.RewritePath("~/Callback.aspx?g=" & strGateway)
        End If

        'This is due to a breaking change in ASP.NET 4.0 that can stop
        'postbacks working on the default document if only folder URL
        Dim strRawURL As String = Request.RawUrl.ToLower()
        If strRawURL.EndsWith("/admin") Then
            Response.Redirect(Replace(strRawURL, "/admin", "/Admin/_Default.aspx"))
        ElseIf strRawURL.EndsWith("/admin/") Then
            Response.Redirect(Replace(strRawURL, "/admin/", "/Admin/_Default.aspx"))
        ElseIf strRawURL.EndsWith("/") Then
            Response.Redirect(strRawURL & "Default.aspx")
        End If

    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
        'Trap validation request errors and return 404 so that BING
        'stops coming back calling them. This should work but doesn't
        'Any ideas?
        Dim ex As Exception = Server.GetLastError()
        If TypeOf ex Is System.Web.HttpRequestValidationException Then
            Server.ClearError()
            Response.Clear()
            Response.StatusCode = 404 'This is to stop BING and other SEs keep coming back and trying again
            Response.Write("This looks like a bad or invalid URL.")
            Response.End()
        End If

        'Log the un-handled error
        CkartrisFormatErrors.ReportUnHandledError()
    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs when a new session is started
        If Application("DBConnected") Then
            Dim objSession As New SessionsBLL
            objSession.NewSession()
            objSession.CleanExpiredSessionsData()
            Session("SessionCode") = objSession.SessionCode
            Session("SessionID") = objSession.SessionID
            objSession = Nothing

            'Create a cookie if it doesn’t exist yet (user visits the website for the first time).
            KartSettingsManager.CreateKartrisCookie()

            If Request.Cookies(HttpSecureCookie.GetCookieName("Search")) IsNot Nothing Then
                Response.Cookies.Remove(HttpSecureCookie.GetCookieName("Search"))
            End If

            'Set the default currency - can no longer
            'assume is ID=1
            Dim tblCurrencies As DataTable = KartSettingsManager.GetCurrenciesFromCache() 'CurrenciesBLL.GetCurrencies()
            Dim drwLiveCurrencies As DataRow() = tblCurrencies.Select("CUR_Live = 1")
            If drwLiveCurrencies.Length > 0 Then
                Session("CUR_ID") = CInt(drwLiveCurrencies(0)("CUR_ID"))
            Else
                Session("CUR_ID") = 1
            End If

            'clear other session values, just to make sure
            'we start everything right
            Session("ProductsToCompare") = ""
            Session("SearchKeyWords") = String.Empty
            Session("HTMLEditorFieldID") = 0
            Session("RecentProducts") = String.Empty
        End If
    End Sub

    Public Overrides Function GetVaryByCustomString(context As HttpContext, arg As String) As String
        'This lets us store different caches for different cultures (e.g. en-EN, de-DE)
        Dim Page = TryCast(context.Handler, PageBaseClass)

        If arg.ToLower() = "culture;user" Then Return context.Session("KartrisUserCulture").ToString() & ";" & Page.User.Identity.Name
        Return MyBase.GetVaryByCustomString(context, arg)
    End Function

</script>