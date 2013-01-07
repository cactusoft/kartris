<%@ Control Language="VB" AutoEventWireup="false" CodeFile="TopListProducts.ascx.vb"
    Inherits="UserControls_Skin_TopListProducts" %>
<%  If KartSettingsManager.GetKartConfig("frontend.display.topsellers.quantity") <> 0 Then%>
<div class="box" id="toplistproducts">
    <h2 class="blockheader">
        <span><span>
            <asp:Literal ID="litContentTextNewProductsList" runat="server" Text='<%$ Resources: Kartris, ContentText_TopSellerList %>' /></span></span></h2>
    <div class="products products_tabular">
        <asp:Repeater ID="rptTopListProducts" runat="server">
            <ItemTemplate>
                <user:ProductLinkTemplate ID="UC_ProductLinkTemplate" runat="server" />
            </ItemTemplate>
            <SeparatorTemplate>
            </SeparatorTemplate>
        </asp:Repeater>
    </div>
</div>
<%  End If%>