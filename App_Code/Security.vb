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
Imports System.Web.Security
Imports System.Reflection
Imports System.Text
Imports System.Globalization
Imports System.Web.HttpContext
Imports KartSettingsManager
Imports System.Threading
Imports Microsoft.VisualBasic
Imports System.Xml
Imports System
Imports CkartrisFormatErrors
Imports CkartrisDisplayFunctions

<Assembly: Obfuscation(Feature:="code control flow obfuscation", Exclude:=False)> 


''' <summary> 
''' Provides cookie cyphering services. 
''' </summary> 
Public NotInheritable Class HttpSecureCookie
    Private Sub New()
    End Sub

    ''' <summary>
    ''' Creates a SHA256 hash
    ''' </summary>
    Public Shared Function CreateHash(ByVal drwLogin As DataRow, ByVal strUserName As String, ByVal strPassword As String, ByVal strClientIP As String) As String
        Dim strUserData As String = strUserName & "##" & drwLogin("LOGIN_Config").ToString & "##" & _
                            drwLogin("LOGIN_Products").ToString & "##" & drwLogin("LOGIN_Orders").ToString & "##" & _
                            drwLogin("LOGIN_LanguageID").ToString & "##" & NowOffset() & "##" & _
                            UsersBLL.EncryptSHA256Managed(strPassword, LoginsBLL._GetSaltByUserName(strUserName), True) & "##" & strClientIP & "##" & drwLogin("LOGIN_Tickets").ToString
        Dim objTicket As New FormsAuthenticationTicket(1, strUserName, NowOffset, NowOffset.AddDays(1), True, strUserData, FormsAuthentication.FormsCookiePath)
        Return FormsAuthentication.Encrypt(objTicket)
    End Function

    ''' <summary>
    ''' Decrypts cookie
    ''' </summary>
    Public Shared Function Decrypt(Optional ByVal strCookieValue As String = "") As String()
        Dim arrAuth As String() = Nothing
        Dim strValue As String
        If Not String.IsNullOrEmpty(strCookieValue) Then
            strValue = strCookieValue
        Else
            Dim cokKartris As HttpCookie = Current.Request.Cookies(GetCookieName("BackAuth"))
            If cokKartris IsNot Nothing Then
                strValue = cokKartris.Value
            Else
                Return Nothing
            End If
        End If
        If Not String.IsNullOrEmpty(strValue) Then
            Try
                Dim returnValue As FormsAuthenticationTicket = FormsAuthentication.Decrypt(strValue)
                arrAuth = Split(returnValue.UserData, "##")
                Return arrAuth
            Catch ex As Exception
                'Invalid Cookie Data
                ForceLogout(False)
                'arrAuth.SetValue("", 0)
            End Try
        End If
        Return Nothing
    End Function

    ''' <summary>
    ''' Decrypts cookie value
    ''' </summary>
    Public Shared Function DecryptValue(ByVal strValue As String, ByVal strScript As String) As String()
        Dim arrAuth As String() = Nothing
        If Not String.IsNullOrEmpty(strValue) Then
            Try
                Dim returnValue As FormsAuthenticationTicket = FormsAuthentication.Decrypt(strValue)
                arrAuth = Split(returnValue.UserData, "##")
                Return arrAuth
            Catch ex As Exception
                'Invalid Cookie Data
                LogError("Cannot Decrypt in " & strScript)
                arrAuth.SetValue("", 0)
            End Try
        End If
        Return arrAuth
    End Function

    ''' <summary>
    ''' Check if user is authenticated for back end (admin) access
    ''' </summary>
    Public Shared Function IsBackendAuthenticated() As Boolean
        Dim arrAuth As String() = Nothing
        arrAuth = Decrypt()
        If arrAuth IsNot Nothing Then
            If UBound(arrAuth) = 8 Then
                Dim strClientIP As String = Current.Request.ServerVariables("HTTP_X_FORWARDED_FOR")
                If String.IsNullOrEmpty(strClientIP) Then strClientIP = Current.Request.ServerVariables("REMOTE_ADDR")
                If Not String.IsNullOrEmpty(arrAuth(0)) And strClientIP = arrAuth(7) Then Return True
            End If
        End If
        Return False
    End Function

    ''' <summary>
    ''' Log the user out
    ''' </summary>
    Public Shared Sub ForceLogout(Optional ByVal blnRedirect As Boolean = True)
        Dim cokKartris As HttpCookie
        cokKartris = New HttpCookie(HttpSecureCookie.GetCookieName("BackAuth"), "")
        cokKartris.Expires = NowOffset()
        Current.Response.Cookies.Add(cokKartris)
        Current.Session("Back_Auth") = ""
        Current.Session("_LANG") = LanguagesBLL.GetDefaultLanguageID()
        If blnRedirect Then Current.Response.Redirect("~/Admin/")
    End Sub

    ''' <summary>
    ''' Find out the name of the cookie used
    ''' </summary>
    Public Shared Function GetCookieName(Optional strPostfix As String = "") As String
        Return Trim(GetKartConfig("general.sessions.cookiename")) & strPostfix & Left(ConfigurationManager.AppSettings("HashSalt"), 5)
    End Function
End Class

''' <summary>
''' Is SSL required?
''' Checks config setting
''' </summary>
Public NotInheritable Class SSLHandler
    Public Shared Function IsSSLEnabled() As Boolean
        Dim blnIsSSLEnabled As Boolean = False

        'SSL enabled in config settings
        If GetKartConfig("general.security.ssl") = "y" Or GetKartConfig("general.security.ssl") = "a" Then blnIsSSLEnabled = True

        Return blnIsSSLEnabled
    End Function

    ''' <summary>
    ''' Force SSL on back end if available
    ''' </summary>
    Public Shared Sub CheckBackSSL()
        If IsSSLEnabled() Then
            'Start with assumption no SSL required
            Dim blnNeedSSL As Boolean = False

            'If admin logged in, then we set the requirement
            'for SSL to 'true'
            If IsBackEndLoggedIn() Then blnNeedSSL = True

            'We need SSL, but current page doesn't have it
            If blnNeedSSL = True And Not Current.Request.IsSecureConnection() Then
                Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("http://", "https://"))
            End If
        ElseIf Current.Request.Url.AbsoluteUri.Contains("https://") Then
            Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("https://", "http://"))
        End If
    End Sub

    ''' <summary>
    ''' Force SSL on front end if available
    ''' </summary>
    Public Shared Sub CheckFrontSSL(ByVal blnAuthenticatedUser As Boolean)
        If IsSSLEnabled() Then
            'Start with assumption no SSL required
            Dim blnNeedSSL As Boolean = False

            'If admin logged in, front end user logged in,
            'or we're on a login page, then we set the requirement
            'for SSL to 'true'
            If IsBackEndLoggedIn() Then blnNeedSSL = True
            If blnAuthenticatedUser Then blnNeedSSL = True
            If Current.Request.Url.AbsoluteUri.ToLower.Contains("customeraccount.aspx") Then blnNeedSSL = True
            If Current.Request.Url.AbsoluteUri.ToLower.Contains("checkout.aspx") Then blnNeedSSL = True
            If Current.Request.Url.AbsoluteUri.ToLower.Contains("customertickets.aspx") Then blnNeedSSL = True

            'This handles SSL always on
            If GetKartConfig("general.security.ssl") = "a" Then blnNeedSSL = True

            'Added v2.6000 - don't redirect on callback.aspx
            'We get problems in some payment systems, because we cannot necessarily
            'control consistently for all whether SSL is used or not. Therefore, we
            'should accept calls to the callback with either http or https, and avoid
            'redirection.
            If Not Current.Request.Url.AbsoluteUri.ToLower.Contains("callback") Then
                'We need SSL, but current page doesn't have it
                If blnNeedSSL = True And Not Current.Request.IsSecureConnection() Then
                    Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("http://", "https://"))
                    'We have SSL but don't need it
                ElseIf blnNeedSSL = False And Current.Request.IsSecureConnection() Then
                    Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("https://", "http://"))
                End If
            End If

        ElseIf Current.Request.Url.AbsoluteUri.Contains("https://") Then
            Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("https://", "http://"))
        End If
    End Sub

    ''' <summary>
    ''' Force SSL redirect
    ''' </summary>
    Public Shared Sub RedirectToSecuredPage()
        If IsSSLEnabled() Then
            Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("http://", "https://"))
        End If
    End Sub

    ''' <summary>
    ''' Not sure what this is for, can anyone update this comment?
    ''' </summary>
    Public Shared Function IsSecuredForSEO() As Boolean
        If IsSSLEnabled() Then
            Try
                If ((Not String.IsNullOrEmpty(Current.Session("Back_Auth"))) Or HttpContext.Current.User.Identity.IsAuthenticated) Then
                    Return True
                End If
            Catch ex As Exception
                If Current.User.Identity.IsAuthenticated Then Return True
            End Try
            'If Current.Session IsNot Nothing Then
        End If
        Return False
    End Function

    ''' <summary>
    ''' Checks if back end (admin) user is logged in
    ''' </summary>
    Public Shared Function IsBackEndLoggedIn() As Boolean
        Return Not String.IsNullOrEmpty(Current.Session("Back_Auth"))
    End Function

End Class