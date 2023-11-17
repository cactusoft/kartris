'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

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
        Response.Clear()
        Response.Status = "404 Not Found"
        Response.TrySkipIisCustomErrors = True

        'Try to read the template file and return that
        Try
            Dim srd404 As StreamReader = New StreamReader(Server.MapPath("~/404Template.html"))
            Dim strText As String

            'Read and display the lines from the file until the end
            'of the file is reached.
            Do
                strText = srd404.ReadLine()
                Response.Write(strText)
            Loop Until strText Is Nothing
            srd404.Close()
        Catch ex As Exception
            'Ok, we just fall back if there is an error reading the template
            'to the really naff old 404
            Response.Write("<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbCrLf)
            Response.Write("<html xmlns=""http://www.w3.org/1999/xhtml"" style=""border: none;"">" & vbCrLf)
            Response.Write("<head id=""Head1"">" & vbCrLf)
            Response.Write("<style type=""text/css"">" & vbCrLf)
            Response.Write("/* we avoid external CSS files because if we're not careful" & vbCrLf)
            Response.Write("those can also create 404s and so you get a cascade of" & vbCrLf)
            Response.Write("404s when running in integrated app pool mode */" & vbCrLf)
            Response.Write("body { font-family: ""Segoe UI"", Verdana, Arial, Helvetica; font-size: 13px; background-color: #fff; }" & vbCrLf)
            Response.Write("div { position: absolute; top: 50%; left: 50%; width: 400px; height: 300px; margin-top: -200px; margin-left: -200px; }" & vbCrLf)
            Response.Write("h1 { font-family: Georgia, Times New Roman, Times New Roman; font-weight: lighter; font-size: 690%; letter-spacing: -2px; color: #c05; padding: 0; margin: 0; }" & vbCrLf)
            Response.Write("h2 { font-family: ""Segoe UI"", Verdana, Arial, Helvetica; font-size: 250%; color: #ccc; text-transform: uppercase; padding: 0; margin: 0; }" & vbCrLf)
            Response.Write("a { color: #04d; }" & vbCrLf)
            Response.Write("</style>" & vbCrLf)
            Response.Write("    <title>404 - Page Not Found</title>" & vbCrLf)
            Response.Write("</head>" & vbCrLf)
            Response.Write("<body>" & vbCrLf)
            Response.Write("    <div>" & vbCrLf)
            Response.Write("        <h1>404!</h1>" & vbCrLf)
            Response.Write("        <h2>Page Not Found</h2>" & vbCrLf)
            Response.Write("        <p>The page you're looking for isn't here.</p>" & vbCrLf)
            Response.Write("        <p><a href=""/Default.aspx"">Go to the home page...</a></p>" & vbCrLf)
            Response.Write("    </div>" & vbCrLf)
            Response.Write("</body>" & vbCrLf)
            Response.Write("</html>" & vbCrLf)
        End Try

        'Flush and end
        Response.Flush()
        Response.End()
    End Sub

End Class
