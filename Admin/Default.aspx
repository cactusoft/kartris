<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="Admin_Default" %>

<%@ Register TagPrefix="_user" TagName="NoMasterCSS" Src="~/UserControls/Back/_NoMasterCSS.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="loginhead" runat="server">
    <_user:NoMasterCSS ID="_UC_NoMasterCSS" runat="server" />
    <base id="baseTag" runat="server" />
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <!--
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
        -->
    <title>Kartris</title>
    <link rel="icon" href="/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:300' rel='stylesheet' type='text/css'>
</head>
<body id="page_login">
    <div id="centrecontainer">
        <form id="frmLogin" runat="server">
        <div id="loginbox">
            <asp:MultiView ID="mvwMain" runat="server" ActiveViewIndex="0">
                <asp:View ID="viwLogin" runat="server">
                    <h1>
                        <asp:Literal ID="litWelcomeText" runat="server" Text="<%$ Resources: _Kartris, PageTitle_WelcomeToKartris %>"></asp:Literal></h1>

                    <!-- Below is a conditional comment to show a warning if someone
                    tries to login to the back end using IE7 or earlier. Things will
                    look a mess, and some features may not work. But we won't actually
                    block logging in - it might this is the only browser available
                    in an emergency. -->

                        <!--[if lte IE 7]>
                        <div style="color: #fff;background-color: #f55;padding: 5px;"><strong style="color: #fff;">Warning!</strong>
                        You're using a very old browser. Parts of the Kartris back end will display incorrectly and other
                        features may not work at all. Please update your browser, or install a new one for the best
                        experience. Latest versions of <a href="http://windows.microsoft.com/en-US/internet-explorer/download-ie">IE</a>,
                        <a href="http://www.mozilla.org/en-US/firefox/new/">Firefox</a>,
                        <a href="http://www.google.com/chrome">Google Chrome</a>,
                        <a href="http://www.apple.com/safari/">Safari</a>
                        and
                        <a href="http://www.opera.com/download/">Opera</a> should all work ok.
                        </div>
                        <![endif]-->
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label runat="server" ID="lblUserName" Text="<%$ Resources: _Kartris, FormLabel_Username %>"
                                        AssociatedControlID="txtUserName" /></span><span class="Kartris-DetailsView-Value"><asp:TextBox
                                            ID="txtUserName" runat="server" CssClass="midtext"></asp:TextBox></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label runat="server" ID="lblPass" Text="<%$ Resources: _Kartris, FormLabel_Password %>"
                                        AssociatedControlID="txtPass" /></span><span class="Kartris-DetailsView-Value"><asp:TextBox
                                            ID="txtPass" runat="server" TextMode="Password" CssClass="midtext"></asp:TextBox></span></li>
                                <li>
                                    <asp:Button ID="btnLogin" runat="server" Text="<%$ Resources: _Kartris, FormButton_Submit %>"
                                        CssClass="button" /></li>
                            </ul>
                        </div>
                    </div>
                    <div class="spacer">
                    </div>
                    <asp:Panel ID="divError" runat="server" CssClass="errormessage">
                        <asp:Literal ID="litError" Text="<%$ Resources: ContentText_LoginBadUser %>" runat="server" />
                    </asp:Panel>
                    <div class="spacer">
                    </div>
                    <asp:HyperLink ID="lnkFrontOfSite" runat="server" NavigateUrl="~/Default.aspx" Text="<%$ Resources:_Kartris, ContentText_FrontOfSite %>"
                        CssClass="gotofront" />
                </asp:View>
            </asp:MultiView>
        </div>
        </form>
    </div>
</body>
</html>
