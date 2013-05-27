<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="NavigationMenu.ascx.vb"
    Inherits="UserControls_Front_NavigationMenu" %>
<%@ OutputCache Duration="3600" VaryByParam="none" VaryByCustom="culture" Shared="true" %>
<%
    '------------------------------------
    'EDITING THESE LINKS
    'Edit the 'web_menu.sitemap' file
    'in the root of the web
    '------------------------------------
%>
<div id="menubar">
    <nav class="top-bar">
        <ul class="title-area show-for-medium-down" style="display: none;">
            <li class="name"><span><asp:Literal ID="litNavMenu" runat="server" Text="<%$ Resources: Kartris, ContentText_NavMenu %>" EnableViewState="False"></asp:Literal></span></li>
            <li class="toggle-topbar menu-icon"><a href=""><span></span></a></li>
        </ul>
        <section class="top-bar-section">
            <div class="dropdownmenu">
                <asp:SiteMapDataSource ID="MenuSitemap" SiteMapProvider="MenuSitemap" runat="server"
                    ShowStartingNode="false"></asp:SiteMapDataSource>
                <asp:Menu ID="menFrontEnd" runat="server" Orientation="Horizontal" DataSourceID="MenuSitemap">
                </asp:Menu>
            </div>
        </section>
    </nav>
</div>
