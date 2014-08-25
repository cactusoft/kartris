<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="CategoryMenu.ascx.vb"
    Inherits="UserControls_Skin_CategoryMenu" %>
<%@ OutputCache Duration="300" VaryByCustom="culture;user" VaryByParam="CategoryID" Shared="true" %>
<%
    '-----------------------------------
    'We cache this control for 300 secs,
    'this improves performance but delay
    'in any changes going live is kept
    'to minimum (=5 mins)
    
    'Note that we vary cache by culture
    'and user. This way, when a user
    'is logged in, they get a personal
    'cached version. This is necessary
    'because some categories may be
    'available only to some customer
    'groups, so we cannot serve same
    'menu to each user.
    '-----------------------------------
%>
<!-- CategoryMenu - dropdown -->
<div id="categorymenu">
    <nav class="top-bar" data-topbar>
        <div class="box">
            <ul class="title-area show-for-small" style="display:none;">
                <li class="name"><asp:Hyperlink ID="lnkCategories" runat="server" Text="<%$ Resources: Kartris, ContentText_Categories %>" EnableViewState="False" NavigateUrl="~/Category.aspx"></asp:Hyperlink></li>
                <!-- Remove the class "menu-icon" to get rid of menu icon. Take out "Menu" to just have icon alone -->
                <li class="toggle-topbar menu-icon"><a href=""><span>MENU</span></a></li>
            </ul>
            <section class="cssfoldout top-bar-section">
                <asp:Menu ID="menCategory" DataSourceID="srcSiteMap" Orientation="Horizontal" runat="server">
                    <DataBindings>
                        <asp:MenuItemBinding DataMember="MenuItem" NavigateUrlField="NavigateUrl" TextField="Text"
                            ToolTipField="ToolTip" ValueField="Value" />
                    </DataBindings>
                </asp:Menu>
            </section>
        </div>
    </nav>
</div>
<asp:SiteMapDataSource ID="srcSiteMap" SiteMapProvider="CategorySiteMapProvider"
    ShowStartingNode="false" runat="server" />