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
Imports System.Xml
Imports System.Web.Security

Partial Public Class Skin_Kartris_Template

    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        baseTag.Attributes("href") = CkartrisBLL.WebShopURL()
        lnkFavIcon1.Href = CkartrisBLL.WebShopURL() & "favicon.ico"
        If Not Page.IsPostBack Then UC_AdminBar.Visible = HttpSecureCookie.IsBackendAuthenticated

        'Add zepto/jquery tag at end of page,
        'this is part of the responsive layout
        Dim strWebShopFolder As String = CkartrisBLL.WebShopFolder()
        litZeptoJquery.Text = "<script>" & vbCrLf & _
            "document.write('<script src=JavaScript/'" & vbCrLf & _
            "+ ('__proto__' in {} ? 'zepto' : 'jquery')" & vbCrLf & _
            "+ '.js><\/script>');" & vbCrLf & _
            "</script><script src=JavaScript/foundation.js></script>"
    End Sub

End Class
