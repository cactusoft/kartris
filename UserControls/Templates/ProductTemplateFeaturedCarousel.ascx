<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateFeaturedCarousel.ascx.vb" Inherits="ProductTemplateFeaturedCarousel" %>

<asp:Literal ID="litProductID" runat="server" Text='<%# Eval("P_ID") %>' Visible="false" ></asp:Literal>

<div>
    <asp:HyperLink ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>'>
        <img src="<%# FormatImageURL(litProductID.Text) %>" alt="<%# DisplayProductName() %>" />
        <div class="details">
            <h2><%# DisplayProductName() %></h2>
        </div>
        <div class="minprice" id="divPrice" runat="server" visible='<%# IIf(ObjectConfigBLL.GetValue("K:product.callforprice", Eval("P_ID")) = 1 OrElse Not String.IsNullOrEmpty(ObjectConfigBLL.GetValue("K:product.customcontrolname", Eval("P_ID"))), False, True) %>'>
            <asp:Literal ID="litPriceFrom" runat="server" Text="<%$ Resources:Products,ContentText_ProductPriceFrom %>"></asp:Literal>
            <asp:Literal ID="litPriceHidden" runat="server" Text='<%# Eval("MinPrice") %>' Visible="false" />
            <asp:Literal ID="litPriceView" runat="server" />
        </div>
    </asp:HyperLink>
</div>



