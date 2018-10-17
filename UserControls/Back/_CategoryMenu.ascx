<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="False" CodeFile="_CategoryMenu.ascx.vb"
    Inherits="_CategoryMenu" %>
<asp:UpdatePanel ID="updMenu" runat="server" UpdateMode="Conditional">
    <contenttemplate>
            <div class="squarebuttons blackbuttons">
            <asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/Admin/_Default.aspx"
                        ToolTip="<%$ Resources: _Kartris, BackMenu_Home %>"
                        text="<%$ Resources: _Kartris, BackMenu_Home %>" CssClass="homebutton"></asp:HyperLink>
                        <asp:HyperLink ID="lnkCategory" runat="server" NavigateUrl="~/Admin/_Category.aspx"
                        ToolTip="<%$ Resources: _Category, BackMenu_Categories %>"
                        text="<%$ Resources: _Category, BackMenu_Categories %>" CssClass="categoriesbutton"></asp:HyperLink>
                    <asp:LinkButton ID="btnRefresh" runat="server" Text="<%$ Resources: _Kartris, ContentText_Refresh %>"
                        CssClass="linkbutton icon_edit refreshbutton" ToolTip="<%$ Resources: _Kartris, ContentText_RefreshKartrisCaches %>" />
            </div>
            <div class="spacer"></div>
            <div id="categorymenu">

                <asp:TreeView ID="tvwCategory" runat="server" ExpandImageUrl="~/Skins/Admin/Images/expand.gif"
                    CollapseImageUrl="~/Skins/Admin/Images/collapse.gif"
                    NoExpandImageUrl="~/Skins/Admin/Images/noexpand.gif" ExpandDepth="0" SelectedNodeStyle-CssClass="selecteditem"
                    HoverNodeStyle-CssClass="hovernode" LeafNodeStyle-CssClass="leafnode" NodeStyle-CssClass="nodestyle"
                    NodeIndent="15" CssClass="treeview">
                </asp:TreeView>
            </div>
    </contenttemplate>
</asp:UpdatePanel>
<script>
// This is a jquery function to add the site ID to the URLs in the treeview where required
function AddSiteIDParameter()
{
$("a.leafnode").attr("href", function(i, href) {
  return href + '&test=testing';
});
}
</script>
