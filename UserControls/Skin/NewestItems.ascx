<%@ Control Language="VB" AutoEventWireup="false" CodeFile="NewestItems.ascx.vb"
    Inherits="UserControls_Skin_NewestItems" %>
<div id="newestitems">
    <h2 class="blockheader">
        <span><span>
            <asp:Literal ID="litContentTextNewProductsList" runat="server" Text='<%$ Resources: Kartris, ContentText_NewProductsList %>' /></span></span></h2>
    <div class="products products_tabular">
        <asp:Repeater ID="rptNewestItems" runat="server">
            <ItemTemplate>
                <user:ProductTemplateShortened ID="UC_ProductShortened" runat="server" />
            </ItemTemplate>
            <SeparatorTemplate>
            </SeparatorTemplate>
        </asp:Repeater>
    </div>
</div>
