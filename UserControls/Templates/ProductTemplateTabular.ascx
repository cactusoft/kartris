<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductTemplateTabular.ascx.vb" Inherits="ProductTemplateTabular" %>
<!-- product tabular template start -->
<div class="box item loadspinner">
    <div class="pad">
        <asp:Literal ID="litProductID" runat="server" Visible="false" Text='<%# Eval("P_ID") %>'></asp:Literal>
        <div class="imageblock">
            <user:ImageViewer ID="UC_ImageView" runat="server" EnableViewState="False" />
        </div>
        <asp:HyperLink ID="lnkProductName" runat="server" NavigateUrl='<%# Eval("P_ID", "~/Product.aspx?ProductID={0}") %>' CssClass="details">
            <h2>
                <asp:Literal ID="litProductName" runat="server" Text='<%# DisplayProductName() %>'></asp:Literal></h2>
            <div class="minprice" enableviewstate="true" id="divPrice" runat="server" visible='<%# ShowMinPrice(Eval("P_ID")) %>'>
                <asp:Literal ID="litPriceFrom" runat="server" Text="<%$ Resources:Products,ContentText_ProductPriceFrom %>"></asp:Literal>
                <asp:Literal ID="litPriceHidden" runat="server" Text='<%# Eval("MinPrice") %>' Visible="false" />
                <asp:Literal ID="litPriceView" runat="server" />
            </div>
        </asp:HyperLink>
    </div>
</div>
<!-- product tabular template end -->
