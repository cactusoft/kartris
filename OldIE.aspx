<%@ Page Language="VB" AutoEventWireup="false" CodeFile="OldIE.aspx.vb" Inherits="_OldIE" %>
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
    <title>You're running an old version of Internet Explorer</title>
</head>
<body>
    <div>
        <h1>Sorry</h1>
        <h2>You're running a very old browser</h2>
        <p>This site supports IE9+, Firefox, Chrome, Safari, Opera - pretty much all browsers other than
            older versions of IE. If you cannot upgrade your version if IE, consider installing <a href="http://www.google.com/chromeframe">Chrome Frame</a>
        </p>
    </div>
</body>
</html>
