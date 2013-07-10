'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Globalization
Imports System.Diagnostics
Imports System.Threading
Imports KartSettingsManager
Imports System.Web.UI

Public MustInherit Class _PageBaseClass

    Inherits System.Web.UI.Page

    Protected NotOverridable Overrides Sub Render(ByVal writer As HtmlTextWriter)

        'Create our own mechanism to store the page output
        'This way we can alter the text of the page prior to
        'rendering.
        'If Not Page.IsPostBack Then
        Dim sbdPageSource As StringBuilder = New StringBuilder()
        Dim objStringWriter As StringWriter = New StringWriter(sbdPageSource)
        Dim objHtmlWriter As HtmlTextWriter = New HtmlTextWriter(objStringWriter)
        MyBase.Render(objHtmlWriter)

        'Add copyright notice - NOTE, this should not be
        'removed, under the GPL this conforms to the definition
        'of a copyright notification message
        RunGlobalReplacements(sbdPageSource)

        'Output replacements
        writer.Write(sbdPageSource.ToString())
    End Sub

    Protected Overrides Sub InitializeCulture()
        If Not IsPostBack Then
            'Set the UICulture and the Culture with a value stored in a Session-object.
            Dim strBackUserCulture As String
            If CInt(Session("_LANG")) > 0 Then
                strBackUserCulture = LanguagesBLL.GetCultureByLanguageID_s(CInt(Session("_LANG")))
            Else
                strBackUserCulture = LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID)
                Session("_LANG") = LanguagesBLL.GetDefaultLanguageID
            End If
            Thread.CurrentThread.CurrentUICulture = New CultureInfo(strBackUserCulture)
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US")
            MyBase.InitializeCulture()
        End If

    End Sub

    Private Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Error
        CkartrisFormatErrors.LogError()
    End Sub

    Private Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreInit
        'Theme = "Admin"
        MasterPageFile = "~/Skins/Admin/Template.master"
    End Sub

    Private Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        'Additional security - this ensures that all of our viewstate are unique and is tied to the user's session
        ViewStateUserKey = Session.SessionID
    End Sub

    Protected NotOverridable Overrides Sub OnPreLoad(ByVal e As System.EventArgs)
        Page.Title = GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        '301 Redirect Code
        'On the back end, we want this to be a little smarter than the front. If you restore
        'a local db to a live site, very often you will still have the local webshopURL set up.
        'If we simply redirect to the webshopURL setting, then it will keep sending you to your
        'local site backend instead of allowing you in to the live site in order to change this
        'setting.

        'But we do want to redirect from domain.xyz to www.domain.xyz if someone uses that in
        'order that SSL sites don't show security issues.

        'So what we ideally want is to redirect to the webshopURL only if it is the same as 
        'the entered URL but with or without www.
        If InStr(Request.Url.ToString.ToLower, CkartrisBLL.WebShopURL.ToLower) = 0 Then

            'URL doesn't match the webshopURL setting, so check if it is close (www only difference)
            If InStr(Replace(Request.Url.ToString.ToLower, "://", "://www."), CkartrisBLL.WebShopURL.ToLower) = 0 And _
                InStr(Request.Url.ToString.ToLower, Replace(CkartrisBLL.WebShopURL.ToLower, "://", "://www.")) = 0 Then

                'webshopURL very different from entered one, do nothing so user can login here
                'and access back end in order to update webshopURL
            Else
                'Domain entered very similar to one in webshopURL, e.g. entered domain without www,
                'so we redirect to correct one to ensure SSL if present doesn't give security error
                Dim strRedirectURL As String = CkartrisDisplayFunctions.CleanURL(Request.RawUrl.ToLower)

                'remove the web shop folder if present - webshopurl already contains this
                strRedirectURL = Replace(strRedirectURL, "/" & CkartrisBLL.WebShopFolder.ToLower, "")
                If Left(strRedirectURL, 1) = "/" Then strRedirectURL = Mid(strRedirectURL, 2)
                Response.Status = "301 Moved Permanently"
                'append the webshop url
                Response.AddHeader("Location", CkartrisBLL.WebShopURL & strRedirectURL)
            End If
        End If
    End Sub

    Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then

            'Postbacks don't work on ipads and some other Apple devices
            'because they're assumed to be generic primitive devices not
            'capable of an 'uplevel' experience. This fixes it.
            Dim strUserAgent As String = Request.UserAgent
            If strUserAgent IsNot Nothing _
                AndAlso (strUserAgent.IndexOf("iPhone", StringComparison.CurrentCultureIgnoreCase) >= 0 _
                OrElse strUserAgent.IndexOf("iPad", StringComparison.CurrentCultureIgnoreCase) >= 0 _
                OrElse strUserAgent.IndexOf("iPod", StringComparison.CurrentCultureIgnoreCase) >= 0) _
                AndAlso strUserAgent.IndexOf("Safari", StringComparison.CurrentCultureIgnoreCase) < 0 Then
                Me.ClientTarget = "uplevel"
            End If

            'Get user's IP address
            Dim strClientIP As String = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
            If String.IsNullOrEmpty(strClientIP) Then
                strClientIP = Request.ServerVariables("REMOTE_ADDR")
            End If

            'Check matches specified IPs in web.config, if not blank
            Dim strBackEndIPLock = ConfigurationManager.AppSettings("BackEndIpLock").ToString()
            If strBackEndIPLock <> "" Then
                Try
                    Dim arrBackendIPs As String() = Split(strBackEndIPLock, ",")
                    Dim blnFullIP As Boolean
                    Dim blnAllowIP As Boolean = False
                    For x As Integer = 0 To arrBackendIPs.Count - 1
                        'check if the IP is a range or a full IP, if its a full ip then it must be matched exactly
                        If Split(arrBackendIPs(x), ".").Count = 4 Then blnFullIP = True Else blnFullIP = False
                        If IIf(blnFullIP, arrBackendIPs(x) = strClientIP, Left(strClientIP, arrBackendIPs(x).Length) = arrBackendIPs(x)) Then
                            'ok, let 'em in
                            blnAllowIP = True
                            Exit For
                        End If
                    Next
                    If Not blnAllowIP Then
                        Response.Write("You are not authorized to view this page")
                        Response.End()
                    End If
                Catch ex As Exception
                    Response.Write("Invalid IP Lock Config")
                    Response.End()
                End Try
            End If

            'Check cookie security
            Dim cokKartris As HttpCookie = Request.Cookies(HttpSecureCookie.GetCookieName("BackAuth"))
            Dim arrAuth As String() = Nothing
            Session("Back_Auth") = ""
            If cokKartris IsNot Nothing Then
                arrAuth = HttpSecureCookie.Decrypt(cokKartris.Value)
                If arrAuth IsNot Nothing Then
                    If UBound(arrAuth) = 8 Then
                        If Not String.IsNullOrEmpty(arrAuth(0)) And strClientIP = arrAuth(7) And LoginsBLL.Validate(arrAuth(0), arrAuth(6), True) Then
                            Session("Back_Auth") = cokKartris.Value
                            Session("_LANG") = arrAuth(4)
                            Session("_USER") = arrAuth(0)
                            Session("_UserID") = LoginsBLL._GetIDbyName(arrAuth(0))
                        Else
                            Session("Back_Auth") = ""
                            cokKartris = New HttpCookie(HttpSecureCookie.GetCookieName("BackAuth"))
                            cokKartris.Expires = CkartrisDisplayFunctions.NowOffset.AddDays(-1D)
                            Response.Cookies.Add(cokKartris)
                        End If
                    End If
                End If
            End If

            Response.Cache.SetCacheability(HttpCacheability.NoCache)

            Dim strScriptURL As String = Request.RawUrl.Substring(Request.Path.LastIndexOf("/") + 1)

            If String.IsNullOrEmpty(Session("Back_Auth")) Then
                If LCase(Left(strScriptURL, 11)) <> "default.aspx" Then Response.Redirect("~/Admin/Default.aspx?page=" & strScriptURL)
            Else
                Dim strScriptName As String = Request.Path.Substring(Request.Path.LastIndexOf("/") + 1)
                Dim nodeCurrent As SiteMapNode = SiteMap.Providers("_KartrisSiteMap").FindSiteMapNodeFromKey("~/Admin/" & strScriptName)
                If Not nodeCurrent Is Nothing Then
                    Dim strNodeValue As String = nodeCurrent.Item("Value")
                    If UBound(arrAuth) = 8 Then

                        'If user doesn't have product permissions then hide category menu and set splitterbar width to 0
                        If Not CBool(arrAuth(2)) Then
                            Page.Master.FindControl("_UC_CategoryMenu").Visible = False
                            Page.Master.FindControl("litHiddenCatMenu").Visible = True
                            Page.Master.FindControl("lnkNewCat").Visible = False
                            Page.Master.FindControl("lnkNewProd").Visible = False
                            DirectCast(Page.Master.FindControl("splMainPage"), VwdCms.SplitterBar).Width = 40

                        End If

                        Select Case strNodeValue
                            Case "orders"
                                Dim blnOrders As Boolean = CBool(arrAuth(3))
                                'Session("Back_Orders")
                                If Not blnOrders Then
                                    Response.Write("You are not authorized to view this page")
                                    Response.End()
                                End If
                            Case "products"
                                Dim blnProducts As Boolean = CBool(arrAuth(2))
                                'Session("Back_Products")
                                If Not blnProducts Then
                                    Response.Write("You are not authorized to view this page")
                                    Response.End()
                                End If
                            Case "config"
                                Dim blnConfig As Boolean = CBool(arrAuth(1))
                                'Session("Back_Config")
                                If Not blnConfig Then
                                    Response.Write("You are not authorized to view this page")
                                    Response.End()
                                End If
                            Case "support"
                                Dim blnSupport As Boolean = CBool(arrAuth(8))
                                'Session("Back_Support")
                                If Not blnSupport Then
                                    Response.Write("You are not authorized to view this page")
                                    Response.End()
                                End If
                        End Select
                    Else
                        Response.Write("Invalid Cookie")
                        Response.End()
                    End If

                Else
                    Response.Write("Unknown Backend Page. This needs to be added to the Admin/_web.sitemap. If you don't want to show the link to the navigation menu. set its 'visible' tag to 'false' in the sitemap entry. <br/> e.g." & Server.HtmlEncode("<siteMapNode title=""default"" url=""~/Admin/_Default.aspx"" visible=""false"" />"))
                    Response.End()
                End If
            End If
        End If
    End Sub

    'This creates the 'powered by kartris' tag in bottom right.
    Protected Sub RunGlobalReplacements(ByVal sbdPageSource As StringBuilder)

        'Any license.config file in the root will disable this,
        'but the license must be valid or it's a violation of 
        'the GPL v2 terms
        If Not KartSettingsManager.HasCommercialLicense Then

            Dim blnReplacedTag As Boolean = False
            Dim strLinkText = KartSettingsManager.PoweredByLink

            'Try to replace closing body tag with this
            Try
                sbdPageSource.Replace("</body", strLinkText & vbCrLf & "</body")
                blnReplacedTag = True
            Catch ex As Exception
                'Oh dear
            End Try

            'If they have somehow managed to remove or
            'obscure the closing body and form tags, we
            'just tag our code to the end of the page.
            'It is not XHTML compliant, but it should 
            'ensure the tag shows in any case.
            If blnReplacedTag = False Then
                Try
                    sbdPageSource.Append(vbCrLf & strLinkText)
                    blnReplacedTag = True
                Catch ex As Exception
                    'Oh dear
                End Try
            End If
        End If
    End Sub

    Private Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        SSLHandler.CheckBackSSL()
    End Sub

End Class
