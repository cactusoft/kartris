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

    Public Shared Function CreateHash(ByVal drwLogin As DataRow, ByVal strUserName As String, ByVal strPassword As String, ByVal strClientIP As String) As String
        Dim strUserData As String = strUserName & "##" & drwLogin("LOGIN_Config").ToString & "##" & _
                            drwLogin("LOGIN_Products").ToString & "##" & drwLogin("LOGIN_Orders").ToString & "##" & _
                            drwLogin("LOGIN_LanguageID").ToString & "##" & NowOffset() & "##" & _
                            UsersBLL.EncryptSHA256Managed(strPassword, LoginsBLL._GetSaltByUserName(strUserName), True) & "##" & strClientIP & "##" & drwLogin("LOGIN_Tickets").ToString
        Dim objTicket As New FormsAuthenticationTicket(1, strUserName, NowOffset, NowOffset.AddDays(1), True, strUserData, FormsAuthentication.FormsCookiePath)
        Return FormsAuthentication.Encrypt(objTicket)
    End Function

    Public Shared Function Decrypt(Optional ByVal strCookieValue As String = "") As String()
        Dim arrAuth As String() = Nothing
        Dim strValue As String
        If Not String.IsNullOrEmpty(strCookieValue) Then
            strValue = strCookieValue
        Else
            Dim cokKartris As HttpCookie = Current.Request.Cookies(GetKartConfig("general.webshopurl"))
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

    Public Shared Sub ForceLogout(Optional ByVal blnRedirect As Boolean = True)
        Dim cokKartris As HttpCookie
        cokKartris = New HttpCookie(KartSettingsManager.GetKartConfig("general.webshopurl"), "")
        cokKartris.Expires = NowOffset()
        Current.Response.Cookies.Add(cokKartris)
        Current.Session("Back_Auth") = ""
        Current.Session("_LANG") = LanguagesBLL.GetDefaultLanguageID()
        If blnRedirect Then Current.Response.Redirect("~/Admin/")
    End Sub

End Class

''' <summary>
''' Is SSL required?
''' Checks config setting
''' </summary>
Public NotInheritable Class SSLHandler
    Public Shared Function IsSSLEnabled() As Boolean
        Dim blnIsSSLEnabled As Boolean = False

        'SSL enabled in config settings
        If GetKartConfig("general.security.ssl") = "y" Then blnIsSSLEnabled = True

        Return blnIsSSLEnabled
    End Function

    ''' <summary>
    ''' Force SSL on back end if available
    ''' </summary>
    Public Shared Sub CheckBackSSL()
        If IsSSLEnabled() Then
            If Not Current.Request.IsSecureConnection() Then
                If Not String.IsNullOrEmpty(Current.Session("Back_Auth")) Then
                    Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("http://", "https://"))
                ElseIf Current.Request.Url.AbsoluteUri.Contains("https://") Then
                    Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("https://", "http://"))
                End If
            ElseIf Current.Request.Url.AbsoluteUri.Contains("https://") AndAlso _
                    String.IsNullOrEmpty(Current.Session("Back_Auth")) Then
                Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("https://", "http://"))
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
            If Not Current.Request.IsSecureConnection() Then
                If (IsBackEndLoggedIn() Or blnAuthenticatedUser) Then
                    Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("http://", "https://"))
                ElseIf Current.Request.Url.AbsoluteUri.Contains("https://") Then
                    Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("https://", "http://"))
                End If
            ElseIf Current.Request.Url.AbsoluteUri.Contains("https://") AndAlso _
                    (Not IsBackEndLoggedIn()) AndAlso _
                    (Not blnAuthenticatedUser) AndAlso _
                    ((Not Current.Request.Url.AbsoluteUri.ToLower.Contains("customeraccount.aspx")) And _
                     (Not Current.Request.Url.AbsoluteUri.ToLower.Contains("checkout.aspx")) And _
                     (Not Current.Request.Url.AbsoluteUri.ToLower.Contains("customertickets.aspx"))) Then
                Current.Response.Redirect(Current.Request.Url.AbsoluteUri.Replace("https://", "http://"))
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