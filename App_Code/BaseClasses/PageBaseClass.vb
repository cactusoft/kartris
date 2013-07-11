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
Imports System.Threading
Imports System.Globalization
Imports System.Web.Configuration
Imports System.Web.HttpContext
Imports CkartrisFormatErrors
Imports KartSettingsManager
Imports System.Web.UI
Imports System.Text
Imports System.Web.UI.HtmlControls

Public MustInherit Class PageBaseClass
    Inherits System.Web.UI.Page

    Private _MetaKeywords As String
    Private _MetaDescription As String
    Private _CanonicalTag As String
    Private _CurrentLoggedUser As KartrisMemberShipUser

    Protected NotOverridable Overrides Sub Render(ByVal writer As HtmlTextWriter)

        'Create our own mechanism to store the page output
        'This way we can alter the text of the page prior to
        'rendering.
        'If Not Page.IsPostBack Then
        Dim sbdPageSource As StringBuilder = New StringBuilder()
        Dim objStringWriter As StringWriter = New StringWriter(sbdPageSource)
        Dim objHtmlWriter As HtmlTextWriter = New HtmlTextWriter(objStringWriter)
        MyBase.Render(objHtmlWriter)

        'Insert Google Analytics, if necessary
        If KartSettingsManager.GetKartConfig("general.googleanalytics.webpropertyid") <> "" Then
            InsertGoogleAnalyticsCode(sbdPageSource, KartSettingsManager.GetKartConfig("general.googleanalytics.webpropertyid"))
        End If

        'Add copyright notice - NOTE, this should not be
        'removed, under the GPL this conforms to the definition
        'of a copyright notification message
        RunGlobalReplacements(sbdPageSource)

        'Output replacements
        writer.Write(sbdPageSource.ToString())
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

    'This creates the Google Analytics javascript code
    'at the foot of front end pages if there is a value
    'in the general.googleanalytics.webpropertyid config
    'setting.
    Protected Sub InsertGoogleAnalyticsCode(ByVal sbdPageSource As StringBuilder, ByVal strGoogleWebPropertyID As String)
        Dim blnReplacedTag As Boolean = False
        Dim strReplacement As String = ""
        Dim sbdLink As New StringBuilder

        'Newer Google Analytics code
        sbdLink.Append("<script type=""text/javascript"">" & vbCrLf)
        sbdLink.Append("var _gaq = _gaq || [];" & vbCrLf)
        sbdLink.Append("_gaq.push(['_setAccount', '" & strGoogleWebPropertyID & "']);" & vbCrLf)
        sbdLink.Append("_gaq.push(['_trackPageview']);" & vbCrLf)
        sbdLink.Append("(function() {" & vbCrLf)
        sbdLink.Append("var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;" & vbCrLf)
        sbdLink.Append("ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';" & vbCrLf)
        sbdLink.Append("var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);" & vbCrLf)
        sbdLink.Append("})();" & vbCrLf)
        sbdLink.Append("</script>" & vbCrLf)

        'Newer Google Analytics works in head tag, not close body
        Try
            sbdPageSource.Replace("</head", sbdLink.ToString & vbCrLf & "</head")
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
                sbdPageSource.Append(vbCrLf & sbdLink.ToString)
                blnReplacedTag = True
            Catch ex As Exception
                'Oh dear
            End Try
        End If
    End Sub

    Public Property CanonicalTag() As String
        Get
            Return _CanonicalTag
        End Get
        Set(ByVal value As String)
            _CanonicalTag = value
        End Set
    End Property

    Public Overloads Property MetaKeywords() As String
        Get
            Return _MetaKeywords
        End Get
        Set(ByVal value As String)
            _MetaKeywords = value
        End Set
    End Property

    Public Overloads Property MetaDescription() As String
        Get
            Return _MetaDescription
        End Get
        Set(ByVal value As String)
            _MetaDescription = value
        End Set
    End Property

    Public Property CurrentLoggedUser() As KartrisMemberShipUser
        Get
            Return _CurrentLoggedUser
        End Get
        Set(ByVal value As KartrisMemberShipUser)
            _CurrentLoggedUser = value
        End Set
    End Property

    Protected Overrides Sub InitializeCulture()

        If Not Page.IsPostBack Then
            Dim CatSiteMap As CategorySiteMapProvider = DirectCast(SiteMap.Provider, CategorySiteMapProvider)
            CatSiteMap.ResetSiteMap()

            If Not String.IsNullOrEmpty(Request.QueryString("L")) Then
                Session("KartrisUserCulture") = Server.HtmlEncode(LanguagesBLL.GetCultureByLanguageID_s(Request.QueryString("L")))
                Session("LANG") = CShort(Request.QueryString("L"))
                Response.Cookies(HttpSecureCookie.GetCookieName())("KartrisUserCulture") = Session("KartrisUserCulture")
            Else
                Try
                    'no language querystring passed so get the value from the cookie, set the session-object with the data from the cookie.
                    Session("KartrisUserCulture") = Server.HtmlEncode(Request.Cookies(HttpSecureCookie.GetCookieName())("KartrisUserCulture"))
                    Session("LANG") = CShort(LanguagesBLL.GetLanguageIDByCulture_s(Request.Cookies(HttpSecureCookie.GetCookieName())("KartrisUserCulture")))
                Catch ex As Exception
                    CreateKartrisCookie()
                    'no language querystring passed so get the value from the cookie, set the session-object with the data from the cookie.
                    Session("KartrisUserCulture") = Server.HtmlEncode(Request.Cookies(HttpSecureCookie.GetCookieName())("KartrisUserCulture"))
                    Session("LANG") = CShort(LanguagesBLL.GetLanguageIDByCulture_s(Request.Cookies(HttpSecureCookie.GetCookieName())("KartrisUserCulture")))
                End Try
            End If

            'Set the UICulture and the Culture with a value stored in a Session-object.
            If User.Identity.IsAuthenticated Then
                Try
                    If IsNothing(_CurrentLoggedUser) Then _CurrentLoggedUser = Web.Security.Membership.GetUser()
                    If _CurrentLoggedUser Is Nothing Then Throw New Exception("Invalid User!")
                Catch ex As Exception
                    _CurrentLoggedUser = Nothing
                    Web.Security.FormsAuthentication.SignOut()
                    Response.Redirect("~/CustomerAccount.aspx")
                End Try

            Else
                _CurrentLoggedUser = Nothing
            End If
            Try
                Thread.CurrentThread.CurrentUICulture = New CultureInfo(Session("KartrisUserCulture").ToString)
                Thread.CurrentThread.CurrentCulture = New CultureInfo(Session("KartrisUserCulture").ToString)
            Catch ex As Exception
                Session("KartrisUserCulture") = LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID())
                Thread.CurrentThread.CurrentUICulture = New CultureInfo(Session("KartrisUserCulture").ToString)
                Thread.CurrentThread.CurrentCulture = New CultureInfo(Session("KartrisUserCulture").ToString)
            End Try
            MyBase.InitializeCulture()
        End If


    End Sub

    Private Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Error
        If UCase(Server.GetLastError.ToString).Contains("SYSTEM.WEB.HTTPREQUESTVALIDATIONEXCEPTION") Then
            Server.ClearError()
            Dim strURL As String = Request.Url.ToString
            Session("Error") = "invalidrequest"
            Response.Redirect(strURL)
        Else
            LogError()
        End If
    End Sub

    ''' <summary>
    ''' Skin selection from skin.config
    ''' </summary>
    Protected NotOverridable Overrides Sub OnPreInit(ByVal e As EventArgs)

        '==================================================
        'SKIN HANDLING (start)
        '==================================================
        Dim strSkinOverride As String = ""

        '--------------------------------------------------
        '1. Look for skin config rules

        'The skin.config file is cached by
        'LoadSkinConfigToCache in the kartris.vb file to
        '"tblSkinRules"... if this exists, then we look
        'to implement those rules here.
        '--------------------------------------------------
        If HttpRuntime.Cache("tblSkinRules") IsNot Nothing Then
            Dim strScriptName As String = Path.GetFileName(Request.PhysicalPath).ToLower
            Dim intProductID As Integer = 0, intCategoryID As Integer = 0, intCustomerID As Integer = 0, intCustomerGroupID As Integer = 0

            '--------------------------------------------------
            '1a. Look for product or category ID

            'Need this so can implement product or category
            'skin.
            '--------------------------------------------------
            Try
                Dim strCurrentPath As String = Request.RawUrl.ToString.ToLower
                If Not (InStr(strCurrentPath, "/skins/") > 0 Or InStr(strCurrentPath, "/javascript/") > 0 Or InStr(strCurrentPath, "/images/") > 0) Then
                    Select Case strScriptName
                        Case "product.aspx"
                            intProductID = Request.QueryString("ProductID")
                        Case "category.aspx"
                            intCategoryID = Request.QueryString("CategoryID")
                    End Select
                End If
            Catch ex As Exception

            End Try

            '--------------------------------------------------
            '1b. Look for user ID

            'Need this so can implement customer-specific
            'skin.
            '--------------------------------------------------
            If User.Identity.IsAuthenticated Then
                Try
                    intCustomerID = CurrentLoggedUser.ID
                    intCustomerGroupID = CurrentLoggedUser.CustomerGroupID
                Catch ex As Exception

                End Try
            End If

            '--------------------------------------------------
            '1c. Determine which skin to use

            'Use the SkinMasterConfig function in kartris.vb,
            'pass in the product ID, category IDs, customer
            'ID, customer group ID and page/script name, and
            'then this looks up which skin to use.
            '--------------------------------------------------
            strSkinOverride = CkartrisBLL.SkinMasterConfig(Page, intProductID, intCategoryID, intCustomerID, intCustomerGroupID, strScriptName)
        End If

        '--------------------------------------------------
        '2. Check if skin specified for this language

        'This uses the SkinMaster function in kartris.vb.
        'We only run this if section (1) above did not
        'return any value.
        '--------------------------------------------------
        Dim strSkinMaster As String
        If strSkinOverride <> "" Then
            strSkinMaster = strSkinOverride
        Else
            strSkinMaster = CkartrisBLL.SkinMaster(Me, Session("LANG"))
        End If
        If strSkinMaster <> "" Then
            MasterPageFile = strSkinMaster
        End If

        '--------------------------------------------------
        '3a. Check if using HomePage master page

        'Often sites will want to use a different layout on
        'the home (default/index) page of the site. If we
        'are viewing the Default.aspx page, we check to see
        'if the skin includes a HomePage.master page. If
        'so, we use this. If not, just revert to the normal
        'Template.master instead.

        'Notice that we need to check for this HomePage
        'file in whichever skin is being used (which might
        'be the one specified in the Language, but could
        'be an overridden one, set in (1) or (2) above.
        '--------------------------------------------------
        If Path.GetFileName(Request.PhysicalPath).ToLower = "default.aspx" Then
            If Me.MasterPageFile <> "~/Skins/Kartris/Template.master" Then
                If strSkinOverride <> "" Then
                    'Look for HomePage template in the overridden skin
                    If File.Exists(Server.MapPath("~/Skins/" & strSkinOverride & "/HomePage.master")) Then
                        Me.MasterPageFile = "~/Skins/" & strSkinOverride & "/HomePage.master"
                    End If

                Else
                    'Look for HomePage template in the language-specified or default skin
                    If File.Exists(Server.MapPath("~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/HomePage.master")) Then
                        Me.MasterPageFile = "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/HomePage.master"
                    End If
                End If
            End If
        End If

        '--------------------------------------------------
        '3b. Is this a customer invoice page (front end)?

        'If so, we look in the present skin folder for an
        'Invoice.master. If there is one, we use it, if not,
        'we default back to the one in the Admin skin.
        '--------------------------------------------------
        If Path.GetFileName(Request.PhysicalPath).ToLower = "customerinvoice.aspx" Then
            If strSkinOverride <> "" Then
                If File.Exists(Server.MapPath("~/Skins/" & strSkinOverride & "/Invoice.master")) Then
                    Me.MasterPageFile = "~/Skins/" & strSkinOverride & "/Invoice.master"
                End If
            Else
                'If the skin has a HomePage.master file, we use this
                If File.Exists(Server.MapPath("~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Invoice.master")) Then
                    Me.MasterPageFile = "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Invoice.master"
                End If
            End If
        End If

        'Check if store is closed, and user is not
        'logged into back end - if so, redirect to
        'closed message
        If Not HttpSecureCookie.IsBackendAuthenticated() Then
            If GetKartConfig("general.storestatus") <> "open" Then Server.Transfer("~/Closed.aspx")
        End If

        '301 Redirect Code
        'This redirects to the official webshopURL domain, if another is used to access the site.
        If Not Current.Request.IsSecureConnection() Then
            If InStr(Request.Url.ToString.ToLower, CkartrisBLL.WebShopURL.ToLower) = 0 Then
                Dim strRedirectURL As String = CkartrisDisplayFunctions.CleanURL(Request.RawUrl.ToLower)
                'remove the web shop folder if present - webshopurl already contains this
                strRedirectURL = Replace(strRedirectURL, "/" & CkartrisBLL.WebShopFolder, "")
                If Left(strRedirectURL, 1) = "/" Then strRedirectURL = Mid(strRedirectURL, 2)
                Response.Status = "301 Moved Permanently"
                'append the webshop url
                Response.AddHeader("Location", CkartrisBLL.WebShopURL & strRedirectURL)
            End If
        End If

        'If the site requires users to login, redirect
        'to the login page if user is not logged in
        Dim strUserAccess As String = LCase(GetKartConfig("frontend.users.access"))
        If strUserAccess = "yes" And Not Request.Path.ToString.Contains("/CustomerAccount.aspx") And Not User.Identity.IsAuthenticated Then
            Response.Redirect("CustomerAccount.aspx")
        End If
        MyBase.OnPreInit(e)
    End Sub

    Private Sub Page_PreLoad(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreLoad

        If Not Page.IsPostBack Then
            'Get site name and set default page title to this. It
            'will be overridden on most pages.
            KartSettingsManager.GetKartConfig("")
            Page.Title = Server.HtmlEncode(GetGlobalResourceObject("Kartris", "Config_Webshopname"))

        End If

    End Sub

    Private Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        If Not Page.IsPostBack Then
            Dim tagHtmlMeta As New HtmlMeta
            Dim tagHtmlHead As HtmlHead = CType(Page.Header, HtmlHead)

            'Add the Meta Description and Keywords Tags
            tagHtmlMeta.Attributes.Add("name", "description")
            If Not String.IsNullOrEmpty(_MetaDescription) Then
                tagHtmlMeta.Attributes.Add("content", _MetaDescription)
            Else
                tagHtmlMeta.Attributes.Add("content", GetGlobalResourceObject("Kartris", "ContentText_DefaultMetaDescription"))
            End If
            tagHtmlHead.Controls.Add(tagHtmlMeta)

            tagHtmlMeta = New HtmlMeta
            tagHtmlMeta.Attributes.Add("name", "keywords")
            If Not String.IsNullOrEmpty(_MetaKeywords) Then
                tagHtmlMeta.Attributes.Add("content", _MetaKeywords)
            Else
                tagHtmlMeta.Attributes.Add("content", GetGlobalResourceObject("Kartris", "ContentText_DefaultMetaKeywords"))
            End If
            tagHtmlHead.Controls.Add(tagHtmlMeta)

            'Copyright
            Dim litLicenceNo As New WebControls.Literal
            litLicenceNo.Text = vbCrLf & vbCrLf & "<!-- Kartris - Copyright 2013 Cactusoft International FZ LLC - www.kartris.com -->"
            Page.Controls.Add(litLicenceNo)

            'Add the Canonical Tag if set
            If Not String.IsNullOrEmpty(_CanonicalTag) Then
                Dim tagCanonical As HtmlLink = New HtmlLink
                tagCanonical.Attributes.Add("rel", "canonical")
                tagCanonical.Href = _CanonicalTag
                tagHtmlHead.Controls.Add(tagCanonical)
            End If
        End If
    End Sub

    Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'Check if this is an affiliate link and we
            'need to log affiliate credit
            BasketBLL.CheckAffiliateLink()

            'Check if we are emptying the basket. Callbacks
            'from payment gateways often use this so when
            'a customer is returned, they don't still have
            'items in their basket.
            If Request.QueryString("strWipeBasket") = "yes" Then
                Dim BasketObject As BasketBLL = New BasketBLL
                BasketObject.DeleteBasket()
                Session("Basket") = Nothing
            End If

            If Session("Error") IsNot Nothing Then
                If Session("Error") = "invalidrequest" Then
                    Dim strBodyText As String = "alert('" & GetGlobalResourceObject("Kartris", "ContentText_HTMLNotAllowed") & "');"
                    ScriptManager.RegisterStartupScript(Me, Page.GetType, "AlertUser", strBodyText, True)
                    Session("Error") = Nothing
                End If
            End If

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

            'Add links to javascript such a KartrisInterface.js
            RegisterScripts()
        End If
    End Sub

    Private Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        'If Not String.IsNullOrEmpty(Current.Session("Back_Auth")) Then
        SSLHandler.CheckFrontSSL(Page.User.Identity.IsAuthenticated)
        'End If
    End Sub

    Private Sub RegisterScripts()
        'Extender.RegisterScripts()

        Dim folderPath As String = WebConfigurationManager.AppSettings.Get("Kartris-JavaScript-Path")
        If (String.IsNullOrEmpty(folderPath)) Then
            folderPath = "~/JavaScript"
        End If

        Dim filePath As String = IIf(folderPath.EndsWith("/"), folderPath & "KartrisInterface.js", folderPath & "/KartrisInterface.js")
        Page.ClientScript.RegisterClientScriptInclude(Me.GetType(), Me.GetType().ToString(), Page.ResolveUrl(filePath))
    End Sub
End Class
