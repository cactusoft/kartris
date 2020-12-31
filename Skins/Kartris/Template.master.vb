'========================================================================
'KARTRIS by cactusoft
'Copyright 2021 CACTUSOFT - www.kartris.com
'This skin is licensed under a
'Creative Commons Attribution-ShareAlike 3.0 Unported License

'http://creativecommons.org/licenses/by-sa/3.0/deed.en_GB
'========================================================================
Imports System.Xml
Imports System.Web.Security

Partial Public Class Skin_Kartris_Template

    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        baseTag.Attributes("href") = CkartrisBLL.WebShopURL()
        lnkFavIcon1.Href = CkartrisBLL.WebShopURL() & "favicon.ico"
        If Not Page.IsPostBack Then UC_AdminBar.Visible = HttpSecureCookie.IsBackendAuthenticated
        If Application("subsiteId") > 0 Then
            UC_AdminBar.Visible = True
        End If
    End Sub

    ''' <summary>
    ''' Return name of script
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>We embed a css class with the name of the script,
    ''' this lets us make page specific changes such as for the home page
    ''' if we want full width, without needing server side diddling. We
    ''' can have custom CSS for particular pages like Default.</remarks>
    Public Shared Function PageName(ByVal strRawScriptName As String) As String
        Dim strPageName As String = ""
        Try
            strPageName = Replace(strRawScriptName.ToLower, ".aspx", "")
            strPageName = Replace(strPageName, "/", "")
        Catch ex As Exception
            'Guess it stays blank
        End Try
        Return strPageName
    End Function

End Class
