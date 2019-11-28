<%@ Control Language="VB" AutoEventWireup="false" CodeFile="EcommerceTracking.ascx.vb" Inherits="UserControls_Front_EcommerceTracking" %>
<asp:Literal ID="litHiddenBecause" runat="server" />
<asp:PlaceHolder ID="phdEcommerceTracking" runat="server">
<!--
Kartris Google Analytics Ecommerce Tracking
Updated 2019/11/28
-->
    <asp:HiddenField ID="hidCurrencyID" runat="server" />
    <asp:Literal ID="litHeader" runat="server" />

        <asp:Literal ID="litOrderID" runat="server" />,
        <asp:Literal ID="litWebShopName" runat="server" />,
        <asp:Literal ID="litTotal" runat="server" />,
        <asp:Literal ID="litCurrencyIsoCode" runat="server" />,
        <asp:Literal ID="litTax" runat="server" />,
        <asp:Literal ID="litShipping" runat="server" />,
        "items": [
            <asp:Repeater ID="rptOrderItems" runat="server">
                <SeparatorTemplate>,
                </SeparatorTemplate>
                <ItemTemplate>
                    {
                        <asp:Literal ID="litVersionCode" runat="server" />,
                        <asp:Literal ID="litItemName" runat="server" />,
                        <asp:Literal ID="litItemOptions" runat="server" />,
                        <asp:Literal ID="litItemQuantity" runat="server" />,
                        <asp:Literal ID="litItemPrice" runat="server" />
                    }
                </ItemTemplate>
            </asp:Repeater>
        ]
    <asp:Literal ID="litFooter" runat="server" />

</asp:PlaceHolder>