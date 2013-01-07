<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="CategoryMenu.ascx.vb"
    Inherits="UserControls_Skin_CategoryMenu" %>
<%@ OutputCache Duration="300" VaryByCustom="culture" VaryByParam="CategoryID" Shared="true" %>
<%
    '-----------------------------------
    'We cache this control for 300 secs,
    'this improves performance but delay
    'in any changes going live is kept
    'to minimum (=5 mins)
    '-----------------------------------
%>
<!-- CategoryMenu - dropdown -->
<div id="categorymenu">
    <div class="box">
        <div class="cssfoldout">
            <asp:Menu ID="menCategory" DataSourceID="srcSiteMap" Orientation="Horizontal" runat="server">
                <DataBindings>
                    <asp:MenuItemBinding DataMember="MenuItem" NavigateUrlField="NavigateUrl" TextField="Text"
                        ToolTipField="ToolTip" ValueField="Value" />
                </DataBindings>
            </asp:Menu>
        </div>
    </div>
</div>
<%  'DataSource %>
<asp:SiteMapDataSource ID="srcSiteMap" SiteMapProvider="CategorySiteMapProvider"
    ShowStartingNode="false" runat="server" />