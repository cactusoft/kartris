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
    <div class="dropdownmenu">
        <asp:SiteMapDataSource ID="MenuSitemap" SiteMapProvider="MenuSitemap" runat="server"
            ShowStartingNode="false"></asp:SiteMapDataSource>
        <asp:Menu ID="menFrontEnd" runat="server" Orientation="Horizontal" DataSourceID="MenuSitemap">
        </asp:Menu>
    </div>
</div>
