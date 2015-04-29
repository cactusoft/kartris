'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class _404
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim strThisPageURL As String = HttpContext.Current.Request.Url.AbsoluteUri
        Dim strNewPageURL As String = ""

        '---------------------------------------------------------------------
        'CACTUSHOP URL HANDLING
        'Kartris sites that have been upgraded from CactuShop will want
        'to map old format CactuShop URLs to the equivalent Kartris pages.
        'Fortunately, in most cases the Data Tool will preserve the same 
        'product and category IDs. Therefore if you set the web site to 
        'execute /404.aspx to handle 404s, this code below should be able
        'to convert the failed CactuShop URL to an appropriate Kartris one,
        'and then 301 redirect to it.

        'If your site is not upgraded from CactuShop, you could comment out
        'the whole IF block below, though it will have very little impact on
        'performance.

        'For mapping of custom pages, see the page.asp file in the root of the
        'web which handles this.
        '---------------------------------------------------------------------
        If strThisPageURL.Contains("/c-1-") Then 'Could be a category page
            strNewPageURL = strThisPageURL.ToLower.Replace("/c-1-", "__c-p-0-0-") 'replace format part of URL
            strNewPageURL = strNewPageURL & ".aspx" 'Add .aspx
            strNewPageURL = strNewPageURL.ToLower.Replace("/.aspx", ".aspx") 'Replace the /.aspx with just .aspx
            strNewPageURL = strNewPageURL.ToLower.Replace(CkartrisBLL.WebShopURL.ToLower & "404.aspx?404;", "") 'Just get the URL part that is in the querystring sent to the 404
            Response.RedirectPermanent(strNewPageURL) 'Redirect
        ElseIf strThisPageURL.Contains("/p-") Then 'Could be a product page
            strNewPageURL = strThisPageURL.ToLower.Replace("/p-", "__p-") 'replace format part of URL
            strNewPageURL = strNewPageURL & ".aspx" 'Add .aspx
            strNewPageURL = strNewPageURL.ToLower.Replace("/.aspx", ".aspx") 'Replace the /.aspx with just .aspx
            strNewPageURL = strNewPageURL.ToLower.Replace(CkartrisBLL.WebShopURL.ToLower & "404.aspx?404;", "") 'Just get the URL part that is in the querystring sent to the 404
            Response.RedirectPermanent(strNewPageURL) 'Redirect
        End If

        'Send a 404 code to browser
        Response.Status = "404 Not Found"
    End Sub

End Class
