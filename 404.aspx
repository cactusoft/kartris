<%@ Page Language="VB" AutoEventWireup="false" CodeFile="404.aspx.vb" Inherits="_404" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" style="border: none;">
<head id="Head1" runat="server">
<style type="text/css">
/* we avoid external CSS files because if we're not careful
those can also create 404s and so you get a cascade of
404s when running in integrated app pool mode */

body { font-family: "Segoe UI", Verdana, Arial, Helvetica; font-size: 13px; background-color: #fff; }
div { position: absolute; top: 50%; left: 50%; width: 400px; height: 300px; margin-top: -200px; margin-left: -200px; }
h1 { font-family: Georgia, Times New Roman, Times New Roman; font-weight: lighter; font-size: 690%; letter-spacing: -2px; color: #c05; padding: 0; margin: 0; }
h2 { font-family: "Segoe UI", Verdana, Arial, Helvetica; font-size: 250%; color: #ccc; text-transform: uppercase; padding: 0; margin: 0; }
a { color: #04d; }
</style>
    <title>404 - Page Not Found</title>
</head>
<body>
    <div>
        <h1>404!</h1>
        <h2>Page Not Found</h2>
        <p>The page you're looking for isn't here.</p>
        <p><asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/Default.aspx">Go to the home page...</asp:HyperLink></p>
    </div>
</body>
</html>
