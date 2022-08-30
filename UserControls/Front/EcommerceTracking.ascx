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

<%--<asp:PlaceHolder ID="phdGoogleTagManagerPurchase" runat="server">
<script>
    // Send transaction data with a pageview if available
    // when the page loads. Otherwise, use an event when the transaction
    // data becomes available.
    //dataLayer.push({ ecommerce: null });  // Clear the previous ecommerce object.
    //dataLayer.push({
    //    event: "purchase",
    //    ecommerce: {
    //        transaction_id: "T12345",
    //        affiliation: "Online Store",
    //        value: "59.89",
    //        tax: "4.90",
    //        shipping: "5.99",
    //        currency: "EUR",
    //        coupon: "SUMMER_SALE",
    //        items: [{
    //            item_name: "Triblend Android T-Shirt",
    //            item_id: "12345",
    //            price: "15.25",
    //            item_brand: "Google",
    //            item_category: "Apparel",
    //            item_variant: "Gray",
    //            quantity: 1
    //        }, {
    //            item_name: "Donut Friday Scented T-Shirt",
    //            item_id: "67890",
    //            price: 33.75,
    //            item_brand: "Google",
    //            item_category: "Apparel",
    //            item_variant: "Black",
    //            quantity: 1
    //        }]
    //    }
    //});
    dataLayer.push({ ecommerce: null });  // Clear the previous ecommerce object.
    dataLayer.push({
        event: "purchase",
        ecommerce: {
            transaction_id: "<asp:Literal ID='litOrderID2' runat='server' />",
            affiliation: "<asp:Literal ID='litWebShopName2' runat='server' />",
            value: "<asp:Literal ID='litTotal2' runat='server' />",
            tax: "<asp:Literal ID='litTax2' runat='server' />",
            shipping: "<asp:Literal ID='litShipping2' runat='server' />",
            currency: "<asp:Literal ID='litCurrency2' runat='server' />",
            coupon: "<asp:Literal ID='litCoupon2' runat='server' />",
            items: [<asp:Repeater ID='rptOrderItems2' runat='server'>
                <SeparatorTemplate>,
                </SeparatorTemplate>
                <ItemTemplate>
                    {
                        item_name: "<asp:Literal ID='litItemName2' runat='server' />",
                        item_id: "<asp:Literal ID='litVersionCode2' runat='server' />",
                        price: "<asp:Literal ID='litItemPrice2' runat='server' />",
                        item_brand: "Google",
                        item_category: "Apparel",
                        item_variant: "<asp:Literal ID='litItemOptions2' runat='server' />",
                        quantity: <asp:Literal ID='litItemQuantity2' runat='server' />
                    }
                </ItemTemplate>
            </asp:Repeater>]
        }
    });
</script>
</asp:PlaceHolder>--%>
