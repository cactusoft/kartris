<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="_NavigationMenu.ascx.vb" Inherits="UserControls_Back_NavigationMenu" %>
<div class="dropdownmenu" id="backendmenu">
    <asp:SiteMapDataSource ID="_KartrisSitemap" SiteMapProvider="_KartrisSiteMap" runat="server"
        ShowStartingNode="false"></asp:SiteMapDataSource>
    <asp:Menu ID="menBackEnd" runat="server" Orientation="Horizontal" DataSourceID="_KartrisSiteMap">
    </asp:Menu>
</div>







